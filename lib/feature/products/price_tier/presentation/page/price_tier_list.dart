// features/products/sale_mode/presentation/screens/price_tier_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/widgets/app_scaffold.dart';
import '../../../../../../core/widgets/app_loader.dart';
import '../../../../../../core/widgets/show_custom_toast.dart';
import '../../../sale_mode/data/product_sale_mode_model.dart';
import '../../data/model/price_tier_model.dart';
import '../bloc/price_tier_bloc.dart';
import 'price_tier_management_dialog.dart';

class PriceTierListScreen extends StatefulWidget {
  final int? productSaleModeId;
  final int? productId;

  const PriceTierListScreen({
    super.key,
    this.productSaleModeId,
    this.productId,
  });

  @override
  State<PriceTierListScreen> createState() => _PriceTierListScreenState();
}

class _PriceTierListScreenState extends State<PriceTierListScreen> {
  late PriceTierBloc _priceTierBloc;

  @override
  void initState() {
    super.initState();
    _priceTierBloc = context.read<PriceTierBloc>();
    _loadPriceTiers();
  }

  void _loadPriceTiers() {
    _priceTierBloc.add(LoadPriceTiers(
      context: context,
      productSaleModeId: widget.productSaleModeId,
      productId: widget.productId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Price Tiers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => PriceTierManagementDialog(
                  productSaleModeId: widget.productSaleModeId,
                  productId: widget.productId,
                  title: 'Add Price Tier',
                  showAddButton: true,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPriceTiers,
          ),
        ],
      ),
      body: BlocConsumer<PriceTierBloc, PriceTierState>(
        listener: (context, state) {
          if (state is PriceTierOperationFailed) {
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
          if (state is PriceTierLoading && _priceTierBloc.priceTiers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PriceTierListLoaded) {
            return _buildPriceTierList(state.priceTiers);
          }

          return const Center(child: Text('No price tiers found'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => PriceTierManagementDialog(
              productSaleModeId: widget.productSaleModeId,
              productId: widget.productId,
              title: 'Add Price Tier',
              showAddButton: true,
            ),
          );
        },
        child: const Icon(Icons.add),
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
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No Price Tiers Found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Click the + button to add a new price tier',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: priceTiers.length,
      itemBuilder: (context, index) {
        final tier = priceTiers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryColor(context).withOpacity(0.1),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor(context),
                ),
              ),
            ),
            title: Text(
              'Quantity: ${tier.minQuantity} ${tier.maxQuantity != null && tier.maxQuantity! > 0 ? '- ${tier.maxQuantity}' : '+'} ${tier.unit ?? 'units'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Price: \$${tier.price?.toStringAsFixed(2)} per ${tier.maxQuantity ?? 'unit'}',
              style: TextStyle(
                color: AppColors.primaryColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: AppColors.primaryColor(context)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => PriceTierManagementDialog(
                        productSaleModeId: widget.productSaleModeId,
                        title: 'Edit Price Tier',
                        showAddButton: false,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    if (tier.id != null) {
                      _priceTierBloc.add(DeletePriceTier(
                        id: tier.id!,
                        context: context,
                      ));
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}