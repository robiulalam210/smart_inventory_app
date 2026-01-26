import 'package:collection/collection.dart';


import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../../../../core/widgets/app_dropdown.dart';
import '../../../../../../core/widgets/input_field.dart';
import '../../../../../../core/widgets/show_custom_toast.dart';
import '../../../price_tier/presentation/bloc/price_tier_bloc.dart';
import '../../data/avliable_sales_model.dart';
import '../bloc/product_sale_mode/product_sale_mode_bloc.dart';

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
      ...?widget.initialData,
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
      elevation: 0,
      color: AppColors.bottomNavBg(context),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bottomNavBg(context),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color:   AppColors.greyColor(context).withValues(alpha: 0.5),width: 0.5
              
              
          )
        ),
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
  final formKey = GlobalKey<FormState>();

  late TextEditingController unitPriceCtrl;
  late TextEditingController flatPriceCtrl;
  late TextEditingController discountCtrl;

  String selectedSaleModeId = '';
  String selectedPriceType = 'unit';
  String selectedDiscountType = 'fixed';
  String selectedStatus = 'Active';
  List<Map<String, dynamic>> tiers = [];

  @override
  void initState() {
    super.initState();

    unitPriceCtrl = TextEditingController();
    flatPriceCtrl = TextEditingController();
    discountCtrl = TextEditingController();

    if (widget.initialData != null) {
      _loadInitial(widget.initialData!);
    }
  }

  @override
  void didUpdateWidget(ProductSaleModeConfigScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != null && oldWidget.initialData != widget.initialData) {
      _loadInitial(widget.initialData!);
    }
  }

  void _loadInitial(Map<String, dynamic> data) {
    selectedSaleModeId = data['sale_mode_id']?.toString() ?? '';
    final loadedTiers = List<Map<String, dynamic>>.from(data['tiers'] ?? []);
    if (loadedTiers.isNotEmpty) {
      selectedPriceType = 'tier';
      tiers = loadedTiers;
    } else {
      selectedPriceType = data['price_type'] ?? 'unit';
      tiers = [];
    }
    selectedDiscountType = data['discount_type'] ?? 'fixed';
    selectedStatus = data['is_active'] == true ? 'Active' : 'Inactive';
    unitPriceCtrl.text = data['unit_price']?.toString() ?? '';
    flatPriceCtrl.text = data['flat_price']?.toString() ?? '';
    discountCtrl.text = data['discount_value']?.toString() ?? '';
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
      'price_type': selectedPriceType,
      'unit_price': selectedPriceType == 'unit' ? double.tryParse(unitPriceCtrl.text) : null,
      'flat_price': selectedPriceType == 'flat' ? double.tryParse(flatPriceCtrl.text) : null,
      'discount_type': discountCtrl.text.isNotEmpty ? selectedDiscountType : null,
      'discount_value': discountCtrl.text.isNotEmpty ? double.tryParse(discountCtrl.text) : null,
      'is_active': selectedStatus == 'Active',
      if (selectedPriceType == 'tier') 'tiers': tiers,
    };
    final bloc = context.read<ProductSaleModeBloc>();

    if (widget.initialData?['id'] != null) {
      body['id'] = widget.initialData!['id'];
      bloc.add(UpdateProductSaleMode(
        id: widget.initialData!['id'].toString(),
        body: body,
      ));
    } else {
      bloc.add(AddProductSaleMode(body: body));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductSaleModeBloc, ProductSaleModeState>(
      listener: (context, state) {
        if (state is ProductSaleModeAddSuccess) {
          Navigator.of(context).pop(true);
          context.read<ProductSaleModeBloc>().add(FetchProductSaleModeList(context, productId: widget.productId));
          showCustomToast(
            context: context,
            title: 'Success!',
            description: "Configuration saved successfully",
            icon: Icons.check_circle,
            primaryColor: Colors.green,
          );
        } else if (state is ProductSaleModeAddFailed) {
          Navigator.of(context).pop(true);
          context.read<ProductSaleModeBloc>().add(FetchProductSaleModeList(context, productId: widget.productId));
          showCustomToast(
            context: context,
            title: state.title.isNotEmpty ? state.title : 'Error',
            description: state.content,
            icon: Icons.add_alert,
            primaryColor: Colors.redAccent,
          );
        }
      },
      child: BlocBuilder<PriceTierBloc, PriceTierState>(
        builder: (context, saleModeState) {
          List<AvlibleSaleModeModel> modes = [];
          if (saleModeState is AvailableSaleModesSuccess) {
            modes = saleModeState.availableModes;
            // Make sure selectedSaleModeId always points to a valid mode, or default to the first one
            if (modes.isNotEmpty && (selectedSaleModeId.isEmpty || !modes.any((m) => m.id.toString() == selectedSaleModeId))) {
              selectedSaleModeId = modes.first.id.toString();
            }
          }
          AvlibleSaleModeModel? selectedMode = modes.firstWhereOrNull((e) => e.id.toString() == selectedSaleModeId);

          return Scaffold(
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

                    /// SALE MODE DROPDOWN
                    AppDropdown<AvlibleSaleModeModel>(
                      label: "Sale Mode",
                      hint: "Select Sale Mode",
                      value: selectedMode,
                      itemList: modes,
                      itemLabel: (m) => '${m.name} (${m.priceType})',
                      onChanged: (m) {
                        setState(() {
                          selectedSaleModeId = m!.id.toString();
                          selectedPriceType = m.priceType ?? 'unit';
                          if (selectedPriceType == 'unit') {
                            unitPriceCtrl.text = m.unitPrice?.toString() ?? '';
                            flatPriceCtrl.clear();
                            tiers.clear();
                          } else if (selectedPriceType == 'flat') {
                            flatPriceCtrl.text = m.flatPrice?.toString() ?? '';
                            unitPriceCtrl.clear();
                            tiers.clear();
                          } else if (selectedPriceType == 'tier') {
                            tiers = [];
                            unitPriceCtrl.clear();
                            flatPriceCtrl.clear();
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    /// PRICE TYPE DROPDOWN
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
                          final newType = v?['value'] ?? '';
                          if (newType == 'tier') {
                            if (widget.initialData != null &&
                                (widget.initialData?['tiers'] != null) &&
                                (widget.initialData?['tiers'] as List).isNotEmpty) {
                              tiers = List<Map<String, dynamic>>.from(widget.initialData?['tiers']);
                            } else {
                              tiers = [];
                            }
                            unitPriceCtrl.clear();
                            flatPriceCtrl.clear();
                          } else {
                            tiers.clear();
                            if (newType == 'unit') {
                              unitPriceCtrl.text = widget.initialData?['unit_price']?.toString() ?? '';
                              flatPriceCtrl.clear();
                            } else if (newType == 'flat') {
                              flatPriceCtrl.text = widget.initialData?['flat_price']?.toString() ?? '';
                              unitPriceCtrl.clear();
                            }
                          }
                          selectedPriceType = newType;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    if (selectedPriceType == 'unit')
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
                        keyboardType: TextInputType.number,
                        hintText: 'Enter flat price',
                      ),

                    if (selectedPriceType == 'tier') ...[
                      const SizedBox(height: 12),
                      ...tiers.asMap().entries.map(
                            (e) => Row(
                          children: [
                            Expanded(
                              child: PriceTierRow(
                                initialData: e.value,
                                onUpdate: (d) => setState(() {
                                  tiers[e.key] = {...tiers[e.key], ...d};
                                }),
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
          );
        },
      ),
    );
  }
}