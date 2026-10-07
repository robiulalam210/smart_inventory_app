import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import '../configs/configs.dart';

// ============================================================
// AppDataTable — desktop এর সব list টেবিলের জন্য একটাই component
// ------------------------------------------------------------
// আগের DataTable গুলোর সমস্যা:
//   • প্রতিটা column এর প্রস্থ = মোট প্রস্থ / column সংখ্যা — তাই
//     "SL" আর "Customer Name" সমান চওড়া, অথচ একটায় ২ অক্ষর আরেকটায় ২০
//   • DataTable এর default margin যোগ হয়ে টেবিল পর্দার চেয়ে চওড়া —
//     অকারণ horizontal scroll, প্রথম column কেটে যেত
//   • সব লেখা center — টাকার অঙ্ক একটার নিচে আরেকটা মিলত না
//   • 10px লেখা — desktop monitor এ পড়তে কষ্ট
//
// এখানে:
//   • flex — কোন column কতটা জায়গা পাবে (SL ছোট, নাম বড়)
//   • minWidth — জায়গা কম হলে তবেই horizontal scroll
//   • align — লেখা বাঁয়ে, টাকা ডানে, status/action মাঝে; header ও
//     cell একই align পায়, তাই সবসময় এক লাইনে মেলে
//   • zebra row + hover highlight — লম্বা টেবিলে চোখ হারায় না
// ============================================================

/// column এর লেখা কোন দিকে থাকবে
enum AppCellAlign { start, center, end }

class AppTableColumn {
  const AppTableColumn(
    this.label, {
    this.flex = 2,
    this.minWidth = 90,
    this.align = AppCellAlign.start,
    this.sortKey,
  });

  final String label;
  final int flex;
  final double minWidth;
  final AppCellAlign align;

  /// দিলে header এ ক্লিক করে এই column দিয়ে sort করা যায়
  final String? sortKey;

  /// টাকা / সংখ্যা — ডানে align, যাতে দশমিক এক লাইনে মেলে
  const AppTableColumn.numeric(this.label,
      {this.flex = 2, this.minWidth = 100, this.sortKey})
      : align = AppCellAlign.end;

  /// status / action — মাঝে
  const AppTableColumn.center(this.label,
      {this.flex = 2, this.minWidth = 90, this.sortKey})
      : align = AppCellAlign.center;
}

typedef AppTableCellBuilder = Widget Function(
  BuildContext context,
  int row,
  int column,
);

class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.columns,
    required this.rowCount,
    required this.cellBuilder,
    this.onRowTap,
    this.rowHeight = 48,
    this.headerHeight = 44,
    this.sortKey,
    this.sortAscending = true,
    this.onSort,
  });

  final List<AppTableColumn> columns;
  final int rowCount;
  final AppTableCellBuilder cellBuilder;
  final ValueChanged<int>? onRowTap;
  final double rowHeight;
  final double headerHeight;

  /// বর্তমানে কোন column দিয়ে sort হচ্ছে (AppTableColumn.sortKey)
  final String? sortKey;
  final bool sortAscending;
  final void Function(String key, bool ascending)? onSort;

  static Alignment alignmentOf(AppCellAlign a) => switch (a) {
        AppCellAlign.start => Alignment.centerLeft,
        AppCellAlign.center => Alignment.center,
        AppCellAlign.end => Alignment.centerRight,
      };

  static TextAlign textAlignOf(AppCellAlign a) => switch (a) {
        AppCellAlign.start => TextAlign.left,
        AppCellAlign.center => TextAlign.center,
        AppCellAlign.end => TextAlign.right,
      };

  /// flex অনুযায়ী প্রস্থ ভাগ — কিন্তু কোনো column minWidth এর নিচে নয়
  List<double> _widths(double available) {
    final raw = _rawWidths(available);
    // প্রতিটা column নিচে round — যোগফল কখনো available ছাড়াবে না;
    // বাকি পিক্সেল শেষ column পায়
    final w = raw.map((e) => e.floorToDouble()).toList();
    final double used = w.fold(0.0, (s, e) => s + e);
    if (available > used && w.isNotEmpty && raw.fold(0.0, (s, e) => s + e) <= available + 0.5) {
      w[w.length - 1] += (available - used);
    }
    return w;
  }

  List<double> _rawWidths(double available) {
    final double minTotal = columns.fold(0.0, (s, c) => s + c.minWidth);
    if (available <= minTotal) {
      return columns.map((c) => c.minWidth).toList();
    }
    final int flexTotal = columns.fold(0, (s, c) => s + c.flex);
    final List<double> w =
        columns.map((c) => available * c.flex / flexTotal).toList();

    // কোনো column min এর নিচে নামলে তাকে min দিয়ে বাকিদের থেকে কেটে নেওয়া
    double deficit = 0;
    int freeFlex = 0;
    for (int i = 0; i < w.length; i++) {
      if (w[i] < columns[i].minWidth) {
        deficit += columns[i].minWidth - w[i];
        w[i] = columns[i].minWidth;
      } else {
        freeFlex += columns[i].flex;
      }
    }
    if (deficit > 0 && freeFlex > 0) {
      for (int i = 0; i < w.length; i++) {
        if (w[i] > columns[i].minWidth) {
          w[i] = math.max(
            columns[i].minWidth,
            w[i] - deficit * columns[i].flex / freeFlex,
          );
        }
      }
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color border =
        isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.borderLight;

    return LayoutBuilder(
      builder: (context, constraints) {
        // −2: বাইরের container এর ১px border দুই পাশে। আগে এটা বাদ দেওয়া
        // হতো না, তাই row ২px চওড়া হয়ে শেষ column এ হলুদ-কালো
        // "overflow" দাগ দেখাত। floor — দশমিক পিক্সেলের যোগফলেও যেন না ছাড়ায়
        final double available = constraints.maxWidth.isFinite
            ? (constraints.maxWidth - 2).floorToDouble()
            : columns.fold(0.0, (s, c) => s + c.minWidth);
        final List<double> widths = _widths(available);
        final double tableWidth = widths.fold(0.0, (s, w) => s + w);

        final Widget table = SizedBox(
          width: tableWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderRow(
                columns: columns,
                widths: widths,
                height: headerHeight,
                sortKey: sortKey,
                sortAscending: sortAscending,
                onSort: onSort,
              ),
              for (int r = 0; r < rowCount; r++)
                _BodyRow(
                  index: r,
                  columns: columns,
                  widths: widths,
                  height: rowHeight,
                  border: border,
                  isLast: r == rowCount - 1,
                  onTap: onRowTap == null ? null : () => onRowTap!(r),
                  cellBuilder: cellBuilder,
                ),
            ],
          ),
        );

        return Container(
          decoration: BoxDecoration(
            color: AppColors.bottomNavBg(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          clipBehavior: Clip.antiAlias,
          child: tableWidth > available + 0.5
              ? _HorizontalScroller(child: table)
              : table,
        );
      },
    );
  }
}

