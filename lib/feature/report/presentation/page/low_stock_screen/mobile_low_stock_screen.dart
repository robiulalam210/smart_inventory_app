import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';
import '/core/configs/app_colors.dart';
import '/core/configs/app_images.dart';
import '/feature/report/presentation/bloc/low_stock_bloc/low_stock_bloc.dart';
import '/feature/report/presentation/page/low_stock_screen/pdf/pdf.dart';

import '../../../../../responsive.dart';
import '../../../data/model/low_stock_model.dart';

class MobileLowStockScreen extends StatefulWidget {
  const MobileLowStockScreen({super.key});

  @override
  State<MobileLowStockScreen> createState() => _MobileLowStockScreenState();
}

class _MobileLowStockScreenState extends State<MobileLowStockScreen> {
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
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.bottomNavBg(context),
      appBar: AppBar(
        title: const Text('Low Stock Alert'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchLowStockReport(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchLowStockReport(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Info
              _buildHeaderInfo(),
              const SizedBox(height: 16),

              // Alert Cards
              _buildAlertCards(),
              const SizedBox(height: 16),

              // Low Stock List
              _buildLowStockList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRestockAlert,
        icon: const Icon(Icons.notification_important),
        label: const Text('Restock Alert'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber, color: Colors.red),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Low Stock Items',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Monitor products that require immediate attention. Critical items are out of stock, while low stock items are below alert levels.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCards() {
    return BlocBuilder<LowStockBloc, LowStockState>(
      builder: (context, state) {
        if (state is! LowStockSuccess) return const SizedBox();

        final summary = state.response.summary;
        final criticalItems = state.response.report.where((p) => p.totalStockQuantity == 0).length;
        final lowStockItems = state.response.report.length - criticalItems;

        return Column(
          children: [
            // Critical Items Alert
            if (criticalItems > 0)
              Card(
                color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.dangerous, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '$criticalItems Critical Items',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'URGENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'These items are completely out of stock and need immediate restocking.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

            // Summary Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildMobileAlertCard(
                  'Total Items',
                  summary.totalLowStockItems.toString(),
                  Icons.inventory_2,
                  AppColors.primaryColor(context),
                ),
                _buildMobileAlertCard(
                  'Critical',
                  criticalItems.toString(),
                  Icons.dangerous,
                  Colors.red,
                ),
                _buildMobileAlertCard(
                  'Low Stock',
                  lowStockItems.toString(),
                  Icons.warning,
                  Colors.orange,
                ),
                _buildMobileAlertCard(
                  'Alert Level',
                  '${summary.threshold}',
                  Icons.settings,
                  Colors.blue,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileAlertCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockList() {
    return BlocBuilder<LowStockBloc, LowStockState>(
      builder: (context, state) {
        if (state is LowStockLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading low stock items..."),
              ],
            ),
          );
        } else if (state is LowStockSuccess) {
          if (state.response.report.isEmpty) {
            return _buildEmptyState();
          }
          return _buildMobileStockList(state.response.report);
        } else if (state is LowStockFailed) {
          return _buildErrorState(state.content);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildMobileStockList(List<LowStockProduct> products) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isCritical = product.totalStockQuantity == 0;
        final belowLevel = product.alertQuantity - product.totalStockQuantity;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isCritical ? Colors.red.withOpacity(0.05) : Colors.orange.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: product.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isCritical ? Icons.dangerous : Icons.warning,
                        color: product.statusColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  product.category,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  product.brand,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Stock Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStockDetailItem(
                      'Current Stock',
                      product.totalStockQuantity.toString(),
                      Colors.black,
                    ),
                    _buildStockDetailItem(
                      'Alert Level',
                      product.alertQuantity.toString(),
                      Colors.blue,
                    ),
                    _buildStockDetailItem(
                      'Below By',
                      belowLevel > 0 ? belowLevel.toString() : '0',
                      Colors.orange,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Status Bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: product.totalStockQuantity / product.alertQuantity,
                    child: Container(
                      decoration: BoxDecoration(
                        color: product.statusColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Status Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: product.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.stockStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: product.statusColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${product.sellingPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showMobileProductDetails(context, product),
                        icon: const Icon(Icons.remove_red_eye, size: 16),
                        label: const Text('Details'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToRestock(context, product),
                        icon: const Icon(Icons.shopping_cart, size: 16),
                        label: const Text('Restock'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: product.statusColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStockDetailItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showMobileProductDetails(BuildContext context, LowStockProduct product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.productName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Product Details
              _buildMobileDetailRow('Category:', product.category),
              _buildMobileDetailRow('Brand:', product.brand),
              _buildMobileDetailRow('Selling Price:', '\$${product.sellingPrice.toStringAsFixed(2)}'),
              _buildMobileDetailRow('Current Stock:', product.totalStockQuantity.toString()),
              _buildMobileDetailRow('Alert Level:', product.alertQuantity.toString()),
              _buildMobileDetailRow('Total Sold:', product.totalSoldQuantity.toString()),
              _buildMobileDetailRow('Below Level:', (product.alertQuantity - product.totalStockQuantity).toString()),

              const SizedBox(height: 16),

              // Status Card
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        product.totalStockQuantity == 0
                            ? 'OUT OF STOCK - Immediate restock required!'
                            : 'LOW STOCK - Consider restocking soon',
                        style: TextStyle(
                          color: product.statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToRestock(context, product);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: product.statusColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Create Purchase Order'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AppImages.noData, width: 150, height: 150),
          const SizedBox(height: 16),
          Text(
            "No Low Stock Items",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "All products are well-stocked! 🎉",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchLowStockReport,
            icon: const Icon(Icons.refresh),
            label: const Text("Check Again"),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            "Error Loading Low Stock",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(fontSize: 14, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchLowStockReport,
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  void _showRestockAlert() {
    final state = context.read<LowStockBloc>().state;
    if (state is LowStockSuccess) {
      final products = state.response.report;
      final criticalItems = products.where((p) => p.totalStockQuantity == 0).length;
      final lowStockItems = products.length - criticalItems;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.notification_important, color: Colors.red),
              SizedBox(width: 8),
              Text('Restock Alert'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (criticalItems > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.dangerous, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$criticalItems Critical Items',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const Text('Completely out of stock'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (lowStockItems > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$lowStockItems Low Stock Items',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const Text('Below alert levels'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Consider creating purchase orders for these items.',
                style: TextStyle(fontStyle: FontStyle.italic),
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
                // TODO: Navigate to bulk purchase screen
              },
              child: const Text('Bulk Restock'),
            ),
          ],
        ),
      );
    }
  }

  void _generatePdf() {
    final state = context.read<LowStockBloc>().state;
    if (state is LowStockSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Low Stock PDF'),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            body: PdfPreview(
              build: (format) => generateLowStockReportPdf(state.response),
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No low stock data available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _navigateToRestock(BuildContext context, LowStockProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restock ${product.productName}'),
        content: Text(
          'Navigate to purchase screen to create a purchase order for this product?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to purchase screen with product data
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}