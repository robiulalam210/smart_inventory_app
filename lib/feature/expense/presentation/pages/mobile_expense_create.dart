import '../../../accounts/data/model/account_active_model.dart';
import '../../data/model/expense.dart';
import '/feature/expense/expense_head/data/model/expense_head_model.dart';
import '/feature/expense/expense_sub_head/data/model/expense_sub_head_model.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../expense_head/presentation/bloc/expense_head/expense_head_bloc.dart';
import '../../expense_sub_head/presentation/bloc/expense_sub_head/expense_sub_head_bloc.dart';
import '../bloc/expense_list/expense_bloc.dart';

class MobileExpenseCreate extends StatefulWidget {
  final String? id;
  final String? name;
  final String? accountId;
  final ExpenseModel? expenseModel;
  final ExpenseHeadModel? selectedExpenseHead;
  final ExpenseSubHeadModel? selectedExpenseSubHead;
  final ScrollController? scrollController; // 🔥 Add scrollController
  const MobileExpenseCreate({
    super.key,
    this.id,
    this.name,
    this.expenseModel,
    this.accountId,
    this.selectedExpenseHead,
    this.selectedExpenseSubHead,
    this.scrollController,
  });

  @override
  State<MobileExpenseCreate> createState() => _ExpenseCreateScreenState();
}

