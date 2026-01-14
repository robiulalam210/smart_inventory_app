// lib/feature/report/presentation/screens/low_stock_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';
import '/core/configs/app_colors.dart';
import '/core/configs/app_images.dart';
import '/core/configs/app_text.dart';
import '/core/shared/widgets/sideMenu/sidebar.dart';
import '/core/widgets/app_alert_dialog.dart';
import '/feature/report/presentation/bloc/low_stock_bloc/low_stock_bloc.dart';
import '/feature/report/presentation/page/low_stock_screen/pdf/pdf.dart';

import '../../../../../core/configs/app_routes.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../responsive.dart';
import '../../../data/model/low_stock_model.dart';

class MobileLowStockScreen extends StatefulWidget {
  const MobileLowStockScreen({super.key});

  @override
  State<MobileLowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<MobileLowStockScreen> {
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
      color: AppColors.bottomNavBg(context),
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
              SizedBox(child: _buildLowStockTable()),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Low Stock Alert",
              style: AppTextStyle.cardTitle(context).copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Monitor and manage products requiring restocking",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _fetchLowStockReport,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor(context),
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
          spacing: 12,
          runSpacing: 12,
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
            AppButton(
                size: 100,
                name: "Pdf", onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    backgroundColor: Colors.red,
                    body: PdfPreview.builder(
                      useActions: true,
                      allowSharing: false,
                      canDebug: false,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      dynamicLayout: true,
                      build: (format) => generateLowStockReportPdf(
                        state.response,

                      ),
                      pdfPreviewPageDecoration:
                      BoxDecoration(color: AppColors.white),
                      actionBarTheme: PdfActionBarTheme(
                        backgroundColor: AppColors.primaryColor(context),
                        iconColor: Colors.white,
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () => AppRoutes.pop(context),
                          icon: const Icon(Icons.cancel, color: Colors.red),
                        ),
                      ],
                      pagesBuilder: (context, pages) {
                        debugPrint('Rendering ${pages.length} pages');
                        return PageView.builder(
                          itemCount: pages.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            final page = pages[index];
                            return Container(
                              color: Colors.grey,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8.0),
                              child: Image(image: page.image, fit: BoxFit.contain),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              );

            }),
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
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
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
            return _buildEmptyState();
          }
          return LowStockTableCard(products: state.response.report);
        } else if (state is LowStockFailed) {
          return _buildErrorState(state.content);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AppImages.noData, width: 200, height: 200),
          const SizedBox(height: 16),
          Text(
            "No Low Stock Items Found",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Great job! All products are well-stocked",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchLowStockReport,
            child: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            "Error Loading Low Stock Report",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
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
            child: const Text("Retry"),
          ),
        ],
      ),
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
        color: color.withValues(alpha: 0.1),
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

}

class LowStockTableCard extends StatelessWidget {
  final List<LowStockProduct> products;
  final VoidCallback? onProductTap;

  const LowStockTableCard({
    super.key,
    required this.products,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 9; // #, Product Name, Category, Brand, Current Stock, Alert Level, Status, Below Level, Actions
        const minColumnWidth = 120.0;

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Scrollbar(
            controller: verticalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: verticalScrollController,
              scrollDirection: Axis.vertical,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Scrollbar(
                  controller: horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: totalWidth),
                        child: DataTable(
                          dataRowMinHeight: 40,
                          dataRowMaxHeight: 40,
                          columnSpacing: 8,
                          horizontalMargin: 12,
                          dividerThickness: 0.5,
                          headingRowHeight: 40,
                          headingTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          headingRowColor: WidgetStateProperty.all(
                            Colors.red, // Red header for low stock alert
                          ),
                          dataTextStyle: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: products.asMap().entries.map((entry) {
                            final product = entry.value;
                            return DataRow(
                              onSelectChanged: onProductTap != null
                                  ? (_) => onProductTap!()
                                  : null,
                              cells: [
                                _buildIndexCell(entry.key + 1, dynamicColumnWidth * 0.6),
                                _buildProductNameCell(product, dynamicColumnWidth),
                                _buildCategoryCell(product.category, dynamicColumnWidth),
                                _buildBrandCell(product.brand, dynamicColumnWidth),
                                _buildStockCell(product, dynamicColumnWidth),
                                _buildAlertLevelCell(product.alertQuantity, dynamicColumnWidth),
                                _buildStatusCell(product, dynamicColumnWidth),
                                _buildBelowLevelCell(product, dynamicColumnWidth),
                                _buildActionCell(product, context, dynamicColumnWidth),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildColumns(double columnWidth) {
    return [
      DataColumn(
        label: SizedBox(
          width: columnWidth * 0.6,
          child: const Text('#', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Product Name', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Category', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Brand', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Current Stock', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Alert Level', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Status', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Below Level', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Actions', textAlign: TextAlign.center),
        ),
      ),
    ];
  }

  DataCell _buildIndexCell(int index, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Text(
            index.toString(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildProductNameCell(LowStockProduct product, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Tooltip(
          message: product.productName,
          child: Text(
            product.productName,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ),
    );
  }

  DataCell _buildCategoryCell(String category, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          category,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  DataCell _buildBrandCell(String brand, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          brand,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  DataCell _buildStockCell(LowStockProduct product, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: product.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: product.statusColor),
            ),
            child: Text(
              product.totalStockQuantity.toString(),
              style: TextStyle(
                color: product.statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildAlertLevelCell(int alertQuantity, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              alertQuantity.toString(),
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildStatusCell(LowStockProduct product, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: product.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              product.stockStatus,
              style: TextStyle(
                color: product.statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildBelowLevelCell(LowStockProduct product, double width) {
    final belowLevel = product.alertQuantity - product.totalStockQuantity;

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              belowLevel > 0 ? belowLevel.toString() : '0',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildActionCell(LowStockProduct product, BuildContext context, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // View Details Button
            _buildActionButton(
              icon: HugeIcons.strokeRoundedView,
              color: Colors.blue,
              tooltip: 'View product details',
              onPressed: () => _showProductDetails(context, product),
            ),

            // Restock Button
            _buildActionButton(
              icon: Iconsax.shopping_cart,
              color: product.totalStockQuantity == 0 ? Colors.red : Colors.orange,
              tooltip: 'Create purchase order',
              onPressed: () => _navigateToRestock(context, product),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 25, minHeight: 25),
    );
  }

  void _showProductDetails(BuildContext context, LowStockProduct product) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.40,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: AppTextStyle.cardLevelHead(context).copyWith(color: Colors.red),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Category:', product.category),
                _buildDetailRow('Brand:', product.brand),
                _buildDetailRow('Selling Price:', product.sellingPrice.toStringAsFixed(2)),
                _buildDetailRow('Current Stock:', product.totalStockQuantity.toString()),
                _buildDetailRow('Alert Level:', product.alertQuantity.toString()),
                _buildDetailRow('Total Sold:', product.totalSoldQuantity.toString()),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: product.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: product.statusColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: product.statusColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          product.totalStockQuantity == 0
                              ? '🚨 OUT OF STOCK - Immediate restock required!'
                              : '⚠️ LOW STOCK - ${product.belowAlertLevel} units below alert level',
                          style: TextStyle(
                            color: product.statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToRestock(context, product);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Create Purchase Order'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRestock(BuildContext context, LowStockProduct product) {
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
}