import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../../../../core/configs/app_colors.dart';
import '../../../../core/configs/number_format.dart';

/// Desktop dashboard এর ছোট ছোট নকশার অংশ — ওয়েবের dashboard এর (.panel, .kpi,
/// .rows, .flow, .alert-box, chart) হুবহু ভাষা। কোনো নতুন package লাগে না।

// ───────────────────────── helpers ─────────────────────────

num dashNum(dynamic v) {
  if (v is num) return v;
  return num.tryParse('${v ?? 0}') ?? 0;
}

String taka(dynamic v) => '৳ ${formatNumberAll(dashNum(v).toDouble())}';

String qtyText(dynamic v) {
  final n = dashNum(v).toDouble();
  if (n == n.roundToDouble()) return n.toStringAsFixed(0);
  return n.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
}

/// 12500 → 12.5K, 2300000 → 2.3M (চার্টের অক্ষের জন্য)
String compactNum(num v) {
  final a = v.abs();
  String f(double x) {
    final s = x.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  if (a >= 1e7) return '${f(v / 1e7)}Cr';
  if (a >= 1e5) return '${f(v / 1e5)}L';
  if (a >= 1e3) return '${f(v / 1e3)}K';
  return f(v.toDouble());
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "2026-10-11" → "11 Oct"
String shortDate(String iso) {
  final p = iso.split('-');
  if (p.length != 3) return iso;
  final m = int.tryParse(p[1]) ?? 1;
  return '${int.tryParse(p[2]) ?? 0} ${_months[(m - 1).clamp(0, 11)]}';
}

String dateText(DateTime? d) {
  if (d == null) return '';
  return '${d.day} ${_months[d.month - 1]} ${d.year}';
}

/// ওয়েবের --line / --muted এর সমতুল্য
class DashColors {
  final bool dark;
  DashColors(BuildContext c) : dark = Theme.of(c).brightness == Brightness.dark;

  Color get surface => dark ? const Color(0xFF131A2A) : Colors.white;
  Color get line => dark ? const Color(0xFF243049) : const Color(0xFFE2E8F0);
  Color get tint => dark ? const Color(0xFF1A2338) : const Color(0xFFF1F5F9);
  Color get ink => dark ? const Color(0xFFE8EDF7) : const Color(0xFF0F172A);
  Color get ink2 => dark ? const Color(0xFFC4CDE1) : const Color(0xFF334155);
  Color get muted => dark ? const Color(0xFF8B97B1) : const Color(0xFF64748B);
  Color get blue => dark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
  Color get purple => dark ? const Color(0xFFC4A1FF) : const Color(0xFF7C3AED);
  Color get orange => dark ? const Color(0xFFFB923C) : const Color(0xFFC2410C);
  Color get green => dark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
  Color get red => dark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
  Color get amber => dark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
  Color get cyan => dark ? const Color(0xFF22D3EE) : const Color(0xFF0891B2);

  List<Color> get palette => [blue, purple, orange, green, amber, cyan];
}

TextStyle _num(TextStyle s) =>
    s.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

// ───────────────────────── panel ─────────────────────────

class DashPanel extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const DashPanel({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(18, 16, 18, 16),
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: c.dark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: c.ink,
                      ),
                    ),
                    if (subtitle != null)
                      TextSpan(
                        text: '  $subtitle',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: c.muted,
                        ),
                      ),
                  ]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class DashEmpty extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;
  const DashEmpty(this.text, {super.key, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color ?? c.muted),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(text,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: color ?? c.muted)),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── segmented / tabs ─────────────────────────

/// ওয়েবের .seg — ছোট গোল কোণার segmented control
class DashSegmented<T> extends StatelessWidget {
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;
  final bool small;

