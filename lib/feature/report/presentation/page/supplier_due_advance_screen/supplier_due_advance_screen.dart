// lib/feature/report/presentation/screens/supplier_due_advance_screen.dart
import 'dart:async';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:printing/printing.dart';
import '../../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '/core/core.dart';
import '/core/widgets/date_range.dart';
import '/feature/report/presentation/page/supplier_due_advance_screen/pdf.dart';

import '../../../data/model/supplier_due_advance_report_model.dart';
import '../../bloc/supplier_due_advance_bloc/supplier_due_advance_bloc.dart';

class SupplierDueAdvanceScreen extends StatefulWidget {
  const SupplierDueAdvanceScreen({super.key});

  @override
  State<SupplierDueAdvanceScreen> createState() => _SupplierDueAdvanceScreenState();
}

class _SupplierDueAdvanceScreenState extends State<SupplierDueAdvanceScreen> {
  DateRange? selectedDateRange;
  Timer? _filterDebounceTimer;

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

  void _fetchWithDebounce({
    DateTime? from,
    DateTime? to,
  }) {
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
        onRefresh: () async => _fetchSupplierDueAdvanceReport(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildSummaryCards(),
              const SizedBox(height: 8),
              SizedBox(child: _buildSupplierTable()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Supplier Due & Advance Report",
                style: AppTextStyle.cardTitle(context).copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Monitor supplier balances and payment status",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

Spacer(),
        SizedBox(
          width: 260,
          child: CustomDateRangeField(
            isLabel: false,
            selectedDateRange: selectedDateRange,
            onDateRangeSelected: _onDateRangeSelected,
          ),
        ),
        const SizedBox(width: 12),

        AppButton(
            size: 100,
            name: "Clear", onPressed: (){
          setState(() => selectedDateRange = null);
          context.read<SupplierDueAdvanceBloc>().add(ClearSupplierDueAdvanceFilters());
          _fetchSupplierDueAdvanceReport();
        })

      ],
    );

  }


