import 'package:meherinMart/core/core.dart';

import 'report_core.dart';

/// Report এর data — চওড়া screen এ টেবিল, ছোট screen এ card।
/// দুটোতেই search, column ধরে sort, আর নিচে মোট হিসাব।
/// অনেক row থাকলে ৫০টা করে দেখায় ("Show more") — যাতে screen ধীর না হয়।
class ReportTable<T> extends StatefulWidget {
  final List<ReportColumn<T>> columns;
  final List<T> rows;
  final List<ReportTotal> totals;
  final String searchHint;
  final ValueChanged<T>? onRowTap;

  const ReportTable({
    super.key,
    required this.columns,
    required this.rows,
    this.totals = const [],
    this.searchHint = 'Search in this report',
    this.onRowTap,
  });

  @override
  State<ReportTable<T>> createState() => _ReportTableState<T>();
}

class _ReportTableState<T> extends State<ReportTable<T>> {
  static const _pageSize = 50;

  String _query = '';
  int? _sortCol;
  bool _sortAsc = true;
  int _visible = _pageSize;

  List<T> get _filtered {
    final q = _query.trim().toLowerCase();
    var list = widget.rows;
    if (q.isNotEmpty) {
      list = list.where((r) {
        for (final c in widget.columns) {
          if (c.kind == ReportKind.serial) continue;
          if (c.display(r).toLowerCase().contains(q)) return true;
        }
        return false;
      }).toList();
    }
    if (_sortCol != null) {
      final c = widget.columns[_sortCol!];
      list = [...list]..sort((a, b) => _sortAsc ? c.compare(a, b) : c.compare(b, a));
    }
    return list;
  }

