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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
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
                    color: AppColors.whiteColor,
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

                // Status Dropdown (only in edit mode)
                if (widget.id.isNotEmpty) ...[
                  _buildStatusDropdown(),
                  const SizedBox(height: 8),
                ],

                const SizedBox(height: 16),

                // Submit Button
                AppButton(
                  name: widget.submitText.isEmpty ? "Submit" : widget.submitText,
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
    );
  }

  Widget _buildStatusDropdown() {
    return AppDropdown(
      label: "Status",
      context: context,
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
  }

  void _createOrUpdateSupplier() {
    final supplierBloc = context.read<SupplierListBloc>();

    Map<String, dynamic> body = {
      "name": supplierBloc.customerNameController.text.trim(),
      "phone": supplierBloc.customerNumberController.text.trim(),
      "address": supplierBloc.addressController.text.trim(),
    };

    if (widget.id.isNotEmpty && supplierBloc.selectedState.isNotEmpty) {
      body["is_active"] = supplierBloc.selectedState == "Active";
    }

    debugPrint("Sending supplier payload: $body");

    if (widget.id.isEmpty) {
      supplierBloc.add(AddSupplierList(body: body));
    } else {
      supplierBloc.add(UpdateSupplierList(body: body, branchId: widget.id));
    }

    // Navigator.of(context).pop(); // Close dialog after submission
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Function to show as Dialog