  Widget _buildSummaryCards() {
    return BlocBuilder<SupplierDueAdvanceBloc, SupplierDueAdvanceState>(
      builder: (context, state) {
        if (state is! SupplierDueAdvanceSuccess) {
          return Container(
            padding: const EdgeInsets.all(10),
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
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 48,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Supplier Balance Summary",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Apply date filters to view supplier due and advance summary",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade500,
                    ),
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
        final suppliersWithDue = suppliers.where((s) => s.presentDue > 0).length;
        final suppliersWithAdvance = suppliers.where((s) => s.presentAdvance > 0).length;
        final settledSuppliers = suppliers.where((s) => s.netBalance == 0).length;
        final totalActiveSuppliers = suppliers.length;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSummaryCard(
              "Total Suppliers",
              totalActiveSuppliers.toString(),
              Icons.business_center,
              AppColors.primaryColor(context),subtitle: ""
            ),
            _buildSummaryCard(
              "Total Due",
              summary.totalDueAmount.toStringAsFixed(2),
              Icons.money_off,
              Colors.red,
              subtitle: '$suppliersWithDue due',
            ),
            _buildSummaryCard(
              "Total Advance",
              summary.totalAdvanceAmount.toStringAsFixed(2),
              Icons.attach_money,
              Colors.green,
              subtitle: '$suppliersWithAdvance advance',
            ),
            _buildSummaryCard(
              "Net Balance",
              summary.netBalance.abs().toStringAsFixed(2),
              summary.netBalance >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
              summary.overallStatusColor,
              subtitle: summary.overallStatus,
            ),
            _buildSummaryCard(
              "Settled Suppliers",
              '$settledSuppliers/${suppliers.length}',
              Icons.check_circle,
              Colors.teal,
              subtitle: '${((settledSuppliers / suppliers.length) * 100).toStringAsFixed(1)}% settled',
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
                      build: (format) => generateSupplierDueAdvanceReportPdf(
                        state.response, context.read<ProfileBloc>().permissionModel?.data?.companyInfo

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

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
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
              color: color.withValues(alpha: 0.1),
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
                    fontSize: 14,
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
            return _buildEmptyState();
          }
          return SupplierDueAdvanceDataTable(suppliers: state.response.report);
        } else if (state is SupplierDueAdvanceFailed) {
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
            "No Supplier Data Found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Supplier due and advance data will appear here when available",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchSupplierDueAdvanceReport,
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
            "Error Loading Supplier Report",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
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
            onPressed: _fetchSupplierDueAdvanceReport,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

// Move this class outside the state class
class SupplierDueAdvanceDataTable extends StatelessWidget {
  final List<SupplierDueAdvance> suppliers;

  const SupplierDueAdvanceDataTable({super.key, required this.suppliers});

  @override
  Widget build(BuildContext context) {
    final totalDue = suppliers.fold(0.0, (sum, supplier) => sum + supplier.presentDue);
    final totalAdvance = suppliers.fold(0.0, (sum, supplier) => sum + supplier.presentAdvance);
    final netBalance = totalDue - totalAdvance;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [

            // Summary row
            _buildTableSummary(totalDue, totalAdvance, netBalance),
            const SizedBox(height: 8),
            // Data table
            SizedBox(
              child: _buildDataTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSummary(double totalDue, double totalAdvance, double netBalance) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _buildSummaryItem("Total Due", totalDue.toStringAsFixed(2), Colors.red),
          const SizedBox(width: 8),
          _buildSummaryItem("Total Advance", totalAdvance.toStringAsFixed(2), Colors.green),
          const SizedBox(width: 8),
          _buildSummaryItem(
              "Net Balance",
              netBalance.abs().toStringAsFixed(2),
              netBalance >= 0 ? Colors.red : Colors.green,
              subtitle: netBalance >= 0 ? 'Due' : 'Advance'
          ),
          const Spacer(),
          Text(
            'Total Suppliers: ${suppliers.length}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
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
    );
  }

  Widget _buildDataTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 8; // #, Name, Phone, Email, Due, Advance, Net Balance, Status
        const minColumnWidth = 100.0;

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

        return Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.resolveWith<Color>(
                      (states) => AppColors.primaryColor(context),
                ),
                columnSpacing: 12,
                dataRowMinHeight: 35,
                dataRowMaxHeight: 35,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 12,
                ),
                dataTextStyle: const TextStyle(
                  fontSize: 11,
                  color: Colors.black87,
                ),
                columns: [
                  DataColumn(
                    label: SizedBox(
                      width: dynamicColumnWidth * 0.6,
                      child: const Text(
                        '#',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: dynamicColumnWidth * 1.2,
                      child: const Text(
                        'Supplier Name',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: dynamicColumnWidth,
                      child: const Text(
                        'Phone',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: dynamicColumnWidth * 1.3,
                      child: const Text(
                        'Email',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: dynamicColumnWidth,
                      child: const Text(
                        'Due Amount',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: dynamicColumnWidth,
                      child: const Text(
                        'Advance Amount',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: dynamicColumnWidth,
                      child: const Text(
                        'Net Balance',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: dynamicColumnWidth,
                      child: const Text(
                        'Status',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
                rows: suppliers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final supplier = entry.value;

                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                        return index % 2 == 0 ? Colors.grey.withValues(alpha: 0.03) : Colors.transparent;
                      },
                    ),
                    cells: [
                      DataCell(
                        SizedBox(
                          width: dynamicColumnWidth * 0.6,
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dynamicColumnWidth * 1.2,
                          child: Tooltip(
                            message: supplier.supplierName,
                            child: Text(
                              supplier.supplierName,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dynamicColumnWidth,
                          child: Tooltip(
                            message: supplier.phone,
                            child: Text(
                              supplier.phone,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dynamicColumnWidth * 1.3,
                          child: Tooltip(
                            message: supplier.email,
                            child: Text(
                              supplier.email,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dynamicColumnWidth,
                          child: Center(
                            child: _buildAmountCell(
                              supplier.presentDue,
                              Colors.red,
                              'Due Amount',
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dynamicColumnWidth,
                          child: Center(
                            child: _buildAmountCell(
                              supplier.presentAdvance,
                              Colors.green,
                              'Advance Amount',
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dynamicColumnWidth,
                          child: Center(
                            child: _buildNetBalanceCell(supplier.netBalance),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dynamicColumnWidth,
                          child: Center(
                            child: _buildStatusCell(supplier),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountCell(double amount, Color color, String tooltip) {
    return Tooltip(
      message: '$tooltip: ${amount.toStringAsFixed(2)}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: amount > 0 ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: amount > 0 ? Border.all(color: color.withValues(alpha: 0.3)) : null,
        ),
        child: Text(
          amount > 0 ? amount.toStringAsFixed(2) : '-',
          style: TextStyle(
            color: amount > 0 ? color : Colors.grey,
            fontWeight: amount > 0 ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildNetBalanceCell(double netBalance) {
    final isDue = netBalance > 0;
    final isSettled = netBalance == 0;

    return Tooltip(
      message: isDue
          ? 'Due: ${netBalance.toStringAsFixed(2)}'
          : isSettled
          ? 'Settled'
          : 'Advance: ${netBalance.abs().toStringAsFixed(2)}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSettled
              ? Colors.green.withValues(alpha: 0.1)
              : (isDue ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSettled
                ? Colors.green.withValues(alpha: 0.3)
                : (isDue ? Colors.red.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.3)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSettled ? Icons.check : (isDue ? Icons.arrow_upward : Icons.arrow_downward),
              size: 12,
              color: isSettled ? Colors.green : (isDue ? Colors.red : Colors.green),
            ),
            const SizedBox(width: 4),
            Text(
              netBalance.abs().toStringAsFixed(2),
              style: TextStyle(
                color: isSettled ? Colors.green : (isDue ? Colors.red : Colors.green),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCell(SupplierDueAdvance supplier) {
    return Tooltip(
      message: '${supplier.balanceStatus}: ${supplier.netBalance.abs().toStringAsFixed(2)}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: supplier.balanceStatusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(supplier.balanceStatusIcon, size: 12, color: supplier.balanceStatusColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                supplier.balanceStatus,
                style: TextStyle(
                  color: supplier.balanceStatusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}