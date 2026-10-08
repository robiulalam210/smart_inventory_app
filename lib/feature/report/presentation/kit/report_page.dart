import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:meherinMart/desktop/widgets/sidebar.dart';

import 'report_core.dart';

/// সব report এর একই কাঠামো:
///   ① header — নাম, সময়সীমা, Refresh / PDF
///   ② filter card — তারিখের দ্রুত বাছাই + report এর নিজস্ব filter
///   ③ summary card গুলো
///   ④ মূল data (table / statement) — loading, error, ফাঁকা অবস্থা সহ
///
/// নিজে scroll করে না — desktop এ বাইরের main area scroll করে, mobile এ
/// [ReportMobileShell] scroll দেয়।
class ReportPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  final bool showDate;
  final ReportRangePreset preset;
  final DateTimeRange? range;
  final void Function(ReportRangePreset preset, DateTimeRange? range)? onRangeChanged;

  /// report এর নিজস্ব filter (dropdown ইত্যাদি) — [ReportFilter] দিয়ে মোড়ানো
  final List<Widget> filters;
  final VoidCallback? onClear;
  final VoidCallback? onRefresh;
  final VoidCallback? onPdf;

  final List<ReportStat> stats;
  final bool loading;
  final String? error;
  final bool isEmpty;
  final String emptyTitle;
  final String emptyMessage;

  /// ফাঁকা অবস্থার বদলে দেখানো বার্তা (যেমন "আগে customer বাছুন")
  final Widget? prompt;
  final Widget? child;

  /// mobile এ AppBar নিজেই নাম দেখায় — তাই বড় header লুকানো
  final bool compact;

  const ReportPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.showDate = true,
    this.preset = ReportRangePreset.last30,
    this.range,
    this.onRangeChanged,
    this.filters = const [],
    this.onClear,
    this.onRefresh,
    this.onPdf,
    this.stats = const [],
    this.loading = false,
    this.error,
    this.isEmpty = false,
    this.emptyTitle = 'No data for this period',
    this.emptyMessage = 'Try another date range or clear the filters.',
    this.prompt,
    this.child,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 760;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!compact) ...[
            _Header(
              title: title,
              subtitle: subtitle,
              icon: icon,
              color: color,
              onRefresh: onRefresh,
              onPdf: loading || error != null || isEmpty ? null : onPdf,
            ),
            const SizedBox(height: 16),
          ],
          if (showDate || filters.isNotEmpty || compact)
            _FilterCard(
              wide: wide,
              showDate: showDate,
              preset: preset,
              range: range,
              onRangeChanged: onRangeChanged,
              filters: filters,
              onClear: onClear,
              compactActions: compact
                  ? _CompactActions(onRefresh: onRefresh, onPdf: loading || error != null || isEmpty ? null : onPdf)
                  : null,
            ),
          if (stats.isNotEmpty || loading) ...[
            const SizedBox(height: 16),
            _StatsGrid(stats: stats, loading: loading, width: c.maxWidth),
          ],
          const SizedBox(height: 16),
          _content(context),
        ],
      );
    });
  }

  Widget _content(BuildContext context) {
    if (prompt != null) return _Panel(child: prompt!);
    if (loading) return const _Panel(child: _LoadingRows());
    if (error != null) {
      return _Panel(
        child: ReportMessage(
          icon: Icons.cloud_off_rounded,
          color: AppColors.danger,
          title: 'Could not load this report',
          message: error!,
          action: onRefresh == null
              ? null
              : OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try again'),
                ),
        ),
      );
    }
    if (isEmpty) {
      return _Panel(
        child: ReportMessage(
          icon: Icons.insert_chart_outlined_rounded,
          color: color,
          title: emptyTitle,
          message: emptyMessage,
        ),
      );
    }
    return child ?? const SizedBox();
  }
}

/// filter এর একটা ঘর — চওড়া screen এ নির্দিষ্ট প্রস্থ, ছোট screen এ পুরো লাইন
class ReportFilter extends StatelessWidget {
  final Widget child;
  final double width;

  const ReportFilter({super.key, required this.child, this.width = 230});

