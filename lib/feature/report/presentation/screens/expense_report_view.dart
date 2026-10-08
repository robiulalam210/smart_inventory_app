import 'package:meherinMart/core/core.dart';

import '../../../expense/expense_head/data/model/expense_head_model.dart';
import '../../../expense/expense_head/presentation/bloc/expense_head/expense_head_bloc.dart';
import '../../data/model/expense_report_model.dart';
import '../bloc/expense_report_bloc/expense_report_bloc.dart';
import '../kit/report_kit.dart';

/// Expense Report — কোন খাতে কত খরচ, কোন মাধ্যমে
class ExpenseReportView extends StatefulWidget {
  final bool mobile;

  const ExpenseReportView({super.key, this.mobile = false});

  @override
  State<ExpenseReportView> createState() => _ExpenseReportViewState();
}

class _ExpenseReportViewState extends State<ExpenseReportView> with ReportPeriodMixin {
  static const _title = 'Expense Report';
  static const _color = Color(0xFFDC2626);

  /// FIX: আগে "Cash"/"Bank"/"Mobile Banking" পাঠানো হতো, কিন্তু database এ
  /// cash / bank / mobile রাখা থাকে — তাই payment দিয়ে filter করলে সবসময় ফাঁকা আসত
  static const _methods = {
    'cash': 'Cash',
    'bank': 'Bank transfer',
    'mobile': 'Mobile banking',
    'card': 'Card',
    'other': 'Other',
  };

  ExpenseHeadModel? _head;
  String? _method;

  @override
  void initState() {
    super.initState();
    initPeriod();
    context.read<ExpenseHeadBloc>().add(FetchExpenseHeadList(context));
    reload();
  }

  @override
  void reload() {
    context.read<ExpenseReportBloc>().add(FetchExpenseReport(
          context: context,
          from: range?.start,
          to: range?.end,
          head: _head?.id?.toString(),
          paymentMethod: _method,
        ));
  }

  void _clear() {
    setState(() {
      _head = null;
      _method = null;
      initPeriod();
    });
    reload();
  }

  String get _period => [
        periodText,
        if (_head != null) 'Head: ${_head!.name ?? ''}',
        if (_method != null) _methods[_method] ?? _method!,
      ].join('  ·  ');

  static String _methodLabel(String m) => _methods[m.toLowerCase()] ?? ReportFmt.titleCase(m);

  static final List<ReportColumn<ExpenseReport>> _columns = [
    const ReportColumn.serial(),
    ReportColumn('Date', value: (r) => r.expenseDate, kind: ReportKind.date, secondary: true, minWidth: 100),
    ReportColumn('Head', value: (r) => r.head, bold: true, primary: true, flex: 3, minWidth: 150),
    ReportColumn('Sub head', value: (r) => r.subhead, minWidth: 110),
    ReportColumn('Payment', value: (r) => _methodLabel(r.paymentMethod), minWidth: 110),
    ReportColumn('Note', value: (r) => r.note, flex: 3, minWidth: 140),
    ReportColumn('Amount', value: (r) => r.amount, kind: ReportKind.money, bold: true, highlight: true,
        minWidth: 120, color: (_) => _color),
  ];

  List<(String, double)> _byHead(List<ExpenseReport> rows) {
    final map = <String, double>{};
    for (final r in rows) {
      final k = r.head.trim().isEmpty ? 'Uncategorised' : r.head;
      map[k] = (map[k] ?? 0) + r.amount;
    }
    return [for (final e in map.entries) (e.key, e.value)];
  }

