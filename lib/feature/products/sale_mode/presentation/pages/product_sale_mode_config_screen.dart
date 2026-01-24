// features/products/sale_mode/presentation/screens/product_sale_mode_config_screen.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../../../../core/widgets/app_dropdown.dart';
import '../../../../../../core/widgets/input_field.dart';
import '../../../../../../core/widgets/show_custom_toast.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../price_tier/presentation/bloc/price_tier_bloc.dart';
import '../../data/avliable_sales_model.dart';
import '../bloc/product_sale_mode/product_sale_mode_bloc.dart';

/// ================= PRICE TIER ROW =================
class PriceTierRow extends StatefulWidget {
  final Function(Map<String, dynamic>) onUpdate;
  final Map<String, dynamic>? initialData;

  const PriceTierRow({super.key, required this.onUpdate, this.initialData});

  @override
  State<PriceTierRow> createState() => _PriceTierRowState();
}

class _PriceTierRowState extends State<PriceTierRow> {
  late final TextEditingController minQtyCtrl;
  late final TextEditingController maxQtyCtrl;
  late final TextEditingController priceCtrl;

  @override
  void initState() {
    super.initState();
    minQtyCtrl = TextEditingController(
      text: widget.initialData?['min_quantity']?.toString() ?? '0',
    );
    maxQtyCtrl = TextEditingController(
      text: widget.initialData?['max_quantity']?.toString() ?? '',
    );
    priceCtrl = TextEditingController(
      text: widget.initialData?['price']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    minQtyCtrl.dispose();
    maxQtyCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  void _update() {
    widget.onUpdate({
      'min_quantity': double.tryParse(minQtyCtrl.text) ?? 0,
      'max_quantity': maxQtyCtrl.text.isNotEmpty
          ? double.tryParse(maxQtyCtrl.text)
          : null,
      'price': double.tryParse(priceCtrl.text) ?? 0,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: CustomInputField(
                controller: minQtyCtrl,
                labelText: 'Min Qty',
                keyboardType: TextInputType.number,
                onChanged: (_) => _update(),
                hintText: 'Enter Min Quantity',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomInputField(
                controller: maxQtyCtrl,
                labelText: 'Max Qty',
                hintText: 'Optional',
                keyboardType: TextInputType.number,
                onChanged: (_) => _update(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomInputField(
                controller: priceCtrl,
                hintText: 'Enter Price',
                labelText: 'Price',
                keyboardType: TextInputType.number,
                onChanged: (_) => _update(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= MAIN SCREEN =================
class ProductSaleModeConfigScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic>? initialData;

  const ProductSaleModeConfigScreen({
    super.key,
    required this.productId,
    this.initialData,
  });

  @override
  State<ProductSaleModeConfigScreen> createState() =>
      _ProductSaleModeConfigScreenState();
}

class _ProductSaleModeConfigScreenState
    extends State<ProductSaleModeConfigScreen> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController unitPriceCtrl;
  late final TextEditingController flatPriceCtrl;
  late final TextEditingController discountCtrl;

  String selectedSaleModeId = '';
  String selectedPriceType = 'unit';
  String selectedDiscountType = 'fixed';
  String selectedStatus = 'Active';

  List<Map<String, dynamic>> tiers = [];

  bool isEditInitialized = false; // ✅ prevent overwriting controllers multiple times

  @override
  void initState() {
    super.initState();

    unitPriceCtrl = TextEditingController();
    flatPriceCtrl = TextEditingController();
    discountCtrl = TextEditingController();

    if (widget.initialData != null) {
      final data = widget.initialData!;
      selectedSaleModeId = data['sale_mode_id']?.toString() ?? '';
      selectedPriceType = data['price_type'] ?? 'unit';
      selectedDiscountType = data['discount_type'] ?? 'fixed';
      selectedStatus = data['is_active'] == true ? 'Active' : 'Inactive';

      unitPriceCtrl.text = data['unit_price']?.toString() ?? '';
      flatPriceCtrl.text = data['flat_price']?.toString() ?? '';
      discountCtrl.text = data['discount_value']?.toString() ?? '';
      tiers = List<Map<String, dynamic>>.from(data['tiers'] ?? []);
    }

    context.read<PriceTierBloc>().add(
      FetchAvailableSaleModes(context, productId: widget.productId),
    );
  }

  @override
  void dispose() {
    unitPriceCtrl.dispose();
    flatPriceCtrl.dispose();
    discountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!formKey.currentState!.validate()) return;

    if (selectedPriceType == 'tier' && tiers.isEmpty) {
      showCustomToast(
        context: context,
        title: 'Error',
        description: 'Add at least one tier',
        type: ToastificationType.error,
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );
      return;
    }

    final body = {
      'product': int.parse(widget.productId),
      'sale_mode': int.parse(selectedSaleModeId),
      'unit_price': unitPriceCtrl.text.isNotEmpty
          ? double.tryParse(unitPriceCtrl.text)
          : null,
      'flat_price': flatPriceCtrl.text.isNotEmpty
          ? double.tryParse(flatPriceCtrl.text)
          : null,
      'discount_type': discountCtrl.text.isNotEmpty
          ? selectedDiscountType
          : null,
      'discount_value': discountCtrl.text.isNotEmpty
          ? double.tryParse(discountCtrl.text)
          : null,
      'is_active': selectedStatus == 'Active',
      if (selectedPriceType == 'tier') 'tiers': tiers,
    };

    final bloc = context.read<ProductSaleModeBloc>();

    if (widget.initialData?['id'] != null) {
      bloc.add(
        UpdateProductSaleMode(
          id: widget.initialData!['id'].toString(),
          body: body,
        ),
      );
    } else {
      bloc.add(AddProductSaleMode(body: body));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductSaleModeBloc, ProductSaleModeState>(
      listener: (context, state) {
        if (state is ProductSaleModeAddLoading) {
          // Optionally show loader
        }

        if (state is ProductSaleModeAddSuccess) {
          Navigator.of(context).pop(true); // close screen safely
          context.read<ProductSaleModeBloc>().add(
            FetchProductSaleModeList(context, productId: widget.productId),
          );
          showCustomToast(
            context: context,
            title: 'Success!',
            description: "Configuration saved successfully",
            icon: Icons.check_circle,
            primaryColor: Colors.green,
          );
        } else if (state is ProductSaleModeAddFailed) {
          Navigator.of(context).pop(true); // close screen safely
          context.read<ProductSaleModeBloc>().add(
            FetchProductSaleModeList(context, productId: widget.productId),
          );
          showCustomToast(
            context: context,
            title: state.title.isNotEmpty ? state.title : 'Error',
            description: state.content,
            icon: Icons.add_alert,
            primaryColor: Colors.redAccent,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bottomNavBg(context),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Product Configuration',
                      style: AppTextStyle.titleMedium(context),
                    ),
                    IconButton(
                      icon: const Icon(HugeIcons.strokeRoundedCancelSquare),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// SALE MODE
                BlocBuilder<PriceTierBloc, PriceTierState>(
                  builder: (context, state) {
                    if (state is AvailableSaleModesSuccess) {
                      AvlibleSaleModeModel? selectedMode;

                      // Only set selectedMode if we are in edit mode
                      if (selectedSaleModeId.isNotEmpty && !isEditInitialized) {
                        selectedMode = state.availableModes.firstWhereOrNull(
                              (e) => e.id.toString() == selectedSaleModeId,
                        );

                        if (selectedMode != null) {
                          unitPriceCtrl.text =
                              selectedMode.unitPrice?.toString() ?? '';
                          flatPriceCtrl.text =
                              selectedMode.flatPrice?.toString() ?? '';
                          selectedPriceType = selectedMode.priceType ?? 'unit';
                        }

                        isEditInitialized = true; // prevent overwriting
                      }

                      return AppDropdown<AvlibleSaleModeModel>(
                        label: "Sale Mode",
                        hint: "Select Sale Mode",
                        value: selectedMode,
                        itemList: state.availableModes,
                        itemLabel: (m) => '${m.name} (${m.priceType})',
                        onChanged: (m) {
                          setState(() {
                            selectedSaleModeId = m!.id.toString();
                            selectedPriceType = m.priceType ?? 'unit';
                            unitPriceCtrl.text = m.unitPrice?.toString() ?? '';
                            flatPriceCtrl.text = m.flatPrice?.toString() ?? '';
                            tiers.clear();
                          });
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),

                const SizedBox(height: 16),

                /// PRICE TYPE
                AppDropdown<Map<String, String>>(
                  label: "Price Type",
                  hint: "Select Price Type",
                  value: {
                    'value': selectedPriceType,
                    'label': selectedPriceType == 'unit'
                        ? 'Unit Price'
                        : selectedPriceType == 'flat'
                        ? 'Flat Price'
                        : 'Tier Price',
                  },
                  itemList: const [
                    {'value': 'unit', 'label': 'Unit Price'},
                    {'value': 'flat', 'label': 'Flat Price'},
                    {'value': 'tier', 'label': 'Tier Price'},
                  ],
                  itemLabel: (i) => i['label']!,
                  onChanged: (v) {
                    setState(() {
                      selectedPriceType = v?['value'] ?? '';
                      if (selectedPriceType != 'tier') tiers.clear();
                    });
                  },
                ),

                const SizedBox(height: 12),

                if (selectedPriceType != 'flat')
                  CustomInputField(
                    controller: unitPriceCtrl,
                    labelText: 'Unit Price',
                    keyboardType: TextInputType.number,
                    hintText: 'Enter unit price',
                  ),

                if (selectedPriceType == 'flat')
                  CustomInputField(
                    controller: flatPriceCtrl,
                    labelText: 'Flat Price',
                    hintText: "Enter flat price",
                    keyboardType: TextInputType.number,
                  ),

                if (selectedPriceType == 'tier') ...[
                  const SizedBox(height: 12),
                  ...tiers.asMap().entries.map(
                        (e) => Row(
                      children: [
                        Expanded(
                          child: PriceTierRow(
                            initialData: e.value,
                            onUpdate: (d) => tiers[e.key] = d,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() => tiers.removeAt(e.key)),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() {
                      tiers.add({
                        'min_quantity': 0,
                        'max_quantity': null,
                        'price': 0,
                      });
                    }),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Tier'),
                  ),
                ],

                const SizedBox(height: 30),
                AppButton(name: 'Save', onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
