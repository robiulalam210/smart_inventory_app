// lib/feature/report/presentation/screens/purchase_report_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_inventory/core/configs/app_colors.dart';
import 'package:smart_inventory/core/configs/app_images.dart';
import 'package:smart_inventory/core/configs/app_text.dart';
import 'package:smart_inventory/core/shared/widgets/sideMenu/sidebar.dart';
import 'package:smart_inventory/core/widgets/app_dropdown.dart';
import 'package:smart_inventory/core/widgets/date_range.dart';
import 'package:smart_inventory/feature/supplier/data/model/supplier_active_model.dart';
import 'package:smart_inventory/feature/supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';

import '../../../../../responsive.dart';
import '../../../data/model/purchase_report_model.dart';
import '../../bloc/purchase_report/purchase_report_bloc.dart';

class PurchaseReportScreen extends StatefulWidget {
  const PurchaseReportScreen({super.key});

  @override
  State<PurchaseReportScreen> createState() => _PurchaseReportScreenState();
}

class _PurchaseReportScreenState extends State<PurchaseReportScreen> {
  TextEditingController filterTextController = TextEditingController();
  DateRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    filterTextController.clear();
    context.read<SupplierInvoiceBloc>().add(FetchSupplierActiveList(context));
    _fetchPurchaseReport();
  }

  void _fetchPurchaseReport({
    String supplier = '',
    DateTime? from,
    DateTime? to,
  }) {
    context.read<PurchaseReportBloc>().add(FetchPurchaseReport(
      context: context,
      supplier: supplier,
      from: from,
      to: to,
    ));
  }

  @override
  void dispose() {
    filterTextController.dispose();
    super.dispose();
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
        onRefresh: () async => _fetchPurchaseReport(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            children: [
              _buildFilterRow(),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 16),
              _buildDataTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 👤 Supplier Dropdown
        Expanded(
          flex: 1,
          child: BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
            builder: (context, state) {
              return AppDropdown<SupplierActiveModel>(
                label: "Supplier",
                context: context,
                isSearch: true,
                hint: "Select Supplier",
                isNeedAll: true,
                isRequired: false,
                value: context.read<PurchaseReportBloc>().selectedSupplier,
                itemList: context.read<SupplierInvoiceBloc>().supplierActiveList,
                onChanged: (newVal) {
                  _fetchPurchaseReport(
                    from: selectedDateRange?.start,
                    to: selectedDateRange?.end,
                    supplier: newVal?.id.toString() ?? '',
                  );
                },
                itemBuilder: (item) => DropdownMenuItem<SupplierActiveModel>(
                  value: item,
                  child: Text(
                    item.name ?? 'Unknown Supplier',
                    style: const TextStyle(
                      color: AppColors.blackColor,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 5),

        // 📅 Date Range Picker
        SizedBox(
          width: 260,
          child: CustomDateRangeField(
            selectedDateRange: selectedDateRange,
            onDateRangeSelected: (value) {
              setState(() => selectedDateRange = value);
              if (value != null) {
                _fetchPurchaseReport(from: value.start, to: value.end);
              }
            },
          ),
        ),
        const SizedBox(width: 5),

        // Clear Filters Button
        ElevatedButton.icon(
          onPressed: () {
            setState(() => selectedDateRange = null);
            context.read<PurchaseReportBloc>().add(ClearPurchaseReportFilters());
            _fetchPurchaseReport();
          },
          icon: const Icon(Icons.clear_all),
          label: const Text("Clear"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.grey,
            foregroundColor: AppColors.blackColor,
          ),
        ),
        const SizedBox(width: 5),

        IconButton(
          onPressed: () => _fetchPurchaseReport(),
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<PurchaseReportBloc, PurchaseReportState>(
      builder: (context, state) {
        if (state is! PurchaseReportSuccess) return const SizedBox();

        final summary = state.response.summary;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildSummaryCard(
              "Total Purchases",
              "\$${summary.totalPurchases.toStringAsFixed(2)}",
              Icons.shopping_cart,
              AppColors.primaryColor,
            ),
            _buildSummaryCard(
              "Total Paid",
              "\$${summary.totalPaid.toStringAsFixed(2)}",
              Icons.payment,
              Colors.green,
            ),
            _buildSummaryCard(
              "Total Due",
              "\$${summary.totalDue.toStringAsFixed(2)}",
              Icons.money_off,
              Colors.orange,
            ),
            _buildSummaryCard(
              "Transactions",
              summary.totalTransactions.toString(),
              Icons.receipt,
              Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 200,
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
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Column(
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return BlocBuilder<PurchaseReportBloc, PurchaseReportState>(
      builder: (context, state) {
        if (state is PurchaseReportLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading purchase report..."),
              ],
            ),
          );
        } else if (state is PurchaseReportSuccess) {
          if (state.response.report.isEmpty) {
            return _noDataWidget("No purchase report data found");
          }
          return PurchaseReportDataTableWidget(reports: state.response.report);
        } else if (state is PurchaseReportFailed) {
          return _errorWidget(state.content);
        }
        return _noDataWidget("No data available");
      },
    );
  }

  Widget PurchaseReportDataTableWidget({required List<PurchaseReportModel> reports}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Invoice No')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Supplier')),
          DataColumn(label: Text('Net Total')),
          DataColumn(label: Text('Paid')),
          DataColumn(label: Text('Due')),
          DataColumn(label: Text('Status')),
        ],
        rows: reports.map((report) => DataRow(cells: [
          DataCell(Text(report.invoiceNo)),
          DataCell(Text(report.purchaseDate.toString().split(' ')[0])),
          DataCell(Text(report.supplier)),
          DataCell(Text('\$${report.netTotal.toStringAsFixed(2)}')),
          DataCell(Text('\$${report.paidTotal.toStringAsFixed(2)}')),
          DataCell(Text('\$${report.dueTotal.toStringAsFixed(2)}')),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: report.paymentStatus == 'paid' ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                report.paymentStatus.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ])).toList(),
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
            onPressed: _fetchPurchaseReport,
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
            onPressed: _fetchPurchaseReport,
            child: const Text("Retry")
        ),
      ],
    ),
  );
}