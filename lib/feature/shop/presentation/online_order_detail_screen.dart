import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:meherinMart/core/widgets/web_ui.dart';

import '../../payroll/presentation/payroll_common.dart';
import '../data/shop_models.dart';
import '../data/shop_repo.dart';
import 'shop_common.dart';

/// একটা অনলাইন অর্ডার — ওয়েবের অর্ডার কার্ডের মতো: কাস্টমার, পণ্যের টেবিল, মোট,
/// আর নিচে Confirm / Mark delivered / Cancel। স্ট্যাটাস বদলালে pop করে true ফেরত দেয়।
class OnlineOrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OnlineOrderDetailScreen({super.key, required this.orderId});

  @override
  State<OnlineOrderDetailScreen> createState() => _OnlineOrderDetailScreenState();
}

class _OnlineOrderDetailScreenState extends State<OnlineOrderDetailScreen> {
  final _repo = const ShopRepo();

  ShopOrder? _order;
  bool _loading = true;
  bool _busy = false;
  bool _changed = false;
  String? _error;

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
    final (o, err) = await _repo.order(context, widget.orderId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (o == null) {
        _error = err;
      } else {
        _order = o;
      }
    });
  }

  Future<void> _act(String action, {bool cash = false}) async {
    setState(() => _busy = true);
    final err = await _repo.changeStatus(widget.orderId, action, cashReceived: cash);
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      payToast(context, err, error: true);
      return;
    }
    _changed = true;
    payToast(context, switch (action) {
      'confirm' => 'Order confirmed. Stock is reserved.',
      'deliver' => 'Order delivered and invoiced.',
      _ => 'Order cancelled.',
    });
    _load();
  }

  Future<void> _confirm() async {
    final yes = await _ask(
        title: 'Confirm this order?',
        body: 'Stock for the items is reserved for this customer.',
        action: 'Confirm order',
        danger: false);
    if (yes && mounted) _act('confirm');
  }

  Future<void> _cancel(ShopOrder o) async {
    final yes = await _ask(
        title: 'Cancel ${o.orderNo}?',
        body: o.stockDeducted
            ? 'Reserved stock goes back to the inventory.'
            : 'The customer\'s order will be cancelled.',
        action: 'Cancel order',
        danger: true);
    if (yes && mounted) _act('cancel');
  }

  Future<bool> _ask({required String title, required String body, required String action, required bool danger}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: W.surface(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(W.rLg)),
        title: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: W.ink(ctx))),
        content: Text(body, style: TextStyle(color: W.ink2(ctx))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Back')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action, style: TextStyle(color: danger ? W.redInk(ctx) : W.blue(ctx), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _deliver(ShopOrder o) async {
    var cash = true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: W.surface(ctx),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(W.rLg)),
          title: Text('Mark as delivered',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: W.ink(ctx))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('An invoice for ${taka(o.total)} is created for ${o.customerName}.',
                  style: TextStyle(color: W.ink2(ctx))),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: cash,
                title: const Text('Cash received'),
                subtitle: Text(cash
                    ? 'The full amount is added to your cash account.'
                    : 'The invoice stays unpaid (due). Receive the money later.'),
                onChanged: (v) => setD(() => cash = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Back')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Delivered', style: TextStyle(color: W.blue(ctx), fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
    if (ok == true && mounted) _act('deliver', cash: cash);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _changed);
      },
      child: AppScaffold(
        appBar: AppBar(
          title: Text(_order?.orderNo ?? 'Order', style: AppTextStyle.titleMedium(context)),
          actions: [
            IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: (_loading || _busy) ? null : _load),
          ],
        ),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    if (_loading && _order == null) return const Center(child: CircularProgressIndicator());
    if (_error != null && _order == null) {
      return WEmpty(
        icon: Icons.error_outline,
        title: 'Could not load this order',
        body: _error!,
        actionLabel: 'Try again',
        onAction: _load,
      );
    }
    final o = _order!;
    final (label, tone) = orderStatusStyle(o.status);
    final showActions = o.isOpen && o.canEdit;
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, showActions ? 110 : 28),
          children: [
            WPanel(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text.rich(TextSpan(
                            text: o.orderNo,
                            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: W.ink(context)),
                            children: [
                              TextSpan(
                                text: '  · ${o.customerName}',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: W.muted(context)),
                              ),
                            ],
                          )),
                        ),
                        const SizedBox(width: 8),
                        WPill(label, tone: tone, strike: o.status == 'cancelled'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Text(orderWhen(o.createdAt), style: TextStyle(fontSize: 13, color: W.muted(context))),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _copyRow(Icons.phone_outlined, o.phone, 'Phone number', bold: true),
                        if (o.address.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _copyRow(Icons.place_outlined, o.address, 'Address'),
                        ],
                        if (o.invoiceNo != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Invoice ${o.invoiceNo} · paid ${taka(o.paidAmount)} · due ${taka(o.dueAmount)}',
                            style: TextStyle(fontSize: 13, color: W.muted(context)),
                          ),
                        ],
                        if (o.note.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Note: ${o.note}', style: TextStyle(fontSize: 13, color: W.muted(context))),
                        ],
                      ],
                    ),
                  ),
                  _table(o),
                ],
              ),
            ),
            if (showActions)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
                child: Text(
                  o.stockDeducted
                      ? 'Stock for these items is reserved.'
                      : 'Stock is reserved when you confirm the order.',
                  style: TextStyle(fontSize: 13, color: W.muted(context)),
                ),
              ),
          ],
        ),
        if (showActions) Positioned(left: 0, right: 0, bottom: 0, child: _actions(o)),
        if (_busy)
          const Positioned.fill(
            child: ColoredBox(color: Color(0x55000000), child: Center(child: CircularProgressIndicator())),
          ),
      ],
    );
  }

  /// ওয়েবের .ot টেবিল: Product · Qty · Price · Total
  Widget _table(ShopOrder o) {
    TextStyle head() => TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: W.muted(context));
    TextStyle num() => TextStyle(fontSize: 14, color: W.ink(context), fontFeatures: W.tabular);
    Widget cell(String t, {int flex = 1, TextStyle? style, TextAlign align = TextAlign.right}) =>
        Expanded(flex: flex, child: Text(t, textAlign: align, style: style));

    Widget row(Widget child, {Color? bg}) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: bg,
            border: Border(top: BorderSide(color: W.line(context))),
          ),
          child: child,
        );

    return Column(
      children: [
        row(
          Row(children: [
            cell('Product', flex: 5, style: head(), align: TextAlign.left),
            cell('Qty', flex: 2, style: head()),
            cell('Price', flex: 3, style: head()),
            cell('Total', flex: 3, style: head()),
          ]),
          bg: W.soft(context),
        ),
        for (final it in o.items)
          row(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cell(it.name, flex: 5, style: TextStyle(fontSize: 14, color: W.ink(context)), align: TextAlign.left),
              cell('${it.qty}', flex: 2, style: num()),
              cell(taka(it.unitPrice), flex: 3, style: num()),
              cell(taka(it.lineTotal), flex: 3, style: num()),
            ],
          )),
        if (o.deliveryCharge > 0)
          row(Row(children: [
            cell('Delivery', flex: 8, style: TextStyle(fontSize: 14, color: W.ink(context)), align: TextAlign.left),
            cell(taka(o.deliveryCharge), flex: 3, style: num()),
          ])),
        row(
          Row(children: [
            cell('Total',
                flex: 8,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: W.ink(context)),
                align: TextAlign.left),
            cell(taka(o.total),
                flex: 3,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: W.ink(context), fontFeatures: W.tabular)),
          ]),
          bg: W.soft(context),
        ),
      ],
    );
  }

  Widget _actions(ShopOrder o) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: W.surface(context),
        border: Border(top: BorderSide(color: W.line(context))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: _busy ? null : () => _cancel(o),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 46),
                  foregroundColor: W.redInk(context),
                  side: BorderSide(color: W.redLine(context)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(W.rMd)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: FilledButton.icon(
                onPressed: _busy ? null : (o.isPending ? _confirm : () => _deliver(o)),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 46),
                  backgroundColor: W.blue(context),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(W.rMd)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                icon: Icon(o.isPending ? Icons.check_circle_outline : Icons.local_shipping_outlined, size: 18),
                label: Text(o.isPending ? 'Confirm order' : 'Mark delivered'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _copyRow(IconData icon, String text, String what, {bool bold = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        payToast(context, '$what copied.');
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 16, color: W.muted(context)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                    color: bold ? W.ink(context) : W.ink2(context))),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 2),
            child: Icon(Icons.copy_rounded, size: 14, color: W.muted(context)),
          ),
        ],
      ),
    );
  }
}
