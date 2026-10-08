import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ─────────────────────────────────────────────────────────────
/// Report kit এর ভিত্তি — সব report একই নিয়মে টাকা/তারিখ দেখায়,
/// আর একটা column একবার লিখলে সেটা desktop table, mobile card ও
/// PDF — তিন জায়গাতেই ব্যবহার হয়।
/// ─────────────────────────────────────────────────────────────

class ReportFmt {
  ReportFmt._();

  static final _money = NumberFormat('#,##0.00', 'en_US');
  static final _qty = NumberFormat('#,##0.##', 'en_US');
  static final _date = DateFormat('dd MMM yyyy');
  static final _dateTime = DateFormat('dd MMM yyyy, hh:mm a');

  static String money(num? v) => _money.format(v ?? 0);

  /// Screen এ ৳ সহ
  static String taka(num? v) => '৳ ${money(v)}';

  static String qty(num? v) => _qty.format(v ?? 0);

  static String date(DateTime? d) => d == null ? '—' : _date.format(d);

  static String dateTime(DateTime d) => _dateTime.format(d);

  static String range(DateTimeRange? r) {
    if (r == null) return 'All dates';
    if (r.start.year <= 2000) return 'All time (up to ${_date.format(r.end)})';
    if (DateUtils.isSameDay(r.start, r.end)) return _date.format(r.start);
    return '${_date.format(r.start)} – ${_date.format(r.end)}';
  }

  static String titleCase(String s) => s
      .replaceAll('_', ' ')
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

/// তারিখের দ্রুত বাছাই — Today, Last 7 days, This month ...
enum ReportRangePreset { today, yesterday, last7, last30, thisMonth, lastMonth, thisYear, allTime, custom }

extension ReportRangePresetX on ReportRangePreset {
  String get label => switch (this) {
        ReportRangePreset.today => 'Today',
        ReportRangePreset.yesterday => 'Yesterday',
        ReportRangePreset.last7 => 'Last 7 days',
        ReportRangePreset.last30 => 'Last 30 days',
        ReportRangePreset.thisMonth => 'This month',
        ReportRangePreset.lastMonth => 'Last month',
        ReportRangePreset.thisYear => 'This year',
        ReportRangePreset.allTime => 'All time',
        ReportRangePreset.custom => 'Custom',
      };

  DateTimeRange? get range {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (this) {
      ReportRangePreset.today => DateTimeRange(start: today, end: today),
      ReportRangePreset.yesterday => DateTimeRange(
          start: today.subtract(const Duration(days: 1)), end: today.subtract(const Duration(days: 1))),
      ReportRangePreset.last7 => DateTimeRange(start: today.subtract(const Duration(days: 6)), end: today),
      ReportRangePreset.last30 => DateTimeRange(start: today.subtract(const Duration(days: 29)), end: today),
      ReportRangePreset.thisMonth => DateTimeRange(start: DateTime(now.year, now.month, 1), end: today),
      ReportRangePreset.lastMonth => DateTimeRange(
          start: DateTime(now.year, now.month - 1, 1), end: DateTime(now.year, now.month, 0)),
      ReportRangePreset.thisYear => DateTimeRange(start: DateTime(now.year, 1, 1), end: today),
      // server তারিখ না পেলে নিজে "গত ৩০ দিন" ধরে নেয় — তাই "সব সময়" এর জন্য স্পষ্ট পুরো সীমা পাঠানো হয়
      ReportRangePreset.allTime => DateTimeRange(start: DateTime(2000, 1, 1), end: today),
      ReportRangePreset.custom => null,
    };
  }
}

/// কোন ধরনের মান — সাজানো (sort), ডানে/বাঁয়ে বসানো আর format এটা দেখে হয়
enum ReportKind { serial, text, money, qty, percent, date, status }

/// একটা column এর সংজ্ঞা।
/// - [value]: row থেকে মান (String / num / DateTime)
/// - [primary]: mobile card এর শিরোনাম
/// - [secondary]: mobile card এর শিরোনামের নিচের লাইন
/// - [highlight]: mobile card এর ডান পাশের বড় অঙ্ক
class ReportColumn<T> {
  final String label;
  final ReportKind kind;
  final dynamic Function(T row) value;
  final int flex;
  final double minWidth;
  final bool bold;
  final bool primary;
  final bool secondary;
  final bool highlight;
  final bool inCard;
  final bool inPdf;

