import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:lottie/lottie.dart';

import '../../../../../core/configs/app_colors.dart';
import '../../../../../core/configs/app_images.dart';
import '../../../../../core/configs/app_text.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/date_range.dart';
import '../../../../../responsive.dart';
import '../../../../customer/data/model/customer_active_model.dart';
import '../../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../../users_list/data/model/user_model.dart';
import '../../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../../../data/model/sales_report_model.dart';
import '../../bloc/sales_report_bloc/sales_report_bloc.dart';

class SaleReportScreen extends StatefulWidget {
  const SaleReportScreen({super.key});

  @override
  State<SaleReportScreen> createState() => _SaleReportScreenState();
}

class _SaleReportScreenState extends State<SaleReportScreen> {
  TextEditingController filterTextController = TextEditingController();
  DateRange? selectedDateRange;

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
        onRefresh: () async => _fetchSalesReport(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            children: [
              _buildFilterRow(),
              _buildSummaryCards(),
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
        // 👤 Customer Dropdown
        Expanded(
          flex: 1,
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              return AppDropdown<CustomerActiveModel>(
                label: "Customer",
                context: context,
                isSearch: true,
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
                itemBuilder: (item) => DropdownMenuItem<CustomerActiveModel>(
                  value: item,
                  child: Text(
                    item.name ?? 'Unknown Customer',
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

        // 🧑‍💼 Seller Dropdown
        Expanded(
          flex: 1,
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              return AppDropdown<UsersListModel>(
                label: "Seller",
                context: context,
                hint: "Select Seller",
                isLabel: false,
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
                itemBuilder: (item) => DropdownMenuItem<UsersListModel>(
                  value: item,
                  child: Text(
                    item.username ?? 'Unknown Seller',
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
        const SizedBox(width: 5),

        // Clear Filters Button
        ElevatedButton.icon(
          onPressed: () {
            setState(() => selectedDateRange = null);
            context.read<SalesReportBloc>().add(ClearSalesReportFilters());
            _fetchSalesReport();
          },
          icon: const Icon(Icons.clear_all),
          label: const Text("Clear"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textLight,
            foregroundColor: AppColors.blackColor,
          ),
        ),
        const SizedBox(width: 5),

        IconButton(
          onPressed: () => _fetchSalesReport(),
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<SalesReportBloc, SalesReportState>(
      builder: (context, state) {
        if (state is! SalesReportSuccess) return const SizedBox();

        final summary = state.response.summary;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSummaryCard(
              "Total Sales",
              "\$${summary.totalSales.toStringAsFixed(2)}",
              Icons.shopping_cart,
              AppColors.primaryColor,
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
            return _noDataWidget("No sales report data found");
          }
          return SalesReportDataTableWidget(reports: state.response.report);
        } else if (state is SalesReportFailed) {
          return _errorWidget(state.content);
        }
        return _noDataWidget("No data available");
      },
    );
  }

  // You'll need to create this widget
  Widget SalesReportDataTableWidget({required List<SalesReportModel> reports}) {
    // Implement your data table here using SalesReportModel
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Invoice No')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Customer')),
          DataColumn(label: Text('Sales Price')),
          DataColumn(label: Text('Profit')),
          DataColumn(label: Text('Status')),
        ],
        rows: reports.map((report) => DataRow(cells: [
          DataCell(Text(report.invoiceNo)),
          DataCell(Text(report.saleDate.toString().split(' ')[0])),
          DataCell(Text(report.customerName)),
          DataCell(Text('\$${report.salesPrice.toStringAsFixed(2)}')),
          DataCell(Text('\$${report.profit.toStringAsFixed(2)}')),
          DataCell(Text(report.paymentStatus)),
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
            onPressed: _fetchSalesReport,
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
            onPressed: _fetchSalesReport,
            child: const Text("Retry")
        ),
      ],
    ),
  );
}