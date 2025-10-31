// lib/feature/report/presentation/screens/supplier_due_advance_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_inventory/core/configs/app_colors.dart';
import 'package:smart_inventory/core/configs/app_images.dart';
import 'package:smart_inventory/core/configs/app_text.dart';
import 'package:smart_inventory/core/shared/widgets/sideMenu/sidebar.dart';
import 'package:smart_inventory/core/widgets/date_range.dart';

import '../../../../../responsive.dart';
import '../../../data/model/supplier_due_advance_report_model.dart';
import '../../bloc/supplier_due_advance_bloc/supplier_due_advance_bloc.dart';

class SupplierDueAdvanceScreen extends StatefulWidget {
  const SupplierDueAdvanceScreen({super.key});

  @override
  State<SupplierDueAdvanceScreen> createState() => _SupplierDueAdvanceScreenState();
}

class _SupplierDueAdvanceScreenState extends State<SupplierDueAdvanceScreen> {
  DateRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    _fetchSupplierDueAdvanceReport();
  }

  void _fetchSupplierDueAdvanceReport({
    DateTime? from,
    DateTime? to,
  }) {
    context.read<SupplierDueAdvanceBloc>().add(FetchSupplierDueAdvanceReport(
      context: context,
      from: from,
      to: to,
    ));
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
        onRefresh: () async => _fetchSupplierDueAdvanceReport(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildFilterRow(),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 16),
              _buildSupplierTable(),
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
          "Supplier Due & Advance Report",
          style: AppTextStyle.cardTitle(context).copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => _fetchSupplierDueAdvanceReport(),
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 📅 Date Range Picker
        SizedBox(
          width: 260,
          child: CustomDateRangeField(
            selectedDateRange: selectedDateRange,
            onDateRangeSelected: (value) {
              setState(() => selectedDateRange = value);
              if (value != null) {
                _fetchSupplierDueAdvanceReport(from: value.start, to: value.end);
              }
            },
          ),
        ),
        const SizedBox(width: 5),

        // Clear Filters Button
        ElevatedButton.icon(
          onPressed: () {
            setState(() => selectedDateRange = null);
            context.read<SupplierDueAdvanceBloc>().add(ClearSupplierDueAdvanceFilters());
            _fetchSupplierDueAdvanceReport();
          },
          icon: const Icon(Icons.clear_all),
          label: const Text("Clear"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.grey,
            foregroundColor: AppColors.blackColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<SupplierDueAdvanceBloc, SupplierDueAdvanceState>(
      builder: (context, state) {
        if (state is! SupplierDueAdvanceSuccess) return const SizedBox();

        final summary = state.response.summary;
        final suppliers = state.response.report;

        // Calculate additional metrics
        final suppliersWithDue = suppliers.where((s) => s.presentDue > 0).length;
        final suppliersWithAdvance = suppliers.where((s) => s.presentAdvance > 0).length;
        final settledSuppliers = suppliers.where((s) => s.netBalance == 0).length;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildSummaryCard(
              "Total Suppliers",
              summary.totalSuppliers.toString(),
              Icons.business_center,
              AppColors.primaryColor,
            ),
            _buildSummaryCard(
              "Total Due Amount",
              "\$${summary.totalDueAmount.toStringAsFixed(2)}",
              Icons.money_off,
              Colors.red,
            ),
            _buildSummaryCard(
              "Total Advance Amount",
              "\$${summary.totalAdvanceAmount.toStringAsFixed(2)}",
              Icons.attach_money,
              Colors.green,
            ),
            _buildSummaryCard(
              "Net Balance",
              "\$${summary.netBalance.abs().toStringAsFixed(2)}",
              summary.netBalance >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
              summary.overallStatusColor,
              subtitle: summary.overallStatus,
            ),
            _buildSummaryCard(
              "Suppliers with Due",
              suppliersWithDue.toString(),
              Icons.warning,
              Colors.orange,
            ),
            _buildSummaryCard(
              "Suppliers with Advance",
              suppliersWithAdvance.toString(),
              Icons.thumb_up,
              Colors.blue,
            ),
            _buildSummaryCard(
              "Settled Suppliers",
              settledSuppliers.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      width: 220,
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
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
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
                if (subtitle != null)
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

  Widget _buildSupplierTable() {
    return BlocBuilder<SupplierDueAdvanceBloc, SupplierDueAdvanceState>(
      builder: (context, state) {
        if (state is SupplierDueAdvanceLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading supplier due & advance report..."),
              ],
            ),
          );
        } else if (state is SupplierDueAdvanceSuccess) {
          if (state.response.report.isEmpty) {
            return _noDataWidget("No supplier due & advance data found");
          }
          return SupplierDueAdvanceDataTableWidget(suppliers: state.response.report);
        } else if (state is SupplierDueAdvanceFailed) {
          return _errorWidget(state.content);
        }
        return _noDataWidget("No data available");
      },
    );
  }

  Widget SupplierDueAdvanceDataTableWidget({required List<SupplierDueAdvance> suppliers}) {
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
                (Set<MaterialState> states) => AppColors.primaryColor.withOpacity(0.1),
          ),
          columns: const [
            DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Supplier Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Due Amount', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('Advance Amount', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('Net Balance', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: suppliers.asMap().entries.map((entry) {
            final index = entry.key;
            final supplier = entry.value;

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
                    supplier.supplierName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(Text(supplier.phone)),
                DataCell(Text(supplier.email)),
                DataCell(
                  supplier.presentDue > 0
                      ? Text(
                    '\$${supplier.presentDue.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  )
                      : const Text('-'),
                ),
                DataCell(
                  supplier.presentAdvance > 0
                      ? Text(
                    '\$${supplier.presentAdvance.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  )
                      : const Text('-'),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: supplier.balanceStatusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: supplier.balanceStatusColor),
                    ),
                    child: Text(
                      '\$${supplier.netBalance.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        color: supplier.balanceStatusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: supplier.balanceStatusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(supplier.balanceStatusIcon, size: 14, color: supplier.balanceStatusColor),
                        const SizedBox(width: 4),
                        Text(
                          supplier.balanceStatus,
                          style: TextStyle(
                            color: supplier.balanceStatusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _noDataWidget(String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(AppImages.noData, width: 200, height: 200),
        const SizedBox(height: 12),
        Text(message),
        const SizedBox(height: 8),
        ElevatedButton(
            onPressed: _fetchSupplierDueAdvanceReport,
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
            onPressed: _fetchSupplierDueAdvanceReport,
            child: const Text("Retry")
        ),
      ],
    ),
  );
}