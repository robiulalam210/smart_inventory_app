import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/feature/return/purchase_return/data/model/purchase_invoice_model.dart';
import '/feature/supplier/data/model/supplier_active_model.dart';
import '/feature/supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';

import '../../../../../../core/configs/app_colors.dart';
import '../../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../../../../core/widgets/app_dropdown.dart';
import '../../../../../../core/widgets/app_loader.dart';
import '../../../../../../core/widgets/input_field.dart';
import '../../../../../../core/widgets/show_custom_toast.dart';
import '../../../../../accounts/data/model/account_active_model.dart';
import '../../../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../../../expense/presentation/bloc/expense_list/expense_bloc.dart';
import '../../bloc/purchase_return/purchase_return_bloc.dart';

class CreatePurchaseReturnScreen extends StatefulWidget {
  const CreatePurchaseReturnScreen({super.key});

  @override
  State<CreatePurchaseReturnScreen> createState() =>
      _CreatePurchaseReturnScreenState();
}

class _CreatePurchaseReturnScreenState
    extends State<CreatePurchaseReturnScreen> {
  List<Item> products = [];
  final TextEditingController _returnChargeController = TextEditingController(text: "0");
  final TextEditingController _returnAmountController = TextEditingController(text: "0.00");
  String _selectedReturnChargeType = "fixed";
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  SupplierActiveModel? _selectedSupplier;
  PurchaseInvoiceModel? _selectedInvoice;
  String? _selectedPaymentMethod;
  AccountActiveModel? _selectedAccount;

  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(FetchAccountList(context));
    context.read<SupplierInvoiceBloc>().add(FetchSupplierActiveList(context));
    context.read<AccountBloc>().add(FetchAccountActiveList(context));

    // Set initial return date
    final bloc = context.read<PurchaseReturnBloc>();
    bloc.returnDateTextController.text = _formatDate(DateTime.now());

    _returnChargeController.addListener(_updateReturnAmount);
    _updateReturnAmount();
  }

  @override
  void dispose() {
    _returnChargeController.removeListener(_updateReturnAmount);
    _returnChargeController.dispose();
    _returnAmountController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  DateTime? _parseDate(String dateString) {
    try {
      return DateFormat('dd-MM-yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  void onProductChanged(PurchaseInvoiceModel? newVal) {
    if (newVal == null) return;

    products.clear();
    setState(() {
      if (newVal.items != null && newVal.items!.isNotEmpty) {
        for (var item in newVal.items!) {
          products.add(Item(
            productId: item.id,
            productName: item.productName,
            unitPrice: double.tryParse(item.price?.replaceAll(',', '') ?? '0') ?? 0.0,
            quantity: item.qty ?? 1,
            discount: double.tryParse(item.discount?.replaceAll(',', '') ?? '0') ?? 0.0,
            discountType: item.discountType ?? 'fixed',
          ));
        }
      } else {
        // Show warning if no items in invoice
        showCustomToast(
          context: context,
          title: 'Info',
          description: 'No products found in selected invoice',
          icon: Icons.info,
          primaryColor: Colors.blue,
        );
      }
      _updateReturnAmount();
    });
  }

  void _updateReturnAmount() {
    if (!mounted) return;

    double returnCharge = double.tryParse(_returnChargeController.text) ?? 0.0;
    double totalProductPrice = products.fold(0.0, (sum, item) {
      double itemTotal = (item.unitPrice ?? 0) * (item.quantity ?? 1);
      double discountAmount = 0.0;

      if (item.discountType == 'percentage') {
        discountAmount = itemTotal * (item.discount ?? 0) / 100;
      } else {
        discountAmount = item.discount ?? 0;
      }

      return sum + (itemTotal - discountAmount);
    });

    double calculatedReturnAmount = totalProductPrice;

    if (_selectedReturnChargeType == "fixed") {
      calculatedReturnAmount = totalProductPrice - returnCharge;
    } else if (_selectedReturnChargeType == "percentage") {
      calculatedReturnAmount = totalProductPrice * (1 - (returnCharge / 100));
    }

    setState(() {
      _returnAmountController.text = calculatedReturnAmount.toStringAsFixed(2);
    });
  }

  void _updateProductQuantity(int index, int newQuantity) {
    if (newQuantity < 1) return;

    setState(() {
      products[index].quantity = newQuantity;
      _updateReturnAmount();
    });
  }

  void _removeProduct(int index) {
    setState(() {
      products.removeAt(index);
      _updateReturnAmount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bottomNavBg(context),
      padding: const EdgeInsets.all(16),
      child: BlocListener<PurchaseReturnBloc, PurchaseReturnState>(
        listener: (context, state) {
          if (state is PurchaseReturnCreateLoading) {
            appLoader(context, "Creating purchase return...");
          } else if (state is PurchaseReturnCreateSuccess) {
            Navigator.pop(context); // Close loader
            showCustomToast(
              context: context,
              title: 'Success!',
              description: state.message,
              icon: Icons.check_circle,
              primaryColor: Colors.green,
            );
            // Clear form and reset state
            _resetForm();
            Navigator.pop(context);
          } else if (state is PurchaseReturnError) {
            Navigator.pop(context); // Close loader
            appAlertDialog(
              context,
              state.content,
              title: state.title,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            );
          }
        },
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      'Create Purchase Return',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor(context),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Supplier and Invoice Selection
                Row(
                  children: [
                    Expanded(
                      child: BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
                        builder: (context, state) {
                          List<SupplierActiveModel> suppliers = [];

                          if (state is SupplierActiveListSuccess) {
                            suppliers = state.list;
                          } else if (state is SupplierInvoiceLoading) {
                          }

                          return AppDropdown<SupplierActiveModel>(
                            label: "Supplier ",
                            hint: "Select Supplier",
                            isRequired: true,
                            value: _selectedSupplier,
                            itemList: suppliers,
                            onChanged: (newVal) {
                              if (newVal != null) {
                                setState(() {
                                  _selectedSupplier = newVal;
                                  _selectedInvoice = null;
                                  products.clear();
                                });

                                // Fetch invoices for selected supplier
                                context.read<PurchaseReturnBloc>().add(
                                  FetchPurchaseInvoiceList(
                                 context,
                                    supplierId: newVal.id.toString(),
                                  ),
                                );
                              }
                            },
                            validator: (value) => value == null ? 'Please select a supplier' : null,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: BlocBuilder<PurchaseReturnBloc, PurchaseReturnState>(
                        builder: (context, state) {
                          final bloc = context.read<PurchaseReturnBloc>();

                          if (state is PurchaseInvoiceListLoading) {
                          }

                          // Check if invoice list is empty
                          final hasInvoices = bloc.invoiceList.isNotEmpty;

                          return AppDropdown<PurchaseInvoiceModel>(
                            label: "Invoice Number ",
                            hint: hasInvoices ? "Select Invoice Number" : "No invoices available",
                            isRequired: true,
                            value: _selectedInvoice,
                            itemList: bloc.invoiceList,
                            onChanged: (newVal) {
                              if (newVal != null) {
                                setState(() {
                                  _selectedInvoice = newVal;
                                });
                                onProductChanged(newVal);
                              }
                            } ,
                            validator: (value) {
                              if (value == null) return 'Please select an invoice';
                              if (!hasInvoices) return 'No invoices available for this supplier';
                              return null;
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Products List
                if (products.isNotEmpty) ...[
                  Text(
                    'Products to Return',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final item = products[index];
                      final total = (item.unitPrice ?? 0) * (item.quantity ?? 1);

                      return Card(
                        color: AppColors.bottomNavBg(context),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        elevation: 0,
                        child: ListTile(
                          title: Text(
                            item.productName ?? 'Unknown Product',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Wrap(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Row(
                                spacing: 5,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Price: ${item.unitPrice?.toStringAsFixed(2) ?? "0.00"}'),
                                  Text('Discount: ${item.discount?.toStringAsFixed(2) ?? "0.00"}'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 20),
                                    onPressed: () {
                                      _updateProductQuantity(index, (item.quantity ?? 1) - 1);
                                    },
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 20),
                                    onPressed: () {
                                      _updateProductQuantity(index, (item.quantity ?? 1) + 1);
                                    },
                                  ),
                                  Spacer(),
                                  Text(
                                    'Total: ${total.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),



                            ],
                          ),
                          trailing: products.length > 1
                              ? IconButton(
                            icon:  Icon(HugeIcons.strokeRoundedDelete02, color: Colors.red),
                            onPressed: () => _removeProduct(index),
                          )
                              : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                // Payment Method and Account
                Row(
                  children: [
                    Expanded(child: _buildPaymentMethodDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildAccountDropdown()),
                  ],
                ),
                // Return Charge Type and Charge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppDropdown<String>(
                        label: "Return Charge Type",
                        hint: "Select Type",
                        isRequired: true,
                        value: _selectedReturnChargeType,
                        itemList: const ["fixed", "percentage"],
                        onChanged: (newVal) {
                          if (newVal != null) {
                            setState(() {
                              _selectedReturnChargeType = newVal;
                              _updateReturnAmount();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: CustomInputField(
                        isRequired: true,
                        controller: _returnChargeController,
                        labelText: 'Return Charge',
                        hintText: _selectedReturnChargeType == 'fixed' ? 'Enter amount' : 'Enter percentage',
                        fillColor: Colors.white,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Return Charge';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          final doubleVal = double.parse(value);
                          if (_selectedReturnChargeType == 'percentage' && (doubleVal < 0 || doubleVal > 100)) {
                            return 'Percentage must be between 0 and 100';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                // Return Amount and Date
                Row(
                  children: [
                    Expanded(
                      child: CustomInputField(
                        isRequired: false,
                        controller: _returnAmountController,
                        labelText: 'Return Amount',
                        hintText: 'Calculated amount',
                        fillColor: Colors.grey[100],
                        keyboardType: TextInputType.number,
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: CustomInputField(
                        isRequired: true,
                        controller: context.read<PurchaseReturnBloc>().returnDateTextController,
                        labelText: 'Return Date',
                        hintText: 'Select date',
                        fillColor: Colors.white,
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select Return Date';
                          }
                          return null;
                        },
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null && context.mounted) {
                            context.read<PurchaseReturnBloc>().returnDateTextController.text = _formatDate(pickedDate);
                          }
                        }, keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Remark
                CustomInputField(
                  isRequired: false, keyboardType: TextInputType.text,
                  controller: context.read<PurchaseReturnBloc>().remarkController,
                  labelText: 'Remark',
                  hintText: 'Enter remark (optional)',
                  fillColor: Colors.white,
                ),
                const SizedBox(height: 10),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    BlocBuilder<PurchaseReturnBloc, PurchaseReturnState>(
                      builder: (context, state) {
                        final isLoading = state is PurchaseReturnCreateLoading;

                        return AppButton(
                          size: 150,
                          onPressed: isLoading ? null : () => _submitForm(),
                         isLoading: isLoading,
                          name:'Purchase Return',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildPaymentMethodDropdown() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        return AppDropdown<String>(
          label: "Payment Method",
          hint: _selectedPaymentMethod ?? "Select Payment Method",
          isRequired: true,
          value: _selectedPaymentMethod,
          itemList: ['cash', 'bank', 'mobile'],
          onChanged: (newVal) {
            setState(() {
              _selectedPaymentMethod = newVal;
            });
          },
          validator: (value) => value == null ? 'Please select Payment Method' : null,
        );
      },
    );
  }

  Widget _buildAccountDropdown() {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        return AppDropdown<AccountActiveModel>(
          label: "Account ",
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
        );
      },
    );
  }
  void _resetForm() {
    setState(() {
      products.clear();
      _selectedSupplier = null;
      _selectedInvoice = null;
      _returnChargeController.text = "0";
      _returnAmountController.text = "0.00";
      _selectedReturnChargeType = "fixed";
      formKey.currentState?.reset();
    });

    final bloc = context.read<PurchaseReturnBloc>();
    bloc.returnDateTextController.text = _formatDate(DateTime.now());
    bloc.remarkController.text = "Purchase return processed.";
  }

  void _submitForm() {
    if (!formKey.currentState!.validate()) {
      showCustomToast(
        context: context,
        title: 'Validation Error',
        description: 'Please fix all errors in the form',
        icon: Icons.error,
        primaryColor: Colors.red,
      );
      return;
    }

    if (products.isEmpty) {
      showCustomToast(
        context: context,
        title: 'Warning!',
        description: "Please select products to return",
        icon: Icons.warning,
        primaryColor: Colors.orange,
      );
      return;
    }

    if (_selectedSupplier == null) {
      showCustomToast(
        context: context,
        title: 'Warning!',
        description: "Please select a supplier",
        icon: Icons.warning,
        primaryColor: Colors.orange,
      );
      return;
    }

    if (_selectedInvoice == null) {
      showCustomToast(
        context: context,
        title: 'Warning!',
        description: "Please select an invoice",
        icon: Icons.warning,
        primaryColor: Colors.orange,
      );
      return;
    }

    // Prepare products data
    var returnProducts = products.map((product) => {
      "product_id": product.productId,
      "quantity": product.quantity,
      "unit_price": product.unitPrice?.toString(),
      "discount": product.discount?.toString(),
      "discount_type": product.discountType,
    }).toList();

    // Prepare the request body
    final returnDate = _parseDate(context.read<PurchaseReturnBloc>().returnDateTextController.text);

    Map<String, dynamic> body = {
      "supplier_id": _selectedSupplier!.id.toString(),
      "invoice_no": _selectedInvoice!.invoiceNo,
      "return_date": returnDate?.toIso8601String().split('T').first,
      "return_charge": _returnChargeController.text,
      "return_charge_type": _selectedReturnChargeType,
      "return_amount": _returnAmountController.text,
      "account_id": _selectedAccount?.id,
      "payment_method": _selectedPaymentMethod,
      "reason": context.read<PurchaseReturnBloc>().remarkController.text.trim(),
      "items": returnProducts,
    };

    // Dispatch create event
    context.read<PurchaseReturnBloc>().add(
      CreatePurchaseReturn(
         context,
        body: body,
      ),
    );
  }
}

class Item {
  int? productId;
  String? productName;
  double? unitPrice;
  int? quantity;
  double? discount;
  String? discountType;

  Item({
    this.productId,
    this.productName,
    this.unitPrice,
    this.quantity,
    this.discount,
    this.discountType,
  });
}