/// জায়গা কম হলে তবেই horizontal scroll — নিজের controller রাখে যাতে
/// rebuild এ scroll position হারায় না
class _HorizontalScroller extends StatefulWidget {
  const _HorizontalScroller({required this.child});
  final Widget child;

  @override
  State<_HorizontalScroller> createState() => _HorizontalScrollerState();
}

class _HorizontalScrollerState extends State<_HorizontalScroller> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: 10),
        child: widget.child,
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.columns,
    required this.widths,
    required this.height,
    this.sortKey,
    this.sortAscending = true,
    this.onSort,
  });

  final List<AppTableColumn> columns;
  final List<double> widths;
  final double height;
  final String? sortKey;
  final bool sortAscending;
  final void Function(String key, bool ascending)? onSort;

  @override
  Widget build(BuildContext context) {
    final Color primary = AppColors.primaryColor(context);
    final Color onPrimary = AppColors.onColor(primary);

    return Container(
      height: height,
      color: primary,
      child: Row(
        children: [
          for (int i = 0; i < columns.length; i++)
            SizedBox(
              width: widths[i],
              child: _headerCell(columns[i], onPrimary),
            ),
        ],
      ),
    );
  }

  Widget _headerCell(AppTableColumn col, Color onPrimary) {
    final String? key = col.sortKey;
    final bool sortable = key != null && onSort != null;
    final bool active = sortable && key == sortKey;

    final Widget label = Text(
      col.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: AppDataTable.textAlignOf(col.align),
      style: TextStyle(
        color: onPrimary,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );

    Widget content = sortable
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: label),
              const SizedBox(width: 4),
              Icon(
                active
                    ? (sortAscending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded)
                    : Icons.unfold_more_rounded,
                size: 14,
                color: onPrimary.withValues(alpha: active ? 1 : 0.6),
              ),
            ],
          )
        : label;

    content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Align(
        alignment: AppDataTable.alignmentOf(col.align),
        child: content,
      ),
    );

    if (!sortable) return content;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // একই column এ আবার ক্লিক = উল্টো ক্রম
        onTap: () => onSort!(key, active ? !sortAscending : true),
        child: content,
      ),
    );
  }
}

class _BodyRow extends StatefulWidget {
  const _BodyRow({
    required this.index,
    required this.columns,
    required this.widths,
    required this.height,
    required this.border,
    required this.isLast,
    required this.onTap,
    required this.cellBuilder,
  });

  final int index;
  final List<AppTableColumn> columns;
  final List<double> widths;
  final double height;
  final Color border;
  final bool isLast;
  final VoidCallback? onTap;
  final AppTableCellBuilder cellBuilder;

  @override
  State<_BodyRow> createState() => _BodyRowState();
}

