import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:printing/printing.dart';
import '../../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
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
  State<MobileSalesReportScreen> createState() =>
      _MobileSaleReportScreenState();
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
    context.read<UserBloc>().add(
      FetchUserList(context, dropdownFilter: "?status=1"),
    );
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
    context.read<SalesReportBloc>().add(
      FetchSalesReport(
        context: context,
        customer: customer,
        seller: seller,
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
        title: const Text('Sales Report'),
        actions: [
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedPdf02, color: AppColors.text(context)),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedReload, color: AppColors.text(context)),
            onPressed: () {
              setState(() => selectedDateRange = null);
              _isExpanded = false;

              context.read<SalesReportBloc>().add(
                ClearSalesReportFilters(),
              );
              _fetchSalesReport();
            },            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchSalesReport(),
        child: SingleChildScrollView(
          padding:  EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter Section (Expandable for mobile)
              _buildMobileFilterSection(),

              const SizedBox(height: 8),

              // Summary Cards
              _buildSummaryCards(),

              const SizedBox(height: 8),

              // Data Table/List
              _buildDataDisplay(isMobile),
            ],
          ),
        ),
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryColor(context),
              onPressed: () {
                setState(() => _isExpanded = !_isExpanded);
              },
              tooltip: 'Toggle Filters',
              child: Icon(
                _isExpanded ? HugeIcons.strokeRoundedFilterRemove:HugeIcons.strokeRoundedFilter,
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
            onTap: () => setState(() => _isExpanded = !_isExpanded),
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
                    _isExpanded
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
                            seller: context
                                .read<SalesReportBloc>()
                                .selectedSeller
                                ?.id
                                .toString() ??
                                '',
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
                            customer: context
                                .read<SalesReportBloc>()
                                .selectedCustomer
                                ?.id
                                .toString() ??
                                '',
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
                    selectedDateRange: selectedDateRange,
                    onDateRangeSelected: (value) {
                      setState(() => selectedDateRange = value);
                      if (value != null) {
                        _fetchSalesReport(
                          from: value.start,
                          to: value.end,
                          customer: context
                              .read<SalesReportBloc>()
                              .selectedCustomer
                              ?.id
                              .toString() ??
                              '',
                          seller: context
                              .read<SalesReportBloc>()
                              .selectedSeller
                              ?.id
                              .toString() ??
                              '',
                        );
                      }
                    },
                  ),

                  // TODO: Add Clear Filters / Action Buttons here
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<SalesReportBloc, SalesReportState>(
      builder: (context, state) {
        if (state is! SalesReportSuccess) return const SizedBox();

        final summary = state.response.summary;

        return Column(
          children: [
            Row(
              children: [
                _buildSummaryCard(
                  "Total Sales",
                  summary.totalSales.toStringAsFixed(2),
                  Icons.shopping_cart,
                  AppColors.primaryColor(context),
                ),
                const SizedBox(width: 8),
                _buildSummaryCard(
                  "Total Profit",
                  summary.totalProfit.toStringAsFixed(2),
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
                  summary.totalCollected.toStringAsFixed(2),
                  Icons.payment,
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildSummaryCard(
                  "Total Due",
                  summary.totalDue.toStringAsFixed(2),
                  Icons.money_off,
                  Colors.orange,
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
          return _buildMobileReportList(state.response.report);
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
                        fontWeight: FontWeight.bold,
                        color: AppColors.text(context),

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text(
                    report.customerName,
                    style:  AppTextStyle.body(context),
                  ),
                  Text(
                    _formatDate(report.saleDate),
                    style:  AppTextStyle.body(context),
                  ),

                ],),


                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMobileAmountItem(
                      'Sales Price',
                      report.salesPrice.toStringAsFixed(2),
                      Colors.blue,
                    ),
                    _buildMobileAmountItem(
                      'Profit',
                      report.profit.toStringAsFixed(2),
                      report.profit >= 0 ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                Divider(color: Colors.grey[300]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      'Seller:',
                      style:  AppTextStyle.body(context),
                    ),
                    Text(
                      report.salesBy,
                      style:  AppTextStyle.body(context),

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
        Text(label,                   style:  AppTextStyle.body(context),
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
              build: (format) => generateSalesReportPdf(state.response, context.read<ProfileBloc>().permissionModel?.data?.companyInfo),
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
