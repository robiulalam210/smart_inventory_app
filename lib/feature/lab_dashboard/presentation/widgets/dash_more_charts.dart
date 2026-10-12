import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../stock_tools/data/stock_models.dart';
import '../../../stock_tools/data/stock_repo.dart';
import 'dash_kit.dart';
import 'dashboard_extras.dart';

const _mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// Dashboard এর অতিরিক্ত চার্ট (ওয়েবের dashboard এর মতোই):
///  • মাসভিত্তিক লাভ  • লাভ-ক্ষতির ট্রেন্ড (দৈনিক)  • পণ্যের স্টক মূল্য (ক্যাটাগরি অনুযায়ী)
///  • Account balance এর ভাগ  • মেয়াদ শেষের সতর্কতা
/// কোনো নতুন package লাগে না — চার্ট CustomPaint এ আঁকা।
/// [accounts] — dashboard এর আগে-আনা account তালিকা (null হলে ভাগের চার্ট "Loading…")।
/// [onOpenExpiry] — "View all" চাপলে Expiry Alerts পেজ খোলার কাজ।
class DashMoreCharts extends StatefulWidget {
  final bool wide;
  final List<Map<String, dynamic>>? accounts;
  final VoidCallback? onOpenExpiry;

  const DashMoreCharts({super.key, this.wide = false, this.accounts, this.onOpenExpiry});

  @override
  State<DashMoreCharts> createState() => _DashMoreChartsState();
}

