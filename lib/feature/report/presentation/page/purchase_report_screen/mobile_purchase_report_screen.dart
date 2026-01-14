import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';
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
  State<MobilePurchaseReportScreen> createState() => _MobilePurchaseReportScreenState();
}

class _MobilePurchaseReportScreenState extends State<MobilePurchaseReportScreen> {
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
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.bottomNavBg(context),
      appBar: AppBar(
        title: const Text('Purchase Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchPurchaseReport(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchPurchaseReport(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter Section
              if (isMobile) _buildMobileFilterSection(),
              if (!isMobile) _buildDesktopFilterRow(),

              const SizedBox(height: 16),

              // Summary Cards
              _buildSummaryCards(),

              const SizedBox(height: 16),

              // Data Display
              _buildDataDisplay(isMobile),
            ],
          ),
        ),
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
        onPressed: () {
          setState(() => _isFilterExpanded = !_isFilterExpanded);
        },
        child: Icon(_isFilterExpanded ? Icons.filter_alt_off : Icons.filter_alt),
        tooltip: 'Toggle Filters',
      )
          : null,
    );
  }

  Widget _buildMobileFilterSection() {
    return Card(
      child: ExpansionPanelList(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        expansionCallback: (int index, bool isExpanded) {
          setState(() => _isFilterExpanded = !isExpanded);
        },
        children: [
          ExpansionPanel(
            headerBuilder: (context, isExpanded) {
              return const ListTile(
                leading: Icon(Icons.filter_alt),
                title: Text('Filters'),
              );
            },
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Supplier Dropdown
                  BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
                    builder: (context, state) {
                      return AppDropdown<SupplierActiveModel>(
                        label: "Supplier",
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
                        _fetchPurchaseReport(from: value.start, to: value.end);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Clear Filters Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedDateRange = null;
                          _isFilterExpanded = false;
                        });
                        context.read<PurchaseReportBloc>().add(ClearPurchaseReportFilters());
                        _fetchPurchaseReport();
                      },
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Clear All Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            isExpanded: _isFilterExpanded,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopFilterRow() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Supplier Dropdown
                Expanded(
                  flex: 2,
                  child: BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
                    builder: (context, state) {
                      return AppDropdown<SupplierActiveModel>(
                        label: "Supplier",
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
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Date Range Picker
                Expanded(
                  flex: 2,
                  child: CustomDateRangeField(
                    isLabel: true,
                    selectedDateRange: selectedDateRange,
                    onDateRangeSelected: (value) {
                      setState(() => selectedDateRange = value);
                      if (value != null) {
                        _fetchPurchaseReport(from: value.start, to: value.end);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Clear Button
                SizedBox(
                  width: 100,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() => selectedDateRange = null);
                      context.read<PurchaseReportBloc>().add(ClearPurchaseReportFilters());
                      _fetchPurchaseReport();
                    },
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<PurchaseReportBloc, PurchaseReportState>(
      builder: (context, state) {
        if (state is! PurchaseReportSuccess) return const SizedBox();

        final summary = state.response.summary;
        final isMobile = Responsive.isMobile(context);

        if (isMobile) {
          return Column(
            children: [
              Row(
                children: [
                  _buildSummaryCard(
                    "Total Purchases",
                    "\$${summary.totalPurchases.toStringAsFixed(2)}",
                    Icons.shopping_cart,
                    AppColors.primaryColor(context),
                    isMobile: true,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    "Total Paid",
                    "\$${summary.totalPaid.toStringAsFixed(2)}",
                    Icons.payment,
                    Colors.green,
                    isMobile: true,
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
                    isMobile: true,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    "Transactions",
                    summary.totalTransactions.toString(),
                    Icons.receipt,
                    Colors.purple,
                    isMobile: true,
                  ),
                ],
              ),
            ],
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSummaryCard(
              "Total Purchases",
              "\$${summary.totalPurchases.toStringAsFixed(2)}",
              Icons.shopping_cart,
              AppColors.primaryColor(context),
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

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, {bool isMobile = false}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
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
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor(context),
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
          return
              _buildMobileReportList(state.response.report)
              ;
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
        return Card(
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(report.paymentStatus).withOpacity(0.1),
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
                const SizedBox(height: 8),
                Text(
                  report.supplier,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(report.purchaseDate),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: InkWell(
                        onTap:() {
                          _showMobileViewDetails(context, report);

                      },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.remove_red_eye, size: 14, color: Colors.blue),
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
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
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
    );
  }

  void _showMobileViewDetails(BuildContext context, PurchaseReportModel report) {
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
                  Text(
                    'Purchase Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor(context),
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
              _buildMobileDetailItem('Invoice No:', report.invoiceNo),
              _buildMobileDetailItem('Date:', _formatDate(report.purchaseDate)),
              _buildMobileDetailItem('Supplier:', report.supplier),
              _buildMobileDetailItem('Net Total:', '\$${report.netTotal.toStringAsFixed(2)}'),
              _buildMobileDetailItem('Paid Amount:', '\$${report.paidTotal.toStringAsFixed(2)}'),
              _buildMobileDetailItem('Due Amount:', '\$${report.dueTotal.toStringAsFixed(2)}'),
              _buildMobileDetailItem('Status:', report.paymentStatus.toUpperCase()),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _printMobileReport(context, report),
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text('Print'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileDetailItem(String label, String value) {
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
              build: (format) => generatePurchaseReportPdf(state.response),
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

  void _printMobileReport(BuildContext context, PurchaseReportModel report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing report for ${report.invoiceNo}'),
        duration: const Duration(seconds: 2),
      ),
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
}

// Keep your existing PurchaseReportTableCard class for desktop view