  /// status pill এর রং, বা লেখার রং (যেমন ঋণাত্মক লাল)
  final Color? Function(T row)? color;

  /// desktop table এ দ্বিতীয় ছোট লাইন
  final String? Function(T row)? subtitle;

  const ReportColumn(
    this.label, {
    required this.value,
    this.kind = ReportKind.text,
    this.flex = 2,
    this.minWidth = 100,
    this.bold = false,
    this.primary = false,
    this.secondary = false,
    this.highlight = false,
    this.inCard = true,
    this.inPdf = true,
    this.color,
    this.subtitle,
  });

  const ReportColumn.serial()
      : label = 'SL',
        kind = ReportKind.serial,
        value = _noValue,
        flex = 1,
        minWidth = 52,
        bold = false,
        primary = false,
        secondary = false,
        highlight = false,
        inCard = false,
        inPdf = true,
        color = null,
        subtitle = null;

  static dynamic _noValue(dynamic _) => null;

  bool get isNumeric => kind == ReportKind.money || kind == ReportKind.qty || kind == ReportKind.percent;

  /// screen এ দেখানোর লেখা
  String display(T row, {bool currency = false}) {
    final v = value(row);
    return switch (kind) {
      ReportKind.serial => '',
      ReportKind.money => currency ? ReportFmt.taka(v as num?) : ReportFmt.money(v as num?),
      ReportKind.qty => ReportFmt.qty(v as num?),
      ReportKind.percent => '${((v as num?) ?? 0).toStringAsFixed(1)}%',
      ReportKind.date => v is DateTime ? ReportFmt.date(v) : '${v ?? '—'}',
      ReportKind.status => ReportFmt.titleCase('${v ?? ''}'),
      ReportKind.text => (v == null || '$v'.trim().isEmpty) ? '—' : '$v',
    };
  }

  int compare(T a, T b) {
    final va = value(a), vb = value(b);
    if (va == null && vb == null) return 0;
    if (va == null) return -1;
    if (vb == null) return 1;
    if (va is num && vb is num) return va.compareTo(vb);
    if (va is DateTime && vb is DateTime) return va.compareTo(vb);
    return '$va'.toLowerCase().compareTo('$vb'.toLowerCase());
  }
}

/// উপরের summary card (এবং PDF এর KPI box)
class ReportStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? hint;

  const ReportStat(this.label, this.value, {required this.icon, required this.color, this.hint});
}

/// Table এর নিচের মোট হিসাব (এবং PDF এর শেষ লাইন)
class ReportTotal {
  final String label;
  final String value;
  final Color? color;

  const ReportTotal(this.label, this.value, {this.color});
}

/// Payment / status এর রং — সব report এ একই অর্থে একই রং
Color reportStatusColor(String? status) {
  switch ((status ?? '').toLowerCase()) {
    case 'paid':
    case 'completed':
    case 'received':
    case 'settled':
    case 'in stock':
      return const Color(0xFF16A34A);
    case 'partial':
    case 'partially paid':
      return const Color(0xFF2563EB);
    case 'pending':
    case 'low':
    case 'advance':
      return const Color(0xFFF59E0B);
    case 'due':
    case 'unpaid':
    case 'overdue':
    case 'cancelled':
    case 'out of stock':
    case 'critical':
      return const Color(0xFFDC2626);
    default:
      return const Color(0xFF64748B);
  }
}
