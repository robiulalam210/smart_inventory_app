import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:printing/printing.dart';
import '../../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '/core/core.dart';
import '/core/widgets/date_range.dart';
import '/feature/report/presentation/page/purchase_report_screen/pdf.dart';
import '/feature/supplier/data/model/supplier_active_model.dart';
import '/feature/supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';

import '../../../data/model/purchase_report_model.dart';
import '../../bloc/purchase_report/purchase_report_bloc.dart';

class MobilePurchaseReportScreen extends StatefulWidget {
  const MobilePurchaseReportScreen({super.key});

  @override
  State<MobilePurchaseReportScreen> createState() =>
      _MobilePurchaseReportScreenState();
}

class _MobilePurchaseReportScreenState
    extends State<MobilePurchaseReportScreen> {
  TextEditingController filterTextController = TextEditingController();
  DateRange? selectedDateRange;
  bool _isFilterExpanded = false;

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
    final isMobile = Responsive.isMobile(context);

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Purchase Report',
          style: AppTextStyle.titleMedium(context),
        ),
        actions: [
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedPdf02, color: AppColors.text(context)),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedReload, color: AppColors.text(context)),
            onPressed: () {
              setState(() {
                selectedDateRange = null;
                _isFilterExpanded = false;
              });
              context.read<PurchaseReportBloc>().add(
                ClearPurchaseReportFilters(),
              );
              _fetchPurchaseReport();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchPurchaseReport(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter Section
              _buildMobileFilterSection(),

              const SizedBox(height: 8),

              // Summary Cards
              _buildSummaryCards(),

              const SizedBox(height: 8),

              // Data Display
              _buildDataDisplay(isMobile),
            ],
          ),
        ),
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryColor(context),
              onPressed: () {
                setState(() => _isFilterExpanded = !_isFilterExpanded);
              },
              tooltip: 'Toggle Filters',
              child: Icon(
                _isFilterExpanded ? HugeIcons.strokeRoundedFilterRemove:HugeIcons.strokeRoundedFilter,
                color: AppColors.whiteColor(context),
              ),
            )
          : null,
    );
  }

  Widget _buildMobileFilterSection() {
    return Card(
      elevation: 0,
      color: AppColors.bottomNavBg(context),
      child: Column(
        children: [
          // Header: fully clickable
          InkWell(
            onTap: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(HugeIcons.strokeRoundedFilter, color: AppColors.text(context)),
                  const SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: AppTextStyle.bodyLarge(context),
                  ),
                  const Spacer(),
                  Icon(
                    _isFilterExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.text(context),
                  ),
                ],
              ),
            ),
          ),

          // Expandable body
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Supplier Dropdown
                  BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
                    builder: (context, state) {
                      final supplierList = context
                          .read<SupplierInvoiceBloc>()
                          .supplierActiveList;
                      return AppDropdown<SupplierActiveModel>(
                        label: "Supplier",
                        isSearch: true,
                        hint: "Select Supplier",
                        isNeedAll: true,
                        isRequired: false,
                        isLabel: true,
                        value: context
                            .read<PurchaseReportBloc>()
                            .selectedSupplier,
                        itemList: supplierList,
                        onChanged: (newVal) {
                          _fetchPurchaseReport(
                            from: selectedDateRange?.start,
                            to: selectedDateRange?.end,
                            supplier: newVal?.id.toString() ?? '',
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Date Range Picker
                  CustomDateRangeField(
                    isLabel: true,
                    selectedDateRange: selectedDateRange,
                    onDateRangeSelected: (value) {
                      setState(() => selectedDateRange = value);
                      if (value != null) {
                        _fetchPurchaseReport(
                          from: value.start,
                          to: value.end,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            crossFadeState: _isFilterExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }


  Widget _buildSummaryCards() {
    return BlocBuilder<PurchaseReportBloc, PurchaseReportState>(
      builder: (context, state) {
        if (state is! PurchaseReportSuccess) return const SizedBox();

        final summary = state.response.summary;

        return Column(
          children: [
            Row(
              children: [
                _buildSummaryCard(
                  "Total Purchases",
                  "\$${summary.totalPurchases.toStringAsFixed(2)}",
                  Icons.shopping_cart,
                  AppColors.primaryColor(context),
                ),
                const SizedBox(width: 8),
                _buildSummaryCard(
                  "Total Paid",
                  "\$${summary.totalPaid.toStringAsFixed(2)}",
                  Icons.payment,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSummaryCard(
                  "Total Due",
                  "\$${summary.totalDue.toStringAsFixed(2)}",
                  Icons.money_off,
                  Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildSummaryCard(
                  "Transactions",
                  summary.totalTransactions.toString(),
                  Icons.receipt,
                  Colors.purple,
                ),
              ],
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
    final isMobile = Responsive.isMobile(context);

    return Expanded(
      child: Container(
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
        child: Row(
          children: [
            Icon(icon, color: color, size: isMobile ? 24 : 28),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      color: AppColors.text(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text(context),
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

  Widget _buildDataDisplay(bool isMobile) {
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
          return _buildMobileReportList(state.response.report);
        } else if (state is PurchaseReportFailed) {
          return _buildErrorState(state.content);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildMobileReportList(List<PurchaseReportModel> reports) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bottomNavBg(context),
            border: Border.all(
              color: AppColors.greyColor(context).withValues(alpha: 0.5),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      report.invoiceNo,
                      style:  TextStyle(
                        color: AppColors.text(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          report.paymentStatus,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        report.paymentStatus.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(report.paymentStatus),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  report.supplier,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(report.purchaseDate),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMobileAmountItem(
                      'Net Total',
                      '\$${report.netTotal.toStringAsFixed(2)}',
                      Colors.blue,
                    ),
                    _buildMobileAmountItem(
                      'Paid',
                      '\$${report.paidTotal.toStringAsFixed(2)}',
                      Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMobileAmountItem(
                      'Due',
                      '\$${report.dueTotal.toStringAsFixed(2)}',
                      Colors.orange,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: InkWell(
                        onTap: () {
                          _showMobileViewDetails(context, report);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              size: 14,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue,
                              ),
                            ),
                          ],
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

  Widget _buildMobileAmountItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.body(context)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showMobileViewDetails(
    BuildContext context,
    PurchaseReportModel report,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
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
                    'Purchase Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text(context),
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
              _buildMobileDetailItem('Invoice No:', report.invoiceNo, context),
              _buildMobileDetailItem(
                'Date:',
                _formatDate(report.purchaseDate),
                context,
              ),
              _buildMobileDetailItem('Supplier:', report.supplier, context),
              _buildMobileDetailItem(
                'Net Total:',
                '\$${report.netTotal.toStringAsFixed(2)}',
                context,
              ),
              _buildMobileDetailItem(
                'Paid Amount:',
                '\$${report.paidTotal.toStringAsFixed(2)}',
                context,
              ),
              _buildMobileDetailItem(
                'Due Amount:',
                '\$${report.dueTotal.toStringAsFixed(2)}',
                context,
              ),
              _buildMobileDetailItem(
                'Status:',
                report.paymentStatus.toUpperCase(),
                context,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileDetailItem(
    String label,
    String value,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
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
              style: TextStyle(
                fontSize: 14,

                color: AppColors.text(context),

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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(AppImages.noData, width: 150, height: 150),
            const SizedBox(height: 16),
            Text(
              "No Purchase Report Data Found",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Purchase report data will appear here when available",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPurchaseReport,
              child: const Text("Refresh"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
              onPressed: _fetchPurchaseReport,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  void _generatePdf() {
    final state = context.read<PurchaseReportBloc>().state;
    if (state is PurchaseReportSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('PDF Preview'),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            body: PdfPreview(
              build: (format) => generatePurchaseReportPdf(state.response, context.read<ProfileBloc>().permissionModel?.data?.companyInfo),
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
          content: Text('No data available to generate PDF'),
          backgroundColor: Colors.orange,
        ),
      );
    }
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
}
