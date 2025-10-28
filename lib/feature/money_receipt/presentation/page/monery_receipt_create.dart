import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_inventory/feature/accounts/data/model/account_model.dart';

import '../../../../core/configs/app_colors.dart';
import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/input_field.dart';
import '../../../../responsive.dart';
import '../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../sales/data/models/pos_sale_model.dart';
import '../../../sales/presentation/bloc/possale/possale_bloc.dart';
import '../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../bloc/money_receipt/money_receipt_bloc.dart';

class MoneyReceiptForm extends StatefulWidget {
  const MoneyReceiptForm({super.key});

  @override
  State<MoneyReceiptForm> createState() => _MoneyReceiptListScreenState();
}

class _MoneyReceiptListScreenState extends State<MoneyReceiptForm> {
  @override
  void initState() {
    context.read<UserBloc>().add(
      FetchUserList(context, dropdownFilter: "?status=1"),
    );
    context.read<CustomerBloc>().add(
      FetchCustomerActiveList(context, ),
    );
    context.read<AccountBloc>().add(FetchAccountList(context));

    context.read<MoneyReceiptBloc>().dateController.text = appWidgets
        .convertDateTimeDDMMYYYY(DateTime.now());
    context.read<MoneyReceiptBloc>().withdrawDateController.text = appWidgets
        .convertDateTimeDDMMYYYY(DateTime.now());
    // TODO: implement initState
    super.initState();
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late MoneyReceiptBloc moneyReceiptBloc;

  @override
  void didUpdateWidget(covariant MoneyReceiptForm oldWidget) {
    moneyReceiptBloc = context.read<MoneyReceiptBloc>();
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  ValueNotifier<String> selectedPaymentToState = ValueNotifier<String>(
    'Over All',
  );
  ValueNotifier<PosSaleModel?> selectPosSaleModel =
      ValueNotifier<PosSaleModel?>(null);
  ValueNotifier<String?> selectedPaymentMethodNotifier = ValueNotifier("Cash");
  ValueNotifier<String?> selectedAccountNotifier = ValueNotifier(null);

  @override
  void dispose() {
    selectedPaymentMethodNotifier.dispose();
    selectedPaymentToState.dispose();
    selectPosSaleModel.dispose();
    selectedAccountNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: _buildMainContent());
  }

  Widget _buildMainContent() {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
    final moneyBloc = context.read<MoneyReceiptBloc>();

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
          child: Form(
            key: formKey,
            child: Container(
              padding: EdgeInsets.all(10),
              color: AppColors.bg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    "Create Money Receipt",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        ResponsiveRow(
                          spacing: 20,
                          runSpacing: 10,
                          children: [
                            ResponsiveCol(
                              xs: 12,
                              sm: 3,
                              md: 3,
                              lg: 3,
                              xl: 3,
                              child: BlocBuilder<CustomerBloc, CustomerState>(
                                builder: (context, state) {
                                  return AppDropdown(
                                    label: "Customer",
                                    context: context,
                                    isSearch: true,
                                    hint:
                                        context
                                            .read<MoneyReceiptBloc>()
                                            .selectCustomerModel
                                            ?.name
                                            ?.toString() ??
                                        "Select Customer",
                                    isNeedAll: false,
                                    isRequired: true,
                                    value: context
                                        .read<MoneyReceiptBloc>()
                                        .selectCustomerModel,
                                    itemList: context.read<CustomerBloc>().activeCustomer,
                                    onChanged: (newVal) {
                                      context
                                              .read<MoneyReceiptBloc>()
                                              .selectCustomerModel =
                                          newVal;

                                      context.read<PosSaleBloc>().add(
                                        FetchCustomerSaleList(
                                          context,
                                          dropdownFilter: "/due/?customer_id=${newVal?.id.toString()}&due=true",

                                          // dropdownFilter:
                                          //     "?filter=&due=true&customer_id=${newVal?.id.toString()}",
                                        ),
                                      );

                                      //  setState(() {});
                                    },
                                    validator: (value) {
                                      return value == null
                                          ? 'Please select Customer '
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
                            ),
                            ResponsiveCol(
                              xs: 12,
                              sm: 3,
                              md: 3,
                              lg: 3,
                              xl: 3,
                              child: BlocBuilder<UserBloc, UserState>(
                                builder: (context, state) {
                                  final userList = context.read<UserBloc>().list;

                                  // Set default user if none is selected
                                  if (userList.isNotEmpty &&
                                      context
                                              .read<MoneyReceiptBloc>()
                                              .selectUserModel ==
                                          null) {
                                    context
                                            .read<MoneyReceiptBloc>()
                                            .selectUserModel =
                                        userList.first;
                                  }

                                  return AppDropdown(
                                    label: "Collected By",
                                    context: context,
                                    hint:
                                        context
                                            .read<MoneyReceiptBloc>()
                                            .selectUserModel
                                            ?.username
                                            .toString() ??
                                        "Select Collected By",
                                    isLabel: false,
                                    isRequired: true,
                                    isNeedAll: false,
                                    value: context
                                        .read<MoneyReceiptBloc>()
                                        .selectUserModel,
                                    itemList: userList,
                                    onChanged: (newVal) {
                                      context
                                              .read<MoneyReceiptBloc>()
                                              .selectUserModel =
                                          newVal;
                                    },
                                    validator: (value) {
                                      return value == null
                                          ? 'Please select Collected By'
                                          : null;
                                    },
                                    itemBuilder: (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                        item.username ?? "",
                                        // Safely use userName
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
                            ),
                            ResponsiveCol(
                              xs: 12,
                              sm: 2,
                              md: 2,
                              lg: 2,
                              xl: 2,
                              child: ValueListenableBuilder<String>(
                                valueListenable: selectedPaymentToState,
                                builder: (context, selectedPaymentTo, child) {
                                  return AppDropdown(
                                    label: "Payment To",
                                    context: context,
                                    hint: selectedPaymentTo.isNotEmpty
                                        ? selectedPaymentTo
                                        : "Select Payment To",
                                    isLabel: false,
                                    isRequired: true,
                                    isNeedAll: false,
                                    value: selectedPaymentTo,
                                    itemList: context
                                        .read<MoneyReceiptBloc>()
                                        .paymentTo,
                                    onChanged: (newVal) {
                                      selectedPaymentToState.value =
                                          newVal; // Update ValueNotifier
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
                                  );
                                },
                              ),
                            ),
                            ResponsiveCol(
                              xs: 12,
                              sm: 3,
                              md: 3,
                              lg: 3,
                              xl: 3,
                              child: ValueListenableBuilder<String>(
                                valueListenable: selectedPaymentToState,
                                builder: (context, selectedPaymentTo, child) {
                                  return selectedPaymentTo == "Specific"
                                      ? ValueListenableBuilder<PosSaleModel?>(
                                          valueListenable: selectPosSaleModel,
                                          builder: (context, selectedPosSale, child) {
                                            return BlocBuilder<
                                              PosSaleBloc,
                                              PosSaleState
                                            >(
                                              builder: (context, state) {
                                                return AppDropdown(
                                                  label: "Invoice",
                                                  context: context,
                                                  hint:
                                                      selectedPosSale?.invoiceNo
                                                          ?.toString() ??
                                                      "Select Invoice",
                                                  isNeedAll: false,
                                                  isRequired: true,
                                                  value: selectedPosSale,
                                                  itemList: context
                                                      .read<PosSaleBloc>()
                                                      .list,
                                                  onChanged: (newVal) {
                                                    selectPosSaleModel.value =
                                                        newVal; // Update ValueNotifier
                                                  },
                                                  validator: (value) {
                                                    return value == null
                                                        ? 'Please select PosSale '
                                                        : null;
                                                  },
                                                  itemBuilder: (item) =>
                                                      DropdownMenuItem(
                                                        value: item,
                                                        child: Text(
                                                          item.toString(),
                                                          style: const TextStyle(
                                                            color: AppColors
                                                                .blackColor,
                                                            fontFamily:
                                                                'Quicksand',
                                                            fontWeight:
                                                                FontWeight.w300,
                                                          ),
                                                        ),
                                                      ),
                                                );
                                              },
                                            );
                                          },
                                        )
                                      : Container();
                                },
                              ),
                            ),

                            ResponsiveCol(
                              xs: 12,
                              sm: 3,
                              md: 3,
                              lg: 3,
                              xl: 3,
                              child: CustomInputField(
                                isRequiredLable: true,
                                isRequired: false,
                                controller: context
                                    .read<MoneyReceiptBloc>()
                                    .dateController,
                                hintText: 'Date',
                                fillColor: const Color.fromARGB(
                                  255,
                                  255,
                                  255,
                                  255,
                                ),
                                readOnly: true,
                                keyboardType: TextInputType.text,
                                autofillHints: AutofillHints.telephoneNumber,
                                validator: (value) {
                                  return value!.isEmpty
                                      ? 'Please enter Date '
                                      : null;
                                },
                                onTap: () async {
                                  FocusScope.of(context).requestFocus(
                                    FocusNode(),
                                  ); // Close the keyboard
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (pickedDate != null) {
                                    moneyBloc.dateController.text = appWidgets
                                        .convertDateTimeDDMMYYYY(pickedDate);
                                  }
                                },
                                onChanged: (value) {
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        // Top Row
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              "Payment Information",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.credit_card,
                              size: 17,
                              color: Colors.amber,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ResponsiveRow(
                          spacing: 20,
                          runSpacing: 10,
                          children: [
                            ResponsiveCol(
                              xs: 12,
                              sm: 3,
                              md: 3,
                              lg: 3,
                              xl: 3,
                              child: ValueListenableBuilder<String?>(
                                valueListenable: selectedPaymentMethodNotifier,
                                builder: (context, selectedPaymentMethod, child) {
                                  if (!mounted) {
                                    return Container(); // Prevent access if the widget is unmounted
                                  }

                                  return AppDropdown<String>(
                                    label: "Payment Method",
                                    context: context,
                                    hint:
                                        selectedPaymentMethod ??
                                        "Select Payment Method",
                                    isLabel: false,
                                    isRequired: true,
                                    isNeedAll: false,
                                    value: selectedPaymentMethod,
                                    itemList: context
                                        .read<MoneyReceiptBloc>()
                                        .paymentMethod,
                                    onChanged: (newVal) {
                                      debugPrint(newVal);
                                      selectedPaymentMethodNotifier.value = newVal
                                          .toString();
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
                                  );
                                },
                              ),
                            ),
                            ResponsiveCol(
                              xs: 12,
                              sm: 3,
                              md: 3,
                              lg: 3,
                              xl: 3,
                              child: ValueListenableBuilder<String?>(
                                valueListenable: selectedPaymentMethodNotifier,
                                builder: (context, selectedPaymentMethod, child) {
                                  return BlocBuilder<AccountBloc, AccountState>(
                                    builder: (context, state) {
                                      // Debug: Print all accounts and their types
                                      print("=== ACCOUNT DEBUG INFO ===");
                                      print("Selected Payment Method: '$selectedPaymentMethod'");
                                      print("All Accounts:");
                                      for (var account in context.read<AccountBloc>().list) {
                                        print(" - ${account.acName} | Type: '${account.acType}' | ID: ${account.acId}");
                                      }

                                      final List<AccountModel> filteredList = selectedPaymentMethod != null
                                          ? context.read<AccountBloc>().list.where((item) {
                                        // Debug each comparison
                                        bool matches = item.acType?.toLowerCase() == selectedPaymentMethod.toLowerCase();
                                        if (matches) {
                                          print("MATCH FOUND: '${item.acType}' == '$selectedPaymentMethod'");
                                        }
                                        return matches;
                                      }).toList()
                                          : context.read<AccountBloc>().list;

                                      print("Filtered Accounts Count: ${filteredList.length}");
                                      print("==========================");

                                      return AppDropdown<AccountModel>(
                                        label: "Account",
                                        hint: filteredList.isEmpty ? "No accounts available" : "Select Account",
                                        context: context,
                                        isLabel: false,
                                        isRequired: true,
                                        isNeedAll: false,
                                        value: null,
                                        itemList: filteredList,
                                        onChanged: (AccountModel? newVal) {
                                          if (newVal != null) {
                                            context.read<MoneyReceiptBloc>().selectedAccountId = newVal.acId.toString();
                                            print("Selected Account: ${newVal.acName} (ID: ${newVal.acId})");
                                          }
                                        },
                                        validator: (value) {
                                          if (filteredList.isEmpty && selectedPaymentMethod != null) {
                                            return 'No ${selectedPaymentMethod} accounts available';
                                          }
                                          return value == null ? 'Please select an account' : null;
                                        },
                                        itemBuilder: (AccountModel item) => DropdownMenuItem<AccountModel>(
                                          value: item,
                                          child: Text(
                                            "${item.acName ?? 'Unknown'} - ${item.acNumber ?? 'No Number'}",
                                            style: const TextStyle(
                                              color: AppColors.blackColor,
                                              fontFamily: 'Quicksand',
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            ResponsiveCol(
                              xs: 12,
                              sm: 2,
                              md: 2,
                              lg: 2,
                              xl: 2,
                              child: CustomInputField(
                                isRequiredLable: true,
                                isRequired: true,
                                controller: context
                                    .read<MoneyReceiptBloc>()
                                    .amountController,
                                hintText: 'Amount',
                                fillColor: const Color.fromARGB(
                                  255,
                                  255,
                                  255,
                                  255,
                                ),
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
                            ),
                            ResponsiveCol(
                              xs: 12,
                              sm: 3,
                              md: 3,
                              lg: 3,
                              xl: 3,
                              child: CustomInputField(
                                isRequiredLable: true,
                                isRequired: false,
                                controller: context
                                    .read<MoneyReceiptBloc>()
                                    .remarkController,
                                hintText: 'Remark',
                                fillColor: const Color.fromARGB(
                                  255,
                                  255,
                                  255,
                                  255,
                                ),
                                keyboardType: TextInputType.text,
                                autofillHints: AutofillHints.telephoneNumber,
                                // validator: (value) {
                                //   return value!.isEmpty ? 'Please enter amount ' : null;
                                // },
                                onChanged: (value) {
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppButton(
                      name: "Create",
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;

                        final moneyBloc = context.read<MoneyReceiptBloc>();

                        Map<String, dynamic> body = {
                          "amount": moneyBloc.amountController.text.trim(),
                          "customer_id": moneyBloc.selectCustomerModel?.id.toString(),
                          "payment_date": appWidgets.convertDateTime(
                            DateFormat("dd-MM-yyyy").parse(moneyBloc.dateController.text.trim(), true),
                            "yyyy-MM-dd",
                          ),
                          "payment_method": selectedPaymentMethodNotifier.value.toString(),
                          "seller_id": moneyBloc.selectUserModel?.id.toString(),
                          "account": moneyBloc.selectedAccountId,
                          "specific_invoice": selectedPaymentToState.value != "Over All",
                          "payment_type": selectedPaymentToState.value == "Over All" ? "overall" : "specific",
                        };

                        // Invoice for specific payment
                        if (selectedPaymentToState.value == "Specific" &&
                            selectPosSaleModel.value != null) {
                          body["sale"] = selectPosSaleModel.value!.id.toString();
                        }



                        if (moneyBloc.remarkController.text.isNotEmpty) {
                          body["remark"] = moneyBloc.remarkController.text.trim();
                        }

                        moneyBloc.add(AddMoneyReceipt(body: body));
                      },
                    )

                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
