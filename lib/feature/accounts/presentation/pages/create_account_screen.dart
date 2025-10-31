import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/input_field.dart';
import '../../data/model/account_model.dart';
import '../bloc/account/account_bloc.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({
    super.key,
    this.submitText = '',
    this.id = '',
    this.account,
  });
  final String id;
  final String submitText;
  final AccountModel? account;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final ValueNotifier<String> selectedAccountType = ValueNotifier<String>('');
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill form if editing existing account
    if (widget.account != null) {
      _prefillFormData();
    }
  }

  void _prefillFormData() {
    final account = widget.account;
    if (account == null) return;

    final accountBloc = context.read<AccountBloc>();

    // Set account type
    selectedAccountType.value = account.acType ?? '';

    // Set controllers
    accountBloc.accountNameController.text = account.acName ?? '';
    accountBloc.accountNumberController.text = account.acNumber ?? '';
    accountBloc.bankNameController.text = account.bankName ?? '';
    accountBloc.branchNameController.text = account.branch ?? '';
    accountBloc.accountOpeningBalanceController.text = account.balance?.toString() ?? '0.0';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.whiteColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.id.isEmpty ? "Create Account" : "Update Account",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ResponsiveRow(
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    // Account Type Dropdown
                    ResponsiveCol(
                      xs: 12,
                      sm: 6,
                      md: 4,
                      lg: 4,
                      xl: 4,
                      child: ValueListenableBuilder<String>(
                        valueListenable: selectedAccountType,
                        builder: (context, selectedType, child) {
                          return AppDropdown(
                            context: context,
                            label: "Account Type",
                            hint: selectedType.isEmpty
                                ? "Select Account type"
                                : selectedType,
                            isRequired: true,
                            isNeedAll: false,
                            value: selectedType.isEmpty ? null : selectedType,
                            itemList: const ["Bank", "Mobile Banking", "Cash", "Other"],
                            onChanged: (newVal) {
                              selectedAccountType.value = newVal.toString();
                              setState(() {});
                            },
                            validator: (value) {
                              if (value == null || value.toString().isEmpty) {
                                return 'Please select account type';
                              }
                              return null;
                            },
                            itemBuilder: (item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                item.toString(),
                                style: const TextStyle(
                                  color: AppColors.blackColor,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Account Name
                    ResponsiveCol(
                      xs: 12,
                      sm: 6,
                      md: 4,
                      lg: 4,
                      xl: 4,
                      child: CustomInputField(
                        isRequiredLable: true,
                        isRequired: true,
                        textInputAction: TextInputAction.next,
                        controller: context.read<AccountBloc>().accountNameController,
                        hintText: 'Account Name',
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter account name';
                          }
                          if (value.trim().length < 2) {
                            return 'Account name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Account Number (Only for Bank and Mobile Banking)
                    ResponsiveCol(
                      xs: 12,
                      sm: 6,
                      md: 4,
                      lg: 4,
                      xl: 4,
                      child: ValueListenableBuilder<String>(
                        valueListenable: selectedAccountType,
                        builder: (context, selectedType, child) {
                          final isBank = selectedType == "Bank";
                          final isMobile = selectedType == "Mobile Banking";
                          final showField = isBank || isMobile;

                          if (!showField) {
                            return Container();
                          }

                          return CustomInputField(
                            isRequiredLable: true,
                            isRequired: true,
                            textInputAction: TextInputAction.next,
                            controller: context.read<AccountBloc>().accountNumberController,
                            hintText: isBank ? 'Bank Account Number' : 'Mobile Account Number',
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter account number';
                              }
                              if (value.trim().length < 5) {
                                return 'Account number must be at least 5 characters';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bank Details Section (Only for Bank type)
                ValueListenableBuilder<String>(
                  valueListenable: selectedAccountType,
                  builder: (context, selectedType, child) {
                    final isBank = selectedType == "Bank";
                    return isBank
                        ? ResponsiveRow(
                      spacing: 20,
                      runSpacing: 10,
                      children: [
                        ResponsiveCol(
                          xs: 12,
                          sm: 6,
                          md: 6,
                          lg: 6,
                          xl: 6,
                          child: CustomInputField(
                            isRequiredLable: true,
                            isRequired: true,
                            textInputAction: TextInputAction.next,
                            controller: context.read<AccountBloc>().bankNameController,
                            hintText: 'Bank Name',
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter bank name';
                              }
                              if (value.trim().length < 2) {
                                return 'Bank name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        ResponsiveCol(
                          xs: 12,
                          sm: 6,
                          md: 6,
                          lg: 6,
                          xl: 6,
                          child: CustomInputField(
                            isRequiredLable: true,
                            isRequired: true,
                            textInputAction: TextInputAction.next,
                            controller: context.read<AccountBloc>().branchNameController,
                            hintText: 'Branch Name',
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter branch name';
                              }
                              if (value.trim().length < 2) {
                                return 'Branch name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    )
                        : Container();
                  },
                ),

                const SizedBox(height: 16),

                // Opening Balance
                ResponsiveRow(
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    ResponsiveCol(
                      xs: 12,
                      sm: 6,
                      md: 6,
                      lg: 6,
                      xl: 6,
                      child: CustomInputField(
                        isRequiredLable: true,
                        isRequired: true,
                        textInputAction: TextInputAction.done,
                        controller: context.read<AccountBloc>().accountOpeningBalanceController,
                        hintText: 'Opening Balance',
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter opening balance';
                          }
                          final balance = double.tryParse(value);
                          if (balance == null) {
                            return 'Please enter a valid number';
                          }
                          if (balance < 0) {
                            return 'Opening balance cannot be negative';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Submit Button
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        name: widget.submitText.isEmpty ? "Create Account" : widget.submitText,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            _createOrUpdateAccount();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        name: "Cancel",
                        color: Colors.grey,
                        onPressed: () => Navigator.of(context).pop(),
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

  void _createOrUpdateAccount() {
    final accountBloc = context.read<AccountBloc>();
    final selectedType = selectedAccountType.value;

    Map<String, dynamic> body = {
      "ac_name": accountBloc.accountNameController.text.trim(),
      "ac_type": selectedType,
      "opening_balance": accountBloc.accountOpeningBalanceController.text.trim(),
    };

    // Add account number for bank and mobile banking accounts
    if (selectedType == "Bank" || selectedType == "Mobile Banking") {
      body["ac_number"] = accountBloc.accountNumberController.text.trim();
    }

    // Add bank details only for bank accounts
    if (selectedType == "Bank") {
      body["bank_name"] = accountBloc.bankNameController.text.trim();
      body["branch"] = accountBloc.branchNameController.text.trim();
    }

    debugPrint("Sending account payload: $body");

    if (widget.id.isEmpty) {
      // Create new account
      accountBloc.add(AddAccount(body: body));
    } else {
      // Update existing account
      accountBloc.add(UpdateAccount(body: body, id: widget.id));
    }

    // Close dialog after submission
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    selectedAccountType.dispose();
    super.dispose();
  }
}