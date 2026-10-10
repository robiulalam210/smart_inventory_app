import 'dart:async';

import 'package:intl/intl.dart';
import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '../data/audit_models.dart';
import '../data/audit_repo.dart';

/// Audit Log — কে, কখন, কোন app/device থেকে, কোন record এ কী বদলেছে।
/// শুধু Super Admin ও Admin (backend ও একই নিয়ম মানে)।
///
/// - Super Admin ও Admin: ব্যবসার সব log দেখে
///
/// Layout: চওড়া screen (≥ 1100px) এ বাঁয়ে timeline, ডানে বিস্তারিত panel।
/// ছোট screen এ timeline, ট্যাপ করলে নিচ থেকে বিস্তারিত উঠে আসে।
class AuditLogScreen extends StatefulWidget {
  /// Desktop এর main area তে বসলে নিজস্ব AppBar লাগে না
  final bool showAppBar;

  const AuditLogScreen({super.key, this.showAppBar = true});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final _repo = const AuditRepo();
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();
  final _debouncer = _Debounce(const Duration(milliseconds: 450));

  AuditMeta _meta = const AuditMeta();
  AuditFilter _filter = const AuditFilter();
  final List<AuditEntry> _items = [];
  AuditEntry? _selected;

  int _page = 1;
  int _count = 0;
  bool _hasMore = false;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _requestId = 0; // পুরনো request দেরিতে ফিরলে যেন নতুন ফলাফল মুছে না দেয়

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchCtrl.dispose();
    _debouncer.cancel();
    super.dispose();
  }

  // ───────────────────────── data ─────────────────────────

  Future<void> _refresh() async {
    _loadMeta();
    await _loadFirstPage();
  }

  int _metaRequestId = 0;

  /// Dropdown এর বিকল্পগুলো বর্তমান filter মেনে আনা হয় (faceted) — তাই এমন জোড়া
  /// বাছাই করা যায় না যার কোনো ফলাফল নেই (যেমন একজন user + "System")
  Future<void> _loadMeta() async {
    final id = ++_metaRequestId;
    final (meta, _) = await _repo.meta(context, _filter);
    if (mounted && meta != null && id == _metaRequestId) setState(() => _meta = meta);
  }

  Future<void> _loadFirstPage() async {
    final id = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    final (page, error) = await _repo.list(context, _filter, page: 1);
    if (!mounted || id != _requestId) return;
    setState(() {
      _loading = false;
      if (page == null) {
        _error = error;
        return;
      }
      _items
        ..clear()
        ..addAll(page.items);
      _page = page.page;
      _count = page.count;
      _hasMore = page.hasMore;
      // চওড়া screen এ প্রথমটা আগে থেকেই খোলা থাকে
      if (_selected == null || !_items.any((e) => e.id == _selected!.id)) {
        _selected = _items.isNotEmpty ? _items.first : null;
      }
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _loading) return;
    final id = _requestId;
    setState(() => _loadingMore = true);
    final (page, _) = await _repo.list(context, _filter, page: _page + 1);
    if (!mounted || id != _requestId) return;
    setState(() {
      _loadingMore = false;
      if (page != null) {
        _items.addAll(page.items);
        _page = page.page;
        _hasMore = page.hasMore;
      }
    });
  }

  void _onScroll() {
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) _loadMore();
  }

  void _applyFilter(AuditFilter f) {
    setState(() {
      _filter = f;
      _selected = null;
    });
    _loadMeta();
    _loadFirstPage();
  }

  void _clearFilters() {
    _searchCtrl.clear();
    _applyFilter(const AuditFilter());
  }

  /// একটা record এর পুরো ইতিহাস (কে কবে কী বদলেছে) দেখানো
  void _showHistoryOf(AuditEntry e) {
    _searchCtrl.clear();
    _applyFilter(AuditFilter(model: e.model, objectId: e.objectId));
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _filter.range,
    );
    if (picked != null) _applyFilter(_filter.copyWith(range: () => picked));
  }

  // ───────────────────────── UI ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final body = LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 1100;
      final list = _buildList(context, wide: wide, width: c.maxWidth);
      if (!wide) return list;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: list),
          Container(
            width: 440,
            decoration: BoxDecoration(
              color: AppColors.bottomNavBg(context),
              border: Border(left: BorderSide(color: AppColors.greyColor(context).withValues(alpha: 0.2))),
            ),
            child: _selected == null
                ? const _DetailPlaceholder()
                : _AuditDetail(
                    key: ValueKey(_selected!.id),
                    entry: _selected!,
                    onShowHistory: () => _showHistoryOf(_selected!),
                  ),
          ),
        ],
      );
    });

    return AppScaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text('Audit Log', style: AppTextStyle.titleMedium(context)),
              actions: [
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _loading ? null : _refresh,
                ),
              ],
            )
          : null,
      body: body,
    );
  }

  Widget _buildList(BuildContext context, {required bool wide, required double width}) {
    final pad = wide ? 24.0 : 16.0;
    // চওড়া screen এ ডানের detail panel (440) বাদে list এর আসল প্রস্থ
    final listWidth = wide ? width - 440 : width;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (!widget.showAppBar) ...[
                  _PageHeader(onRefresh: _loading ? null : _refresh),
                  const SizedBox(height: 16),
                ],
                _StatsRow(summary: _meta.summary, width: listWidth - pad * 2),
                const SizedBox(height: 16),
                _FilterBar(
                  meta: _meta,
                  filter: _filter,
                  searchCtrl: _searchCtrl,
                  wide: listWidth >= 760,
                  onSearch: (v) => _debouncer.run(() => _applyFilter(_filter.copyWith(query: v))),
                  onChanged: _applyFilter,
                  onPickRange: _pickRange,
                  onClear: _clearFilters,
                ),
                const SizedBox(height: 8),
                if (!_loading && _error == null)
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 4),
                    child: Text(
                      _count == 0 ? '' : '$_count ${_count == 1 ? 'activity' : 'activities'} found',
                      style: TextStyle(fontSize: 12, color: AppColors.subText),
                    ),
                  ),
              ]),
            ),
          ),
          ..._timelineSlivers(context, wide: wide, pad: pad),
        ],
      ),
    );
  }

  List<Widget> _timelineSlivers(BuildContext context, {required bool wide, required double pad}) {
    if (_loading) {
      return [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((_, i) => const _SkeletonTile(), childCount: 6),
          ),
        ),
      ];
    }
    if (_error != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyState(
            icon: Icons.lock_clock_outlined,
            color: AppColors.danger,
            title: 'Could not load the audit log',
            message: _error!,
            action: OutlinedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
            ),
          ),
        ),
      ];
    }
    if (_items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyState(
            icon: Icons.manage_search_rounded,
            color: AppColors.info,
            title: _filter.isEmpty ? 'No activity yet' : 'Nothing matches these filters',
            message: _filter.isEmpty
                ? 'Every create, edit and delete will appear here.'
                : 'Try a different date range or clear the filters.',
            action: _filter.isEmpty
                ? null
                : TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                    label: const Text('Clear filters'),
                  ),
          ),
        ),
      ];
    }

    // দিন অনুযায়ী ভাগ
    final rows = <Widget>[];
    String? lastDay;
    for (final e in _items) {
      final day = AuditFormat.dayHeader(e.createdAt);
      if (day != lastDay) {
        rows.add(_DayHeader(label: day, first: lastDay == null));
        lastDay = day;
      }
      rows.add(_AuditTile(
        entry: e,
        selected: wide && _selected?.id == e.id,
        onTap: () {
          if (wide) {
            setState(() => _selected = e);
          } else {
            _openSheet(e);
          }
        },
      ));
    }

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(pad, 0, pad, 24),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            ...rows,
            if (_loadingMore)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
              )
            else if (!_hasMore && _items.length > 10)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text('You\'ve reached the beginning', style: TextStyle(fontSize: 12, color: AppColors.subText)),
                ),
              ),
          ]),
        ),
      ),
    ];
  }

  void _openSheet(AuditEntry e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.bottomNavBg(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (ctx, controller) => _AuditDetail(
          entry: e,
          scrollController: controller,
          showHandle: true,
          onShowHistory: () {
            Navigator.pop(ctx);
            _showHistoryOf(e);
          },
        ),
      ),
    );
  }
}

