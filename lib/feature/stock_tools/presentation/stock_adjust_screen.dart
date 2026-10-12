import 'dart:async';

import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/web_ui.dart';

import '../data/stock_models.dart';
import '../data/stock_repo.dart';
import 'stock_kit.dart';

/// Stock Adjustment — এক পণ্যের স্টক হাতে ঠিক করা (নষ্ট, হারানো, ভুল এন্ট্রি…) আর সব বদলের ইতিহাস।
/// "Set new quantity" = গুনে পাওয়া মোট; "Add / remove" = +/−।
class StockAdjustScreen extends StatefulWidget {
  /// Desktop এর main area তে বসলে নিজস্ব AppBar লাগে না
  final bool showAppBar;
  const StockAdjustScreen({super.key, this.showAppBar = true});

  @override
  State<StockAdjustScreen> createState() => _StockAdjustScreenState();
}

class _StockAdjustScreenState extends State<StockAdjustScreen> {
  final _repo = const StockRepo();
  final _qtyCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;

  // form
  ProductHit? _product;
  bool _setMode = true; // true = Set new quantity, false = Add / remove
  String _reason = '';
  String? _formError;
  bool _saving = false;

  // history
  final List<AdjustmentEntry> _items = [];
  AdjustmentPage? _page;
  String _filterReason = '';
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _req = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) _loadMore();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFirst());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _qtyCtrl.dispose();
    _noteCtrl.dispose();
    _searchCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ───────── history ─────────

  Future<void> _loadFirst() async {
    final id = ++_req;
    setState(() {
      _loading = true;
      _error = null;
    });
    final (page, err) = await _repo.adjustments(context, q: _searchCtrl.text, reason: _filterReason);
    if (!mounted || id != _req) return;
    setState(() {
      _loading = false;
      if (page == null) {
        _error = err;
        return;
      }
      _page = page;
      _items
        ..clear()
        ..addAll(page.items);
    });
  }

  Future<void> _loadMore() async {
    final p = _page;
    if (_loadingMore || _loading || p == null || !p.hasMore) return;
    final id = _req;
    setState(() => _loadingMore = true);
    final (page, _) =
        await _repo.adjustments(context, q: _searchCtrl.text, reason: _filterReason, page: p.page + 1);
    if (!mounted || id != _req) return;
    setState(() {
      _loadingMore = false;
      if (page != null) {
        _page = page;
        _items.addAll(page.items);
      }
    });
  }

  // ───────── form ─────────

  int? get _qtyValue => int.tryParse(_qtyCtrl.text.trim().replaceFirst('+', ''));

  /// বদল (সংখ্যা) — preview এর জন্য
  int? get _change {
    final p = _product;
    final v = _qtyValue;
    if (p == null || v == null) return null;
    return _setMode ? v - p.stock : v;
  }

  void _pick(ProductHit p) {
    setState(() {
      _product = p;
      _formError = null;
      _qtyCtrl.text = _setMode ? '${p.stock}' : '';
    });
  }

  void _clearProduct() => setState(() {
        _product = null;
        _qtyCtrl.clear();
        _formError = null;
      });

  void _switchMode(bool set) {
    setState(() {
      _setMode = set;
      _qtyCtrl.text = set && _product != null ? '${_product!.stock}' : '';
      _formError = null;
    });
  }

  Future<void> _save() async {
    final p = _product;
    if (p == null) return setState(() => _formError = 'Choose a product first.');
    final v = _qtyValue;
    if (v == null) return setState(() => _formError = 'Enter a whole number.');
    if (_reason.isEmpty) return setState(() => _formError = 'Choose a reason.');
    final change = _setMode ? v - p.stock : v;
    if (change == 0) return setState(() => _formError = 'Nothing to change — the quantity is the same.');
    if (_setMode && v < 0) return setState(() => _formError = 'Quantity cannot be negative.');
    if (p.stock + change < 0) return setState(() => _formError = 'Stock cannot go below zero.');

    setState(() {
      _saving = true;
      _formError = null;
    });
    final (msg, err) = await _repo.adjust(
      p.id,
      newQty: _setMode ? v : null,
      change: _setMode ? null : v,
      reason: _reason,
      note: _noteCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (err != null) {
      setState(() => _formError = err);
      return;
    }
    stockToast(context, msg ?? 'Stock adjusted');
    setState(() {
      _product = null;
      _qtyCtrl.clear();
      _noteCtrl.clear();
      _reason = '';
    });
    _loadFirst();
  }

  // ───────── UI ─────────

  @override
  Widget build(BuildContext context) {
    return StockScaffold(
      title: 'Stock Adjustment',
      subtitle: 'Fix a product\'s stock by hand — damaged, lost, entry mistakes…',
      showAppBar: widget.showAppBar,
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _loading ? null : _loadFirst,
        ),
      ],
      body: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 1000;
        final pad = wide ? 24.0 : 12.0;
        final form = _buildForm(context);
        final history = _buildHistory(context);
        if (wide) {
          return Padding(
            padding: EdgeInsets.fromLTRB(pad, 8, pad, pad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 400, child: SingleChildScrollView(child: form)),
                const SizedBox(width: 16),
                Expanded(child: history),
              ],
            ),
          );
        }
        // ছোট screen: ফর্ম উপরে, ইতিহাস নিচে — একসাথে scroll
        return ListView(
          controller: _scroll,
          padding: EdgeInsets.all(pad),
          children: [form, const SizedBox(height: 16), ..._historyChildren(context)],
        );
      }),
    );
  }

  Widget _buildForm(BuildContext context) {
    final p = _product;
    final change = _change;
    final after = (p != null && change != null) ? p.stock + change : null;
    return WPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WPanelHead('Adjust stock'),
          const SizedBox(height: 14),
          if (p == null)
            ProductPicker(onPicked: _pick)
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: W.blueWash(context),
                border: Border.all(color: W.blueLine(context)),
                borderRadius: BorderRadius.circular(W.rMd),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(p.sku, style: TextStyle(color: W.muted(context), fontSize: 12.5)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('In stock', style: TextStyle(color: W.muted(context), fontSize: 12)),
                      Text('${p.stock}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                    ],
                  ),
                  IconButton(tooltip: 'Change product', icon: const Icon(Icons.close_rounded), onPressed: _clearProduct),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _modeButton('Set new quantity', _setMode, () => _switchMode(true))),
              const SizedBox(width: 8),
              Expanded(child: _modeButton('Add / remove', !_setMode, () => _switchMode(false))),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _qtyCtrl,
            enabled: p != null,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-]'))],
            onChanged: (_) => setState(() => _formError = null),
            decoration: InputDecoration(
              labelText: _setMode ? 'Counted quantity' : 'Change (use − to remove)',
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(W.rMd)),
            ),
          ),
          if (p != null && change != null && change != 0) ...[
            const SizedBox(height: 8),
            Text(
              '${p.stock} → $after   (${change > 0 ? '+' : ''}$change)',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: change > 0 ? W.greenInk(context) : W.redInk(context),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text('Reason', style: TextStyle(fontSize: 12.5, color: W.muted(context), fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final r in kManualReasons)
                WChip(label: r.label, selected: _reason == r.key, onTap: () => setState(() {
                      _reason = r.key;
                      _formError = null;
                    })),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Note (optional)',
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(W.rMd)),
            ),
          ),
          if (_formError != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_formError!, style: TextStyle(color: W.redInk(context), fontSize: 13)),
            ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 46)),
            icon: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check_rounded, size: 20),
            label: const Text('Save adjustment'),
          ),
        ],
      ),
    );
  }

  Widget _modeButton(String label, bool on, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 42),
        backgroundColor: on ? W.blueWash(context) : null,
        foregroundColor: on ? W.blueInk(context) : W.ink2(context),
        side: BorderSide(color: on ? W.blue(context) : W.line2(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(W.rMd)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  /// বড় screen: ইতিহাস নিজে scroll করে
  Widget _buildHistory(BuildContext context) {
    return ListView(
      controller: _scroll,
      padding: EdgeInsets.zero,
      children: _historyChildren(context),
    );
  }

  List<Widget> _historyChildren(BuildContext context) {
    final t = _page;
    return [
      if (t != null)
        WSumBar(
          margin: EdgeInsets.zero,
          items: [
            WSum('Net value', fmtMoney(t.netValue), color: t.netValue < 0 ? W.redInk(context) : W.greenInk(context)),
            WSum('Loss', fmtMoney(t.lossValue), color: W.redInk(context)),
            WSum('Gain', fmtMoney(t.gainValue), color: W.greenInk(context)),
          ],
        ),
      const SizedBox(height: 12),
      TextField(
        controller: _searchCtrl,
        onChanged: (_) {
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 350), _loadFirst);
        },
        decoration: InputDecoration(
          hintText: 'Search history (product, SKU, number, note)',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(W.rMd)),
        ),
      ),
      const SizedBox(height: 8),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            WChip(label: 'All', selected: _filterReason.isEmpty, onTap: () => _setFilter('')),
            for (final r in [...kManualReasons, const StockReason('count', 'Stock count')]) ...[
              const SizedBox(width: 6),
              WChip(label: r.label, selected: _filterReason == r.key, onTap: () => _setFilter(r.key)),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
      if (_loading)
        const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
      else if (_error != null)
        StockError(message: _error!, onRetry: _loadFirst)
      else if (_items.isEmpty)
        const WEmpty(
          icon: Icons.tune_rounded,
          title: 'No adjustments yet',
          body: 'Every stock change you make by hand shows up here.',
        )
      else ...[
        for (final e in _items) _AdjustTile(entry: e),
        if (_loadingMore)
          const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
      ],
    ];
  }

  void _setFilter(String key) {
    setState(() => _filterReason = key);
    _loadFirst();
  }
}

