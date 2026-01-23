// features/products/sale_mode/presentation/screens/product_sale_mode_config_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';

import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../../../../core/widgets/app_dropdown.dart';
import '../../../../../../core/widgets/input_field.dart';
import '../../../../../../core/widgets/show_custom_toast.dart';
import '../../data/product_sale_mode_model.dart';
import '../bloc/product_sale_mode/product_sale_mode_bloc.dart';

class PriceTierRow extends StatefulWidget {
  final Function(Map<String, dynamic>) onUpdate;
  final Map<String, dynamic>? initialData;

  const PriceTierRow({
    super.key,
    required this.onUpdate,
    this.initialData,
  });

  @override
  State<PriceTierRow> createState() => _PriceTierRowState();
}

class _PriceTierRowState extends State<PriceTierRow> {
  late TextEditingController minQuantityController;
  late TextEditingController maxQuantityController;
  late TextEditingController priceController;

  @override
  void initState() {
    super.initState();
    minQuantityController = TextEditingController(
      text: widget.initialData?['min_quantity']?.toString() ?? '0',
    );
    maxQuantityController = TextEditingController(
      text: widget.initialData?['max_quantity']?.toString() ?? '',
    );
    priceController = TextEditingController(
      text: widget.initialData?['price']?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: CustomInputField(
                controller: minQuantityController,
                hintText: 'Min Qty',
                labelText: 'Min Quantity',
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateData(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomInputField(
                controller: maxQuantityController,
                hintText: 'Max Qty (leave empty for unlimited)',
                labelText: 'Max Quantity',
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateData(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomInputField(
                controller: priceController,
                hintText: 'Price',
                labelText: 'Price',
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateData(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateData() {
    widget.onUpdate({
      'min_quantity': double.tryParse(minQuantityController.text) ?? 0,
      'max_quantity': maxQuantityController.text.isNotEmpty
          ? double.tryParse(maxQuantityController.text)
          : null,
      'price': double.tryParse(priceController.text) ?? 0,
    });
  }
}

class ProductSaleModeConfigScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic>? initialData;

  const ProductSaleModeConfigScreen({
    super.key,
    required this.productId,
    this.initialData,
  });

  @override
  State<ProductSaleModeConfigScreen> createState() => _ProductSaleModeConfigScreenState();
}

class _ProductSaleModeConfigScreenState extends State<ProductSaleModeConfigScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController unitPriceController;
  late TextEditingController flatPriceController;
  late TextEditingController discountValueController;

  String selectedSaleModeId = '';
  String selectedPriceType = 'unit';
  String selectedDiscountType = 'fixed';
  String selectedStatus = 'Active';

  List<Map<String, dynamic>> tiers = [];

  @override
  void initState() {
    super.initState();
    unitPriceController = TextEditingController();
    flatPriceController = TextEditingController();
    discountValueController = TextEditingController();

    // Load initial data if provided
    if (widget.initialData != null) {
      selectedSaleModeId = widget.initialData!['sale_mode_id']?.toString() ?? '';
      selectedPriceType = widget.initialData!['price_type'] ?? 'unit';
      selectedDiscountType = widget.initialData!['discount_type'] ?? 'fixed';
      selectedStatus = widget.initialData!['is_active'] == true ? 'Active' : 'Inactive';
      unitPriceController.text = widget.initialData!['unit_price']?.toString() ?? '';
      flatPriceController.text = widget.initialData!['flat_price']?.toString() ?? '';
      discountValueController.text = widget.initialData!['discount_value']?.toString() ?? '';
      tiers = List<Map<String, dynamic>>.from(widget.initialData!['tiers'] ?? []);
    }
  }

  @override
  void dispose() {
    unitPriceController.dispose();
    flatPriceController.dispose();
    discountValueController.dispose();
    super.dispose();
  }

  void _addTier() {
    setState(() {
      tiers.add({
        'min_quantity': 0,
        'max_quantity': null,
        'price': 0,
      });
    });
  }

  void _removeTier(int index) {
    setState(() {
      tiers.removeAt(index);
    });
  }

  void _updateTier(int index, Map<String, dynamic> data) {
    setState(() {
      tiers[index] = data;
    });
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Configuration'),
          content: const Text('Are you sure you want to save this sale mode configuration?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
      if (selectedSaleModeId.isEmpty) {
        showCustomToast(
          context: context,
          title: 'Error',
          description: 'Please select a sale mode',
          type: ToastificationType.error,
          icon: Icons.error,
          primaryColor: Colors.redAccent,
        );
        return;
      }

      final Map<String, dynamic> body = {
        'product_id': widget.productId,
        'sale_mode_id': int.parse(selectedSaleModeId),
        'unit_price': unitPriceController.text.isNotEmpty
            ? double.tryParse(unitPriceController.text)
            : null,
        'flat_price': flatPriceController.text.isNotEmpty
            ? double.tryParse(flatPriceController.text)
            : null,
        'discount_type': discountValueController.text.isNotEmpty
            ? selectedDiscountType
            : null,
        'discount_value': discountValueController.text.isNotEmpty
            ? double.tryParse(discountValueController.text)
            : null,
        'is_active': selectedStatus == 'Active',
      };

      if (selectedPriceType == 'tier' && tiers.isNotEmpty) {
        body['tiers'] = tiers;
      }

      // Check if we're updating or creating
      if (widget.initialData != null && widget.initialData!['id'] != null) {
        context.read<ProductSaleModeBloc>().add(
          UpdateProductSaleMode(
            id: widget.initialData!['id'].toString(),
            body: body,
          ),
        );
      } else {
        context.read<ProductSaleModeBloc>().add(
          AddProductSaleMode(body: body),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductSaleModeBloc, ProductSaleModeState>(
      listener: (context, state) {
        if (state is ProductSaleModeAddSuccess) {
          showCustomToast(
            context: context,
            title: 'Success!',
            description: 'Sale mode configuration saved successfully',
            type: ToastificationType.success,
            icon: Icons.check_circle,
            primaryColor: Colors.green,
          );
          Navigator.pop(context, true);
        } else if (state is ProductSaleModeAddFailed) {
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
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.initialData == null
                      ? 'Configure Sale Mode'
                      : 'Update Sale Mode Configuration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor(context),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Sale Mode Selection

            BlocBuilder<ProductSaleModeBloc, ProductSaleModeState>(
              builder: (context, state) {
                print("Current state: $state");

                if (state is ProductSaleModeListSuccess) {
                  final availableModes = state.list;

                  // Debug print to see what we have
                  print("Available modes count: ${availableModes.length}");
                  for (var mode in availableModes) {
                    print("Mode: ${mode.saleModeName}, ID: ${mode.id}, Price Type: ${mode.priceType}");
                  }

                  if (availableModes.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "No sale modes available. Please create sale modes first.",
                        style: TextStyle(color: Colors.orange),
                      ),
                    );
                  }

                  return AppDropdown(
                    label: "Sale Mode",
                    hint: "Select Sale Mode",
                    isLabel: true,
                    value: selectedSaleModeId.isNotEmpty ? selectedSaleModeId : null,
                    itemList: availableModes
                        .where((mode) => mode.id != null)
                        .map((mode) => {
                      'value': mode.id.toString(),
                      'label': '${mode.saleModeName ?? "Unknown"} (${mode.priceType ?? "unit"})',
                    })
                        .toList(),
                    onChanged: (newVal) {
                      if (newVal != null) {
                        setState(() {
                          selectedSaleModeId = newVal.toString();

                          // Find the selected mode from the list
                          final selectedMode = availableModes.firstWhere(
                                (mode) => mode.id.toString() == newVal.toString(),
                            orElse: () => ProductSaleModeModel(), // Return empty model if not found
                          );

                          // Get price type from the model
                          selectedPriceType = selectedMode.priceType ?? 'unit';

                          // Also auto-fill prices if available
                          if (selectedMode.unitPrice != null) {
                            unitPriceController.text = selectedMode.unitPrice.toString();
                          }
                          if (selectedMode.flatPrice != null) {
                            flatPriceController.text = selectedMode.flatPrice.toString();
                          }
                        });

                        print("Selected Sale Mode ID: $selectedSaleModeId");
                        print("Selected Price Type: $selectedPriceType");
                      }
                    },
                  );
                } else if (state is ProductSaleModeListLoading) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state is ProductSaleModeListFailed) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Error loading sale modes: ${state.content}",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),

            const SizedBox(height: 16),

            // Price Type Selection
            AppDropdown(
              label: "Price Type",
              hint: "Select Price Type",
              isLabel: true,
              value: selectedPriceType,
              itemList: const [
                {'value': 'unit', 'label': 'Unit Price'},
                {'value': 'flat', 'label': 'Flat Price'},
                {'value': 'tier', 'label': 'Tier Price'},
              ],
              onChanged: (newVal) {
                setState(() {
                  selectedPriceType = newVal.toString();
                });
              },
            ),

            const SizedBox(height: 16),

            // Unit Price (for unit price type)
            if (selectedPriceType == 'unit' || selectedPriceType == 'tier')
              CustomInputField(
                controller: unitPriceController,
                hintText: 'e.g., 100.00',
                labelText: 'Unit Price',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (selectedPriceType == 'unit' && (value == null || value.isEmpty)) {
                    return 'Please enter unit price';
                  }
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                  }
                  return null;
                },
              ),

            const SizedBox(height: 16),

            // Flat Price (for flat price type)
            if (selectedPriceType == 'flat')
              CustomInputField(
                controller: flatPriceController,
                hintText: 'e.g., 4000.00 (for BOSTA)',
                labelText: 'Flat Price',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (selectedPriceType == 'flat' && (value == null || value.isEmpty)) {
                    return 'Please enter flat price';
                  }
                  if (value != null && value.isNotEmpty) {
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                  }
                  return null;
                },
              ),

            const SizedBox(height: 16),

            // Tier Pricing (for tier price type)
            if (selectedPriceType == 'tier') ...[
              const Text(
                'Tier Pricing',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...tiers.asMap().entries.map((entry) {
                final index = entry.key;
                final tier = entry.value;
                return Row(
                  children: [
                    Expanded(
                      child: PriceTierRow(
                        initialData: tier,
                        onUpdate: (data) => _updateTier(index, data),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeTier(index),
                    ),
                  ],
                );
              }).toList(),
              ElevatedButton.icon(
                onPressed: _addTier,
                icon: const Icon(Icons.add),
                label: const Text('Add Tier'),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),

            // Discount Section
            Row(
              children: [
                Expanded(
                  child: AppDropdown(
                    label: "Discount Type",
                    hint: "Select Discount Type",
                    isLabel: true,
                    value: selectedDiscountType,
                    itemList: const [
                      {'value': 'fixed', 'label': 'Fixed Amount'},
                      {'value': 'percentage', 'label': 'Percentage'},
                    ],
                    onChanged: (newVal) {
                      setState(() {
                        selectedDiscountType = newVal.toString();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomInputField(
                    controller: discountValueController,
                    hintText: selectedDiscountType == 'percentage' ? 'e.g., 10' : 'e.g., 50',
                    labelText: 'Discount Value',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status Selection
            AppDropdown(
              label: "Status",
              hint: "Select Status",
              isLabel: true,
              value: selectedStatus,
              itemList: const [
                {'value': 'Active', 'label': 'Active'},
                {'value': 'Inactive', 'label': 'Inactive'},
              ],
              onChanged: (newVal) {
                setState(() {
                  selectedStatus = newVal.toString();
                });
              },
            ),

            const SizedBox(height: 24),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(
                  isOutlined: true,
                  size: 120,
                  color: AppColors.primaryColor(context),
                  borderColor: AppColors.primaryColor(context),
                  textColor: AppColors.errorColor(context),
                  name: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                BlocBuilder<ProductSaleModeBloc, ProductSaleModeState>(
                  builder: (context, state) {
                    return AppButton(
                      size: 120,
                      name: widget.initialData == null ? 'Save' : 'Update',
                      onPressed: (state is ProductSaleModeAddLoading)
                          ? null
                          : _showConfirmationDialog,
                      isLoading: state is ProductSaleModeAddLoading,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}