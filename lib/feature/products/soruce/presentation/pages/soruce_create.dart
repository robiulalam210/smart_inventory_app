import 'package:meherin_mart/core/core.dart';
import '../bloc/source/source_bloc.dart';

class SourceCreate extends StatefulWidget {
  final String? id;

  const SourceCreate({super.key, this.id});

  @override
  State<SourceCreate> createState() => _SourceCreateState();
}

class _SourceCreateState extends State<SourceCreate> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();

    // If updating, load existing data
    if (widget.id != null) {
      // You might need to fetch existing source data here
      // For now, we'll use the bloc's controller if it has data
      final bloc = context.read<SourceBloc>();
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
                ? 'Are you sure you want to create this source?'
                : 'Are you sure you want to update this source?',
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
      final Map<String, dynamic> body = {"name": nameController.text.trim()};
      if (widget.id != null &&
          context.read<SourceBloc>().selectedState.trim().isNotEmpty) {
        body["is_active"] =
        context.read<SourceBloc>().selectedState == "Active"
            ? true
            : false;
      }
      if (widget.id == null) {
        // Create new source
        context.read<SourceBloc>().add(AddSource(body: body));
      } else {
        // Update existing source
        context.read<SourceBloc>().add(
          UpdateSource(body: body, id: widget.id!),
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
    return BlocListener<SourceBloc, SourceState>(
      listener: (context, state) {
        if (state is SourceAddSuccess) {
          showCustomToast(
            context: context,
            title: 'Success!',
            description: widget.id == null
                ? 'Source created successfully!'
                : 'Source updated successfully!',
            type: ToastificationType.success,
            icon: Icons.check_circle,
            primaryColor: Colors.green,
          );

          // Clear form and close on success
          if (widget.id == null) {
            _clearForm();
          }
          Navigator.pop(context, true); // Return success result
        }
        if (state is SourceUpdateSuccess) {
          showCustomToast(
            context: context,
            title: 'Success!',
            description: widget.id == null
                ? 'Source created successfully!'
                : 'Source updated successfully!',
            type: ToastificationType.success,
            icon: Icons.check_circle,
            primaryColor: Colors.green,
          );

          // Clear form and close on success
          if (widget.id == null) {
            _clearForm();
          }
          // Navigator.pop(context, true); // Return success result
        } else if (state is SourceAddFailed) {
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
                  widget.id == null ? 'Create Source' : 'Update Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.red, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Name Input Field
            AppTextField(
              isRequired: true,
              controller: nameController,
              hintText: 'Enter source name',
              labelText: 'Source Name',

              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter source name';
                }
                if (value.length < 2) {
                  return 'Source name must be at least 2 characters long';
                }
                if (value.length > 50) {
                  return 'Source name must be less than 50 characters';
                }
                return null;
              },
            ),

            SizedBox(height: 10),
            if (widget.id !=null) ...[
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
                      hint: context.read<SourceBloc>().selectedState.isEmpty
                          ? "Select Status"
                          : context.read<SourceBloc>().selectedState,
                      isLabel: false,
                      value:
                      context.read<SourceBloc>().selectedState.isEmpty
                          ? null
                          : context.read<SourceBloc>().selectedState,
                      itemList: ["Active", "Inactive"],
                      onChanged: (newVal) {
                        setState(() {
                          context.read<SourceBloc>().selectedState = newVal
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
                  child: BlocBuilder<SourceBloc, SourceState>(
                    builder: (context, state) {
                      return AppButton(
                        name: widget.id == null ? 'Create' : 'Update',
                        onPressed: (state is SourceAddLoading)
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