// ═════════════════════════ widgets ═════════════════════════

class _Debounce {
  final Duration delay;
  Timer? _t;

  _Debounce(this.delay);

  void run(VoidCallback f) {
    _t?.cancel();
    _t = Timer(delay, f);
  }

  void cancel() => _t?.cancel();
}

BoxDecoration _card(BuildContext context, {Color? border}) => BoxDecoration(
      color: AppColors.bottomNavBg(context),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: border ?? AppColors.greyColor(context).withValues(alpha: 0.2)),
    );

class _PageHeader extends StatelessWidget {
  final VoidCallback? onRefresh;

  const _PageHeader({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryColor(context).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.policy_outlined, color: AppColors.primaryColor(context)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Audit Log',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text(context))),
              const SizedBox(height: 2),
              Text(
                'Every change in your business — who, when, from where',
                style: TextStyle(fontSize: 12.5, color: AppColors.subText),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Refresh'),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AuditSummary summary;
  final double width;

  const _StatsRow({required this.summary, required this.width});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _StatTile(label: 'Today', value: summary.today, icon: Icons.bolt_rounded, color: AppColors.primaryColor(context)),
      _StatTile(label: 'Created', value: summary.todayCreate, icon: Icons.add_circle_outline, color: _AuditColors.create),
      _StatTile(label: 'Updated', value: summary.todayUpdate, icon: Icons.edit_outlined, color: _AuditColors.update),
      _StatTile(label: 'Deleted', value: summary.todayDelete, icon: Icons.delete_outline, color: _AuditColors.delete),
    ];
    // চওড়া হলে এক সারিতে ৪টা, না হলে ২×২
    final perRow = width >= 640 ? 4 : 2;
    const gap = 12.0;
    final w = (width - gap * (perRow - 1)) / perRow - 0.5;
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [for (final t in tiles) SizedBox(width: w, child: t)],
    );
  }
}