  List<ReportStat> _stats(ExpenseReportResponse d) {
    final heads = _byHead(d.report)..sort((a, b) => b.$2.compareTo(a.$2));
    final avg = d.summary.totalCount == 0 ? 0.0 : d.summary.totalAmount / d.summary.totalCount;
    return [
      ReportStat('Total expense', ReportFmt.taka(d.summary.totalAmount), icon: Icons.payments_outlined, color: _color),
      ReportStat('Entries', '${d.summary.totalCount}', icon: Icons.receipt_long_outlined, color: AppColors.info),
      ReportStat('Average per entry', ReportFmt.taka(avg),
          icon: Icons.functions_rounded, color: const Color(0xFF7C3AED)),
      if (heads.isNotEmpty)
        ReportStat('Biggest head', heads.first.$1,
            icon: Icons.label_important_outline_rounded,
            color: AppColors.warning,
            hint: ReportFmt.taka(heads.first.$2)),
    ];
  }

  void _pdf(ExpenseReportResponse d) {
    final company = reportCompany(context);
    final period = _period;
    final heads = _byHead(d.report)..sort((a, b) => b.$2.compareTo(a.$2));
    openReportPdf(
      context,
      title: _title,
      build: () => ReportPdf.build<ExpenseReport>(
        title: _title,
        period: period,
        company: company,
        accent: _color,
        stats: _stats(d),
        sections: [
          ReportPdfSection('Expense by head', [
            for (final h in heads) ReportPdfLine(h.$1, ReportFmt.money(h.$2), indent: true),
            ReportPdfLine('Total', ReportFmt.money(d.summary.totalAmount), bold: true),
          ]),
        ],
        columns: _columns,
        rows: d.report,
        totals: [ReportTotal('Total expense', ReportFmt.taka(d.summary.totalAmount), color: _color)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseReportBloc, ExpenseReportState>(
      builder: (context, state) {
        final data = state is ExpenseReportSuccess ? state.response : null;
        final page = ReportPage(
          title: _title,
          subtitle: _period,
          icon: Icons.payments_outlined,
          color: _color,
          compact: widget.mobile,
          preset: preset,
          range: range,
          onRangeChanged: onPeriodChanged,
          filters: [
            ReportFilter(
              child: BlocBuilder<ExpenseHeadBloc, ExpenseHeadState>(
                builder: (context, _) => AppDropdown<ExpenseHeadModel>(
                  key: ValueKey('exp-head-${_head?.id}'),
                  label: 'Expense head',
                  hint: 'All heads',
                  value: _head,
                  itemList: context.read<ExpenseHeadBloc>().list,
                  itemLabel: (h) => h.name ?? '',
                  onChanged: (v) {
                    setState(() => _head = v);
                    reload();
                  },
                ),
              ),
            ),
            ReportFilter(
              width: 190,
              child: AppDropdown<String>(
                key: ValueKey('exp-method-$_method'),
                label: 'Payment',
                hint: 'All payment types',
                value: _method,
                itemList: _methods.keys.toList(),
                itemLabel: (m) => _methods[m] ?? m,
                onChanged: (v) {
                  setState(() => _method = v);
                  reload();
                },
              ),
            ),
          ],
          onClear: _clear,
          onRefresh: reload,
          onPdf: data == null ? null : () => _pdf(data),
          stats: data == null ? const [] : _stats(data),
          loading: state is ExpenseReportLoading || state is ExpenseReportInitial,
          error: state is ExpenseReportFailed ? state.content : null,
          isEmpty: data != null && data.report.isEmpty,
          emptyTitle: 'No expenses in this period',
          child: data == null ? null : _body(data),
        );
        return wrapReport(mobile: widget.mobile, title: _title, page: page);
      },
    );
  }

  Widget _body(ExpenseReportResponse d) {
    final table = ReportTable<ExpenseReport>(
      columns: _columns,
      rows: d.report,
      totals: [ReportTotal('Total expense', ReportFmt.taka(d.summary.totalAmount), color: _color)],
      searchHint: 'Search head, payment or note',
    );
    final breakdown = ReportBreakdown(title: 'Expense by head', items: _byHead(d.report), color: _color);
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth >= 1150) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: table),
            const SizedBox(width: 16),
            Expanded(flex: 3, child: breakdown),
          ],
        );
      }
      return Column(children: [breakdown, const SizedBox(height: 16), table]);
    });
  }
}