class _ExpenseCreateScreenState extends State<MobileExpenseCreate> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late ExpenseHeadModel? _selectedExpenseHead;
  late ExpenseSubHeadModel? _selectedExpenseSubHead;

  @override
  void initState() {
    super.initState();

    // Initialize with existing values if in edit mode
    _selectedExpenseHead = widget.selectedExpenseHead;
    _selectedExpenseSubHead = widget.selectedExpenseSubHead;

    if (widget.expenseModel != null) {
      context.read<ExpenseBloc>().noteTextController.text =
          widget.expenseModel?.note ?? "";
      context.read<ExpenseBloc>().amountTextController.text =
          widget.expenseModel?.account.toString() ?? "";
      context.read<ExpenseBloc>().dateExpenseTextController.text =
          widget.expenseModel?.expenseDate.toString() ?? "";
    }

    // Fetch expense heads
    context.read<ExpenseHeadBloc>().add(FetchExpenseHeadList(context));

    // Fetch accounts
    context.read<AccountBloc>().add(FetchAccountActiveList(context));

    // Set initial date
    context.read<ExpenseBloc>().dateExpenseTextController.text = DateTime.now()
        .toIso8601String()
        .split('T')[0];

    // If we have a selected expense head, fetch its subheads
    if (_selectedExpenseHead != null) {
      context.read<ExpenseSubHeadBloc>().add(
        FetchSubExpenseHeadList(context, filterText: '', pageNumber: 0),
      );
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.id == null ? 'Create Expense' : 'Update Expense'),
          content: Text(
            widget.id == null
                ? 'Are you sure you want to create this expense?'
                : 'Are you sure you want to update this expense?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitForm();
              },
              child: Text(widget.id == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      final accountId = context.read<ExpenseBloc>().selectedAccountId;

      if (accountId.isEmpty) {
        showCustomToast(
          context: context,
          title: 'Error!',
          description: 'Please select an account.',
          type: ToastificationType.error,
          icon: Icons.error,
          primaryColor: Colors.redAccent,
        );
        return;
      }

      // Complete the payment method mapping function
      String mapPaymentMethodToBackend(String frontendValue) {
        final mapping = {
          "Cash": "cash",
          "Bank": "bank",
          "Mobile banking": "mobile",
          "Card": "card",
          "Other": "other",
        };
        return mapping[frontendValue] ?? "cash"; // Added default value
      }

      // Get the mapped payment method
      final String backendPaymentMethod = mapPaymentMethodToBackend(
        context.read<ExpenseBloc>().selectedPayment,
      );

      final Map<String, dynamic> body = {
        "account": accountId,
        "amount": context.read<ExpenseBloc>().amountTextController.text,
        "expense_date": context
            .read<ExpenseBloc>()
            .dateExpenseTextController
            .text,
        // "head": _selectedExpenseHead!.id.toString(),
        "payment_method": backendPaymentMethod, // Use the mapped value
        if (_selectedExpenseHead != null)
          "head": _selectedExpenseHead!.id.toString(),

        if (_selectedExpenseSubHead != null)
          "subhead": _selectedExpenseSubHead!.id.toString(),
        if (context.read<ExpenseBloc>().noteTextController.text.isNotEmpty)
          "note": context.read<ExpenseBloc>().noteTextController.text,
      };

      // Debug log to see the actual request body

      if (widget.id == null) {
        // Create new expense
        context.read<ExpenseBloc>().add(AddExpense(body: body));
      } else {
        final Map<String, dynamic> body = {
          "account": widget.accountId,
          "amount": context.read<ExpenseBloc>().amountTextController.text,
          "expense_date": context
              .read<ExpenseBloc>()
              .dateExpenseTextController
              .text,
          "head": _selectedExpenseHead!.id.toString(),
          "payment_method": backendPaymentMethod, // Use the mapped value
          if (_selectedExpenseSubHead != null)
            "subhead": _selectedExpenseSubHead!.id.toString(),
          if (context.read<ExpenseBloc>().noteTextController.text.isNotEmpty)
            "note": context.read<ExpenseBloc>().noteTextController.text,
        };
        // Update existing expense
        context.read<ExpenseBloc>().add(
          UpdateExpense(body: body, id: widget.id!),
        );
      }
    }
  }

  void _onExpenseHeadChanged(ExpenseHeadModel? newHead) {
    setState(() {
      _selectedExpenseHead = newHead;
      _selectedExpenseSubHead = null; // Reset subhead when head changes
    });

    // Update the bloc
    context.read<ExpenseBloc>().selectedExpenseHead = newHead;

    // Fetch subheads for the selected head
    if (newHead != null) {
      context.read<ExpenseSubHeadBloc>().add(
        FetchSubExpenseHeadList(context, filterText: '', pageNumber: 0),
      );
    }
  }

  void _onExpenseSubHeadChanged(ExpenseSubHeadModel? newSubHead) {
    setState(() {
      _selectedExpenseSubHead = newSubHead;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    final expenseBloc = context.read<ExpenseBloc>();

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSize),
      ),
      padding: AppTextStyle.getResponsivePaddingBody(context),
      child: SingleChildScrollView(
        controller: widget.scrollController, // 🔥 Attach scrollController
        child: Form(
          key: formKey,
          child: BlocListener<ExpenseBloc, ExpenseState>(
            listener: (context, state) {
              if (state is ExpenseAddLoading) {
                appLoader(context, "Processing expense, please wait...");
              } else if (state is ExpenseAddSuccess) {
                Navigator.pop(context); // Close loader dialog
                // Navigator.of(context).pop(true); // Return success
              } else if (state is ExpenseAddFailed) {
                Navigator.pop(context); // Close loader dialog
                appAlertDialog(
                  context,
                  state.content,
                  title: state.title,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Dismiss"),
                    ),
                  ],
                );
              }
            },
            child: Column(
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.id == null ? 'Create Expense ' : 'Update Expense',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.text(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => AppRoutes.pop(context),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 22,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSizes.height(context) * 0.02),
                SizedBox(
                  child: BlocBuilder<ExpenseHeadBloc, ExpenseHeadState>(
                    builder: (context, state) {
                      if (state is ExpenseHeadListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return AppDropdown<ExpenseHeadModel>(
                        label: "Expense Head",
                        isLabel: true,
                        hint:
                            _selectedExpenseHead?.name ?? "Select Expense Head",
                        isNeedAll: false,
                        isRequired: false,
                        value: _selectedExpenseHead,
                        itemList: context.read<ExpenseHeadBloc>().list,
                        onChanged: _onExpenseHeadChanged,
                        // validator: (value) {
                        //   return value == null
                        //       ? 'Please select Expense Head'
                        //       : null;
                        // },
                      );
                    },
                  ),
                ),

                gapH8,
                // Expense SubHead Dropdown
                SizedBox(
                  child: BlocBuilder<ExpenseSubHeadBloc, ExpenseSubHeadState>(
                    builder: (context, state) {
                      final subHeads = _selectedExpenseHead != null
                          ? (context.read<ExpenseSubHeadBloc>().list)
                                .where(
                                  (subHead) =>
                                      subHead.head == _selectedExpenseHead!.id,
                                )
                                .toList()
                          : <ExpenseSubHeadModel>[];

                      /// 🔥 If empty → return SizedBox (not visible)
                      if (subHeads.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return AppDropdown<ExpenseSubHeadModel>(
                        label: "Expense Sub Head (Optional)",
                        hint:
                            _selectedExpenseSubHead?.name ??
                            "Select Expense Sub Head",
                        isNeedAll: false,
                        isLabel: true,

                        isRequired: false,
                        value: _selectedExpenseSubHead,
                        itemList: subHeads,
                        onChanged: _onExpenseSubHeadChanged,
                      );
                    },
                  ),
                ),

                gapH8,
                ValueListenableBuilder<String?>(
                  valueListenable: expenseBloc.selectedPaymentMethodNotifier,
                  builder: (context, selectedPaymentMethod, child) {
                    if (!mounted) return Container();

                    return AppDropdown<String>(
                      label: "Payment Method",
                      hint: selectedPaymentMethod ?? "Select Payment Method",
                      isLabel: true,
                      isRequired: true,
                      isNeedAll: false,
                      value: selectedPaymentMethod,
                      itemList: expenseBloc.paymentMethod,
                      onChanged: (newVal) {
                        expenseBloc.selectedPaymentMethodNotifier.value = newVal
                            .toString();
                        // Clear selected account when payment method changes
                        expenseBloc.selectedAccountNotifier.value = null;
                        setState(() {});
                      },
                      validator: (value) {
                        return value == null
                            ? 'Please select a payment method'
                            : null;
                      },
                    );
                  },
                ),

                gapH8,

                BlocBuilder<AccountBloc, AccountState>(
                  builder: (context, state) {
                    final expenseBloc = context.read<ExpenseBloc>();
                    final selectedPayment = expenseBloc.selectedPaymentMethodNotifier.value;

                    // Hide account dropdown if no payment method selected
                    if (selectedPayment == null || selectedPayment.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    if (state is AccountActiveListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is AccountActiveListSuccess) {
                      // Filter accounts based on selected payment method
                      final paymentMethodMap = {
                        'bank': 'bank',
                        'cash': 'cash',
                        'mobile banking': 'mobile banking',
                        'mobile': 'mobile banking',
                        'other': 'other',
                      };

                      final paymentMethod = selectedPayment.toLowerCase().trim();
                      final mappedPaymentMethod = paymentMethodMap[paymentMethod] ?? paymentMethod;

                      final filteredList = state.list.where((account) {
                        final accountType = account.acType?.toLowerCase().trim() ?? '';
                        return accountType == mappedPaymentMethod;
                      }).toList();

                      // Auto-select first account if none selected
                      if (expenseBloc.accountModel == null && filteredList.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() {
                            expenseBloc.accountModel = filteredList.first;
                            expenseBloc.selectedAccountId = filteredList.first.id.toString();
                            debugPrint("Auto-selected account: ${filteredList.first.name}");
                          });
                        });
                      }

                      // Clear selection if selected account is not in filtered list
                      if (expenseBloc.accountModel != null &&
                          !filteredList.any((account) => account.id == expenseBloc.accountModel!.id)) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() {
                            expenseBloc.accountModel = null;
                            expenseBloc.selectedAccountId = "";
                            debugPrint("Cleared account selection - not in filtered list");
                          });
                        });
                      }

                      return AppDropdown<AccountActiveModel>(
                        label: "Account",
                        hint: filteredList.isEmpty
                            ? "No accounts available"
                            : (expenseBloc.accountModel == null
                            ? "Select Account"
                            : "${expenseBloc.accountModel!.name}${expenseBloc.accountModel!.acNumber != null ? ' - ${expenseBloc.accountModel!.acNumber}' : ''}"),
                        isLabel: true,
                        isRequired: true,
                        isNeedAll: false,
                        value: expenseBloc.accountModel,
                        itemList: filteredList,
                        onChanged: (newVal) {
                          setState(() {
                            expenseBloc.accountModel = newVal;
                            if (newVal != null) {
                              expenseBloc.selectedAccountId = newVal.id.toString();
                              debugPrint("Selected Account: ${newVal.name} (ID: ${newVal.id})");
                            } else {
                              expenseBloc.selectedAccountId = "";
                              debugPrint("Account selection cleared");
                            }
                          });
                        },
                        validator: (value) {
                          if (selectedPayment != null && filteredList.isEmpty) {
                            return 'No "$selectedPayment" accounts available';
                          }
                          return value == null ? 'Please select an account' : null;
                        },
                      );
                    }

                    if (state is AccountActiveListFailed) {
                      return Text('Failed to load accounts: ${state.content}');
                    }

                    return const SizedBox.shrink();
                  },
                ),

                // Amount Field
                gapH8,
                // Payment Method (only for create)
                SizedBox(
                  child: CustomInputField(
                    isRequiredLable: true,
                    isRequired: true,
                    controller: expenseBloc.amountTextController,
                    hintText: 'Amount',
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      return null;
                    },
                  ),
                ),
                // Note Field
                CustomInputField(
                  isRequiredLable: true,
                  isRequired: false,
                  controller: expenseBloc.noteTextController,
                  hintText: 'Note',
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    return null;
                  },
                ),
                SizedBox(
                  child: CustomInputField(
                    isRequiredLable: true,
                    isRequired: false,
                    controller: expenseBloc.dateExpenseTextController,
                    hintText: 'Expense Date',
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    readOnly: true,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      return value == null || value.isEmpty
                          ? 'Please enter Expense Date'
                          : null;
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
                        expenseBloc.dateExpenseTextController.text = pickedDate
                            .toLocal()
                            .toString()
                            .split(' ')[0];
                      }
                    },
                    onChanged: (value) {
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Submit Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppButton(
                      size: 120,
                      name: "Cancel",
                      isOutlined: true,
                      textColor: AppColors.errorColor(context),
                      borderColor: AppColors.primaryColor(context),
                      onPressed: () {
                        AppRoutes.pop(context);
                      },
                    ),
                    SizedBox(width: 10),
                    AppButton(
                      size: 120,
                      name: widget.name ?? "Create",
                      onPressed: _showConfirmationDialog,
                    ),
                  ],
                ),

                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