class _AuditColors {
  _AuditColors._();

  static const create = Color(0xFF16A34A);
  static const update = Color(0xFF2563EB);
  static const delete = Color(0xFFDC2626);
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card(context),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(end: value.toDouble()),
                  duration: const Duration(milliseconds: 500),
                  builder: (_, v, __) => Text(
                    v.round().toString(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text(context)),
                  ),
                ),
                Text(label == 'Today' ? 'Changes today' : '$label today',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: AppColors.subText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final AuditMeta meta;
  final AuditFilter filter;
  final TextEditingController searchCtrl;
  final bool wide;
  final ValueChanged<String> onSearch;
  final ValueChanged<AuditFilter> onChanged;
  final VoidCallback onPickRange;
  final VoidCallback onClear;

  const _FilterBar({
    required this.meta,
    required this.filter,
    required this.searchCtrl,
    required this.wide,
    required this.onSearch,
    required this.onChanged,
    required this.onPickRange,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final search = SizedBox(
      height: 36, // AppDropdown (35) এর সাথে সমান উচ্চতা
      child: TextField(
      controller: searchCtrl,
      onChanged: onSearch,
      style: TextStyle(fontSize: 13.5, color: AppColors.text(context)),
      decoration: _inputDecoration(context, 'Search by record or user name', Icons.search_rounded),
      ),
    );

    final actionTabs = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final a in const [null, 'create', 'update', 'delete'])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ActionTab(
                label: a == null ? 'All' : AuditFormat.actionLabel(a),
                color: a == null ? AppColors.primaryColor(context) : AuditFormat.actionColor(a),
                icon: a == null ? Icons.all_inclusive_rounded : AuditFormat.actionIcon(a),
                selected: filter.action == a,
                onTap: () => onChanged(filter.copyWith(action: () => a)),
              ),
            ),
        ],
      ),
    );

    final dropdowns = <Widget>[
      _FilterDropdown(
        icon: Icons.category_outlined,
        hint: 'All modules',
        value: filter.model,
        options: meta.models,
        fallbackLabel: AuditFormat.modelName,
        onChanged: (v) => onChanged(filter.copyWith(model: () => v, objectId: () => null)),
      ),
      _FilterDropdown(
        icon: Icons.person_outline_rounded,
        hint: 'All users',
        value: filter.userId,
        options: meta.users,
        onChanged: (v) => onChanged(filter.copyWith(userId: () => v)),
      ),
      _FilterDropdown(
        icon: Icons.devices_other_outlined,
        hint: 'All apps',
        value: filter.source,
        options: meta.sources,
        onChanged: (v) => onChanged(filter.copyWith(source: () => v)),
      ),
      _DateButton(range: filter.range, onTap: onPickRange, onClear: () => onChanged(filter.copyWith(range: () => null))),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (wide)
            Row(children: [Expanded(flex: 5, child: search), const SizedBox(width: 12), Flexible(flex: 6, child: actionTabs)])
          else ...[
            search,
            const SizedBox(height: 10),
            actionTabs,
          ],
          const SizedBox(height: 12),
          wide
              ? Wrap(spacing: 10, runSpacing: 10, children: [for (final d in dropdowns) SizedBox(width: 200, child: d)])
              : Column(children: [
                  for (final d in dropdowns) Padding(padding: const EdgeInsets.only(bottom: 8), child: d),
                ]),
          if (filter.objectId != null || !filter.isEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (filter.objectId != null)
                  Flexible(
                    child: InputChip(
                      avatar: const Icon(Icons.history_rounded, size: 16),
                      label: Text(
                        'History of ${AuditFormat.modelName(filter.model ?? '')} #${filter.objectId}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      onDeleted: () => onChanged(filter.copyWith(objectId: () => null)),
                    ),
                  ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: const Text('Clear all'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration(BuildContext context, String hint, IconData icon) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: AppColors.greyColor(context).withValues(alpha: 0.3)),
  );
  return InputDecoration(
    isDense: true,
    hintText: hint,
    hintStyle: TextStyle(fontSize: 13, color: AppColors.subText),
    prefixIcon: Icon(icon, size: 19),
    prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 34),
    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(borderSide: BorderSide(color: AppColors.primaryColor(context), width: 1.4)),
  );
}

class _ActionTab extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ActionTab({
    required this.label,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : AppColors.greyColor(context).withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: selected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.text(context),
                )),
          ],
        ),
      ),
    );
  }
}