class _DashMoreChartsState extends State<DashMoreCharts> {
  final _repo = const StockRepo();
  DashboardCharts? _charts;
  ExpiryReport? _expiry;
  List<Map<String, dynamic>>? _ownAccounts; // [accounts] না দিলে নিজেই আনে (mobile)
  bool _loading = true;
  bool _failed = false;
  int _months = 6;
  int _days = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _repo.charts(context, months: _months, days: _days),
      _repo.expiry(context, days: 30, status: 'alerts', limit: 5),
    ]);
    if (widget.accounts == null && _ownAccounts == null && mounted) {
      final a = await DashboardExtras.accounts(context);
      if (mounted) _ownAccounts = a;
    }
    if (!mounted) return;
    final ch = results[0].$1 as DashboardCharts?;
    final ex = results[1].$1 as ExpiryReport?;
    setState(() {
      _loading = false;
      _failed = ch == null;
      if (ch != null) _charts = ch;
      _expiry = ex;
    });
  }

  Widget _row(Widget a, Widget b) {
    if (!widget.wide) return Column(children: [a, const SizedBox(height: 16), b]);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: a),
      const SizedBox(width: 16),
      Expanded(child: b),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    final ch = _charts;
    if (ch == null) {
      return DashPanel(
        title: 'Business charts',
        child: _loading
            ? const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
            : DashEmpty(_failed ? 'Charts are not available right now.' : 'No data yet.'),
      );
    }
    return Column(
      children: [
        if (_expiry != null && _expiry!.alerts > 0) ...[
          _expiryPanel(c, _expiry!),
          const SizedBox(height: 16),
        ],
        _row(_monthlyPanel(c, ch), _trendPanel(c, ch)),
        const SizedBox(height: 16),
        _row(_stockPanel(c, ch), _accountsPanel(c)),
      ],
    );
  }

  // ───────── মেয়াদ ─────────

  Widget _expiryPanel(DashColors c, ExpiryReport r) {
    return DashPanel(
      title: 'Expiry alerts',
      subtitle: '${r.expired} expired · ${r.expiring} expiring soon',
      trailing: widget.onOpenExpiry == null
          ? null
          : TextButton(onPressed: widget.onOpenExpiry, child: const Text('View all')),
      child: Column(
        children: [
          for (var i = 0; i < r.batches.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: i == r.batches.length - 1 ? null : Border(bottom: BorderSide(color: c.line)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: r.batches[i].status == 'expired' ? c.red : c.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.batches[i].productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w600, color: c.ink)),
                        Text(
                          '${r.batches[i].batchNo.isNotEmpty ? 'Batch ${r.batches[i].batchNo} · ' : ''}${qtyText(r.batches[i].qtyRemaining)} left',
                          style: TextStyle(fontSize: 12, color: c.muted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    r.batches[i].status == 'expired'
                        ? 'Expired ${r.batches[i].daysLeft.abs()}d ago'
                        : (r.batches[i].daysLeft == 0 ? 'Today' : '${r.batches[i].daysLeft}d left'),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: r.batches[i].status == 'expired' ? c.red : c.amber,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ───────── মাসভিত্তিক লাভ ─────────

  Widget _monthlyPanel(DashColors c, DashboardCharts ch) {
    final labels = [
      for (final l in ch.monthLabels) _monthName(l),
    ];
    final totalNet = ch.netProfit.fold<double>(0, (s, v) => s + v);
    return DashPanel(
      title: 'Monthly profit',
      subtitle: 'Net, after expenses',
      trailing: DashSegmented<int>(
        small: true,
        options: const [(6, '6 mo'), (12, '12 mo')],
        value: _months,
        onChanged: (v) {
          if (v == _months) return;
          _months = v;
          _load();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(taka(totalNet),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: totalNet < 0 ? c.red : c.green)),
          Text('over the last $_months months', style: TextStyle(fontSize: 12, color: c.muted)),
          const SizedBox(height: 10),
          SizedBox(
            height: 190,
            child: CustomPaint(
              size: Size.infinite,
              painter: _BarsPainter(values: ch.netProfit, labels: labels, pos: c.green, neg: c.red, ink: c.muted, line: c.line),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(String ym) {
    final p = ym.split('-');
    if (p.length < 2) return ym;
    final m = int.tryParse(p[1]) ?? 1;
    return _mon[(m - 1).clamp(0, 11)];
  }

  // ───────── লাভ-ক্ষতির ট্রেন্ড ─────────

  Widget _trendPanel(DashColors c, DashboardCharts ch) {
    final total = ch.dayNet.fold<double>(0, (s, v) => s + v);
    final labels = [for (final d in ch.dayLabels) shortDate(d)];
    return DashPanel(
      title: 'Profit / loss trend',
      subtitle: 'Daily',
      trailing: DashSegmented<int>(
        small: true,
        options: const [(7, '7 d'), (30, '30 d')],
        value: _days,
        onChanged: (v) {
          if (v == _days) return;
          _days = v;
          _load();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(taka(total), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: total < 0 ? c.red : c.green)),
          Text('over the last $_days days', style: TextStyle(fontSize: 12, color: c.muted)),
          const SizedBox(height: 10),
          SizedBox(
            height: 190,
            child: CustomPaint(
              size: Size.infinite,
              painter: _LinePainter(values: ch.dayNet, labels: labels, color: c.blue, neg: c.red, ink: c.muted, line: c.line),
            ),
          ),
        ],
      ),
    );
  }

  // ───────── স্টক মূল্য ─────────

  Widget _stockPanel(DashColors c, DashboardCharts ch) {
    final cats = ch.byCategory;
    final maxV = cats.fold<double>(0, (m, e) => math.max(m, e.costValue));
    return DashPanel(
      title: 'Stock value',
      subtitle: '${ch.stockProducts} products',
      child: cats.isEmpty
          ? const DashEmpty('No stock yet.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 22,
                  runSpacing: 6,
                  children: [
                    _stat(c, 'At cost', taka(ch.stockCost), c.ink),
                    _stat(c, 'At selling price', taka(ch.stockRetail), c.ink),
                    _stat(c, 'Expected margin', taka(ch.stockMargin), ch.stockMargin < 0 ? c.red : c.green),
                  ],
                ),
                const SizedBox(height: 14),
                for (var i = 0; i < cats.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(cats[i].name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink2)),
                            ),
                            Text(taka(cats[i].costValue), style: TextStyle(fontSize: 12.5, color: c.muted)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: maxV <= 0 ? 0 : cats[i].costValue / maxV,
                            minHeight: 7,
                            backgroundColor: c.tint,
                            valueColor: AlwaysStoppedAnimation(c.palette[i % c.palette.length]),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _stat(DashColors c, String label, String value, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: c.muted)),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
        ],
      );

  // ───────── account balance এর ভাগ ─────────

  Widget _accountsPanel(DashColors c) {
    final list = widget.accounts ?? _ownAccounts;
    if (list == null) {
      return const DashPanel(title: 'Account balance share', child: DashEmpty('Loading…'));
    }
    final rows = [
      for (final a in list)
        if (dashNum(a['balance']) > 0) (name: '${a['name'] ?? ''}', value: dashNum(a['balance']).toDouble()),
    ]..sort((a, b) => b.value.compareTo(a.value));
    final total = rows.fold<double>(0, (s, e) => s + e.value);
    return DashPanel(
      title: 'Account balance share',
      trailing: rows.isEmpty
          ? null
          : Text(taka(total), style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: c.ink)),
      child: rows.isEmpty
          ? const DashEmpty('No account has a balance yet.')
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      values: [for (final r in rows) r.value],
                      colors: [for (var i = 0; i < rows.length; i++) c.palette[i % c.palette.length]],
                      hole: c.surface,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      for (var i = 0; i < rows.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: c.palette[i % c.palette.length],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(rows[i].name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 13, color: c.ink2)),
                              ),
                              Text('${(rows[i].value / total * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.ink)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ═════════════════════════ painters ═════════════════════════

void _text(Canvas canvas, String s, Offset at, Color color,
    {double size = 10.5, bool center = false, bool right = false, FontWeight weight = FontWeight.w500}) {
  final tp = TextPainter(
    text: TextSpan(text: s, style: TextStyle(fontSize: size, color: color, fontWeight: weight)),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  final dx = center ? at.dx - tp.width / 2 : (right ? at.dx - tp.width : at.dx);
  tp.paint(canvas, Offset(dx, at.dy));
}

/// min/max কে সুন্দর সীমায় আনা (শূন্য সবসময় ভেতরে)
(double, double) _range(List<double> v) {
  var lo = 0.0, hi = 0.0;
  for (final x in v) {
    lo = math.min(lo, x);
    hi = math.max(hi, x);
  }
  if (hi == lo) hi = lo + 1;
  final pad = (hi - lo) * 0.12;
  return (lo < 0 ? lo - pad : 0, hi > 0 ? hi + pad : 0);
}

class _BarsPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color pos, neg, ink, line;
  _BarsPainter({required this.values, required this.labels, required this.pos, required this.neg, required this.ink, required this.line});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const left = 4.0, bottom = 22.0, top = 16.0;
    final (lo, hi) = _range(values);
    final h = size.height - bottom - top;
    double y(double v) => top + (hi - v) / (hi - lo) * h;
    final zero = y(0);
    canvas.drawLine(Offset(left, zero), Offset(size.width, zero), Paint()..color = line..strokeWidth = 1);

    final slot = (size.width - left) / values.length;
    final bw = math.min(34.0, slot * 0.62);
    final showAll = values.length <= 8;
    for (var i = 0; i < values.length; i++) {
      final cx = left + slot * i + slot / 2;
      final v = values[i];
      final yy = y(v);
      final rect = Rect.fromLTRB(cx - bw / 2, math.min(yy, zero), cx + bw / 2, math.max(yy, zero));
      if (rect.height > 0.5) {
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), Paint()..color = v < 0 ? neg : pos);
      }
      if (showAll && v != 0) {
        _text(canvas, compactNum(v), Offset(cx, v >= 0 ? rect.top - 14 : rect.bottom + 2), ink, center: true, size: 10);
      }
      if (showAll || i % 2 == 0) {
        _text(canvas, i < labels.length ? labels[i] : '', Offset(cx, size.height - 16), ink, center: true);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter o) => o.values != values || o.labels != labels || o.pos != pos || o.neg != neg;
}

class _LinePainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color color, neg, ink, line;
  _LinePainter({required this.values, required this.labels, required this.color, required this.neg, required this.ink, required this.line});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    const left = 4.0, right = 8.0, bottom = 22.0, top = 8.0;
    final (lo, hi) = _range(values);
    final w = size.width - left - right;
    final h = size.height - bottom - top;
    double x(int i) => left + w * i / (values.length - 1);
    double y(double v) => top + (hi - v) / (hi - lo) * h;
    final zero = y(0);

    // গ্রিড: শূন্য রেখা + উপর/নিচের সীমা
    final grid = Paint()..color = line..strokeWidth = 1;
    canvas.drawLine(Offset(left, zero), Offset(size.width - right, zero), grid);
    _text(canvas, compactNum(hi), Offset(left, top - 2), ink, size: 9.5);
    if (lo < 0) _text(canvas, compactNum(lo), Offset(left, top + h - 12), ink, size: 9.5);

    final path = Path()..moveTo(x(0), y(values[0]));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(x(i), y(values[i]));
    }
    final area = Path.from(path)
      ..lineTo(x(values.length - 1), zero)
      ..lineTo(x(0), zero)
      ..close();
    canvas.drawPath(area, Paint()..color = color.withValues(alpha: 0.10));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round,
    );
    // ক্ষতির দিনগুলো লাল বিন্দু
    for (var i = 0; i < values.length; i++) {
      if (values[i] < 0) canvas.drawCircle(Offset(x(i), y(values[i])), 3, Paint()..color = neg);
    }
    canvas.drawCircle(Offset(x(values.length - 1), y(values.last)), 3.5, Paint()..color = color);

    // নিচের তারিখ: প্রথম, মাঝের, শেষ
    if (labels.length == values.length) {
      for (final i in {0, values.length ~/ 2, values.length - 1}) {
        _text(canvas, labels[i], Offset(x(i), size.height - 16), ink, center: i != 0 && i != values.length - 1, right: i == values.length - 1, size: 10);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter o) => o.values != values || o.labels != labels || o.color != color;
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final Color hole;
  _DonutPainter({required this.values, required this.colors, required this.hole});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (s, v) => s + v);
    if (total <= 0) return;
    final side = math.min(size.width, size.height);
    final rect = Rect.fromCenter(center: size.center(Offset.zero), width: side - 8, height: side - 8);
    final stroke = side * 0.2;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * math.pi * 2;
      canvas.drawArc(
        rect.deflate(stroke / 2),
        start,
        math.max(0, sweep - (values.length > 1 ? 0.03 : 0)),
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter o) => o.values != values || o.colors != colors;
}
