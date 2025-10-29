import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/input_field.dart';
import '../bloc/supplier/supplier_list_bloc.dart';

class CreateSupplierScreen extends StatefulWidget {
  CreateSupplierScreen({super.key, this.submitText = '', this.id = ''});
  final String id;
  final String submitText;

  @override
  State<CreateSupplierScreen> createState() => _CreateSupplierScreenState();
}

class _CreateSupplierScreenState extends State<CreateSupplierScreen> {
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
            // if (isBigScreen) _buildSidebar(),
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

                  // Supplier Name
                  CustomInputField(
                    isRequiredLable: true,
                    isRequired: true,
                    textInputAction: TextInputAction.next,
                    controller: context.read<SupplierListBloc>().customerNameController,
                    hintText: 'Supplier Name',
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please enter Supplier Name'
                          : null;
                    },
                    onChanged: (value) {
                      return null;
                    },
                  ),

                  SizedBox(height: AppSizes.height(context) * 0.02),

                  // Phone Number
                  CustomInputField(
                    isRequiredLable: true,
                    isRequired: true,
                    textInputAction: TextInputAction.next,
                    controller: context.read<SupplierListBloc>().customerNumberController,
                    hintText: 'Phone Number',
                    maxLength: 11,
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

                  SizedBox(height: AppSizes.height(context) * 0.02),

                  // Address
                  CustomInputField(
                    isRequiredLable: true,
                    isRequired: true,
                    textInputAction: TextInputAction.done,
                    controller: context.read<SupplierListBloc>().addressController,
                    hintText: 'Address',
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      return value!.isEmpty ? 'Please enter address' : null;
                    },
                    onChanged: (value) {
                      return null;
                    },
                  ),

                  SizedBox(height: AppSizes.height(context) * 0.04),

                  // Submit Button
                  AppButton(
                    name: widget.submitText.isEmpty ? "Create Supplier" : widget.submitText,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        _createOrUpdateSupplier();
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

  void _createOrUpdateSupplier() {
    final supplierBloc = context.read<SupplierListBloc>();

    Map<String, dynamic> body = {
      "name": supplierBloc.customerNameController.text.trim(),
      "phone": supplierBloc.customerNumberController.text.trim(),
      "address": supplierBloc.addressController.text.trim(),
    };

    print("Sending supplier payload: $body");

    if (widget.id.isEmpty) {
      // Create new supplier
      supplierBloc.add(AddSupplierList(body: body));
    } else {
      // Update existing supplier
      supplierBloc.add(UpdateSupplierList(body: body, branchId: widget.id));
    }

    _showSuccessMessage();
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.id.isEmpty
            ? 'Supplier created successfully!'
            : 'Supplier updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}