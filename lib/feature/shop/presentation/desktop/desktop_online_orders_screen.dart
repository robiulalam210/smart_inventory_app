import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:meherinMart/core/widgets/web_ui.dart';
import 'package:meherinMart/desktop/widgets/desk_kit.dart';
import 'package:meherinMart/feature/lab_dashboard/presentation/widgets/dash_kit.dart' show DashColors;
import 'package:meherinMart/feature/payroll/presentation/payroll_common.dart';

import '../../data/shop_models.dart';
import '../../data/shop_repo.dart';
import '../shop_common.dart';

/// Online Orders — ডেস্কটপ ডিজাইন (বাম: অর্ডারের তালিকা, ডান: বাছাই করা অর্ডারের বিস্তারিত)।
/// API: GET /api/shop/orders/ · GET /api/shop/orders/<id>/ · POST /api/shop/orders/<id>/status/
class DesktopOnlineOrdersScreen extends StatefulWidget {
  const DesktopOnlineOrdersScreen({super.key});

  @override
  State<DesktopOnlineOrdersScreen> createState() => _DesktopOnlineOrdersScreenState();
}

class _DesktopOnlineOrdersScreenState extends State<DesktopOnlineOrdersScreen> {
  final _repo = const ShopRepo();
  final _search = TextEditingController();

  String _status = 'pending';
  String _q = '';
  int _page = 1;
  ShopOrderPage? _data;
  ShopOrder? _selected;
  bool _loading = true;
  bool _acting = false;
  String? _error;
  int _req = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({bool keepSelection = true}) async {
    final id = ++_req;
    setState(() {
      _loading = true;
      _error = null;
    });
    final (d, err) = await _repo.orders(context, status: _status, q: _q, page: _page);
    if (!mounted || id != _req) return;
    setState(() {
      _loading = false;
      if (d == null) {
        _error = err;
        return;
      }
      _data = d;
      final keepId = keepSelection ? _selected?.id : null;
      _selected = d.items.where((o) => o.id == keepId).firstOrNull ?? (d.items.isEmpty ? null : d.items.first);
    });
  }

  Future<void> _act(ShopOrder o, String action, {bool cash = false}) async {
    setState(() => _acting = true);
    final err = await _repo.changeStatus(o.id, action, cashReceived: cash);
    if (!mounted) return;
    setState(() => _acting = false);
    if (err != null) {
      payToast(context, err, error: true);
      return;
    }
    payToast(context, action == 'confirm' ? '${o.orderNo} confirmed.' : action == 'deliver' ? '${o.orderNo} delivered.' : '${o.orderNo} cancelled.');
    // বর্তমান ট্যাবে অর্ডারটা আর না-ও থাকতে পারে, তাই বাছাই সরিয়ে আবার আনি
    await _load(keepSelection: false);
  }

