import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meherin_mart/feature/return/purchase_return/data/model/purchase_invoice_model.dart';
import 'package:meherin_mart/feature/supplier/data/model/supplier_active_model.dart';
import 'package:meherin_mart/feature/supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';

import '../../../../../../core/configs/app_colors.dart';
import '../../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../../../../core/widgets/app_dropdown.dart';
import '../../../../../../core/widgets/app_loader.dart';
import '../../../../../../core/widgets/app_snack_bar.dart';
import '../../../../../../core/widgets/input_field.dart';
import '../../../../../accounts/presentation/bloc/account/account_bloc.dart';
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
  String? _selectedInvoice;

  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(FetchAccountList(context));
    context.read<SupplierInvoiceBloc>().add(FetchSupplierActiveList(context));

    // Set initial return date
    final bloc = context.read<PurchaseReturnBloc>();
    bloc.returnDateTextController.text = _formatDate(DateTime.now());

    _returnChargeController.addListener(_updateReturnAmount);
    _updateReturnAmount();
  }

  @override
  void dispose() {
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
      if (newVal.items != null) {
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
      padding: EdgeInsets.all(16),
      child: BlocListener<PurchaseReturnBloc, PurchaseReturnState>(
        listener: (context, state) {
          if (state is PurchaseReturnCreateLoading) {
            appLoader(context, "Creating purchase return...");
          } else if (state is PurchaseReturnCreateSuccess) {
            Navigator.pop(context);
            appSnackBar(context, state.message, color: AppColors.secondaryBabyBlue);
            Navigator.pop(context);
          } else if (state is PurchaseReturnError) {
            Navigator.pop(context);
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
              children: [
                Row(children: [
                  Expanded(child:   BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
                    builder: (context, state) {
                      List<SupplierActiveModel> suppliers = [];
                      if (state is SupplierActiveListSuccess) {
                        suppliers = state.list;
                      }
                      return AppDropdown<SupplierActiveModel>(
                        context: context,
                        label: "Supplier",
                        hint: _selectedSupplier?.name ?? "Select Supplier",
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
                              FetchPurchaseInvoiceList(context, newVal.id.toString()),
                            );
                          }
                        },
                        validator: (value) => value == null ? 'Please select Supplier' : null,
                        itemBuilder: (item) => DropdownMenuItem<SupplierActiveModel>(
                          value: item,
                          child: Text(
                            item.name ?? 'Unknown',
                            style: const TextStyle(
                              color: AppColors.blackColor,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),),
                  const SizedBox(width: 8),

                  Expanded(child:   BlocBuilder<PurchaseReturnBloc, PurchaseReturnState>(
                    builder: (context, state) {
                      final bloc = context.read<PurchaseReturnBloc>();
                      return AppDropdown<PurchaseInvoiceModel>(
                        context: context,
                        label: "Invoice Number",
                        hint: _selectedInvoice ?? "Select Invoice Number",
                        isRequired: true,
                        value: _selectedInvoice != null
                            ? bloc.invoiceList.firstWhere(
                              (inv) => inv.invoiceNo == _selectedInvoice,
                          orElse: () => PurchaseInvoiceModel(),
                        )
                            : null,
                        itemList: bloc.invoiceList,
                        onChanged: (newVal) {
                          if (newVal != null) {
                            setState(() {
                              _selectedInvoice = newVal.invoiceNo;
                            });
                            onProductChanged(newVal);
                          }
                        },
                        validator: (value) => value == null ? 'Please select Invoice Number' : null,
                        itemBuilder: (item) => DropdownMenuItem<PurchaseInvoiceModel>(
                          value: item,
                          child: Text(
                            item.invoiceNo ?? 'Unknown',
                            style: const TextStyle(
                              color: AppColors.blackColor,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),),
                ],),
                // Supplier Dropdown


                // Invoice Dropdown



                // Products List
                if (products.isNotEmpty) ...[
                  Text(
                    'Products to Return',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
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
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            item.productName ?? 'Unknown Product',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Price: \$${item.unitPrice?.toStringAsFixed(2)}'),
                                  Text('Discount: \$${item.discount?.toStringAsFixed(2)}'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove, size: 20),
                                          onPressed: () {
                                            _updateProductQuantity(index, (item.quantity ?? 1) - 1);
                                          },
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${item.quantity}',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add, size: 20),
                                          onPressed: () {
                                            _updateProductQuantity(index, (item.quantity ?? 1) + 1);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Total: \$${total.toStringAsFixed(2)}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: products.length > 1
                              ? IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeProduct(index),
                          )
                              : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                  Expanded(child:     AppDropdown<String>(
                    context: context,
                    label: "Return Charge Type",
                    hint: _selectedReturnChargeType == 'fixed' ? 'Fixed' : 'Percentage',
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
                    itemBuilder: (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item == 'fixed' ? 'Fixed' : 'Percentage',
                        style: const TextStyle(
                          color: AppColors.blackColor,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),),
                  const SizedBox(width: 8),

                  Expanded(child:    CustomInputField(
                    isRequiredLable: true,
                    isRequired: true,
                    controller: _returnChargeController,
                    hintText: 'Return Charge',
                    fillColor: Colors.white,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Return Charge';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),),
                ],),
                // Return Charge Type


                // Return Charge

                const SizedBox(height: 8),

                Row(children: [
                  Expanded(child:   CustomInputField(
                    isRequiredLable: true,
                    isRequired: false,
                    controller: _returnAmountController,
                    hintText: 'Return Amount',
                    fillColor: Colors.grey[100],
                    keyboardType: TextInputType.number,
                    readOnly: true,
                  ),),

                  const SizedBox(width: 8),

                  Expanded(child:       CustomInputField(
                    isRequiredLable: true,
                    isRequired: true,
                    controller: context.read<PurchaseReturnBloc>().returnDateTextController,
                    hintText: 'Return Date',
                    fillColor: Colors.white,
                    readOnly: true,
                    validator: (value) {
                      return value == null || value.isEmpty ? 'Please select Return Date' : null;
                    },
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        context.read<PurchaseReturnBloc>().returnDateTextController.text = _formatDate(pickedDate);
                      }
                    }, keyboardType: TextInputType.name,
                  ),),
                ],),
                // Return Amount (Read-only)

                const SizedBox(height: 8),

                // Return Date


                // Remark
                CustomInputField(
                  isRequiredLable: false,
                  isRequired: false,
                  controller: context.read<PurchaseReturnBloc>().remarkController,
                  hintText: 'Remark',
                  fillColor: Colors.white,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 24),

                // Submit Button
                BlocBuilder<PurchaseReturnBloc, PurchaseReturnState>(
                  builder: (context, state) {
                    return AppButton(
                      name: "Create Purchase Return",
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (products.isEmpty) {
                            appSnackBar(context, "Please select products to return", color: AppColors.redColor);
                            return;
                          }

                          if (_selectedSupplier == null) {
                            appSnackBar(context, "Please select a supplier", color: AppColors.redColor);
                            return;
                          }

                          if (_selectedInvoice == null) {
                            appSnackBar(context, "Please select an invoice", color: AppColors.redColor);
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
                          Map<String, dynamic> body = {
                            "supplier_id": _selectedSupplier!.id.toString(),
                            "invoice_no": _selectedInvoice,
                            "return_date": _parseDate(context.read<PurchaseReturnBloc>().returnDateTextController.text)?.toIso8601String().split('T').first,
                            "payment_method": "Cash",
                            "return_charge": _returnChargeController.text,
                            "return_charge_type": _selectedReturnChargeType,
                            "return_amount": _returnAmountController.text,
                            "reason": context.read<PurchaseReturnBloc>().remarkController.text.trim(),
                            "items": returnProducts,
                          };


                          context.read<PurchaseReturnBloc>().add(
                            CreatePurchaseReturn(context, body: body),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
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