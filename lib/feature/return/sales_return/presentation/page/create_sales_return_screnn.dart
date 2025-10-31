import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:smart_inventory/feature/accounts/data/model/account_active_model.dart';
import 'package:smart_inventory/feature/return/sales_return/data/model/sales_invoice_model.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../../expense/presentation/bloc/expense_list/expense_bloc.dart';
import '../../../../money_receipt/presentation/bloc/money_receipt/money_receipt_bloc.dart';
import '../sales_return_bloc/sales_return_bloc.dart';

class CreateSalesReturnScreen extends StatefulWidget {
  const CreateSalesReturnScreen({super.key});

  @override
  State<CreateSalesReturnScreen> createState() =>
      _CreateSalesReturnScreenState();
}

class _CreateSalesReturnScreenState extends State<CreateSalesReturnScreen> {
  List<Item> products = [];
  TextEditingController customerNameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(FetchAccountActiveList(context));

    // Fetch invoice list when screen loads
    context.read<SalesReturnBloc>().add(FetchInvoiceList(context));

    // Setting initial return date
    context.read<SalesReturnBloc>().returnDateTextController.text =
        appWidgets.convertDateTimeDDMMYYYY(DateTime.now());
  }

  void onProductChanged(SalesInvoiceModel? newVal) {
    if (newVal == null) return;

    setState(() {
      // Update customer name
      String name = newVal.customerName ?? "Walk-in-customer";
      customerNameController.text = name;

      // Clear and update product details
      products.clear();
      if (newVal.items != null) {
        for (var item in newVal.items!) {
          products.add(Item(
            productId: item.productId,
            productName: item.productName,
            unitPrice: double.tryParse(item.unitPrice.toString()) ?? 0.0,
            totalPrice: double.tryParse(item.subtotal.toString()) ?? 0.0,
            quantity: item.quantity ?? 1,
            discount: double.tryParse(item.discount.toString()) ?? 0.0,
            discountType: item.discountType,
            originalQuantity: item.quantity ?? 1, // Store original quantity
          ));
        }
      }
    });
  }

  void _updateProductQuantity(int index, int newQuantity) {
    if (newQuantity < 0) return;

    setState(() {
      final item = products[index];
      final originalMaxQuantity = item.originalQuantity ?? item.quantity ?? 1;

      // Don't allow returning more than original quantity
      if (newQuantity > originalMaxQuantity) {
        newQuantity = originalMaxQuantity;

        // Show warning message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot return more than $originalMaxQuantity items'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      item.quantity = newQuantity;
      item.totalPrice = (item.unitPrice ?? 0) * newQuantity;
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text("Create Return Product"),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: AppTextStyle.getResponsivePaddingBody(context),
        child: RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async {
            context.read<AccountBloc>().add(FetchAccountList(context));
            context.read<SalesReturnBloc>().add(FetchInvoiceList(context));
          },
          child: BlocListener<SalesReturnBloc, SalesReturnState>(
            listener: (context, state) {
              if (state is InvoiceListLoading) {
                appLoader(context, "Loading invoices...");
              } else if (state is InvoiceListSuccess) {
                Navigator.pop(context); // Close loader
              } else if (state is InvoiceError) {
                Navigator.pop(context); // Close loader
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.content),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    _buildReceiptNumberDropdown(),
                    const SizedBox(height: 12),
                    _buildCustomerNameField(),
                    const SizedBox(height: 12),
                    if (products.isNotEmpty) _buildProductsList(),
                    if (products.isNotEmpty) _buildTotalAmount(),
                    const SizedBox(height: 12),
                    _buildAdditionalFields(),
                    const SizedBox(height: 20),
                    _buildSubmitButton(),
                  ],
                ),
              ),
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

        // Show loading state
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
          hint: bloc.selectedInvoice?.invoiceNo ?? "Select Receipt Number",
          isRequired: true,
          value: bloc.selectedInvoice,
          itemList: bloc.invoiceList,
          onChanged: (newVal) {
            if (newVal != null) {
              setState(() {
                bloc.selectedInvoice = newVal;
                // Call onProductChanged to update the products list
                onProductChanged(newVal);
              });
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
                  style: const TextStyle(
                    color: AppColors.blackColor,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Customer: ${item.customerName ?? "Walk-in Customer"}',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                  ),
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
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      readOnly: true,
      keyboardType: TextInputType.text,
      onChanged: (value) {},
      autofillHints: '',
    );
  }

  Widget _buildProductsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Products to Return",
          style: AppTextStyle.cardTitle(context).copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
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
      elevation: 2,
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name and Remove Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.productName ?? 'Unknown Product',
                    style: AppTextStyle.cardTitle(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (products.length > 1)
                  IconButton(
                    onPressed: () => _removeProduct(index),
                    icon: const Icon(
                      HugeIcons.strokeRoundedDelete02,
                      size: 20,
                      color: Colors.red,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Quantity Controls
            Row(
              children: [
                Text(
                  'Quantity:',
                  style: AppTextStyle.cardLevelText(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: () {
                          if (item.quantity! > 0) {
                            _updateProductQuantity(index, item.quantity! - 1);
                          }
                        },
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                      Container(
                        width: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          item.quantity.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () {
                          if (item.quantity! < originalMaxQuantity) {
                            _updateProductQuantity(index, item.quantity! + 1);
                          }
                        },
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Max: $originalMaxQuantity',
                  style: AppTextStyle.cardLevelText(context).copyWith(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Price Information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unit Price:',
                      style: AppTextStyle.cardLevelText(context).copyWith(
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '৳${(item.unitPrice ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discount:',
                      style: AppTextStyle.cardLevelText(context).copyWith(
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '৳${(item.discount ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total:',
                      style: AppTextStyle.cardLevelText(context).copyWith(
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '৳${(item.totalPrice ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmount() {
    return Card(
      color: AppColors.primaryColor.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Return Amount:',
              style: AppTextStyle.cardTitle(context).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '৳${_totalReturnAmount.toStringAsFixed(2)}',
              style: AppTextStyle.cardTitle(context).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalFields() {
    return Column(
      children: [
        const SizedBox(height: 12),
        _buildReturnDateField(),
        const SizedBox(height: 12),
        _buildPaymentMethodDropdown(),
        const SizedBox(height: 12),
        _buildAccountDropdown(),
        const SizedBox(height: 12),
        _buildRemarkField(),
      ],
    );
  }

  Widget _buildReturnDateField() {
    return CustomInputField(
      isRequiredLable: true,
      isRequired: true,
      controller: context.read<SalesReturnBloc>().returnDateTextController,
      hintText: 'Return Date',
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      readOnly: true,
      keyboardType: TextInputType.text,
      validator: (value) => value!.isEmpty ? 'Please enter Date' : null,
      onTap: () async {
        FocusScope.of(context).requestFocus(FocusNode());
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          context.read<SalesReturnBloc>().returnDateTextController.text =
              appWidgets.convertDateTimeDDMMYYYY(pickedDate);
        }
      },
      autofillHints: '',
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return AppDropdown(
      label: "Payment Method",
      context: context,
      hint: context.read<MoneyReceiptBloc>().selectedPaymentMethod.isEmpty
          ? "Select Payment Method"
          : context.read<MoneyReceiptBloc>().selectedPaymentMethod,
      isLabel: false,
      isRequired: true,
      value: context.read<MoneyReceiptBloc>().selectedPaymentMethod.isEmpty
          ? null
          : context.read<MoneyReceiptBloc>().selectedPaymentMethod,
      itemList: context.read<ExpenseBloc>().paymentMethod,
      onChanged: (newVal) {
        context.read<MoneyReceiptBloc>().selectedPaymentMethod = newVal.toString();
        setState(() {});
      },
      validator: (value) => value == null ? 'Please select a payment method' : null,
      itemBuilder: (item) => DropdownMenuItem(
        value: item,
        child: Text(
          item.toString(),
          style: const TextStyle(
            color: AppColors.blackColor,
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDropdown() {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        final salesReturnBloc = context.read<SalesReturnBloc>();
        final moneyReceiptBloc = context.read<MoneyReceiptBloc>();

        // Filter accounts based on selected payment method
        final filteredList = moneyReceiptBloc.selectedPaymentMethod.isNotEmpty
            ? context.read<AccountBloc>().activeAccount.where((item) {
          return item.acType?.toLowerCase() ==
              moneyReceiptBloc.selectedPaymentMethod.toLowerCase();
        }).toList()
            : context.read<AccountBloc>().activeAccount;

        return AppDropdown<AccountActiveModel>(
          label: "Account",
          context: context,
          hint: salesReturnBloc.selectedAccount?.acName ?? "Select Account",
          isLabel: false,
          isRequired: true,
          isNeedAll: false,
          value: salesReturnBloc.selectedAccount,
          itemList: filteredList,
          onChanged: (newVal) {
            if (newVal != null) {
              setState(() {
                // Update in SalesReturnBloc
                salesReturnBloc.selectedAccount = newVal;

                // Also update in MoneyReceiptBloc for consistency
                moneyReceiptBloc.selectedAccount = newVal.acName ?? "";
                moneyReceiptBloc.selectedAccountId = newVal.acId?.toString() ?? "";
              });
            }
          },
          validator: (value) => value == null ? 'Please select an account' : null,
          itemBuilder: (item) => DropdownMenuItem<AccountActiveModel>(
            value: item,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.acName ?? 'Unknown Account',
                  style: const TextStyle(
                    color: AppColors.blackColor,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.acType != null)
                  Text(
                    'Type: ${item.acType}',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildRemarkField() {
    return CustomInputField(
      isRequiredLable: true,
      isRequired: false,
      controller: context.read<SalesReturnBloc>().remarkController,
      hintText: 'Product Return Note',
      fillColor: const Color.fromARGB(255, 255, 255, 255),
      keyboardType: TextInputType.text,
      autofillHints: AutofillHints.telephoneNumber,
      onChanged: (value) {},
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<SalesReturnBloc, SalesReturnState>(
      builder: (context, state) {
        return AppButton(
          name: "Submit Return",
          onPressed: () {
            if (formKey.currentState!.validate()) {
              if (products.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select products to return'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              var returnProducts = products
                  .where((product) => (product.quantity ?? 0) > 0)
                  .map((product) => {
                "product_id": product.productId,
                "quantity": product.quantity,
                "unit_price": product.unitPrice,
                "discount": product.discount,
                "discount_type": product.discountType,
                "total": product.totalPrice,
              })
                  .toList();

              if (returnProducts.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select at least one product with quantity > 0'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Map<String, dynamic> body = {
                "items": returnProducts,
                "return_date": appWidgets.convertDateTime(
                  DateFormat("dd-MM-yyyy").parse(
                    context.read<SalesReturnBloc>().returnDateTextController.text.trim(),
                    true,
                  ),
                  "yyyy-MM-dd",
                ),
                "invoice_no": context.read<SalesReturnBloc>().selectedInvoice?.invoiceNo.toString(),
                "note": context.read<SalesReturnBloc>().remarkController.text.trim(),
                "discount": double.tryParse(context.read<SalesReturnBloc>().selectedInvoice!.overallDiscount.toString()),
                "discount_type": context.read<SalesReturnBloc>().selectedInvoice?.overallDiscountType,
                "vat": double.tryParse(context.read<SalesReturnBloc>().selectedInvoice!.overallVatAmount.toString()),
                "vat_type": context.read<SalesReturnBloc>().selectedInvoice?.overallVatType,
                "delivary_charge": double.tryParse(context.read<SalesReturnBloc>().selectedInvoice!.overallDeliveryCharge.toString()),
                "delivery_charge_type": context.read<SalesReturnBloc>().selectedInvoice?.overallDeliveryType,
                "service_charge": double.tryParse(context.read<SalesReturnBloc>().selectedInvoice!.overallServiceCharge.toString()),
                "service_charge_type": context.read<SalesReturnBloc>().selectedInvoice?.overallServiceType,
                "payment_method": context.read<MoneyReceiptBloc>().selectedPaymentMethod.toString(),
                "account_id": context.read<MoneyReceiptBloc>().selectedAccountId,
                "return_amount": _totalReturnAmount,
              };

              context.read<SalesReturnBloc>().add(SalesReturnCreate(body: body, context: context));
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    customerNameController.dispose();
    super.dispose();
  }
}

class Item {
  int? productId;
  String? productName;
  double? unitPrice;
  int? quantity;
  double? totalPrice;
  double? discount;
  String? discountType;
  int? originalQuantity; // Store original purchase quantity

  Item({
    this.productId,
    this.productName,
    this.unitPrice,
    this.totalPrice,
    this.quantity,
    this.discount,
    this.discountType,
    this.originalQuantity,
  });
}