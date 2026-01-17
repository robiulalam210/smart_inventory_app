// lib/feature/report/presentation/page/low_stock_screen/mobile_low_stock_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:meherinMart/core/configs/app_text.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:printing/printing.dart';
import '../../../data/model/low_stock_model.dart';
import '/core/configs/app_colors.dart';
import '/core/configs/app_images.dart';
import '/feature/report/presentation/bloc/low_stock_bloc/low_stock_bloc.dart';
import '/feature/report/presentation/page/low_stock_screen/pdf/pdf.dart';

// === MODEL CLASSES ===



// === SCREEN ===
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
    return AppScaffold(
      appBar: AppBar(
        title:  Text('Low Stock Alert',style: AppTextStyle.titleMedium(context),),
        actions: [
          IconButton(
            icon:  Icon(Icons.picture_as_pdf,color: AppColors.text(context),),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon:  Icon(Icons.refresh,color:  AppColors.text(context),),
            onPressed: () => _fetchLowStockReport(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchLowStockReport(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderInfo(),
              const SizedBox(height: 4),
              _buildAlertCards(),
              const SizedBox(height: 8),
              _buildLowStockList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        
        onPressed: _showRestockAlert,
        icon: const Icon(Icons.notification_important),
        label: const Text('Restock Alert'),
        backgroundColor: AppColors.primaryColor(context),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.greyColor(context).withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber, color: Colors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Low Stock Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Monitor products that require immediate attention. Critical items are out of stock, while low stock items are below alert levels.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.text(context)
            ),
          ),
        ],
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
            if (criticalItems > 0)
              Card(
                elevation: 0,
                color: AppColors.bottomNavBg(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.9,
              children: [
                _buildMobileAlertCard('Total Items', summary.totalLowStockItems.toString(), Icons.inventory_2, AppColors.primaryColor(context)),
                _buildMobileAlertCard('Critical', criticalItems.toString(), Icons.dangerous, Colors.red),
                _buildMobileAlertCard('Low Stock', lowStockItems.toString(), Icons.warning, Colors.orange),
                _buildMobileAlertCard('Alert Level', '${summary.threshold}', Icons.settings, Colors.blue),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileAlertCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: AppColors.bottomNavBg(context),
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
                  child: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockList() {
    return BlocBuilder<LowStockBloc, LowStockState>(
      builder: (context, state) {
        if (state is LowStockLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is LowStockSuccess) {
          if (state.response.report.isEmpty) return _buildEmptyState();
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
        return Card(


          margin: const EdgeInsets.only(bottom: 8),
          color: product.totalStockQuantity == 0 ? Colors.red.withValues(alpha: 0.05) : Colors.orange.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: product.statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(product.totalStockQuantity == 0 ? Icons.dangerous : Icons.warning, color: product.statusColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.productName, style:AppTextStyle.body(context), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildTag(product.category,context),
                              const SizedBox(width: 4),
                              _buildTag(product.brand,context),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStockDetailItem('Current Stock', product.totalStockQuantity.toString(), Colors.pink),
                    _buildStockDetailItem('Alert Level', product.alertQuantity.toString(), Colors.blue),
                    _buildStockDetailItem('Below By', product.belowAlertLevel.toString(), Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTag(String text,BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
    child: Text(text, style:  TextStyle(fontSize: 10, color: AppColors.blackColor(context))),
  );

  Widget _buildStockDetailItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style:  TextStyle(fontSize: 10, color: AppColors.text(context))),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AppImages.noData, width: 150, height: 150),
          const SizedBox(height: 16),
          Text("No Low Stock Items", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green)),
          const SizedBox(height: 8),
          Text("All products are well-stocked! 🎉", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: _fetchLowStockReport, icon: const Icon(Icons.refresh), label: const Text("Check Again")),
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
          Text("Error Loading Low Stock", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(error, style: const TextStyle(fontSize: 14, color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchLowStockReport, child: const Text("Try Again")),
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
            children: [Icon(Icons.notification_important, color: Colors.red), SizedBox(width: 8), Text('Restock Alert')],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (criticalItems > 0)
                Text('$criticalItems Critical Items - Immediate restock required!', style: const TextStyle(color: Colors.red)),
              if (lowStockItems > 0)
                Text('$lowStockItems Low Stock Items - Below alert levels', style: const TextStyle(color: Colors.orange)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
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
              actions: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))],
            ),
            body: PdfPreview(build: (format) => generateLowStockReportPdf(state.response)),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No low stock data available')));
    }
  }
}
