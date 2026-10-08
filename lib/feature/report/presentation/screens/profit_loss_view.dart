import 'package:meherinMart/core/core.dart';

import '../../data/model/profit_loss_report_model.dart';
import '../bloc/profit_loss_bloc/profit_loss_bloc.dart';
import '../kit/report_kit.dart';

/// Profit & Loss — হিসাবের খাতার মতো statement:
/// বিক্রি − কেনা = মোট লাভ → − খরচ (খাত অনুযায়ী) ± return = নিট লাভ
class ProfitLossView extends StatefulWidget {
  final bool mobile;

  const ProfitLossView({super.key, this.mobile = false});

  @override
  State<ProfitLossView> createState() => _ProfitLossViewState();
}

class _ProfitLossViewState extends State<ProfitLossView> with ReportPeriodMixin {
  static const _title = 'Profit & Loss';
  static const _color = Color(0xFF16A34A);

  @override
  ReportRangePreset get defaultPreset => ReportRangePreset.thisMonth;

  @override
  void initState() {
    super.initState();
    initPeriod();
    reload();
  }

  @override
  void reload() {
    context.read<ProfitLossBloc>().add(FetchProfitLossReport(context: context, from: range?.start, to: range?.end));
  }

  void _clear() {
    setState(initPeriod);
    reload();
  }

  /// server এর নিট লাভে sales / purchase return ও যোগ-বিয়োগ হয় — statement মেলাতে আলাদা লাইন
  double _returnsAdjustment(ProfitLossSummary s) => s.netProfit - (s.grossProfit - s.totalExpenses);

  double _margin(ProfitLossSummary s) => s.totalSales == 0 ? 0 : s.netProfit / s.totalSales * 100;

  List<ReportStat> _stats(ProfitLossSummary s) => [
        ReportStat('Sales', ReportFmt.taka(s.totalSales), icon: Icons.point_of_sale_rounded, color: AppColors.info),
        ReportStat('Purchases', ReportFmt.taka(s.totalPurchase),
            icon: Icons.local_shipping_outlined, color: const Color(0xFF7C3AED)),
        ReportStat('Gross profit', ReportFmt.taka(s.grossProfit),
            icon: Icons.stacked_line_chart_rounded,
            color: s.grossProfit < 0 ? AppColors.danger : const Color(0xFF0D9488)),
        ReportStat('Expenses', ReportFmt.taka(s.totalExpenses), icon: Icons.payments_outlined, color: AppColors.warning),
        ReportStat(s.netProfit < 0 ? 'Net loss' : 'Net profit', ReportFmt.taka(s.netProfit),
            icon: s.netProfit < 0 ? Icons.trending_down_rounded : Icons.trending_up_rounded,
            color: s.netProfit < 0 ? AppColors.danger : _color,
            hint: 'Net margin ${_margin(s).toStringAsFixed(1)}% of sales'),
      ];

  List<ReportPdfSection> _sections(ProfitLossSummary s) {
    final adj = _returnsAdjustment(s);
    return [
      ReportPdfSection('Trading', [
        ReportPdfLine('Sales', ReportFmt.money(s.totalSales)),
        ReportPdfLine('Less: Purchases', '(${ReportFmt.money(s.totalPurchase)})'),
        ReportPdfLine('Gross profit', ReportFmt.money(s.grossProfit),
            bold: true, color: s.grossProfit < 0 ? AppColors.danger : null),
      ]),
      ReportPdfSection('Expenses', [
        for (final e in s.expenseBreakdown)
          ReportPdfLine(_expenseLabel(e), ReportFmt.money(e.total), indent: true),
        if (s.expenseBreakdown.isEmpty) const ReportPdfLine('No expenses recorded', '0.00', indent: true),
        ReportPdfLine('Total expenses', '(${ReportFmt.money(s.totalExpenses)})', bold: true),
      ]),
      ReportPdfSection('Result', [
        ReportPdfLine('Gross profit', ReportFmt.money(s.grossProfit)),
        ReportPdfLine('Less: Expenses', '(${ReportFmt.money(s.totalExpenses)})'),
        if (adj.abs() >= 0.01)
          ReportPdfLine('Returns adjustment (sales / purchase returns)',
              adj < 0 ? '(${ReportFmt.money(-adj)})' : ReportFmt.money(adj)),
        ReportPdfLine(s.netProfit < 0 ? 'NET LOSS' : 'NET PROFIT', ReportFmt.money(s.netProfit),
            bold: true, color: s.netProfit < 0 ? AppColors.danger : _color),
      ]),
    ];
  }

