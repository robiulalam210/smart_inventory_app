import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

/// ওয়েব সফটওয়্যারের (web/static/web/css/app.css) একই চেহারা মোবাইল অ্যাপে —
/// panel, pill, chip, summary bar, empty state। light ও dark দুই মোডের রং ওয়েবের টোকেন থেকে নেওয়া।
class W {
  W._();

  static bool dark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
  static Color _p(BuildContext c, int light, int darkV) => Color(dark(c) ? darkV : light);

  // মূল
  static Color surface(BuildContext c) => _p(c, 0xFFFFFFFF, 0xFF131A2A);
  static Color soft(BuildContext c) => _p(c, 0xFFFAFBFD, 0xFF172034);
  static Color tint(BuildContext c) => _p(c, 0xFFF1F5F9, 0xFF1C2640);
  static Color canvas(BuildContext c) => _p(c, 0xFFF4F6FA, 0xFF0B101B);
  static Color line(BuildContext c) => _p(c, 0xFFE2E8F0, 0xFF243049);
  static Color line2(BuildContext c) => _p(c, 0xFFCBD5E1, 0xFF34425F);
  static Color ink(BuildContext c) => _p(c, 0xFF0F172A, 0xFFE8EDF7);
  static Color ink2(BuildContext c) => _p(c, 0xFF334155, 0xFFC4CDE1);
  static Color muted(BuildContext c) => _p(c, 0xFF64748B, 0xFF8E9AB2);
  static Color onInk(BuildContext c) => _p(c, 0xFFFFFFFF, 0xFF0B101B);

  // নীল
  static Color blue(BuildContext c) => _p(c, 0xFF2563EB, 0xFF3B82F6);
  static Color blueInk(BuildContext c) => _p(c, 0xFF1D4ED8, 0xFF8AB4FF);
  static Color blueWash(BuildContext c) => _p(c, 0xFFEEF3FF, 0xFF15233F);
  static Color blueLine(BuildContext c) => _p(c, 0xFFC7D7FE, 0xFF2A4A8A);

  // সবুজ
  static Color greenInk(BuildContext c) => _p(c, 0xFF15803D, 0xFF4ADE80);
  static Color greenWash(BuildContext c) => _p(c, 0xFFF0FDF4, 0xFF0F2A20);
  static Color greenLine(BuildContext c) => _p(c, 0xFFBBF7D0, 0xFF1F5A3B);

  // লাল
  static Color redInk(BuildContext c) => _p(c, 0xFFB91C1C, 0xFFFCA5A5);
  static Color redWash(BuildContext c) => _p(c, 0xFFFEF2F2, 0xFF2C1618);
  static Color redLine(BuildContext c) => _p(c, 0xFFFECACA, 0xFF5B2326);

  // অ্যাম্বার
  static Color amberInk(BuildContext c) => _p(c, 0xFFB45309, 0xFFFBBF24);
  static Color amberWash(BuildContext c) => _p(c, 0xFFFFF7E6, 0xFF2B2110);
  static Color amberLine(BuildContext c) => _p(c, 0xFFFDE3B0, 0xFF5A4414);

  static const double rSm = 8, rMd = 10, rLg = 14;

  /// বাংলা ও ৳ এর জন্য fallback সহ সংখ্যা সমান-চওড়া লেখা
  static const tabular = [FontFeature.tabularFigures()];
}

enum WTone { neutral, blue, green, red, amber, muted }

extension WToneColors on WTone {
  Color bg(BuildContext c) => switch (this) {
        WTone.neutral => W.tint(c),
        WTone.blue => W.blueWash(c),
        WTone.green => W.greenWash(c),
        WTone.red => W.redWash(c),
        WTone.amber => W.amberWash(c),
        WTone.muted => W.tint(c),
      };

  Color fg(BuildContext c) => switch (this) {
        WTone.neutral => W.ink2(c),
        WTone.blue => W.blueInk(c),
        WTone.green => W.greenInk(c),
        WTone.red => W.redInk(c),
        WTone.amber => W.amberInk(c),
        WTone.muted => W.muted(c),
      };

  Color border(BuildContext c) => switch (this) {
        WTone.neutral => W.line(c),
        WTone.blue => W.blueLine(c),
        WTone.green => W.greenLine(c),
        WTone.red => W.redLine(c),
        WTone.amber => W.amberLine(c),
        WTone.muted => W.line(c),
      };
}

