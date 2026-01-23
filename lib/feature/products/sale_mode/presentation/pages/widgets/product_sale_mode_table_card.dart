// features/products/sale_mode/presentation/widgets/product_sale_mode_table_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/widgets/app_alert_dialog.dart';
import '../../../data/product_sale_mode_model.dart';
import '../../bloc/product_sale_mode/product_sale_mode_bloc.dart';
import '../product_sale_mode_config_screen.dart';


class ProductSaleModeTableCard extends StatelessWidget {
  final List<ProductSaleModeModel> productSaleModes;
  final Function() onRefresh;

  const ProductSaleModeTableCard({
    super.key,
    required this.productSaleModes,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (productSaleModes.isEmpty) {
      return const Center(
        child: Text('No sale modes configured'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          border: Border.all(color: AppColors.greyColor(context)),
        ),
        child: DataTable(
          columnSpacing: 20,
          horizontalMargin: 12,
          headingRowColor: MaterialStateProperty.all(
            AppColors.primaryColor(context).withOpacity(0.1),
          ),
          columns: const [
            DataColumn(label: Text('Sale Mode')),
            DataColumn(label: Text('Price Type')),
            DataColumn(label: Text('Unit Price')),
            DataColumn(label: Text('Flat Price')),
            DataColumn(label: Text('Discount')),
            DataColumn(label: Text('Tiers')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: productSaleModes.map((mode) {
            return DataRow(cells: [
              DataCell(Text(mode.saleModeName ?? '')),
              DataCell(
                Chip(
                  label: Text(
                    _getPriceTypeDisplay(mode.priceType),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: _getPriceTypeColor(mode.priceType),
                ),
              ),
              DataCell(Text(mode.unitPrice?.toStringAsFixed(2) ?? '')),
              DataCell(Text(mode.flatPrice?.toStringAsFixed(2) ?? '')),
              DataCell(Text(
                mode.discountValue != null
                    ? '${mode.discountValue}${mode.discountType == 'percentage' ? '%' : ''}'
                    : '-',
              )),
              DataCell(Text(mode.tiers?.length.toString() ?? '0')),
              DataCell(
                Chip(
                  label: Text(
                    mode.isActive == true ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: mode.isActive == true ? Colors.white : Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: mode.isActive == true ? Colors.green : Colors.grey[300],
                ),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: AppColors.primaryColor(context)),
                      onPressed: () => _showEditDialog(context, mode),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(context, mode),
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  String _getPriceTypeDisplay(String? priceType) {
    switch (priceType) {
      case 'unit':
        return 'Unit Price';
      case 'flat':
        return 'Flat Price';
      case 'tier':
        return 'Tier Price';
      default:
        return priceType ?? 'Unknown';
    }
  }

  Color _getPriceTypeColor(String? priceType) {
    switch (priceType) {
      case 'unit':
        return Colors.blue;
      case 'flat':
        return Colors.orange;
      case 'tier':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showEditDialog(BuildContext context, ProductSaleModeModel mode) {
    final data = {
      'id': mode.id,
      'sale_mode_id': mode.saleMode,
      'price_type': mode.priceType,
      'unit_price': mode.unitPrice,
      'flat_price': mode.flatPrice,
      'discount_type': mode.discountType,
      'discount_value': mode.discountValue,
      'is_active': mode.isActive,
      'tiers': mode.tiers?.map((tier) => tier.toJson()).toList(),
    };

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: ProductSaleModeConfigScreen(
                productId: mode.product?.toString() ?? '',
                initialData: data,
              ),
            ),
          ),
        );
      },
    ).then((_) {
      // if (_ == true) {
      //   onRefresh();
      // }
    });
  }

  void _showDeleteDialog(BuildContext context, ProductSaleModeModel mode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Configuration'),
          content: Text(
            'Are you sure you want to delete "${mode.saleModeName}" configuration?',
            style: AppTextStyle.body(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ProductSaleModeBloc>().add(
                  DeleteProductSaleMode(id: mode.id!.toString()),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}