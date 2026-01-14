import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/core/core.dart';
import '../../../accounts/data/model/account_active_model.dart';
import '../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../sales/data/models/pos_sale_model.dart';
import '../../../sales/presentation/bloc/possale/possale_bloc.dart';
import '../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../bloc/money_receipt/money_receipt_bloc.dart';
import '../bloc/money_receipt/money_receipt_state.dart';
import 'mobile_money_receipt_list.dart';

class MobileMoneyReceiptForm extends StatefulWidget {
  const MobileMoneyReceiptForm({super.key});

  @override
  State<MobileMoneyReceiptForm> createState() => _MoneyReceiptListScreenState();
}

class _MoneyReceiptListScreenState extends State<MobileMoneyReceiptForm> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey3 = GlobalKey<FormState>();

  late MoneyReceiptBloc moneyReceiptBloc;
  bool _isValidationMode = false;

  ValueNotifier<String> selectedPaymentToState = ValueNotifier<String>('Over All');
  ValueNotifier<PosSaleModel?> selectPosSaleModel = ValueNotifier<PosSaleModel?>(null);
  ValueNotifier<String?> selectedPaymentMethodNotifier = ValueNotifier<String?>("Cash");
  ValueNotifier<String?> selectedAccountNotifier = ValueNotifier<String?>(null);

  // Stepper state for mobile
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    context.read<UserBloc>().add(
      FetchUserList(context, dropdownFilter: "?status=1"),
    );
    context.read<CustomerBloc>().add(FetchCustomerActiveList(context));
    context.read<AccountBloc>().add(FetchAccountActiveList(context));

    moneyReceiptBloc = context.read<MoneyReceiptBloc>();
    moneyReceiptBloc.dateController.text = appWidgets.convertDateTimeDDMMYYYY(DateTime.now());
    moneyReceiptBloc.withdrawDateController.text = appWidgets.convertDateTimeDDMMYYYY(DateTime.now());
  }

  void _setValidationMode(bool mode) {
    if (mounted) {
      setState(() {
        _isValidationMode = mode;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    moneyReceiptBloc = context.read<MoneyReceiptBloc>();
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
    int pageNumber = 1,
    int pageSize = 10,
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
        pageSize: pageSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Money receipt", style: AppTextStyle.titleMedium(context)),
      ),
      body: SafeArea(child: _buildMobileLayout()),
    );
  }

  // ----------------------------
  // Mobile layout (stepper)
  // ----------------------------
  Widget _buildMobileLayout() {
    return BlocConsumer<MoneyReceiptBloc, MoneyReceiptState>(
      listener: (context, state) {
        if (state is MoneyReceiptAddLoading) {
          appLoader(context, "Money receipt, please wait...");
        } else if (state is MoneyReceiptAddSuccess) {
          Navigator.pop(context); // close loader
          _fetchApi(
            customer: moneyReceiptBloc.selectCustomerModel?.id.toString() ?? '',
            seller: moneyReceiptBloc.selectUserModel?.id.toString() ?? '',
            paymentMethod: selectedPaymentMethodNotifier.value?.toString() ?? '',
          );
          AppRoutes.pushReplacement(context, MobileMoneyReceiptList());
        } else if (state is MoneyReceiptAddFailed) {
          Navigator.pop(context);
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
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: _buildMobileStepperContent(),
        );
      },
    );
  }

  Widget _buildMobileStepperContent() {
    return Stepper(
      physics: const ClampingScrollPhysics(),
      type: StepperType.vertical,
      currentStep: currentStep,
      onStepContinue: () {
        // Validate current step before moving
        if (!_validateCurrentStep()) {
          return;
        }

        if (currentStep < 3) {
          setState(() => currentStep += 1);
        } else {
          _createMoneyReceipt();
        }
      },
      onStepCancel: () {
        if (currentStep > 0) setState(() => currentStep -= 1);
      },
      onStepTapped: (step) => setState(() => currentStep = step),
      controlsBuilder: (context, details) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              if (currentStep > 0)
                Expanded(
                  child: AppButton(
                    onPressed: details.onStepCancel,
                    name: "Back",
                    color: AppColors.redColor,
                  ),
                ),
              if (currentStep > 0) const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  onPressed: details.onStepContinue,
                  name: currentStep < 3 ? 'Next' : 'Submit',
                ),
              ),
            ],
          ),
        );
      },
      steps: [
        Step(
          title: Text('Customer & Date', style: AppTextStyle.cardLevelHead(context)),
          content: Form(
            key: formKey1,
            child: _buildMobileTopFormSection(),
          ),
          isActive: currentStep >= 0,
          state: currentStep > 0 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: Text('Payment To / Invoice', style: AppTextStyle.cardLevelHead(context)),
          content: Form(
            key: formKey2,
            child: _buildMobilePaymentToSection(),
          ),
          isActive: currentStep >= 1,
          state: currentStep > 1 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: Text('Payment Info', style: AppTextStyle.cardLevelHead(context)),
          content: Form(
            key: formKey3,
            child: _buildMobilePaymentSection(),
          ),
          isActive: currentStep >= 2,
          state: currentStep > 2 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: Text('Review & Create', style: AppTextStyle.cardLevelHead(context)),
          content: _buildMobileSummarySection(),
          isActive: currentStep >= 3,
          state: StepState.indexed,
        ),
      ],
    );
  }

  bool _validateCurrentStep() {
    switch (currentStep) {
      case 0:
        return _validateStep1();
      case 1:
        return _validateStep2();
      case 2:
        return _validateStep3();
      case 3:
        return true; // No validation needed for review step
      default:
        return true;
    }
  }

  bool _validateStep1() {
    _setValidationMode(true);

    // Validate form
    if (!formKey1.currentState!.validate()) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Please fix the errors in step 1')),
      //   );
      // });
      return false;
    }

    // Validate customer selection
    if (moneyReceiptBloc.selectCustomerModel == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a customer')),
        );
      });
      return false;
    }

    // Validate collected by selection
    if (moneyReceiptBloc.selectUserModel == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select collected by')),
        );
      });
      return false;
    }

    _setValidationMode(false);
    return true;
  }

  bool _validateStep2() {
    _setValidationMode(true);

    // Validate form
    if (!formKey2.currentState!.validate()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fix the errors in step 2')),
        );
      });
      return false;
    }

    // Validate payment to selection
    if (selectedPaymentToState.value.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select payment to')),
        );
      });
      return false;
    }

    // If specific payment is selected, validate invoice
    if (selectedPaymentToState.value == "Specific" && selectPosSaleModel.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an invoice for specific payment')),
        );
      });
      return false;
    }

    _setValidationMode(false);
    return true;
  }

  bool _validateStep3() {
    _setValidationMode(true);

    // Validate form
    if (!formKey3.currentState!.validate()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fix the errors in step 3')),
        );
      });
      return false;
    }

    // Validate payment method
    if (selectedPaymentMethodNotifier.value == null || selectedPaymentMethodNotifier.value!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select payment method')),
        );
      });
      return false;
    }

    // Validate amount
    final amount = double.tryParse(moneyReceiptBloc.amountController.text.trim());
    if (amount == null || amount <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid amount greater than 0')),
        );
      });
      return false;
    }

    // Validate account selection
    if (moneyReceiptBloc.accountModel == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an account')),
        );
      });
      return false;
    }

    _setValidationMode(false);
    return true;
  }

  Widget _buildMobileTopFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            final customerBloc = context.read<CustomerBloc>();
            return AppDropdown(
              label: "Customer",
              isSearch: true,
              hint: moneyReceiptBloc.selectCustomerModel?.name?.toString() ?? "Select Customer",
              isNeedAll: false,
              isRequired: true,
              value: moneyReceiptBloc.selectCustomerModel,
              itemList: customerBloc.activeCustomer,
              onChanged: (newVal) {
                setState(() {
                  moneyReceiptBloc.selectCustomerModel = newVal;
                });

                if (newVal != null) {
                  context.read<PosSaleBloc>().add(
                    FetchCustomerSaleList(
                      context,
                      dropdownFilter: "/due/?customer_id=${newVal.id.toString()}&due=true",
                    ),
                  );
                }
              },
              validator: (value) {
                if (_isValidationMode && value == null) {
                  return 'Please select Customer';
                }
                return null;
              },

            );
          },
        ),
        const SizedBox(height: 12),
        BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            final userBloc = context.read<UserBloc>();
            final userList = userBloc.list;

            if (userList.isNotEmpty && moneyReceiptBloc.selectUserModel == null) {
              moneyReceiptBloc.selectUserModel = userList.first;
            }

            return AppDropdown(
              label: "Collected By",
              hint: moneyReceiptBloc.selectUserModel?.username?.toString() ?? "Select Collected By",
              isLabel: false,
              isRequired: true,
              isNeedAll: false,
              value: moneyReceiptBloc.selectUserModel,
              itemList: userList,
              onChanged: (newVal) {
                setState(() {
                  moneyReceiptBloc.selectUserModel = newVal;
                });
              },
              validator: (value) {
                if (_isValidationMode && value == null) {
                  return 'Please select Collected By';
                }
                return null;
              },

            );
          },
        ),
        const SizedBox(height: 12),
        CustomInputField(
          isRequiredLable: true,
          isRequired: false,
          controller: moneyReceiptBloc.dateController,
          hintText: 'Date',
          fillColor: Colors.white,
          readOnly: true,
          keyboardType: TextInputType.text,
          validator: (value) {
            if (_isValidationMode && (value == null || value.isEmpty)) {
              return 'Please enter Date';
            }
            return null;
          },
          onTap: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() {
                moneyReceiptBloc.dateController.text =
                    appWidgets.convertDateTimeDDMMYYYY(pickedDate);
              });
            }
          },
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildMobilePaymentToSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<String>(
          valueListenable: selectedPaymentToState,
          builder: (context, selectedPaymentTo, child) {
            return AppDropdown<String>(
              label: "Payment To",
              hint: selectedPaymentTo.isNotEmpty ? selectedPaymentTo : "Select Payment To",
              isLabel: false,
              isRequired: true,
              isNeedAll: false,
              value: selectedPaymentTo,
              itemList: moneyReceiptBloc.paymentTo,
              onChanged: (newVal) {
                selectedPaymentToState.value = newVal.toString();
                if (newVal != "Specific") {
                  selectPosSaleModel.value = null;
                }
                setState(() {});
              },
              validator: (value) {
                if (_isValidationMode && value == null) {
                  return 'Please select Payment To';
                }
                return null;
              },

            );
          },
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<String>(
          valueListenable: selectedPaymentToState,
          builder: (context, selectedPaymentTo, child) {
            return selectedPaymentTo == "Specific"
                ? ValueListenableBuilder<PosSaleModel?>(
              valueListenable: selectPosSaleModel,
              builder: (context, selectedPosSale, child) {
                return BlocBuilder<PosSaleBloc, PosSaleState>(
                  builder: (context, state) {
                    final posSaleBloc = context.read<PosSaleBloc>();
                    return AppDropdown<PosSaleModel>(
                      label: "Invoice",
                      hint: selectedPosSale?.invoiceNo?.toString() ?? "Select Invoice",
                      isNeedAll: false,
                      isRequired: true,
                      value: selectedPosSale,
                      itemList: posSaleBloc.list,
                      onChanged: (newVal) {
                        selectPosSaleModel.value = newVal;
                        if (newVal != null) {
                          moneyReceiptBloc.amountController.text = newVal.dueAmount.toString();
                        }
                        setState(() {});
                      },
                      validator: (value) {
                        if (_isValidationMode && value == null) {
                          return 'Please select Invoice';
                        }
                        return null;
                      },

                    );
                  },
                );
              },
            )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildMobilePaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<String?>(
          valueListenable: selectedPaymentMethodNotifier,
          builder: (context, selectedPaymentMethod, child) {
            return AppDropdown<String>(
              label: "Payment Method",
              hint: selectedPaymentMethod ?? "Select Payment Method",
              isLabel: false,
              isRequired: true,
              isNeedAll: false,
              value: selectedPaymentMethod,
              itemList: moneyReceiptBloc.paymentMethod,
              onChanged: (newVal) {
                selectedPaymentMethodNotifier.value = newVal.toString();
                // Clear selected account when payment method changes
                moneyReceiptBloc.accountModel = null;
                moneyReceiptBloc.selectedAccountId = "";
                setState(() {});
              },
              validator: (value) {
                if (_isValidationMode && value == null) {
                  return 'Please select a payment method';
                }
                return null;
              },

            );
          },
        ),
        const SizedBox(height: 12),
        BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            if (state is AccountActiveListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AccountActiveListSuccess) {
              return _buildAccountDropdown(context, state.list);
            } else if (state is AccountActiveListFailed) {
              return Text('Error: ${state.content}');
            } else {
              return const Text('No accounts available');
            }
          },
        ),
        const SizedBox(height: 12),
        AppTextField(
          isRequired: true,
          controller: moneyReceiptBloc.amountController,
          hintText: 'Amount',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (_isValidationMode && (value == null || value.isEmpty)) {
              return 'Please enter amount';
            }
            final amount = double.tryParse(value ?? '');
            if (_isValidationMode && (amount == null || amount <= 0)) {
              return 'Please enter a valid amount greater than 0';
            }
            return null;
          },
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: moneyReceiptBloc.remarkController,
          hintText: 'Remark',
          keyboardType: TextInputType.text,
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildMobileSummarySection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Review", style: AppTextStyle.cardLevelHead(context)),
          const SizedBox(height: 8),
          _reviewRow("Customer", moneyReceiptBloc.selectCustomerModel?.name ?? "-"),
          _reviewRow("Collected By", moneyReceiptBloc.selectUserModel?.username ?? "-"),
          _reviewRow("Payment To", selectedPaymentToState.value),
          if (selectedPaymentToState.value == "Specific")
            _reviewRow("Invoice", selectPosSaleModel.value?.invoiceNo ?? "-"),
          _reviewRow("Payment Method", selectedPaymentMethodNotifier.value ?? "-"),
          _reviewRow("Account", moneyReceiptBloc.accountModel?.name ?? "-"),
          _reviewRow("Amount", moneyReceiptBloc.amountController.text.trim()),
          _reviewRow("Remark", moneyReceiptBloc.remarkController.text.trim().isEmpty ? "-" : moneyReceiptBloc.remarkController.text.trim()),
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyle.cardLevelHead(context))),
          Text(value ?? "-", style: AppTextStyle.cardLevelText(context)),
        ],
      ),
    );
  }

  Widget _buildAccountDropdown(
      BuildContext context,
      List<AccountActiveModel> accounts,
      ) {
    final selectedPaymentMethod = selectedPaymentMethodNotifier.value;

    // Filter accounts based on selected payment method
    final List<AccountActiveModel> filteredList;
    if (selectedPaymentMethod != null && selectedPaymentMethod.isNotEmpty) {
      filteredList = accounts.where((item) {
        final itemType = item.acType?.toLowerCase().trim() ?? '';
        final paymentMethod = selectedPaymentMethod.toLowerCase().trim();

        final paymentMethodMap = {
          'bank': 'bank',
          'cash': 'cash',
          'mobile banking': 'mobile banking',
          'mobile': 'mobile banking',
          'other': 'other',
        };

        final mappedPaymentMethod =
            paymentMethodMap[paymentMethod] ?? paymentMethod;

        return itemType == mappedPaymentMethod;
      }).toList();
    } else {
      filteredList = accounts;
    }

    // Auto-select first account if none is selected and list is available
    if (moneyReceiptBloc.accountModel == null && filteredList.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        moneyReceiptBloc.accountModel = filteredList.first;
        moneyReceiptBloc.selectedAccountId = filteredList.first.id.toString();
        setState(() {});
      });
    }

    return AppDropdown<AccountActiveModel>(
      label: "Account",
      hint: filteredList.isEmpty
          ? "No accounts available"
          : (moneyReceiptBloc.accountModel == null
          ? "Select Account"
          : "${moneyReceiptBloc.accountModel!.name}${moneyReceiptBloc.accountModel!.acNumber != null ? ' - ${moneyReceiptBloc.accountModel!.acNumber}' : ''}"),
      isLabel: false,
      isRequired: true,
      isNeedAll: false,
      value: moneyReceiptBloc.accountModel,
      itemList: filteredList,
      onChanged: (newVal) {
        setState(() {
          moneyReceiptBloc.accountModel = newVal;
          if (newVal != null) {
            moneyReceiptBloc.selectedAccountId = newVal.id.toString();
          } else {
            moneyReceiptBloc.selectedAccountId = "";
          }
        });
      },
      validator: (value) {
        if (_isValidationMode) {
          if (selectedPaymentMethod != null && filteredList.isEmpty) {
            return 'No "$selectedPaymentMethod" accounts available';
          }
          if (value == null) {
            return 'Please select an account';
          }
        }
        return null;
      },

    );
  }

  void _createMoneyReceipt() {
    // Final validation of all steps
    bool allStepsValid = true;
    for (int i = 0; i < 3; i++) {
      if (!_validateStepWithIndex(i)) {
        allStepsValid = false;
        setState(() {
          currentStep = i;
        });
        break;
      }
    }

    if (!allStepsValid) {
      return;
    }

    // Validate required fields
    if (moneyReceiptBloc.selectCustomerModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a customer')),
      );
      return;
    }

    if (moneyReceiptBloc.selectUserModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select collected by')),
      );
      return;
    }

    if (selectedPaymentToState.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select payment to')),
      );
      return;
    }

    if (selectedPaymentToState.value == "Specific" && selectPosSaleModel.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an invoice for specific payment')),
      );
      return;
    }

    if (selectedPaymentMethodNotifier.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select payment method')),
      );
      return;
    }

    if (moneyReceiptBloc.accountModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an account')),
      );
      return;
    }

    final amount = double.tryParse(moneyReceiptBloc.amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid amount greater than 0')),
      );
      return;
    }

    Map<String, dynamic> body = {
      "amount": double.tryParse(moneyReceiptBloc.amountController.text.trim()),
      "customer_id": moneyReceiptBloc.selectCustomerModel!.id.toString(),
      "payment_date": appWidgets.convertDateTime(
        DateFormat("dd-MM-yyyy").parse(moneyReceiptBloc.dateController.text.trim(), true),
        "yyyy-MM-dd",
      ),
      "payment_method": selectedPaymentMethodNotifier.value.toString(),
      "seller_id": moneyReceiptBloc.selectUserModel!.id.toString(),
      "account": moneyReceiptBloc.selectedAccountId,
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
    if (moneyReceiptBloc.remarkController.text.isNotEmpty) {
      body["remark"] = moneyReceiptBloc.remarkController.text.trim();
    }

    moneyReceiptBloc.add(AddMoneyReceipt(body: body));
  }

  bool _validateStepWithIndex(int index) {
    switch (index) {
      case 0:
        return _validateStep1();
      case 1:
        return _validateStep2();
      case 2:
        return _validateStep3();
      default:
        return true;
    }
  }
}