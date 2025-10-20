import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/custom_filter_ui.dart';
import '../../../../core/widgets/input_field.dart';
import '../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../products/product/presentation/bloc/products/products_bloc.dart';
import '../bloc/account/account_bloc.dart';
import '../widget/widget.dart';

class CreateAccountScreen extends StatefulWidget {
  CreateAccountScreen({super.key, this.submitText = '', this.id = ''});
  final String id;
  final String submitText;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final ValueNotifier<String> selectedAccountType = ValueNotifier<String>('');

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
            if (isBigScreen) _buildSidebar(),
            _buildContentArea(isBigScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return ResponsiveCol(
      xs: 0,
      sm: 1,
      md: 1,
      lg: 2,
      xl: 2,
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: const Sidebar(),
      ),
    );
  }

  Widget _buildContentArea(bool isBigScreen) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
                                return value == null ? 'Please select account type' : null;
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
                            return value!.trim().isEmpty
                                ? 'Please enter account name'
                                : null;
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
                            final isCash = selectedType == "Cash";
                            final isOther = selectedType == "Other";
                            return (isCash || isOther)
                                ? Container()
                                : CustomInputField(
                              isRequiredLable: true,
                              isRequired: !isCash && !isOther,
                              textInputAction: TextInputAction.next,
                              controller: context.read<AccountBloc>().accountNumberController,
                              hintText: 'Account Number',
                              fillColor: const Color.fromARGB(255, 255, 255, 255),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (!isCash && !isOther && (value == null || value.trim().isEmpty)) {
                                  return 'Please enter account number';
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
                                return value!.trim().isEmpty
                                    ? 'Please enter bank name'
                                    : null;
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
                                return value!.trim().isEmpty
                                    ? 'Please enter branch name'
                                    : null;
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

    Map<String, dynamic> body = {
      "ac_name": accountBloc.accountNameController.text.trim(), // ✅ Matches Django model: name
      "ac_type": selectedType, // ✅ Matches Django model: ac_type
      "balance": accountBloc.accountOpeningBalanceController.text.trim(), // ✅ Matches Django model
      "opening_balance": accountBloc.accountOpeningBalanceController.text.trim(), // ✅ Matches Django model
    };

    // Add account number for non-cash and non-other accounts
    if (selectedType != "Cash" && selectedType != "Other") {
      body["ac_number"] = accountBloc.accountNumberController.text.trim(); // ✅ Matches Django model: number
    }

    // Add bank details for bank accounts
    if (selectedType == "Bank") {
      body["bank_name"] = accountBloc.bankNameController.text.trim(); // ✅ Matches Django model: bank_name
      body["branch"] = accountBloc.branchNameController.text.trim(); // ✅ Matches Django model: branch
    }

    // Balance will be auto-set by Django model to opening_balance
    // No need to send balance separately

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