/// App এর সাধারণ AppDropdown (search সহ) — × চাপলে filter উঠে যায় ("All")
class _FilterDropdown extends StatelessWidget {
  final IconData icon; // (AppDropdown এ icon নেই — পুরনো call এর সাথে মিল রাখতে)
  final String hint;
  final String? value;
  final List<AuditOption> options;
  final bool showCount;
  final String Function(String value)? fallbackLabel;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.icon,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
    this.showCount = true,
    this.fallbackLabel,
  });

  @override
  Widget build(BuildContext context) {
    final byValue = {for (final o in options) o.value: o};
    final values = [for (final o in options) o.value];
    // filter এ যে মান আছে সেটা তালিকায় না থাকলেও (যেমন history থেকে আসা) দেখাতে হবে
    if (value != null && !byValue.containsKey(value)) values.insert(0, value!);

    return AppDropdown<String>(
      key: ValueKey('$hint-$value'), // বাইরে থেকে মান বদলালে (Clear all) নতুন মান দেখায়
      label: hint,
      hint: hint,
      value: value,
      itemList: values,
      itemLabel: (v) {
        final o = byValue[v];
        if (o == null) return fallbackLabel?.call(v) ?? v;
        return showCount && o.count > 0 ? '${o.label}  (${o.count})' : o.label;
      },
      onChanged: onChanged,
    );
  }
}

