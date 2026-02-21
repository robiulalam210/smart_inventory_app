import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../../../../accounts/data/model/account_active_model.dart';
import '../../../../accounts/presentation/bloc/account/account_bloc.dart';
import '../../../data/model/income_model.dart';
import '../../../income_expense/data/model/income_head_model.dart';
import '../../../income_expense/presentation/income_expense_bloc/income_expense_head_bloc.dart';
import '../../IncomeBloc/income_bloc.dart';
class MobileIncomeCreate extends StatefulWidget {
  final String? id;
  final IncomeModel? incomeModel;
  final ScrollController? scrollController; // 🔥 Add scrollController


  const MobileIncomeCreate({Key? key, this.id, this.incomeModel,this.scrollController}) : super(key: key);

  @override
  State<MobileIncomeCreate> createState() => _MobileIncomeCreateState();
}

class _MobileIncomeCreateState extends State<MobileIncomeCreate> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController amountController;
  late TextEditingController noteController;
  late TextEditingController dateController;

  IncomeHeadModel? _selectedIncomeHead;
  AccountActiveModel? _selectedAccount;
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();

    final model = widget.incomeModel;

    amountController = TextEditingController(text: model?.amount ?? '');
    noteController = TextEditingController(text: model?.note ?? '');
    dateController = TextEditingController(
      text: model?.incomeDate ?? DateTime.now().toIso8601String().split('T')[0],
    );

    _selectedIncomeHead = model != null
        ? IncomeHeadModel(id: model.head, name: model.headName)
        : null;

    // 1️⃣ Default payment method to "Cash"
    _selectedPaymentMethod = "Cash";

    // Account will be auto-selected after fetch
    _selectedAccount = null;

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

  void _submitForm() {
    if (!formKey.currentState!.validate()) return;

    final body = {
      "account": _selectedAccount?.id,
      "amount": amountController.text,
      "income_date": dateController.text,
      if (_selectedIncomeHead != null) "head": _selectedIncomeHead!.id.toString(),
      if (noteController.text.isNotEmpty) "note": noteController.text.trim(),
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
    return Form(
      key: formKey,
      child: BlocListener<IncomeBloc, IncomeState>(
        listener: (context, state) {
          if (state is IncomeAddLoading) {
            appLoader(context, widget.id == null ? "Creating..." : "Updating...");
          } else if (state is IncomeAddSuccess) {
            Navigator.pop(context);
            Navigator.pop(context);
            showCustomToast(
              context: context,
              title: "Success!",
              description: widget.id == null ? "Income created" : "Income updated",
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Dismiss"),
                ),
              ],
            );
          }
        },
        child: SingleChildScrollView(
          controller: widget.scrollController, // 🔥 Attach scrollController

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

              SizedBox(height: AppSizes.height(context) * 0.01),
              // 2️⃣ Income Head optional
              BlocBuilder<IncomeHeadBloc, IncomeHeadState>(
                builder: (context, state) {
                  return AppDropdown<IncomeHeadModel>(
                    label: "Income Head (Optional)",
                    isLabel: true,
                    hint: _selectedIncomeHead?.name ?? "Select Income Head",
                    value: _selectedIncomeHead,
                    itemList: context.read<IncomeHeadBloc>().list,
                    onChanged: (val) => setState(() => _selectedIncomeHead = val),
                    isRequired: false,
                  );
                },
              ),

              const SizedBox(height: 4),

              // Payment Method
              AppDropdown<String>(
                label: "Payment Method",
                isLabel: true,
                hint: _selectedPaymentMethod ?? "Select Payment Method",
                value: _selectedPaymentMethod,
                itemList: ["Cash", "Bank", "Mobile Banking", "Other"],
                onChanged: (val) {
                  setState(() {
                    _selectedPaymentMethod = val;
                    _selectedAccount = null; // clear account when method changes
                  });
                },
                isRequired: true,
              ),

              const SizedBox(height: 4),

              // 3️⃣ Account Dropdown auto-selected
              BlocBuilder<AccountBloc, AccountState>(
                builder: (context, state) {
                  if (state is AccountActiveListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is AccountActiveListSuccess) {
                    final filtered = state.list.where((acc) {
                      final type = acc.acType?.toLowerCase() ?? "";
                      final selected = _selectedPaymentMethod?.toLowerCase() ?? "";
                      if (selected == "cash") return type == "cash";
                      if (selected == "bank") return type == "bank";
                      if (selected.contains("mobile")) return type == "mobile banking";
                      return type == "other";
                    }).toList();

                    // Auto-select first account
                    if (_selectedAccount == null && filtered.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        setState(() => _selectedAccount = filtered.first);
                      });
                    }

                    return AppDropdown<AccountActiveModel>(
                      label: "Account",                isLabel: true,

                      hint: filtered.isEmpty
                          ? "No accounts available"
                          : _selectedAccount?.name ?? "Select Account",
                      value: _selectedAccount,
                      itemList: filtered,
                      onChanged: (val) => setState(() => _selectedAccount = val),
                      isRequired: true,
                      validator: (val) => val == null ? "Please select account" : null,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 4),

              // Amount
              CustomInputField(
                controller: amountController,
                hintText: "Amount",                isRequiredLable: true,

                keyboardType: TextInputType.number,
                isRequired: true,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Please enter amount";
                  if (double.tryParse(val) == null) return "Please enter valid number";
                  return null;
                },
              ),

              // Note
              CustomInputField(
                isRequiredLable: true,
                controller: noteController,
                hintText: "Note",
              ),
              // Date
              CustomInputField(
                controller: dateController,
                hintText: "Income Date",
                readOnly: true,                isRequiredLable: true,

                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => dateController.text = picked.toIso8601String().split('T')[0]);
                  }
                },
                isRequired: true,
              ),




              const SizedBox(height: 8),

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
                    onPressed: _submitForm,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
