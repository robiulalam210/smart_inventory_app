// lib/feature/report/presentation/screens/profit_loss_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
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

              _buildProfitLossCards(),
              const SizedBox(height: 8),
              SizedBox(child: _buildReportContent()),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildProfitLossCards() {
    return BlocBuilder<ProfitLossBloc, ProfitLossState>(
      builder: (context, state) {
        if (state is! ProfitLossSuccess) return const SizedBox();

        final summary = state.response.summary;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildProfitLossCard(
              "Total Sales",
              summary.totalSales.toStringAsFixed(2),
              Icons.trending_up,
              Colors.blue,
            ),
            _buildProfitLossCard(
              "Total Purchases",
              summary.totalPurchase.toStringAsFixed(2),
              Icons.shopping_cart,
              Colors.orange,
            ),
            _buildProfitLossCard(
              "Total Expenses",
              summary.totalExpenses.toStringAsFixed(2),
              Icons.money_off,
              Colors.red,
            ),
            _buildProfitLossCard(
              "Gross Profit",
              summary.grossProfit.toStringAsFixed(2),
              Icons.attach_money,
              Colors.green,
              isProfit: true,
            ),
            _buildProfitLossCard(
              "Net Profit",
              summary.netProfit.toStringAsFixed(2),
              Icons.account_balance_wallet,
              summary.netProfit >= 0 ? Colors.green : Colors.red,
              isProfit: true,
            ),       SizedBox(
              width: 260,
              child: CustomDateRangeField(
                isLabel: false,
                selectedDateRange: selectedDateRange,
                onDateRangeSelected: (value) {
                  setState(() => selectedDateRange = value);
                  if (value != null) {
                    _fetchProfitLossReport(from: value.start, to: value.end);
                  }
                },
              ),
            ),
            const SizedBox(width: 4),
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
                      build: (format) => generateProfitLossReportPdf(
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

            }),
            const SizedBox(width: 4),
            AppButton(
              name: "Clear",size: 80,
              onPressed: () {
                setState(() => selectedDateRange = null);
                context.read<ProfitLossBloc>().add(ClearProfitLossFilters());
                _fetchProfitLossReport();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfitLossCard(String title, String value, IconData icon, Color color, {bool isProfit = false}) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(8),
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
        border: isProfit ? Border.all(color: color.withValues(alpha: 0.3), width: 2) : null,
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

          return SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Expense Breakdown Section
                Column(children: [
                  if (summary.expenseBreakdown.isNotEmpty) ...[
                    _buildSectionTitle("Expense Breakdown"),
                    const SizedBox(height: 8),
                    SizedBox(

                        width: 500,
                        child: ExpenseBreakdownTableCard(expenses: summary.expenseBreakdown)),
                    const SizedBox(height: 8),
                  ] else ...[
                    _buildEmptyState("No expense breakdown available"),
                  ],
                ],),
                SizedBox(width: 10,),

                // Profit & Loss Summary Section
               Column(children: [
                 _buildSectionTitle("Profit & Loss Summary"),
                 const SizedBox(height: 8),
                 SizedBox(
                     width: 300,
                     child: ProfitLossSummaryCard(summary: summary)),
               ],)

                // Export/Print Section
                // const SizedBox(height: 8),
                // _buildExportSection(),
              ],
            ),
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
      style: AppTextStyle.cardTitle(context).copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }


  Widget _buildEmptyState(String message) {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 48,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
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
            "Error Loading Profit & Loss Report",
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
            onPressed: _fetchProfitLossReport,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

}

class ExpenseBreakdownTableCard extends StatelessWidget {
  final List<ExpenseBreakdown> expenses;

  const ExpenseBreakdownTableCard({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 3; // Head, Subhead, Amount
        const minColumnWidth = 150.0;

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
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
                borderRadius: BorderRadius.circular(8),
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
                          headingRowColor: WidgetStateProperty.all(
                            AppColors.primaryColor,
                          ),
                          dataTextStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: expenses.asMap().entries.map((entry) {
                            final expense = entry.value;
                            return DataRow(
                              cells: [
                                _buildDataCell(expense.head, dynamicColumnWidth),
                                _buildDataCell(expense.subhead, dynamicColumnWidth),
                                _buildAmountCell(expense.total, dynamicColumnWidth),
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
          child: const Text('Expense Head', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Subhead', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Amount', textAlign: TextAlign.center),
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

  DataCell _buildAmountCell(double amount, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              amount.toStringAsFixed(2),
              style: const TextStyle(
                color: Colors.red,
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
}

class ProfitLossSummaryCard extends StatelessWidget {
  final ProfitLossSummary summary;

  const ProfitLossSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
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
      child: Column(
        children: [
          _buildSummaryRow("Total Revenue", summary.totalSales, isRevenue: true),
          _buildSummaryRow("Cost of Goods Sold", summary.totalPurchase, isExpense: true),
          _buildDivider(),
          _buildSummaryRow("Gross Profit", summary.grossProfit, isProfit: true),
          _buildSummaryRow("Operating Expenses", summary.totalExpenses, isExpense: true),
          _buildDivider(),
          _buildSummaryRow(
              "NET PROFIT/LOSS",
              summary.netProfit,
              isNet: true,
              isPositive: summary.netProfit >= 0
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {
    bool isRevenue = false,
    bool isExpense = false,
    bool isProfit = false,
    bool isNet = false,
    bool isPositive = true
  }) {

    final isNegative = amount < 0;

    Color getAmountColor() {
      if (isNet) return isPositive ? Colors.green : Colors.red;
      if (isProfit) return Colors.green;
      if (isExpense) return Colors.red;
      if (isRevenue) return Colors.blue;
      return Colors.black;
    }

    String getFormattedAmount() {
      if (isNet && isNegative) return '-${amount.abs().toStringAsFixed(2)}';
      return amount.toStringAsFixed(2);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isNet ? FontWeight.bold : FontWeight.w600,
                fontSize: isNet ? 14 : 14,
                color: isNet ? getAmountColor() : Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              getFormattedAmount(),
              style: TextStyle(
                fontWeight: isNet ? FontWeight.bold : FontWeight.w600,
                fontSize: isNet ? 16 : 14,
                color: getAmountColor(),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.grey,
      thickness: 1,
      height: 10,
    );
  }
}