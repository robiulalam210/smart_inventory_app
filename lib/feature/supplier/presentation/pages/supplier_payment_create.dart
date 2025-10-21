import 'package:intl/intl.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/input_field.dart';
import '../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../money_receipt/presentation/bloc/money_receipt/money_receipt_bloc.dart';
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
      FetchSupplierList(
        // dropdownFilter: "?status=1"
        context,
      ),
    );
    context.read<AccountBloc>().add(FetchAccountList(context));

    context.read<SupplierPaymentBloc>().dateController.text = appWidgets
        .convertDateTimeDDMMYYYY(DateTime.now());
    // TODO: implement initState
    super.initState();
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: _buildMainContent());
  }

  Widget _buildMainContent() {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return ResponsiveRow(
      spacing: 0,
      runSpacing: 0,
      children: [
        if (isBigScreen)
          ResponsiveCol(
            xs: 0,
            sm: 1,
            md: 1,
            lg: 2,
            xl: 2,
            child: Container(
              decoration: BoxDecoration(color: AppColors.whiteColor),
              child: isBigScreen ? const Sidebar() : const SizedBox.shrink(),
            ),
          ),
        ResponsiveCol(
          xs: 12,
          sm: 12,
          md: 12,
          lg: 10,
          xl: 10,
          child: BlocListener<SupplierPaymentBloc, SupplierPaymentState>(
            listener: (context, state) {
              if (state is SupplierPaymentAddLoading) {
                appLoader(context, "Payment, please wait...");
              } else if (state is SupplierPaymentAddSuccess) {
                // AppRoutes.pushReplacement(context, const PaymentListSupplier());
              } else if (state is SupplierPaymentAddFailed) {
                Navigator.pop(context); // Close loader dialog
                // Navigator.pop(context); // Close loader dialog
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
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          BlocBuilder<SupplierListBloc, SupplierListState>(
                            builder: (context, state) {
                              return AppDropdown(
                                label: "Supplier",
                                context: context,
                                hint:
                                context
                                    .read<SupplierPaymentBloc>()
                                    .selectCustomerModel
                                    ?.name
                                    ?.toString() ??
                                    "Select Supplier",
                                isNeedAll: false,
                                isRequired: true,
                                value: context
                                    .read<SupplierPaymentBloc>()
                                    .selectCustomerModel,
                                itemList: context
                                    .read<SupplierListBloc>()
                                    .supplierListModel,
                                onChanged: (newVal) {
                                  context
                                      .read<SupplierPaymentBloc>()
                                      .selectCustomerModel =
                                      newVal;
                                  context
                                      .read<SupplierInvoiceBloc>()
                                      .supplierInvoiceListModel ==
                                      "";
                                  context.read<SupplierInvoiceBloc>().add(
                                    FetchSupplierInvoiceList(
                                      context,
                                      dropdownFilter:
                                      "${newVal?.id.toString()}",
                                    ),
                                  );

                                  print(newVal);
                                  if (double.tryParse(
                                    newVal!.totalDue.toString(),
                                  )! >
                                      0) {
                                    context
                                        .read<SupplierPaymentBloc>()
                                        .amountController
                                        .text = newVal.totalDue
                                        .toString();
                                  } else {
                                    context
                                        .read<SupplierPaymentBloc>()
                                        .amountController
                                        .text =
                                    "0";
                                  }

                                  setState(() {});
                                },
                                validator: (value) {
                                  return value == null
                                      ? 'Please select Supplier '
                                      : null;
                                },
                                itemBuilder: (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item.toString(),
                                    style: const TextStyle(
                                      color: AppColors.blackColor,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          BlocBuilder<UserBloc, UserState>(
                            builder: (context, state) {
                              return AppDropdown(
                                label: "Collected By",
                                context: context,
                                hint:
                                context
                                    .read<SupplierPaymentBloc>()
                                    .selectUserModel
                                    ?.username
                                    .toString() ??
                                    "Select Collected By",
                                isLabel: false,
                                isRequired: true,
                                isNeedAll: false,
                                value: context
                                    .read<SupplierPaymentBloc>()
                                    .selectUserModel,
                                itemList: context.read<UserBloc>().list,
                                onChanged: (newVal) {
                                  // Update the selected warehouse in the bloc
                                  context
                                      .read<SupplierPaymentBloc>()
                                      .selectUserModel =
                                      newVal;
                                },
                                validator: (value) {
                                  return value == null
                                      ? 'Please select Collected By '
                                      : null;
                                },
                                itemBuilder: (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item.toString(),
                                    style: const TextStyle(
                                      color: AppColors.blackColor,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          AppDropdown(
                            label: "Payment To",
                            context: context,
                            hint:
                            context
                                .read<SupplierPaymentBloc>()
                                .selectedPaymentToState
                                .isNotEmpty
                                ? context
                                .read<SupplierPaymentBloc>()
                                .selectedPaymentToState
                                : "Select Payment To",
                            isLabel: false,
                            isRequired: true,
                            isNeedAll: false,
                            value: context
                                .read<SupplierPaymentBloc>()
                                .selectedPaymentToState,
                            itemList: context
                                .read<SupplierPaymentBloc>()
                                .paymentTo,
                            onChanged: (newVal) {
                              context
                                  .read<SupplierPaymentBloc>()
                                  .selectedPaymentToState =
                                  newVal;
                              setState(() {});
                            },
                            validator: (value) {
                              return value == null
                                  ? 'Please select Payment To '
                                  : null;
                            },
                            itemBuilder: (item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                item.toString(),
                                style: const TextStyle(
                                  color: AppColors.blackColor,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
                          context
                              .read<SupplierPaymentBloc>()
                              .selectedPaymentToState
                              .toString() ==
                              "Specific"
                              ? BlocBuilder<
                              SupplierInvoiceBloc,
                              SupplierInvoiceState
                          >(
                            builder: (context, state) {
                              return AppDropdown(
                                label: "Invoice   ",
                                context: context,
                                hint:
                                context
                                    .read<SupplierInvoiceBloc>()
                                    .supplierInvoiceListModel ==
                                    ""
                                    ? "Select Invoice"
                                    : context
                                    .read<SupplierInvoiceBloc>()
                                    .supplierInvoiceListModel,
                                isNeedAll: false,
                                isRequired: true,
                                value: context
                                    .read<SupplierInvoiceBloc>()
                                    .supplierInvoiceListModel,
                                itemList: context
                                    .read<SupplierInvoiceBloc>()
                                    .supplierListModel,
                                onChanged: (newVal) {
                                  context
                                      .read<SupplierInvoiceBloc>()
                                      .supplierInvoiceListModel = newVal
                                      .toString();
                                  context
                                      .read<SupplierPaymentBloc>()
                                      .amountController
                                      .text = newVal
                                      .toString()
                                      .split("(")
                                      .last
                                      .split(")")
                                      .first;
                                },
                                validator: (value) {
                                  return value == null
                                      ? 'Please select Invoice '
                                      : null;
                                },
                                itemBuilder: (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item.toString(),
                                    style: const TextStyle(
                                      color: AppColors.blackColor,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                              : Container(),
                          CustomInputField(
                            isRequiredLable: true,
                            isRequired: false,
                            controller: context
                                .read<SupplierPaymentBloc>()
                                .dateController,
                            hintText: 'Date',
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            readOnly: true,
                            keyboardType: TextInputType.text,
                            autofillHints: AutofillHints.telephoneNumber,
                            validator: (value) {
                              return value!.isEmpty
                                  ? 'Please enter Date '
                                  : null;
                            },
                            onTap: () async {
                              FocusScope.of(
                                context,
                              ).requestFocus(FocusNode()); // Close the keyboard
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                context
                                    .read<SupplierPaymentBloc>()
                                    .dateController
                                    .text = appWidgets.convertDateTimeDDMMYYYY(
                                  pickedDate,
                                );
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
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Payment Information",
                            style: AppTextStyle.headerTitle(context),
                          ),
                          const SizedBox(height: 10),
                          AppDropdown(
                            label: "Payment Method",
                            context: context,
                            hint:
                            context
                                .read<SupplierPaymentBloc>()
                                .selectedPaymentMethod
                                .isEmpty
                                ? "Select Payment Method"
                                : context
                                .read<SupplierPaymentBloc>()
                                .selectedPaymentMethod,
                            isLabel: false,
                            isRequired: true,
                            isNeedAll: false,
                            value:
                            context
                                .read<SupplierPaymentBloc>()
                                .selectedPaymentMethod
                                .isEmpty
                                ? null
                                : context
                                .read<SupplierPaymentBloc>()
                                .selectedPaymentMethod,
                            itemList: context
                                .read<SupplierPaymentBloc>()
                                .paymentMethod,
                            onChanged: (newVal) {
                              // Update the selected payment method in the bloc
                              context
                                  .read<SupplierPaymentBloc>()
                                  .selectedPaymentMethod = newVal
                                  .toString();

                              setState(() {
                                context
                                    .read<SupplierPaymentBloc>()
                                    .selectedPaymentMethod = newVal
                                    .toString();
                                // Clear selected account when payment method changes
                                context
                                    .read<SupplierPaymentBloc>()
                                    .selectedAccount = "";
                                context
                                    .read<SupplierPaymentBloc>()
                                    .selectedAccountId = "";
                              });
                            },
                            validator: (value) {
                              return value == null
                                  ? 'Please select a payment method'
                                  : null;
                            },
                            itemBuilder: (item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                item.toString(),
                                style: const TextStyle(
                                  color: AppColors.blackColor,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
                          BlocBuilder<AccountBloc, AccountState>(
                            builder: (context, state) {
                              // Filter the accounts list based on selected payment method (ac_type)
                              final filteredList =
                              context
                                  .read<SupplierPaymentBloc>()
                                  .selectedPaymentMethod
                                  .isNotEmpty
                                  ? context.read<AccountBloc>().list.where((
                                  item,
                                  ) {
                                // Handle null acType safely
                                final itemAcType = item.acType?.toLowerCase() ?? '';
                                final selectedMethod = context
                                    .read<SupplierPaymentBloc>()
                                    .selectedPaymentMethod
                                    .toLowerCase();

                                return itemAcType == selectedMethod;
                              }).toList()
                                  : context.read<AccountBloc>().list;

                              // Debug: Check the size of the filtered list
                              print("Filtered accounts count: ${filteredList.length}");
                              print("Selected payment method: ${context.read<SupplierPaymentBloc>().selectedPaymentMethod}");

                              return AppDropdown(
                                label: "Account",
                                hint: filteredList.isEmpty
                                    ? "No accounts available for selected payment method"
                                    : "Select Account",
                                context: context,
                                isLabel: false,
                                isRequired: true,
                                isNeedAll: false,
                                value:
                                context
                                    .read<SupplierPaymentBloc>()
                                    .selectedAccount
                                    .isEmpty
                                    ? null
                                    : context
                                    .read<SupplierPaymentBloc>()
                                    .selectedAccount,
                                itemList: filteredList,
                                onChanged: (newVal) {
                                  if (newVal != null) {
                                    // Update the selected account in the bloc
                                    context
                                        .read<SupplierPaymentBloc>()
                                        .selectedAccount = newVal
                                        .toString();

                                    // Find the matching account to get the ID
                                    try {
                                      var matchingAccount = filteredList.firstWhere(
                                            (acc) =>
                                        acc.toString() == newVal.toString(),
                                      );

                                      context
                                          .read<SupplierPaymentBloc>()
                                          .selectedAccountId = matchingAccount.acId
                                          .toString();
                                    } catch (e) {
                                      print("Error finding account: $e");
                                      context
                                          .read<SupplierPaymentBloc>()
                                          .selectedAccountId = "";
                                    }
                                  }
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select an account';
                                  }
                                  return null;
                                },
                                itemBuilder: (item) => DropdownMenuItem(
                                  value: item.toString(),
                                  child: Text(
                                    item.toString(),
                                    style: const TextStyle(
                                      color: AppColors.blackColor,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          CustomInputField(
                            isRequiredLable: true,
                            isRequired: true,
                            controller: context
                                .read<SupplierPaymentBloc>()
                                .amountController,
                            hintText: 'Amount',
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            keyboardType: TextInputType.number,
                            autofillHints: AutofillHints.telephoneNumber,
                            validator: (value) {
                              return value!.isEmpty
                                  ? 'Please enter amount '
                                  : null;
                            },
                            onChanged: (value) {
                              return null;
                            },
                          ),
                          CustomInputField(
                            isRequiredLable: true,
                            isRequired: false,
                            controller: context
                                .read<SupplierPaymentBloc>()
                                .remarkController,
                            hintText: 'Remark',
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            keyboardType: TextInputType.text,
                            autofillHints: AutofillHints.telephoneNumber,
                            // validator: (value) {
                            //   return value!.isEmpty ? 'Please enter amount ' : null;
                            // },
                            onChanged: (value) {
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      name: "Create",
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          // Collecting the form data
                          Map<String, dynamic> body = {
                            "account_id": context
                                .read<SupplierPaymentBloc>()
                                .selectedAccountId,
                            "amount": double.tryParse(
                              context
                                  .read<SupplierPaymentBloc>()
                                  .amountController
                                  .text
                                  .trim(),
                            ),
                            "supplier_id":
                            "${context.read<SupplierPaymentBloc>().selectCustomerModel?.id.toString()}",
                            "payment_date": appWidgets.convertDateTime(
                              DateFormat("dd-MM-yyyy").parse(
                                context
                                    .read<SupplierPaymentBloc>()
                                    .dateController
                                    .text
                                    .trim(),
                                true,
                              ),
                              "yyyy-MM-dd",
                            ),
                            "payment_method": context
                                .read<SupplierPaymentBloc>()
                                .selectedPaymentMethod
                                .toString().toLowerCase(),
                            "seller_id":
                            "${context.read<SupplierPaymentBloc>().selectUserModel?.id.toString()}",
                            "specific_invoice":
                            context
                                .read<SupplierPaymentBloc>()
                                .selectedPaymentToState
                                .toString() ==
                                "Over All"
                                ? false
                                : true,
                          };

                          if (context
                              .read<SupplierPaymentBloc>()
                              .selectedPaymentToState
                              .toString() ==
                              "Specific") {
                            body["invoice_no"] = context
                                .read<SupplierInvoiceBloc>()
                                .supplierInvoiceListModel
                                .toString()
                                .split("(")
                                .first;
                          }
                          if (context
                              .read<SupplierPaymentBloc>()
                              .remarkController
                              .text
                              .isNotEmpty) {
                            body["remark"] = context
                                .read<SupplierPaymentBloc>()
                                .remarkController
                                .text
                                .toString();
                          }

                          context.read<SupplierPaymentBloc>().add(
                            AddSupplierPayment(body: body),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}