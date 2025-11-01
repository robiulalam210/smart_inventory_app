import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../bloc/categories/categories_bloc.dart';

class CategoriesCreate extends StatefulWidget {
  final String? id;

  const CategoriesCreate({super.key, this.id, });

  @override
  State<CategoriesCreate> createState() => _CategoriesCreateState();
}

class _CategoriesCreateState extends State<CategoriesCreate> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: Text(
            widget.id == null
                ? 'Are you sure you want to create this category?'
                : 'Are you sure you want to update this category?',
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
      final Map<String, String> body = {
        "name":  context.read<CategoriesBloc>().nameController.text.trim(),
      };

      if (widget.id == null) {
        // Create new category
        context.read<CategoriesBloc>().add(AddCategories(body: body));
      } else {
        // Update existing category
        context.read<CategoriesBloc>().add(
          UpdateCategories(body: body, id: widget.id!),
        );
      }
    }
  }

  void _clearForm() {
    context.read<CategoriesBloc>().  nameController.clear();
    formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoriesBloc, CategoriesState>(
      listener: (context, state) {
        if (state is CategoriesAddSuccess) {
          showCustomToast(
            context: context,
            title: 'Success!',
            description: widget.id == null
                ? 'Category created successfully!'
                : 'Category updated successfully!',
            type: ToastificationType.success,
            icon: Icons.check_circle,
            primaryColor: Colors.green,
          );

          // Clear form and close on success
          if (widget.id == null) {
            _clearForm();
          }
          Navigator.pop(context, true); // Return success result

        } else if (state is CategoriesAddFailed) {
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
      child: _buildDialogContent()

    );
  }

  Widget _buildDialogContent() {
    return Container(
      width: AppSizes.width(context)*0.40,
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important for dialog
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button and title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.id == null ? 'Create Category' : 'Update Category',
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
            CustomInputField(
              isRequiredLable: true,
              isRequired: true,
              controller:  context.read<CategoriesBloc>().nameController,
              hintText: 'Enter category name',
              labelText: 'Category Name',
              fillColor: Colors.grey[50],
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter category name';
                }
                if (value.length < 2) {
                  return 'Category name must be at least 2 characters long';
                }
                if (value.length > 100) {
                  return 'Category name must be less than 100 characters';
                }
                return null;
              },
            ),

            SizedBox(height: 20),

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
                  child: BlocBuilder<CategoriesBloc, CategoriesState>(
                    builder: (context, state) {
                      return AppButton(
                        name: widget.id == null ? 'Create' : 'Update',
                        onPressed: (state is CategoriesAddLoading)
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