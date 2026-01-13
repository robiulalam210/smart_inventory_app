import 'package:intl/intl.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/input_field.dart';
import '../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../bloc/supplier/supplier_list_bloc.dart';
import '../bloc/supplier_invoice/supplier_invoice_bloc.dart';
import '../bloc/supplier_payment/supplier_payment_bloc.dart';

class SupplierPaymentForm extends StatefulWidget {
  const SupplierPaymentForm({super.key});

  @override
  State<SupplierPaymentForm> createState() => _MoneyReceiptListScreenState();
}

class _MoneyReceiptListScreenState extends State<SupplierPaymentForm> {
  @override
  void initState() {
    context.read<UserBloc>().add(
      FetchUserList(context, dropdownFilter: "?status=1"),
    );
    context.read<SupplierListBloc>().add(
      FetchSupplierList(context),
    );
    context.read<AccountBloc>().add(FetchAccountActiveList(context));

    context.read<SupplierPaymentBloc>().dateController.text =
        appWidgets.convertDateTimeDDMMYYYY(DateTime.now());

    super.initState();
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: _buildMainContent());
  }

  Widget _buildMainContent() {
    return BlocListener<SupplierPaymentBloc, SupplierPaymentState>(
      listener: (context, state) {
        if (state is SupplierPaymentAddLoading) {
          appLoader(context, "Payment, please wait...");
        } else if (state is SupplierPaymentAddSuccess) {
          // AppRoutes.pushReplacement(context, const PaymentListSupplier());
        } else if (state is SupplierPaymentAddFailed) {
          Navigator.pop(context); // Close loader dialog
          Navigator.pop(context); // Close loader dialog
          appAlertDialog(
            context,
            state.content,
            title: state.title,
            actions: [
              TextButton(
                onPressed: () => AppRoutes.pop(context),
                child: const Text("Dismiss"),
              ),
            ],
          );
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // Header with Cancel/Up Button
                Container(
                  padding:  EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bottomNavBg(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Supplier Payment",
                        style: AppTextStyle.headerTitle(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 24),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Supplier and Collected By Row
                      _buildTwoColumnRow(
                        firstChild: BlocBuilder<SupplierListBloc, SupplierListState>(
                          builder: (context, state) {
                            return AppDropdown(
                              label: "Supplier",
                              hint: context.read<SupplierPaymentBloc>().selectCustomerModel?.name?.toString() ??
                                  "Select Supplier",
                              isNeedAll: false,
                              isRequired: true,
                              value: context.read<SupplierPaymentBloc>().selectCustomerModel,
                              itemList: context.read<SupplierListBloc>().supplierListModel,
                              onChanged: (newVal) {
                                context.read<SupplierPaymentBloc>().selectCustomerModel = newVal;
                                context.read<SupplierInvoiceBloc>().supplierInvoiceListModel = "";
                                context.read<SupplierInvoiceBloc>().add(
                                  FetchSupplierInvoiceList(
                                    context,
                                    dropdownFilter: "${newVal?.id.toString()}",
                                  ),
                                );

                                if (double.tryParse(newVal!.totalDue.toString())! > 0) {
                                  context.read<SupplierPaymentBloc>().amountController.text =
                                      newVal.totalDue.toString();
                                } else {
                                  context.read<SupplierPaymentBloc>().amountController.text = "0";
                                }

                                setState(() {});
                              },
                              validator: (value) {
                                return value == null ? 'Please select Supplier' : null;
                              },

                            );
                          },
                        ),
                        secondChild: BlocBuilder<UserBloc, UserState>(
                          builder: (context, state) {
                            return AppDropdown(
                              label: "Collected By",
                              hint: context.read<SupplierPaymentBloc>().selectUserModel?.username.toString() ??
                                  "Select Collected By",
                              isLabel: false,
                              isRequired: true,
                              isNeedAll: false,
                              value: context.read<SupplierPaymentBloc>().selectUserModel,
                              itemList: context.read<UserBloc>().list,
                              onChanged: (newVal) {
                                context.read<SupplierPaymentBloc>().selectUserModel = newVal;
                                setState(() {});
                              },
                              validator: (value) {
                                return value == null ? 'Please select Collected By' : null;
                              },

                            );
                          },
                        ),
                      ),


                      // Payment To and Conditional Invoice Row
                      _buildTwoColumnRow(
                        firstChild: AppDropdown(
                          label: "Payment To",
                          hint: context.read<SupplierPaymentBloc>().selectedPaymentToState.isNotEmpty
                              ? context.read<SupplierPaymentBloc>().selectedPaymentToState
                              : "Select Payment To",
                          isLabel: false,
                          isRequired: true,
                          isNeedAll: false,
                          value: context.read<SupplierPaymentBloc>().selectedPaymentToState,
                          itemList: context.read<SupplierPaymentBloc>().paymentTo,
                          onChanged: (newVal) {
                            context.read<SupplierPaymentBloc>().selectedPaymentToState = newVal;
                            setState(() {});
                          },
                          validator: (value) {
                            return value == null ? 'Please select Payment To' : null;
                          },

                        ),
                        secondChild: context.read<SupplierPaymentBloc>().selectedPaymentToState.toString() == "Specific"
                            ? BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
                          builder: (context, state) {
                            return AppDropdown(
                              label: "Invoice",
                              hint: context.read<SupplierInvoiceBloc>().supplierInvoiceListModel == ""
                                  ? "Select Invoice"
                                  : context.read<SupplierInvoiceBloc>().supplierInvoiceListModel,
                              isNeedAll: false,
                              isRequired: true,
                              value: context.read<SupplierInvoiceBloc>().supplierInvoiceListModel,
                              itemList: context.read<SupplierInvoiceBloc>().supplierListModel,
                              onChanged: (newVal) {
                                context.read<SupplierInvoiceBloc>().supplierInvoiceListModel = newVal.toString();
                                context.read<SupplierPaymentBloc>().amountController.text =
                                    newVal.toString().split("(").last.split(")").first;
                                setState(() {});
                              },
                              validator: (value) {
                                return value == null ? 'Please select Invoice' : null;
                              },

                            );
                          },
                        )
                            : const SizedBox(), // Empty space when not needed
                      ),


                      // Date Field (Full width)
                      CustomInputField(
                        isRequiredLable: true,
                        isRequired: false,
                        controller: context.read<SupplierPaymentBloc>().dateController,
                        hintText: 'Date',
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                        readOnly: true,
                        keyboardType: TextInputType.text,
                        autofillHints: AutofillHints.telephoneNumber,
                        validator: (value) {
                          return value!.isEmpty ? 'Please enter Date' : null;
                        },
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode()); // Close the keyboard
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            context.read<SupplierPaymentBloc>().dateController.text =
                                appWidgets.convertDateTimeDDMMYYYY(pickedDate);
                            setState(() {});
                          }
                        },
                        onChanged: (value) {
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Payment Information",
                        style: AppTextStyle.headerTitle(context),
                      ),
                      const SizedBox(height: 6),

                      // Payment Method and Account Row
                      _buildTwoColumnRow(
                        firstChild: AppDropdown(
                          label: "Payment Method",
                          hint: context.read<SupplierPaymentBloc>().selectedPaymentMethod.isEmpty
                              ? "Select Payment Method"
                              : context.read<SupplierPaymentBloc>().selectedPaymentMethod,
                          isLabel: false,
                          isRequired: true,
                          isNeedAll: false,
                          value: context.read<SupplierPaymentBloc>().selectedPaymentMethod.isEmpty
                              ? null
                              : context.read<SupplierPaymentBloc>().selectedPaymentMethod,
                          itemList: context.read<SupplierPaymentBloc>().paymentMethod,
                          onChanged: (newVal) {
                            context.read<SupplierPaymentBloc>().selectedPaymentMethod = newVal.toString();
                            setState(() {
                              // Clear selected account when payment method changes
                              context.read<SupplierPaymentBloc>().selectedAccount = "";
                              context.read<SupplierPaymentBloc>().selectedAccountId = "";
                            });
                          },
                          validator: (value) {
                            return value == null ? 'Please select a payment method' : null;
                          },

                        ),
                        secondChild: BlocBuilder<AccountBloc, AccountState>(
                          builder: (context, state) {
                            // Filter the accounts list based on selected payment method (ac_type)
                            final filteredList = context.read<SupplierPaymentBloc>().selectedPaymentMethod.isNotEmpty
                                ? context.read<AccountBloc>().activeAccount.where((item) {
                              final itemAcType = item.acType?.toLowerCase() ?? '';
                              final selectedMethod = context.read<SupplierPaymentBloc>().selectedPaymentMethod.toLowerCase();
                              return itemAcType == selectedMethod;
                            }).toList()
                                : context.read<AccountBloc>().activeAccount;

                            return AppDropdown(
                              label: "Account",
                              hint: filteredList.isEmpty
                                  ? "No accounts available for selected payment method"
                                  : "Select Account",
                              isLabel: false,
                              isRequired: true,
                              isNeedAll: false,
                              value: context.read<SupplierPaymentBloc>().selectedAccount.isEmpty
                                  ? null
                                  : context.read<SupplierPaymentBloc>().selectedAccount,
                              itemList: filteredList,
                              onChanged: (newVal) {
                                if (newVal != null) {
                                  context.read<SupplierPaymentBloc>().selectedAccount = newVal.toString();
                                  try {
                                    var matchingAccount = filteredList.firstWhere(
                                          (acc) => acc.toString() == newVal.toString(),
                                    );
                                    context.read<SupplierPaymentBloc>().selectedAccountId =
                                        matchingAccount.id.toString();
                                  } catch (e) {
                                    context.read<SupplierPaymentBloc>().selectedAccountId = "";
                                  }
                                }
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select an account';
                                }
                                return null;
                              },

                            );
                          },
                        ),
                      ),

                      // const SizedBox(height: 12),

                      // Amount and Remark Row
                      _buildTwoColumnRow(
                        firstChild: CustomInputField(
                          isRequiredLable: true,
                          isRequired: true,
                          controller: context.read<SupplierPaymentBloc>().amountController,
                          hintText: 'Amount',
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          keyboardType: TextInputType.number,
                          autofillHints: AutofillHints.telephoneNumber,
                          validator: (value) {
                            return value!.isEmpty ? 'Please enter amount' : null;
                          },
                          onChanged: (value) {
                            return null;
                          },
                        ),
                        secondChild: CustomInputField(
                          isRequiredLable: true,
                          isRequired: false,
                          controller: context.read<SupplierPaymentBloc>().remarkController,
                          hintText: 'Remark',
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          keyboardType: TextInputType.text,
                          autofillHints: AutofillHints.telephoneNumber,
                          onChanged: (value) {
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Submit and Cancel Buttons
                _buildTwoColumnRow(
                  firstChild: AppButton(
                    name: "Cancel",
                    color: Colors.grey,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  secondChild: AppButton(
                    name: "Create Payment",
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Map<String, dynamic> body = {
                          "account_id": context.read<SupplierPaymentBloc>().selectedAccountId,
                          "amount": double.tryParse(context.read<SupplierPaymentBloc>().amountController.text.trim()),
                          "supplier_id": "${context.read<SupplierPaymentBloc>().selectCustomerModel?.id.toString()}",
                          "payment_date": appWidgets.convertDateTime(
                            DateFormat("dd-MM-yyyy").parse(
                              context.read<SupplierPaymentBloc>().dateController.text.trim(),
                              true,
                            ),
                            "yyyy-MM-dd",
                          ),
                          "payment_method": context.read<SupplierPaymentBloc>().selectedPaymentMethod.toString().toLowerCase(),
                          "seller_id": "${context.read<SupplierPaymentBloc>().selectUserModel?.id.toString()}",
                          "specific_invoice": context.read<SupplierPaymentBloc>().selectedPaymentToState.toString() == "Over All" ? false : true,
                        };

                        if (context.read<SupplierPaymentBloc>().selectedPaymentToState.toString() == "Specific") {
                          body["invoice_no"] = context.read<SupplierInvoiceBloc>().supplierInvoiceListModel.toString().split("(").first;
                        }
                        if (context.read<SupplierPaymentBloc>().remarkController.text.isNotEmpty) {
                          body["description"] = context.read<SupplierPaymentBloc>().remarkController.text.toString();
                        }

                        context.read<SupplierPaymentBloc>().add(AddSupplierPayment(body: body));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTwoColumnRow({required Widget firstChild, required Widget secondChild}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 500;

        if (isSmallScreen) {
          // Stack vertically on small screens
          return Column(
            children: [
              firstChild,
              const SizedBox(height: 6),
              secondChild,
            ],
          );
        } else {
          // Place side by side on larger screens
          return Row(
            children: [
              Expanded(
                child: firstChild,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: secondChild,
              ),
            ],
          );
        }
      },
    );
  }
}