/// সাদা surface + ১px রেখা + ১৪px কোণা (ওয়েবের .panel)
class WPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? color;
  const WPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(W.rLg);
    final body = Padding(padding: padding ?? EdgeInsets.zero, child: child);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? W.surface(context),
        borderRadius: radius,
        border: Border.all(color: W.line(context)),
      ),
      child: onTap == null
          ? body
          : Material(
              color: Colors.transparent,
              child: InkWell(borderRadius: radius, onTap: onTap, child: body),
            ),
    );
  }
}

/// panel এর শিরোনাম সারি (ওয়েবের .panel-head)
class WPanelHead extends StatelessWidget {
  final String title;
  final String? note;
  final Widget? trailing;
  const WPanelHead(this.title, {super.key, this.note, this.trailing});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: W.ink(context))),
                if (note != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(note!, style: TextStyle(fontSize: 13, color: W.muted(context))),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      );
}

/// ছোট গোলাকার ব্যাজ (ওয়েবের .pill)
class WPill extends StatelessWidget {
  final String text;
  final WTone tone;
  final bool strike;
  final IconData? icon;
  const WPill(this.text, {super.key, this.tone = WTone.neutral, this.strike = false, this.icon});

  @override
  Widget build(BuildContext context) {
    final fg = tone.fg(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: tone.bg(context), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: fg), const SizedBox(width: 4)],
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              decoration: strike ? TextDecoration.lineThrough : null,
              decorationColor: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// ফিল্টার chip — বাছাই করলে গাঢ় ink রং (ওয়েবের .chip.is-on)
class WChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback? onTap;
  const WChip({super.key, required this.label, this.count, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final fg = selected ? W.onInk(context) : W.ink2(context);
    return Material(
      color: selected ? W.ink(context) : W.surface(context),
      shape: StadiumBorder(side: BorderSide(color: selected ? W.ink(context) : W.line2(context))),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: fg)),
              if (count != null) ...[
                const SizedBox(width: 6),
                Text('$count',
                    style: TextStyle(
                        fontSize: 13,
                        color: selected ? W.onInk(context).withValues(alpha: 0.7) : W.muted(context))),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// আনুভূমিক chip সারি
class WChipBar extends StatelessWidget {
  final List<Widget> chips;
  const WChipBar({super.key, required this.chips});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          itemCount: chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) => chips[i],
        ),
      );
}

/// সার্চ ঘর (ওয়েবের .f-search)
class WSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool showClear;
  const WSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onSubmitted,
    this.onChanged,
    this.onClear,
    this.showClear = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 42,
        padding: const EdgeInsets.only(left: 12, right: 4),
        decoration: BoxDecoration(
          color: W.surface(context),
          border: Border.all(color: W.line2(context)),
          borderRadius: BorderRadius.circular(W.rMd),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 18, color: W.muted(context)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                onSubmitted: onSubmitted,
                onChanged: onChanged,
                style: TextStyle(fontSize: 14.5, color: W.ink(context)),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: W.muted(context)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (showClear)
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.close, size: 18, color: W.muted(context)),
                onPressed: onClear,
              ),
          ],
        ),
      );
}

/// উপরের সংখ্যার সারি — ১px রেখায় আলাদা ঘর (ওয়েবের .sumbar)
class WSum {
  final String label, value;
  final Color? color;
  const WSum(this.label, this.value, {this.color});
}

class WSumBar extends StatelessWidget {
  final List<WSum> items;
  final EdgeInsetsGeometry margin;
  const WSumBar({super.key, required this.items, this.margin = const EdgeInsets.fromLTRB(16, 8, 16, 4)});

  @override
  Widget build(BuildContext context) {
    final line = W.line(context);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: line,
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(W.rLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 1),
              Expanded(
                child: Container(
                  color: W.surface(context),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(items[i].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: W.muted(context))),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(items[i].value,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: items[i].color ?? W.ink(context),
                                fontFeatures: W.tabular)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// খালি অবস্থা — নীল-wash আইকন টাইল (ওয়েবের .empty)
class WEmpty extends StatelessWidget {
  final IconData icon;
  final String title, body;
  final String? actionLabel;
  final VoidCallback? onAction;
  const WEmpty({
    super.key,
    required this.icon,
    required this.title,
    this.body = '',
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: W.blueWash(context), borderRadius: BorderRadius.circular(18)),
                child: Icon(icon, size: 26, color: W.blue(context)),
              ),
              const SizedBox(height: 16),
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: W.ink(context))),
              if (body.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(body,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: W.muted(context))),
              ],
              if (actionLabel != null) ...[
                const SizedBox(height: 18),
                OutlinedButton(
                  onPressed: onAction,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    foregroundColor: W.ink2(context),
                    side: BorderSide(color: W.line2(context)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(W.rMd)),
                  ),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      );
}

