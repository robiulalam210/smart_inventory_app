import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../bloc/expense_head/expense_head_bloc.dart';

class ExpenseHeadCreate extends StatefulWidget {
  final String? id;
  final String? name;

  const ExpenseHeadCreate({super.key, this.id, this.name});

  @override
  State<ExpenseHeadCreate> createState() => _ExpenseHeadCreateState();
}

class _ExpenseHeadCreateState extends State<ExpenseHeadCreate> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name ?? '');

    // Initialize the bloc with existing data if in edit mode
    if (widget.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ExpenseHeadBloc>().name.text = widget.name ?? '';
      });
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
          title:  Text('Confirm',style: AppTextStyle.titleMedium(context)),
          content: Text(
            widget.id == null
                ? 'Are you sure you want to create this expense head?'
                : 'Are you sure you want to update this expense head?',
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
      final Map<String, String> body = {
        "name": context.read<ExpenseHeadBloc>().name.text,
      };

      if (widget.id == null) {
        // Create new expense head
        context.read<ExpenseHeadBloc>().add(AddExpenseHead(body: body));
      } else {
        // Update existing expense head
        context.read<ExpenseHeadBloc>().add(
          UpdateExpenseHead(body: body, id: widget.id!),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseHeadBloc, ExpenseHeadState>(
      listener: (context, state) {
        if (state is ExpenseHeadAddSuccess) {
          showCustomToast(
            context: context,
            title: 'Success!',
            description: widget.id == null
                ? 'Expense head created successfully!'
                : 'Expense head updated successfully!',
            type: ToastificationType.success,
            icon: Icons.check_circle,
            primaryColor: Colors.green,
          );
          // AppRoutes.pop(context);
        } else if (state is ExpenseHeadAddFailed) {
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
      child: SafeArea(child: _buildMainContent()),
    );
  }

  Widget _buildMainContent() {
    return ResponsiveRow(
      spacing: 0,
      runSpacing: 0,
      children: [
        ResponsiveCol(
          xs: 12,
          sm: 12,
          md: 12,
          lg: 10,
          xl: 10,
          child: Container(
            padding: const EdgeInsets.only(bottom: 10),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: AppColors.bottomNavBg(context),
              borderRadius: BorderRadius.circular(AppSizes.radius),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 8.0),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Header with close button and title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.id == null
                                ? 'Create Expense Head'
                                : 'Update Expense Head',
                            style:  TextStyle(
                              fontSize: 16,
                              color: AppColors.text(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => AppRoutes.pop(context),
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 22,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppSizes.height(context) * 0.02),

                      // Name Input Field
                      CustomInputField(
                        isRequiredLable: true,
                        isRequired: true,
                        controller: context.read<ExpenseHeadBloc>().name,
                        hintText: 'Name',
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter name';
                          }
                          if (value.length < 2) {
                            return 'Name must be at least 2 characters long';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          // You can add real-time validation or other logic here
                        },
                      ),

                      SizedBox(height: AppSizes.height(context) * 0.03),

                      // Submit Button
                      Center(
                        child: BlocBuilder<ExpenseHeadBloc, ExpenseHeadState>(
                          builder: (context, state) {
                            return AppButton(
                              name: widget.id == null ? 'Create' : 'Update',
                              onPressed: state is ExpenseHeadAddLoading
                                  ? null
                                  : _showConfirmationDialog,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
