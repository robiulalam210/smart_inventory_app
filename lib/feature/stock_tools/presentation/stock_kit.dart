import 'dart:async';

import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:meherinMart/core/widgets/web_ui.dart';

import '../data/stock_models.dart';
import '../data/stock_repo.dart';

/// ছোট সাহায্যকারী: টাকার লেখা, তারিখ, বার্তা

String fmtMoney(num v) => '৳ ${formatNumberAll(v.toDouble())}';

String fmtQty(num v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String fmtDate(DateTime? d) => d == null ? '—' : '${d.day} ${_months[d.month - 1]} ${d.year}';

String fmtDateTime(DateTime? d) {
  if (d == null) return '—';
  final l = d.toLocal();
  final h = l.hour % 12 == 0 ? 12 : l.hour % 12;
  final m = l.minute.toString().padLeft(2, '0');
  return '${l.day} ${_months[l.month - 1]}, $h:$m ${l.hour >= 12 ? 'PM' : 'AM'}';
}

void stockToast(BuildContext context, String message, {bool error = false}) {
  showCustomToast(
    context: context,
    title: error ? 'Something went wrong' : 'Done',
    description: message,
    type: error ? ToastificationType.error : ToastificationType.success,
    icon: error ? Icons.error_outline : Icons.check_circle_outline,
    primaryColor: error ? AppColors.danger : AppColors.success,
    duration: const Duration(seconds: 3),
  );
}

/// Desktop এর main area তে বসলে (showAppBar = false) নিজস্ব AppBar লাগে না — মাথায় শিরোনাম সারি দেখায়।
class StockScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showAppBar;
  final List<Widget> actions;
  final Widget body;

  const StockScaffold({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.showAppBar,
    this.actions = const [],
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: showAppBar
          ? AppBar(title: Text(title, style: AppTextStyle.titleMedium(context)), actions: actions)
          : null,
      body: showAppBar
          ? body
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: W.ink(context))),
                            if (subtitle.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(subtitle, style: TextStyle(fontSize: 13.5, color: W.muted(context))),
                              ),
                          ],
                        ),
                      ),
                      ...actions,
                    ],
                  ),
                ),
                Expanded(child: body),
              ],
            ),
    );
  }
}

/// পণ্য খুঁজে বাছার ঘর — নাম বা SKU লিখুন; SKU লিখে Enter চাপলে সরাসরি বাছা হয় (scanner ও চলে)।
class ProductPicker extends StatefulWidget {
  final ValueChanged<ProductHit> onPicked;
  final String hint;
  final bool autofocus;

  const ProductPicker({
    super.key,
    required this.onPicked,
    this.hint = 'Search product by name, or scan / type the SKU and press Enter',
    this.autofocus = false,
  });

  @override
  State<ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends State<ProductPicker> {
  final _repo = const StockRepo();
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _t;
  List<ProductHit> _results = [];
  bool _searching = false;
  int _req = 0;
  bool _enterPending = false;

  @override
  void dispose() {
    _t?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _t?.cancel();
    if (v.trim().isEmpty) {
      setState(() {
        _results = [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    _t = Timer(const Duration(milliseconds: 250), () => _search(v.trim()));
  }

  Future<void> _search(String q) async {
    final id = ++_req;
    final (list, _) = await _repo.searchProducts(context, q);
    if (!mounted || id != _req) return;
    setState(() {
      _results = list ?? [];
      _searching = false;
    });
    if (_enterPending) {
      _enterPending = false;
      _pickBest(q);
    }
  }

  void _pickBest(String q) {
    if (_results.isEmpty) return;
    final exact = _results.where((p) => p.sku.toLowerCase() == q.toLowerCase());
    _pick(exact.isNotEmpty ? exact.first : _results.first);
  }

  void _pick(ProductHit p) {
    _t?.cancel();
    _ctrl.clear();
    setState(() => _results = []);
    widget.onPicked(p);
    _focus.requestFocus();
  }

  void _submit(String v) {
    final q = v.trim();
    if (q.isEmpty) return;
    if (_searching) {
      _enterPending = true;
      return;
    }
    _pickBest(q);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _ctrl,
          focusNode: _focus,
          autofocus: widget.autofocus,
          onChanged: _onChanged,
          onSubmitted: _submit,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(fontSize: 13.5, color: W.muted(context)),
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _searching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : null,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(W.rMd)),
          ),
        ),
        if (_ctrl.text.trim().isNotEmpty && !_searching)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 280),
            decoration: BoxDecoration(
              color: W.surface(context),
              border: Border.all(color: W.line(context)),
              borderRadius: BorderRadius.circular(W.rMd),
            ),
            child: _results.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text('No product matches “${_ctrl.text.trim()}”',
                        style: TextStyle(fontSize: 13.5, color: W.muted(context))),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: W.line(context)),
                    itemBuilder: (_, i) {
                      final p = _results[i];
                      return ListTile(
                        dense: true,
                        onTap: () => _pick(p),
                        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(p.sku, style: TextStyle(color: W.muted(context), fontSize: 12)),
                        trailing: Text('In stock ${p.stock}', style: TextStyle(color: W.muted(context), fontSize: 12)),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}

/// ত্রুটি + আবার চেষ্টা
class StockError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const StockError({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => WEmpty(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load',
        body: message,
        actionLabel: 'Try again',
        onAction: onRetry,
      );
}
