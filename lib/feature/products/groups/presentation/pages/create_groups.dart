import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_inventory/feature/products/groups/presentation/bloc/groups/groups_bloc.dart';
import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/input_field.dart';
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
        "name": nameController.text.trim(),
      };

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
          Navigator.pop(context, true);

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
      child: widget.isDialog ? _buildDialogContent() : _buildFullScreenContent(),
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
                  widget.id == null ? 'Create Group' : 'Update Group',
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
              controller: nameController,
              hintText: 'Enter group name',
              labelText: 'Group Name',
              fillColor: Colors.grey[50],
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

  Widget _buildFullScreenContent() {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: Text(widget.id == null ? 'Create Group' : 'Update Group'),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            margin: EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusSize),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Name Input Field
                      CustomInputField(
                        isRequiredLable: true,
                        isRequired: true,
                        controller: nameController,
                        hintText: 'Enter group name',
                        labelText: 'Group Name',
                        fillColor: Colors.grey[50],
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

                      SizedBox(height: 30),

                      // Buttons Row
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15),
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
                            child: BlocBuilder<GroupsBloc, GroupsState>(
                              builder: (context, state) {
                                return AppButton(
                                  name: widget.id == null ? 'Create Group' : 'Update Group',
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}