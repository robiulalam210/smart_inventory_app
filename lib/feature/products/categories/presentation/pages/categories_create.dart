import '/core/core.dart';
import '../bloc/categories/categories_bloc.dart';

class CategoriesCreate extends StatefulWidget {
  final String? id;

  const CategoriesCreate({super.key, this.id});

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
            style: AppTextStyle.body(context),
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
        "name": context.read<CategoriesBloc>().nameController.text.trim(),
      };
      if (widget.id != null &&
          context.read<CategoriesBloc>().selectedState.trim().isNotEmpty) {
        body["is_active"] =
        context.read<CategoriesBloc>().selectedState == "Active"
            ? true
            : false;
      }

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
    context.read<CategoriesBloc>().nameController.clear();
    formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoriesBloc, CategoriesState>(
      listener: (context, state) {
        // Always guard against using a deactivated context
        if (!mounted) return;

        if (state is CategoriesAddSuccess) {
          // show toast while dialog is still mounted
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

          // clear controller
          context.read<CategoriesBloc>().nameController.clear();

          // Clear form if creating new
          if (widget.id == null) {
            _clearForm();
          }

          // Defer popping the dialog to the next frame so any in-flight
          // builders/overlays (e.g. dropdown overlays) can finish using this context.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pop(true); // Return success result
          });
        } else if (state is CategoriesAddFailed) {
          if (!mounted) return;
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
      child: _buildDialogContent(),
    );
  }

  Widget _buildDialogContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.bottomNavBg(context),
      ),
      width: AppSizes.width(context) * 0.40,
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
                    color: AppColors.primaryColor(context),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.red, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Name Input Field
            CustomInputField(
              isRequired: true,
              controller: context.read<CategoriesBloc>().nameController,
              hintText: 'Enter category name',
              labelText: 'Category Name',
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

            const SizedBox(height: 10),
            if (widget.id != null) ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 600;

                  return SizedBox(
                    width: isSmallScreen
                        ? double.infinity
                        : constraints.maxWidth * 0.5,
                    child: AppDropdown(
                      label: "Status",
                      hint: "Select Status",
                      isLabel: false,
                      value: context.read<CategoriesBloc>().selectedState.isEmpty
                          ? null
                          : context.read<CategoriesBloc>().selectedState,
                      itemList: const ["Active", "Inactive"],
                      onChanged: (newVal) {
                        // only mutate bloc-backed state (no need to call setState for the dialog)
                        context.read<CategoriesBloc>().selectedState =
                            newVal.toString();
                        // If you need UI changes inside this dialog that depend on
                        // selectedState, call setState here. Otherwise it's not necessary.
                        setState(() {});
                      },
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
                  child: AppButton(
                    isOutlined: true,
                    color: AppColors.primaryColor(context),
                    borderColor: AppColors.primaryColor(context),
                    textColor: AppColors.errorColor(context),
                    name: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BlocBuilder<CategoriesBloc, CategoriesState>(
                    builder: (context, state) {
                      return AppButton(
                        name: widget.id == null ? 'Create' : 'Update',
                        onPressed:
                        (state is CategoriesAddLoading) ? null : _showConfirmationDialog,
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