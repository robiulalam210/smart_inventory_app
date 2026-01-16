import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:printing/printing.dart';
import '/core/configs/app_colors.dart';
import '/core/configs/app_images.dart';
import '/core/configs/app_text.dart';
import '/core/widgets/app_button.dart';
import '/core/widgets/date_range.dart';
import '/feature/report/presentation/page/supplier_due_advance_screen/pdf.dart';

import '../../../../../core/configs/app_routes.dart';
import '../../../../../responsive.dart';
import '../../../data/model/supplier_due_advance_report_model.dart';
import '../../bloc/supplier_due_advance_bloc/supplier_due_advance_bloc.dart';

class MobileSupplierDueAdvanceScreen extends StatefulWidget {
  const MobileSupplierDueAdvanceScreen({super.key});

  @override
  State<MobileSupplierDueAdvanceScreen> createState() =>
      _MobileSupplierDueAdvanceScreenState();
}

class _MobileSupplierDueAdvanceScreenState
    extends State<MobileSupplierDueAdvanceScreen> {
  DateRange? selectedDateRange;
  Timer? _filterDebounceTimer;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchSupplierDueAdvanceReport();
  }

  void _fetchSupplierDueAdvanceReport({DateTime? from, DateTime? to}) {
    context.read<SupplierDueAdvanceBloc>().add(
      FetchSupplierDueAdvanceReport(context: context, from: from, to: to),
    );
  }

  void _fetchWithDebounce({DateTime? from, DateTime? to}) {
    _filterDebounceTimer?.cancel();
    _filterDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchSupplierDueAdvanceReport(from: from, to: to);
    });
  }

  void _onDateRangeSelected(DateRange? value) {
    setState(() => selectedDateRange = value);

    if (value != null && value.start.isAfter(value.end)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before start date')),
      );
      return;
    }

    _fetchWithDebounce(from: value?.start, to: value?.end);
  }

  @override
  void dispose() {
    _filterDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Supplier Due & Advance',
          style: AppTextStyle.titleMedium(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf, color: AppColors.text(context)),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.text(context)),
            onPressed: () => _fetchSupplierDueAdvanceReport(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchSupplierDueAdvanceReport(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter Section
              CustomDateRangeField(
                isLabel: true,
                selectedDateRange: selectedDateRange,
                onDateRangeSelected: _onDateRangeSelected,
              ),
              const SizedBox(height: 8),

              // Summary Cards
              _buildSummaryCards(),
              const SizedBox(height: 8),

              // Supplier List
              _buildSupplierList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<SupplierDueAdvanceBloc, SupplierDueAdvanceState>(
      builder: (context, state) {
        if (state is! SupplierDueAdvanceSuccess) {
          return Card(
            elevation: 0,
            color: AppColors.primaryColor(context),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 60,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Supplier Balance Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Apply date filters to view supplier balances",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final summary = state.response.summary;
        final suppliers = state.response.report;

        // Calculate additional metrics
        final suppliersWithDue = suppliers
            .where((s) => s.presentDue > 0)
            .length;
        final suppliersWithAdvance = suppliers
            .where((s) => s.presentAdvance > 0)
            .length;
        final settledSuppliers = suppliers
            .where((s) => s.netBalance == 0)
            .length;
        final totalActiveSuppliers = suppliers.length;

        return Column(
          children: [
            // First row
            Row(
              children: [
                _buildMobileSummaryCard(
                  "Total Suppliers",
                  totalActiveSuppliers.toString(),
                  Icons.business_center,
                  AppColors.primaryColor(context),
                ),
                const SizedBox(width: 8),
                _buildMobileSummaryCard(
                  "Net Balance",
                  '\$${summary.netBalance.abs().toStringAsFixed(2)}',
                  summary.netBalance >= 0
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  summary.overallStatusColor,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Second row
            Row(
              children: [
                _buildMobileSummaryCard(
                  "Total Due",
                  '\$${summary.totalDueAmount.toStringAsFixed(2)}',
                  Icons.money_off,
                  Colors.red,
                ),
                const SizedBox(width: 8),
                _buildMobileSummaryCard(
                  "Total Advance",
                  '\$${summary.totalAdvanceAmount.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Third row (counts)
            Row(
              children: [
                if (suppliersWithDue > 0)
                  Expanded(
                    child: _buildMobileSummaryCard(
                      "With Due",
                      suppliersWithDue.toString(),
                      Icons.warning,
                      Colors.orange,
                    ),
                  ),
                if (suppliersWithDue > 0) const SizedBox(width: 8),
                if (suppliersWithAdvance > 0)
                  Expanded(
                    child: _buildMobileSummaryCard(
                      "With Advance",
                      suppliersWithAdvance.toString(),
                      Icons.thumb_up,
                      Colors.blue,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.bottomNavBg(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.greyColor(context).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.text(context),

                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierList() {
    return BlocBuilder<SupplierDueAdvanceBloc, SupplierDueAdvanceState>(
      builder: (context, state) {
        if (state is SupplierDueAdvanceLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading supplier data..."),
              ],
            ),
          );
        } else if (state is SupplierDueAdvanceSuccess) {
          if (state.response.report.isEmpty) {
            return _buildEmptyState();
          }
          return _buildMobileSupplierList(state.response.report);
        } else if (state is SupplierDueAdvanceFailed) {
          return _buildErrorState(state.content);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildMobileSupplierList(List<SupplierDueAdvance> suppliers) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        final hasDue = supplier.presentDue > 0;
        final hasAdvance = supplier.presentAdvance > 0;
        final netBalanceText = supplier.netBalance >= 0
            ? '\$${supplier.netBalance.toStringAsFixed(2)}'
            : '-\$${supplier.netBalance.abs().toStringAsFixed(2)}';

        return Card(
          elevation: 0,
          color: AppColors.bottomNavBg(context),
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Supplier Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: supplier.balanceStatusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        supplier.balanceStatusIcon,
                        color: supplier.balanceStatusColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            supplier.supplierName,
                            style:  TextStyle(
                              fontSize: 16,
                              color: AppColors.text(context),
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (supplier.phone.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    supplier.phone,
                                    style:  TextStyle(fontSize: 10,
                                      color: AppColors.text(context),

                                    ),
                                  ),
                                ),
                              if (supplier.phone.isNotEmpty &&
                                  supplier.email.isNotEmpty)
                                const SizedBox(width: 4),
                              if (supplier.email.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    supplier.email,
                                    style:  TextStyle(fontSize: 10,
                                      color: AppColors.text(context),

                                    ),
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

                // Amount Cards
                Row(
                  children: [
                    if (hasDue)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'DUE',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                ),
                              ),
                              Text(
                                '\$${supplier.presentDue.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (hasDue) const SizedBox(width: 8),
                    if (hasAdvance)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'ADVANCE',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                '\$${supplier.presentAdvance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // Net Balance
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: supplier.balanceStatusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: supplier.balanceStatusColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NET BALANCE',
                        style: TextStyle(
                          fontSize: 12,
                          color: supplier.balanceStatusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        netBalanceText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: supplier.balanceStatusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: supplier.balanceStatusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        supplier.balanceStatusIcon,
                        size: 14,
                        color: supplier.balanceStatusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        supplier.balanceStatus.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: supplier.balanceStatusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Action Buttons
                Row(
                  children: [
                    SizedBox(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showSupplierDetails(context, supplier),
                        icon: const Icon(Icons.remove_red_eye, size: 16),
                        label: const Text(''),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 0),
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AppImages.noData, width: 150, height: 150),
          const SizedBox(height: 16),
          Text(
            "No Supplier Data Found",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Supplier due and advance data will appear here when available",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchSupplierDueAdvanceReport,
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
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
            "Error Loading Supplier Data",
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
          ElevatedButton.icon(
            onPressed: _fetchSupplierDueAdvanceReport,
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  void _showSupplierDetails(BuildContext context, SupplierDueAdvance supplier) {
    final netBalanceText = supplier.netBalance >= 0
        ? '\$${supplier.netBalance.toStringAsFixed(2)}'
        : '-\$${supplier.netBalance.abs().toStringAsFixed(2)}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration:  BoxDecoration(
            color: AppColors.bottomNavBg(context),
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
                  Text(
                    supplier.supplierName,
                    style:  TextStyle(
                      fontSize: 18,
                      color: AppColors.primaryColor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 4),

              // Supplier Details
              _buildMobileDetailRow('Phone:', supplier.phone),
              _buildMobileDetailRow('Email:', supplier.email),
              _buildMobileDetailRow(
                'Due Amount:',
                '\$${supplier.presentDue.toStringAsFixed(2)}',
              ),
              _buildMobileDetailRow(
                'Advance Amount:',
                '\$${supplier.presentAdvance.toStringAsFixed(2)}',
              ),
              _buildMobileDetailRow('Net Balance:', netBalanceText),
              _buildMobileDetailRow('Status:', supplier.balanceStatus),

              // Status Card
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: supplier.balanceStatusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: supplier.balanceStatusColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      supplier.balanceStatusIcon,
                      color: supplier.balanceStatusColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Balance Status: ${supplier.balanceStatus}',
                        style: TextStyle(
                          color: supplier.balanceStatusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

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
              style:  TextStyle(
                fontSize: 14,
                color: AppColors.text(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style:  TextStyle(fontSize: 14,

                  color: AppColors.text(context),

                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }



  void _generatePdf() {
    final state = context.read<SupplierDueAdvanceBloc>().state;
    if (state is SupplierDueAdvanceSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Supplier Due & Advance PDF'),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            body: PdfPreview(
              build: (format) =>
                  generateSupplierDueAdvanceReportPdf(state.response),
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
          content: Text('No supplier data available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
