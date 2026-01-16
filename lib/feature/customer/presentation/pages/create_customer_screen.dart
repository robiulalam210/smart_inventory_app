import '/core/core.dart';

import '../../../customer/presentation/bloc/customer/customer_bloc.dart';

class CreateCustomerScreen extends StatefulWidget {
  const CreateCustomerScreen({super.key, this.submitText = '', this.id = ''});
  final String id;
  final String submitText;

  @override
  State<CreateCustomerScreen> createState() => _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends State<CreateCustomerScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(AppSizes.bodyPadding),
      ),
      child: SafeArea(
        child: _buildContentArea(isBigScreen),
      ),
    );
  }

  Widget _buildContentArea(bool isBigScreen) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSize),
      ),
      child: Padding(
        padding: AppTextStyle.getResponsivePaddingBody(context),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.bottomNavBg(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Customer ",
                        style: AppTextStyle.headerTitle(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Row 1: Customer Name and Phone Number
                _buildTwoColumnRow(
                  firstChild: AppTextField(
                    isRequired: true,
                    textInputAction: TextInputAction.next,
                    controller: context.read<CustomerBloc>().customerNameController,
                    hintText: 'Customer Name',

                    keyboardType: TextInputType.text,
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please enter Customer Name'
                          : null;
                    },

                  ),
                  secondChild: AppTextField(

                    isRequired: true,
                    textInputAction: TextInputAction.next,
                    controller: context.read<CustomerBloc>().customerNumberController,
                    hintText: 'Phone Number',

                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      return value!.trim().isEmpty
                          ? 'Please enter Phone number'
                          : AppConstants.phoneValidation.hasMatch(value.trim())
                          ? null
                          : 'Invalid phone number';
                    },
                    onChanged: (value) {
                      return;
                    },
                  ),
                ),

                // const SizedBox(height: 16),

                // Row 2: Email and Address
                _buildTwoColumnRow(
                  firstChild: AppTextField(

                    isRequired: false,
                    textInputAction: TextInputAction.next,
                    controller: context.read<CustomerBloc>().customerEmailController,
                    hintText: 'Email (Optional)',

                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        return AppConstants.emailRegex.hasMatch(value.trim())
                            ? null
                            : 'Invalid Email';
                      }
                      return null; // Email is optional
                    },
                    onChanged: (value) {
                      return;
                    },
                  ),
                  secondChild: AppTextField(

                    isRequired: false,
                    textInputAction: TextInputAction.done,
                    controller: context.read<CustomerBloc>().addressController,
                    hintText: 'Address (Optional)',

                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      return null; // Address is optional
                    },
                    onChanged: (value) {
                      return;
                    },
                  ),
                ),

                SizedBox(height: AppSizes.height(context) * 0.01),

                // Status Dropdown (only for edit mode)
                if (widget.id.toString().isNotEmpty) ...[
                  _buildStatusDropdown(),
                  SizedBox(height: AppSizes.height(context) * 0.01),
                ],

                SizedBox(height: AppSizes.height(context) * 0.01),

                // Submit Button
                AppButton(
                  name: widget.submitText.isEmpty ? "Create Customer" : widget.submitText,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      _createOrUpdateCustomer();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTwoColumnRow({required Widget firstChild, required Widget secondChild}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        if (isSmallScreen) {
          // Stack vertically on small screens
          return Column(  crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              firstChild,
              const SizedBox(height: 4),
              secondChild,
            ],
          );
        } else {
          // Place side by side on larger screens
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: firstChild,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: secondChild,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatusDropdown() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return SizedBox(
          width: isSmallScreen ? double.infinity : constraints.maxWidth * 0.5,
          child: AppDropdown(
            label: "Status",
            hint:  "Select Status"
              ,
            isLabel: false,
            value: context.read<CustomerBloc>().selectedState.isEmpty
                ? null
                : context.read<CustomerBloc>().selectedState,
            itemList: context.read<CustomerBloc>().status,
            onChanged: (newVal) {
              setState(() {
                context.read<CustomerBloc>().selectedState = newVal.toString();
              });
            },

          ),
        );
      },
    );
  }

  void _createOrUpdateCustomer() {
    final customerBloc = context.read<CustomerBloc>();

    Map<String, dynamic> body = {
      "name": customerBloc.customerNameController.text.trim(),
      "phone": customerBloc.customerNumberController.text.trim(),
    };

    // Add optional fields if they have values
    if (customerBloc.customerEmailController.text.trim().isNotEmpty) {
      body["email"] = customerBloc.customerEmailController.text.trim();
    }

    if (customerBloc.addressController.text.trim().isNotEmpty) {
      body["address"] = customerBloc.addressController.text.trim();
    }

    if (widget.id.isNotEmpty && customerBloc.selectedState.trim().isNotEmpty) {
      body["is_active"] = customerBloc.selectedState == "Active" ? true : false;
    }

    // For debugging

    if (widget.id.isEmpty) {
      // Create new customer
      customerBloc.add(AddCustomer(body: body));
    } else {
      // Update existing customer
      customerBloc.add(UpdateCustomer(body: body, id: widget.id));
    }

    // Show success message or handle navigation
    Navigator.of(context).pop(); // Close the screen after submission
  }

  @override
  void dispose() {
    super.dispose();
  }
}