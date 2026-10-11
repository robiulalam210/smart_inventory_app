import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/configs/app_urls.dart';
import '../../../../core/repositories/get_response.dart';

/// Dashboard এর বাড়তি data — ওয়েবের dashboard.js যে চারটা API ডাকে, desktop ও সেগুলোই ডাকে:
///  • /reports/dashboard-trends/?days=   → চার্ট (শেষ ৭/৩০ দিন) + খরচের head ভাগ
///  • /accounts/?no_pagination=true      → account balance
///  • /reports/top-products/?start&end   → best sellers
///  • /reports/low-stock-alert/          → restock soon
/// প্রতিটা আলাদা — একটা ব্যর্থ হলে (যেমন অনুমতি নেই) বাকিগুলো ঠিকই দেখায়।
class DashboardExtras {
  static Future<Map<String, dynamic>?> trend(
      BuildContext context, int days) async {
    final data = await _get(
        context, '${AppUrls.baseUrl}/reports/dashboard-trends/',
        query: {'days': '$days'});
    return data is Map<String, dynamic> ? data : null;
  }

  static Future<List<Map<String, dynamic>>> accounts(
      BuildContext context) async {
    final data = await _get(
        context, '${AppUrls.baseUrl}/accounts/',
        query: {'no_pagination': 'true'});
    final raw = data is Map ? (data['results'] ?? data) : data;
    return _maps(raw)
        .where((a) => a['is_active'] != false)
        .toList(growable: false);
  }

  static Future<List<Map<String, dynamic>>> topProducts(
      BuildContext context, DateTime? start, DateTime? end) async {
    final q = <String, String>{};
    if (start != null) q['start'] = _ymd(start);
    if (end != null) q['end'] = _ymd(end);
    final data =
        await _get(context, '${AppUrls.baseUrl}/reports/top-products/', query: q);
    final raw = data is Map ? data['report'] : null;
    return _maps(raw).take(5).toList(growable: false);
  }

  static Future<List<Map<String, dynamic>>> lowStock(
      BuildContext context) async {
    final data =
        await _get(context, '${AppUrls.baseUrl}/reports/low-stock-alert/');
    final raw = data is Map ? data['report'] : null;
    return _maps(raw).take(6).toList(growable: false);
  }

  // ───── helpers ─────

  static Future<dynamic> _get(BuildContext context, String url,
      {Map<String, String>? query}) async {
    try {
      final res = await getResponse(
          context: context, url: url, queryParams: query);
      final body = json.decode(res);
      if (body is Map && body['status'] == true) return body['data'];
    } catch (_) {
      // নীরবে খালি — panel নিজেই "পাওয়া যায়নি" দেখাবে
    }
    return null;
  }

  static List<Map<String, dynamic>> _maps(dynamic raw) {
    if (raw is! List) return const [];
    return [
      for (final e in raw)
        if (e is Map) Map<String, dynamic>.from(e),
    ];
  }

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
