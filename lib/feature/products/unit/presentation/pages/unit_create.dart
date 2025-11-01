import 'package:smart_inventory/feature/products/unit/presentation/bloc/unit/unti_bloc.dart';
import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';

class UnitCreate extends StatefulWidget {
  final String? id;
  final bool isDialog;

  const UnitCreate({super.key, this.id, this.isDialog = true});

  @override
  State<UnitCreate> createState() => _UnitCreateState();
}

class _UnitCreateState extends State<UnitCreate> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();

    // If updating, load existing data
    if (widget.id != null) {
      // You might need to fetch existing unit data here
      // For now, we'll use the bloc's controller if it has data
      final bloc = context.read<UnitBloc>();
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
      final Map<String, String> body = {
        "name": nameController.text.trim(),
      };

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
    nameController.clear();
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
            CustomInputField(
              isRequiredLable: true,
              isRequired: true,
              controller: nameController,
              hintText: 'Enter unit name',
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

  Widget _buildFullScreenContent() {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: Text(widget.id == null ? 'Create Unit' : 'Update Unit'),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
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
                        hintText: 'Enter unit name',
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
                            child: BlocBuilder<UnitBloc, UnitState>(
                              builder: (context, state) {
                                return AppButton(
                                  name: widget.id == null ? 'Create Unit' : 'Update Unit',
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}