class _DateButton extends StatelessWidget {
  final DateTimeRange? range;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateButton({required this.range, required this.onTap, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('dd MMM');
    final label = range == null ? 'Any date' : '${f.format(range!.start)} – ${f.format(range!.end)}';
    // AppDropdown এর মতো একই উচ্চতা ও border — filter row এক লাইনে সমান দেখায়
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radius),
      onTap: onTap,
      child: Container(
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.greyColor(context)),
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range_outlined, size: 17, color: AppColors.greyColor(context)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14, color: range == null ? AppColors.greyColor(context) : AppColors.text(context))),
            ),
            if (range != null)
              InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 18, color: AppColors.greyColor(context)),
                ),
              )
            else
              Icon(Icons.keyboard_arrow_down, color: AppColors.greyColor(context)),
          ],
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String label;
  final bool first;

  const _DayHeader({required this.label, required this.first});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: first ? 8 : 20, bottom: 8, left: 2),
      child: Row(
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                fontSize: 11.5,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor(context),
              )),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: AppColors.greyColor(context).withValues(alpha: 0.25), height: 1)),
        ],
      ),
    );
  }
}

class _AuditTile extends StatelessWidget {
  final AuditEntry entry;
  final bool selected;
  final VoidCallback onTap;

  const _AuditTile({required this.entry, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = AuditFormat.actionColor(entry.action);
    final textColor = AppColors.text(context);
    final changed = entry.action == 'update' ? entry.changes.length : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? color.withValues(alpha: 0.06) : AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? color.withValues(alpha: 0.5) : AppColors.greyColor(context).withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: Icon(AuditFormat.actionIcon(entry.action), size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(text: entry.user, style: const TextStyle(fontWeight: FontWeight.w700)),
                          TextSpan(text: ' ${AuditFormat.actionVerb(entry.action)} ', style: TextStyle(color: AppColors.subText)),
                          TextSpan(
                            text: AuditFormat.modelName(entry.model).toLowerCase(),
                            style: TextStyle(fontWeight: FontWeight.w600, color: color),
                          ),
                        ]),
                        style: TextStyle(fontSize: 13.5, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        entry.objectRepr.isEmpty ? '#${entry.objectId}' : entry.objectRepr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.5, color: textColor.withValues(alpha: 0.8)),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _MetaChip(icon: Icons.schedule_rounded, label: AuditFormat.time(entry.createdAt)),
                          _MetaChip(icon: AuditFormat.sourceIcon(entry.source), label: AuditFormat.sourceName(entry.source)),
                          if (changed > 0)
                            _MetaChip(
                              icon: Icons.difference_outlined,
                              label: '$changed field${changed == 1 ? '' : 's'}',
                              color: AuditFormat.actionColor('update'),
                            ),
                          if (entry.wasOffline)
                            const _MetaChip(icon: Icons.cloud_off_rounded, label: 'Synced later', color: AppColors.warning),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.subText.withValues(alpha: 0.7)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.subText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.09), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: c)),
          ),
        ],
      ),
    );
  }
}

/// একটা audit entry এর পুরো বিস্তারিত — desktop এ ডান panel, mobile এ bottom sheet
class _AuditDetail extends StatelessWidget {
  final AuditEntry entry;
  final VoidCallback onShowHistory;
  final ScrollController? scrollController;
  final bool showHandle;

  const _AuditDetail({
    super.key,
    required this.entry,
    required this.onShowHistory,
    this.scrollController,
    this.showHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AuditFormat.actionColor(entry.action);
    final text = AppColors.text(context);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        if (showHandle)
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.greyColor(context).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )
        else
          const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AuditFormat.actionIcon(entry.action), size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(AuditFormat.actionLabel(entry.action),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(AuditFormat.modelName(entry.model),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            const Spacer(),
            Text('#${entry.id}', style: TextStyle(fontSize: 11.5, color: AppColors.subText)),
          ],
        ),
        const SizedBox(height: 12),
        SelectableText(
          entry.objectRepr.isEmpty ? '${AuditFormat.modelName(entry.model)} #${entry.objectId}' : entry.objectRepr,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: text, height: 1.3),
        ),
        const SizedBox(height: 4),
        Text('Record ID: ${entry.objectId}', style: TextStyle(fontSize: 12, color: AppColors.subText)),
        const SizedBox(height: 18),