  @override
  void didUpdateWidget(covariant ReportTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.rows, widget.rows)) _visible = _pageSize;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;
    final shown = rows.take(_visible).toList();

    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 760;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Toolbar(
            hint: widget.searchHint,
            count: rows.length,
            total: widget.rows.length,
            onSearch: (v) => setState(() {
              _query = v;
              _visible = _pageSize;
            }),
            sortMenu: wide ? null : _mobileSortMenu(context),
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            _NoMatch(query: _query)
          else if (wide)
            _table(context, shown)
          else
            ...[for (var i = 0; i < shown.length; i++) _card(context, shown[i], i)],
          if (rows.length > shown.length)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _visible += _pageSize),
                  icon: const Icon(Icons.expand_more_rounded, size: 18),
                  label: Text('Show more (${rows.length - shown.length} left)'),
                ),
              ),
            ),
          if (widget.totals.isNotEmpty) ...[
            const SizedBox(height: 12),
            ReportTotalsBar(totals: widget.totals),
          ],
        ],
      );
    });
  }

  // ───────────── desktop table ─────────────

  Widget _table(BuildContext context, List<T> rows) {
    final cols = widget.columns;
    return AppDataTable(
      columns: [
        for (var i = 0; i < cols.length; i++)
          AppTableColumn(
            cols[i].label,
            flex: cols[i].flex,
            minWidth: cols[i].minWidth,
            align: cols[i].isNumeric
                ? AppCellAlign.end
                : (cols[i].kind == ReportKind.serial || cols[i].kind == ReportKind.status)
                    ? AppCellAlign.center
                    : AppCellAlign.start,
            sortKey: cols[i].kind == ReportKind.serial ? null : '$i',
          ),
      ],
      rowCount: rows.length,
      sortKey: _sortCol?.toString(),
      sortAscending: _sortAsc,
      onSort: (key, asc) => setState(() {
        _sortCol = int.tryParse(key);
        _sortAsc = asc;
      }),
      onRowTap: widget.onRowTap == null ? null : (i) => widget.onRowTap!(rows[i]),
      cellBuilder: (context, r, ci) {
        final c = cols[ci];
        final row = rows[r];
        final color = c.color?.call(row);
        switch (c.kind) {
          case ReportKind.serial:
            return AppTableText('${r + 1}', align: AppCellAlign.center, muted: true);
          case ReportKind.money:
            // AppTableMoney কমা দেয় না — report এ বড় অঙ্ক পড়তে কমা দরকার
            return AppTableText(ReportFmt.taka(c.value(row) as num?),
                align: AppCellAlign.end, bold: c.bold, color: color);
          case ReportKind.status:
            final label = c.display(row);
            return label.isEmpty ? const SizedBox() : AppStatusPill(label, color: color ?? reportStatusColor(label));
          case ReportKind.qty:
          case ReportKind.percent:
            return AppTableText(c.display(row), align: AppCellAlign.end, bold: c.bold, color: color);
          default:
            return AppTableText(
              c.display(row),
              bold: c.bold,
              color: color,
              subtitle: c.subtitle?.call(row),
            );
        }
      },
    );
  }

  // ───────────── mobile card ─────────────

  Widget _card(BuildContext context, T row, int index) {
    final cols = widget.columns;
    final primary = cols.where((c) => c.primary).firstOrNull ??
        cols.firstWhere((c) => c.kind == ReportKind.text, orElse: () => cols.last);
    final secondary = cols.where((c) => c.secondary).firstOrNull;
    final highlight = cols.where((c) => c.highlight).firstOrNull;
    final status = cols.where((c) => c.kind == ReportKind.status).firstOrNull;
    final rest = cols
        .where((c) =>
            c.inCard && c.kind != ReportKind.serial && c != primary && c != secondary && c != highlight && c != status)
        .toList();
    final text = AppColors.text(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greyColor(context).withValues(alpha: 0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: widget.onRowTap == null ? null : () => widget.onRowTap!(row),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(primary.display(row),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: text)),
                        if (secondary != null) ...[
                          const SizedBox(height: 2),
                          Text(secondary.display(row),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: AppColors.subText)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (highlight != null)
                        Text(
                          highlight.display(row, currency: true),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: highlight.color?.call(row) ?? text,
                          ),
                        ),
                      if (status != null && status.display(row).isNotEmpty) ...[
                        const SizedBox(height: 4),
                        AppStatusPill(status.display(row),
                            color: status.color?.call(row) ?? reportStatusColor(status.display(row))),
                      ],
                    ],
                  ),
                ],
              ),
              if (rest.isNotEmpty) ...[
                const SizedBox(height: 10),
                Divider(height: 1, color: AppColors.greyColor(context).withValues(alpha: 0.18)),
                const SizedBox(height: 10),
                LayoutBuilder(builder: (context, c) {
                  final w = (c.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      for (final col in rest)
                        SizedBox(
                          width: w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(col.label,
                                  style: TextStyle(fontSize: 11, color: AppColors.subText)),
                              const SizedBox(height: 1),
                              Text(
                                col.display(row, currency: col.kind == ReportKind.money),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: col.isNumeric ? FontWeight.w700 : FontWeight.w500,
                                  color: col.color?.call(row) ?? text,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobileSortMenu(BuildContext context) {
    final cols = widget.columns;
    return PopupMenuButton<int>(
      tooltip: 'Sort',
      icon: Icon(Icons.sort_rounded, color: _sortCol == null ? AppColors.subText : AppColors.primaryColor(context)),
      onSelected: (i) => setState(() {
        if (_sortCol == i) {
          _sortAsc = !_sortAsc;
        } else {
          _sortCol = i;
          _sortAsc = !cols[i].isNumeric; // টাকা/সংখ্যা: বড় থেকে ছোট আগে
        }
      }),
      itemBuilder: (_) => [
        for (var i = 0; i < cols.length; i++)
          if (cols[i].kind != ReportKind.serial)
            PopupMenuItem(
              value: i,
              child: Row(
                children: [
                  Expanded(child: Text(cols[i].label)),
                  if (_sortCol == i)
                    Icon(_sortAsc ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 16),
                ],
              ),
            ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  final String hint;
  final int count;
  final int total;
  final ValueChanged<String> onSearch;
  final Widget? sortMenu;

  const _Toolbar({
    required this.hint,
    required this.count,
    required this.total,
    required this.onSearch,
    this.sortMenu,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radius),
      borderSide: BorderSide(color: AppColors.greyColor(context).withValues(alpha: 0.4)),
    );
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 38,
            child: TextField(
              onChanged: onSearch,
              style: TextStyle(fontSize: 13.5, color: AppColors.text(context)),
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                hintStyle: TextStyle(fontSize: 13, color: AppColors.subText),
                prefixIcon: const Icon(Icons.search_rounded, size: 19),
                prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 36),
                contentPadding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                filled: true,
                fillColor: AppColors.bottomNavBg(context),
                border: border,
                enabledBorder: border,
                focusedBorder: border.copyWith(
                    borderSide: BorderSide(color: AppColors.primaryColor(context), width: 1.4)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          count == total ? '$total records' : '$count of $total',
          style: TextStyle(fontSize: 12, color: AppColors.subText, fontWeight: FontWeight.w500),
        ),
        if (sortMenu != null) sortMenu!,
      ],
    );
  }
}

class _NoMatch extends StatelessWidget {
  final String query;

  const _NoMatch({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 36, color: AppColors.subText.withValues(alpha: 0.7)),
          const SizedBox(height: 8),
          Text('Nothing matches "$query"', style: TextStyle(fontSize: 13, color: AppColors.subText)),
        ],
      ),
    );
  }
}

/// Table এর নিচের মোট হিসাব — চওড়া screen এ এক সারিতে ডানে, ছোট screen এ ২ কলামে
class ReportTotalsBar extends StatelessWidget {
  final List<ReportTotal> totals;

  const ReportTotalsBar({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withValues(alpha: 0.18)),
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 28,
        runSpacing: 10,
        children: [
          for (final t in totals)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t.label, style: TextStyle(fontSize: 11.5, color: AppColors.subText)),
                const SizedBox(height: 2),
                Text(t.value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: t.color ?? AppColors.text(context),
                    )),
              ],
            ),
        ],
      ),
    );
  }
}
