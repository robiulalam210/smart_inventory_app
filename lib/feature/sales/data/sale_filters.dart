import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../../core/configs/app_urls.dart';
import '../../../core/repositories/get_response.dart';

/// সেল তালিকার ফিল্টার — ওয়েবের salesList() এর `f` এর হুবহু একই নিয়ম
/// (period preset, payment status, customer, seller, search)।
class SaleFilters {
  static const pageSize = 30; // server এর সর্বোচ্চ (ওয়েবের PAGE_SIZE)

  static const presets = <(String, String)>[
    ('today', 'Today'),
    ('7d', 'Last 7 days'),
    ('month', 'This month'),
    ('all', 'All time'),
    ('custom', 'Custom'),
  ];

  static const statuses = <(String, String)>[
    ('', 'All'),
    ('paid', 'Paid'),
    ('partial', 'Partial'),
    ('pending', 'Unpaid'),
    ('due', 'Has due'),
  ];

  String q;
  String status;
  String preset;
  DateTime? from;
  DateTime? to;
  int? customerId;
  int? sellerId;

  SaleFilters({
    this.q = '',
    this.status = '',
    this.preset = 'month',
    this.from,
    this.to,
    this.customerId,
    this.sellerId,
  }) {
    if (preset != 'custom') applyPreset(preset);
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// preset এর তারিখ — ওয়েবের rangeOf()
  void applyPreset(String key) {
    preset = key;
    final t = _day(DateTime.now());
    switch (key) {
      case 'today':
        from = t;
        to = t;
      case '7d':
        from = t.subtract(const Duration(days: 6));
        to = t;
      case 'month':
        from = DateTime(t.year, t.month, 1);
        to = t;
      case 'all':
        from = null;
        to = null;
      default: // custom — তারিখ ব্যবহারকারী বাছবে
        break;
    }
  }

  void reset() {
    q = '';
    status = '';
    customerId = null;
    sellerId = null;
    applyPreset('month');
  }

  /// ওয়েবের `filtered` — ডিফল্টের চেয়ে আলাদা কিছু বাছা আছে কি
  bool get isFiltered =>
      q.isNotEmpty || status.isNotEmpty || customerId != null || sellerId != null || preset != 'month';

  static String _iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// server এ যায় যে query — শুধু তারিখ (yyyy-MM-dd)। server নিজেই end_date কে দিনের শেষ ধরে,
  /// তাই আগের মতো "পরের দিন T00:00" পাঠালে এক দিন বেশি সেল চলে আসত।
  Map<String, String> toQuery() {
    DateTime? f = from, t = to;
    if (f != null && t != null && f.isAfter(t)) {
      final tmp = f;
      f = t;
      t = tmp;
    }
    final m = <String, String>{
      if (q.trim().isNotEmpty) 'search': q.trim(),
      if (customerId != null) 'customer': '$customerId',
      if (sellerId != null) 'seller': '$sellerId',
      if (f != null) 'start_date': _iso(f),
      if (t != null) 'end_date': _iso(t),
    };
    if (status == 'due') {
      m['due_only'] = 'true';
    } else if (status.isNotEmpty) {
      m['payment_status'] = status;
    }
    return m;
  }

  String listQuery(int page) {
    final m = {'page': '$page', 'page_size': '$pageSize', ...toQuery()};
    return '?${m.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
  }

  /// "1 Oct 2026 – 11 Oct 2026" (ওয়েবের periodText)
  String get periodText {
    if (preset == 'all' || (from == null && to == null)) return 'All time';
    String fmt(DateTime d) {
      const mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${d.day} ${mon[d.month - 1]} ${d.year}';
    }

    if (from != null && to != null && _iso(from!) == _iso(to!)) return fmt(from!);
    return '${from != null ? fmt(from!) : 'Start'} – ${to != null ? fmt(to!) : 'today'}';
  }
}

/// একই ফিল্টারে মোট হিসাব — /api/sales/summary/
class SaleSummary {
  final int totalSales;
  final double totalAmount, totalPaid, totalDue;
  const SaleSummary(this.totalSales, this.totalAmount, this.totalPaid, this.totalDue);

  static double _n(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  factory SaleSummary.fromJson(Map<String, dynamic> j) => SaleSummary(
        (j['total_sales'] as num?)?.toInt() ?? 0,
        _n(j['total_amount']),
        _n(j['total_paid']),
        _n(j['total_due']),
      );
}

class SaleSummaryRepo {
  const SaleSummaryRepo();

  /// ব্যর্থ হলে null — সারাংশ না এলেও তালিকা ঠিকই চলে (ওয়েবেও এমন)
  Future<SaleSummary?> fetch(BuildContext context, SaleFilters f) async {
    try {
      final q = f.toQuery();
      final res = await getResponse(
        context: context,
        url: AppUrls.posSaleSummary,
        queryParams: q.isEmpty ? null : q,
      );
      final json = jsonDecode(res);
      if (json is Map && json['status'] == true && json['data'] is Map) {
        return SaleSummary.fromJson((json['data'] as Map).cast<String, dynamic>());
      }
    } catch (_) {}
    return null;
  }
}
