import 'package:intl/intl.dart';
import '/feature/accounts/data/model/account_active_model.dart';
import '/feature/accounts/presentation/bloc/account/account_bloc.dart';
import '/feature/expense/presentation/bloc/expense_list/expense_bloc.dart';
import '/feature/return/sales_return/data/model/sales_invoice_model.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../../data/model/sales_return_create_model.dart';
import '../sales_return_bloc/sales_return_bloc.dart';

class MobileCreateSalesReturnScrenn extends StatefulWidget {
  final VoidCallback? onSuccess;

  const MobileCreateSalesReturnScrenn({super.key, this.onSuccess});

  @override
  State<MobileCreateSalesReturnScrenn> createState() =>
      _CreateSalesReturnScreenState();
}

class _CreateSalesReturnScreenState
    extends State<MobileCreateSalesReturnScrenn> {
  List<Item> products = [];
  TextEditingController customerNameController = TextEditingController();
  TextEditingController returnDateController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  TextEditingController returnChargeController = TextEditingController(
    text: "0",
  );
  TextEditingController returnChargeAmountController = TextEditingController(
    text: "0.00",
  );
  TextEditingController subtotalController = TextEditingController(
    text: "0.00",
  );
  TextEditingController totalAmountController = TextEditingController(
    text: "0.00",
  );

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? _selectedPaymentMethod;
  String? _returnChargeType = 'fixed';
  AccountActiveModel? _selectedAccount;
  SalesInvoiceModel? _selectedInvoice;

  @override
  void initState() {
    super.initState();

    // Load initial data
    context.read<AccountBloc>().add(FetchAccountActiveList(context));
    context.read<SalesReturnBloc>().add(FetchInvoiceList(context));

    // Set initial return date to today
    returnDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Initialize controllers from bloc if needed
    final bloc = context.read<SalesReturnBloc>();
    if (bloc.selectedInvoice != null) {
      _selectedInvoice = bloc.selectedInvoice;
    }

    // Add listener to return charge controller
    returnChargeController.addListener(_calculateTotals);
  }

  @override
  void dispose() {
    returnChargeController.removeListener(_calculateTotals);
    customerNameController.dispose();
    returnDateController.dispose();
    remarkController.dispose();
    returnChargeController.dispose();
    returnChargeAmountController.dispose();
    subtotalController.dispose();
    totalAmountController.dispose();
    super.dispose();
  }

  void _calculateTotals() {
    if (_returnChargeType == null) return;

    double subtotal = _calculateSubtotal();
    double returnCharge = double.tryParse(returnChargeController.text) ?? 0.0;
    double returnChargeAmount = 0.0;
    double totalAmount = 0.0;

    // Calculate return charge amount
    if (_returnChargeType == 'percentage') {
      returnChargeAmount = subtotal * (returnCharge / 100);
    } else {
      returnChargeAmount = returnCharge;
    }

    // Calculate total amount (subtotal + return charge)
    totalAmount = subtotal + returnChargeAmount;

    // Update controllers
    setState(() {
      subtotalController.text = subtotal.toStringAsFixed(2);
      returnChargeAmountController.text = returnChargeAmount.toStringAsFixed(2);
      totalAmountController.text = totalAmount.toStringAsFixed(2);
    });
  }

  double _calculateSubtotal() {
    double subtotal = 0.0;

    for (var item in products) {
      double itemPrice = item.unitPrice ?? 0.0;
      int quantity = item.quantity ?? 0;
      double discount = item.discount ?? 0.0;
      String discountType = item.discountType ?? 'fixed';

      double itemTotal = itemPrice * quantity;

      // Apply discount
      if (discountType == 'percentage') {
        itemTotal = itemTotal - (itemTotal * discount / 100);
      } else {
        itemTotal = itemTotal - discount;
      }

      subtotal += itemTotal;
    }

    return subtotal;
  }

  void onProductChanged(SalesInvoiceModel? newVal) {
    if (newVal == null) return;

    setState(() {
      _selectedInvoice = newVal;

      // Update customer name
      String name = newVal.customerName ?? "Walk-in Customer";
      customerNameController.text = name;

      // Clear and update product details
      products.clear();
      if (newVal.items != null && newVal.items!.isNotEmpty) {
        for (var item in newVal.items!) {
          // Extract product ID - handle different field names
          int? productId = item.productId ?? item.id;

          products.add(
            Item(
              productId: productId ?? 0,
              productName: item.productName ?? 'Unknown Product',
              unitPrice:
                  double.tryParse(item.unitPrice?.toString() ?? "0") ?? 0.0,
              totalPrice:
                  double.tryParse(item.subtotal?.toString() ?? "0") ?? 0.0,
              quantity: item.quantity ?? 1,
              damageQuantity: 0,
              // Initialize damage quantity as 0
              discount:
                  double.tryParse(item.discount?.toString() ?? "0") ?? 0.0,
              discountType: item.discountType ?? "fixed",
              originalQuantity: item.quantity ?? 1,
            ),
          );
        }
      }

      // Recalculate totals after products update
      _calculateTotals();
    });
  }

  void _updateProductQuantity(
    int index,
    int newQuantity, {
    bool isDamage = false,
  }) {
    if (newQuantity < 0) return;

    setState(() {
      final item = products[index];
      final originalMaxQuantity = item.originalQuantity ?? item.quantity ?? 1;

      if (isDamage) {
        // Update damage quantity
        final maxDamage = item.quantity ?? 0;
        if (newQuantity > maxDamage) {
          newQuantity = maxDamage;
          showCustomToast(
            context: context,
            title: 'Alert!',
            description:
                'Damage quantity cannot exceed returned quantity ($maxDamage)',
            icon: Icons.error,
            primaryColor: Colors.redAccent,
          );
        }
        item.damageQuantity = newQuantity;
      } else {
        // Update return quantity
        if (newQuantity > originalMaxQuantity) {
          newQuantity = originalMaxQuantity;
          showCustomToast(
            context: context,
            title: 'Alert!',
            description: 'Cannot return more than $originalMaxQuantity items',
            icon: Icons.error,
            primaryColor: Colors.redAccent,
          );
        }
        item.quantity = newQuantity;

        // Update damage quantity if it exceeds new quantity
        if (item.damageQuantity! > newQuantity) {
          item.damageQuantity = newQuantity;
        }

        // Recalculate item total
        double itemPrice = item.unitPrice ?? 0.0;
        double discount = item.discount ?? 0.0;
        String discountType = item.discountType ?? 'fixed';

        double itemTotal = itemPrice * newQuantity;

        // Apply discount
        if (discountType == 'percentage') {
          itemTotal = itemTotal - (itemTotal * discount / 100);
        } else {
          itemTotal = itemTotal - discount;
        }

        item.totalPrice = itemTotal;
      }

      // Recalculate totals after quantity change
      _calculateTotals();
    });
  }

  void _removeProduct(int index) {
    setState(() {
      if (index >= 0 && index < products.length) {
        products.removeAt(index);
        _calculateTotals();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: AppTextStyle.getResponsivePaddingBody(context),
      child: BlocListener<SalesReturnBloc, SalesReturnState>(
        listener: (context, state) {
          if (state is SalesReturnCreateLoading) {
            appLoader(context, "Creating Sales Return...");
          } else if (state is SalesReturnCreateSuccess) {
            Navigator.pop(context); // Close loader
            Navigator.pop(context); // Close dialog
            widget.onSuccess?.call();
            showCustomToast(
              context: context,
              title: 'Success!',
              description: state.message,
              icon: Icons.check_circle,
              primaryColor: Colors.green,
            );
          } else if (state is SalesReturnError) {
            Navigator.pop(context); // Close loader
            showCustomToast(
              context: context,
              title: 'Error!',
              description: state.content,
              icon: Icons.error,
              primaryColor: Colors.redAccent,
            );
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Create Sales Return",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor(context),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Invoice Selection
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(child: _buildReceiptNumberDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCustomerNameField()),

                  ],
                ),


                // Return Date
                const SizedBox(height: 8),

                // Return Charge Section
                _buildReturnChargeSection(),
                const SizedBox(height: 8),

                // Payment Method and Account
                Row(
                  children: [
                    Expanded(child: _buildPaymentMethodDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildAccountDropdown()),
                  ],
                ),
                const SizedBox(height: 8),

                // Products Section
                if (products.isNotEmpty) ...[
                  _buildProductsList(),
                  const SizedBox(height: 8),
                ],

                // Summary Section
                if (products.isNotEmpty) ...[
                  _buildSummarySection(),
                  const SizedBox(height: 8),
                ],

                // Remark Field
                _buildRemarkField(),
                const SizedBox(height: 8),

                // Submit Button
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptNumberDropdown() {
    return BlocBuilder<SalesReturnBloc, SalesReturnState>(
      builder: (context, state) {
        final bloc = context.read<SalesReturnBloc>();

        if (state is InvoiceListLoading) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 12),
                Text("Loading invoices..."),
              ],
            ),
          );
        }

        return AppDropdown<SalesInvoiceModel>(
          label: "Receipt Number",
          isSearch: true,
          context: context,
          hint: _selectedInvoice?.invoiceNo ?? "Select Receipt Number",
          isRequired: true,
          value: _selectedInvoice,
          itemList: bloc.invoiceList,
          onChanged: (newVal) {
            if (newVal != null) {
              onProductChanged(newVal);
            }
          },
          validator: (value) =>
              value == null ? 'Please select Receipt Number' : null,
          itemBuilder: (item) => DropdownMenuItem<SalesInvoiceModel>(
            value: item,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.invoiceNo ?? 'Unknown',
                  style: TextStyle(
                    color:AppColors.blackColor(context),
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Customer: ${item.customerName ?? "Walk-in Customer"}',
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
                Text(
                  'Total: ৳${item.grandTotal?.toStringAsFixed(2) ?? "0.00"}',
                  style: TextStyle(
                    color: AppColors.primaryColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerNameField() {
    return CustomInputField(
      isRequiredLable: true,
      controller: customerNameController,
      hintText: 'Customer Name',
      fillColor: Colors.white,
      readOnly: true,
      keyboardType: TextInputType.text,
      onChanged: (value) {},
    );
  }

  Widget _buildReturnDateField() {
    return CustomInputField(
      isRequiredLable: true,
      controller: returnDateController,
      hintText: 'DD-MM-YYYY',
      fillColor: Colors.white,
      readOnly: true,
      keyboardType: TextInputType.text,
      validator: (value) => value!.isEmpty ? 'Please enter Return Date' : null,
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            returnDateController.text = DateFormat(
              'dd-MM-yyyy',
            ).format(pickedDate);
          });
        }
      },
    );
  }

  Widget _buildReturnChargeSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Return Charge',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor(context),
            ),
          ),
          const SizedBox(height: 6),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: CustomInputField(
                  labelText: "Return Charge",
                  controller: returnChargeController,
                  hintText: '0.00',
                  fillColor: Colors.white,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _calculateTotals();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppDropdown<String>(
                  label: "Type",
                  context: context,
                  hint: _returnChargeType ?? "Select",
                  value: _returnChargeType,
                  itemList: ['fixed', 'percentage'],
                  onChanged: (newVal) {
                    setState(() {
                      _returnChargeType = newVal;
                      _calculateTotals();
                    });
                  },
                  itemBuilder: (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item == 'percentage' ? '%' : 'Fixed',
                      style: TextStyle(
                        color:AppColors.blackColor(context),
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),


            ],
          ),

          Row(children: [
            Expanded(child: _buildReturnDateField()),
            const SizedBox(width: 12),

            Expanded(
              child: CustomInputField(
                labelText: "Charge Amount",
                controller: returnChargeAmountController,
                hintText: '0.00',
                fillColor: Colors.white,
                readOnly: true,
                keyboardType: TextInputType.number,
              ),
            ),
          ],)

        ],
      ),
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        return AppDropdown<String>(
          label: "Payment Method ",
          context: context,
          hint: _selectedPaymentMethod ?? "Select Payment Method",
          isRequired: true,
          value: _selectedPaymentMethod,
          itemList: ['cash', 'bank', 'mobile', 'card', 'credit'],
          onChanged: (newVal) {
            setState(() {
              _selectedPaymentMethod = newVal;
            });
          },
          validator: (value) =>
              value == null ? 'Please select Payment Method' : null,
          itemBuilder: (item) => DropdownMenuItem(
            value: item,
            child: Text(
              item.toUpperCase(),
              style: TextStyle(
                color:AppColors.blackColor(context),
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountDropdown() {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        return AppDropdown<AccountActiveModel>(
          label: "Account",
          context: context,
          hint: _selectedAccount?.name ?? "Select Account",
          isRequired: true,
          value: _selectedAccount,
          itemList: context.read<AccountBloc>().activeAccount,
          onChanged: (newVal) {
            setState(() {
              _selectedAccount = newVal;
            });
          },
          validator: (value) => value == null ? 'Please select Account' : null,
          itemBuilder: (item) => DropdownMenuItem<AccountActiveModel>(
            value: item,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name ?? 'Unknown Account',
                  style: TextStyle(
                    color:AppColors.blackColor(context),
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.acType != null)
                  Text(
                    'Type: ${item.acType}',
                    style: TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Products to Return",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor(context),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _buildProductItem(index),
        ),
      ],
    );
  }

  Widget _buildProductItem(int index) {
    final item = products[index];
    final originalMaxQuantity = item.originalQuantity ?? item.quantity ?? 1;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.productName ?? 'Unknown Product',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (products.length > 1)
                  IconButton(
                    onPressed: () => _removeProduct(index),
                    icon: Icon(Icons.delete, size: 20, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Quantity Controls
            Row(
              children: [
                _buildQuantityControl(
                  label: "Return Qty:",
                  quantity: item.quantity ?? 0,
                  maxQuantity: originalMaxQuantity,
                  onIncrement: () =>
                      _updateProductQuantity(index, (item.quantity ?? 0) + 1),
                  onDecrement: () =>
                      _updateProductQuantity(index, (item.quantity ?? 0) - 1),
                  color: AppColors.primaryColor(context),
                ),
                const SizedBox(width: 16),
                _buildQuantityControl(
                  label: "Damage Qty:",
                  quantity: item.damageQuantity ?? 0,
                  maxQuantity: item.quantity ?? 0,
                  onIncrement: () => _updateProductQuantity(
                    index,
                    (item.damageQuantity ?? 0) + 1,
                    isDamage: true,
                  ),
                  onDecrement: () => _updateProductQuantity(
                    index,
                    (item.damageQuantity ?? 0) - 1,
                    isDamage: true,
                  ),
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Price Information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriceInfo("Unit Price", item.unitPrice ?? 0),
                _buildPriceInfo("Discount", item.discount ?? 0),
                _buildPriceInfo("Total", item.totalPrice ?? 0, isTotal: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl({
    required String label,
    required int quantity,
    required int maxQuantity,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, size: 18, color: color),
                  onPressed: quantity > 0 ? onDecrement : null,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
                Expanded(
                  child: Text(
                    quantity.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, size: 18, color: color),
                  onPressed: quantity < maxQuantity ? onIncrement : null,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Text(
            'Max: $maxQuantity',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(String label, double amount, {bool isTotal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey)),
        Text(
          '৳${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primaryColor(context) :AppColors.blackColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Return Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor(context),
            ),
          ),
          const SizedBox(height: 12),

          // Subtotal
          _buildSummaryRow(
            label: 'Subtotal:',
            value: double.tryParse(subtotalController.text) ?? 0.0,
            color: Colors.black87,
          ),

          // Return Charge
          _buildSummaryRow(
            label: 'Return Charge:',
            value: double.tryParse(returnChargeAmountController.text) ?? 0.0,
            color: Colors.orange.shade700,
            showType: true,
          ),

          Divider(height: 20, thickness: 1, color: Colors.grey.shade300),

          // Total Amount
          _buildSummaryRow(
            label: 'Total Return Amount:',
            value: double.tryParse(totalAmountController.text) ?? 0.0,
            color: AppColors.primaryColor(context),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required double value,
    required Color color,
    bool showType = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTotal ? 16 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                  color: color,
                ),
              ),
              if (showType && _returnChargeType == 'percentage')
                Text(
                  ' (${returnChargeController.text}%)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
          Text(
            '৳${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkField() {
    return CustomInputField(
      controller: remarkController,
      hintText: 'Enter reason for return...',
      fillColor: Colors.white,
      keyboardType: TextInputType.multiline,
      onChanged: (value) {},
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppButton(
          name: "Cancel",
          size: 100,
          color: AppColors.redAccent,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        AppButton(size: 150, name: "Submit Return", onPressed: _submitReturn),
      ],
    );
  }

  void _submitReturn() {
    if (!formKey.currentState!.validate()) {
      showCustomToast(
        context: context,
        title: 'Validation Error!',
        description: 'Please fill all required fields',
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );
      return;
    }

    if (products.isEmpty) {
      showCustomToast(
        context: context,
        title: 'Alert!',
        description: 'Please select products to return',
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );
      return;
    }

    // Validate product quantities
    for (var product in products) {
      if (product.quantity == null || product.quantity! <= 0) {
        showCustomToast(
          context: context,
          title: 'Alert!',
          description: 'Quantity must be greater than 0 for all products',
          icon: Icons.error,
          primaryColor: Colors.redAccent,
        );
        return;
      }

      if (product.damageQuantity! > product.quantity!) {
        showCustomToast(
          context: context,
          title: 'Alert!',
          description: 'Damage quantity cannot exceed return quantity',
          icon: Icons.error,
          primaryColor: Colors.redAccent,
        );
        return;
      }
    }

    // Parse return date
    DateTime? returnDate;
    try {
      returnDate = DateFormat('dd-MM-yyyy').parse(returnDateController.text);
    } catch (e) {
      showCustomToast(
        context: context,
        title: 'Error!',
        description: 'Invalid date format. Use DD-MM-YYYY',
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );
      return;
    }

    // Validate account
    if (_selectedAccount == null) {
      showCustomToast(
        context: context,
        title: 'Error!',
        description: 'Please select an account for the return',
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );
      return;
    }

    // Validate payment method
    if (_selectedPaymentMethod == null || _selectedPaymentMethod!.isEmpty) {
      showCustomToast(
        context: context,
        title: 'Error!',
        description: 'Please select a payment method',
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );
      return;
    }

    // Create request items
    List<Map<String, dynamic>> returnItems = products.map((product) {
      return {
        "product_id": product.productId,
        "quantity": product.quantity,
        "damage_quantity": product.damageQuantity,
        "unit_price": product.unitPrice,
        "discount": product.discount,
        "discount_type": product.discountType,
      };
    }).toList();

    // Get calculated amounts
    double totalAmount = double.tryParse(totalAmountController.text) ?? 0.0;

    // Create request body
    Map<String, dynamic> body = {
      "customer_name": customerNameController.text,
      "return_date": DateFormat('yyyy-MM-dd').format(returnDate),
      "account_id": _selectedAccount!.id,
      "payment_method": _selectedPaymentMethod,
      "reason": remarkController.text,
      "return_charge": double.tryParse(returnChargeController.text) ?? 0.0,
      "return_charge_type": _returnChargeType ?? 'fixed',
      "return_amount": totalAmount, // Send calculated total
      "items": returnItems,
    };

    // If we have an invoice reference
    if (_selectedInvoice != null && _selectedInvoice!.invoiceNo != null) {
      body["receipt_no"] = _selectedInvoice!.invoiceNo;
    }

    // Log for debugging

    // Dispatch the event
    context.read<SalesReturnBloc>().add(
      SalesReturnCreate(
        context: context,
        body: SalesReturnCreateModel(
          customerName: customerNameController.text,
          returnDate: returnDate,
          accountId: _selectedAccount!.id,
          paymentMethod: _selectedPaymentMethod,
          reason: remarkController.text,
          returnCharge: double.tryParse(returnChargeController.text) ?? 0.0,
          returnChargeType: _returnChargeType,
          returnAmount: totalAmount,
          // Pass calculated amount
          items: products
              .map(
                (item) => SalesReturnItemCreate(
                  productId: item.productId!,
                  quantity: item.quantity!,
                  damageQuantity: item.damageQuantity!,
                  unitPrice: item.unitPrice!,
                  discount: item.discount ?? 0,
                  discountType: item.discountType,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class Item {
  int? productId;
  String? productName;
  double? unitPrice;
  int? quantity;
  int? damageQuantity;
  double? totalPrice;
  double? discount;
  String? discountType;
  int? originalQuantity;

  Item({
    required this.productId,
    this.productName,
    this.unitPrice,
    this.quantity,
    this.damageQuantity = 0,
    this.totalPrice,
    this.discount,
    this.discountType,
    this.originalQuantity,
  });
}
