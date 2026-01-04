import '/core/core.dart';

import '../../data/model/account_model.dart';
import '../bloc/account/account_bloc.dart';
class MobileCreateAccountScreen extends StatefulWidget {
  const MobileCreateAccountScreen({
    super.key,
    this.submitText = '',
    this.id = '',
    this.account,
  });

  final String id;
  final String submitText;
  final AccountModel? account;

  @override
  State<MobileCreateAccountScreen> createState() =>
      _MobileCreateAccountScreenState();
}

class _MobileCreateAccountScreenState
    extends State<MobileCreateAccountScreen> {
  final ValueNotifier<String> selectedAccountType = ValueNotifier('');
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final AccountBloc accountBloc;

  @override
  void initState() {
    super.initState();
    accountBloc = context.read<AccountBloc>();

    if (widget.account != null) {
      _prefill();
    }
  }

  void _prefill() {
    final a = widget.account!;
    selectedAccountType.value = a.acType ?? '';
    accountBloc.accountNameController.text = a.name ?? '';
    accountBloc.accountNumberController.text = a.acNumber ?? '';
    accountBloc.bankNameController.text = a.bankName ?? '';
    accountBloc.branchNameController.text = a.branch ?? '';
    accountBloc.accountOpeningBalanceController.text =
        a.balance?.toString() ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.id.isEmpty
                          ? "Create Account"
                          : "Update Account",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// ACCOUNT TYPE
                ValueListenableBuilder<String>(
                  valueListenable: selectedAccountType,
                  builder: (_, type, __) {
                    return AppDropdown(
                      context: context,
                      label: "Account Type",
                      hint: "Select account type",
                      value: type.isEmpty ? null : type,
                      isRequired: true,
                      itemList: const [
                        "Bank",
                        "Cash",
                        "Mobile banking"
                      ],
                      onChanged: (v) =>
                      selectedAccountType.value = v!,
                      validator: (v) =>
                      v == null ? "Select account type" : null,
                      itemBuilder: (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                /// ACCOUNT NAME
                AppTextField(
                  controller:
                  accountBloc.accountNameController,
                  hintText: "Account Name",
                  isRequired: true,
                  validator: (v) =>
                  v == null || v.trim().length < 2
                      ? "Enter valid account name"
                      : null, keyboardType: TextInputType.text,
                ),

                const SizedBox(height: 10),

                /// OPENING BALANCE
                AppTextField(
                  controller: accountBloc
                      .accountOpeningBalanceController,
                  hintText: "Opening Balance",
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  isRequired: true,
                  validator: (v) {
                    final d = double.tryParse(v ?? '');
                    if (d == null || d < 0) {
                      return "Invalid balance";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                /// ACCOUNT NUMBER
                ValueListenableBuilder<String>(
                  valueListenable: selectedAccountType,
                  builder: (_, type, __) {
                    if (type.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return AppTextField(keyboardType: TextInputType.number,
                      controller:
                      accountBloc.accountNumberController,
                      hintText: type == "Bank"
                          ? "Bank Account Number"
                          : type == "Mobile banking"
                          ? "Mobile Account Number"
                          : "Cash Reference",
                      isRequired: true,
                      validator: (v) =>
                      v == null || v.length < 5
                          ? "Enter valid number"
                          : null,
                    );
                  },
                ),

                const SizedBox(height: 10),

                /// BANK DETAILS
                ValueListenableBuilder<String>(
                  valueListenable: selectedAccountType,
                  builder: (_, type, __) {
                    if (type != "Bank") {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        AppTextField(keyboardType: TextInputType.text,
                          controller:
                          accountBloc.bankNameController,
                          hintText: "Bank Name",
                          isRequired: true,
                        ),
                        const SizedBox(height: 10),
                        AppTextField(keyboardType: TextInputType.text,
                          controller:
                          accountBloc.branchNameController,
                          hintText: "Branch Name",
                          isRequired: true,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                /// BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        name: widget.submitText.isEmpty
                            ? "Create Account"
                            : widget.submitText,
                        onPressed: _submit,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        name: "Cancel",
                        color: Colors.grey,
                        onPressed: () =>
                            Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!formKey.currentState!.validate()) return;

    final body = {
      "name": accountBloc.accountNameController.text.trim(),
      "ac_type": selectedAccountType.value,
      "opening_balance": accountBloc
          .accountOpeningBalanceController.text
          .trim(),
      "ac_number":
      accountBloc.accountNumberController.text.trim(),
      if (selectedAccountType.value == "Bank") ...{
        "bank_name":
        accountBloc.bankNameController.text.trim(),
        "branch":
        accountBloc.branchNameController.text.trim(),
      }
    };

    widget.id.isEmpty
        ? accountBloc.add(AddAccount(body: body))
        : accountBloc.add(
      UpdateAccount(body: body, id: widget.id),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    selectedAccountType.dispose();
    super.dispose();
  }
}
