import 'package:flutter/material.dart';
import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '../data/payroll_models.dart';
import '../data/payroll_repo.dart';
import 'payroll_common.dart';

/// Advances — বেতনের আগে দেওয়া অগ্রিম; পরের বেতন থেকে কাটা যায় (ওয়েবের Advances এর মতো)
class MobileAdvancesScreen extends StatefulWidget {
  const MobileAdvancesScreen({super.key});

  @override
  State<MobileAdvancesScreen> createState() => _MobileAdvancesScreenState();
}

class _MobileAdvancesScreenState extends State<MobileAdvancesScreen> {
  final _repo = const PayrollRepo();

  List<StaffOption> _staff = const [];
  int? _filterStaff;
  bool _openOnly = false;
  AdvanceData _data = const AdvanceData([], {});
  bool _loading = true;
  String? _error;
  int _req = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      _repo.staff(context).then((s) {
        if (mounted) setState(() => _staff = s);
      });
    });
  }

  Future<void> _load() async {
    final id = ++_req;
    setState(() {
      _loading = true;
      _error = null;
    });
    final (d, err) = await _repo.advances(context, staffId: _filterStaff, openOnly: _openOnly);
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

  double get _totalOwed => _data.balances.values.fold(0.0, (a, b) => a + b);
  int get _staffOwing => _data.balances.values.where((v) => v > 0).length;
  double get _listed => _data.items.fold(0.0, (a, b) => a + b.amount);

  Future<void> _give() async {
    final ok = await showPaySheet<bool>(
        context, _AdvanceForm(repo: _repo, staff: _staff, balances: _data.balances));
    if (ok == true && mounted) {
      payToast(context, 'Advance recorded.');
      _load();
    }
  }

  Future<void> _cancel(SalaryAdvance a) async {
    final yes = await payConfirm(context,
        title: 'Cancel this advance?',
        body: '${taka(a.amount)} to ${a.staffName} goes back to the account.',
        action: 'Cancel advance');
    if (!yes || !mounted) return;
    final err = await _repo.deleteAdvance(a.id);
    if (!mounted) return;
    if (err != null) {
      payToast(context, err, error: true);
    } else {
      payToast(context, 'Advance cancelled.');
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Advances', style: AppTextStyle.titleMedium(context)),
        actions: [
          IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loading ? null : _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _give,
        icon: const Icon(Icons.add),
        label: const Text('Give advance'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    value: _filterStaff,
                    isExpanded: true,
                    decoration: const InputDecoration(
                        labelText: 'Staff', border: OutlineInputBorder(), isDense: true),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('Everyone')),
                      for (final s in _staff)
                        DropdownMenuItem<int?>(value: s.id, child: Text(s.name, overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (v) {
                      setState(() => _filterStaff = v);
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                FilterChip(
                  label: const Text('Still owed'),
                  selected: _openOnly,
                  onSelected: (v) {
                    setState(() => _openOnly = v);
                    _load();
                  },
                ),
              ],
            ),
          ),
          SumBar(items: [
            SumItem('Still owed', taka(_totalOwed), color: AppColors.danger),
            SumItem('Staff who owe', '$_staffOwing'),
            SumItem('Listed', taka(_listed)),
          ]),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading && _data.items.isEmpty) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return PayEmpty(
          icon: Icons.error_outline,
          title: "Couldn't load advances",
          body: _error!,
          actionLabel: 'Try again',
          onAction: _load);
    }
    if (_data.items.isEmpty) {
      return const PayEmpty(
        icon: Icons.account_balance_wallet_outlined,
        title: 'No advances',
        body: 'Money you give a staff member before payday is recorded here and cut from their next salary.',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        itemCount: _data.items.length,
        itemBuilder: (context, i) {
          final a = _data.items[i];
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
                      Expanded(child: Text(a.staffName, style: AppTextStyle.titleMedium(context))),
                      Text(fmtDate(a.date), style: AppTextStyle.bodySmall(context)),
                    ],
                  ),
                  if (a.note.isNotEmpty) Text(a.note, style: AppTextStyle.bodySmall(context)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _cell(context, 'Amount', taka(a.amount)),
                      _cell(context, 'Cut so far', taka(a.deducted)),
                      _cell(context, 'Still owed', taka(a.remaining),
                          color: a.remaining > 0 ? AppColors.danger : null, bold: true),
                    ],
                  ),
                  if (a.accountName.isNotEmpty || a.deducted == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(a.accountName.isEmpty ? '' : 'Paid from ${a.accountName}',
                                style: AppTextStyle.bodySmall(context)),
                          ),
                          if (a.deducted == 0)
                            IconButton(
                              tooltip: 'Cancel advance',
                              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                              onPressed: () => _cancel(a),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _cell(BuildContext context, String label, String value, {Color? color, bool bold = false}) =>
      Expanded(
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

class _AdvanceForm extends StatefulWidget {
  final PayrollRepo repo;
  final List<StaffOption> staff;
  final Map<int, double> balances;
  const _AdvanceForm({required this.repo, required this.staff, required this.balances});

  @override
  State<_AdvanceForm> createState() => _AdvanceFormState();
}

class _AdvanceFormState extends State<_AdvanceForm> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  List<AccountOption> _accounts = const [];
  int? _staff;
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

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amt = double.tryParse(_amount.text.trim()) ?? 0;
    if (_staff == null) return setState(() => _err = 'Choose a staff member.');
    if (amt <= 0) return setState(() => _err = 'Enter the advance amount.');
    if (_account == null) return setState(() => _err = 'Choose the account the advance is paid from.');
    setState(() {
      _working = true;
      _err = null;
    });
    final err = await widget.repo.giveAdvance(
      staffId: _staff!,
      amount: _amount.text.trim(),
      accountId: _account!,
      method: _method,
      date: isoDate(_date),
      note: _note.text.trim(),
    );
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
    final owed = _staff == null ? null : widget.balances[_staff];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Give an advance', style: AppTextStyle.titleMedium(context)),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: _staff,
          isExpanded: true,
          decoration: const InputDecoration(
              labelText: 'Staff *', border: OutlineInputBorder(), isDense: true),
          items: [
            for (final s in widget.staff)
              DropdownMenuItem(value: s.id, child: Text(s.name, overflow: TextOverflow.ellipsis)),
          ],
          onChanged: (v) => setState(() => _staff = v),
        ),
        if (owed != null && owed > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text('Already owes ${taka(owed)}',
                style: const TextStyle(fontSize: 12, color: AppColors.slate500)),
          ),
        const SizedBox(height: 12),
        MoneyField(controller: _amount, label: 'Amount *', onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        PayFromFields(
          accounts: _accounts,
          accountId: _account,
          method: _method,
          date: _date,
          needed: double.tryParse(_amount.text.trim()),
          onAccount: (v) => setState(() => _account = v),
          onMethod: (v) => setState(() => _method = v),
          onDate: (v) => setState(() => _date = v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _note,
          maxLength: 255,
          decoration: const InputDecoration(labelText: 'Note', border: OutlineInputBorder(), isDense: true),
        ),
        if (_err != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_err!, style: const TextStyle(color: AppColors.danger)),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _working ? null : _save,
            child: Text(_working ? 'Saving…' : 'Give advance'),
          ),
        ),
      ],
    );
  }
}