/// বার্তার বক্স (ওয়েবের .notice)
class WNotice extends StatelessWidget {
  final WTone tone;
  final IconData icon;
  final String text;
  final EdgeInsetsGeometry margin;
  const WNotice({
    super.key,
    required this.tone,
    required this.icon,
    required this.text,
    this.margin = const EdgeInsets.fromLTRB(16, 8, 16, 0),
  });

  @override
  Widget build(BuildContext context) {
    final fg = tone.fg(context);
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: tone.bg(context),
        border: Border.all(color: tone.border(context)),
        borderRadius: BorderRadius.circular(W.rMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 1), child: Icon(icon, size: 18, color: fg)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13.5, color: fg))),
        ],
      ),
    );
  }
}

/// ফর্মের গ্রুপ শিরোনাম
class WSectionLabel extends StatelessWidget {
  final String text;
  const WSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(text.toUpperCase(),
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: W.muted(context))),
      );
}

/// ওয়েবের মতো ইনপুট সাজ — সাদা surface, ১px রেখা, ফোকাসে নীল
InputDecoration wInput(BuildContext context, String label, {String? hint, String? prefix}) {
  OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(W.rMd),
        borderSide: BorderSide(color: c, width: w),
      );
  return InputDecoration(
    labelText: label,
    helperText: hint,
    prefixText: prefix,
    filled: true,
    fillColor: W.surface(context),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: b(W.line2(context)),
    focusedBorder: b(W.blue(context), 1.6),
    border: b(W.line2(context)),
  );
}

/// সময়-বাছাইয়ের মতো গোল সেগমেন্ট (ওয়েবের .seg) — বাছাই করাটা নীল
class WSeg extends StatelessWidget {
  final List<(String, String)> items; // (key, label)
  final String value;
  final ValueChanged<String> onChanged;
  const WSeg({super.key, required this.items, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: W.surface(context),
          border: Border.all(color: W.line(context)),
          borderRadius: BorderRadius.circular(W.rMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (key, label) in items)
              InkWell(
                borderRadius: BorderRadius.circular(7),
                onTap: () => onChanged(key),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: key == value ? W.blue(context) : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: key == value ? Colors.white : W.ink2(context),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

/// পাতা বদলের সারি — "Showing 1–30 of 120" + ‹ 1 … 4 [5] 6 … 20 › (ওয়েবের .pager)
class WPager extends StatelessWidget {
  final int page, totalPages, count, from, to;
  final ValueChanged<int> onPage;
  const WPager({
    super.key,
    required this.page,
    required this.totalPages,
    required this.count,
    required this.from,
    required this.to,
    required this.onPage,
  });

  List<int?> _pages() {
    // null = "…"
    final out = <int?>[];
    for (var i = 1; i <= totalPages; i++) {
      if (i == 1 || i == totalPages || (i - page).abs() <= 2) {
        out.add(i);
      } else if (out.isNotEmpty && out.last != null) {
        out.add(null);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    Widget arrow(IconData icon, bool enabled, VoidCallback tap) => Opacity(
          opacity: enabled ? 1 : 0.4,
          child: InkWell(
            borderRadius: BorderRadius.circular(W.rMd),
            onTap: enabled ? tap : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: W.surface(context),
                border: Border.all(color: W.line(context)),
                borderRadius: BorderRadius.circular(W.rMd),
              ),
              child: Icon(icon, size: 18, color: W.ink2(context)),
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 8,
        spacing: 12,
        children: [
          Text('Showing $from–$to of $count',
              style: TextStyle(fontSize: 13, color: W.muted(context))),
          if (totalPages > 1)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                arrow(Icons.chevron_left_rounded, page > 1, () => onPage(page - 1)),
                const SizedBox(width: 4),
                for (final p in _pages())
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: p == null
                        ? SizedBox(
                            width: 28,
                            child: Center(child: Text('…', style: TextStyle(color: W.muted(context)))),
                          )
                        : InkWell(
                            borderRadius: BorderRadius.circular(W.rSm),
                            onTap: p == page ? null : () => onPage(p),
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 36),
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: p == page ? W.blue(context) : Colors.transparent,
                                borderRadius: BorderRadius.circular(W.rSm),
                              ),
                              child: Text('$p',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: p == page ? Colors.white : W.ink2(context),
                                  )),
                            ),
                          ),
                  ),
                arrow(Icons.chevron_right_rounded, page < totalPages, () => onPage(page + 1)),
              ],
            ),
        ],
      ),
    );
  }
}
