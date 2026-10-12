import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/web_ui.dart';

import '../data/stock_models.dart';
import '../data/stock_repo.dart';
import 'stock_kit.dart';

/// Expiry Alerts — মেয়াদ পেরোনো ও শিগগিরই পেরোনো ব্যাচ, আর নষ্ট মাল write-off।
class ExpiryScreen extends StatefulWidget {
  final bool showAppBar;
  const ExpiryScreen({super.key, this.showAppBar = true});

  @override
  State<ExpiryScreen> createState() => _ExpiryScreenState();
}

class _ExpiryScreenState extends State<ExpiryScreen> {
  final _repo = const StockRepo();
  ExpiryReport _report = const ExpiryReport();
  bool _loading = true;
  String? _error;
  String _status = 'alerts'; // alerts | expired | expiring | all
  int _days = 30;
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
    final (r, err) = await _repo.expiry(context, days: _days, status: _status);
    if (!mounted || id != _req) return;
    setState(() {
      _loading = false;
      if (r == null) {
        _error = err;
      } else {
        _report = r;
      }
    });
  }

  Future<void> _writeOff(ExpiryBatch b) async {
    final reasonCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Write off this batch?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${b.productName}${b.batchNo.isNotEmpty ? ' · batch ${b.batchNo}' : ''}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${fmtQty(b.qtyRemaining)} units (${fmtMoney(b.costValue)}) will be removed from stock and recorded as bad stock.'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(labelText: 'Note (optional)', isDense: true, border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Write off')),
        ],
      ),
    );
    final reason = reasonCtrl.text.trim();
    reasonCtrl.dispose();
    if (ok != true || !mounted) return;
    final (msg, err) = await _repo.writeOff(b.id, reason: reason);
    if (!mounted) return;
    if (err != null) {
      stockToast(context, err, error: true);
      return;
    }
    stockToast(context, msg ?? 'Written off');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final r = _report;
    return StockScaffold(
      title: 'Expiry Alerts',
      subtitle: 'Batches that have expired or will expire soon',
      showAppBar: widget.showAppBar,
      actions: [
        IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh_rounded), onPressed: _loading ? null : _load),
      ],
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            WSumBar(items: [
              WSum('Expired', '${r.expired}', color: r.expired > 0 ? W.redInk(context) : null),
              WSum('Expiring in ${r.days}d', '${r.expiring}', color: r.expiring > 0 ? W.amberInk(context) : null),
              WSum('Stock at risk', fmtMoney(r.expiredValue + r.expiringValue)),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final f in const [
                      ('alerts', 'Alerts'),
                      ('expired', 'Expired'),
                      ('expiring', 'Expiring soon'),
                      ('all', 'All batches'),
                    ]) ...[
                      WChip(
                          label: f.$2,
                          selected: _status == f.$1,
                          onTap: () {
                            setState(() => _status = f.$1);
                            _load();
                          }),
                      const SizedBox(width: 6),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text('Soon means within', style: TextStyle(fontSize: 12.5, color: W.muted(context))),
                    const SizedBox(width: 8),
                    for (final d in const [7, 15, 30, 60, 90]) ...[
                      WChip(
                          label: '$d days',
                          selected: _days == d,
                          onTap: () {
                            setState(() => _days = d);
                            _load();
                          }),
                      const SizedBox(width: 6),
                    ],
                  ],
                ),
              ),
            ),
            if (_loading)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              StockError(message: _error!, onRetry: _load)
            else if (r.batches.isEmpty)
              WEmpty(
                icon: Icons.verified_outlined,
                title: _status == 'alerts' ? 'Nothing is expiring' : 'No batches here',
                body: 'Add an expiry date when you buy a product, and it will show up here.',
              )
            else
              for (final b in r.batches)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: _BatchCard(batch: b, onWriteOff: b.qtyRemaining > 0 ? () => _writeOff(b) : null),
                ),
          ],
        ),
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final ExpiryBatch batch;
  final VoidCallback? onWriteOff;
  const _BatchCard({required this.batch, this.onWriteOff});

  @override
  Widget build(BuildContext context) {
    final b = batch;
    final tone = switch (b.status) {
      'expired' => WTone.red,
      'expiring' => WTone.amber,
      _ => WTone.green,
    };
    final label = b.status == 'expired'
        ? 'Expired ${b.daysLeft.abs()}d ago'
        : (b.daysLeft == 0 ? 'Expires today' : '${b.daysLeft}d left');
    return WPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(b.productName,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              WPill(label, tone: tone),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${b.sku}${b.category.isNotEmpty ? ' · ${b.category}' : ''}${b.batchNo.isNotEmpty ? ' · batch ${b.batchNo}' : ''}',
            style: TextStyle(fontSize: 12.5, color: W.muted(context)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              Text('Expires ${fmtDate(b.expiryDate)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text('${fmtQty(b.qtyRemaining)} left', style: TextStyle(fontSize: 13, color: W.ink2(context))),
              Text(fmtMoney(b.costValue), style: TextStyle(fontSize: 13, color: W.ink2(context))),
              if (b.supplier.isNotEmpty) Text(b.supplier, style: TextStyle(fontSize: 13, color: W.muted(context))),
            ],
          ),
          if (onWriteOff != null && b.status != 'ok')
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onWriteOff,
                style: TextButton.styleFrom(foregroundColor: W.redInk(context)),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Write off'),
              ),
            ),
        ],
      ),
    );
  }
}
