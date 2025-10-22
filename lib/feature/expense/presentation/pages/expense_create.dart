import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_inventory/feature/expense/expense_head/data/model/expense_head_model.dart';
import 'package:smart_inventory/feature/expense/expense_sub_head/data/model/expense_sub_head_model.dart';

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

class ExpenseCreateScreen extends StatefulWidget {
  final String? id;
  final String? name;
  final ExpenseHeadModel? selectedExpenseHead;
  final ExpenseSubHeadModel? selectedExpenseSubHead;

  const ExpenseCreateScreen({
    super.key,
    this.id,
    this.name,
    this.selectedExpenseHead,
    this.selectedExpenseSubHead,
  });

  @override
  State<ExpenseCreateScreen> createState() => _ExpenseCreateScreenState();
}

class _ExpenseCreateScreenState extends State<ExpenseCreateScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late ExpenseHeadModel? _selectedExpenseHead;
  late ExpenseSubHeadModel? _selectedExpenseSubHead;

  @override
  void initState() {
    super.initState();

    // Initialize with existing values if in edit mode
    _selectedExpenseHead = widget.selectedExpenseHead;
    _selectedExpenseSubHead = widget.selectedExpenseSubHead;

    // Fetch expense heads
    context.read<ExpenseHeadBloc>().add(FetchExpenseHeadList(context));

    // Fetch accounts
    context.read<AccountBloc>().add(FetchAccountList(context));

    // Set initial date
    context.read<ExpenseBloc>().dateExpenseTextController.text =
    DateTime.now().toIso8601String().split('T')[0];

    // If we have a selected expense head, fetch its subheads
    if (_selectedExpenseHead != null) {
      context.read<ExpenseSubHeadBloc>().add(
        FetchSubExpenseHeadList(
          context,
          filterText: '',
          pageNumber: 0,
        ),
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
      if (_selectedExpenseHead == null) {
        showCustomToast(
          context: context,
          title: 'Error!',
          description: 'Please select an expense head',
          type: ToastificationType.error,
          icon: Icons.error,
          primaryColor: Colors.redAccent,
        );
        return;
      }

      final Map<String, dynamic> body = {
        "account": context.read<ExpenseBloc>().selectedAccountId, // Changed from account_id
        "amount": context.read<ExpenseBloc>().amountTextController.text,
        "expense_date": context.read<ExpenseBloc>().dateExpenseTextController.text, // Changed from date
        "head": _selectedExpenseHead!.id.toString(), // Changed from expense_type_id
        "payment_method": context.read<ExpenseBloc>().selectedPayment,
        if (_selectedExpenseSubHead != null)
          "subhead": _selectedExpenseSubHead!.id.toString(), // Changed from expense_subhead_id
        if (context.read<ExpenseBloc>().noteTextController.text.isNotEmpty)
          "note": context.read<ExpenseBloc>().noteTextController.text, // Changed from description
      };

      // Debug log to see the actual request body
      print('Sending request body: $body');

      if (widget.id == null) {
        // Create new expense
        context.read<ExpenseBloc>().add(AddExpense(body: body));
      } else {
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
        FetchSubExpenseHeadList(
          context,
          filterText: '',
          pageNumber: 0,
        ),
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

    return ResponsiveRow(
      spacing: 0,
      runSpacing: 0,
      children: [
        ResponsiveCol(
          xs: 12,
          sm: 12,
          md: 12,
          lg: 10,
          xl: 10,
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSize),
            ),
            padding: AppTextStyle.getResponsivePaddingBody(context),
            child: SingleChildScrollView(
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
                                child: const Text("Dismiss")
                            )
                          ]
                      );
                    }
                  },
                  child: Column(
                    children: [
                      // Expense Head Dropdown
                      BlocBuilder<ExpenseHeadBloc, ExpenseHeadState>(
                        builder: (context, state) {
                          if (state is ExpenseHeadListLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          return AppDropdown<ExpenseHeadModel>(
                            context: context,
                            label: "Expense Head",
                            hint: _selectedExpenseHead?.name ?? "Select Expense Head",
                            isNeedAll: false,
                            isRequired: true,
                            value: _selectedExpenseHead,
                            itemList: context.read<ExpenseHeadBloc>().list,
                            onChanged: _onExpenseHeadChanged,
                            validator: (value) {
                              return value == null
                                  ? 'Please select Expense Head'
                                  : null;
                            },
                            itemBuilder: (item) => DropdownMenuItem<ExpenseHeadModel>(
                              value: item,
                              child: Text(
                                item.name ?? 'Unnamed Head',
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

                      const SizedBox(height: 16),

                      // Expense SubHead Dropdown
                      BlocBuilder<ExpenseSubHeadBloc, ExpenseSubHeadState>(
                        builder: (context, state) {
                          final subHeads = _selectedExpenseHead != null
                              ? (context.read<ExpenseSubHeadBloc>().list as List<ExpenseSubHeadModel>)
                              .where((subHead) => subHead.head == _selectedExpenseHead!.id)
                              .toList()
                              : <ExpenseSubHeadModel>[];

                          return AppDropdown<ExpenseSubHeadModel>(
                            context: context,
                            label: "Expense Sub Head (Optional)",
                            hint: _selectedExpenseSubHead?.name ?? "Select Expense Sub Head",
                            isNeedAll: false,
                            isRequired: false,
                            value: _selectedExpenseSubHead,
                            itemList: subHeads,
                            onChanged: _onExpenseSubHeadChanged,
                            itemBuilder: (item) => DropdownMenuItem<ExpenseSubHeadModel>(
                              value: item,
                              child: Text(
                                item.name ?? 'Unnamed Sub Head',
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

                      const SizedBox(height: 16),

                      // Amount Field
                      CustomInputField(
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

                      const SizedBox(height: 16),

                      // Payment Method (only for create)
                      widget.id == null
                          ? AppDropdown<String>(
                        context: context,
                        label: "Payment Method",
                        hint: expenseBloc.selectedPayment.isEmpty
                            ? "Select Payment Method"
                            : expenseBloc.selectedPayment,
                        isLabel: false,
                        isRequired: true,
                        isNeedAll: false,
                        value: expenseBloc.selectedPayment.isEmpty
                            ? null
                            : expenseBloc.selectedPayment,
                        itemList: expenseBloc.paymentMethod,
                        onChanged: (newVal) {
                          setState(() {
                            expenseBloc.selectedPayment = newVal.toString();
                          });
                        },
                        validator: (value) {
                          return value == null
                              ? 'Please select a payment method'
                              : null;
                        },
                        itemBuilder: (item) => DropdownMenuItem<String>(
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
                      )
                          : Container(),

                      const SizedBox(height: 16),

                      // Account Dropdown (only for create)
                      widget.id == null
                          ? BlocBuilder<AccountBloc, AccountState>(
                        builder: (context, state) {
                          if (state is AccountListLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is AccountListSuccess) {
                            // Filter accounts based on selected payment method
                            final filteredList = expenseBloc.selectedPayment.isNotEmpty
                                ? state.list.where((item) {
                              return item.acType?.toLowerCase() ==
                                  expenseBloc.selectedPayment.toLowerCase();
                            }).toList()
                                : state.list;

                            return AppDropdown<dynamic>(
                              context: context,
                              label: "Account",
                              hint: "Select Account",
                              isLabel: false,
                              isRequired: true,
                              isNeedAll: false,
                              value: expenseBloc.selectedAccount.isEmpty
                                  ? null
                                  : expenseBloc.selectedAccount,
                              itemList: filteredList,
                              onChanged: (newVal) {
                                final selectedAccount = filteredList.firstWhere(
                                      (acc) => acc.toString() == newVal.toString(),
                                );

                                setState(() {
                                  expenseBloc.selectedAccount = newVal.toString();
                                  expenseBloc.selectedAccountId = selectedAccount.acId.toString();
                                });
                              },
                              validator: (value) {
                                return value == null
                                    ? 'Please select an account'
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
                          } else if (state is AccountListFailed) {
                            return Center(
                                child: Text('Failed to load accounts: ${state.content}'));
                          } else {
                            return Container();
                          }
                        },
                      )
                          : Container(),

                      const SizedBox(height: 16),

                      // Date Field
                      CustomInputField(
                        isRequiredLable: true,
                        isRequired: true,
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
                            expenseBloc.dateExpenseTextController.text =
                            pickedDate.toLocal().toString().split(' ')[0];
                          }
                        },
                        onChanged: (value) {
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

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

                      const SizedBox(height: 20),

                      // Submit Button
                      AppButton(
                        name: widget.name ?? "Create",
                        onPressed: _showConfirmationDialog,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}