import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:printing/printing.dart';

import '/core/widgets/date_range.dart';
import '/feature/report/presentation/bloc/profit_loss_bloc/profit_loss_bloc.dart';
import '/feature/report/presentation/page/profit_loss_screen/pdf.dart';
import 'profit_loss_screen.dart';

class MobileProfitLossScreen extends StatefulWidget {
  const MobileProfitLossScreen({super.key});

  @override
  State<MobileProfitLossScreen> createState() => _MobileProfitLossScreenState();
}

class _MobileProfitLossScreenState extends State<MobileProfitLossScreen> {
  DateRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    _fetchProfitLossReport();
  }

  void _fetchProfitLossReport({DateTime? from, DateTime? to}) {
    context.read<ProfitLossBloc>().add(
      FetchProfitLossReport(context: context, from: from, to: to),
    );
  }

  @override
  Widget build(BuildContext context) {

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Profit & Loss Report',
          style: AppTextStyle.titleMedium(context),
        ),
        actions: [
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedPdf02, color: AppColors.text(context)),
            onPressed: _generatePdf,
          ),
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedReload, color: AppColors.text(context)), onPressed: () {

          _fetchProfitLossReport();
          setState(() => selectedDateRange = null);


          },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchProfitLossReport(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 8),
              _buildProfitLossCards(),
              _buildReportContent(),
            ],
          ),
        ),
      ),

    );
  }

  // ---------------------------------------------------------------------------
  // FILTER

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
                  style: AppTextStyle.body(context)
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
            ProfitLossSummaryCard(summary: summary),
            const SizedBox(height: 8),
            if (summary.expenseBreakdown.isNotEmpty)
              ExpenseBreakdownList(expenses: summary.expenseBreakdown),
          ],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(child: Lottie.asset(AppImages.noData, width: 150));
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
          build: (_) => generateProfitLossReportPdf(state.response),
          canChangeOrientation: false,
          canChangePageFormat: false,
        ),
      ),
    );
  }
}
