import 'dart:async';

import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:meherinMart/core/widgets/web_ui.dart';

import '../data/stock_models.dart';
import '../data/stock_repo.dart';
import 'stock_kit.dart';

/// একটা গণনার স্ক্রিন — গুনে সংখ্যা লেখা, পার্থক্য দেখা, সিস্টেমের সাথে মিলানো (Apply)।
///
/// - প্রতিটা সংখ্যা লেখার একটু পরে নিজে নিজে সেভ হয় (বন্ধ করে আবার খুললেও থাকে)
/// - Enter চাপলে পরের পণ্যে যায়
/// - Apply: পার্থক্য (গণনা − শুরুর snapshot) **এখনকার** স্টকে যোগ হয়; গণনা না করা পণ্য ছোঁয়া হয় না
class StocktakeCountScreen extends StatefulWidget {
  final int id;
  const StocktakeCountScreen({super.key, required this.id});

  @override
  State<StocktakeCountScreen> createState() => _StocktakeCountScreenState();
}

class _StocktakeCountScreenState extends State<StocktakeCountScreen> {
  final _repo = const StockRepo();
  final _searchCtrl = TextEditingController();
  final Map<int, TextEditingController> _ctrls = {};
  final Map<int, FocusNode> _nodes = {};
  final Map<int, int?> _dirty = {}; // line id -> সংখ্যা (null = গণনা মুছে ফেলা)
  Timer? _saveTimer;