class _BodyRowState extends State<_BodyRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final Color primary = AppColors.primaryColor(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bg = _hover
        ? primary.withValues(alpha: 0.06)
        : widget.index.isOdd
            ? (isDark
                ? Colors.white.withValues(alpha: 0.02)
                : const Color(0xFFF8FAFC))
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: BoxConstraints(minHeight: widget.height),
          decoration: BoxDecoration(
            color: bg,
            border: widget.isLast
                ? null
                : Border(bottom: BorderSide(color: widget.border)),
          ),
          child: Row(
            children: [
              for (int c = 0; c < widget.columns.length; c++)
                SizedBox(
                  width: widget.widths[c],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: Align(
                      alignment:
                          AppDataTable.alignmentOf(widget.columns[c].align),
                      // status pill / action বাটন জায়গার চেয়ে চওড়া হলে
                      // overflow দাগ না দেখিয়ে সামান্য ছোট হয়ে যায়
                      child: widget.columns[c].align == AppCellAlign.center
                          ? FittedBox(
                              fit: BoxFit.scaleDown,
                              child:
                                  widget.cellBuilder(context, widget.index, c),
                            )
                          : widget.cellBuilder(context, widget.index, c),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CELL HELPERS
// ============================================================

/// সাধারণ লেখা — এক লাইন, বেশি হলে "…" আর hover এ পুরোটা tooltip এ।
/// subtitle দিলে নিচে ছোট ধূসর দ্বিতীয় লাইন (যেমন Bank এর নিচে Branch)
class AppTableText extends StatelessWidget {
  const AppTableText(
    this.text, {
    super.key,
    this.align = AppCellAlign.start,
    this.color,
    this.bold = false,
    this.muted = false,
    this.subtitle,
  });

  final String text;
  final AppCellAlign align;
  final Color? color;
  final bool bold;
  final bool muted;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final Color base = AppColors.text(context);
    final String shown = (text.trim().isEmpty || text == 'null') ? '-' : text;
    final Widget t = Text(
      shown,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: AppDataTable.textAlignOf(align),
      style: TextStyle(
        fontSize: 13,
        height: 1.3,
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: color ?? (muted ? base.withValues(alpha: 0.6) : base),
        fontFeatures: align == AppCellAlign.end
            ? const [FontFeature.tabularFigures()]
            : null,
      ),
    );

    Widget child = t;
    final sub = subtitle;
    if (sub != null && sub.trim().isNotEmpty && sub != 'null') {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: switch (align) {
          AppCellAlign.start => CrossAxisAlignment.start,
          AppCellAlign.center => CrossAxisAlignment.center,
          AppCellAlign.end => CrossAxisAlignment.end,
        },
        children: [
          t,
          const SizedBox(height: 2),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, color: base.withValues(alpha: 0.55)),
          ),
        ],
      );
    }
    return shown.length > 18 ? Tooltip(message: shown, child: child) : child;
  }
}

/// টাকার অঙ্ক — ডানে align, ৳ সহ, ঋণাত্মক হলে লাল
class AppTableMoney extends StatelessWidget {
  const AppTableMoney(
    this.value, {
    super.key,
    this.bold = false,
    this.color,
    this.signColor = false,
  });

  final num? value;
  final bool bold;
  final Color? color;

  /// true হলে ধনাত্মক সবুজ, ঋণাত্মক লাল
  final bool signColor;

  static double parse(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final double v = (value ?? 0).toDouble();
    Color? c = color;
    if (signColor && v != 0) c = v < 0 ? AppColors.danger : AppColors.success;
    return AppTableText(
      '৳${v.toStringAsFixed(2)}',
      align: AppCellAlign.end,
      bold: bold,
      color: c,
    );
  }
}

/// সম্পাদনা / মুছে ফেলা — সব টেবিলে একই রকম action জোড়া
class AppTableEditDelete extends StatelessWidget {
  const AppTableEditDelete({
    super.key,
    this.onEdit,
    this.onDelete,
    this.onView,
    this.extra = const [],
  });

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onView;
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onView != null)
          AppTableAction(
            icon: Icons.visibility_outlined,
            tooltip: 'View',
            color: AppColors.info,
            onPressed: onView,
          ),
        ...extra,
        if (onEdit != null)
          AppTableAction(
            icon: Icons.edit_outlined,
            tooltip: 'Edit',
            color: AppColors.info,
            onPressed: onEdit,
          ),
        if (onDelete != null)
          AppTableAction(
            icon: Icons.delete_outline_rounded,
            tooltip: 'Delete',
            color: AppColors.danger,
            onPressed: onDelete,
          ),
      ],
    );
  }
}

/// রঙিন ছোট pill — Paid / Partial / Due ইত্যাদি
class AppStatusPill extends StatelessWidget {
  const AppStatusPill(this.label, {super.key, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// row এর action icon — hover এ রঙিন পটভূমি, tooltip সহ
class AppTableAction extends StatelessWidget {
  const AppTableAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? AppColors.primaryColor(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          hoverColor: c.withValues(alpha: 0.10),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: c),
          ),
        ),
      ),
    );
  }
}
