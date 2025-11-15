// lib/feature/report/presentation/screens/purchase_report_screen.dart
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:smart_inventory/core/core.dart';
import 'package:smart_inventory/core/widgets/date_range.dart';
import 'package:smart_inventory/feature/report/presentation/page/purchase_report_screen/pdf.dart';
import 'package:smart_inventory/feature/supplier/data/model/supplier_active_model.dart';
import 'package:smart_inventory/feature/supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';

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
              _buildSummaryCards(),
              const SizedBox(height: 8),
              SizedBox(child: _buildDataTable()),
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
        SizedBox(

       width: 220,
          child: BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
            builder: (context, state) {
              return AppDropdown<SupplierActiveModel>(
                label: "Supplier",
                context: context,
                isSearch: true,
                hint: "Select Supplier",
                isNeedAll: true,
                isRequired: false,
                isLabel: true,
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
        const SizedBox(width: 6),

        // 📅 Date Range Picker
        SizedBox(
          width: 260,
          child: CustomDateRangeField(
            isLabel: false,
            selectedDateRange: selectedDateRange,
            onDateRangeSelected: (value) {
              setState(() => selectedDateRange = value);
              if (value != null) {
                _fetchPurchaseReport(from: value.start, to: value.end);
              }
            },
          ),
        ),
        const SizedBox(width: 6),

        AppButton(name: "Clear", onPressed: (){
          setState(() => selectedDateRange = null);
          context.read<PurchaseReportBloc>().add(ClearPurchaseReportFilters());
          _fetchPurchaseReport();
        }),
        // Clear Filters Button

      ],
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<PurchaseReportBloc, PurchaseReportState>(
      builder: (context, state) {
        if (state is! PurchaseReportSuccess) return const SizedBox();

        final summary = state.response.summary;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
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
                      build: (format) => generatePurchaseReportPdf(
                        state.response,

                      ),
                      pdfPreviewPageDecoration:
                      BoxDecoration(color: AppColors.white),
                      actionBarTheme: PdfActionBarTheme(
                        backgroundColor: AppColors.primaryColor,
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

            })
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(8),
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
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 6),
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
            return _buildEmptyState();
          }
          return PurchaseReportTableCard(reports: state.response.report);
        } else if (state is PurchaseReportFailed) {
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
            "No Purchase Report Data Found",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Purchase report data will appear here when available",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchPurchaseReport,
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
            "Error Loading Purchase Report",
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
            onPressed: _fetchPurchaseReport,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

class PurchaseReportTableCard extends StatelessWidget {
  final List<PurchaseReportModel> reports;
  final VoidCallback? onReportTap;

  const PurchaseReportTableCard({
    super.key,
    required this.reports,
    this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 8; // Invoice No, Date, Supplier, Net Total, Paid, Due, Status, Actions
        const minColumnWidth = 120.0;

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
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
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          headingRowColor: MaterialStateProperty.all(
                            AppColors.primaryColor,
                          ),
                          dataTextStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: reports.asMap().entries.map((entry) {
                            final report = entry.value;
                            return DataRow(
                              onSelectChanged: onReportTap != null
                                  ? (_) => onReportTap!()
                                  : null,
                              cells: [
                                _buildDataCell(report.invoiceNo, dynamicColumnWidth),
                                _buildDateCell(report.purchaseDate, dynamicColumnWidth),
                                _buildDataCell(report.supplier, dynamicColumnWidth),
                                _buildAmountCell(report.netTotal, dynamicColumnWidth, isTotal: true),
                                _buildAmountCell(report.paidTotal, dynamicColumnWidth, isPaid: true),
                                _buildAmountCell(report.dueTotal, dynamicColumnWidth, isDue: true),
                                _buildStatusCell(report.paymentStatus, dynamicColumnWidth),
                                _buildActionCell(report, context, dynamicColumnWidth),
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
          width: columnWidth,
          child: const Text('Invoice No', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Date', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Supplier', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Net Total', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Paid', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Due', textAlign: TextAlign.center),
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
          child: const Text('Actions', textAlign: TextAlign.center),
        ),
      ),
    ];
  }

  DataCell _buildDataCell(String text, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  DataCell _buildDateCell(DateTime date, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          _formatDate(date),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  DataCell _buildAmountCell(double amount, double width, {bool isTotal = false, bool isPaid = false, bool isDue = false}) {
    Color getAmountColor() {
      if (isPaid) return Colors.green;
      if (isDue) return Colors.orange;
      if (isTotal) return Colors.blue;
      return Colors.grey;
    }

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getAmountColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: getAmountColor(),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildStatusCell(String status, double width) {
    final statusColor = _getStatusColor(status);

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
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

  DataCell _buildActionCell(PurchaseReportModel report, BuildContext context, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // View Button
            _buildActionButton(
              icon: HugeIcons.strokeRoundedView,
              color: Colors.green,
              tooltip: 'View purchase details',
              onPressed: () => _showViewDialog(context, report),
            ),

            // Print/Export Button
            _buildActionButton(
              icon: Iconsax.printer,
              color: Colors.blue,
              tooltip: 'Print report',
              onPressed: () => _printReport(context, report),
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
      icon: Icon(icon, size: 18, color: color),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'due':
      case 'overdue':
        return Colors.red;
      case 'partial':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showViewDialog(BuildContext context, PurchaseReportModel report) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: AppSizes.width(context) * 0.50,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Purchase Report Details - ${report.invoiceNo}',
                  style: AppTextStyle.cardLevelHead(context),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Invoice No:', report.invoiceNo),
                _buildDetailRow('Date:', _formatDate(report.purchaseDate)),
                _buildDetailRow('Supplier:', report.supplier),
                _buildDetailRow('Net Total:', '\$${report.netTotal.toStringAsFixed(2)}'),
                _buildDetailRow('Paid Amount:', '\$${report.paidTotal.toStringAsFixed(2)}'),
                _buildDetailRow('Due Amount:', '\$${report.dueTotal.toStringAsFixed(2)}'),
                _buildDetailRow('Status:', report.paymentStatus.toUpperCase()),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _printReport(BuildContext context, PurchaseReportModel report) {
    // Implement print/export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing report for ${report.invoiceNo}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
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
}