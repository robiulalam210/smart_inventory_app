// lib/feature/report/presentation/screens/profit_loss_screen.dart
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
import 'package:smart_inventory/feature/report/presentation/bloc/profit_loss_bloc/profit_loss_bloc.dart';

import '../../../../../responsive.dart';

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  DateRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    _fetchProfitLossReport();
  }

  void _fetchProfitLossReport({
    DateTime? from,
    DateTime? to,
  }) {
    context.read<ProfitLossBloc>().add(FetchProfitLossReport(
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
        onRefresh: () async => _fetchProfitLossReport(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            children: [
              _buildFilterRow(),
              const SizedBox(height: 16),
              _buildProfitLossCards(),
              const SizedBox(height: 16),
              _buildExpenseBreakdown(),
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
        // 📅 Date Range Picker
        SizedBox(
          width: 260,
          child: CustomDateRangeField(
            selectedDateRange: selectedDateRange,
            onDateRangeSelected: (value) {
              setState(() => selectedDateRange = value);
              if (value != null) {
                _fetchProfitLossReport(from: value.start, to: value.end);
              }
            },
          ),
        ),
        const SizedBox(width: 5),

        // Clear Filters Button
        ElevatedButton.icon(
          onPressed: () {
            setState(() => selectedDateRange = null);
            context.read<ProfitLossBloc>().add(ClearProfitLossFilters());
            _fetchProfitLossReport();
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
          onPressed: () => _fetchProfitLossReport(),
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
        ),
      ],
    );
  }

  Widget _buildProfitLossCards() {
    return BlocBuilder<ProfitLossBloc, ProfitLossState>(
      builder: (context, state) {
        if (state is! ProfitLossSuccess) return const SizedBox();

        final summary = state.response.summary;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildProfitLossCard(
              "Total Sales",
              "\$${summary.totalSales.toStringAsFixed(2)}",
              Icons.trending_up,
              Colors.blue,
            ),
            _buildProfitLossCard(
              "Total Purchases",
              "\$${summary.totalPurchase.toStringAsFixed(2)}",
              Icons.shopping_cart,
              Colors.orange,
            ),
            _buildProfitLossCard(
              "Total Expenses",
              "\$${summary.totalExpenses.toStringAsFixed(2)}",
              Icons.money_off,
              Colors.red,
            ),
            _buildProfitLossCard(
              "Gross Profit",
              "\$${summary.grossProfit.toStringAsFixed(2)}",
              Icons.attach_money,
              Colors.green,
              isProfit: true,
            ),
            _buildProfitLossCard(
              "Net Profit",
              "\$${summary.netProfit.toStringAsFixed(2)}",
              Icons.account_balance_wallet,
              summary.netProfit >= 0 ? Colors.green : Colors.red,
              isProfit: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfitLossCard(String title, String value, IconData icon, Color color, {bool isProfit = false}) {
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
        border: isProfit ? Border.all(color: color.withOpacity(0.3), width: 2) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
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
                    color: isProfit ? color : AppColors.blackColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseBreakdown() {
    return BlocBuilder<ProfitLossBloc, ProfitLossState>(
      builder: (context, state) {
        if (state is ProfitLossLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading profit & loss report..."),
              ],
            ),
          );
        } else if (state is ProfitLossSuccess) {
          final summary = state.response.summary;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expense Breakdown Section
              if (summary.expenseBreakdown.isNotEmpty) ...[
                Text(
                  "Expense Breakdown",
                  style: AppTextStyle.cardTitle(context).copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Head')),
                        DataColumn(label: Text('Subhead')),
                        DataColumn(label: Text('Amount')),
                      ],
                      rows: summary.expenseBreakdown.map((expense) => DataRow(cells: [
                        DataCell(Text(expense.head)),
                        DataCell(Text(expense.subhead)),
                        DataCell(Text('\$${expense.total.toStringAsFixed(2)}')),
                      ])).toList(),
                    ),
                  ),
                ),
              ] else ...[
                _noDataWidget("No expense breakdown available"),
              ],

              // Profit/Loss Summary Section
              const SizedBox(height: 24),
              Text(
                "Profit & Loss Summary",
                style: AppTextStyle.cardTitle(context).copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
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
                child: Column(
                  children: [
                    _buildSummaryRow("Total Revenue", "\$${summary.totalSales.toStringAsFixed(2)}"),
                    _buildSummaryRow("Cost of Goods Sold", "\$${summary.totalPurchase.toStringAsFixed(2)}", isExpense: true),
                    _buildSummaryRow("Gross Profit", "\$${summary.grossProfit.toStringAsFixed(2)}", isProfit: true),
                    _buildSummaryRow("Operating Expenses", "\$${summary.totalExpenses.toStringAsFixed(2)}", isExpense: true),
                    const Divider(),
                    _buildSummaryRow("NET PROFIT/LOSS", "\$${summary.netProfit.toStringAsFixed(2)}",
                        isNet: true, isPositive: summary.netProfit >= 0),
                  ],
                ),
              ),
            ],
          );
        } else if (state is ProfitLossFailed) {
          return _errorWidget(state.content);
        }
        return _noDataWidget("No data available");
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isExpense = false, bool isProfit = false, bool isNet = false, bool isPositive = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isNet ? FontWeight.bold : FontWeight.normal,
              fontSize: isNet ? 16 : 14,
              color: isNet ? (isPositive ? Colors.green : Colors.red) : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isNet ? FontWeight.bold : FontWeight.normal,
              fontSize: isNet ? 16 : 14,
              color: isExpense ? Colors.red : (isProfit ? Colors.green : (isNet ? (isPositive ? Colors.green : Colors.red) : Colors.black)),
            ),
          ),
        ],
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
            onPressed: _fetchProfitLossReport,
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
            onPressed: _fetchProfitLossReport,
            child: const Text("Retry")
        ),
      ],
    ),
  );
}