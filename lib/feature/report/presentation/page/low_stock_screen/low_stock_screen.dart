// lib/feature/report/presentation/screens/low_stock_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_inventory/core/configs/app_colors.dart';
import 'package:smart_inventory/core/configs/app_images.dart';
import 'package:smart_inventory/core/configs/app_text.dart';
import 'package:smart_inventory/core/shared/widgets/sideMenu/sidebar.dart';
import 'package:smart_inventory/core/widgets/app_alert_dialog.dart';
import 'package:smart_inventory/feature/report/presentation/bloc/low_stock_bloc/low_stock_bloc.dart';

import '../../../../../responsive.dart';
import '../../../data/model/low_stock_model.dart';

class LowStockScreen extends StatefulWidget {
  const LowStockScreen({super.key});

  @override
  State<LowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  @override
  void initState() {
    super.initState();
    _fetchLowStockReport();
  }

  void _fetchLowStockReport() {
    context.read<LowStockBloc>().add(FetchLowStockReport(context: context));
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen = Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return Container(
      color: AppColors.bg,
      child: SafeArea(
        child: ResponsiveRow(
          children: [
            if (isBigScreen) _buildSidebar(),
            _buildContentArea(isBigScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() => ResponsiveCol(
    xs: 0,
    sm: 1,
    md: 1,
    lg: 2,
    xl: 2,
    child: Container(color: Colors.white, child: const Sidebar()),
  );

  Widget _buildContentArea(bool isBigScreen) {
    return ResponsiveCol(
      xs: 12,
      lg: 10,
      child: RefreshIndicator(
        onRefresh: () async => _fetchLowStockReport(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildAlertCards(),
              const SizedBox(height: 16),
              _buildLowStockTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Low Stock Alert",
          style: AppTextStyle.cardTitle(context).copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _fetchLowStockReport,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            BlocBuilder<LowStockBloc, LowStockState>(
              builder: (context, state) {
                if (state is LowStockSuccess) {
                  return ElevatedButton.icon(
                    onPressed: () => _showRestockAlert(context, state.response.report),
                    icon: const Icon(Icons.notification_important),
                    label: const Text("Restock Alert"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlertCards() {
    return BlocBuilder<LowStockBloc, LowStockState>(
      builder: (context, state) {
        if (state is! LowStockSuccess) return const SizedBox();

        final summary = state.response.summary;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildAlertCard(
              "Total Low Stock Items",
              summary.totalLowStockItems.toString(),
              Icons.warning_amber,
              Colors.orange,
              "Items below alert level",
            ),
            _buildAlertCard(
              "Critical Items",
              summary.criticalItems.toString(),
              Icons.dangerous,
              Colors.red,
              "Out of stock items",
            ),
            _buildAlertCard(
              "Alert Threshold",
              "Below ${summary.threshold}",
              Icons.settings,
              Colors.blue,
              "Stock alert level",
            ),
            _buildAlertCard(
              "Stock Health",
              "${((summary.totalLowStockItems - summary.criticalItems) / summary.totalLowStockItems * 100).toStringAsFixed(1)}%",
              Icons.health_and_safety,
              Colors.green,
              "Items with some stock",
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlertCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockTable() {
    return BlocBuilder<LowStockBloc, LowStockState>(
      builder: (context, state) {
        if (state is LowStockLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading low stock report..."),
              ],
            ),
          );
        } else if (state is LowStockSuccess) {
          if (state.response.report.isEmpty) {
            return _noDataWidget("No low stock items found. Great job!");
          }
          return LowStockDataTableWidget(products: state.response.report);
        } else if (state is LowStockFailed) {
          return _errorWidget(state.content);
        }
        return _noDataWidget("No data available");
      },
    );
  }

  Widget LowStockDataTableWidget({required List<LowStockProduct> products}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DataTable(
          headingRowColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) => Colors.red.withOpacity(0.1),
          ),
          columns: const [
            DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Current Stock', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('Alert Level', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Action Needed', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: products.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;

            return DataRow(
              color: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return index % 2 == 0 ? Colors.grey.withOpacity(0.05) : Colors.transparent;
                },
              ),
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(
                  Text(
                    product.productName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(Text(product.category)),
                DataCell(Text(product.brand)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: product.statusColor),
                    ),
                    child: Text(
                      product.totalStockQuantity.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: product.statusColor,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(product.alertQuantity.toString())),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.stockStatus,
                      style: TextStyle(
                        color: product.statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  _buildActionButton(product),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionButton(LowStockProduct product) {
    return ElevatedButton(
      onPressed: () => _showProductDetails(product),
      style: ElevatedButton.styleFrom(
        backgroundColor: product.totalStockQuantity == 0 ? Colors.red : Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            product.totalStockQuantity == 0 ? Icons.error : Icons.warning,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(product.totalStockQuantity == 0 ? 'URGENT' : 'RESTOCK'),
        ],
      ),
    );
  }

  void _showProductDetails(LowStockProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.productName, style: const TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Category:', product.category),
            _buildDetailRow('Brand:', product.brand),
            _buildDetailRow('Selling Price:', '\$${product.sellingPrice.toStringAsFixed(2)}'),
            _buildDetailRow('Current Stock:', product.totalStockQuantity.toString()),
            _buildDetailRow('Alert Level:', product.alertQuantity.toString()),
            _buildDetailRow('Total Sold:', product.totalSoldQuantity.toString()),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: product.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: product.statusColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: product.statusColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.totalStockQuantity == 0
                          ? '🚨 OUT OF STOCK - Immediate restock required!'
                          : '⚠️ LOW STOCK - ${product.belowAlertLevel} units below alert level',
                      style: TextStyle(
                        color: product.statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to purchase screen or show restock dialog
              _navigateToRestock(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create Purchase Order'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  void _navigateToRestock(LowStockProduct product) {
    // Implement navigation to purchase screen with pre-filled product
    appAlertDialog(
      context,
      "Navigate to purchase screen to restock ${product.productName}?",
      title: "Restock Product",
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Add your navigation logic here
            // context.read<DashboardBloc>().add(ChangeDashboardScreen(index: /* purchase screen index */));
          },
          child: const Text("Go to Purchase"),
        ),
      ],
    );
  }

  void _showRestockAlert(BuildContext context, List<LowStockProduct> products) {
    final criticalItems = products.where((p) => p.totalStockQuantity == 0).length;
    final lowStockItems = products.where((p) => p.totalStockQuantity > 0 && p.totalStockQuantity <= p.alertQuantity).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notification_important, color: Colors.red),
            SizedBox(width: 8),
            Text('Restock Alert Summary'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have ${products.length} items requiring attention:'),
            const SizedBox(height: 16),
            if (criticalItems > 0) _buildAlertItem('🚨 Critical Items (Out of Stock)', criticalItems, Colors.red),
            if (lowStockItems > 0) _buildAlertItem('⚠️ Low Stock Items', lowStockItems, Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Consider creating purchase orders for these items to maintain optimal inventory levels.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to bulk purchase screen
            },
            child: const Text('Bulk Restock'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, int count, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noDataWidget(String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(AppImages.noData, width: 200, height: 200),
        const SizedBox(height: 12),
        Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.green),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
            onPressed: _fetchLowStockReport,
            child: const Text("Refresh")
        ),
      ],
    ),
  );

  Widget _errorWidget(String error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 60, color: Colors.red),
        const SizedBox(height: 16),
        Text("Error: $error"),
        const SizedBox(height: 8),
        ElevatedButton(
            onPressed: _fetchLowStockReport,
            child: const Text("Retry")
        ),
      ],
    ),
  );
}