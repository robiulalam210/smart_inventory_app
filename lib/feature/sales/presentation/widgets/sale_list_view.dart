import 'dart:async';

import 'package:intl/intl.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/web_ui.dart';
import '../../../customer/data/model/customer_active_model.dart';
import '../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../payroll/presentation/payroll_common.dart' show taka;
import '../../../products/product/presentation/bloc/products/products_bloc.dart';
import '../../../users_list/data/model/user_model.dart';
import '../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../../data/models/pos_sale_model.dart';
import '../../data/sale_filters.dart';
import '../bloc/possale/possale_bloc.dart';
import '../shared/sales_details_screen.dart';

/// Sale List — ওয়েবের Sale List পেজের হুবহু একই কাঠামো, মোবাইল ও ডেস্কটপ দুই অ্যাপে:
///   ফিল্টার panel (search · সময় · status chip · customer/seller) → মোট হিসাব →
///   টেবিল (বড় পর্দায়) / কার্ড (ছোট পর্দায়) → পাতা বদল।
/// parent একটা GlobalKey দিয়ে [SaleListViewState.refresh] ডাকতে পারে (নতুন sale save এর পর)।
class SaleListView extends StatefulWidget {
  const SaleListView({super.key});

  @override
  State<SaleListView> createState() => SaleListViewState();
}

class SaleListViewState extends State<SaleListView> {
  final SaleFilters _f = SaleFilters();
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;

  int _page = 1;
  SaleSummary? _sum;
  int _sumReq = 0;
  // Reset চাপলে dropdown গুলো নতুন করে তৈরি হয় (FormField এর মান বাইরে থেকে বদলায় না)
  int _resetTick = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserBloc>().add(FetchUserList(context, dropdownFilter: '?status=1'));
      context.read<CustomerBloc>().add(FetchCustomerActiveList(context));
      context.read<ProductsBloc>().add(FetchProductsStockList(context));
      _fetch();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  /// বাইরে থেকে তালিকা নতুন করে আনতে
  void refresh() => _fetch();

  void _fetch() {
    if (!mounted) return;
    context.read<PosSaleBloc>().add(FetchPosSaleList(context, dropdownFilter: _f.listQuery(_page)));
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final id = ++_sumReq;
    final s = await const SaleSummaryRepo().fetch(context, _f);
    if (!mounted || id != _sumReq) return;
    setState(() => _sum = s);
  }

  /// filter বদলালে প্রথম পাতা থেকে
  void _changed() {
    setState(() => _page = 1);
    _fetch();
  }

