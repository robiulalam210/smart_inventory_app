import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/input_field.dart';
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
        color: AppColors.bg,

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
                    labelText: "Phone Number",
                    // maxLength: 11,
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

                  widget.id.toString() == ""
                      ? Container()
                      : AppDropdown(
                    label: "Status",context: context,
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