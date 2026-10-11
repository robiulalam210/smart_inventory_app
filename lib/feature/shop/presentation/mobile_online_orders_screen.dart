import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:meherinMart/core/widgets/web_ui.dart';

import '../../payroll/presentation/payroll_common.dart';
import '../data/shop_models.dart';
import '../data/shop_repo.dart';
import 'mobile_shop_settings_screen.dart';
import 'online_order_detail_screen.dart';
import 'shop_common.dart';

/// Online Orders — ওয়েবের Online Orders পেজের মতো: শপ লিংক, status chip, সার্চ, অর্ডার কার্ড
class MobileOnlineOrdersScreen extends StatefulWidget {
  const MobileOnlineOrdersScreen({super.key});

  @override
  State<MobileOnlineOrdersScreen> createState() => _MobileOnlineOrdersScreenState();
}

class _MobileOnlineOrdersScreenState extends State<MobileOnlineOrdersScreen> {
  final _repo = const ShopRepo();
  final _search = TextEditingController();

  String _status = 'pending';
  String _q = '';
  int _page = 1;
  int _totalPages = 1;
  List<ShopOrder> _items = [];
  Map<String, int> _counts = {};
  bool _shopOpen = true;
  bool _canEdit = false;
  String _shopUrl = '';
  bool _loading = true;
  bool _loadingMore = false;
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

  Future<void> _load({bool more = false}) async {
    final id = ++_req;
    final page = more ? _page + 1 : 1;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _error = null;
      }
    });
    final (d, err) = await _repo.orders(context, status: _status, q: _q, page: page);
    if (!mounted || id != _req) return;
    setState(() {
      _loading = false;
      _loadingMore = false;
      if (d == null) {
        if (!more) _error = err;
        if (more && err != null) payToast(context, err, error: true);
      } else {
        _items = more ? [..._items, ...d.items] : d.items;
        _page = page;
        _totalPages = d.totalPages;
        _counts = d.counts;
        _shopOpen = d.shopIsOpen;
        _canEdit = d.canEdit;
        if (d.shopUrl.isNotEmpty) _shopUrl = d.shopUrl;
      }
    });
  }

  Future<void> _open(ShopOrder o) async {
    final changed = await AppRoutes.push(context, OnlineOrderDetailScreen(orderId: o.id));
    if (changed == true && mounted) _load();
  }

  Future<void> _settings() async {
    await AppRoutes.push(context, const MobileShopSettingsScreen());
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Online Orders', style: AppTextStyle.titleMedium(context)),
        actions: [
          IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loading ? null : _load),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            if (_shopUrl.isNotEmpty) _shopLink(),
            if (!_shopOpen)
              const WNotice(
                tone: WTone.amber,
                icon: Icons.pause_circle_outline,
                text: 'The shop is closed — customers can\'t place new orders.',
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: WSearchField(
                controller: _search,
                hint: 'Order no, name or phone',
                showClear: _q.isNotEmpty,
                onSubmitted: (v) {
                  _q = v.trim();
                  _load();
                },
                onClear: () {
                  _search.clear();
                  _q = '';
                  _load();
                },
              ),
            ),
            WChipBar(chips: [
              for (final s in ShopRepo.statuses)
                WChip(
                  label: '${s[0].toUpperCase()}${s.substring(1)}',
                  count: _counts[s] ?? 0,
                  selected: _status == s,
                  onTap: () {
                    if (_status == s) return;
                    _status = s;
                    _load();
                  },
                ),
            ]),
            ..._content(),
          ],
        ),
      ),
    );
  }

  Widget _shopLink() {
    return WPanel(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WPanelHead('Your online shop', note: 'Share this link with customers'),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: W.soft(context),
              border: Border.all(color: W.line2(context)),
              borderRadius: BorderRadius.circular(W.rMd),
            ),
            child: Text(_shopUrl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: W.ink2(context))),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _shopUrl));
                    payToast(context, 'Shop link copied.');
                  },
                  style: _ghost(),
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy link'),
                ),
              ),
              if (_canEdit) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _settings,
                    style: _ghost(),
                    icon: const Icon(Icons.storefront_outlined, size: 16),
                    label: const Text('Shop settings'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  ButtonStyle _ghost() => OutlinedButton.styleFrom(
        minimumSize: const Size(0, 42),
        foregroundColor: W.ink2(context),
        side: BorderSide(color: W.line2(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(W.rMd)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      );

  List<Widget> _content() {
    if (_loading) {
      return const [Padding(padding: EdgeInsets.only(top: 80), child: Center(child: CircularProgressIndicator()))];
    }
    if (_error != null) {
      return [
        SizedBox(
          height: 340,
          child: WEmpty(
            icon: Icons.cloud_off_outlined,
            title: 'Could not load orders',
            body: _error!,
            actionLabel: 'Try again',
            onAction: _load,
          ),
        ),
      ];
    }
    if (_items.isEmpty) {
      return [
        SizedBox(
          height: 340,
          child: WEmpty(
            icon: Icons.shopping_cart_outlined,
            title: _q.isNotEmpty ? 'No orders match "$_q"' : 'No orders here',
            body: 'New orders from your online shop will appear here.',
          ),
        ),
      ];
    }
    return [
      for (final o in _items)
        _OrderCard(order: o, onTap: () => _open(o)),
      if (_page < _totalPages)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Center(
            child: _loadingMore
                ? const CircularProgressIndicator()
                : OutlinedButton(
                    onPressed: () => _load(more: true),
                    style: _ghost(),
                    child: const Text('Load more'),
                  ),
          ),
        ),
    ];
  }
}

class _OrderCard extends StatelessWidget {
  final ShopOrder order;
  final VoidCallback onTap;
  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (label, tone) = orderStatusStyle(order.status);
    return WPanel(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: order.orderNo,
                      style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: W.ink(context)),
                      children: [
                        TextSpan(
                          text: '  · ${order.customerName}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: W.muted(context)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                WPill(label, tone: tone, strike: order.status == 'cancelled'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(orderWhen(order.createdAt), style: TextStyle(fontSize: 13, color: W.muted(context))),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: order.phone,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: W.ink(context)),
                    children: [
                      if (order.address.isNotEmpty)
                        TextSpan(
                          text: ' — ${order.address}',
                          style: TextStyle(fontWeight: FontWeight.w400, color: W.ink2(context)),
                        ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (order.invoiceNo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Invoice ${order.invoiceNo} · paid ${taka(order.paidAmount)} · due ${taka(order.dueAmount)}',
                      style: TextStyle(fontSize: 13, color: W.muted(context)),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: W.soft(context),
              border: Border(top: BorderSide(color: W.line(context))),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(W.rLg)),
            ),
            child: Row(
              children: [
                Text('${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 13, color: W.muted(context))),
                const Spacer(),
                Text(taka(order.total),
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: W.ink(context),
                        fontFeatures: W.tabular)),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, size: 20, color: W.muted(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
