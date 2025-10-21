import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_inventory/feature/expense/expense_head/data/model/expense_head_model.dart';
import 'package:smart_inventory/feature/expense/expense_sub_head/presentation/bloc/expense_sub_head/expense_sub_head_bloc.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/input_field.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
import '../../../expense_head/presentation/bloc/expense_head/expense_head_bloc.dart';

class ExpenseSubHeadCreate extends StatefulWidget {
  final String? id;
  final String? name;
  final ExpenseHeadModel? selectedHead; // Add selected head for edit mode

  const ExpenseSubHeadCreate({
    super.key,
    this.id,
    this.name,
    this.selectedHead
  });

  @override
  State<ExpenseSubHeadCreate> createState() => _ExpenseSubHeadCreateState();
}

class _ExpenseSubHeadCreateState extends State<ExpenseSubHeadCreate> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late ExpenseHeadModel? _selectedExpenseHead;

  @override
  void initState() {
    super.initState();
    _selectedExpenseHead = widget.selectedHead;

    // Fetch expense heads list
    context.read<ExpenseHeadBloc>().add(FetchExpenseHeadList(context));

    // Initialize the bloc with existing data if in edit mode
    if (widget.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ExpenseSubHeadBloc>().name.text = widget.name ?? '';
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }


  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.id == null ? 'Create Expense Sub Head' : 'Update Expense Sub Head'),
          content: Text(
            widget.id == null
                ? 'Are you sure you want to create this expense sub head?'
                : 'Are you sure you want to update this expense sub head?',
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
              child: Text(widget.id == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      if (_selectedExpenseHead == null) {
        showCustomToast(
          context: context,
          title: 'Error!',
          description: 'Please select an expense head',
          type: ToastificationType.error,
          icon: Icons.error,
          primaryColor: Colors.redAccent,
        );
        return;
      }

      final Map<String, dynamic> body = {
        "name": context.read<ExpenseSubHeadBloc>().name.text,
        "head": _selectedExpenseHead!.id.toString(), // Use the local variable
      };

      if (widget.id == null) {
        // Create new expense sub head
        context.read<ExpenseSubHeadBloc>().add(AddSubExpenseHead(body: body));
      } else {
        // Update existing expense sub head
        context.read<ExpenseSubHeadBloc>().add(
          UpdateSubExpenseHead(body: body, id: widget.id!),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseSubHeadBloc, ExpenseSubHeadState>(
      listener: (context, state) {
        if (state is ExpenseSubHeadAddSuccess) {
          showCustomToast(
            context: context,
            title: 'Success!',
            description: widget.id == null
                ? 'Expense sub head created successfully!'
                : 'Expense sub head updated successfully!',
            type: ToastificationType.success,
            icon: Icons.check_circle,
            primaryColor: Colors.green,
          );
        } else if (state is ExpenseSubHeadAddFailed) {
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
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusSize),
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
                                ? 'Create Expense Sub Head'
                                : 'Update Expense Sub Head',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 22,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppSizes.height(context) * 0.02),

                      // Expense Head Dropdown
                      BlocBuilder<ExpenseHeadBloc, ExpenseHeadState>(
                        builder: (context, state) {
                          if (state is ExpenseHeadListLoading) {
                            return const CircularProgressIndicator();
                          }

                          if (state is ExpenseHeadListFailed) {
                            return Text('Error: ${state.content}');
                          }

                          final expenseHeads = context.read<ExpenseHeadBloc>().list;

                          return AppDropdown<ExpenseHeadModel>(
                            context: context,
                            label: "Expense Head",
                            hint: _selectedExpenseHead?.name ?? "Select Expense Head",
                            isNeedAll: false,
                            isRequired: true,
                            value: _selectedExpenseHead,
                            itemList: expenseHeads,
                            onChanged: (newVal) {
                              setState(() {
                                _selectedExpenseHead = newVal;
                              });
                            },
                            validator: (value) {
                              return value == null
                                  ? 'Please select Expense Head'
                                  : null;
                            },
                            itemBuilder: (item) => DropdownMenuItem<ExpenseHeadModel>(
                              value: item,
                              child: Text(
                                item.name ?? 'Unnamed Head',
                                style: const TextStyle(
                                  color: AppColors.blackColor,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: AppSizes.height(context) * 0.02),

                      // Name Input Field
                      CustomInputField(
                        isRequiredLable: true,
                        isRequired: true,
                        controller: context.read<ExpenseSubHeadBloc>().name,
                        hintText: 'Sub Head Name',
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter sub head name';
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
                      BlocBuilder<ExpenseSubHeadBloc, ExpenseSubHeadState>(
                        builder: (context, state) {
                          return AppButton(
                            name: widget.id == null ? 'Create' : 'Update',
                            onPressed: state is ExpenseSubHeadAddLoading
                                ? null
                                : _showConfirmationDialog,

                          );
                        },
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