  const DashSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    final primary = AppColors.primaryColor(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.tint,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final o in options)
            GestureDetector(
              onTap: () => onChanged(o.$1),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(
                      horizontal: small ? 11 : 16, vertical: small ? 5 : 8),
                  decoration: BoxDecoration(
                    color: o.$1 == value ? c.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: o.$1 == value
                        ? [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: c.dark ? 0.25 : 0.07),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    o.$2,
                    style: TextStyle(
                      fontSize: small ? 12 : 13.5,
                      fontWeight: FontWeight.w600,
                      color: o.$1 == value ? primary : c.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── KPI ─────────────────────────

class DashKpi extends StatelessWidget {
  final String title;
  final String value;
  final String? note;
  final IconData icon;
  final Color color;
  final bool loading;
  final bool loss;

  const DashKpi({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.note,
    this.loading = false,
    this.loss = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: loss ? c.red.withValues(alpha: 0.06) : c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: loss ? c.red.withValues(alpha: 0.35) : c.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: c.dark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.muted)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          loading
              ? Container(
                  height: 24,
                  width: 120,
                  decoration: BoxDecoration(
                      color: c.tint, borderRadius: BorderRadius.circular(6)),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value,
                      style: _num(TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: loss ? c.red : c.ink))),
                ),
          const SizedBox(height: 4),
          Text(note ?? ' ',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: c.muted)),
        ],
      ),
    );
  }
}

// ───────────────────────── list rows ─────────────────────────

class DashRow extends StatelessWidget {
  final String title;
  final String? sub;
  final String? date;
  final Widget? trailing;
  final bool last;

  const DashRow({
    super.key,
    required this.title,
    this.sub,
    this.date,
    this.trailing,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: c.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: c.ink)),
                if (sub != null && sub!.isNotEmpty)
                  Text(sub!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: c.muted)),
              ],
            ),
          ),
          if (date != null && date!.isNotEmpty) ...[
            const SizedBox(width: 12),
            Text(date!, style: TextStyle(fontSize: 12, color: c.muted)),
          ],
          if (trailing != null) ...[
            const SizedBox(width: 14),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class DashPill extends StatelessWidget {
  final String text;
  final Color color;
  const DashPill(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

/// সংখ্যা + নিচে ছোট "বকেয়া" লাইন
class DashAmount extends StatelessWidget {
  final String amount;
  final String? due;
  final Color? color;
  const DashAmount(this.amount, {super.key, this.due, this.color});

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(amount,
            style: _num(TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: color ?? c.ink))),
        if (due != null)
          Text(due!,
              style: TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w600, color: c.red)),
      ],
    );
  }
}

// ───────────────────────── money flow ─────────────────────────

class DashFlowRow extends StatelessWidget {
  final String label;
  final String hint;
  final double value;
  final double max;
  final bool incoming;

  const DashFlowRow({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.max,
    required this.incoming,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    final frac = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    final color = incoming ? c.green : c.orange;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 170,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: c.ink)),
                Text(hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: c.muted)),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(children: [
                Container(height: 10, color: c.tint),
                FractionallySizedBox(
                  widthFactor: value > 0 ? math.max(frac, 0.02) : 0,
                  child: Container(height: 10, color: color),
                ),
              ]),
            ),
          ),
          SizedBox(
            width: 130,
            child: Text(taka(value),
                textAlign: TextAlign.right,
                style: _num(TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: c.ink))),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── stock alert box ─────────────────────────

class DashAlertBox extends StatelessWidget {
  final int count;
  final String label;
  final Color hot;
  const DashAlertBox(
      {super.key, required this.count, required this.label, required this.hot});

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    final active = count > 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: active ? hot.withValues(alpha: 0.08) : c.tint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: active ? hot.withValues(alpha: 0.35) : c.line),
      ),
      child: Column(
        children: [
          Text('$count',
              style: _num(TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: active ? hot : c.ink))),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12.5, color: c.muted)),
        ],
      ),
    );
  }
}

// ───────────────────────── ranked bar (best sellers) ─────────────────────────

class DashRankRow extends StatelessWidget {
  final int rank;
  final String name;
  final String sub;
  final String amount;
  final double frac;
  final bool last;

  const DashRankRow({
    super.key,
    required this.rank,
    required this.name,
    required this.sub,
    required this.amount,
    required this.frac,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    final primary = AppColors.primaryColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: c.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$rank',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: c.ink)),
                Text(sub, style: TextStyle(fontSize: 12, color: c.muted)),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(children: [
                    Container(height: 5, color: c.tint),
                    FractionallySizedBox(
                      widthFactor: frac.clamp(0.0, 1.0),
                      child: Container(height: 5, color: primary),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(amount,
              style: _num(TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w700, color: c.ink))),
        ],
      ),
    );
  }
}