  @override
  Widget build(BuildContext context) => SizedBox(width: width, child: child);
}

// ───────────────────────── header ─────────────────────────

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onRefresh;
  final VoidCallback? onPdf;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onRefresh,
    this.onPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.text(context))),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12.5, color: AppColors.subText)),
            ],
          ),
        ),
        if (onRefresh != null)
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        const SizedBox(width: 10),
        FilledButton.icon(
          onPressed: onPdf,
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
          label: const Text('Download PDF'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryColor(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

class _CompactActions extends StatelessWidget {
  final VoidCallback? onRefresh;
  final VoidCallback? onPdf;

  const _CompactActions({this.onRefresh, this.onPdf});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: onPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('PDF'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryColor(context)),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── filters ─────────────────────────

class _FilterCard extends StatelessWidget {
  final bool wide;
  final bool showDate;
  final ReportRangePreset preset;
  final DateTimeRange? range;
  final void Function(ReportRangePreset preset, DateTimeRange? range)? onRangeChanged;
  final List<Widget> filters;
  final VoidCallback? onClear;
  final Widget? compactActions;

  const _FilterCard({
    required this.wide,
    required this.showDate,
    required this.preset,
    required this.range,
    required this.onRangeChanged,
    required this.filters,
    required this.onClear,
    this.compactActions,
  });

  Future<void> _pickCustom(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: range,
      helpText: 'Select report period',
    );
    if (picked != null) onRangeChanged?.call(ReportRangePreset.custom, picked);
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDate) ...[
            Row(
              children: [
                Icon(Icons.event_note_outlined, size: 16, color: primary),
                const SizedBox(width: 6),
                Text('Period', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.subText)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(ReportFmt.range(range),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.text(context))),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final p in ReportRangePreset.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _PresetChip(
                        label: p == ReportRangePreset.custom ? 'Custom…' : p.label,
                        icon: p == ReportRangePreset.custom ? Icons.date_range_outlined : null,
                        selected: p == preset,
                        onTap: () {
                          if (p == ReportRangePreset.custom) {
                            _pickCustom(context);
                          } else {
                            onRangeChanged?.call(p, p.range);
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (filters.isNotEmpty) ...[
            if (showDate) const SizedBox(height: 12),
            wide
                ? Wrap(spacing: 12, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.end, children: [
                    ...filters,
                    if (onClear != null) _ClearButton(onClear: onClear!),
                  ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final f in filters)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          // ছোট screen এ প্রস্থ বাধা নয় — পুরো লাইন জুড়ে
                          child: f is ReportFilter ? f.child : f,
                        ),
                      if (onClear != null) Align(alignment: Alignment.centerRight, child: _ClearButton(onClear: onClear!)),
                    ],
                  ),
          ] else if (onClear != null && !wide) ...[
            const SizedBox(height: 4),
            Align(alignment: Alignment.centerRight, child: _ClearButton(onClear: onClear!)),
          ],
          if (compactActions != null) ...[
            const SizedBox(height: 12),
            compactActions!,
          ],
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.selected, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor(context);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? primary : AppColors.greyColor(context).withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: selected ? Colors.white : primary),
              const SizedBox(width: 5),
            ],
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

class _ClearButton extends StatelessWidget {
  final VoidCallback onClear;

  const _ClearButton({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onClear,
      icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
      label: const Text('Reset filters'),
    );
  }
}

// ───────────────────────── stats ─────────────────────────

class _StatsGrid extends StatelessWidget {
  final List<ReportStat> stats;
  final bool loading;
  final double width;

  const _StatsGrid({required this.stats, required this.loading, required this.width});

  @override
  Widget build(BuildContext context) {
    final count = loading && stats.isEmpty ? 4 : stats.length;
    final perRow = width >= 1100 ? (count >= 5 ? 5 : count) : width >= 760 ? 3 : 2;
    const gap = 12.0;
    final w = (width - gap * (perRow - 1)) / perRow - 0.5;
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (var i = 0; i < count; i++)
          SizedBox(
            width: w,
            child: loading ? const _StatSkeleton() : _StatCard(stat: stats[i]),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final ReportStat stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(stat.icon, color: stat.color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: AppColors.subText, fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(stat.value,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.text(context))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return stat.hint == null ? card : Tooltip(message: stat.hint!, child: card);
  }
}

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.greyColor(context).withValues(alpha: 0.15);
    return Container(
      height: 70,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(11))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 70, height: 9, color: c),
                const SizedBox(height: 8),
                Container(width: 110, height: 13, color: c),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── states ─────────────────────────

BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
      color: AppColors.bottomNavBg(context),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.greyColor(context).withValues(alpha: 0.2)),
    );

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(16), decoration: _cardDecoration(context), child: child);
  }
}

/// সাদা card — report এর মূল data এর চারপাশে (statement ইত্যাদির জন্য)
class ReportCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ReportCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) =>
      Container(padding: padding, decoration: _cardDecoration(context), child: child);
}

