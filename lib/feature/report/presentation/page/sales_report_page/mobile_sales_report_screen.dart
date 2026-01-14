import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';
import '/core/core.dart';

import '../../../../../core/widgets/date_range.dart';
import '../../../../customer/data/model/customer_active_model.dart';
import '../../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../../users_list/data/model/user_model.dart';
import '../../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../../../data/model/sales_report_model.dart';
import '../../bloc/sales_report_bloc/sales_report_bloc.dart';
import 'pdf/sales_report.dart';

class MobileSalesReportScreen extends StatefulWidget {
  const MobileSalesReportScreen({super.key});

  @override
  State<MobileSalesReportScreen> createState() => _MobileSaleReportScreenState();
}

class _MobileSaleReportScreenState extends State<MobileSalesReportScreen> {
  TextEditingController filterTextController = TextEditingController();
  DateRange? selectedDateRange;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    filterTextController.clear();

    // Load dropdown data
    context.read<UserBloc>().add(FetchUserList(context, dropdownFilter: "?status=1"));
    context.read<CustomerBloc>().add(FetchCustomerActiveList(context));

    // Fetch initial sales report
    _fetchSalesReport();
  }

  void _fetchSalesReport({
    String customer = '',
    String seller = '',
    DateTime? from,
    DateTime? to,
  }) {
    context.read<SalesReportBloc>().add(FetchSalesReport(
      context: context,
      customer: customer,
      seller: seller,
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
        title: const Text('Sales Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchSalesReport(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchSalesReport(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter Section (Expandable for mobile)
              if (isMobile) _buildMobileFilterSection(),
              if (!isMobile) _buildDesktopFilterRow(),

              const SizedBox(height: 16),

              // Summary Cards
              _buildSummaryCards(),

              const SizedBox(height: 16),

              // Data Table/List
              _buildDataDisplay(isMobile),
            ],
          ),
        ),
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
        onPressed: () {
          setState(() => _isExpanded = !_isExpanded);
        },
        child: Icon(_isExpanded ? Icons.filter_alt_off : Icons.filter_alt),
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
          setState(() => _isExpanded = !isExpanded);
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
                  // Customer Dropdown
                  BlocBuilder<CustomerBloc, CustomerState>(
                    builder: (context, state) {
                      return AppDropdown<CustomerActiveModel>(
                        label: "Customer",
                        isSearch: true,
                        isLabel: true,
                        hint: "Select Customer",
                        isNeedAll: true,
                        isRequired: false,
                        value: context.read<SalesReportBloc>().selectedCustomer,
                        itemList: context.read<CustomerBloc>().activeCustomer,
                        onChanged: (newVal) {
                          _fetchSalesReport(
                            from: selectedDateRange?.start,
                            to: selectedDateRange?.end,
                            customer: newVal?.id.toString() ?? '',
                            seller: context.read<SalesReportBloc>().selectedSeller?.id.toString() ?? '',
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Seller Dropdown
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      return AppDropdown<UsersListModel>(
                        label: "Seller",
                        hint: "Select Seller",
                        isLabel: true,
                        isRequired: false,
                        isNeedAll: true,
                        value: context.read<SalesReportBloc>().selectedSeller,
                        itemList: context.read<UserBloc>().list,
                        onChanged: (newVal) {
                          _fetchSalesReport(
                            from: selectedDateRange?.start,
                            to: selectedDateRange?.end,
                            customer: context.read<SalesReportBloc>().selectedCustomer?.id.toString() ?? '',
                            seller: newVal?.id.toString() ?? '',
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Date Range Picker
                  CustomDateRangeField(
                    isLabel: true,
                    // label: 'Date Range',
                    selectedDateRange: selectedDateRange,
                    onDateRangeSelected: (value) {
                      setState(() => selectedDateRange = value);
                      if (value != null) {
                        _fetchSalesReport(
                          from: value.start,
                          to: value.end,
                          customer: context.read<SalesReportBloc>().selectedCustomer?.id.toString() ?? '',
                          seller: context.read<SalesReportBloc>().selectedSeller?.id.toString() ?? '',
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Clear Filters Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() => selectedDateRange = null);
                        context.read<SalesReportBloc>().add(ClearSalesReportFilters());
                        _fetchSalesReport();
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
            isExpanded: _isExpanded,
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
                // Customer Dropdown
                Expanded(
                  child: BlocBuilder<CustomerBloc, CustomerState>(
                    builder: (context, state) {
                      return AppDropdown<CustomerActiveModel>(
                        label: "Customer",
                        isSearch: true,
                        isLabel: true,
                        hint: "Select Customer",
                        isNeedAll: true,
                        isRequired: false,
                        value: context.read<SalesReportBloc>().selectedCustomer,
                        itemList: context.read<CustomerBloc>().activeCustomer,
                        onChanged: (newVal) {
                          _fetchSalesReport(
                            from: selectedDateRange?.start,
                            to: selectedDateRange?.end,
                            customer: newVal?.id.toString() ?? '',
                            seller: context.read<SalesReportBloc>().selectedSeller?.id.toString() ?? '',
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Seller Dropdown
                Expanded(
                  child: BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      return AppDropdown<UsersListModel>(
                        label: "Seller",
                        hint: "Select Seller",
                        isLabel: true,
                        isRequired: false,
                        isNeedAll: true,
                        value: context.read<SalesReportBloc>().selectedSeller,
                        itemList: context.read<UserBloc>().list,
                        onChanged: (newVal) {
                          _fetchSalesReport(
                            from: selectedDateRange?.start,
                            to: selectedDateRange?.end,
                            customer: context.read<SalesReportBloc>().selectedCustomer?.id.toString() ?? '',
                            seller: newVal?.id.toString() ?? '',
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Date Range Picker
                Expanded(
                  child: CustomDateRangeField(
                    isLabel: true,
                    // label: 'Date Range',
                    selectedDateRange: selectedDateRange,
                    onDateRangeSelected: (value) {
                      setState(() => selectedDateRange = value);
                      if (value != null) {
                        _fetchSalesReport(
                          from: value.start,
                          to: value.end,
                          customer: context.read<SalesReportBloc>().selectedCustomer?.id.toString() ?? '',
                          seller: context.read<SalesReportBloc>().selectedSeller?.id.toString() ?? '',
                        );
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
                      context.read<SalesReportBloc>().add(ClearSalesReportFilters());
                      _fetchSalesReport();
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
    return BlocBuilder<SalesReportBloc, SalesReportState>(
      builder: (context, state) {
        if (state is! SalesReportSuccess) return const SizedBox();

        final summary = state.response.summary;
        final isMobile = Responsive.isMobile(context);

        if (isMobile) {
          return Column(
            children: [
              Row(
                children: [
                  _buildSummaryCard(
                    "Total Sales",
                    "\$${summary.totalSales.toStringAsFixed(2)}",
                    Icons.shopping_cart,
                    AppColors.primaryColor(context),
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    "Total Profit",
                    "\$${summary.totalProfit.toStringAsFixed(2)}",
                    Icons.trending_up,
                    Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildSummaryCard(
                    "Collected",
                    "\$${summary.totalCollected.toStringAsFixed(2)}",
                    Icons.payment,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildSummaryCard(
                    "Total Due",
                    "\$${summary.totalDue.toStringAsFixed(2)}",
                    Icons.money_off,
                    Colors.orange,
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
              "Total Sales",
              "\$${summary.totalSales.toStringAsFixed(2)}",
              Icons.shopping_cart,
              AppColors.primaryColor(context),
            ),
            _buildSummaryCard(
              "Total Profit",
              "\$${summary.totalProfit.toStringAsFixed(2)}",
              Icons.trending_up,
              Colors.green,
            ),
            _buildSummaryCard(
              "Total Collected",
              "\$${summary.totalCollected.toStringAsFixed(2)}",
              Icons.payment,
              Colors.blue,
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
    final isMobile = Responsive.isMobile(context);

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
    return BlocBuilder<SalesReportBloc, SalesReportState>(
      builder: (context, state) {
        if (state is SalesReportLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading sales report..."),
              ],
            ),
          );
        } else if (state is SalesReportSuccess) {
          if (state.response.report.isEmpty) {
            return _buildEmptyState();
          }
          return
              _buildMobileReportList(state.response.report)
             ;
        } else if (state is SalesReportFailed) {
          return _buildErrorState(state.content);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildMobileReportList(List<SalesReportModel> reports) {
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
                  report.customerName,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(report.saleDate),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMobileAmountItem(
                      'Sales Price',
                      '\$${report.salesPrice.toStringAsFixed(2)}',
                      Colors.blue,
                    ),
                    _buildMobileAmountItem(
                      'Profit',
                      '\$${report.profit.toStringAsFixed(2)}',
                      report.profit >= 0 ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(color: Colors.grey[300]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Seller:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      report.salesBy,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
              "No Sales Report Data Found",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Sales report data will appear here when available",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchSalesReport,
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
              "Error Loading Sales Report",
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
              onPressed: _fetchSalesReport,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  void _generatePdf() {
    final state = context.read<SalesReportBloc>().state;
    if (state is SalesReportSuccess) {
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
              build: (format) => generateSalesReportPdf(state.response),
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

// Keep your existing SalesReportTableCard class for desktop view