  static String _expenseLabel(ExpenseBreakdown e) =>
      e.subhead.trim().isEmpty ? e.head : '${e.head} › ${e.subhead}';

  void _pdf(ProfitLossSummary s) {
    final company = reportCompany(context);
    final period = periodText;
    openReportPdf(
      context,
      title: _title,
      build: () => ReportPdf.build<Object>(
        title: _title,
        period: period,
        company: company,
        accent: _color,
        stats: _stats(s),
        sections: _sections(s),
        note: 'Gross profit = Sales − Purchases in this period. Net profit also adjusts for sales and purchase returns.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfitLossBloc, ProfitLossState>(
      builder: (context, state) {
        final s = state is ProfitLossSuccess ? state.response.summary : null;
        final page = ReportPage(
          title: _title,
          subtitle: periodText,
          icon: Icons.account_balance_outlined,
          color: _color,
          compact: widget.mobile,
          preset: preset,
          range: range,
          onRangeChanged: onPeriodChanged,
          onClear: _clear,
          onRefresh: reload,
          onPdf: s == null ? null : () => _pdf(s),
          stats: s == null ? const [] : _stats(s),
          loading: state is ProfitLossLoading || state is ProfitLossInitial,
          error: state is ProfitLossFailed ? state.content : null,
          child: s == null ? null : _statement(context, s),
        );
        return wrapReport(mobile: widget.mobile, title: _title, page: page);
      },
    );
  }

  Widget _statement(BuildContext context, ProfitLossSummary s) {
    final adj = _returnsAdjustment(s);
    final statement = ReportCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Statement', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text(context))),
          const SizedBox(height: 4),
          Text(periodText, style: TextStyle(fontSize: 12, color: AppColors.subText)),
          const SizedBox(height: 14),
          _line(context, 'Sales', s.totalSales),
          _line(context, 'Less: Purchases', -s.totalPurchase),
          _total(context, 'Gross profit', s.grossProfit),
          const SizedBox(height: 10),
          _line(context, 'Less: Expenses', -s.totalExpenses),
          if (adj.abs() >= 0.01) _line(context, 'Returns adjustment', adj, hint: 'Sales and purchase returns'),
          const SizedBox(height: 6),
          _result(context, s),
        ],
      ),
    );

    final breakdown = ReportBreakdown(
      title: 'Where the money went',
      color: AppColors.warning,
      items: [for (final e in s.expenseBreakdown) (_expenseLabel(e), e.total)],
    );

    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth >= 900) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: statement),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: s.expenseBreakdown.isEmpty ? _noExpenses(context) : breakdown),
          ],
        );
      }
      return Column(children: [
        statement,
        const SizedBox(height: 16),
        s.expenseBreakdown.isEmpty ? _noExpenses(context) : breakdown,
      ]);
    });
  }

  Widget _noExpenses(BuildContext context) => const ReportCard(
        child: ReportMessage(
          icon: Icons.savings_outlined,
          color: AppColors.success,
          title: 'No expenses in this period',
          message: 'Expenses you record will be broken down here by head.',
        ),
      );

  Widget _line(BuildContext context, String label, double value, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13.5, color: AppColors.text(context))),
                if (hint != null) Text(hint, style: TextStyle(fontSize: 11, color: AppColors.subText)),
              ],
            ),
          ),
          Text(
            value < 0 ? '(${ReportFmt.taka(-value)})' : ReportFmt.taka(value),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: value < 0 ? AppColors.danger : AppColors.text(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _total(BuildContext context, String label, double value) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.greyColor(context).withValues(alpha: 0.35))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text(context))),
          ),
          Text(ReportFmt.taka(value),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: value < 0 ? AppColors.danger : AppColors.text(context),
              )),
        ],
      ),
    );
  }

  Widget _result(BuildContext context, ProfitLossSummary s) {
    final loss = s.netProfit < 0;
    final c = loss ? AppColors.danger : _color;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(loss ? Icons.trending_down_rounded : Icons.trending_up_rounded, color: c),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loss ? 'Net loss' : 'Net profit',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c)),
                Text('${_margin(s).toStringAsFixed(1)}% of sales',
                    style: TextStyle(fontSize: 11.5, color: AppColors.subText)),
              ],
            ),
          ),
          Text(ReportFmt.taka(s.netProfit), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c)),
        ],
      ),
    );
  }
}
