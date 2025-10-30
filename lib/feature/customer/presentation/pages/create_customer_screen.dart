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
import '../widget/widget.dart';

class CreateCustomerScreen extends StatefulWidget {
  CreateCustomerScreen({super.key, this.submitText = '', this.id = ''});
  final String id;
  final String submitText;

  @override
  State<CreateCustomerScreen> createState() => _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends State<CreateCustomerScreen> {
  @override
  Widget build(BuildContext context) {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,

        borderRadius: BorderRadius.circular(AppSizes.bodyPadding),

      ),
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
                      // Customer Name
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
                          controller: context.read<CustomerBloc>().customerNameController,
                          hintText: 'Customer Name',
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            return value!.isEmpty
                                ? 'Please enter Customer Name'
                                : null;
                          },
                          onChanged: (value) {
                            return null;
                          },
                        ),
                      ),

                      // Phone Number
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
                          controller: context.read<CustomerBloc>().customerNumberController,
                          hintText: 'Phone Number',
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            return value!.trim().isEmpty
                                ? 'Please enter Phone number'
                                : AppConstants.phoneValidation.hasMatch(value.trim())
                                ? null
                                : 'Invalid phone number';
                          },
                          onChanged: (value) {
                            return null;
                          },
                        ),
                      ),

                      // Email
                      ResponsiveCol(
                        xs: 12,
                        sm: 6,
                        md: 4,
                        lg: 4,
                        xl: 4,
                        child: CustomInputField(
                          isRequiredLable: false,
                          isRequired: false,
                          textInputAction: TextInputAction.next,
                          controller: context.read<CustomerBloc>().customerEmailController,
                          hintText: 'Email (Optional)',
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
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
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSizes.height(context) * 0.02),

                  // Address Field
                  ResponsiveRow(
                    spacing: 20,
                    runSpacing: 10,
                    children: [
                      ResponsiveCol(
                        xs: 12,
                        sm: 12,
                        md: 12,
                        lg: 12,
                        xl: 12,
                        child: CustomInputField(
                          isRequiredLable: false,
                          isRequired: false,
                          textInputAction: TextInputAction.done,
                          controller: context.read<CustomerBloc>().addressController,
                          hintText: 'Address (Optional)',
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          keyboardType: TextInputType.multiline,
                          validator: (value) {
                            return null; // Address is optional
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
      ),
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

    print("Sending customer payload: $body"); // For debugging

    if (widget.id.isEmpty) {
      // Create new customer
      customerBloc.add(AddCustomer(body: body));
    } else {
      // Update existing customer
      // Add any additional fields needed for update
      customerBloc.add(UpdateCustomer(body: body, id: widget.id));
    }

    // Show success message
    _showSuccessMessage();
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.id.isEmpty
            ? 'Customer created successfully!'
            : 'Customer updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}