  StocktakeDetail? _detail;
  StocktakeSummary? _summary;
  bool _loading = true;
  String? _error;
  String _filter = 'all'; // all | uncounted | counted | differ
  bool _saving = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _searchCtrl.dispose();
    for (final c in _ctrls.values) {
      c.dispose();
    }
    for (final n in _nodes.values) {
      n.dispose();
    }
    super.dispose();
  }

  StocktakeHead? get _head => _detail?.head;
  bool get _editable => _head?.isDraft == true;

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final (d, err) = await _repo.countDetail(context, widget.id);
    if (!mounted) return;
    if (d == null) {
      setState(() {
        _loading = false;
        _error = err;
      });
      return;
    }
    for (final c in _ctrls.values) {
      c.dispose();
    }
    for (final n in _nodes.values) {
      n.dispose();
    }
    _ctrls.clear();
    _nodes.clear();
    _dirty.clear();
    for (final l in d.lines) {
      _ctrls[l.id] = TextEditingController(text: l.countedQty?.toString() ?? '');
      _nodes[l.id] = FocusNode();
    }
    setState(() {
      _detail = d;
      _summary = d.head.summary;
      _loading = false;
    });
  }

  // ───────── গণনা সেভ ─────────

  void _onChanged(StocktakeLine l, String text) {
    final t = text.trim();
    int? v;
    if (t.isEmpty) {
      v = null;
    } else {
      v = int.tryParse(t);
      if (v == null || v < 0) return; // অবৈধ সংখ্যা এড়িয়ে যাওয়া
    }
    setState(() => l.countedQty = v);
    _dirty[l.id] = v;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 700), _flush);
  }

  Future<bool> _flush() async {
    _saveTimer?.cancel();
    if (_dirty.isEmpty) return true;
    final batch = Map<int, int?>.from(_dirty);
    _dirty.clear();
    setState(() => _saving = true);
    final rows = [
      for (final e in batch.entries) {'line_id': e.key, 'counted_qty': e.value},
    ];
    final (s, err) = await _repo.saveCounts(widget.id, rows);
    if (!mounted) return false;
    setState(() => _saving = false);
    if (err != null) {
      // সেভ হয়নি — আবার চেষ্টার জন্য ফিরিয়ে রাখা (নতুন লেখা থাকলে সেটাই জেতে)
      for (final e in batch.entries) {
        _dirty.putIfAbsent(e.key, () => e.value);
      }
      stockToast(context, err, error: true);
      return false;
    }
    if (s != null) setState(() => _summary = s);
    return true;
  }

  void _next(StocktakeLine from, List<StocktakeLine> shown) {
    final i = shown.indexWhere((x) => x.id == from.id);
    if (i >= 0 && i + 1 < shown.length) {
      _nodes[shown[i + 1].id]?.requestFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  // ───────── Apply / Cancel ─────────

  Future<void> _apply() async {
    if (!await _flush()) return;
    final s = _summary ?? const StocktakeSummary();
    if (s.counted == 0) {
      stockToast(context, 'Count at least one product first.', error: true);
      return;
    }
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Match the system to your count?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${s.counted} of ${s.total} products counted.'),
            const SizedBox(height: 6),
            Text('${s.differing} product${s.differing == 1 ? '' : 's'} will change.'),
            if (s.shortQty > 0) Text('Short: ${s.shortQty} (${fmtMoney(s.shortValue)})'),
            if (s.overQty > 0) Text('Extra: ${s.overQty} (${fmtMoney(s.overValue)})'),
            const SizedBox(height: 6),
            if (s.uncounted > 0) Text('${s.uncounted} uncounted products stay as they are.'),
            const SizedBox(height: 8),
            const Text('This cannot be undone, but every change is recorded in Stock Adjustment.',
                style: TextStyle(fontSize: 12.5)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep counting')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Apply')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final (msg, err) = await _repo.applyCount(widget.id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      stockToast(context, err, error: true);
      return;
    }
    stockToast(context, msg ?? 'Stock matched');
    _load();
  }

  Future<void> _cancel() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this count?'),
        content: const Text('Your typed numbers are discarded. Stock is not changed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cancel count')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _saveTimer?.cancel();
    _dirty.clear();
    setState(() => _busy = true);
    final (msg, err) = await _repo.cancelCount(widget.id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      stockToast(context, err, error: true);
      return;
    }
    stockToast(context, msg ?? 'Count cancelled');
    _load();
  }

  Future<bool> _confirmLeave() async {
    if (_dirty.isEmpty) return true;
    return _flush();
  }

  // ───────── UI ─────────

  List<StocktakeLine> _filtered() {
    final lines = _detail?.lines ?? const <StocktakeLine>[];
    final q = _searchCtrl.text.trim().toLowerCase();
    return lines.where((l) {
      if (q.isNotEmpty && !(l.name.toLowerCase().contains(q) || l.sku.toLowerCase().contains(q))) return false;
      switch (_filter) {
        case 'uncounted':
          return l.countedQty == null;
        case 'counted':
          return l.countedQty != null;
        case 'differ':
          return l.variance != null && l.variance != 0;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final h = _head;
    return PopScope(
      canPop: _dirty.isEmpty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmLeave() && mounted) Navigator.pop(context);
      },
      child: AppScaffold(
        appBar: AppBar(
          title: Text(h == null ? 'Stocktake' : (h.title.isEmpty ? h.number : h.title),
              style: AppTextStyle.titleMedium(context)),
          actions: [
            if (_saving)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
              ),
            IconButton(tooltip: 'Reload', icon: const Icon(Icons.refresh_rounded), onPressed: _loading ? null : _load),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? StockError(message: _error!, onRetry: _load)
                : _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final h = _head!;
    final s = _summary ?? h.summary;
    final shown = _filtered();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WSumBar(items: [
          WSum('Counted', '${s.counted}/${s.total}'),
          WSum('Short', '${s.shortQty}', color: s.shortQty > 0 ? W.redInk(context) : null),
          WSum('Extra', '${s.overQty}', color: s.overQty > 0 ? W.greenInk(context) : null),
          WSum('Net value', fmtMoney(s.netValue), color: s.netValue < 0 ? W.redInk(context) : W.greenInk(context)),
        ]),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: s.progress, minHeight: 6, backgroundColor: W.tint(context)),
          ),
        ),
        if (!_editable)
          WNotice(
            tone: h.status == 'applied' ? WTone.green : WTone.neutral,
            icon: h.status == 'applied' ? Icons.check_circle_outline : Icons.block_rounded,
            text: h.status == 'applied'
                ? 'Applied ${fmtDateTime(h.appliedAt)}. Stock was matched to this count.'
                : 'This count was cancelled. Stock was not changed.',
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search product or SKU',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(W.rMd)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final f in [
                  ('all', 'All', s.total),
                  ('uncounted', 'Uncounted', s.uncounted),
                  ('counted', 'Counted', s.counted),
                  ('differ', 'Differ', s.differing),
                ]) ...[
                  WChip(label: f.$2, count: f.$3, selected: _filter == f.$1, onTap: () => setState(() => _filter = f.$1)),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: shown.isEmpty
              ? const WEmpty(icon: Icons.inventory_2_outlined, title: 'No products here')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: shown.length,
                  itemBuilder: (_, i) => _lineTile(context, shown[i], shown),
                ),
        ),
        if (_editable)
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: BoxDecoration(
                color: W.surface(context),
                border: Border(top: BorderSide(color: W.line(context))),
              ),
              child: Row(
                children: [
                  OutlinedButton(onPressed: _busy ? null : _cancel, child: const Text('Cancel count')),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _busy ? null : _apply,
                    icon: _busy
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.done_all_rounded, size: 20),
                    label: const Text('Match system'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _lineTile(BuildContext context, StocktakeLine l, List<StocktakeLine> shown) {
    final v = l.variance;
    final tone = v == null ? WTone.muted : (v == 0 ? WTone.green : (v < 0 ? WTone.red : WTone.amber));
    return WPanel(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.name, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${l.sku}${l.category.isNotEmpty ? ' · ${l.category}' : ''}',
                    style: TextStyle(fontSize: 12, color: W.muted(context))),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('System ${l.systemQty}', style: TextStyle(fontSize: 12.5, color: W.ink2(context))),
                    if (_editable && l.moved && l.systemNow != null)
                      WPill('Now ${l.systemNow}', tone: WTone.amber, icon: Icons.swap_vert_rounded),
                    if (v != null) WPill(v == 0 ? 'Match' : (v > 0 ? '+$v' : '$v'), tone: tone),
                    if (!_editable && l.appliedChange != null && l.appliedChange != 0)
                      WPill('Applied ${l.appliedChange! > 0 ? '+' : ''}${l.appliedChange}', tone: WTone.blue),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: TextField(
              controller: _ctrls[l.id],
              focusNode: _nodes[l.id],
              enabled: _editable,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (t) => _onChanged(l, t),
              onSubmitted: (_) {
                _flush();
                _next(l, shown);
              },
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'Count',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(W.rMd)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
