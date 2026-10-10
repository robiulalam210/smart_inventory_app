import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../../core/configs/app_urls.dart';
import '../../../core/repositories/delete_response.dart';
import '../../../core/repositories/get_response.dart';
import '../../../core/repositories/patch_response.dart';
import '../../../core/repositories/post_response.dart';
import 'payroll_models.dart';

/// Payroll API — /api/payroll/… (শুধু Admin / Super Admin)
/// পড়ার method (T?, String?) ফেরত দেয়; লেখার method error বার্তা ফেরত দেয় (null = সফল)।
class PayrollRepo {
  const PayrollRepo();

  static String get _base => '${AppUrls.baseUrl}/payroll';

  // ───────────── read ─────────────

  Future<(SlipPage?, String?)> slips(BuildContext context,
      {required String month, String status = '', int page = 1}) async {
    try {
      final d = await _get(context, '$_base/slips/', {
        'month': month,
        if (status.isNotEmpty) 'status': status,
        'page': '$page',
      });
      if (d.$1 == null) return (null, d.$2);
      final m = d.$1 as Map<String, dynamic>;
      final items = [
        for (final r in (m['results'] as List? ?? const []))
          if (r is Map) SalarySlip.fromJson(r.cast<String, dynamic>()),
      ];
      return (
        SlipPage(
          items,
          (m['count'] as num?)?.toInt() ?? items.length,
          (m['total_pages'] as num?)?.toInt() ?? 1,
          SlipSummary.fromJson(((m['summary'] ?? {}) as Map).cast<String, dynamic>()),
        ),
        null,
      );
    } catch (e) {
      return (null, 'Could not load salary slips: $e');
    }
  }

  Future<(AdvanceData?, String?)> advances(BuildContext context,
      {int? staffId, bool openOnly = false}) async {
    try {
      final d = await _get(context, '$_base/advances/', {
        if (staffId != null) 'staff': '$staffId',
        if (openOnly) 'open': '1',
      });
      if (d.$1 == null) return (null, d.$2);
      final m = d.$1 as Map<String, dynamic>;
      final items = [
        for (final r in (m['results'] as List? ?? const []))
          if (r is Map) SalaryAdvance.fromJson(r.cast<String, dynamic>()),
      ];
      final bal = <int, double>{};
      ((m['balances'] ?? {}) as Map).forEach((k, v) => bal[int.tryParse('$k') ?? 0] = payNum(v));
      return (AdvanceData(items, bal), null);
    } catch (e) {
      return (null, 'Could not load advances: $e');
    }
  }

  Future<(PayrollReport?, String?)> report(BuildContext context,
      {required String start, required String end}) async {
    try {
      final d = await _get(context, '$_base/report/', {'start': start, 'end': end});
      if (d.$1 == null) return (null, d.$2);
      final m = d.$1 as Map<String, dynamic>;
      final s = ((m['summary'] ?? {}) as Map).cast<String, dynamic>();
      return (
        PayrollReport(
          [
            for (final r in (m['results'] as List? ?? const []))
              if (r is Map) ReportRow.fromJson(r.cast<String, dynamic>()),
          ],
          basic: payNum(s['basic']),
          additions: payNum(s['additions']),
          deductions: payNum(s['deductions']),
          net: payNum(s['net']),
          paid: payNum(s['paid']),
          unpaid: payNum(s['unpaid']),
          advancesGiven: payNum(s['advances_given']),
          staff: (s['staff'] as num?)?.toInt() ?? 0,
        ),
        null,
      );
    } catch (e) {
      return (null, 'Could not load report: $e');
    }
  }

  Future<List<StaffOption>> staff(BuildContext context) async {
    try {
      final d = await _get(context, '$_base/staff/', null);
      final list = d.$1;
      if (list is List) {
        return [for (final r in list) if (r is Map) StaffOption.fromJson(r.cast<String, dynamic>())];
      }
    } catch (_) {}
    return const [];
  }

  /// চালু account গুলো (বেতন/অগ্রিম কোন account থেকে যাবে বাছতে)
  Future<List<AccountOption>> accounts(BuildContext context) async {
    try {
      final res = await getResponse(context: context, url: AppUrls.accountActive);
      dynamic d = jsonDecode(res);
      if (d is Map && d['data'] != null) d = d['data'];
      if (d is Map && d['results'] != null) d = d['results'];
      if (d is List) {
        return [
          for (final r in d)
            if (r is Map && r['id'] != null)
              AccountOption((r['id'] as num).toInt(), '${r['name'] ?? ''}', payNum(r['balance'])),
        ];
      }
    } catch (_) {}
    return const [];
  }

  // ───────────── write (null = সফল, নইলে error বার্তা) ─────────────

  Future<String?> generate(String month) =>
      _write(postResponse(url: '$_base/slips/generate/', payload: {'month': month}));

  Future<String?> updateSlip(int id, Map<String, dynamic> payload) =>
      _write(patchResponse(url: '$_base/slips/$id/', payload: payload));

  Future<String?> deleteSlip(int id) => _write(deleteResponse(url: '$_base/slips/$id/'));

  Future<String?> pay(int id, {required int accountId, required String method, required String date}) =>
      _write(postResponse(
        url: '$_base/slips/$id/pay/',
        payload: {'account_id': accountId, 'payment_method': method, 'date': date},
      ));

  Future<String?> unpay(int id) =>
      _write(postResponse(url: '$_base/slips/$id/unpay/', payload: {}));

  Future<String?> giveAdvance({
    required int staffId,
    required String amount,
    required int accountId,
    required String method,
    required String date,
    String note = '',
  }) =>
      _write(postResponse(url: '$_base/advances/', payload: {
        'staff_id': staffId,
        'amount': amount,
        'account_id': accountId,
        'payment_method': method,
        'date': date,
        'note': note,
      }));

  Future<String?> deleteAdvance(int id) => _write(deleteResponse(url: '$_base/advances/$id/'));

  // ───────────── helpers ─────────────

  Future<(dynamic, String?)> _get(BuildContext context, String url, Map<String, dynamic>? q) async {
    final res = await getResponse(context: context, url: url, queryParams: q);
    final json = jsonDecode(res);
    if (json is Map && json['status'] == true) return (json['data'], null);
    return (null, json is Map && json['message'] != null ? '${json['message']}' : 'Request failed');
  }

  Future<String?> _write(Future<Map<String, dynamic>> call) async {
    try {
      final r = await call;
      if (r['status'] == true) return null;
      final data = r['data'];
      if (data is Map && data['message'] != null) return '${data['message']}';
      return '${r['message'] ?? 'Request failed'}';
    } catch (e) {
      return 'Request failed: $e';
    }
  }
}
