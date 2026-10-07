import 'package:meherinMart/desktop/widgets/sidebar.dart';
// lib/feature/report/presentation/screens/purchase_report_screen.dart
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import '../../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '/core/core.dart';
import '/core/widgets/date_range.dart';
import '/feature/report/presentation/shared/purchase_report_screen/pdf.dart';
import '/feature/supplier/data/model/supplier_active_model.dart';
import '/feature/supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';

import '../../../data/model/purchase_report_model.dart';
import '../../bloc/purchase_report/purchase_report_bloc.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

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
    context.read<PurchaseReportBloc>().add(
      FetchPurchaseReport(
        context: context,
        supplier: supplier,
        from: from,
        to: to,
      ),
    );
  }

  @override
  void dispose() {
    filterTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

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
        onRefresh: () async => _fetchPurchaseReport(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            children: [
              _buildSummaryCards(),
              const SizedBox(height: 8),
              SizedBox(child: _buildDataTable()),
            ],
          ),
        ),
      ),
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
            // 👤 Supplier Dropdown
            SizedBox(
              width: 180,
              child: BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
                builder: (context, state) {
                  return AppDropdown<SupplierActiveModel>(
                    label: "Supplier",
                    isSearch: true,
                    hint: "Select Supplier",
                    isNeedAll: true,
                    isRequired: false,
                    isLabel: false,
                    value: context.read<PurchaseReportBloc>().selectedSupplier,
                    itemList: context
                        .read<SupplierInvoiceBloc>()
                        .supplierActiveList,
                    onChanged: (newVal) {
                      setState(() {

                      });
                      context.read<PurchaseReportBloc>().selectedSupplier=newVal;
                      _fetchPurchaseReport(
                        from: selectedDateRange?.start,
                        to: selectedDateRange?.end,
                        supplier: newVal?.id.toString() ?? '',
                      );
                    },
                  );
                },
              ),
            ),

            // 📅 Date Range Picker
            SizedBox(
              width: 250,
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


            _buildSummaryCard(
              "Total Purchases",
              summary.totalPurchases.toStringAsFixed(2),
              Icons.shopping_cart,
              AppColors.primaryColor(context),
            ),
            _buildSummaryCard(
              "Total Paid",
              summary.totalPaid.toStringAsFixed(2),
              Icons.payment,
              AppColors.success,
            ),
            _buildSummaryCard(
              "Total Due",
              summary.totalDue.toStringAsFixed(2),
              Icons.money_off,
              AppColors.warning,
            ),
            _buildSummaryCard(
              "Transactions",
              summary.totalTransactions.toString(),
              Icons.receipt,
              Colors.purple,
            ),
            AppButton(
              name: "Clear",
              size: 100,
              onPressed: () {
                setState(() => selectedDateRange = null);
                context.read<PurchaseReportBloc>().add(
                  ClearPurchaseReportFilters(),
                );
                _fetchPurchaseReport();
              },
            ),
            AppButton(
              size: 100,
              name: "Pdf",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      backgroundColor: AppColors.danger,
                      body: PdfPreview.builder(
                        useActions: true,
                        allowSharing: false,
                        canDebug: false,
                        canChangeOrientation: false,
                        canChangePageFormat: false,
                        dynamicLayout: true,
                        build: (format) =>
                            generatePurchaseReportPdf(state.response, context.read<ProfileBloc>().permissionModel?.data?.companyInfo),
                        pdfPreviewPageDecoration: BoxDecoration(
                          color: AppColors.white,
                        ),
                        actionBarTheme: PdfActionBarTheme(
                          backgroundColor: AppColors.primaryColor(context),
                          iconColor: Colors.white,
                          textStyle: const TextStyle(color: Colors.white),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () => AppRoutes.pop(context),
                            icon: const Icon(Icons.cancel, color: AppColors.danger),
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
                                child: Image(
                                  image: page.image,
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
            color: AppColors.greyColor(context).withValues(alpha: 0.5),width: 0.5
        ),
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(8),

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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text(context),
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
          const Icon(Icons.error_outline, size: 60, color: AppColors.danger),
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
            style: const TextStyle(fontSize: 14, color: AppColors.danger),
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
  // Desktop টেবিল — AppDataTable
  Widget build(BuildContext context) {
    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 52),
      AppTableColumn('Invoice No', flex: 2, minWidth: 120),
      AppTableColumn('Date', flex: 2, minWidth: 100),
      AppTableColumn('Supplier', flex: 3, minWidth: 160),
      AppTableColumn.numeric('Net Total', flex: 2, minWidth: 110),
      AppTableColumn.numeric('Paid', flex: 2, minWidth: 100),
      AppTableColumn.numeric('Due', flex: 2, minWidth: 100),
      AppTableColumn.center('Status', flex: 2, minWidth: 104),
      AppTableColumn.center('Actions', flex: 2, minWidth: 96),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: reports.length,
      onRowTap: onReportTap == null ? null : (_) => onReportTap!(),
      cellBuilder: (context, row, col) {
        final r = reports[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(r.invoiceNo,
                bold: true, color: AppColors.primaryColor(context));
          case 2:
            return AppTableText(_formatDate(r.purchaseDate));
          case 3:
            return AppTableText(r.supplier);
          case 4:
            return AppTableMoney(r.netTotal, bold: true);
          case 5:
            return AppTableMoney(r.paidTotal, color: AppColors.success);
          case 6:
            return AppTableMoney(r.dueTotal,
                bold: r.dueTotal > 0,
                color: r.dueTotal > 0
                    ? AppColors.danger
                    : AppColors.text(context).withValues(alpha: 0.5));
          case 7:
            return AppStatusPill(r.paymentStatus.capitalize(),
                color: _getStatusColor(r.paymentStatus));
          default:
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTableAction(
                  icon: Icons.visibility_outlined,
                  tooltip: 'View',
                  color: AppColors.info,
                  onPressed: () => _showViewDialog(context, r),
                ),
                AppTableAction(
                  icon: Icons.print_outlined,
                  tooltip: 'Print',
                  color: AppColors.success,
                  onPressed: () => _printReport(context, r),
                ),
              ],
            );
        }
      },
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
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'due':
      case 'overdue':
        return AppColors.danger;
      case 'partial':
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showViewDialog(BuildContext context, PurchaseReportModel report) {
    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverShell(
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
                _buildDetailRow(
                  'Net Total:',
                  report.netTotal.toStringAsFixed(2),
                ),
                _buildDetailRow(
                  'Paid Amount:',
                  report.paidTotal.toStringAsFixed(2),
                ),
                _buildDetailRow(
                  'Due Amount:',
                  report.dueTotal.toStringAsFixed(2),
                ),
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
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
