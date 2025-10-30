import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/input_field.dart';
import '../bloc/account/account_bloc.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key, this.submitText = '', this.id = ''});
  final String id;
  final String submitText;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final ValueNotifier<String> selectedAccountType = ValueNotifier<String>('');
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchApi();
  }

  void _fetchApi({
    String filterText = '',
    String accountType = '',
    int pageNumber = 0,
  }) {
    context.read<AccountBloc>().add(
      FetchAccountList(
        context,
        filterText: filterText,
        accountType: accountType,
        pageNumber: pageNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
    return Container(
      color: AppColors.bg,
      child: SafeArea(
        child: ResponsiveRow(
          spacing: 0,
          runSpacing: 0,
          children: [
            _buildContentArea(isBigScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildContentArea(bool isBigScreen) {
    return ResponsiveCol(
      xs: 12,
      sm: 12,
      md: 12,
      lg: 10,
      xl: 10,
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSize),
        ),
        child: Padding(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: AppSizes.height(context) * 0.02),

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
                              itemList: const ["Bank", "Mobile banking", "Cash", "Other"],
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
                          onChanged: (value) {
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
                            final isMobile = selectedType == "Mobile banking";
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
                              onChanged: (value) {
                                return null;
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSizes.height(context) * 0.02),

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
                              onChanged: (value) {
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
                              onChanged: (value) {
                                return null;
                              },
                            ),
                          ),
                        ],
                      )
                          : Container();
                    },
                  ),

                  SizedBox(height: AppSizes.height(context) * 0.02),

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
                          onChanged: (value) {
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSizes.height(context) * 0.03),

                  // Submit Button
                  AppButton(
                    name: widget.submitText.isEmpty ? "Create Account" : widget.submitText,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        _createOrUpdateAccount();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _createOrUpdateAccount() {
    final accountBloc = context.read<AccountBloc>();
    final selectedType = selectedAccountType.value;

    // Clear previous validation
    formKey.currentState?.save();

    Map<String, dynamic> body = {
      "ac_name": accountBloc.accountNameController.text.trim(),
      "ac_type": selectedType,
      "opening_balance": accountBloc.accountOpeningBalanceController.text.trim(),
    };

    // Add account number for bank and mobile banking accounts
    if (selectedType == "Bank" || selectedType == "Mobile banking") {
      body["ac_number"] = accountBloc.accountNumberController.text.trim();
    } else {
      // For Cash and Other, explicitly set to null
      body["ac_number"] = null;
    }

    // Add bank details only for bank accounts
    if (selectedType == "Bank") {
      body["bank_name"] = accountBloc.bankNameController.text.trim();
      body["branch"] = accountBloc.branchNameController.text.trim();
    } else {
      // For non-bank accounts, explicitly set to null
      body["bank_name"] = null;
      body["branch"] = null;
    }

    print("Sending payload: $body"); // For debugging

    if (widget.id.isEmpty) {
      // Create new account
      accountBloc.add(AddAccount(body: body));
    } else {
      // Update existing account
      // Add status if needed for update
      if (widget.id.isNotEmpty) {
        body["status"] = "1"; // Active by default
      }
      // accountBloc.add(UpdateAccount(body: body, id: widget.id));
    }

    // Show success message or handle response
    _showSuccessMessage();
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.id.isEmpty
            ? 'Account created successfully!'
            : 'Account updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    selectedAccountType.dispose();
    super.dispose();
  }
}