        // কে, কখন, কোথা থেকে
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _InfoRow(icon: Icons.person_outline_rounded, label: 'Done by', value: entry.user),
              _InfoRow(icon: Icons.schedule_rounded, label: 'Recorded at', value: AuditFormat.dateTime(entry.createdAt)),
              if (entry.wasOffline)
                _InfoRow(
                  icon: Icons.cloud_off_rounded,
                  label: 'Done offline at',
                  value: AuditFormat.dateTime(entry.clientTime!),
                  valueColor: AppColors.warning,
                ),
              _InfoRow(
                icon: AuditFormat.sourceIcon(entry.source),
                label: 'From',
                value: AuditFormat.sourceName(entry.source),
              ),
              if (entry.device != null) _InfoRow(icon: Icons.memory_rounded, label: 'Device', value: entry.device!),
              if (entry.ip != null) _InfoRow(icon: Icons.lan_outlined, label: 'IP address', value: entry.ip!),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Text(
              switch (entry.action) {
                'create' => 'Saved values',
                'delete' => 'Last values before delete',
                _ => 'What changed',
              },
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: text),
            ),
            const SizedBox(width: 8),
            Text('${entry.changes.length}', style: TextStyle(fontSize: 12, color: AppColors.subText)),
          ],
        ),
        const SizedBox(height: 10),
        if (entry.changes.isEmpty)
          Text('No field details recorded.', style: TextStyle(fontSize: 12.5, color: AppColors.subText))
        else
          for (final c in entry.changes) _ChangeRow(change: c, action: entry.action),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: onShowHistory,
          icon: const Icon(Icons.history_rounded, size: 18),
          label: const Text('Full history of this record'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.subText),
          const SizedBox(width: 10),
          SizedBox(
            width: 104,
            child: Text(label, style: TextStyle(fontSize: 12.5, color: AppColors.subText)),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.text(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// একটা field এর আগে → পরে
class _ChangeRow extends StatelessWidget {
  final AuditChange change;
  final String action;

  const _ChangeRow({required this.change, required this.action});

  @override
  Widget build(BuildContext context) {
    final oldV = AuditFormat.value(change.oldValue);
    final newV = AuditFormat.value(change.newValue);

    Widget valueBox(String v, Color color, {bool strike = false}) => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
          child: SelectableText(
            v,
            style: TextStyle(
              fontSize: 12.5,
              color: color,
              fontWeight: FontWeight.w500,
              decoration: strike ? TextDecoration.lineThrough : null,
              decorationColor: color.withValues(alpha: 0.6),
            ),
          ),
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _card(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AuditFormat.fieldName(change.field),
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text(context))),
          const SizedBox(height: 8),
          if (action == 'create')
            valueBox(newV, _AuditColors.create)
          else if (action == 'delete')
            valueBox(oldV, _AuditColors.delete, strike: true)
          else
            Row(
              children: [
                Expanded(child: valueBox(oldV, _AuditColors.delete, strike: true)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.subText),
                ),
                Expanded(child: valueBox(newV, _AuditColors.create)),
              ],
            ),
        ],
      ),
    );
  }
}

class _DetailPlaceholder extends StatelessWidget {
  const _DetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const _EmptyState(
      icon: Icons.touch_app_outlined,
      color: AppColors.info,
      title: 'Select an activity',
      message: 'Details of the change — before and after values — will appear here.',
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final Widget? action;

  const _EmptyState({required this.icon, required this.color, required this.title, required this.message, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.10), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 14),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text(context))),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppColors.subText)),
            if (action != null) ...[const SizedBox(height: 14), action!],
          ],
        ),
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.greyColor(context).withValues(alpha: 0.15);
    Widget bar(double w, double h) =>
        Container(width: w, height: h, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)));
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: _card(context),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [bar(180, 12), const SizedBox(height: 8), bar(120, 10), const SizedBox(height: 10), bar(220, 16)],
            ),
          ),
        ],
      ),
    );
  }
}
