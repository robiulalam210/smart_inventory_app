import '/core/core.dart';
import '../../../customer/presentation/bloc/customer/customer_bloc.dart';

class MobileCreateCustomerScreen extends StatefulWidget {
  const MobileCreateCustomerScreen({super.key, this.submitText = '', this.id = ''});

  final String id;
  final String submitText;

  @override
  State<MobileCreateCustomerScreen> createState() => _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends State<MobileCreateCustomerScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(AppSizes.bodyPadding),
      ),
      child: SafeArea(
        child: _buildContentArea(),
      ),
    );
  }

  Widget _buildContentArea() {
    return Padding(
      padding: AppTextStyle.getResponsivePaddingBody(context),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
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
                      widget.id.isEmpty ? "Create Customer" : "Update Customer",
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

              // Row 1: Customer Name & Phone
              _buildTwoColumnRow(
                firstChild: AppTextField(
                  isRequired: true,
                  controller: context.read<CustomerBloc>().customerNameController,
                  hintText: 'Customer Name',
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    return value!.trim().isEmpty ? 'Please enter Customer Name' : null;
                  },
                ),
                secondChild: AppTextField(
                  isRequired: true,
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
                ),
              ),

              const SizedBox(height: 8),

              // Row 2: Email & Address
              _buildTwoColumnRow(
                firstChild: AppTextField(
                  controller: context.read<CustomerBloc>().customerEmailController,
                  hintText: 'Email (Optional)',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      return AppConstants.emailRegex.hasMatch(value.trim()) ? null : 'Invalid Email';
                    }
                    return null;
                  },
                ),
                secondChild: AppTextField(
                  controller: context.read<CustomerBloc>().addressController,
                  hintText: 'Address (Optional)',
                  keyboardType: TextInputType.multiline,
                ),
              ),

              const SizedBox(height: 8),

              // Status dropdown (only in edit mode)
              if (widget.id.isNotEmpty) ...[
                _buildStatusDropdown(),
                const SizedBox(height: 8),
              ],

              // Submit button
              AppButton(
                name: widget.submitText.isEmpty ? "Submit" : widget.submitText,
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
    );
  }

  Widget _buildTwoColumnRow({required Widget firstChild, required Widget secondChild}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        if (isSmallScreen) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              firstChild,
              const SizedBox(height: 4),
              secondChild,
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(child: firstChild),
              const SizedBox(width: 8),
              Expanded(child: secondChild),
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
            context: context,
            hint: context.read<CustomerBloc>().selectedState.isEmpty
                ? "Select Status"
                : context.read<CustomerBloc>().selectedState,
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

    if (customerBloc.customerEmailController.text.trim().isNotEmpty) {
      body["email"] = customerBloc.customerEmailController.text.trim();
    }

    if (customerBloc.addressController.text.trim().isNotEmpty) {
      body["address"] = customerBloc.addressController.text.trim();
    }

    if (widget.id.isNotEmpty && customerBloc.selectedState.isNotEmpty) {
      body["is_active"] = customerBloc.selectedState == "Active";
    }

    if (widget.id.isEmpty) {
      customerBloc.add(AddCustomer(body: body));
    } else {
      customerBloc.add(UpdateCustomer(body: body, id: widget.id));
    }

    Navigator.of(context).pop(); // Close dialog after submission
  }
}


