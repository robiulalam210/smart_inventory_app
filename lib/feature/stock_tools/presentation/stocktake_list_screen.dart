import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/web_ui.dart';

import '../data/stock_models.dart';
import '../data/stock_repo.dart';
import 'stock_kit.dart';
import 'stocktake_count_screen.dart';

/// Stocktake — দোকানের মাল গুনে সিস্টেমের স্টকের সাথে মিলানো।
/// এখানে গণনার তালিকা আর নতুন গণনা শুরু; গোনার কাজ StocktakeCountScreen এ।
class StocktakeListScreen extends StatefulWidget {
  final bool showAppBar;
  const StocktakeListScreen({super.key, this.showAppBar = true});

  @override
  State<StocktakeListScreen> createState() => _StocktakeListScreenState();
}

class _StocktakeListScreenState extends State<StocktakeListScreen> {
  final _repo = const StockRepo();
  List<StocktakeHead> _items = [];
  bool _loading = true;
  String? _error;
  String _filter = ''; // '' | draft | applied | cancelled

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final (list, err) = await _repo.counts(context);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (list == null) {
        _error = err;
      } else {
        _items = list;
      }
    });
  }

  List<StocktakeHead> get _shown => _filter.isEmpty ? _items : _items.where((e) => e.status == _filter).toList();

  Future<void> _open(StocktakeHead h) async {
    await AppRoutes.push(context, StocktakeCountScreen(id: h.id));
    if (mounted) _load();
  }

  Future<void> _start() async {
    final created = await showDialog<StocktakeHead>(context: context, builder: (_) => const _StartDialog());
    if (created != null && mounted) {
      await _open(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StockScaffold(
      title: 'Stocktake',
      subtitle: 'Count the shelves and match the system to what is really there',
      showAppBar: widget.showAppBar,
      actions: [
        IconButton(tooltip: 'Refresh', icon: const Icon(Icons.refresh_rounded), onPressed: _loading ? null : _load),
        const SizedBox(width: 4),
        FilledButton.icon(
          onPressed: _start,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('New count'),
        ),
        const SizedBox(width: 12),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final f in const [
                    ('', 'All'),
                    ('draft', 'In progress'),
                    ('applied', 'Applied'),
                    ('cancelled', 'Cancelled'),
                  ]) ...[
                    WChip(label: f.$2, selected: _filter == f.$1, onTap: () => setState(() => _filter = f.$1)),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return StockError(message: _error!, onRetry: _load);
    final rows = _shown;
    if (rows.isEmpty) {
      return WEmpty(
        icon: Icons.fact_check_outlined,
        title: _items.isEmpty ? 'No counts yet' : 'Nothing here',
        body: _items.isEmpty ? 'Start a count, type what you counted, then match the system.' : '',
        actionLabel: _items.isEmpty ? 'Start a count' : null,
        onAction: _start,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: rows.length,
        itemBuilder: (_, i) => _CountCard(head: rows[i], onTap: () => _open(rows[i])),
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  final StocktakeHead head;
  final VoidCallback onTap;
  const _CountCard({required this.head, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final h = head;
    final s = h.summary;
    final tone = switch (h.status) {
      'draft' => WTone.amber,
      'applied' => WTone.green,
      _ => WTone.muted,
    };
    return WPanel(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(h.title.isEmpty ? h.number : h.title,
                    style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              WPill(h.statusLabel, tone: tone),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${h.number}${h.categoryName.isNotEmpty ? ' · ${h.categoryName}' : ' · All products'} · ${h.createdBy} · ${fmtDateTime(h.createdAt)}',
            style: TextStyle(fontSize: 12.5, color: W.muted(context)),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: s.progress, minHeight: 6, backgroundColor: W.tint(context)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              Text('${s.counted}/${s.total} counted', style: TextStyle(fontSize: 12.5, color: W.ink2(context))),
              if (s.differing > 0) Text('${s.differing} differ', style: TextStyle(fontSize: 12.5, color: W.amberInk(context))),
              if (s.counted > 0)
                Text('Net ${fmtMoney(s.netValue)}',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: s.netValue < 0 ? W.redInk(context) : W.greenInk(context))),
            ],
          ),
        ],
      ),
    );
  }
}

class _StartDialog extends StatefulWidget {
  const _StartDialog();

  @override
  State<_StartDialog> createState() => _StartDialogState();
}

class _StartDialogState extends State<_StartDialog> {
  final _repo = const StockRepo();
  final _title = TextEditingController();
  final _note = TextEditingController();
  List<({int id, String name})> _cats = [];
  int? _cat;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final (list, _) = await _repo.categories(context);
      if (mounted && list != null) setState(() => _cats = list);
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final (head, err) = await _repo.startCount(title: _title.text.trim(), categoryId: _cat, note: _note.text.trim());
    if (!mounted) return;
    if (head == null) {
      setState(() {
        _saving = false;
        _error = err;
      });
      return;
    }
    Navigator.pop(context, head);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start a stock count'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'The system quantities are saved as they are now. Sales made while you count do not spoil the result.',
                style: TextStyle(fontSize: 13, color: W.muted(context)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _title,
                decoration: InputDecoration(
                  labelText: 'Title (optional)',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(W.rMd)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: _cat,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Count',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(W.rMd)),
                ),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('All products')),
                  for (final c in _cats) DropdownMenuItem<int?>(value: c.id, child: Text(c.name)),
                ],
                onChanged: (v) => setState(() => _cat = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(W.rMd)),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(_error!, style: TextStyle(color: W.redInk(context), fontSize: 13)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _saving ? null : _go, child: Text(_saving ? 'Starting…' : 'Start counting')),
      ],
    );
  }
}
