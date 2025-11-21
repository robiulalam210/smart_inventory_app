import 'package:meherin_mart/feature/products/unit/presentation/bloc/unit/unti_bloc.dart';
import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';

class UnitCreate extends StatefulWidget {
  final String? id;

  const UnitCreate({super.key, this.id,});

  @override
  State<UnitCreate> createState() => _UnitCreateState();
}

class _UnitCreateState extends State<UnitCreate> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();




  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: Text(
            widget.id == null
                ? 'Are you sure you want to create this unit?'
                : 'Are you sure you want to update this unit?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitForm();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      final Map<String, dynamic> body = {
        "name":     context.read<UnitBloc>().nameController.text.trim(),
        "code":     context.read<UnitBloc>().shortNameController.text.trim(),
      };
      if (widget.id != null &&
          context.read<UnitBloc>().selectedState.trim().isNotEmpty) {
        body["is_active"] =
        context.read<UnitBloc>().selectedState == "Active"
            ? true
            : false;
      }
      if (widget.id == null) {
        // Create new unit
        context.read<UnitBloc>().add(AddUnit(body: body));
      } else {
        // Update existing unit
        context.read<UnitBloc>().add(
          UpdateUnit(body: body, id: widget.id!),
        );
      }
    }
  }

  void _clearForm() {
    context.read<UnitBloc>(). nameController.clear();
    formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UnitBloc, UnitState>(
      listener: (context, state) {
        if (state is UnitAddSuccess) {
          showCustomToast(
            context: context,
            title: 'Success!',
            description: widget.id == null
                ? 'Unit created successfully!'
                : 'Unit updated successfully!',
            type: ToastificationType.success,
            icon: Icons.check_circle,
            primaryColor: Colors.green,
          );

          // Clear form and close on success
          if (widget.id == null) {
            _clearForm();
          }
          // Navigator.pop(context, true); // Return success result

        } else if (state is UnitAddFailed) {
          showCustomToast(
            context: context,
            title: state.title,
            description: state.content,
            type: ToastificationType.error,
            icon: Icons.error,
            primaryColor: Colors.redAccent,
          );
        }
      },
      child:_buildDialogContent() ,
    );
  }

  Widget _buildDialogContent() {
    return Container(
      width: AppSizes.width(context) * 0.40,
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button and title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.id == null ? 'Create Unit' : 'Update Unit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Name Input Field
            // Name Input Field
            CustomInputField(
              isRequiredLable: true,
              isRequired: true,
              controller:context.read<UnitBloc>().  nameController,
              hintText: 'Enter unit name (e.g., Kilogram)',
              labelText: 'Unit Name',
              fillColor: Colors.grey[50],
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter unit name';
                }
                if (value.length < 2) {
                  return 'Unit name must be at least 2 characters long';
                }
                if (value.length > 50) {
                  return 'Unit name must be less than 50 characters';
                }
                return null;
              },
            ),

            SizedBox(height: 16),

            // Short Name/Code Input Field
            CustomInputField(
              isRequiredLable: true,
              isRequired: true,
              controller: context.read<UnitBloc>(). shortNameController,
              hintText: 'Enter unit code (e.g., kg)',
              labelText: 'Unit Code',
              fillColor: Colors.grey[50],
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter unit code';
                }
                if (value.isEmpty) {
                  return 'Unit code must be at least 1 character long';
                }
                if (value.length > 10) {
                  return 'Unit code must be less than 10 characters';
                }
                // Optional: Add regex validation for codes
                if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                  return 'Unit code can only contain letters and numbers';
                }
                return null;
              },
            ),


            SizedBox(height: 10),
            if (widget.id !=null)  ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 600;

                  return SizedBox(
                    width: isSmallScreen
                        ? double.infinity
                        : constraints.maxWidth * 0.5,
                    child: AppDropdown(
                      label: "Status",
                      context: context,
                      hint: context.read<UnitBloc>().selectedState.isEmpty
                          ? "Select Status"
                          : context.read<UnitBloc>().selectedState,
                      isLabel: false,
                      value:
                      context.read<UnitBloc>().selectedState.isEmpty
                          ? null
                          : context.read<UnitBloc>().selectedState,
                      itemList: ["Active", "Inactive"],
                      onChanged: (newVal) {
                        setState(() {
                          context.read<UnitBloc>().selectedState = newVal
                              .toString();
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
              ),
              SizedBox(height: AppSizes.height(context) * 0.01),
            ],

            // Buttons Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppColors.primaryColor),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: BlocBuilder<UnitBloc, UnitState>(
                    builder: (context, state) {
                      return AppButton(
                        name: widget.id == null ? 'Create' : 'Update',
                        onPressed: (state is UnitAddLoading)
                            ? null
                            : _showConfirmationDialog,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}