class _AdjustTile extends StatelessWidget {
  final AdjustmentEntry entry;
  const _AdjustTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final up = e.change > 0;
    return WPanel(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: up ? W.greenWash(context) : W.redWash(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${up ? '+' : ''}${e.change}',
              style: TextStyle(fontWeight: FontWeight.w800, color: up ? W.greenInk(context) : W.redInk(context)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.productName, style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${e.before} → ${e.after} · ${e.reasonLabel}${e.stocktakeNumber.isNotEmpty ? ' · ${e.stocktakeNumber}' : ''}',
                  style: TextStyle(fontSize: 12.5, color: W.muted(context)),
                ),
                if (e.note.isNotEmpty)
                  Text(e.note, style: TextStyle(fontSize: 12.5, color: W.ink2(context)), maxLines: 2, overflow: TextOverflow.ellipsis),
                Text('${e.number} · ${e.createdBy} · ${fmtDateTime(e.createdAt)}',
                    style: TextStyle(fontSize: 11.5, color: W.muted(context))),
              ],
            ),
          ),
          Text(fmtMoney(e.valueChange),
              style: TextStyle(fontWeight: FontWeight.w700, color: e.valueChange < 0 ? W.redInk(context) : W.greenInk(context))),
        ],
      ),
    );
  }
}