  Future<void> _deliver(ShopOrder o) async {
    var cash = true;
    final ok = await showDeskDialog<bool>(
      context,
      StatefulBuilder(builder: (ctx, setD) {
        final c = DashColors(ctx);
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Mark ${o.orderNo} as delivered', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.ink)),
            const SizedBox(height: 6),
            Text('An invoice is created and stock is deducted from the inventory.', style: TextStyle(color: c.muted)),
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: cash,
              title: const Text('Cash received'),
              subtitle: Text(cash ? 'The full ৳${o.total.toStringAsFixed(2)} is added to your cash account.' : 'The invoice stays due; collect it later with a Money Receipt.'),
              onChanged: (v) => setD(() => cash = v),
            ),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              DeskButton(label: 'Cancel', outlined: true, onPressed: () => Navigator.pop(ctx, false)),
              const SizedBox(width: 10),
              DeskButton(label: 'Deliver', icon: Icons.local_shipping_outlined, onPressed: () => Navigator.pop(ctx, true)),
            ]),
          ]),
        );
      }),
      width: 460,
    );
    if (ok == true && mounted) _act(o, 'deliver', cash: cash);
  }

  Future<void> _cancel(ShopOrder o) async {
    final ok = await payConfirm(context,
        title: 'Cancel ${o.orderNo}?',
        body: o.stockDeducted ? 'The reserved stock goes back to the inventory.' : 'This order will be marked as cancelled.',
        action: 'Cancel order');
    if (ok && mounted) _act(o, 'cancel');
  }

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    final d = _data;
    return DeskPage(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DeskPageHeader(
          title: 'Online Orders',
          subtitle: 'Orders placed from your online shop — confirm, deliver or cancel.',
          actions: [
            if (d != null && d.shopUrl.isNotEmpty)
              DeskButton(
                label: 'Copy shop link',
                icon: Icons.link_rounded,
                outlined: true,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: d.shopUrl));
                  payToast(context, 'Shop link copied.');
                },
              ),
            DeskButton(label: 'Refresh', icon: Icons.refresh_rounded, outlined: true, onPressed: _loading ? null : () => _load()),
          ],
        ),
        const SizedBox(height: 16),
        if (d != null && !d.shopIsOpen)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DeskCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Icon(Icons.pause_circle_outline_rounded, color: c.amber),
                const SizedBox(width: 10),
                Expanded(
                    child: Text('Your shop is not accepting new orders right now. Turn it back on in Shop Settings.',
                        style: TextStyle(color: c.ink2))),
              ]),
            ),
          ),
        _statusTabs(context),
        const SizedBox(height: 12),
        if (_error != null && d == null)
          DeskState(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load orders',
            message: _error,
            color: c.red,
            action: DeskButton(label: 'Try again', icon: Icons.refresh_rounded, onPressed: _load),
          )
        else if (d == null)
          DeskState.loading()
        else
          LayoutBuilder(builder: (context, box) {
            final wide = box.maxWidth >= 980;
            final list = _list(context, d);
            final detail = _selected == null ? _emptyDetail(context) : _detail(context, _selected!);
            if (!wide) return Column(children: [list, const SizedBox(height: 14), detail]);
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 11, child: list),
              const SizedBox(width: 16),
              Expanded(flex: 9, child: detail),
            ]);
          }),
      ]),
    );
  }

  Widget _statusTabs(BuildContext context) {
    final c = DashColors(context);
    final counts = _data?.counts ?? const <String, int>{};
    return Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
      for (final s in ShopRepo.statuses)
        WChip(
          label: s == 'all' ? 'All' : '${s[0].toUpperCase()}${s.substring(1)}',
          count: counts[s],
          selected: _status == s,
          onTap: () {
            if (_status == s) return;
            setState(() {
              _status = s;
              _page = 1;
            });
            _load(keepSelection: false);
          },
        ),
      const SizedBox(width: 8),
      DeskSearchField(
        controller: _search,
        hint: 'Search order no, name or phone…',
        width: 320,
        onChanged: (v) {
          _q = v;
          _page = 1;
          Future.delayed(const Duration(milliseconds: 350), () {
            if (mounted && _q == v) _load(keepSelection: false);
          });
        },
        onClear: () {
          _q = '';
          _page = 1;
          _load(keepSelection: false);
        },
      ),
      if (_loading && _data != null) SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: c.muted)),
    ]);
  }

  Widget _list(BuildContext context, ShopOrderPage d) {
    final c = DashColors(context);
    if (d.items.isEmpty) {
      return DeskState(
        icon: Icons.shopping_bag_outlined,
        title: _q.isNotEmpty ? 'No orders match “$_q”' : 'No ${_status == 'all' ? '' : '$_status '}orders',
        message: 'New online orders show up here as soon as customers place them.',
      );
    }
    const size = 20;
    final from = (_page - 1) * size + 1;
    final to = from + d.items.length - 1;
    return DeskCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(children: [
            _h('Order', 3, c),
            _h('Customer', 4, c),
            _h('Placed', 3, c),
            _h('Total', 2, c, right: true),
            SizedBox(
                width: 96,
                child: Text('STATUS',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: .5, color: c.muted))),
          ]),
        ),
        Divider(height: 1, color: c.line),
        for (final o in d.items) _row(context, o),
        WPager(page: _page, totalPages: d.totalPages, count: d.count, from: from, to: to, onPage: (p) {
          setState(() => _page = p);
          _load(keepSelection: false);
        }),
      ]),
    );
  }

  Widget _h(String t, int flex, DashColors c, {bool right = false}) {
    final w = Text(t.toUpperCase(),
        textAlign: right ? TextAlign.right : TextAlign.left,
        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: .5, color: c.muted));
    return Expanded(flex: flex, child: w);
  }

  Widget _row(BuildContext context, ShopOrder o) {
    final c = DashColors(context);
    final on = _selected?.id == o.id;
    final (label, tone) = orderStatusStyle(o.status);
    return InkWell(
      onTap: () => setState(() => _selected = o),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: on ? c.blue.withValues(alpha: c.dark ? .14 : .07) : null,
          border: Border(
            bottom: BorderSide(color: c.line),
            left: BorderSide(color: on ? c.blue : Colors.transparent, width: 3),
          ),
        ),
        child: Row(children: [
          Expanded(
            flex: 3,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(o.orderNo, style: TextStyle(fontWeight: FontWeight.w700, color: c.ink)),
              Text('${o.itemCount} item${o.itemCount == 1 ? '' : 's'}', style: TextStyle(fontSize: 12, color: c.muted)),
            ]),
          ),
          Expanded(
            flex: 4,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(o.customerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.ink)),
              Text(o.phone, style: TextStyle(fontSize: 12, color: c.muted)),
            ]),
          ),
          Expanded(
            flex: 3,
            child: Text(orderWhen(o.createdAt), style: TextStyle(fontSize: 12.5, color: c.ink2)),
          ),
          Expanded(
            flex: 2,
            child: Text('৳${NumberFormat('#,##0.##').format(o.total)}',
                textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w700, color: c.ink)),
          ),
          SizedBox(width: 96, child: Align(alignment: Alignment.centerRight, child: WPill(label, tone: tone, strike: o.status == 'cancelled'))),
        ]),
      ),
    );
  }

  Widget _emptyDetail(BuildContext context) => const DeskState(
        icon: Icons.receipt_long_outlined,
        title: 'Select an order',
        message: 'Pick an order from the list to see items, address and actions.',
      );

  Widget _kv(DashColors c, IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 17, color: c.muted),
          const SizedBox(width: 10),
          SizedBox(width: 76, child: Text(label, style: TextStyle(fontSize: 13, color: c.muted))),
          Expanded(child: SelectableText(value.isEmpty ? '—' : value, style: TextStyle(fontSize: 13.5, color: c.ink))),
        ]),
      );

  Widget _detail(BuildContext context, ShopOrder o) {
    final c = DashColors(context);
    final money = NumberFormat('#,##0.00');
    final (label, tone) = orderStatusStyle(o.status);
    return DeskCard(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o.orderNo, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c.ink)),
                const SizedBox(height: 2),
                Text(orderWhen(o.createdAt), style: TextStyle(fontSize: 13, color: c.muted)),
              ]),
            ),
            WPill(label, tone: tone, strike: o.status == 'cancelled'),
          ]),
        ),
        Divider(height: 1, color: c.line),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
          child: Column(children: [
            _kv(c, Icons.person_outline_rounded, 'Customer', o.customerName),
            _kv(c, Icons.call_outlined, 'Phone', o.phone),
            _kv(c, Icons.location_on_outlined, 'Address', o.address),
            if (o.note.isNotEmpty) _kv(c, Icons.sticky_note_2_outlined, 'Note', o.note),
            if (o.invoiceNo != null) _kv(c, Icons.receipt_outlined, 'Invoice', o.invoiceNo!),
          ]),
        ),
        Divider(height: 1, color: c.line),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
          child: Column(children: [
            for (final i in o.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(i.name, style: TextStyle(fontWeight: FontWeight.w600, color: c.ink)),
                      Text('${i.qty} × ৳${money.format(i.unitPrice)}', style: TextStyle(fontSize: 12.5, color: c.muted)),
                    ]),
                  ),
                  Text('৳${money.format(i.lineTotal)}', style: TextStyle(fontWeight: FontWeight.w600, color: c.ink)),
                ]),
              ),
          ]),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(18, 4, 18, 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: c.tint, borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            _sum(c, 'Items', o.itemsTotal, money),
            _sum(c, 'Delivery', o.deliveryCharge, money),
            const Divider(height: 14),
            _sum(c, 'Total', o.total, money, bold: true),
            if (o.paidAmount != null) _sum(c, 'Paid', o.paidAmount!, money, color: c.green),
            if (o.dueAmount != null && o.dueAmount! > 0) _sum(c, 'Due', o.dueAmount!, money, color: c.red),
          ]),
        ),
        if (o.canEdit && o.isOpen)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Row(children: [
              if (o.isPending)
                Expanded(child: DeskButton(label: 'Confirm order', icon: Icons.check_rounded, onPressed: _acting ? null : () => _act(o, 'confirm')))
              else
                Expanded(child: DeskButton(label: 'Mark delivered', icon: Icons.local_shipping_outlined, onPressed: _acting ? null : () => _deliver(o))),
              const SizedBox(width: 10),
              DeskButton(label: 'Cancel', icon: Icons.close_rounded, outlined: true, onPressed: _acting ? null : () => _cancel(o)),
            ]),
          )
        else if (o.status == 'delivered')
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Text('Delivered orders can’t be cancelled — use a Sales Return instead.', style: TextStyle(fontSize: 12.5, color: c.muted)),
          ),
      ]),
    );
  }

  Widget _sum(DashColors c, String l, double v, NumberFormat f, {bool bold = false, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Expanded(child: Text(l, style: TextStyle(fontSize: 13.5, color: bold ? c.ink : c.muted, fontWeight: bold ? FontWeight.w800 : FontWeight.w500))),
          Text('৳${f.format(v)}', style: TextStyle(fontSize: bold ? 16 : 13.5, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: color ?? c.ink)),
        ]),
      );
}
