import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/web_ui.dart';

import '../../stock_tools/presentation/stock_kit.dart';
import '../data/day_close_repo.dart';

/// Day Close — দিন শেষে সারাদিনের হিসাব দেখে, টাকা গুনে সিস্টেমের সাথে মিলিয়ে দিন বন্ধ করা।
/// এটা শুধু রেকর্ড — পুরনো তারিখের লেনদেন বদলানো আটকায় না।
class DayCloseScreen extends StatefulWidget {
  final bool showAppBar;
  const DayCloseScreen({super.key, this.showAppBar = true});

  @override
  State<DayCloseScreen> createState() => _DayCloseScreenState();
}

class _DayCloseScreenState extends State<DayCloseScreen> {
  final _repo = const DayCloseRepo();
  final _noteCtrl = TextEditingController();
  final Map<int, TextEditingController> _counts = {};

  DateTime _date = DateTime.now();
  Map<String, dynamic> _summary = {};
  Map<String, dynamic>? _closed;
  List<Map<String, dynamic>> _history = [];
  bool _canClose = false;
  bool _canReopen = false;
  bool _loading = true;
  bool _busy = false;
  String? _error;
  int _req = 0;

  String get _dateKey =>
      '${_date.year.toString().padLeft(4, '0')}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      _loadHistory();
    });
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    for (final c in _counts.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final id = ++_req;
    setState(() {
      _loading = true;
      _error = null;
    });
    final (data, err) = await _repo.summary(context, _dateKey);
    if (!mounted || id != _req) return;
    setState(() {
      _loading = false;
      if (data == null) {
        _error = err;
        return;
      }
      _summary = dcMap(data['summary']);
      _closed = data['closed'] is Map ? dcMap(data['closed']) : null;
      _canClose = data['can_close'] == true;
      _canReopen = data['can_reopen'] == true;
      for (final c in _counts.values) {
        c.dispose();
      }
      _counts.clear();
      _noteCtrl.clear();
    });
  }

  Future<void> _loadHistory() async {
    final (rows, _) = await _repo.history(context);
    if (!mounted || rows == null) return;
    setState(() => _history = rows);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
    _load();
  }

  TextEditingController _ctrl(int accountId) => _counts.putIfAbsent(accountId, () => TextEditingController());

  double? _diff(Map<String, dynamic> a) {
    final t = _ctrl(dcNum(a['account_id']).toInt()).text.trim();
    if (t.isEmpty) return null;
    final v = double.tryParse(t);
    return v == null ? null : v - dcNum(a['expected']);
  }

  void _fillExpected() {
    setState(() {
      for (final a in dcList(_summary['accounts'])) {
        _ctrl(dcNum(a['account_id']).toInt()).text = dcNum(a['expected']).toStringAsFixed(2);
      }
    });
  }

  Future<void> _close() async {
    final counts = <String, double>{};
    for (final e in _counts.entries) {
      final t = e.value.text.trim();
      if (t.isEmpty) continue;
      final v = double.tryParse(t);
      if (v == null) {
        stockToast(context, 'Counted amounts must be numbers.', error: true);
        return;
      }
      counts['${e.key}'] = v;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Close ${_dateKey}?'),
        content: const Text('The day’s summary and the cash difference will be saved as a record.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not yet')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Close day')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final err = await _repo.close(_dateKey, counts, _noteCtrl.text.trim());
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      stockToast(context, err, error: true);
      return;
    }
    stockToast(context, 'Day closed.');
    _load();
    _loadHistory();
  }

  Future<void> _reopen() async {
    final id = dcNum(_closed?['id']).toInt();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reopen this day?'),
        content: const Text('The closing record for this day will be discarded.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reopen')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final err = await _repo.reopen(id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      stockToast(context, err, error: true);
      return;
    }
    stockToast(context, 'Day reopened.');
    _load();
    _loadHistory();
  }

  String _signed(double v) => '${v > 0 ? '+' : ''}${fmtMoney(v)}';

  Color? _diffColor(double? v) {
    if (v == null || v == 0) return null;
    return v < 0 ? W.redInk(context) : W.greenInk(context);
  }

  @override
  Widget build(BuildContext context) {
    return StockScaffold(
      title: 'Day Close',
      subtitle: 'Review the day, count the cash, close the books',
      showAppBar: widget.showAppBar,
      actions: [
        IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh_rounded), onPressed: _loading ? null : _load),
      ],
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: Text(fmtDate(_date)),
                  ),
                  const SizedBox(width: 10),
                  if (_summary.isNotEmpty)
                    Text(
                      _closed != null ? 'Closed' : 'Open',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _closed != null ? W.greenInk(context) : W.amberInk(context),
                      ),
                    ),
                ],
              ),
            ),
            if (_error != null)
              StockError(message: _error!, onRetry: _load)
            else if (_loading && _summary.isEmpty)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
            else ...[
              _summaryBars(),
              _accountsPanel(),
              if (_closed == null && _canClose) _closePanel(),
              if (_closed != null) _closedPanel(),
              if (_history.isNotEmpty) _historyPanel(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryBars() {
    final s = _summary;
    final sales = dcMap(s['sales']);
    final returns = dcMap(s['returns']);
    final purchases = dcMap(s['purchases']);
    final expenses = dcMap(s['expenses']);
    final income = dcMap(s['income']);
    final receipts = dcMap(s['receipts']);
    return Column(
      children: [
        WSumBar(items: [
          WSum('Sales (${sales['count'] ?? 0})', fmtMoney(dcNum(sales['total']))),
          WSum('Returns (${returns['count'] ?? 0})', fmtMoney(dcNum(returns['total']))),
          WSum('Net sales', fmtMoney(dcNum(s['net_sales']))),
          WSum('Sales due', fmtMoney(dcNum(sales['due'])),
              color: dcNum(sales['due']) > 0 ? W.amberInk(context) : null),
        ]),
        WSumBar(items: [
          WSum('Purchases (${purchases['count'] ?? 0})', fmtMoney(dcNum(purchases['total']))),
          WSum('Expenses (${expenses['count'] ?? 0})', fmtMoney(dcNum(expenses['total']))),
          WSum('Other income', fmtMoney(dcNum(income['total']))),
          WSum('Money received', fmtMoney(dcNum(receipts['total']))),
        ]),
      ],
    );
  }

  Widget _accountsPanel() {
    final closed = _closed != null;
    final rows = closed ? dcList(_closed!['lines']) : dcList(_summary['accounts']);
    final totalExpected = closed ? dcNum(_closed!['total_expected']) : dcNum(_summary['total_expected']);
    double totalDiff = 0;
    if (closed) {
      totalDiff = dcNum(_closed!['difference']);
    } else {
      for (final a in rows) {
        totalDiff += _diff(a) ?? 0;
      }
    }
    final anyCounted = closed || _counts.values.any((c) => c.text.trim().isNotEmpty);

    return WPanel(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WPanelHead(
            'Accounts & cash count',
            trailing: (!closed && _canClose)
                ? TextButton(onPressed: _fillExpected, child: const Text('Fill with expected'))
                : null,
          ),
          const SizedBox(height: 8),
          if (rows.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('No active accounts.')),
          for (final a in rows) ...[
            _accountRow(a, closed),
            Divider(height: 18, color: W.line(context)),
          ],
          Row(
            children: [
              const Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.w700))),
              Text('Expected ${fmtMoney(totalExpected)}', style: const TextStyle(fontWeight: FontWeight.w700)),
              if (anyCounted) ...[
                const SizedBox(width: 14),
                Text(_signed(totalDiff),
                    style: TextStyle(fontWeight: FontWeight.w800, color: _diffColor(totalDiff))),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Expected comes from the account ledger up to the end of this day. Leave Counted empty for accounts you did not count.',
            style: TextStyle(fontSize: 12, color: W.muted(context)),
          ),
        ],
      ),
    );
  }

  Widget _accountRow(Map<String, dynamic> a, bool closed) {
    final id = dcNum(a['account_id']).toInt();
    final diff = closed ? dcNum(a['difference']) : _diff(a);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${a['name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                '${a['type'] ?? ''} · in ${fmtMoney(dcNum(a['money_in']))} · out ${fmtMoney(dcNum(a['money_out']))}',
                style: TextStyle(fontSize: 12, color: W.muted(context)),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text('Expected\n${fmtMoney(dcNum(a['expected']))}', style: const TextStyle(fontSize: 13)),
        ),
        SizedBox(
          width: 120,
          child: closed
              ? Text('Counted\n${fmtMoney(dcNum(a['counted']))}', style: const TextStyle(fontSize: 13))
              : (_canClose
                  ? TextField(
                      controller: _ctrl(id),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Counted', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(W.rMd))),
                      onChanged: (_) => setState(() {}),
                    )
                  : const Text('—')),
        ),
        SizedBox(
          width: 96,
          child: Text(
            diff == null ? '' : _signed(diff),
            textAlign: TextAlign.right,
            style: TextStyle(fontWeight: FontWeight.w700, color: _diffColor(diff)),
          ),
        ),
      ],
    );
  }

  Widget _closePanel() => WPanel(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WPanelHead('Close this day'),
            const SizedBox(height: 10),
            TextField(
              controller: _noteCtrl,
              maxLength: 300,
              decoration: InputDecoration(
                labelText: 'Note (optional)',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(W.rMd)),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: _busy ? null : _close,
                icon: const Icon(Icons.lock_outline_rounded, size: 18),
                label: Text(_busy ? 'Closing…' : 'Close day'),
              ),
            ),
          ],
        ),
      );

  Widget _closedPanel() {
    final c = _closed!;
    final at = DateTime.tryParse('${c['closed_at'] ?? ''}');
    final note = '${c['note'] ?? ''}';
    return WPanel(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Closed by ${c['closed_by'] ?? ''} · ${fmtDateTime(at)}', style: const TextStyle(fontWeight: FontWeight.w700)),
          if (note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(note)),
          if (_canReopen) ...[
            const SizedBox(height: 10),
            OutlinedButton(onPressed: _busy ? null : _reopen, child: const Text('Reopen this day')),
          ],
        ],
      ),
    );
  }

  Widget _historyPanel() => WPanel(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WPanelHead('Recent closings'),
            const SizedBox(height: 6),
            for (final h in _history)
              InkWell(
                onTap: () {
                  final d = DateTime.tryParse('${h['date']}');
                  if (d == null) return;
                  setState(() => _date = d);
                  _load();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text('${h['date']}', style: const TextStyle(fontWeight: FontWeight.w700))),
                      Text(fmtMoney(dcNum(h['total_counted']))),
                      const SizedBox(width: 14),
                      SizedBox(
                        width: 96,
                        child: Text(_signed(dcNum(h['difference'])),
                            textAlign: TextAlign.right,
                            style: TextStyle(fontWeight: FontWeight.w700, color: _diffColor(dcNum(h['difference'])))),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
}