  void _setPreset(String key) {
    setState(() {
      if (key == 'custom') {
        _f.preset = 'custom';
        _f.from ??= DateTime(DateTime.now().year, DateTime.now().month, 1);
        _f.to ??= DateTime.now();
      } else {
        _f.applyPreset(key);
      }
    });
    if (key != 'custom') _changed();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = (isFrom ? _f.from : _f.to) ?? DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );
    if (d == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _f.from = d;
      } else {
        _f.to = d;
      }
    });
    _changed();
  }

  void _resetAll() {
    _debounce?.cancel();
    _search.clear();
    final bloc = context.read<PosSaleBloc>();
    bloc.selectCustomerModel = null;
    bloc.selectUserModel = null;
    setState(() {
      _f.reset();
      _resetTick++;
      _page = 1;
    });
    _fetch();
  }

  void _goPage(int p) {
    setState(() => _page = p);
    _fetch();
  }

  // ───────────────────────── build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final bool wide = c.maxWidth >= 820;
      final bool showMore = c.maxWidth >= 1040;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _filters(wide),
          const SizedBox(height: 12),
          _totals(wide),
          const SizedBox(height: 12),
          _listPanel(wide, showMore),
        ],
      );
    });
  }

  // ───────────────────────── filters ─────────────────────────

  Widget _filters(bool wide) {
    final searchField = WSearchField(
      controller: _search,
      hint: 'Search invoice no., customer name or phone',
      showClear: _search.text.isNotEmpty,
      onChanged: (v) {
        setState(() {});
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 350), () {
          _f.q = v.trim();
          _changed();
        });
      },
      onSubmitted: (v) {
        _debounce?.cancel();
        _f.q = v.trim();
        _changed();
      },
      onClear: () {
        _debounce?.cancel();
        _search.clear();
        _f.q = '';
        _changed();
      },
    );

    final seg = WSeg(items: SaleFilters.presets, value: _f.preset, onChanged: _setPreset);

    final chips = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (key, label) in SaleFilters.statuses)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: WChip(
                label: label,
                selected: _f.status == key,
                onTap: () {
                  if (_f.status == key) return;
                  setState(() => _f.status = key);
                  _changed();
                },
              ),
            ),
        ],
      ),
    );

    final customer = BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, _) {
        final list = context.read<CustomerBloc>().activeCustomer;
        CustomerActiveModel? sel;
        for (final x in list) {
          if (x.id != null && x.id == _f.customerId) sel = x;
        }
        return AppDropdown<CustomerActiveModel>(
          key: ValueKey('cust-$_resetTick-${_f.customerId}-${list.length}'),
          label: 'Customer',
          hint: 'All customers',
          isNeedAll: true,
          useChips: false,
          value: sel,
          itemList: list,
          itemLabel: (x) => x.name ?? '',
          onChanged: (v) {
            context.read<PosSaleBloc>().selectCustomerModel = v;
            _f.customerId = v?.id;
            _changed();
          },
          validator: (v) => null,
        );
      },
    );

    final seller = BlocBuilder<UserBloc, UserState>(
      builder: (context, _) {
        final list = context.read<UserBloc>().list;
        UsersListModel? sel;
        for (final x in list) {
          if (x.id != null && x.id == _f.sellerId) sel = x;
        }
        return AppDropdown<UsersListModel>(
          key: ValueKey('sell-$_resetTick-${_f.sellerId}-${list.length}'),
          label: 'Seller',
          hint: 'All sellers',
          isNeedAll: true,
          useChips: false,
          value: sel,
          itemList: list,
          itemLabel: (x) => x.toString(),
          onChanged: (v) {
            context.read<PosSaleBloc>().selectUserModel = v;
            _f.sellerId = v?.id;
            _changed();
          },
          validator: (v) => null,
        );
      },
    );

    final reset = _f.isFiltered
        ? TextButton.icon(
            onPressed: _resetAll,
            style: TextButton.styleFrom(
              foregroundColor: W.blue(context),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: const Size(0, 36),
              textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
            ),
            icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
            label: const Text('Reset'),
          )
        : const SizedBox.shrink();

    final customDates = _f.preset == 'custom'
        ? Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _DateButton(label: 'From', date: _f.from, onTap: () => _pickDate(isFrom: true)),
                _DateButton(label: 'To', date: _f.to, onTap: () => _pickDate(isFrom: false)),
              ],
            ),
          )
        : const SizedBox.shrink();

    return WPanel(
      padding: const EdgeInsets.all(14),
      child: wide
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: searchField),
                    const SizedBox(width: 12),
                    seg,
                  ],
                ),
                customDates,
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: chips),
                    const SizedBox(width: 12),
                    SizedBox(width: 200, child: customer),
                    const SizedBox(width: 8),
                    SizedBox(width: 200, child: seller),
                    reset,
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: _fetch,
                      icon: Icon(Icons.refresh_rounded, size: 20, color: W.muted(context)),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchField,
                const SizedBox(height: 10),
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: seg),
                customDates,
                const SizedBox(height: 10),
                chips,
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: customer),
                    const SizedBox(width: 8),
                    Expanded(child: seller),
                  ],
                ),
                if (_f.isFiltered) Align(alignment: Alignment.centerLeft, child: reset),
              ],
            ),
    );
  }

  // ───────────────────────── totals ─────────────────────────

  String _num(num v) => NumberFormat('#,##0.###').format(v);

  Widget _totals(bool wide) {
    final s = _sum;
    final invoices = WSum('Invoices', s == null ? '—' : _num(s.totalSales));
    final total = WSum('Total sales', s == null ? '—' : taka(s.totalAmount));
    final paid = WSum('Collected', s == null ? '—' : taka(s.totalPaid), color: AppColors.success);
    final due = WSum('Due', s == null ? '—' : taka(s.totalDue),
        color: (s != null && s.totalDue > 0) ? AppColors.danger : null);
    final period = WSum('Period', _f.periodText);

    if (wide) {
      return WSumBar(items: [invoices, total, paid, due, period], margin: EdgeInsets.zero);
    }
    return Column(
      children: [
        WSumBar(items: [invoices, total], margin: EdgeInsets.zero),
        const SizedBox(height: 8),
        WSumBar(items: [paid, due], margin: EdgeInsets.zero),
        const SizedBox(height: 8),
        WSumBar(items: [period], margin: EdgeInsets.zero),
      ],
    );
  }

  // ───────────────────────── list ─────────────────────────

  Widget _listPanel(bool wide, bool showMore) {
    return WPanel(
      padding: EdgeInsets.zero,
      child: BlocBuilder<PosSaleBloc, PosSaleState>(
        builder: (context, state) {
          if (state is PosSaleListFailed) {
            return SizedBox(
              height: 300,
              child: WEmpty(
                icon: Icons.error_outline,
                title: "Couldn't load sales",
                body: state.content,
                actionLabel: 'Try again',
                onAction: _fetch,
              ),
            );
          }
          if (state is PosSaleListSuccess) {
            if (state.list.isEmpty) {
              final filtered = _f.isFiltered;
              return SizedBox(
                height: 320,
                child: WEmpty(
                  icon: Icons.receipt_long_outlined,
                  title: filtered ? 'No sales match these filters' : 'No sales this month yet',
                  body: filtered
                      ? 'Try a wider date range or clear the filters.'
                      : 'Sales you make will appear here.',
                  actionLabel: filtered ? 'Reset filters' : null,
                  onAction: _resetAll,
                ),
              );
            }
            final int from = (_page - 1) * SaleFilters.pageSize + 1;
            final int to = (from + state.list.length - 1).clamp(0, state.count);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (wide) _table(state.list, showMore) else _cards(state.list),
                if (wide) Divider(height: 1, color: W.line(context)),
                WPager(
                  page: _page,
                  totalPages: state.totalPages,
                  count: state.count,
                  from: from,
                  to: to,
                  onPage: _goPage,
                ),
              ],
            );
          }
          return _skeleton();
        },
      ),
    );
  }

  Widget _skeleton() => Column(
        children: [
          for (var i = 0; i < 6; i++)
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: W.line(context)))),
              alignment: Alignment.centerLeft,
              child: Container(
                height: 12,
                width: 180.0 + (i % 3) * 60,
                decoration: BoxDecoration(color: W.tint(context), borderRadius: BorderRadius.circular(6)),
              ),
            ),
        ],
      );

  // ── টেবিল (ওয়েবের .dt) ──

  Widget _table(List<PosSaleModel> rows, bool showMore) {
    TextStyle head() => TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: W.muted(context));
    Widget cell(int flex, Widget child, {Alignment align = Alignment.centerLeft}) =>
        Expanded(flex: flex, child: Align(alignment: align, child: child));

    final header = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: W.soft(context),
        border: Border(bottom: BorderSide(color: W.line(context))),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(W.rLg)),
      ),
      child: Row(
        children: [
          cell(30, Text('Invoice', style: head())),
          cell(32, Text('Customer', style: head())),
          if (showMore) cell(18, Text('Sold by', style: head())),
          cell(20, Text('Total', style: head()), align: Alignment.centerRight),
          if (showMore) cell(18, Text('Paid', style: head()), align: Alignment.centerRight),
          cell(18, Text('Due', style: head()), align: Alignment.centerRight),
          cell(16, Text('Status', style: head()), align: Alignment.center),
          const SizedBox(width: 24),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        for (var i = 0; i < rows.length; i++)
          _HoverRow(
            isLast: i == rows.length - 1,
            onTap: () => _open(rows[i]),
            child: Row(
              children: [
                cell(30, _two(_text(rows[i].invoiceNo), _when(rows[i].saleDate), boldTop: true)),
                cell(32, _two(_customer(rows[i]), _itemsLine(rows[i]), boldTop: true)),
                if (showMore)
                  cell(18, Text(_text(rows[i].saleByName),
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: _body())),
                cell(20, Text(taka(_d(rows[i].grandTotal ?? rows[i].payableAmount)), style: _money(bold: true)),
                    align: Alignment.centerRight),
                if (showMore)
                  cell(18, Text(taka(_d(rows[i].paidAmount)), style: _money()), align: Alignment.centerRight),
                cell(18, _dueText(rows[i]), align: Alignment.centerRight),
                cell(16, _statusPill(rows[i]), align: Alignment.center),
                SizedBox(width: 24, child: Icon(Icons.chevron_right_rounded, size: 18, color: W.muted(context))),
              ],
            ),
          ),
      ],
    );
  }

  // ── কার্ড (ছোট পর্দা; ওয়েবের মোবাইল .dt) ──

  Widget _cards(List<PosSaleModel> rows) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == rows.length - 1 ? 0 : 10),
              child: _SaleCard(
                sale: rows[i],
                onTap: () => _open(rows[i]),
                customer: _customer(rows[i]),
                itemsLine: _itemsLine(rows[i]),
                when: _when(rows[i].saleDate),
                status: _statusPill(rows[i]),
                total: taka(_d(rows[i].grandTotal ?? rows[i].payableAmount)),
                paid: taka(_d(rows[i].paidAmount)),
                due: _dueText(rows[i], align: TextAlign.left),
              ),
            ),
        ],
      ),
    );
  }

  // ── সাহায্যকারী ──

  void _open(PosSaleModel sale) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SalesDetailsScreen(sale: sale)));
  }

  TextStyle _body() => TextStyle(fontSize: 14, color: W.ink(context));

  TextStyle _money({bool bold = false}) => TextStyle(
        fontSize: 14,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        color: W.ink(context),
        fontFeatures: W.tabular,
      );

  /// উপরে গাঢ় লেখা, নিচে ছোট ধূসর লেখা (ওয়েবের `<b>` + `.sub`)
  Widget _two(String top, String sub, {bool boldTop = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(top,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 14, fontWeight: boldTop ? FontWeight.w700 : FontWeight.w400, color: W.ink(context))),
          if (sub.isNotEmpty)
            Text(sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: W.muted(context))),
        ],
      );

  Widget _dueText(PosSaleModel s, {TextAlign align = TextAlign.right}) {
    final due = _d(s.dueAmount);
    if (due > 0) {
      return Text(taka(due),
          textAlign: align,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.danger, fontFeatures: W.tabular));
    }
    if (due < 0) {
      return Text('+ ${taka(-due)}',
          textAlign: align,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.success, fontFeatures: W.tabular));
    }
    return Text('—', textAlign: align, style: TextStyle(color: W.muted(context)));
  }

  /// ওয়েবের .pill.st-*: Paid সবুজ · Partial নীল · Unpaid/Overdue লাল
  Widget _statusPill(PosSaleModel s) {
    final String st = (s.paymentStatus ?? _computedStatus(s)).toLowerCase();
    final (label, tone) = switch (st) {
      'paid' => ('Paid', WTone.green),
      'partial' => ('Partial', WTone.blue),
      'pending' => ('Unpaid', WTone.red),
      'overdue' => ('Overdue', WTone.red),
      _ => (st.isEmpty ? '—' : st[0].toUpperCase() + st.substring(1), WTone.neutral),
    };
    return WPill(label, tone: tone);
  }

  String _computedStatus(PosSaleModel s) {
    final paid = _d(s.paidAmount), payable = _d(s.payableAmount);
    if (paid >= payable) return 'paid';
    return paid > 0 ? 'partial' : 'pending';
  }

  double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

  String _text(dynamic v) {
    final s = v?.toString() ?? '';
    return (s.isEmpty || s == 'null') ? '—' : s;
  }

  String _customer(PosSaleModel s) {
    final n = s.customerName ?? '';
    return n.isEmpty || n == 'null' ? 'Walk-in customer' : n;
  }

  String _itemsLine(PosSaleModel s) {
    final n = s.items?.length ?? 0;
    final m = s.paymentMethod ?? '';
    return '$n ${n == 1 ? 'item' : 'items'}${m.isNotEmpty ? ', $m' : ''}';
  }

  String _when(DateTime? d) => d == null ? '—' : DateFormat('d MMM yyyy, h:mm a').format(d.toLocal());
}

