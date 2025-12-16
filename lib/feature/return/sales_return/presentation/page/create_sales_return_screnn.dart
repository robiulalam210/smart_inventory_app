import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meherin_mart/feature/accounts/data/model/account_active_model.dart';
import 'package:meherin_mart/feature/return/sales_return/data/model/sales_invoice_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
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
    context.read<SalesReturnBloc>().add(FetchInvoiceList(context));

    // Setting initial return date
    context.read<SalesReturnBloc>().returnDateTextController.text = appWidgets
        .convertDateTimeDDMMYYYY(DateTime.now());
  }

  void onProductChanged(SalesInvoiceModel? newVal) {
    if (newVal == null) return;

    print(newVal);
    print(newVal.invoiceNo);
    // DEBUG: Print the invoice data to see structure
    print("📦 Invoice Data Received:");
    print("Invoice No: ${newVal.invoiceNo}");
    print("Customer: ${newVal.customerName}");

    if (newVal.items != null) {
      print("Items count: ${newVal.items!.length}");
      for (var i = 0; i < newVal.items!.length; i++) {
        var item = newVal.items![i];
        print("Item $i:");
        print("  - productName: ${item.productName}");
        print("  - productId: ${item.id}");
        print("  - quantity: ${item.quantity}");
        print("  - unitPrice: ${item.unitPrice}");
        print("  - subtotal: ${item.subtotal}");
        // Print ALL fields to see what's available
        print("  - All fields: ${item.toJson()}");
      }
    }

    setState(() {
      // Update customer name
      String name = newVal.customerName ?? "Walk-in-customer";
      customerNameController.text = name;

      // Clear and update product details
      products.clear();
      if (newVal.items != null) {
        for (var item in newVal.items!) {
          // FIX: Try multiple possible field names for product ID
          int? productId =
              item.productId ??
              item
                  .id // if snake_case
                  ; // if nested object

          if (productId == null) {
            print(
              "⚠️ WARNING: Could not find productId for ${item.productName}",
            );
            print("   Available fields: ${item.toJson().keys.toList()}");
          }

          products.add(
            Item(
              productId: productId,
              productName: item.productName,
              unitPrice:
                  double.tryParse(item.unitPrice?.toString() ?? "0") ?? 0.0,
              totalPrice:
                  double.tryParse(item.subtotal?.toString() ?? "0") ?? 0.0,
              quantity: item.quantity ?? 1,
              discount:
                  double.tryParse(item.discount?.toString() ?? "0") ?? 0.0,
              discountType: item.discountType ?? "fixed",
              originalQuantity: item.quantity ?? 1,
            ),
          );
        }
      }
    });
  }

  void _updateProductQuantity(int index, int newQuantity) {
    if (newQuantity < 0) return;

    setState(() {
      final item = products[index];
      final originalMaxQuantity = item.originalQuantity ?? item.quantity ?? 1;

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
    return Container(
      // color: AppColors.bg,

      decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
    ),
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
              Navigator.pop(context);
            } else if (state is InvoiceError) {
              Navigator.pop(context);
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
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                      "Create Sales Return" ,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: _buildReceiptNumberDropdown()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildCustomerNameField()),
                    ],
                  ),

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
    );
  }

  Widget _buildReceiptNumberDropdown() {
    return BlocBuilder<SalesReturnBloc, SalesReturnState>(
      buildWhen: (previous, current) {
        return current is InvoiceListLoading ||
            current is InvoiceListSuccess ||
            current is InvoiceError;
      },
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
          hint: bloc.selectedInvoice?.invoiceNo ?? "Select Receipt Number",
          isRequired: true,
          value: bloc.selectedInvoice,
          itemList: bloc.invoiceList,
          onChanged: (newVal) {
            if (newVal != null) {
              setState(() {
                bloc.selectedInvoice = newVal;
                onProductChanged(newVal);
              });
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
                  style: const TextStyle(
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
          style: AppTextStyle.cardTitle(
            context,
          ).copyWith(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (context, index) => const SizedBox(height: 4),
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
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName ?? 'Unknown Product',
                        style: AppTextStyle.cardTitle(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.productId != null)
                        Text(
                          'ID: ${item.productId}',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Quantity:',
                      style: AppTextStyle.cardLevelText(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
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
                                _updateProductQuantity(
                                  index,
                                  item.quantity! - 1,
                                );
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
                                _updateProductQuantity(
                                  index,
                                  item.quantity! + 1,
                                );
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
                      style: AppTextStyle.cardLevelText(
                        context,
                      ).copyWith(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unit Price:',
                      style: AppTextStyle.cardLevelText(
                        context,
                      ).copyWith(fontSize: 12),
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
                      style: AppTextStyle.cardLevelText(
                        context,
                      ).copyWith(fontSize: 12),
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
                      style: AppTextStyle.cardLevelText(
                        context,
                      ).copyWith(fontSize: 12),
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
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Return Amount:',
            style: AppTextStyle.cardTitle(
              context,
            ).copyWith(fontWeight: FontWeight.bold, fontSize: 16),
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
    );
  }

  Widget _buildAdditionalFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildPaymentMethodDropdown()),
            const SizedBox(width: 8),
            Expanded(child: _buildAccountDropdown()),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildReturnDateField()),
            const SizedBox(width: 8),
            Expanded(child: _buildRemarkField()),
          ],
        ),
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
        context.read<MoneyReceiptBloc>().selectedPaymentMethod = newVal
            .toString();
        setState(() {});
      },
      validator: (value) =>
          value == null ? 'Please select a payment method' : null,
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

        final filteredList = moneyReceiptBloc.selectedPaymentMethod.isNotEmpty
            ? context.read<AccountBloc>().activeAccount.where((item) {
                return item.acType?.toLowerCase() ==
                    moneyReceiptBloc.selectedPaymentMethod.toLowerCase();
              }).toList()
            : context.read<AccountBloc>().activeAccount;

        return AppDropdown<AccountActiveModel>(
          label: "Account",
          context: context,
          hint: salesReturnBloc.selectedAccount?.name ?? "Select Account",
          isLabel: false,
          isRequired: true,
          isNeedAll: false,
          value: salesReturnBloc.selectedAccount,
          itemList: filteredList,
          onChanged: (newVal) {
            if (newVal != null) {
              setState(() {
                salesReturnBloc.selectedAccount = newVal;
                moneyReceiptBloc.selectedAccount = newVal.name ?? "";
                moneyReceiptBloc.selectedAccountId =
                    newVal.id?.toString() ?? "";
              });
            }
          },
          validator: (value) =>
              value == null ? 'Please select an account' : null,
          itemBuilder: (item) => DropdownMenuItem<AccountActiveModel>(
            value: item,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name ?? 'Unknown Account',
                  style: const TextStyle(
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
    return Row(
      spacing: 20,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppButton(size: 100,name: "Cancel",color: AppColors.redAccent,onPressed: (){AppRoutes.pop(context);},),
        BlocBuilder<SalesReturnBloc, SalesReturnState>(
          builder: (context, state) {
            return AppButton(
              size: 200,
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

                  // VALIDATE: Check if any product has null productId
                  List<Item> validProducts = products.where((product) {
                    if (product.productId == null) {
                      print(
                        "❌ Invalid product: ${product.productName} has null productId",
                      );
                      return false;
                    }
                    return (product.quantity ?? 0) > 0;
                  }).toList();

                  if (validProducts.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          products.any((p) => p.productId == null)
                              ? 'Some products have invalid IDs. Please check console.'
                              : 'Please select at least one product with quantity > 0',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  var returnProducts = validProducts.map((product) {
                    print(
                      "✅ Sending product: ${product.productName}, ID: ${product.productId}",
                    );
                    return {
                      "product_id": product.productId,
                      "quantity": product.quantity,
                      "unit_price": product.unitPrice,
                      "discount": product.discount,
                      "discount_type": product.discountType ?? "fixed",
                      "total": product.totalPrice,
                    };
                  }).toList();

                  Map<String, dynamic> body = {
                    "items": returnProducts,
                    "return_date": appWidgets.convertDateTime(
                      DateFormat("dd-MM-yyyy").parse(
                        context
                            .read<SalesReturnBloc>()
                            .returnDateTextController
                            .text
                            .trim(),
                        true,
                      ),
                      "yyyy-MM-dd",
                    ),
                    "invoice_no": context
                        .read<SalesReturnBloc>()
                        .selectedInvoice
                        ?.invoiceNo
                        .toString(),
                    "note": context
                        .read<SalesReturnBloc>()
                        .remarkController
                        .text
                        .trim(),
                    "discount":
                        double.tryParse(
                          context
                              .read<SalesReturnBloc>()
                              .selectedInvoice!
                              .overallDiscount
                              .toString(),
                        ) ??
                        0.0,
                    "discount_type":
                        context
                            .read<SalesReturnBloc>()
                            .selectedInvoice
                            ?.overallDiscountType ??
                        "fixed",
                    "vat":
                        double.tryParse(
                          context
                              .read<SalesReturnBloc>()
                              .selectedInvoice!
                              .overallVatAmount
                              .toString(),
                        ) ??
                        0.0,
                    "vat_type":
                        context
                            .read<SalesReturnBloc>()
                            .selectedInvoice
                            ?.overallVatType ??
                        "fixed",
                    "delivary_charge":
                        double.tryParse(
                          context
                              .read<SalesReturnBloc>()
                              .selectedInvoice!
                              .overallDeliveryCharge
                              .toString(),
                        ) ??
                        0.0,
                    "delivery_charge_type":
                        context
                            .read<SalesReturnBloc>()
                            .selectedInvoice
                            ?.overallDeliveryType ??
                        "fixed",
                    "service_charge":
                        double.tryParse(
                          context
                              .read<SalesReturnBloc>()
                              .selectedInvoice!
                              .overallServiceCharge
                              .toString(),
                        ) ??
                        0.0,
                    "service_charge_type":
                        context
                            .read<SalesReturnBloc>()
                            .selectedInvoice
                            ?.overallServiceType ??
                        "fixed",
                    "payment_method": context
                        .read<MoneyReceiptBloc>()
                        .selectedPaymentMethod
                        .toString(),
                    "account_id": context
                        .read<MoneyReceiptBloc>()
                        .selectedAccountId,
                    "return_amount": _totalReturnAmount,
                  };

                  print("📦 Final request body:");
                  print(body);

                  context.read<SalesReturnBloc>().add(
                    SalesReturnCreate(body: body, context: context),
                  );
                }
              },
            );
          },
        ),
      ],
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
  int? originalQuantity;

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