// ───────────────────────── charts ─────────────────────────

class TrendSeries {
  final String label;
  final List<double> values;
  final Color color;
  final bool fill;
  const TrendSeries(this.label, this.values, this.color, {this.fill = false});
}

/// শেষ ৭/৩০ দিনের লাইন চার্ট — hover করলে ওই দিনের তিনটা সংখ্যা tooltip এ
class DashLineChart extends StatefulWidget {
  final List<String> labels; // ISO তারিখ
  final List<TrendSeries> series;
  final double height;

  const DashLineChart({
    super.key,
    required this.labels,
    required this.series,
    this.height = 250,
  });

  @override
  State<DashLineChart> createState() => _DashLineChartState();
}

class _DashLineChartState extends State<DashLineChart> {
  int? _hover;

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(builder: (context, box) {
            final n = widget.labels.length;
            const left = 46.0, right = 8.0;
            final plotW = math.max(1.0, box.maxWidth - left - right);
            int? idxAt(double dx) {
              if (n == 0) return null;
              final step = n == 1 ? 0.0 : plotW / (n - 1);
              final i = step == 0 ? 0 : ((dx - left) / step).round();
              return i.clamp(0, n - 1);
            }

            return MouseRegion(
              onHover: (e) => setState(() => _hover = idxAt(e.localPosition.dx)),
              onExit: (_) => setState(() => _hover = null),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LinePainter(
                        labels: widget.labels,
                        series: widget.series,
                        colors: c,
                        hover: _hover,
                        left: left,
                        right: right,
                      ),
                    ),
                  ),
                  if (_hover != null) _tooltip(c, box.maxWidth, left, plotW),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 18,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            for (final s in widget.series)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration:
                      BoxDecoration(color: s.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(s.label,
                    style: TextStyle(fontSize: 12.5, color: c.ink2)),
              ]),
          ],
        ),
      ],
    );
  }

  Widget _tooltip(DashColors c, double width, double left, double plotW) {
    final n = widget.labels.length;
    final i = _hover!;
    final step = n == 1 ? 0.0 : plotW / (n - 1);
    final x = left + step * i;
    const tipW = 190.0;
    final dx = (x + 12 + tipW > width) ? x - 12 - tipW : x + 12;
    return Positioned(
      left: dx.clamp(0.0, math.max(0.0, width - tipW)),
      top: 4,
      child: IgnorePointer(
        child: Container(
          width: tipW,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: c.dark ? const Color(0xFF1C2640) : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(shortDate(widget.labels[i]),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              for (final s in widget.series)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: s.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(s.label,
                          style: const TextStyle(
                              color: Color(0xFFCBD5E1), fontSize: 12)),
                    ),
                    Text(taka(i < s.values.length ? s.values[i] : 0),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<String> labels;
  final List<TrendSeries> series;
  final DashColors colors;
  final int? hover;
  final double left;
  final double right;

  _LinePainter({
    required this.labels,
    required this.series,
    required this.colors,
    required this.hover,
    required this.left,
    required this.right,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = labels.length;
    if (n == 0) return;
    const top = 8.0, bottom = 24.0;
    final w = size.width - left - right;
    final h = size.height - top - bottom;

    double maxV = 0;
    for (final s in series) {
      for (final v in s.values) {
        if (v > maxV) maxV = v;
      }
    }
    if (maxV <= 0) maxV = 1;
    // ওপরের সীমা "সুন্দর" সংখ্যায় — 4টা ভাগ
    final rough = maxV / 4;
    final pow10 = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
    final f = rough / pow10;
    final nice = (f <= 1 ? 1 : f <= 2 ? 2 : f <= 5 ? 5 : 10) * pow10;
    final yMax = nice * 4;

    double xAt(int i) => left + (n == 1 ? w / 2 : w * i / (n - 1));
    double yAt(double v) => top + h - (v / yMax) * h;

    final grid = Paint()
      ..color = colors.line
      ..strokeWidth = 1;
    for (var g = 0; g <= 4; g++) {
      final y = top + h - h * g / 4;
      canvas.drawLine(Offset(left, y), Offset(left + w, y), grid);
      _text(canvas, compactNum(nice * g), Offset(left - 8, y),
          colors.muted, 11, align: _A.right);
    }

    // x লেবেল — বেশি হলে কিছু বাদ
    final maxTicks = n > 7 ? 8 : 7;
    final every = (n / maxTicks).ceil();
    for (var i = 0; i < n; i += every) {
      _text(canvas, shortDate(labels[i]), Offset(xAt(i), size.height - 6),
          colors.muted, 11, align: _A.center);
    }

    if (hover != null) {
      canvas.drawLine(
        Offset(xAt(hover!), top),
        Offset(xAt(hover!), top + h),
        Paint()
          ..color = colors.muted.withValues(alpha: 0.4)
          ..strokeWidth = 1,
      );
    }

    for (final s in series) {
      final pts = <Offset>[
        for (var i = 0; i < n && i < s.values.length; i++)
          Offset(xAt(i), yAt(s.values[i])),
      ];
      if (pts.isEmpty) continue;
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 1; i < pts.length; i++) {
        // monotone-এর কাছাকাছি নরম বাঁক
        final p0 = pts[i - 1], p1 = pts[i];
        final mx = (p0.dx + p1.dx) / 2;
        path.cubicTo(mx, p0.dy, mx, p1.dy, p1.dx, p1.dy);
      }
      if (s.fill) {
        final area = Path.from(path)
          ..lineTo(pts.last.dx, top + h)
          ..lineTo(pts.first.dx, top + h)
          ..close();
        canvas.drawPath(
          area,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                s.color.withValues(alpha: 0.22),
                s.color.withValues(alpha: 0.0),
              ],
            ).createShader(Rect.fromLTWH(left, top, w, h)),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
      if (n <= 8) {
        for (final p in pts) {
          canvas.drawCircle(p, 3.2, Paint()..color = s.color);
        }
      }
      if (hover != null && hover! < pts.length) {
        canvas.drawCircle(pts[hover!], 5, Paint()..color = colors.surface);
        canvas.drawCircle(
          pts[hover!],
          5,
          Paint()
            ..color = s.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.hover != hover ||
      old.labels != labels ||
      old.series != series ||
      old.colors.dark != colors.dark;
}

enum _A { left, center, right }

void _text(Canvas canvas, String s, Offset at, Color color, double size,
    {_A align = _A.left}) {
  final tp = TextPainter(
    text: TextSpan(text: s, style: TextStyle(color: color, fontSize: size)),
    textDirection: TextDirection.ltr,
  )..layout();
  final dx = switch (align) {
    _A.left => at.dx,
    _A.center => at.dx - tp.width / 2,
    _A.right => at.dx - tp.width,
  };
  tp.paint(canvas, Offset(dx, at.dy - tp.height / 2));
}

class DonutSlice {
  final String name;
  final double value;
  final Color color;
  const DonutSlice(this.name, this.value, this.color);
}

/// খরচ কোন head এ গেছে — মাঝে মোট টাকা
class DashDonut extends StatelessWidget {
  final List<DonutSlice> slices;
  const DashDonut({super.key, required this.slices});

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    final total = slices.fold<double>(0, (s, e) => s + e.value);
    return Column(
      children: [
        SizedBox(
          height: 170,
          width: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(170, 170),
                painter: _DonutPainter(slices, c.surface),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total',
                      style: TextStyle(fontSize: 11.5, color: c.muted)),
                  Text(compactNum(total),
                      style: _num(TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: c.ink))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final s in slices)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                    color: s.color, borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(s.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, color: c.ink2)),
              ),
              Text(
                  total <= 0
                      ? ''
                      : '${(s.value / total * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 12, color: c.muted)),
              const SizedBox(width: 10),
              Text(taka(s.value),
                  style: _num(TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: c.ink))),
            ]),
          ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSlice> slices;
  final Color gap;
  _DonutPainter(this.slices, this.gap);

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (s, e) => s + e.value);
    if (total <= 0) return;
    const stroke = 24.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke,
        size.height - stroke);
    var start = -math.pi / 2;
    for (final s in slices) {
      final sweep = s.value / total * 2 * math.pi;
      canvas.drawArc(
        rect,
        start,
        math.max(0.0, sweep - 0.03),
        false,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.slices != slices || old.gap != gap;
}
