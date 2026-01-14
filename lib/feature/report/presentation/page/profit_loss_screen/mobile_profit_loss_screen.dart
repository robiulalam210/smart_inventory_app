import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';
import '../../../../../core/configs/app_images.dart';
import '/core/configs/app_colors.dart';
import '/core/configs/app_text.dart';
import '/core/shared/widgets/sideMenu/sidebar.dart';
import '/core/widgets/date_range.dart';
import '/feature/report/presentation/bloc/profit_loss_bloc/profit_loss_bloc.dart';
import '/feature/report/presentation/page/profit_loss_screen/pdf.dart';

import '../../../../../core/configs/app_routes.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../responsive.dart';
import '../../../data/model/profit_loss_report_model.dart';

class MobileProfitLossScreen extends StatefulWidget {
  const MobileProfitLossScreen({super.key});

  @override
  State<MobileProfitLossScreen> createState() => _MobileProfitLossScreenState();
}

class _MobileProfitLossScreenState extends State<MobileProfitLossScreen> {
  DateRange? selectedDateRange;
  bool _isFilterExpanded = false;

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
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.bottomNavBg(context),
      appBar: AppBar(
        title: const Text('Profit & Loss Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchProfitLossReport(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchProfitLossReport(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter Section
              if (isMobile) _buildMobileFilterSection(),

              const SizedBox(height: 16),

              // Summary Cards
              _buildProfitLossCards(),

              const SizedBox(height: 16),

              // Report Content
              _buildReportContent(),
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
                leading: Icon(Icons.calendar_today),
                title: Text('Date Range Filter'),
              );
            },
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Date Range Picker
                  CustomDateRangeField(
                    isLabel: true,
                    selectedDateRange: selectedDateRange,
                    onDateRangeSelected: (value) {
                      setState(() => selectedDateRange = value);
                      if (value != null) {
                        _fetchProfitLossReport(from: value.start, to: value.end);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() => selectedDateRange = null);
                            context.read<ProfitLossBloc>().add(ClearProfitLossFilters());
                            _fetchProfitLossReport();
                          },
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Clear Filter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.grey[800],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _generatePdf,
                          icon: const Icon(Icons.picture_as_pdf, size: 18),
                          label: const Text('PDF Report'),
                        ),
                      ),
                    ],
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


  Widget _buildProfitLossCards() {
    return BlocBuilder<ProfitLossBloc, ProfitLossState>(
      builder: (context, state) {
        if (state is! ProfitLossSuccess) return const SizedBox();

        final summary = state.response.summary;
        final isMobile = Responsive.isMobile(context);

        if (isMobile) {
          return Column(
            children: [
              // First row: Sales and Purchases
              Row(
                children: [
                  _buildMobileProfitLossCard(
                    "Sales",
                    summary.totalSales.toStringAsFixed(2),
                    Icons.trending_up,
                    Colors.blue,
                    isMobile: true,
                  ),
                  const SizedBox(width: 8),
                  _buildMobileProfitLossCard(
                    "Purchases",
                    summary.totalPurchase.toStringAsFixed(2),
                    Icons.shopping_cart,
                    Colors.orange,
                    isMobile: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Second row: Expenses and Gross Profit
              Row(
                children: [
                  _buildMobileProfitLossCard(
                    "Expenses",
                    summary.totalExpenses.toStringAsFixed(2),
                    Icons.money_off,
                    Colors.red,
                    isMobile: true,
                  ),
                  const SizedBox(width: 8),
                  _buildMobileProfitLossCard(
                    "Gross Profit",
                    summary.grossProfit.toStringAsFixed(2),
                    Icons.attach_money,
                    Colors.green,
                    isMobile: true,
                    isProfit: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Third row: Net Profit (full width)
              _buildMobileProfitLossCard(
                "Net Profit",
                summary.netProfit.toStringAsFixed(2),
                Icons.account_balance_wallet,
                summary.netProfit >= 0 ? Colors.green : Colors.red,
                isMobile: true,
                isProfit: true,
                isNetProfit: true,
              ),
            ],
          );
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMobileProfitLossCard(
              "Total Sales",
              summary.totalSales.toStringAsFixed(2),
              Icons.trending_up,
              Colors.blue,
            ),
            _buildMobileProfitLossCard(
              "Total Purchases",
              summary.totalPurchase.toStringAsFixed(2),
              Icons.shopping_cart,
              Colors.orange,
            ),
            _buildMobileProfitLossCard(
              "Total Expenses",
              summary.totalExpenses.toStringAsFixed(2),
              Icons.money_off,
              Colors.red,
            ),
            _buildMobileProfitLossCard(
              "Gross Profit",
              summary.grossProfit.toStringAsFixed(2),
              Icons.attach_money,
              Colors.green,
              isProfit: true,
            ),
            _buildMobileProfitLossCard(
              "Net Profit",
              summary.netProfit.toStringAsFixed(2),
              Icons.account_balance_wallet,
              summary.netProfit >= 0 ? Colors.green : Colors.red,
              isProfit: true,
              isNetProfit: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileProfitLossCard(
      String title,
      String value,
      IconData icon,
      Color color, {
        bool isMobile = false,
        bool isProfit = false,
        bool isNetProfit = false,
      }) {
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
          border: Border.all(
            color: color.withOpacity(isProfit ? 0.3 : 0.1),
            width: isProfit ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    color: color,
                    size: isMobile ? 24 : 28
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isNetProfit ? 20 : (isMobile ? 16 : 18),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            // if (isProfit && !isNetProfit)
              // Text(
              //   summary.netProfit >= 0 ? 'Profit' : 'Loss',
              //   style: TextStyle(
              //     fontSize: 10,
              //     color: color.withOpacity(0.8),
              //   ),
              // ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent() {
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profit & Loss Summary
                _buildSectionTitle("Profit & Loss Summary"),
                const SizedBox(height: 12),
                ProfitLossSummaryCard(summary: summary, isMobile: true),

                const SizedBox(height: 24),

                // Expense Breakdown
                if (summary.expenseBreakdown.isNotEmpty) ...[
                  _buildSectionTitle("Expense Breakdown"),
                  const SizedBox(height: 12),
                  ExpenseBreakdownList(expenses: summary.expenseBreakdown),
                ],

                // Additional actions
                const SizedBox(height: 24),
                _buildMobileActionButtons(),
              ],
            );


        } else if (state is ProfitLossFailed) {
          return _buildErrorState(state.content);
        }
        return _buildEmptyState("No data available");
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.blackColor(context),
      ),
    );
  }

  Widget _buildMobileActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _generatePdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _fetchProfitLossReport(),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AppImages.noData, width: 150, height: 150),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            "Error Loading Profit & Loss Report",
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
            onPressed: _fetchProfitLossReport,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  void _generatePdf() {
    final state = context.read<ProfitLossBloc>().state;
    if (state is ProfitLossSuccess) {
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
              build: (format) => generateProfitLossReportPdf(state.response),
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
}

class ExpenseBreakdownList extends StatelessWidget {
  final List<ExpenseBreakdown> expenses;

  const ExpenseBreakdownList({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.money_off, color: Colors.red),
            ),
            title: Text(
              expense.head,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              expense.subhead,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${expense.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expense',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProfitLossSummaryCard extends StatelessWidget {
  final ProfitLossSummary summary;
  final bool isMobile;

  const ProfitLossSummaryCard({
    super.key,
    required this.summary,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Revenue Section
            _buildSummarySection(
              title: "REVENUE",
              items: [
                _buildSummaryItem("Total Sales", summary.totalSales, isPositive: true),
              ],
              color: Colors.blue,
            ),

            // Cost of Goods Sold
            _buildSummarySection(
              title: "COST OF GOODS SOLD",
              items: [
                _buildSummaryItem("Total Purchases", summary.totalPurchase, isPositive: false),
              ],
              color: Colors.orange,
            ),

            // Gross Profit
            _buildSummarySection(
              title: "GROSS PROFIT",
              items: [
                _buildSummaryItem("Gross Profit", summary.grossProfit, isPositive: summary.grossProfit >= 0),
              ],
              color: Colors.green,
              isHighlighted: true,
            ),

            // Operating Expenses
            _buildSummarySection(
              title: "OPERATING EXPENSES",
              items: [
                _buildSummaryItem("Total Expenses", summary.totalExpenses, isPositive: false),
              ],
              color: Colors.red,
            ),

            // Net Profit/Loss
            _buildSummarySection(
              title: "NET PROFIT/LOSS",
              items: [
                _buildSummaryItem("Net Profit/Loss", summary.netProfit, isPositive: summary.netProfit >= 0),
              ],
              color: summary.netProfit >= 0 ? Colors.green : Colors.red,
              isHighlighted: true,
              isNetProfit: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection({
    required String title,
    required List<Widget> items,
    required Color color,
    bool isHighlighted = false,
    bool isNetProfit = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ...items,
          if (isNetProfit)
            const SizedBox(height: 8),
          if (isNetProfit)
            Divider(
              color: color.withOpacity(0.3),
              thickness: 2,
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, {bool isPositive = true}) {
    final amountColor = isPositive ? Colors.green : Colors.red;
    final prefix = isPositive ? '' : '-';
    final formattedAmount = amount.abs().toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            '\$$prefix$formattedAmount',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Keep your existing ExpenseBreakdownTableCard class for desktop view