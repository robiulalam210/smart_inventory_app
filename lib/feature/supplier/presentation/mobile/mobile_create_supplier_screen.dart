import '/core/core.dart';
import '../bloc/supplier/supplier_list_bloc.dart';

class MobileCreateSupplierScreen extends StatefulWidget {
  const MobileCreateSupplierScreen({super.key, this.submitText = '', this.id = ''});

  final String id;
  final String submitText;

  @override
  State<MobileCreateSupplierScreen> createState() => _CreateSupplierScreenState();
}

class _CreateSupplierScreenState extends State<MobileCreateSupplierScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Add controllers for new fields

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing values if editing
    if (widget.id.isNotEmpty) {
      context.read<SupplierListBloc>();
      // Note: You might need to pass the supplier data differently
      // For now, we'll set the controllers in the build method
    }
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(AppSizes.bodyPadding),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
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
                        widget.id.isEmpty ? "Create Supplier" : "Update Supplier",
                        style: AppTextStyle.headerTitle(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Supplier Name
                AppTextField(
                  isRequired: true,
                  controller: context.read<SupplierListBloc>().customerNameController,
                  hintText: 'Supplier Name',
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    return value!.trim().isEmpty ? 'Please enter Supplier Name' : null;
                  },
                ),

                const SizedBox(height: 8),

                // Phone Number
                AppTextField(
                  isRequired: true,
                  controller: context.read<SupplierListBloc>().customerNumberController,
                  hintText: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    return value!.trim().isEmpty
                        ? 'Please enter Phone number'
                        : AppConstants.phoneValidation.hasMatch(value.trim())
                        ? null
                        : 'Invalid phone number';
                  },
                ),

                const SizedBox(height: 8),

                // Address
                AppTextField(
                  isRequired: true,
                  controller: context.read<SupplierListBloc>().addressController,
                  hintText: 'Address',
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    return value!.trim().isEmpty ? 'Please enter address' : null;
                  },
                ),

                const SizedBox(height: 8),

                // Shop/Business Name (NEW FIELD)
                AppTextField(
                  controller: context.read<SupplierListBloc>().shopName,
                  hintText: 'Shop/Business Name (Optional)',
                  keyboardType: TextInputType.text,
                ),

                const SizedBox(height: 8),

                // Products/Services (NEW FIELD)
                AppTextField(
                  controller: context.read<SupplierListBloc>().productName,
                  hintText: 'Products/Services (Optional)',
                  keyboardType: TextInputType.multiline,
                ),



                const SizedBox(height: 8),

                // Email (Optional)
                AppTextField(
                  controller: context.read<SupplierListBloc>().customerEmailController,
                  hintText: 'Email (Optional)',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      // if (!AppConstants.emailValidation.hasMatch(value.trim())) {
                      //   return 'Invalid email format';
                      // }
                    }
                    return null;
                  },
                ),


                const SizedBox(height: 8),

                // Status Dropdown (only in edit mode)
                if (widget.id.isNotEmpty) ...[
                  _buildStatusDropdown(),
                  const SizedBox(height: 8),
                ],

                const SizedBox(height: 16),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppButton(
                      size: 120,
                      name: "Cancel",
                      isOutlined: true,
                      textColor: AppColors.errorColor(context),
                      borderColor: AppColors.primaryColor(context),
                      onPressed: () {
                        AppRoutes.pop(context);
                      },
                    ),
                    const SizedBox(width: 10),
                    AppButton(
                      size: 120,
                      name: widget.submitText.isEmpty ? "Submit" : widget.submitText,
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          _createOrUpdateSupplier();
                        }
                      },
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

  Widget _buildStatusDropdown() {
    return AppDropdown(
      label: "Status",
      hint: context.read<SupplierListBloc>().selectedState.isEmpty
          ? "Select Status"
          : context.read<SupplierListBloc>().selectedState,
      isLabel: false,
      value: context.read<SupplierListBloc>().selectedState.isEmpty
          ? null
          : context.read<SupplierListBloc>().selectedState,
      itemList: context.read<SupplierListBloc>().statesList,
      onChanged: (newVal) {
        setState(() {
          context.read<SupplierListBloc>().selectedState = newVal.toString();
        });
      },
    );
  }

  void _createOrUpdateSupplier() {
    final supplierBloc = context.read<SupplierListBloc>();

    Map<String, dynamic> body = {
      "name": supplierBloc.customerNameController.text.trim(),
      "phone": supplierBloc.customerNumberController.text.trim(),
      "address": supplierBloc.addressController.text.trim(),
    };

    // Add email if provided
    final email = supplierBloc.customerEmailController.text.trim();
    if (email.isNotEmpty) {
      body["email"] = email;
    }

    // Add new fields if provided
    final shopName = supplierBloc.shopName.text.trim();
    if (shopName.isNotEmpty) {
      body["shop_name"] = shopName;
    }

    final productName = supplierBloc.productName.text.trim();
    if (productName.isNotEmpty) {
      body["product_name"] = productName;
    }

    // Add status for edit mode
    if (widget.id.isNotEmpty && supplierBloc.selectedState.isNotEmpty) {
      body["is_active"] = supplierBloc.selectedState == "Active";
    }

    debugPrint("Sending supplier payload: $body");

    if (widget.id.isEmpty) {
      supplierBloc.add(AddSupplierList(body: body));
    } else {
      supplierBloc.add(UpdateSupplierList(body: body, branchId: widget.id));
    }
  }
}