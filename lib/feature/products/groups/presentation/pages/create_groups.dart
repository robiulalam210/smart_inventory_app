import '../../../../../core/widgets/input_field.dart';
import '/feature/products/groups/presentation/bloc/groups/groups_bloc.dart';
import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/show_custom_toast.dart';

class GroupsCreate extends StatefulWidget {
  final String? id;
  final bool isDialog;

  const GroupsCreate({super.key, this.id, this.isDialog = true});

  @override
  State<GroupsCreate> createState() => _GroupsCreateState();
}

class _GroupsCreateState extends State<GroupsCreate> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();

    // If updating, load existing data
    if (widget.id != null) {
      final bloc = context.read<GroupsBloc>();
      if (bloc.nameController.text.isNotEmpty) {
        nameController.text = bloc.nameController.text;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: Text(
            widget.id == null
                ? 'Are you sure you want to create this group?'
                : 'Are you sure you want to update this group?',
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
        "name": nameController.text.trim(),
      };
      if (widget.id != null &&
          context.read<GroupsBloc>().selectedState.trim().isNotEmpty) {
        body["is_active"] =
        context.read<GroupsBloc>().selectedState == "Active"
            ? true
            : false;
      }
      if (widget.id == null) {
        // Create new group
        context.read<GroupsBloc>().add(AddGroups(body: body));
      } else {
        // Update existing group
        context.read<GroupsBloc>().add(
          UpdateGroups(body: body, id: widget.id!),
        );
      }
    }
  }

  void _clearForm() {
    nameController.clear();
    formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupsBloc, GroupsState>(
      listener: (context, state) {
        if (!mounted) return;

        if (state is GroupsAddSuccess) {
          showCustomToast(
            context: context,
            title: 'Success!',
            description: widget.id == null
                ? 'Group created successfully!'
                : 'Group updated successfully!',
            type: ToastificationType.success,
            icon: Icons.check_circle,
            primaryColor: Colors.green,
          );

          if (widget.id == null) {
            _clearForm();
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pop(true); // Return success result
          });
        } else if (state is GroupsAddFailed) {
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
      child: _buildDialogContent() ,
    );
  }

  Widget _buildDialogContent() {
    return Container(
      color: AppColors.bottomNavBg(context),
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
                  widget.id == null ? 'Create Group' : 'Update Group',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor(context),
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

            SizedBox(height: 10),

            // Name Input Field
            CustomInputField(

              isRequired: true,
              controller: nameController,
              hintText: 'Enter group name',
              labelText: 'Group Name',

              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter group name';
                }
                if (value.length < 2) {
                  return 'Group name must be at least 2 characters long';
                }
                if (value.length > 50) {
                  return 'Group name must be less than 50 characters';
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
                      hint:  "Select Status"
                          ,
                      isLabel: false,
                      value:
                      context.read<GroupsBloc>().selectedState.isEmpty
                          ? null
                          : context.read<GroupsBloc>().selectedState,
                      itemList: ["Active", "Inactive"],
                      onChanged: (newVal) {
                        setState(() {
                          context.read<GroupsBloc>().selectedState = newVal
                              .toString();
                        });
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
                    name: 'Cancel',
                    isOutlined: true,
                    color: AppColors.primaryColor(context),
                    borderColor: AppColors.primaryColor(context),
                    textColor: AppColors.errorColor(context),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                SizedBox(width: 10),
                Expanded(
                  child: BlocBuilder<GroupsBloc, GroupsState>(
                    builder: (context, state) {
                      return AppButton(
                        name: widget.id == null ? 'Create' : 'Update',
                        onPressed: (state is GroupsAddLoading)
                            ? null
                            : _showConfirmationDialog,
                        isLoading: state is GroupsAddLoading,
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