class ReportMessage extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final Widget? action;

  const ReportMessage({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
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
    );
  }
}

class _LoadingRows extends StatelessWidget {
  const _LoadingRows();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.greyColor(context).withValues(alpha: 0.14);
    return Column(
      children: [
        for (var i = 0; i < 7; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Container(width: 28, height: 12, color: c),
                const SizedBox(width: 16),
                Expanded(flex: 3, child: Container(height: 12, color: c)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: Container(height: 12, color: c)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: Container(height: 12, color: c)),
              ],
            ),
          ),
      ],
    );
  }
}

// ───────────────────────── shells ─────────────────────────

/// Desktop: বাঁয়ে sidebar (বড় screen এ), ডানে report — আগের সব desktop screen এর মতো।
/// বাইরের main area scroll করে, তাই এখানে scroll নেই।
class ReportDesktopShell extends StatelessWidget {
  final Widget child;
  final Future<void> Function()? onRefresh;

  const ReportDesktopShell({super.key, required this.child, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final isBigScreen = Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
    return Container(
      color: AppColors.background(context),
      child: SafeArea(
        child: ResponsiveRow(
          children: [
            if (isBigScreen)
              ResponsiveCol(
                xs: 0,
                sm: 1,
                md: 1,
                lg: 2,
                xl: 2,
                child: Container(color: Colors.white, child: const Sidebar()),
              ),
            ResponsiveCol(
              xs: 12,
              lg: 10,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mobile: AppBar + টেনে refresh + scroll
class ReportMobileShell extends StatelessWidget {
  final String title;
  final Widget child;
  final Future<void> Function() onRefresh;

  const ReportMobileShell({super.key, required this.title, required this.child, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text(title, style: AppTextStyle.titleMedium(context))),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: child,
        ),
      ),
    );
  }
}

/// ভাগ অনুযায়ী bar — "কোন খাতে কত" (Expense, Profit & Loss এর খরচ)
class ReportBreakdown extends StatelessWidget {
  final String title;
  final List<(String label, double value)> items;
  final Color color;
  final int maxItems;

  const ReportBreakdown({
    super.key,
    required this.title,
    required this.items,
    required this.color,
    this.maxItems = 8,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]..sort((a, b) => b.$2.compareTo(a.$2));
    final shown = sorted.take(maxItems).toList();
    final total = items.fold<double>(0, (s, e) => s + e.$2);
    final max = shown.isEmpty ? 1.0 : (shown.first.$2 == 0 ? 1.0 : shown.first.$2);
    return ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text(context))),
              ),
              Text(ReportFmt.taka(total),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          for (final e in shown)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(e.$1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12.5, color: AppColors.text(context))),
                      ),
                      Text(ReportFmt.taka(e.$2),
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.text(context))),
                      SizedBox(
                        width: 52,
                        child: Text(
                          total == 0 ? '' : '${(e.$2 / total * 100).toStringAsFixed(0)}%',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 11.5, color: AppColors.subText),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (e.$2 / max).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: color.withValues(alpha: 0.10),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            ),
          if (sorted.length > shown.length)
            Text('+ ${sorted.length - shown.length} more', style: TextStyle(fontSize: 11.5, color: AppColors.subText)),
        ],
      ),
    );
  }
}
