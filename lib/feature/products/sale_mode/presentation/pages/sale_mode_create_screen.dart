// features/products/sale_mode/presentation/screens/sale_mode_create_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../../../../core/widgets/app_dropdown.dart';
import '../../../../../../core/widgets/input_field.dart';
import '../../../../../../core/widgets/show_custom_toast.dart';
import '../../../unit/data/model/unit_model.dart';
import '../../../unit/presentation/bloc/unit/unti_bloc.dart';
import '../../data/sale_mode_model.dart';
import '../bloc/sale_mode_bloc.dart';

class SaleModeCreateScreen extends StatefulWidget {
  final String? id;
  final SaleModeModel? saleMode;

  const SaleModeCreateScreen({super.key, this.id, this.saleMode});

  @override
  State<SaleModeCreateScreen> createState() => _SaleModeCreateScreenState();
}

class _SaleModeCreateScreenState extends State<SaleModeCreateScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController codeController;
  late TextEditingController conversionFactorController;
  late TextEditingController baseUnitController;
  late UnitBloc unitBloc;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    codeController = TextEditingController();
    conversionFactorController = TextEditingController();
    baseUnitController = TextEditingController();
    unitBloc = context.read<UnitBloc>();
    unitBloc.add(FetchUnitList(context));

    // If updating, load existing data
    if (widget.id != null || widget.saleMode != null) {
      final bloc = context.read<SaleModeBloc>();

      if (widget.saleMode != null) {
        nameController.text = widget.saleMode!.name ?? '';
        codeController.text = widget.saleMode!.code ?? '';
        conversionFactorController.text =
            widget.saleMode!.conversionFactor?.toString() ?? '1.0';
        baseUnitController.text = widget.saleMode!.baseUnit?.toString() ?? '';
        bloc.selectedPriceType = widget.saleMode!.priceType ?? 'unit';
        bloc.selectedState = widget.saleMode!.isActive == true ? 'Active' : 'Inactive';
      } else if (bloc.nameController.text.isNotEmpty) {
        nameController.text = bloc.nameController.text;
        codeController.text = bloc.codeController.text;
        conversionFactorController.text = bloc.conversionFactorController.text;
        baseUnitController.text = bloc.baseUnitController.text;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    conversionFactorController.dispose();
    baseUnitController.dispose();
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
                ? 'Are you sure you want to create this sale mode?'
                : 'Are you sure you want to update this sale mode?',
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
      final  baseUnitId= int.tryParse(unitBloc.selectedIdState);

      final Map<String, dynamic> body = {
        "name": nameController.text.trim(),
        "code": codeController.text.trim(),
        "base_unit": baseUnitId,
        "conversion_factor": double.tryParse(conversionFactorController.text.trim()) ?? 1.0,
        "price_type": context.read<SaleModeBloc>().selectedPriceType,
        "is_active": context.read<SaleModeBloc>().selectedState == "Active",
      };

      if (widget.id == null && widget.saleMode == null) {
        // Create new sale mode
        context.read<SaleModeBloc>().add(AddSaleMode(body: body));
      } else {
        // Update existing sale mode
        final saleModeId = widget.id ?? widget.saleMode?.id?.toString();
        if (saleModeId != null) {
          context.read<SaleModeBloc>().add(
            UpdateSaleMode(id: saleModeId, body: body),
          );
        }
      }
    }
  }

  void _clearForm() {
    nameController.clear();
    codeController.clear();
    conversionFactorController.clear();
    baseUnitController.clear();
    formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaleModeBloc, SaleModeState>(
      listener: (context, state) {
        if (state is SaleModeAddSuccess) {
          showCustomToast(
            context: context,
            title: 'Success!',
            description: widget.id == null
                ? 'Sale mode created successfully!'
                : 'Sale mode updated successfully!',
            type: ToastificationType.success,
            icon: Icons.check_circle,
            primaryColor: Colors.green,
          );

          if (widget.id == null) {
            _clearForm();
          }
          Navigator.pop(context, true);
        } else if (state is SaleModeAddFailed) {
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
                  widget.id == null ? 'Create Sale Mode' : 'Update Sale Mode',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor(context),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),


            // Name Input Field
            CustomInputField(
              isRequired: true,
              controller: nameController,
              hintText: 'e.g., KG, GRAM, BOSTA',
              labelText: 'Sale Mode Name',
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter sale mode name';
                }
                if (value.length < 2) {
                  return 'Name must be at least 2 characters long';
                }
                return null;
              },
            ),


            // Code Input Field
            CustomInputField(
              isRequired: true,
              controller: codeController,
              hintText: 'e.g., KG, GRAM, BOSTA',
              labelText: 'Sale Mode Code',
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter sale mode code';
                }
                if (value.length < 2) {
                  return 'Code must be at least 2 characters long';
                }
                return null;
              },
            ),


            // Base Unit Input Field
          BlocBuilder<UnitBloc, UnitState>(
            builder: (context, state) {
              final selectedUnit = unitBloc.selectedState;
              final unitList = unitBloc.list;

              return AppDropdown(
                label: "Unit ",
                hint: "Select Unit",
                isLabel: false,
                isNeedAll: false,
                isRequired: true,
                isSearch: true,
                value: selectedUnit.isEmpty ? null : selectedUnit,
                itemList: unitList.map((e) => e.name ?? "").toList(),
                onChanged: (newVal) {
                  setState(() {
                    unitBloc.selectedState = newVal.toString();
                    final matchingUnit = unitList.firstWhere(
                          (unit) => unit.name.toString() == newVal.toString(),
                      orElse: () => UnitsModel(),
                    );
                    unitBloc.selectedIdState = matchingUnit.id?.toString() ?? "";
                  });
                },
                validator: (value) => value == null ? 'Please select Unit' : null,
              );
            },
          ),


            const SizedBox(height: 5),

            // Conversion Factor Input Field
            CustomInputField(
              isRequired: true,
              controller: conversionFactorController,
              hintText: 'e.g., 1.0 for KG, 0.001 for GRAM',
              labelText: 'Conversion Factor',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter conversion factor';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),


            // Price Type Dropdown
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;

                return SizedBox(
                  width: isSmallScreen
                      ? double.infinity
                      : constraints.maxWidth * 0.5,
                  child: AppDropdown(
                    label: "Price Type",
                    hint: "Select Price Type",
                    isLabel: false,
                    value: context.read<SaleModeBloc>().selectedPriceType,
                    itemList: const ["unit", "flat", "tier"],
                    onChanged: (newVal) {
                      setState(() {
                        context.read<SaleModeBloc>().selectedPriceType =
                            newVal.toString();
                      });
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // Status Dropdown (only for update)
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
                      value: context.read<SaleModeBloc>().selectedState.isEmpty
                          ? null
                          : context.read<SaleModeBloc>().selectedState,
                      itemList: const ["Active", "Inactive"],
                      onChanged: (newVal) {
                        setState(() {
                          context.read<SaleModeBloc>().selectedState =
                              newVal.toString();
                        });
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],

            // Buttons Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(
                  isOutlined: true,
                  size: 100,
                  color: AppColors.primaryColor(context),
                  borderColor: AppColors.primaryColor(context),
                  textColor: AppColors.errorColor(context),
                  name: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  child: BlocBuilder<SaleModeBloc, SaleModeState>(
                    builder: (context, state) {
                      return AppButton(
                        size: 100,
                        name: widget.id == null ? 'Create' : 'Update',
                        onPressed: (state is SaleModeAddLoading)
                            ? null
                            : _showConfirmationDialog,
                        isLoading: state is SaleModeAddLoading,
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