/// টেবিলের সারি — hover এ হালকা রং (ওয়েবের .dt tbody tr:hover)
class _HoverRow extends StatefulWidget {
  const _HoverRow({required this.child, required this.onTap, required this.isLast});
  final Widget child;
  final VoidCallback onTap;
  final bool isLast;

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _hover ? W.canvas(context) : Colors.transparent,
              border: widget.isLast ? null : Border(bottom: BorderSide(color: W.line(context))),
            ),
            child: widget.child,
          ),
        ),
      );
}

/// মোবাইল কার্ড
class _SaleCard extends StatelessWidget {
  const _SaleCard({
    required this.sale,
    required this.onTap,
    required this.customer,
    required this.itemsLine,
    required this.when,
    required this.status,
    required this.total,
    required this.paid,
    required this.due,
  });

  final PosSaleModel sale;
  final VoidCallback onTap;
  final String customer, itemsLine, when, total, paid;
  final Widget status, due;

  @override
  Widget build(BuildContext context) {
    Widget kv(String k, Widget v) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(k, style: TextStyle(fontSize: 12, color: W.muted(context))),
              const SizedBox(height: 2),
              v,
            ],
          ),
        );

    TextStyle money({bool bold = false}) => TextStyle(
        fontSize: 14,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        color: W.ink(context),
        fontFeatures: W.tabular);

    return WPanel(
      padding: EdgeInsets.zero,
      onTap: onTap,
      color: W.surface(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sale.invoiceNo ?? '—',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: W.ink(context))),
                      const SizedBox(height: 1),
                      Text(when, style: TextStyle(fontSize: 12.5, color: W.muted(context))),
                    ],
                  ),
                ),
                status,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: W.ink(context))),
                Text(itemsLine, style: TextStyle(fontSize: 12.5, color: W.muted(context))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: W.soft(context),
              border: Border(top: BorderSide(color: W.line(context))),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(W.rLg)),
            ),
            child: Row(
              children: [
                kv('Total', Text(total, style: money(bold: true))),
                kv('Paid', Text(paid, style: money())),
                kv('Due', due),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "From  [11 Oct 2026]" — ওয়েবের .f-date
class _DateButton extends StatelessWidget {
  const _DateButton({required this.label, required this.date, required this.onTap});
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: W.muted(context))),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(W.rSm),
            onTap: onTap,
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: W.surface(context),
                border: Border.all(color: W.line2(context)),
                borderRadius: BorderRadius.circular(W.rSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(date == null ? 'Select' : DateFormat('d MMM yyyy').format(date!),
                      style: TextStyle(fontSize: 14, color: W.ink(context))),
                  const SizedBox(width: 8),
                  Icon(Icons.calendar_today_outlined, size: 15, color: W.muted(context)),
                ],
              ),
            ),
          ),
        ],
      );
}
