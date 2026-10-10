import 'package:flutter/material.dart';
import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '../data/payroll_models.dart';
import '../data/payroll_repo.dart';
import 'payroll_common.dart';

/// Salary Sheet — মাসের বেতন স্লিপ বানানো, বদলানো, পরিশোধ ও বাতিল (ওয়েবের Salary Sheet এর মতো)
class MobileSalarySheetScreen extends StatefulWidget {
  const MobileSalarySheetScreen({super.key});

  @override
  State<MobileSalarySheetScreen> createState() => _MobileSalarySheetScreenState();
}

class _MobileSalarySheetScreenState extends State<MobileSalarySheetScreen> {
  final _repo = const PayrollRepo();
  final _scroll = ScrollController();

  DateTime _month = thisMonth();
  String _status = ''; // '' | unpaid | paid
  final List<SalarySlip> _items = [];
  SlipSummary _summary = const SlipSummary();
  int _page = 1;
  int _totalPages = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _generating = false;
  String? _error;
  int _req = 0;

  bool get _isCurrent => _month == thisMonth();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300 &&
          !_loading &&
          !_loadingMore &&
          _page < _totalPages) {
        _loadMore();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = ++_req;
    setState(() {
      _loading = true;
      _error = null;
    });
    final (page, err) = await _repo.slips(context, month: monthKey(_month), status: _status);
    if (!mounted || id != _req) return;
    setState(() {
      _loading = false;
      if (page == null) {
        _error = err;
        _items.clear();
      } else {
        _items
          ..clear()
          ..addAll(page.items);
        _summary = page.summary;
        _page = 1;
        _totalPages = page.totalPages;
      }
    });
  }

  Future<void> _loadMore() async {
    final id = _req;
    setState(() => _loadingMore = true);
    final (page, _) = await _repo.slips(context, month: monthKey(_month), status: _status, page: _page + 1);
    if (!mounted || id != _req) return;
    setState(() {
      _loadingMore = false;
      if (page != null) {
        _items.addAll(page.items);
        _page += 1;
        _totalPages = page.totalPages;
      }
    });
  }

  void _moveMonth(int delta) {
    final next = DateTime(_month.year, _month.month + delta);
    if (next.isAfter(thisMonth())) return;
    setState(() => _month = next);
    _load();
  }

  Future<void> _pickMonth() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(2020),
      lastDate: thisMonth(),
      helpText: 'Choose any day in the month',
    );
    if (d != null) {
      setState(() => _month = DateTime(d.year, d.month));
      _load();
    }
  }

  Future<void> _generate() async {
    setState(() => _generating = true);
    final err = await _repo.generate(monthKey(_month));
    if (!mounted) return;
    setState(() => _generating = false);
    if (err != null) {
      payToast(context, err, error: true);
    } else {
      payToast(context, '${monthName(_month)} salary prepared.');
      _load();
    }
  }

  Future<void> _pay(SalarySlip s) async {
    final ok = await showPaySheet<bool>(context, _PaySlipForm(slip: s, repo: _repo));
    if (ok == true && mounted) {
      payToast(context, 'Salary paid.');
      _load();
    }
  }

  Future<void> _edit(SalarySlip s) async {
    final ok = await showPaySheet<bool>(context, _EditSlipForm(slip: s, repo: _repo));
    if (ok == true && mounted) {
      payToast(context, 'Slip updated.');
      _load();
    }
  }

  Future<void> _delete(SalarySlip s) async {
    final yes = await payConfirm(context,
        title: 'Delete this slip?',
        body: '${s.staffName} — ${monthName(DateTime.parse(s.month))}. You can prepare it again later.',
        action: 'Delete');
    if (!yes || !mounted) return;
    final err = await _repo.deleteSlip(s.id);
    if (!mounted) return;
    if (err != null) {
      payToast(context, err, error: true);
    } else {
      _load();
    }
  }

  Future<void> _unpay(SalarySlip s) async {
    final yes = await payConfirm(context,
        title: 'Cancel this payment?',
        body: 'The ${taka(s.net)} goes back to the account and any advance cut returns to the staff.',
        action: 'Cancel payment');
    if (!yes || !mounted) return;
    final err = await _repo.unpay(s.id);
    if (!mounted) return;
    if (err != null) {
      payToast(context, err, error: true);
    } else {
      payToast(context, 'Payment cancelled.');
      _load();
    }
  }

  void _payslip(SalarySlip s) {
    final month = monthName(DateTime.parse(s.month));
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Payslip · $month'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.staffName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              if (s.designation.isNotEmpty || s.employeeId.isNotEmpty)
                Text([s.designation, s.employeeId].where((e) => e.isNotEmpty).join(' · ')),
              const Divider(height: 24),
              _line('Basic salary', s.basic),
              if (s.commission > 0) _line('Commission', s.commission),
              if (s.bonus > 0) _line('Bonus', s.bonus),
              if (s.otherAddition > 0) _line('Other addition', s.otherAddition),
              _line('Total earnings', s.gross, bold: true),
              if (s.deductions > 0) const Divider(height: 24),
              if (s.advanceDeduction > 0) _line('Advance recovered', s.advanceDeduction),
              if (s.otherDeduction > 0) _line('Other deduction', s.otherDeduction),
              const Divider(height: 24),
              _line('Net salary paid', s.net, bold: true),
              const SizedBox(height: 8),
              Text(
                'Paid on ${fmtDate(s.paidDate)}'
                '${s.paymentMethod.isNotEmpty ? ' · ${s.paymentMethod}' : ''}'
                '${s.accountName.isNotEmpty ? ' · ${s.accountName}' : ''}',
                style: const TextStyle(fontSize: 12, color: AppColors.slate500),
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Widget _line(String l, double v, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
            Text(taka(v), style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Salary Sheet', style: AppTextStyle.titleMedium(context)),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _moveMonth(-1)),
                Expanded(
                  child: InkWell(
                    onTap: _pickMonth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(monthName(_month),
                          textAlign: TextAlign.center, style: AppTextStyle.titleMedium(context)),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _isCurrent ? null : () => _moveMonth(1),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final s in const [('', 'All'), ('unpaid', 'Unpaid'), ('paid', 'Paid')])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(s.$2),
                      selected: _status == s.$1,
                      onSelected: (_) {
                        setState(() => _status = s.$1);
                        _load();
                      },
                    ),
                  ),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: _generating ? null : _generate,
                  child: Text(_generating ? 'Preparing…' : 'Prepare salary'),
                ),
              ],
            ),
          ),
          SumBar(items: [
            SumItem('Salary', taka(_summary.totalNet)),
            SumItem('Paid (${_summary.paidCount})', taka(_summary.paid), color: AppColors.success),
            SumItem('To pay (${_summary.unpaidCount})', taka(_summary.unpaid), color: AppColors.danger),
          ]),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading && _items.isEmpty) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return PayEmpty(
          icon: Icons.error_outline,
          title: "Couldn't load salary slips",
          body: _error!,
          actionLabel: 'Try again',
          onAction: _load);
    }
    if (_items.isEmpty) {
      return PayEmpty(
        icon: Icons.groups_outlined,
        title: _status.isNotEmpty ? 'No $_status slips this month' : 'No salary slips for ${monthName(_month)} yet',
        body: 'Press "Prepare salary" to make a slip for everyone with a salary set in Staff.',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= _items.length) {
            return const Padding(
                padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
          }
          return _slipCard(context, _items[i]);
        },
      ),
    );
  }

  Widget _slipCard(BuildContext context, SalarySlip s) {
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
                      Text(s.staffName, style: AppTextStyle.titleMedium(context)),
                      if (s.designation.isNotEmpty || s.employeeId.isNotEmpty)
                        Text(s.designation.isNotEmpty ? s.designation : s.employeeId,
                            style: AppTextStyle.bodySmall(context)),
                    ],
                  ),
                ),
                s.isPaid
                    ? PayPill('Paid ${fmtDate(s.paidDate)}', AppColors.success)
                    : const PayPill('Unpaid', AppColors.warning),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _cell(context, 'Basic', taka(s.basic)),
                _cell(context, 'Additions', taka(s.additions)),
                _cell(context, 'Deductions', taka(s.deductions),
                    color: s.deductions > 0 ? AppColors.danger : null),
                _cell(context, 'Net', taka(s.net), bold: true),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: s.isPaid
                  ? [
                      TextButton(onPressed: () => _payslip(s), child: const Text('Payslip')),
                      TextButton(onPressed: () => _unpay(s), child: const Text('Cancel payment')),
                    ]
                  : [
                      IconButton(
                        tooltip: 'Delete slip',
                        icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                        onPressed: () => _delete(s),
                      ),
                      TextButton(onPressed: () => _edit(s), child: const Text('Edit')),
                      FilledButton(onPressed: () => _pay(s), child: const Text('Pay')),
                    ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(BuildContext context, String label, String value, {Color? color, bool bold = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.bodySmall(context).copyWith(fontSize: 11)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Pay form ─────────────────────────

class _PaySlipForm extends StatefulWidget {
  final SalarySlip slip;
  final PayrollRepo repo;
  const _PaySlipForm({required this.slip, required this.repo});

  @override
  State<_PaySlipForm> createState() => _PaySlipFormState();
}

class _PaySlipFormState extends State<_PaySlipForm> {
  List<AccountOption> _accounts = const [];
  int? _account;
  String _method = 'cash';
  DateTime _date = DateTime.now();
  bool _working = false;
  String? _err;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final a = await widget.repo.accounts(context);
      if (mounted) setState(() => _accounts = a);
    });
  }

  Future<void> _submit() async {
    if (_account == null) {
      setState(() => _err = 'Choose the account the salary is paid from.');
      return;
    }
    setState(() {
      _working = true;
      _err = null;
    });
    final err = await widget.repo.pay(widget.slip.id,
        accountId: _account!, method: _method, date: isoDate(_date));
    if (!mounted) return;
    if (err == null) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _working = false;
        _err = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.slip;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pay salary — ${s.staffName}', style: AppTextStyle.titleMedium(context)),
        const SizedBox(height: 4),
        Text(taka(s.net), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        PayFromFields(
          accounts: _accounts,
          accountId: _account,
          method: _method,
          date: _date,
          needed: s.net,
          onAccount: (v) => setState(() => _account = v),
          onMethod: (v) => setState(() => _method = v),
          onDate: (v) => setState(() => _date = v),
        ),
        if (_err != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(_err!, style: const TextStyle(color: AppColors.danger)),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _working ? null : _submit,
            child: Text(_working ? 'Paying…' : 'Pay ${taka(s.net)}'),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Edit form ─────────────────────────

class _EditSlipForm extends StatefulWidget {
  final SalarySlip slip;
  final PayrollRepo repo;
  const _EditSlipForm({required this.slip, required this.repo});

  @override
  State<_EditSlipForm> createState() => _EditSlipFormState();
}

class _EditSlipFormState extends State<_EditSlipForm> {
  late final Map<String, TextEditingController> _c;
  late final TextEditingController _note;
  bool _working = false;
  String? _err;

  static String _s(double v) => v == 0 ? '' : v.toStringAsFixed(2);

  @override
  void initState() {
    super.initState();
    final s = widget.slip;
    _c = {
      'basic': TextEditingController(text: s.basic.toStringAsFixed(2)),
      'commission': TextEditingController(text: _s(s.commission)),
      'bonus': TextEditingController(text: _s(s.bonus)),
      'other_addition': TextEditingController(text: _s(s.otherAddition)),
      'advance_deduction': TextEditingController(text: _s(s.advanceDeduction)),
      'other_deduction': TextEditingController(text: _s(s.otherDeduction)),
    };
    _note = TextEditingController(text: s.note);
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    _note.dispose();
    super.dispose();
  }

  double _v(String k) => double.tryParse(_c[k]!.text.trim()) ?? 0;

  double get _net =>
      _v('basic') + _v('commission') + _v('bonus') + _v('other_addition') - _v('advance_deduction') - _v('other_deduction');

  Future<void> _save() async {
    setState(() {
      _working = true;
      _err = null;
    });
    final payload = <String, dynamic>{
      for (final e in _c.entries) e.key: e.value.text.trim().isEmpty ? '0' : e.value.text.trim(),
      'note': _note.text.trim(),
    };
    final err = await widget.repo.updateSlip(widget.slip.id, payload);
    if (!mounted) return;
    if (err == null) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _working = false;
        _err = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.slip;
    Widget gap() => const SizedBox(height: 12);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${s.staffName} — ${monthName(DateTime.parse(s.month))}',
            style: AppTextStyle.titleMedium(context)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: MoneyField(controller: _c['basic']!, label: 'Basic salary', onChanged: (_) => setState(() {}))),
          const SizedBox(width: 12),
          Expanded(child: MoneyField(controller: _c['commission']!, label: 'Commission', onChanged: (_) => setState(() {}))),
        ]),
        gap(),
        Row(children: [
          Expanded(child: MoneyField(controller: _c['bonus']!, label: 'Bonus', onChanged: (_) => setState(() {}))),
          const SizedBox(width: 12),
          Expanded(child: MoneyField(controller: _c['other_addition']!, label: 'Other addition', onChanged: (_) => setState(() {}))),
        ]),
        gap(),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: MoneyField(
              controller: _c['advance_deduction']!,
              label: 'Advance to cut',
              hint: 'Owed: ${taka(s.openAdvance)}',
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MoneyField(
              controller: _c['other_deduction']!,
              label: 'Other deduction',
              hint: 'e.g. absence, fine',
              onChanged: (_) => setState(() {}),
            ),
          ),
        ]),
        gap(),
        TextField(
          controller: _note,
          maxLength: 255,
          decoration: const InputDecoration(labelText: 'Note', border: OutlineInputBorder(), isDense: true),
        ),
        Text('Net salary ${taka(_net)}',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: _net < 0 ? AppColors.danger : null)),
        if (_err != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_err!, style: const TextStyle(color: AppColors.danger)),
          ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _working ? null : _save,
            child: Text(_working ? 'Saving…' : 'Save slip'),
          ),
        ),
      ],
    );
  }
}
