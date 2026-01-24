import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/widgets/app_button.dart';
import '../../../../../../core/widgets/app_loader.dart';
import '../../../../../../core/widgets/input_field.dart';
import '../../../../../../core/widgets/show_custom_toast.dart';
import '../../data/model/price_tier_model.dart';
import '../bloc/price_tier_bloc.dart';

class PriceTierManagementDialog extends StatefulWidget {
  final int? productSaleModeId;
  final String? productId;
  final String? title;
  final bool showAddButton;

  const PriceTierManagementDialog({
    super.key,
    required this.productSaleModeId,
    this.productId,
    this.title,
    this.showAddButton = true,
  });

  @override
  State<PriceTierManagementDialog> createState() =>
      _PriceTierManagementDialogState();
}

class _PriceTierManagementDialogState extends State<PriceTierManagementDialog> {
  late PriceTierBloc _priceTierBloc;
  final _formKey = GlobalKey<FormState>();
  final _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _priceTierBloc = context.read<PriceTierBloc>();
    _loadPriceTiers();
  }

  void _loadPriceTiers() {
    _priceTierBloc.add(
      LoadPriceTiers(
        context: context,
        productSaleModeId: widget.productSaleModeId,
        productId: widget.productId,
      ),
    );
  }

  void _showAddEditDialog({PriceTierModel? priceTier}) {
    final isEditing = priceTier != null;
    final minQuantityController = TextEditingController(
      text: isEditing ? priceTier.minQuantity?.toString() ?? '' : '',
    );
    final maxQuantityController = TextEditingController(
      text: isEditing
          ? (priceTier.maxQuantity != null && priceTier.maxQuantity! > 0
                ? priceTier.maxQuantity?.toString()
                : '')
          : '',
    );
    final priceController = TextEditingController(
      text: isEditing ? priceTier.price?.toString() ?? '' : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            insetPadding: EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius:BorderRadiusGeometry.circular(AppSizes.radius),
              child: Container(
                width: double.infinity,
                color: AppColors.bottomNavBg(context),
                height: MediaQuery.of(context).size.height * 0.45,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Edit Price Tier' : 'Add Price Tier',
                          style: AppTextStyle.titleMedium(context),
                        ),
                        IconButton(
                          icon: const Icon(HugeIcons.strokeRoundedCancelSquare),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomInputField(
                                controller: minQuantityController,
                                labelText: 'Minimum Quantity',
                                hintText: 'Enter minimum quantity',
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                isRequired: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter minimum quantity';
                                  }
                                  final minQty = double.tryParse(value);
                                  if (minQty == null) {
                                    return 'Please enter a valid number';
                                  }
                                  if (minQty <= 0) {
                                    return 'Minimum quantity must be > 0';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 6),
                              CustomInputField(
                                controller: maxQuantityController,
                                labelText: 'Maximum Quantity (Optional)',
                                hintText: 'Leave empty for unlimited',
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final maxQty = double.tryParse(value);
                                    if (maxQty == null) {
                                      return 'Please enter valid number';
                                    }
                                    final minQty =
                                        double.tryParse(
                                          minQuantityController.text,
                                        ) ??
                                        0;
                                    if (maxQty <= minQty) {
                                      return 'Max must be > min';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 6),
                              CustomInputField(
                                controller: priceController,
                                labelText: 'Price per Unit',
                                hintText: 'Enter price per unit',
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                isRequired: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter price';
                                  }
                                  final price = double.tryParse(value);
                                  if (price == null) {
                                    return 'Please enter a valid number';
                                  }
                                  if (price <= 0) return 'Price must be > 0';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    BlocConsumer<PriceTierBloc, PriceTierState>(
                      listener: (context, state) {
                        if (state is PriceTierOperationSuccess) {
                          Navigator.pop(context);
                          _loadPriceTiers();
                          showCustomToast(
                            context: context,
                            title: 'Success!',
                            description: state.message,
                            type: ToastificationType.success,
                            icon: Icons.check_circle,
                            primaryColor: Colors.green,
                          );
                        } else if (state is PriceTierOperationFailed) {
                          showCustomToast(
                            context: context,
                            title: 'Error',
                            description: state.error,
                            type: ToastificationType.error,
                            icon: Icons.error,
                            primaryColor: Colors.red,
                          );
                        }
                      },
                      builder: (context, state) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
              
                            ElevatedButton(
                              onPressed: state is PriceTierLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        Map<String, dynamic> payload = {
                                          "product_sale_mode":
                                              widget.productSaleModeId,
                                          "min_quantity": double.parse(
                                            minQuantityController.text,
                                          ),
                                          "max_quantity":
                                              maxQuantityController
                                                  .text
                                                  .isNotEmpty
                                              ? double.parse(
                                                  maxQuantityController.text,
                                                )
                                              : null,
                                          "price": double.parse(
                                            priceController.text,
                                          ),
                                        };
                                        if (isEditing) {
                                          payload['id'] = priceTier.id.toString();
                                          _priceTierBloc.add(
                                            UpdatePriceTier(
                                              context: context,
                                              priceTier: payload,
                                            ),
                                          );
                                        } else {
                                          _priceTierBloc.add(
                                            AddPriceTier(
                                              context: context,
                                              priceTier: payload,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              child: state is PriceTierLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(isEditing ? 'Update' : 'Add'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this price tier?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _priceTierBloc.add(DeletePriceTier(id: id, context: context));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceTierList(List<PriceTierModel> priceTiers) {
    if (priceTiers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.price_change_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No price tiers found',
              style: AppTextStyle.body(
                context,
              ).copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            if (widget.showAddButton)
              Text(
                'Click "Add Tier" to create your first price tier',
                style: AppTextStyle.body(context),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: priceTiers.length,
      itemBuilder: (context, index) {
        final tier = priceTiers[index];
        final maxQuantityText =
            tier.maxQuantity != null && tier.maxQuantity! > 0
            ? '- ${tier.maxQuantity?.toStringAsFixed(2)}'
            : 'and above';

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(
              color: AppColors.greyColor(context).withValues(alpha: 0.5),
            ),
          ),
          child: ListTile(
            title: Text(
              '${tier.minQuantity?.toStringAsFixed(2)} $maxQuantityText',
              style: AppTextStyle.subtitle(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Price: ${_currencyFormat.format(tier.price ?? 0)} per unit',
              style: AppTextStyle.body(context).copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor(context),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Iconsax.edit,
                    size: 20,
                    color: AppColors.primaryColor(context),
                  ),
                  onPressed: () => _showAddEditDialog(priceTier: tier),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(
                    HugeIcons.strokeRoundedDeleteThrow,
                    size: 20,
                    color: Colors.red,
                  ),
                  onPressed: () => _confirmDelete(tier.id!),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PriceTierBloc, PriceTierState>(
      listener: (context, state) {
        if (state is PriceTierOperationLoading) {
          appLoader(context, 'Processing...');
        }
      },
      builder: (context, state) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.98,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.title ?? 'Price Tiers Management',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                const SizedBox(height: 8),

                if (widget.showAddButton)
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppButton(
                      size: 120,
                      name: 'Add Tier',
                      icon: Icon(
                        Icons.add,
                        color: AppColors.whiteColor(context),
                      ),
                      onPressed: () => _showAddEditDialog(),
                    ),
                  ),
                const SizedBox(height: 8),

                // Price Tier List
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state is PriceTierListLoaded) {
                        return _buildPriceTierList(state.priceTiers);
                      } else if (state is PriceTierLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return const Center(
                          child: Text('No price tiers loaded'),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
