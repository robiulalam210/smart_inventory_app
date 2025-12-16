import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:meherin_mart/feature/accounts/data/model/account_active_model.dart';
import 'package:meherin_mart/feature/accounts/presentation/bloc/account/account_bloc.dart';
import 'package:meherin_mart/feature/expense/presentation/bloc/expense_list/expense_bloc.dart';
import 'package:meherin_mart/feature/money_receipt/presentation/bloc/money_receipt/money_receipt_bloc.dart';
import 'package:meherin_mart/feature/return/sales_return/data/model/sales_invoice_model.dart';
import 'package:meherin_mart/feature/return/sales_return/data/sales_return_create_model.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../../data/model/sales_return_create_model.dart';
import '../sales_return_bloc/sales_return_bloc.dart';

class CreateSalesReturnScreen extends StatefulWidget {
  final VoidCallback? onSuccess;

  const CreateSalesReturnScreen({super.key, this.onSuccess});

  @override
  State<CreateSalesReturnScreen> createState() => _CreateSalesReturnScreenState();
}

class _CreateSalesReturnScreenState extends State<CreateSalesReturnScreen> {
  List<Item> products = [];
  TextEditingController customerNameController = TextEditingController();
  TextEditingController returnDateController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  TextEditingController returnChargeController = TextEditingController(text: "0");
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

          if (productId == null) {
            // Log warning but still add the item
            print("⚠️ WARNING: Could not find productId for ${item.productName}");
          }

          products.add(
            Item(
              productId: productId ?? 0,
              productName: item.productName ?? 'Unknown Product',
              unitPrice: double.tryParse(item.unitPrice?.toString() ?? "0") ?? 0.0,
              totalPrice: double.tryParse(item.subtotal?.toString() ?? "0") ?? 0.0,
              quantity: item.quantity ?? 1,
              damageQuantity: 0, // Initialize damage quantity as 0
              discount: double.tryParse(item.discount?.toString() ?? "0") ?? 0.0,
              discountType: item.discountType ?? "fixed",
              originalQuantity: item.quantity ?? 1,
            ),
          );
        }
      }
    });
  }

  void _updateProductQuantity(int index, int newQuantity, {bool isDamage = false}) {
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
            description: 'Damage quantity cannot exceed returned quantity ($maxDamage)',
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

        // Recalculate total
        item.totalPrice = (item.unitPrice ?? 0) * newQuantity;
      }
    });
  }

  void _removeProduct(int index) {
    setState(() {
      if (index >= 0 && index < products.length) {
        products.removeAt(index);
      }
    });
  }

  double get _totalReturnAmount {
    return products.fold(0.0, (sum, item) => sum + (item.totalPrice ?? 0));
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
                        color: AppColors.primaryColor,
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
                  children: [
                    Expanded(child: _buildReceiptNumberDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCustomerNameField()),
                  ],
                ),
                const SizedBox(height: 16),

                // Return Date and Charge
                Row(
                  children: [
                    Expanded(child: _buildReturnDateField()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildReturnChargeField()),
                  ],
                ),
                const SizedBox(height: 16),

                // Payment Method and Account
                Row(
                  children: [
                    Expanded(child: _buildPaymentMethodDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildAccountDropdown()),
                  ],
                ),
                const SizedBox(height: 16),

                // Products Section
                if (products.isNotEmpty) ...[
                  _buildProductsList(),
                  const SizedBox(height: 16),
                ],

                // Remark Field
                _buildRemarkField(),
                const SizedBox(height: 16),

                // Total and Submit Button
                if (products.isNotEmpty) ...[
                  _buildTotalSection(),
                  const SizedBox(height: 16),
                ],

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
          label: "Receipt Number *",
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
          validator: (value) => value == null ? 'Please select Receipt Number' : null,
          itemBuilder: (item) => DropdownMenuItem<SalesInvoiceModel>(
            value: item,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.invoiceNo ?? 'Unknown',
                  style: TextStyle(
                    color: AppColors.blackColor,
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
                    color: AppColors.primaryColor,
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
            returnDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
          });
        }
      },
    );
  }

  Widget _buildReturnChargeField() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: CustomInputField(
            controller: returnChargeController,
            hintText: '0.00',
            fillColor: Colors.white,
            keyboardType: TextInputType.number,
            onChanged: (value) {},
          ),
        ),
        const SizedBox(width: 8),
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
              });
            },
            itemBuilder: (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item.toUpperCase(),
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        return AppDropdown<String>(
          label: "Payment Method *",
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
          validator: (value) => value == null ? 'Please select Payment Method' : null,
          itemBuilder: (item) => DropdownMenuItem(
            value: item,
            child: Text(
              item.toUpperCase(),
              style: TextStyle(
                color: AppColors.blackColor,
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
          label: "Account *",
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
                    color: AppColors.blackColor,
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
            color: AppColors.primaryColor,
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
                      color: AppColors.primaryColor,
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
                  onIncrement: () => _updateProductQuantity(index, (item.quantity ?? 0) + 1),
                  onDecrement: () => _updateProductQuantity(index, (item.quantity ?? 0) - 1),
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 16),
                _buildQuantityControl(
                  label: "Damage Qty:",
                  quantity: item.damageQuantity ?? 0,
                  maxQuantity: item.quantity ?? 0,
                  onIncrement: () => _updateProductQuantity(index, (item.damageQuantity ?? 0) + 1, isDamage: true),
                  onDecrement: () => _updateProductQuantity(index, (item.damageQuantity ?? 0) - 1, isDamage: true),
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
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: color.withOpacity(0.3)),
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
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        Text(
          '৳${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primaryColor : AppColors.blackColor,
          ),
        ),
      ],
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

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Return Amount:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          Text(
            '৳${_totalReturnAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppButton(
          name: "Cancel",
          color: AppColors.redAccent,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        AppButton(
          name: "Submit Return",
          onPressed: _submitReturn,
        ),
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

    // Create request body
    Map<String, dynamic> body = {
      "customer_name": customerNameController.text,
      "return_date": DateFormat('yyyy-MM-dd').format(returnDate),
      "account_id": _selectedAccount?.id,
      "payment_method": _selectedPaymentMethod,
      "reason": remarkController.text,
      "return_charge": double.tryParse(returnChargeController.text) ?? 0.0,
      "return_charge_type": _returnChargeType ?? 'fixed',
      "items": returnItems,
    };

    // If we have an invoice reference
    if (_selectedInvoice != null && _selectedInvoice!.invoiceNo != null) {
      body["receipt_no"] = _selectedInvoice!.invoiceNo;
    }

    print("📦 Submitting sales return:");
    print(body);

    // Dispatch the event
    context.read<SalesReturnBloc>().add(
      SalesReturnCreate(
        context: context,
        body: SalesReturnCreateModel(
          customerName: customerNameController.text,
          returnDate: returnDate,
          accountId: _selectedAccount?.id,
          paymentMethod: _selectedPaymentMethod,
          reason: remarkController.text,
          returnCharge: double.tryParse(returnChargeController.text) ?? 0.0,
          returnChargeType: _returnChargeType,
          items: products.map((item) => SalesReturnItemCreate(
            productId: item.productId!,
            quantity: item.quantity!,
            damageQuantity: item.damageQuantity!,
            unitPrice: item.unitPrice!,
            discount: item.discount ?? 0,
            discountType: item.discountType,
          )).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    customerNameController.dispose();
    returnDateController.dispose();
    remarkController.dispose();
    returnChargeController.dispose();
    super.dispose();
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