import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/configs/app_colors.dart';
import '../../data/models/dashboard/dashboard_model.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../widgets/dash_kit.dart';
import '../widgets/dashboard_extras.dart';
import '../widgets/dash_more_charts.dart';
import 'package:meherinMart/desktop/widgets/sidebar.dart' show quickJumpEntries;
import '../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '../../../shop/data/shop_models.dart';
import '../../../shop/data/shop_repo.dart';
import '../../../shop/presentation/shop_common.dart';

/// Desktop Dashboard — ওয়েবের dashboard এর হুবহু গঠন:
///   greeting + সময়কাল  →  ৪টা KPI  →  চার্ট (৭/৩০ দিন) + খরচের ভাগ
///   →  Money flow + Stock alerts  →  Recent activity + Account balance
///   →  Best sellers + Restock soon
/// sidebar/scroll এখন root.dart এর — এখানে আর নিজের sidebar বা স্থির উচ্চতা নেই।
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _period = 'current_day';
  int _trendDays = 7;
  String _tab = 'sales';

  DashboardData? _data;

  Map<String, dynamic>? _trend;
  bool _trendLoading = false;
  List<Map<String, dynamic>>? _accounts;
  List<Map<String, dynamic>>? _top;
  List<Map<String, dynamic>>? _low;
  int _extrasToken = 0; // পুরনো উত্তর নতুনকে চাপা না দেয়
  ShopOrderPage? _online; // Online Shop এর pending অর্ডার (permission/সার্ভার না থাকলে null → প্যানেল লুকানো)

  @override
  void initState() {
    super.initState();
    context
        .read<DashboardBloc>()
        .add(FetchDashboardData(dateFilter: _period, context: context));
  }

  String get _noun =>
      {'current_day': 'today', 'this_month': 'this month', 'lifeTime': 'so far'}[_period]!;

  void _setPeriod(String p) {
    if (p == _period) return;
    setState(() => _period = p);
    context
        .read<DashboardBloc>()
        .add(FetchDashboardData(dateFilter: p, context: context));
  }

  Future<void> _loadExtras(DashboardData d) async {
    final token = ++_extrasToken;
    final ctx = context;
    final start = d.dateFilterInfo?.startDate;
    final end = d.dateFilterInfo?.endDate;

    Future<void> run<T>(Future<T> f, void Function(T) set) async {
      final v = await f;
      if (!mounted || token != _extrasToken) return;
      setState(() => set(v));
    }

    await Future.wait([
      _loadTrend(),
      run(DashboardExtras.accounts(ctx), (v) => _accounts = v),
      run(DashboardExtras.topProducts(ctx, start, end), (v) => _top = v),
      run(DashboardExtras.lowStock(ctx), (v) => _low = v),
      _loadOnline(ctx),
    ]);
  }

  Future<void> _loadOnline(BuildContext ctx) async {
    final (d, _) = await const ShopRepo().orders(ctx, status: 'pending');
    if (!mounted) return;
    setState(() => _online = d);
  }

  void _go(int index) =>
      context.read<DashboardBloc>().add(ChangeDashboardScreen(index: index));

  Future<void> _loadTrend() async {
    setState(() => _trendLoading = true);
    final t = await DashboardExtras.trend(context, _trendDays);
    if (!mounted) return;
    setState(() {
      _trend = t;
      _trendLoading = false;
    });
  }

  void _setTrendDays(int days) {
    if (days == _trendDays) return;
    _trendDays = days;
    _loadTrend();
  }

  // ───────────────────────── build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return BlocConsumer<DashboardBloc, DashboardState>(
      listenWhen: (p, s) => s is DashboardLoaded,
      listener: (context, state) {
        if (state is DashboardLoaded) {
          _data = state.dashboardData;
          _loadExtras(state.dashboardData);
        }
      },
      buildWhen: (p, s) =>
          s is DashboardLoaded || s is DashboardLoading || s is DashboardError,
      builder: (context, state) {
        final loading = _data == null && state is! DashboardError;
        return Container(
          color: AppColors.background(context),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: LayoutBuilder(builder: (context, box) {
            final wide = box.maxWidth >= 1000;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(c),
                const SizedBox(height: 14),
                _quickActions(c),
                const SizedBox(height: 16),
                if (state is DashboardError && _data == null)
                  _error(state.message, c)
                else ...[
                  _kpis(_data, loading, box.maxWidth),
                  const SizedBox(height: 16),
                  if (_online != null) ...[
                    _onlinePanel(c),
                    const SizedBox(height: 16),
                  ],
                  _row(wide, _trendPanel(c), _expensePanel(c), 2, 1),
                  const SizedBox(height: 16),
                  _row(wide, _flowPanel(c), _stockPanel(c), 2, 1),
                  const SizedBox(height: 16),
                  DashMoreCharts(wide: wide, accounts: _accounts, onOpenExpiry: () => _go(54)),
                  const SizedBox(height: 16),
                  _row(wide, _recentPanel(c), _accountsPanel(c), 2, 1),
                  const SizedBox(height: 16),
                  _row(wide, _topPanel(c), _lowPanel(c), 1, 2),
                ],
              ],
            );
          }),
        );
      },
    );
  }

  Widget _row(bool wide, Widget a, Widget b, int fa, int fb) {
    if (!wide) {
      return Column(children: [a, const SizedBox(height: 16), b]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: fa, child: a),
        const SizedBox(width: 16),
        Expanded(flex: fb, child: b),
      ],
    );
  }


  // ───────────────────────── quick actions ─────────────────────────

  Widget _quickActions(DashColors c) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, ps) {
        if (ps is! ProfilePermissionSuccess) return const SizedBox.shrink();
        final allowed = quickJumpEntries(
          ps.permissionData.data?.permissions,
          ps.permissionData.data?.user?.role,
        ).map((e) => e.index).toSet();

        final pending = _online?.counts['pending'] ?? 0;
        final defs = <(int, String, IconData, Color, int)>[
          (1, 'New sale', Icons.point_of_sale_rounded, c.blue, 0),
          (6, 'New purchase', Icons.local_shipping_outlined, c.purple, 0),
          (4, 'Money receipt', Icons.receipt_long_outlined, c.green, 0),
          (8, 'Products', Icons.inventory_2_outlined, c.cyan, 0),
          (10, 'Customers', Icons.groups_outlined, c.orange, 0),
          (51, 'Due reminders', Icons.notifications_active_outlined, c.amber, 0),
          (49, 'Online orders', Icons.storefront_outlined, c.red, pending),
        ].where((d) => allowed.contains(d.$1)).toList();
        if (defs.isEmpty) return const SizedBox.shrink();

        return Wrap(spacing: 10, runSpacing: 10, children: [
          for (final d in defs)
            Material(
              color: c.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: c.line),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _go(d.$1),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: d.$4.withValues(alpha: c.dark ? .18 : .10),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(d.$3, size: 18, color: d.$4),
                    ),
                    const SizedBox(width: 10),
                    Text(d.$2,
                        style: TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w600, color: c.ink)),
                    if (d.$5 > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                            color: c.red, borderRadius: BorderRadius.circular(20)),
                        child: Text('${d.$5}',
                            style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                    ],
                  ]),
                ),
              ),
            ),
        ]);
      },
    );
  }

  // ───────────────────────── online orders ─────────────────────────

  Widget _onlinePanel(DashColors c) {
    final d = _online!;
    final pending = d.counts['pending'] ?? 0;
    final confirmed = d.counts['confirmed'] ?? 0;
    final rows = d.items.take(5).toList();
    return DashPanel(
      title: 'Online orders',
      subtitle: '· $pending pending, $confirmed to deliver${d.shopIsOpen ? '' : ' · shop paused'}',
      trailing: TextButton(
        onPressed: () => _go(49),
        child: const Text('View all'),
      ),
      child: rows.isEmpty
          ? DashEmpty('No pending online orders.',
              icon: Icons.check_circle_outline, color: c.green)
          : Column(children: [
              for (var i = 0; i < rows.length; i++)
                InkWell(
                  onTap: () => _go(49),
                  child: DashRow(
                    title: '${rows[i].orderNo} · ${rows[i].customerName}',
                    sub: '${rows[i].phone}  ·  ${rows[i].itemCount} item${rows[i].itemCount == 1 ? '' : 's'}',
                    date: orderWhen(rows[i].createdAt),
                    last: i == rows.length - 1,
                    trailing: DashAmount(taka(rows[i].total)),
                  ),
                ),
            ]),
    );
  }

  // ───────────────────────── header ─────────────────────────

  Widget _header(DashColors c) {
    final h = DateTime.now().hour;
    final greet = h < 12
        ? 'Good morning'
        : h < 17
            ? 'Good afternoon'
            : 'Good evening';
    final r = _data?.dateFilterInfo;
    final range = r?.startDate == null
        ? dateText(DateTime.now())
        : (_period == 'current_day'
            ? dateText(r!.startDate)
            : '${dateText(r!.startDate)} – ${dateText(r.endDate)}');
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(greet,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800, color: c.ink)),
            const SizedBox(height: 2),
            Text("Here's how the shop is doing · $range",
                style: TextStyle(fontSize: 13.5, color: c.muted)),
          ],
        ),
        Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => context.read<DashboardBloc>().add(
                FetchDashboardData(dateFilter: _period, context: context)),
            icon: Icon(Icons.refresh_rounded, color: c.muted),
          ),
          const SizedBox(width: 6),
          DashSegmented<String>(
            value: _period,
            onChanged: _setPeriod,
            options: const [
              ('current_day', 'Today'),
              ('this_month', 'This month'),
              ('lifeTime', 'All time'),
            ],
          ),
        ]),
      ],
    );
  }

  Widget _error(String msg, DashColors c) => DashPanel(
        title: "Couldn't load the dashboard",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(msg, style: TextStyle(color: c.muted)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.read<DashboardBloc>().add(
                  FetchDashboardData(dateFilter: _period, context: context)),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
            ),
          ],
        ),
      );

  // ───────────────────────── KPI ─────────────────────────

  Widget _kpis(DashboardData? d, bool loading, double width) {
    final c = DashColors(context);
    final m = d?.todayMetrics;
    final pl = d?.profitLoss;
    final sales = m?.sales, pur = m?.purchases, exp = m?.expenses;

    String inv(int? n, String one, String many) =>
        '${n ?? 0} ${(n ?? 0) == 1 ? one : many}';

    final salesDue = dashNum(sales?.totalDue);
    final purDue = dashNum(pur?.totalDue);
    final inc = dashNum(m?.incomes?.total);
    final net = dashNum(pl?.netProfit);
    final isLoss = d != null && net < 0;

    final cards = <Widget>[
      DashKpi(
        title: 'Sales',
        icon: Icons.shopping_cart_outlined,
        color: c.blue,
        loading: loading,
        value: taka(sales?.total),
        note: d == null
            ? null
            : inv(sales?.count, 'invoice', 'invoices') +
                (salesDue > 0 ? ', ${taka(salesDue)} due' : ''),
      ),
      DashKpi(
        title: 'Purchases',
        icon: Icons.local_shipping_outlined,
        color: c.purple,
        loading: loading,
        value: taka(pur?.total),
        note: d == null
            ? null
            : inv(pur?.count, 'invoice', 'invoices') +
                (purDue > 0 ? ', ${taka(purDue)} to pay' : ''),
      ),
      DashKpi(
        title: 'Expenses',
        icon: Icons.receipt_long_outlined,
        color: c.orange,
        loading: loading,
        value: taka(exp?.total),
        note: d == null
            ? null
            : inv(exp?.count, 'entry', 'entries') +
                (inc > 0 ? ', other income ${taka(inc)}' : ''),
      ),
      DashKpi(
        title: isLoss ? 'Net loss' : 'Net profit',
        icon: Icons.trending_up_rounded,
        color: isLoss ? c.red : c.green,
        loss: isLoss,
        loading: loading,
        value: taka(pl?.netProfit),
        note: d == null
            ? null
            : 'Gross profit ${taka(pl?.grossProfit)}'
                '${dashNum(sales?.total) > 0 ? ', ${(pl?.profitMargin ?? 0).toStringAsFixed(1)}% margin' : ''}',
      ),
    ];

    final cols = width >= 1000 ? 4 : (width >= 600 ? 2 : 1);
    const gap = 14.0;
    final w = (width - gap * (cols - 1)) / cols;
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [for (final k in cards) SizedBox(width: w, child: k)],
    );
  }

  // ───────────────────────── charts ─────────────────────────

  Widget _trendPanel(DashColors c) {
    final t = _trend;
    final labels = [for (final x in (t?['labels'] as List? ?? const [])) '$x'];
    List<double> vals(String k) => [
          for (final x in (t?[k] as List? ?? const [])) dashNum(x).toDouble()
        ];
    final sales = vals('sales'), pur = vals('purchases'), exp = vals('expenses');
    final has = [sales, pur, exp].any((l) => l.any((v) => v > 0));

    Widget body;
    if (t == null) {
      body = DashEmpty(_trendLoading ? 'Loading chart…' : "Couldn't load the chart.");
    } else if (!has) {
      body = const DashEmpty('No sales, purchases or expenses in this range yet.');
    } else {
      body = AnimatedOpacity(
        opacity: _trendLoading ? 0.5 : 1,
        duration: const Duration(milliseconds: 150),
        child: DashLineChart(
          labels: labels,
          series: [
            TrendSeries('Sales', sales, c.blue, fill: true),
            TrendSeries('Purchases', pur, c.purple),
            TrendSeries('Expenses', exp, c.orange),
          ],
        ),
      );
    }

    return DashPanel(
      title: 'Sales, purchases & expenses',
      subtitle: '· last $_trendDays days',
      trailing: DashSegmented<int>(
        small: true,
        value: _trendDays,
        onChanged: _setTrendDays,
        options: const [(7, '7 days'), (30, '30 days')],
      ),
      child: body,
    );
  }

  Widget _expensePanel(DashColors c) {
    final heads = (_trend?['expense_by_head'] as List? ?? const []);
    final pal = c.palette;
    final slices = <DonutSlice>[
      for (var i = 0; i < heads.length; i++)
        if (heads[i] is Map)
          DonutSlice('${(heads[i] as Map)['name'] ?? 'Other'}',
              dashNum((heads[i] as Map)['total']).toDouble(), pal[i % pal.length]),
    ];
    return DashPanel(
      title: 'Where expenses go',
      child: slices.isEmpty
          ? DashEmpty(_trend == null
              ? 'Loading…'
              : 'No expenses in the last $_trendDays days.')
          : DashDonut(slices: slices),
    );
  }

  // ───────────────────────── money flow / stock ─────────────────────────

  Widget _flowPanel(DashColors c) {
    final fs = _data?.financialSummary;
    final cc = fs?.cashComponents;
    final rows = [
      ('Money in', 'Sales collected and other income', dashNum(cc?.cashIn).toDouble(), true),
      ('Purchases paid', 'Paid to suppliers', dashNum(cc?.cashOutPurchases).toDouble(), false),
      ('Expenses', 'Shop expenses', dashNum(cc?.cashOutExpenses).toDouble(), false),
    ];
    final max = rows.fold<double>(1, (m, r) => r.$3 > m ? r.$3 : m);
    final net = dashNum(fs?.operatingCashFlow).toDouble();
    return DashPanel(
      title: 'Money flow',
      subtitle: _noun,
      trailing: _data == null
          ? null
          : Text.rich(TextSpan(children: [
              TextSpan(text: 'Net  ', style: TextStyle(fontSize: 12.5, color: c.muted)),
              TextSpan(
                  text: taka(net),
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: net < 0 ? c.red : c.green)),
            ])),
      child: Column(children: [
        for (final r in rows)
          DashFlowRow(label: r.$1, hint: r.$2, value: r.$3, max: max, incoming: r.$4),
      ]),
    );
  }

  Widget _stockPanel(DashColors c) {
    final a = _data?.stockAlerts;
    final out = a?.outOfStock ?? 0, low = a?.lowStock ?? 0;
    return DashPanel(
      title: 'Stock alerts',
      child: Column(children: [
        Row(children: [
          Expanded(child: DashAlertBox(count: out, label: 'Out of stock', hot: c.red)),
          const SizedBox(width: 12),
          Expanded(child: DashAlertBox(count: low, label: 'Running low', hot: c.amber)),
        ]),
        if (_data != null && out == 0 && low == 0)
          DashEmpty('Every product is above its alert quantity.',
              icon: Icons.check_circle_outline, color: c.green),
      ]),
    );
  }

  // ───────────────────────── recent / accounts ─────────────────────────

  Widget _recentPanel(DashColors c) {
    final ra = _data?.recentActivities;
    final items = <Widget>[];
    void add(String title, String sub, dynamic amt, dynamic due, DateTime? date,
        bool last) {
      final dueN = dashNum(due);
      items.add(DashRow(
        title: title,
        sub: sub,
        date: dateText(date),
        last: last,
        trailing: DashAmount(taka(amt), due: dueN > 0 ? '${taka(dueN)} due' : null),
      ));
    }

    if (_tab == 'sales') {
      final l = ra?.sales ?? const <Purchase>[];
      for (var i = 0; i < l.length; i++) {
        add(l[i].invoiceNo ?? '', l[i].customer ?? '', l[i].amount,
            l[i].dueAmount, l[i].date, i == l.length - 1);
      }
    } else if (_tab == 'purchases') {
      final l = ra?.purchases ?? const <Purchase>[];
      for (var i = 0; i < l.length; i++) {
        add(l[i].invoiceNo ?? '', l[i].supplier ?? '', l[i].amount,
            l[i].dueAmount, l[i].date, i == l.length - 1);
      }
    } else {
      final l = ra?.expenses ?? const <ExpenseIncome>[];
      for (var i = 0; i < l.length; i++) {
        final e = l[i];
        final sub = (e.note?.isNotEmpty ?? false)
            ? e.note!
            : ((e.account?.isNotEmpty ?? false) ? e.account! : (e.invoiceNo ?? ''));
        add(e.head ?? 'Expense', sub, e.amount, 0, e.date, i == l.length - 1);
      }
    }

    return DashPanel(
      title: 'Recent activity',
      trailing: DashSegmented<String>(
        small: true,
        value: _tab,
        onChanged: (v) => setState(() => _tab = v),
        options: const [
          ('sales', 'Sales'),
          ('purchases', 'Purchases'),
          ('expenses', 'Expenses'),
        ],
      ),
      child: items.isEmpty
          ? DashEmpty(_data == null ? 'Loading…' : 'Nothing recorded yet.')
          : Column(children: items),
    );
  }

  Widget _accountsPanel(DashColors c) {
    final list = _accounts;
    final total = (list ?? const []).fold<double>(
        0, (s, a) => s + dashNum(a['balance']).toDouble());
    return DashPanel(
      title: 'Account balance',
      trailing: (list == null || list.isEmpty)
          ? null
          : Text(taka(total),
              style: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w800, color: c.ink)),
      child: list == null
          ? const DashEmpty('Loading…')
          : list.isEmpty
              ? const DashEmpty('No active accounts.')
              : Column(children: [
                  for (var i = 0; i < list.length; i++)
                    DashRow(
                      title: '${list[i]['name'] ?? ''}',
                      sub: [
                        list[i]['ac_type'],
                        (list[i]['bank_name']?.toString().isNotEmpty ?? false)
                            ? list[i]['bank_name']
                            : list[i]['ac_number'],
                      ]
                          .where((e) => e != null && '$e'.isNotEmpty)
                          .join(', '),
                      last: i == list.length - 1,
                      trailing: DashAmount(taka(list[i]['balance']),
                          color: dashNum(list[i]['balance']) < 0 ? c.red : null),
                    ),
                ]),
    );
  }

  // ───────────────────────── best sellers / restock ─────────────────────────

  Widget _topPanel(DashColors c) {
    final list = _top;
    final max = (list ?? const []).fold<double>(
        1, (m, p) => dashNum(p['total_sold_price']).toDouble() > m
            ? dashNum(p['total_sold_price']).toDouble()
            : m);
    return DashPanel(
      title: 'Best sellers',
      subtitle: _noun,
      child: list == null
          ? const DashEmpty('Loading…')
          : list.isEmpty
              ? const DashEmpty('No sales in this period.')
              : Column(children: [
                  for (var i = 0; i < list.length; i++)
                    DashRankRow(
                      rank: i + 1,
                      name: '${list[i]['product_name'] ?? ''}',
                      sub: '${qtyText(list[i]['total_sold_quantity'])} sold',
                      amount: taka(list[i]['total_sold_price']),
                      frac: dashNum(list[i]['total_sold_price']).toDouble() / max,
                      last: i == list.length - 1,
                    ),
                ]),
    );
  }

  Widget _lowPanel(DashColors c) {
    final list = _low;
    return DashPanel(
      title: 'Restock soon',
      trailing: (list != null && list.isNotEmpty)
          ? Text('Lowest stock first',
              style: TextStyle(fontSize: 12, color: c.muted))
          : null,
      child: list == null
          ? const DashEmpty('Loading…')
          : list.isEmpty
              ? DashEmpty('Nothing needs restocking.',
                  icon: Icons.check_circle_outline, color: c.green)
              : Column(children: [
                  for (var i = 0; i < list.length; i++)
                    Builder(builder: (context) {
                      final p = list[i];
                      final stock = dashNum(p['total_stock_quantity']);
                      return DashRow(
                        title: '${p['product_name'] ?? ''}',
                        sub: [p['category'], p['brand']]
                            .where((e) => e != null && '$e'.isNotEmpty)
                            .join(', '),
                        date: 'Alert at ${qtyText(p['alert_quantity'])}',
                        last: i == list.length - 1,
                        trailing: stock <= 0
                            ? DashPill('Out of stock', c.red)
                            : DashPill('${qtyText(stock)} left', c.amber),
                      );
                    }),
                ]),
    );
  }
}
