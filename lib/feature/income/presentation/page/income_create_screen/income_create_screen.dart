import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../data/model/income_model.dart';
import '../../../income_expense/data/model/income_head_model.dart';
import '../../../income_expense/presentation/income_expense_bloc/income_expense_head_bloc.dart';
import '../../IncomeBloc/income_bloc.dart';

class MobileIncomeCreate extends StatefulWidget {
  final String? id;
  final IncomeModel? incomeModel;
  final IncomeHeadModel? selectedIncomeHead;
  final dynamic selectedAccount; // Use your AccountModel if strongly typed

  const MobileIncomeCreate({
    Key? key,
    this.id,
    this.incomeModel,
    this.selectedIncomeHead,
    this.selectedAccount,
  }) : super(key: key);

  @override
  State<MobileIncomeCreate> createState() => _MobileIncomeCreateState();
}

class _MobileIncomeCreateState extends State<MobileIncomeCreate> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController amountController;
  late TextEditingController dateController;
  late TextEditingController noteController;
  IncomeHeadModel? _selectedIncomeHead;
  dynamic _selectedAccount;

  @override
  void initState() {
    super.initState();
    final model = widget.incomeModel;
    amountController = TextEditingController(text: model?.amount ?? '');
    noteController = TextEditingController(text: model?.note ?? '');
    dateController = TextEditingController(
      text: model?.incomeDate ?? DateTime.now().toIso8601String().split('T')[0],
    );
    _selectedIncomeHead = widget.selectedIncomeHead ??
        (model != null
            ? IncomeHeadModel(id: model.head, name: model.headName)
            : null);
    _selectedAccount = widget.selectedAccount ?? model?.account;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncomeHeadBloc>().add(FetchIncomeHeadList(context: context));
      context.read<AccountBloc>().add(FetchAccountActiveList(context));
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(widget.id == null ? 'Create Income' : 'Update Income'),
        content: Text(widget.id == null
            ? 'Are you sure you want to create this income?'
            : 'Are you sure you want to update this income?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
      ),
    );
  }

  void _submitForm() {
    if (!formKey.currentState!.validate()) return;
    if (_selectedIncomeHead == null) {
      showCustomToast(
        context: context,
        title: 'Error!',
        description: 'Please select an income head',
        type: ToastificationType.error,
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );
      return;
    }
    if (_selectedAccount == null || _selectedAccount.toString().isEmpty) {
      showCustomToast(
        context: context,
        title: 'Error!',
        description: 'Please select an account',
        type: ToastificationType.error,
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );
      return;
    }

    final body = {
      "account": _selectedAccount.id,  // <<<------ FIXED
      "amount": amountController.text,
      "income_date": dateController.text,
      "head": _selectedIncomeHead!.id.toString(),
      if (noteController.text.trim().isNotEmpty)
        "note": noteController.text.trim(),
    };

    final bloc = context.read<IncomeBloc>();
    if (widget.id == null) {
      bloc.add(AddIncome(body: body));
    } else {
      bloc.add(UpdateIncome(id: int.parse(widget.id!), body: body));
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Form(
            key: formKey,
            child: BlocListener<IncomeBloc, IncomeState>(
              listener: (context, state) {
                if (state is IncomeAddLoading) {
                  appLoader(
                    context,
                    widget.id == null
                        ? "Creating income..."
                        : "Updating income...",
                  );
                } else if (state is IncomeAddSuccess) {
                  Navigator.pop(context); // appLoader
                  Navigator.pop(context); // modal
                  showCustomToast(
                    context: context,
                    title: 'Success!',
                    description: widget.id == null
                        ? 'Income created successfully'
                        : 'Income updated successfully',
                    type: ToastificationType.success,
                    icon: Icons.check_circle,
                    primaryColor: Colors.green,
                  );
                } else if (state is IncomeAddFailed) {
                  Navigator.pop(context);
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.id == null
                              ? 'Create Income'
                              : 'Update Income',
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
                    SizedBox(height: AppSizes.height(context) * 0.03),

                    // Income Head Dropdown
                    BlocBuilder<IncomeHeadBloc, IncomeHeadState>(
                      builder: (context, state) {
                        return AppDropdown<IncomeHeadModel>(
                          label: "Income Head",
                          hint: _selectedIncomeHead?.name ?? "Select Income Head",
                          isNeedAll: false,
                          isRequired: true,
                          value: _selectedIncomeHead,
                          itemList: context.read<IncomeHeadBloc>().list,
                          onChanged: (val) {
                            setState(() => _selectedIncomeHead = val);
                          },
                          validator: (val) => val == null
                              ? 'Please select Income Head'
                              : null,
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    // Account Dropdown
                    BlocBuilder<AccountBloc, AccountState>(
                      builder: (context, state) {
                        if (state is AccountActiveListLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (state is AccountActiveListSuccess) {
                          return AppDropdown<dynamic>(
                            label: "Account",
                            hint: _selectedAccount?.toString() ?? "Select Account",
                            isNeedAll: false,
                            isRequired: true,
                            value: _selectedAccount,
                            itemList: state.list,
                            onChanged: (val) {
                              setState(() => _selectedAccount = val);
                            },
                            validator: (val) => val == null
                                ? 'Please select Account'
                                : null,
                          );
                        }
                        return Container();
                      },
                    ),
                    const SizedBox(height: 10),

                    // Amount
                    CustomInputField(
                      isRequiredLable: true,
                      isRequired: true,
                      controller: amountController,
                      hintText: 'Amount',
                      fillColor: Colors.white,
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
                    ),
                    const SizedBox(height: 10),

                    // Date
                    CustomInputField(
                      isRequiredLable: true,
                      isRequired: true,
                      controller: dateController,
                      hintText: 'Income Date',
                      fillColor: Colors.white,
                      readOnly: true,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        return value == null || value.isEmpty
                            ? 'Please enter Income Date'
                            : null;
                      },
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          dateController.text =
                          picked.toIso8601String().split('T')[0];
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    // Note
                    CustomInputField(
                      isRequiredLable: false,
                      isRequired: false,
                      controller: noteController,
                      hintText: 'Note',
                      fillColor: Colors.white,
                      keyboardType: TextInputType.text,
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppButton(
                          size: 120,
                          name: "Cancel",
                          isOutlined: true,
                          textColor: AppColors.errorColor(context),
                          borderColor: AppColors.primaryColor(context),
                          onPressed: () => AppRoutes.pop(context),
                        ),
                        const SizedBox(width: 10),
                        AppButton(
                          size: 120,
                          name: widget.id == null ? "Create" : "Update",
                          onPressed: _showConfirmationDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
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