import 'package:intl/intl.dart';
import 'package:smart_inventory/core/core.dart';
import '../../../accounts/data/model/account_active_model.dart';
import '../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../../sales/data/models/pos_sale_model.dart';
import '../../../sales/presentation/bloc/possale/possale_bloc.dart';
import '../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../bloc/money_receipt/money_receipt_bloc.dart';
import '../bloc/money_receipt/money_receipt_state.dart';

class MoneyReceiptForm extends StatefulWidget {
  const MoneyReceiptForm({super.key});

  @override
  State<MoneyReceiptForm> createState() => _MoneyReceiptListScreenState();
}

class _MoneyReceiptListScreenState extends State<MoneyReceiptForm> {
  @override
  void initState() {
    _initializeData();
    super.initState();
  }

  void _initializeData() {
    context.read<UserBloc>().add(
      FetchUserList(context, dropdownFilter: "?status=1"),
    );
    context.read<CustomerBloc>().add(FetchCustomerActiveList(context));
    context.read<AccountBloc>().add(FetchAccountActiveList(context));

    final moneyReceiptBloc = context.read<MoneyReceiptBloc>();
    moneyReceiptBloc.dateController.text = appWidgets.convertDateTimeDDMMYYYY(
      DateTime.now(),
    );
    moneyReceiptBloc.withdrawDateController.text = appWidgets
        .convertDateTimeDDMMYYYY(DateTime.now());
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late MoneyReceiptBloc moneyReceiptBloc;

  ValueNotifier<String> selectedPaymentToState = ValueNotifier<String>(
    'Over All',
  );
  ValueNotifier<PosSaleModel?> selectPosSaleModel =
      ValueNotifier<PosSaleModel?>(null);
  ValueNotifier<String?> selectedPaymentMethodNotifier = ValueNotifier<String?>(
    "Cash",
  );
  ValueNotifier<String?> selectedAccountNotifier = ValueNotifier<String?>(null);

  @override
  void didChangeDependencies() {
    moneyReceiptBloc = context.read<MoneyReceiptBloc>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    selectedPaymentMethodNotifier.dispose();
    selectedPaymentToState.dispose();
    selectPosSaleModel.dispose();
    selectedAccountNotifier.dispose();
    super.dispose();
  }

  void _fetchApi({
    String filterText = '',
    String customer = '',
    String seller = '',
    String paymentMethod = '',
    DateTime? from,
    DateTime? to,
    int pageNumber = 1, // Changed from 0 to 1 for pagination
    int pageSize = 10, // Added pageSize parameter
  }) {
    context.read<MoneyReceiptBloc>().add(
      FetchMoneyReceiptList(
        context,
        filterText: filterText,
        customer: customer,
        seller: seller,
        paymentMethod: paymentMethod,
        startDate: from,
        endDate: to,
        pageNumber: pageNumber,
        pageSize: pageSize, // Add pageSize
      ),
    );
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
              padding: const EdgeInsets.all(10),
              color: AppColors.bg,
              child: BlocListener<MoneyReceiptBloc, MoneyReceiptState>(
                listener: (context, state) {
                  if (state is MoneyReceiptAddLoading) {
                    appLoader(context, "Money receipt, please wait...");
                  } else if (state is MoneyReceiptAddSuccess) {
                    Navigator.pop(context); // Close loader dialog
                    _fetchApi(
                      customer:
                          context
                              .read<MoneyReceiptBloc>()
                              .selectCustomerModel
                              ?.id
                              .toString() ??
                          '',
                      seller:
                          context
                              .read<MoneyReceiptBloc>()
                              .selectUserModel
                              ?.id
                              .toString() ??
                          '',
                      paymentMethod:
                          selectedPaymentMethodNotifier.value?.toString() ?? '',
                    );

                    context.read<DashboardBloc>().add(
                      ChangeDashboardScreen(index: 4),
                    );
                  } else if (state is MoneyReceiptDetailsSuccess) {
                    // AppRoutes.pop(context);
                  } else if (state is MoneyReceiptAddFailed) {
                    Navigator.pop(context); // Close loader dialog
                    _fetchApi(
                      customer:
                          context
                              .read<MoneyReceiptBloc>()
                              .selectCustomerModel
                              ?.id
                              .toString() ??
                          '',
                      seller:
                          context
                              .read<MoneyReceiptBloc>()
                              .selectUserModel
                              ?.id
                              .toString() ??
                          '',
                      paymentMethod:
                          selectedPaymentMethodNotifier.value?.toString() ?? '',
                    );
                    appAlertDialog(
                      context,
                      state.content,
                      title: state.title,
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Dismiss"),
                        ),
                      ],
                    );
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      "Create Money Receipt",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 010),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          ResponsiveRow(
                            spacing: 29,
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
                                    final customerBloc = context
                                        .read<CustomerBloc>();
                                    return AppDropdown(
                                      label: "Customer",
                                      context: context,
                                      isSearch: true,
                                      hint:
                                          moneyBloc.selectCustomerModel?.name
                                              ?.toString() ??
                                          "Select Customer",
                                      isNeedAll: false,
                                      isRequired: true,
                                      value: moneyBloc.selectCustomerModel,
                                      itemList: customerBloc.activeCustomer,
                                      onChanged: (newVal) {
                                        setState(() {
                                          moneyBloc.selectCustomerModel =
                                              newVal;
                                        });

                                        if (newVal != null) {
                                          context.read<PosSaleBloc>().add(
                                            FetchCustomerSaleList(
                                              context,
                                              dropdownFilter:
                                                  "/due/?customer_id=${newVal.id.toString()}&due=true",
                                            ),
                                          );
                                        }
                                      },
                                      validator: (value) {
                                        return value == null
                                            ? 'Please select Customer'
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
                                    final userBloc = context.read<UserBloc>();
                                    final userList = userBloc.list;

                                    // Set default user if none is selected and list is available
                                    if (userList.isNotEmpty &&
                                        moneyBloc.selectUserModel == null) {
                                      moneyBloc.selectUserModel =
                                          userList.first;
                                    }

                                    return AppDropdown(
                                      label: "Collected By",
                                      context: context,
                                      hint:
                                          moneyBloc.selectUserModel?.username
                                              ?.toString() ??
                                          "Select Collected By",
                                      isLabel: false,
                                      isRequired: true,
                                      isNeedAll: false,
                                      value: moneyBloc.selectUserModel,
                                      itemList: userList,
                                      onChanged: (newVal) {
                                        setState(() {
                                          moneyBloc.selectUserModel = newVal;
                                        });
                                      },
                                      validator: (value) {
                                        return value == null
                                            ? 'Please select Collected By'
                                            : null;
                                      },
                                      itemBuilder: (item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(
                                          item.username ?? "Unknown",
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
                                    return AppDropdown<String>(
                                      label: "Payment To",
                                      context: context,
                                      hint: selectedPaymentTo.isNotEmpty
                                          ? selectedPaymentTo
                                          : "Select Payment To",
                                      isLabel: false,
                                      isRequired: true,
                                      isNeedAll: false,
                                      value: selectedPaymentTo,
                                      itemList: moneyBloc.paymentTo,
                                      onChanged: (newVal) {
                                        selectedPaymentToState.value = newVal
                                            .toString();
                                        // Clear invoice selection when payment type changes
                                        if (newVal != "Specific") {
                                          selectPosSaleModel.value = null;
                                        }
                                        setState(() {});
                                      },
                                      validator: (value) {
                                        return value == null
                                            ? 'Please select Payment To'
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
                                                  final posSaleBloc = context
                                                      .read<PosSaleBloc>();
                                                  return AppDropdown<
                                                    PosSaleModel
                                                  >(
                                                    label: "Invoice",
                                                    context: context,
                                                    hint:
                                                        selectedPosSale
                                                            ?.invoiceNo
                                                            ?.toString() ??
                                                        "Select Invoice",
                                                    isNeedAll: false,
                                                    isRequired: true,
                                                    value: selectedPosSale,
                                                    itemList: posSaleBloc.list,
                                                    onChanged: (newVal) {
                                                      selectPosSaleModel.value =
                                                          newVal;
                                                      if (newVal != null) {
                                                        moneyBloc
                                                            .amountController
                                                            .text = newVal
                                                            .dueAmount
                                                            .toString();
                                                      }
                                                      setState(() {});
                                                    },
                                                    validator: (value) {
                                                      return value == null
                                                          ? 'Please select Invoice'
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
                                                                  FontWeight
                                                                      .w300,
                                                            ),
                                                          ),
                                                        ),
                                                  );
                                                },
                                              );
                                            },
                                          )
                                        : const SizedBox.shrink();
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
                                  isRequired: false,
                                  controller: moneyBloc.dateController,
                                  hintText: 'Date',
                                  fillColor: const Color.fromARGB(
                                    255,
                                    255,
                                    255,
                                    255,
                                  ),
                                  readOnly: true,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    return value!.isEmpty
                                        ? 'Please enter Date'
                                        : null;
                                  },
                                  onTap: () async {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(FocusNode());
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );
                                    if (pickedDate != null) {
                                      setState(() {
                                        moneyBloc.dateController.text =
                                            appWidgets.convertDateTimeDDMMYYYY(
                                              pickedDate,
                                            );
                                      });
                                    }
                                  },
                                  onChanged: (value) {},
                                ),
                              ),
                            ],
                          ),
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
                                  valueListenable:
                                      selectedPaymentMethodNotifier,
                                  builder: (context, selectedPaymentMethod, child) {
                                    if (!mounted) return Container();

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
                                      itemList: moneyBloc.paymentMethod,
                                      onChanged: (newVal) {
                                        selectedPaymentMethodNotifier.value =
                                            newVal.toString();
                                        // Clear selected account when payment method changes
                                        moneyBloc.accountModel = null;
                                        moneyBloc.selectedAccountId = "";
                                        setState(() {});
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
                                child: SizedBox(
                                  child: BlocBuilder<AccountBloc, AccountState>(
                                    builder: (context, state) {
                                      // Debug current state
                                      debugPrint(
                                        "Current Account State: ${state.runtimeType}",
                                      );

                                      if (state is AccountActiveListLoading) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else if (state
                                          is AccountActiveListSuccess) {
                                        return _buildAccountDropdown(
                                          context,
                                          state.list,
                                        );
                                      } else if (state
                                          is AccountActiveListFailed) {
                                        return Text('Error: ${state.content}');
                                      } else {
                                        return const Text(
                                          'No accounts available',
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              ResponsiveCol(
                                xs: 12,
                                sm: 2,
                                md: 2,
                                lg: 2,
                                xl: 2,
                                child: Center(
                                  child: AppTextField(
                                    // isRequiredLable: true,
                                    isRequired: true,
                                    controller: moneyBloc.amountController,
                                    hintText: 'Amount',
                                    // fillColor: const Color.fromARGB(
                                    //   255,
                                    //   255,
                                    //   255,
                                    //   255,
                                    // ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter amount';
                                      }
                                      final amount = double.tryParse(value);
                                      if (amount == null || amount <= 0) {
                                        return 'Please enter a valid amount';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    textInputAction: TextInputAction.done,
                                  ),
                                ),
                              ),
                              ResponsiveCol(
                                xs: 12,
                                sm: 3,
                                md: 3,
                                lg: 3,
                                xl: 3,
                                child: AppTextField(
                                  isRequired: false,
                                  controller: moneyBloc.remarkController,
                                  hintText: 'Remark',

                                  keyboardType: TextInputType.text,
                                  onChanged: (value) {
                                    setState(() {});
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
                        size: 200,
                        name: "Create",
                        onPressed: () {
                          _createMoneyReceipt();
                        },
                      ),
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

  Widget _buildAccountDropdown(
    BuildContext context,
    List<AccountActiveModel> accounts,
  ) {
    final moneyBloc = context.read<MoneyReceiptBloc>();
    final selectedPaymentMethod = selectedPaymentMethodNotifier.value;

    // Debug: Print all accounts and payment method for troubleshooting
    debugPrint("=== ACCOUNT FILTERING DEBUG ===");
    debugPrint("Selected Payment Method: '$selectedPaymentMethod'");
    debugPrint("All Accounts:");
    for (var account in accounts) {
      debugPrint(
        " - ${account.acName} | Type: '${account.acType}' | ID: ${account.acId}",
      );
    }

    // Filter accounts based on selected payment method
    final List<AccountActiveModel> filteredList;
    if (selectedPaymentMethod != null && selectedPaymentMethod.isNotEmpty) {
      filteredList = accounts.where((item) {
        final itemType = item.acType?.toLowerCase().trim() ?? '';
        final paymentMethod = selectedPaymentMethod.toLowerCase().trim();

        // Map common payment method variations to account types
        final paymentMethodMap = {
          'bank': 'bank',
          'cash': 'cash',
          'mobile banking': 'mobile banking',
          'mobile': 'mobile banking',

          'other': 'other',
        };

        final mappedPaymentMethod =
            paymentMethodMap[paymentMethod] ?? paymentMethod;

        bool matches = itemType == mappedPaymentMethod;
        if (matches) {
          debugPrint(
            "MATCH FOUND: '${item.acType}' == '$selectedPaymentMethod'",
          );
        }

        return matches;
      }).toList();

      debugPrint("Filtered Accounts Count: ${filteredList.length}");
      debugPrint("Filtered Accounts:");
      for (var account in filteredList) {
        debugPrint(" - ${account.acName} | Type: '${account.acType}'");
      }
    } else {
      filteredList = accounts;
    }

    debugPrint("==============================");

    // Auto-select first account if none is selected and list is available
    if (moneyBloc.accountModel == null && filteredList.isNotEmpty) {
      moneyBloc.accountModel = filteredList.first;
      moneyBloc.selectedAccountId = filteredList.first.acId.toString();
      debugPrint("Auto-selected account: ${filteredList.first.acName}");
    }

    // Clear selection if selected account is not in filtered list
    if (moneyBloc.accountModel != null &&
        !filteredList.any(
          (account) => account.acId == moneyBloc.accountModel!.acId,
        )) {
      moneyBloc.accountModel = null;
      moneyBloc.selectedAccountId = "";
      debugPrint("Cleared account selection - not in filtered list");
    }

    return AppDropdown<AccountActiveModel>(
      context: context,
      label: "Account",
      hint: filteredList.isEmpty
          ? "No accounts available"
          : (moneyBloc.accountModel == null
                ? "Select Account"
                : "${moneyBloc.accountModel!.acName}${moneyBloc.accountModel!.acNumber != null ? ' - ${moneyBloc.accountModel!.acNumber}' : ''}"),
      isLabel: false,
      isRequired: true,
      isNeedAll: false,
      value: moneyBloc.accountModel,
      itemList: filteredList,
      onChanged: (newVal) {
        setState(() {
          moneyBloc.accountModel = newVal;
          if (newVal != null) {
            moneyBloc.selectedAccountId = newVal.acId.toString();
            debugPrint(
              "Selected Account: ${newVal.acName} (ID: ${newVal.acId})",
            );
          } else {
            moneyBloc.selectedAccountId = "";
            debugPrint("Account selection cleared");
          }
        });
      },
      validator: (value) {
        if (selectedPaymentMethod != null && filteredList.isEmpty) {
          return 'No "$selectedPaymentMethod" accounts available';
        }
        return value == null ? 'Please select an account' : null;
      },
      itemBuilder: (item) => DropdownMenuItem(
        value: item,
        child: Text(
          "${item.acName ?? 'Unknown'}${item.acNumber != null && item.acNumber!.isNotEmpty ? ' - ${item.acNumber}' : ''}",
          style: const TextStyle(
            color: AppColors.blackColor,
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }

  void _createMoneyReceipt() {
    if (!formKey.currentState!.validate()) return;

    final moneyBloc = context.read<MoneyReceiptBloc>();

    // Validate required fields
    if (moneyBloc.selectCustomerModel == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a customer')));
      return;
    }

    if (moneyBloc.selectUserModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select collected by')),
      );
      return;
    }

    if (selectedPaymentMethodNotifier.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select payment method')),
      );
      return;
    }

    if (moneyBloc.accountModel == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an account')));
      return;
    }

    Map<String, dynamic> body = {
      "amount": moneyBloc.amountController.text.trim(),
      "customer_id": moneyBloc.selectCustomerModel!.id.toString(),
      "payment_date": appWidgets.convertDateTime(
        DateFormat(
          "dd-MM-yyyy",
        ).parse(moneyBloc.dateController.text.trim(), true),
        "yyyy-MM-dd",
      ),
      "payment_method": selectedPaymentMethodNotifier.value.toString(),
      "seller_id": moneyBloc.selectUserModel!.id.toString(),
      "account": moneyBloc.selectedAccountId,
      "specific_invoice": selectedPaymentToState.value == "Specific",
      "payment_type": selectedPaymentToState.value == "Over All"
          ? "overall"
          : "specific",
    };

    // Add invoice for specific payment
    if (selectedPaymentToState.value == "Specific" &&
        selectPosSaleModel.value != null) {
      body["sale"] = selectPosSaleModel.value!.id.toString();
    }

    // Add remark if provided
    if (moneyBloc.remarkController.text.isNotEmpty) {
      body["remark"] = moneyBloc.remarkController.text.trim();
    }

    moneyBloc.add(AddMoneyReceipt(body: body));
  }
}
