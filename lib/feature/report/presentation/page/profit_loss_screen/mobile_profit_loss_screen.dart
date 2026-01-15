import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';

import '../../../../../core/configs/app_images.dart';
import '/core/configs/app_colors.dart';
import '/core/widgets/date_range.dart';
import '/feature/report/presentation/bloc/profit_loss_bloc/profit_loss_bloc.dart';
import '/feature/report/presentation/page/profit_loss_screen/pdf.dart';
import '../../../../../responsive.dart';
import 'profit_loss_screen.dart';

class MobileProfitLossScreen extends StatefulWidget {
  const MobileProfitLossScreen({super.key});

  @override
  State<MobileProfitLossScreen> createState() =>
      _MobileProfitLossScreenState();
}

class _MobileProfitLossScreenState extends State<MobileProfitLossScreen> {
  DateRange? selectedDateRange;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchProfitLossReport();
  }

  void _fetchProfitLossReport({DateTime? from, DateTime? to}) {
    context.read<ProfitLossBloc>().add(
      FetchProfitLossReport(
        context: context,
        from: from,
        to: to,
      ),
    );
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
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchProfitLossReport(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchProfitLossReport(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isMobile) _buildMobileFilterSection(),
              const SizedBox(height: 16),
              _buildProfitLossCards(),
              const SizedBox(height: 16),
              _buildReportContent(),
            ],
          ),
        ),
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
        onPressed: () =>
            setState(() => _isFilterExpanded = !_isFilterExpanded),
        child: Icon(
          _isFilterExpanded
              ? Icons.filter_alt_off
              : Icons.filter_alt,
        ),
      )
          : null,
    );
  }

  // ---------------------------------------------------------------------------
  // FILTER
  Widget _buildMobileFilterSection() {
    return Card(
      child: ExpansionPanelList(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        expansionCallback: (_, isExpanded) =>
            setState(() => _isFilterExpanded = !isExpanded),
        children: [
          ExpansionPanel(
            isExpanded: _isFilterExpanded,
            headerBuilder: (_, __) => const ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Date Range Filter'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomDateRangeField(
                    isLabel: true,
                    selectedDateRange: selectedDateRange,
                    onDateRangeSelected: (value) {
                      setState(() => selectedDateRange = value);
                      if (value != null) {
                        _fetchProfitLossReport(
                          from: value.start,
                          to: value.end,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() => selectedDateRange = null);
                            context
                                .read<ProfitLossBloc>()
                                .add(ClearProfitLossFilters());
                            _fetchProfitLossReport();
                          },
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _generatePdf,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('PDF'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY CARDS
  Widget _buildProfitLossCards() {
    return BlocBuilder<ProfitLossBloc, ProfitLossState>(
      builder: (context, state) {
        if (state is! ProfitLossSuccess) return const SizedBox();

        final s = state.response.summary;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _profitLossCard(
                    "Sales",
                    s.totalSales,
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _profitLossCard(
                    "Purchases",
                    s.totalPurchase,
                    Icons.shopping_cart,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _profitLossCard(
                    "Expenses",
                    s.totalExpenses,
                    Icons.money_off,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _profitLossCard(
                    "Gross Profit",
                    s.grossProfit,
                    Icons.attach_money,
                    Colors.green,
                    highlight: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _profitLossCard(
              "Net Profit",
              s.netProfit,
              Icons.account_balance_wallet,
              s.netProfit >= 0 ? Colors.green : Colors.red,
              highlight: true,
            ),
          ],
        );
      },
    );
  }

  Widget _profitLossCard(
      String title,
      double value,
      IconData icon,
      Color color, {
        bool highlight = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(highlight ? 0.3 : 0.1),
          width: highlight ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: highlight ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CONTENT
  Widget _buildReportContent() {
    return BlocBuilder<ProfitLossBloc, ProfitLossState>(
      builder: (context, state) {
        if (state is ProfitLossLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProfitLossFailed) {
          return _buildError(state.content);
        }

        if (state is! ProfitLossSuccess) {
          return _buildEmpty();
        }

        final summary = state.response.summary;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            ProfitLossSummaryCard(summary: summary,),
            const SizedBox(height: 8),
            if (summary.expenseBreakdown.isNotEmpty)
              ExpenseBreakdownList(
                expenses: summary.expenseBreakdown,
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Lottie.asset(AppImages.noData, width: 150),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Text(error, style: const TextStyle(color: Colors.red)),
    );
  }

  // ---------------------------------------------------------------------------
  // PDF
  void _generatePdf() {
    final state = context.read<ProfitLossBloc>().state;
    if (state is! ProfitLossSuccess) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPreview(
          build: (_) =>
              generateProfitLossReportPdf(state.response),
          canChangeOrientation: false,
          canChangePageFormat: false,
        ),
      ),
    );
  }
}
