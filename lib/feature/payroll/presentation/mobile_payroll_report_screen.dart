import 'package:flutter/material.dart';
import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '../data/payroll_models.dart';
import '../data/payroll_repo.dart';
import 'payroll_common.dart';

/// Payroll Report — মাস/স্টাফ অনুযায়ী মোট বেতন (ওয়েবের Payroll Report এর মতো)
class MobilePayrollReportScreen extends StatefulWidget {
  const MobilePayrollReportScreen({super.key});

  @override
  State<MobilePayrollReportScreen> createState() => _MobilePayrollReportScreenState();
}

class _MobilePayrollReportScreenState extends State<MobilePayrollReportScreen> {
  final _repo = const PayrollRepo();

  late DateTime _start = DateTime(thisMonth().year, 1);
  DateTime _end = thisMonth();
  PayrollReport? _data;
  bool _loading = true;
  String? _error;
  int _req = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final id = ++_req;
    setState(() {
      _loading = true;
      _error = null;
    });
    final (d, err) = await _repo.report(context, start: monthKey(_start), end: monthKey(_end));
    if (!mounted || id != _req) return;
    setState(() {
      _loading = false;
      if (d == null) {
        _error = err;
      } else {
        _data = d;
      }
    });
  }

  Future<void> _pick(bool isStart) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2020),
      lastDate: thisMonth(),
      helpText: 'Choose any day in the month',
    );
    if (d == null) return;
    final m = DateTime(d.year, d.month);
    setState(() {
      if (isStart) {
        _start = m;
        if (_start.isAfter(_end)) _end = m;
      } else {
        _end = m;
        if (_end.isBefore(_start)) _start = m;
      }
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return AppScaffold(
      appBar: AppBar(
        title: Text('Payroll Report', style: AppTextStyle.titleMedium(context)),
        actions: [
          IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loading ? null : _load),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(child: _monthBox('From', _start, () => _pick(true))),
                const SizedBox(width: 12),
                Expanded(child: _monthBox('To', _end, () => _pick(false))),
              ],
            ),
          ),
          if (d != null) ...[
            SumBar(items: [
              SumItem('Net salary', taka(d.net)),
              SumItem('Paid', taka(d.paid), color: AppColors.success),
              SumItem('Still to pay', taka(d.unpaid), color: AppColors.danger),
            ]),
            SumBar(items: [
              SumItem('Advances given', taka(d.advancesGiven)),
              SumItem('Staff', '${d.staff}'),
            ]),
          ],
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  Widget _monthBox(String label, DateTime m, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
          child: Text(monthName(m)),
        ),
      );

  Widget _body(BuildContext context) {
    if (_loading && _data == null) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return PayEmpty(
          icon: Icons.error_outline,
          title: "Couldn't load the report",
          body: _error!,
          actionLabel: 'Try again',
          onAction: _load);
    }
    final rows = _data?.rows ?? const <ReportRow>[];
    if (rows.isEmpty) {
      return const PayEmpty(
          icon: Icons.bar_chart_outlined,
          title: 'No salary slips in this period',
          body: 'Prepare salary in Salary Sheet first.');
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: rows.length,
        itemBuilder: (context, i) {
          final r = rows[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 0,
            color: AppColors.bottomNavBg(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.greyColor(context).withValues(alpha: 0.35), width: 0.6),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.staffName, style: AppTextStyle.titleMedium(context)),
                            if (r.designation.isNotEmpty)
                              Text(r.designation, style: AppTextStyle.bodySmall(context)),
                          ],
                        ),
                      ),
                      PayPill('${r.months} month${r.months == 1 ? '' : 's'}', AppColors.info),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _row('Basic', taka(r.basic)),
                  _row('Additions', taka(r.additions)),
                  _row('Deductions', taka(r.deductions), color: r.deductions > 0 ? AppColors.danger : null),
                  const Divider(height: 16),
                  _row('Net salary', taka(r.net), bold: true),
                  _row('Paid', taka(r.paid), color: AppColors.success),
                  _row('Unpaid', taka(r.unpaid), color: r.unpaid > 0 ? AppColors.danger : null),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _row(String l, String v, {Color? color, bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
            Text(v, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: color)),
          ],
        ),
      );
}
