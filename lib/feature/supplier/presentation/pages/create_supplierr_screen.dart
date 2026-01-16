import '/core/core.dart';

import '../bloc/supplier/supplier_list_bloc.dart';

class CreateSupplierScreen extends StatefulWidget {
  const CreateSupplierScreen({super.key, this.submitText = '', this.id = ''});
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
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),

        borderRadius: BorderRadius.circular(AppSizes.bodyPadding),

      ),
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
          color: AppColors.bottomNavBg(context),
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusSize),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Container(           padding: AppTextStyle.getResponsivePaddingBody(context),

            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Header with Cancel/Up Button
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
                          "Supplier ",
                          style: AppTextStyle.headerTitle(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSizes.height(context) * 0.01),


                  // Supplier Name
                  AppTextField(

                    isRequired: true,
                    textInputAction: TextInputAction.next,
                    controller: context.read<SupplierListBloc>().customerNameController,
                    hintText: 'Supplier Name',

                    keyboardType: TextInputType.text,
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please enter Supplier Name'
                          : null;
                    },
                    onChanged: (value) {
                      return;
                    },
                  ),

                  SizedBox(height: AppSizes.height(context) * 0.01),

                  // Phone Number
                  AppTextField(

                    isRequired: true,
                    textInputAction: TextInputAction.next,
                    controller: context.read<SupplierListBloc>().customerNumberController,
                    hintText: 'Phone Number',
                    labelText: "Phone Number",
                    // maxLength: 11,

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

                  SizedBox(height: AppSizes.height(context) * 0.01),

                  // Address
                  AppTextField(

                    isRequired: true,
                    textInputAction: TextInputAction.done,
                    controller: context.read<SupplierListBloc>().addressController,
                    hintText: 'Address',

                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      return value!.isEmpty ? 'Please enter address' : null;
                    },
                    onChanged: (value) {
                      return;
                    },
                  ),

                  widget.id.toString() == ""
                      ? Container()
                      : AppDropdown(
                    label: "Status",
                    hint:
                    context.read<SupplierListBloc>().selectedState.isEmpty
                        ? "Select Status"
                        : context.read<SupplierListBloc>().selectedState,
                    isLabel: false,
                    value:
                    context.read<SupplierListBloc>().selectedState.isEmpty
                        ? null
                        : context.read<SupplierListBloc>().selectedState,
                    itemList: context.read<SupplierListBloc>().statesList,
                    onChanged: (newVal) {
                      context.read<SupplierListBloc>().selectedState =
                          newVal.toString();
                    },

                  ),
                  SizedBox(height: AppSizes.height(context) * 0.02),

                  // Submit Button

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppButton(
                        size: 120,
                        name:  "Cancel",
                        isOutlined: true,
                        textColor: AppColors.errorColor(context),
                        borderColor: AppColors.primaryColor(context),
                        onPressed: (){
                          AppRoutes.pop(context);
                        },
                      ),
                      SizedBox(width: 10,),
                      AppButton(

                        size: 130,
                        name: widget.submitText.isEmpty ? "Create Supplier" : widget.submitText,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            _createOrUpdateSupplier();
                          }
                        },
                      ),

                    ],
                  ),

                  SizedBox(height: AppSizes.height(context) * 0.02),
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

    debugPrint("Sending supplier payload: $body");

    if (widget.id.isEmpty) {
      // Create new supplier
      supplierBloc.add(AddSupplierList(body: body));
    } else {
      if (supplierBloc.selectedState.trim().isNotEmpty) {
        body["is_active"] = supplierBloc.selectedState=="Active"?true:false;
      }
      // Update existing supplier
      supplierBloc.add(UpdateSupplierList(body: body, branchId: widget.id));
    }

  }



  @override
  void dispose() {
    super.dispose();
  }
}