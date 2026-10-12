import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../../core/configs/app_urls.dart';
import '../../../core/repositories/get_response.dart';
import '../../../core/repositories/post_response.dart';
import 'stock_models.dart';

/// Stock tools API — সব জবাব { status, message, data } আকারে আসে।
/// প্রতিটা কল `(ফল, ত্রুটির বার্তা)` ফেরত দেয়; ত্রুটি না থাকলে বার্তা null।
class StockRepo {
  const StockRepo();

  // ───────── helpers ─────────

  Future<(dynamic, String?)> _get(BuildContext context, String url, [Map<String, dynamic>? query]) async {
    try {
      final res = await getResponse(context: context, url: url, queryParams: query);
      final json = jsonDecode(res);
      if (json is Map && (json['status'] == true || json['success'] == true)) {
        return (json['data'], null);
      }
      return (null, _msg(json, 'Could not load data'));
    } catch (e) {
      return (null, 'Could not load data: $e');
    }
  }

  Future<(dynamic, String?)> _post(String url, [Map<String, dynamic>? payload]) async {
    try {
      final res = await postResponse(url: url, payload: payload ?? <String, dynamic>{});
      if (res['status'] == true) {
        final body = res['data'];
        final data = body is Map ? body['data'] : null;
        final message = body is Map && body['message'] != null ? '${body['message']}' : 'Done';
        return ((data: data, message: message), null);
      }
      return (null, _msg(res['data'], '${res['message'] ?? 'Request failed'}'));
    } catch (e) {
      return (null, 'Request failed: $e');
    }
  }

  String _msg(dynamic json, String fallback) =>
      json is Map && json['message'] != null ? '${json['message']}' : fallback;

  Map<String, dynamic> _map(dynamic v) => v is Map ? v.cast<String, dynamic>() : <String, dynamic>{};

  /// _post এর সফল ফল থেকে data ও message আলাদা করা
  (Map<String, dynamic>, String) _unpack(dynamic r) {
    final rec = r as ({dynamic data, String message});
    return (_map(rec.data), rec.message);
  }

  // ───────── products ─────────

  Future<(List<ProductHit>?, String?)> searchProducts(BuildContext context, String q) async {
    final (data, err) = await _get(context, AppUrls.product, {'search': q, 'is_active': 'true', 'page_size': '12'});
    if (err != null) return (null, err);
    final raw = data is Map ? data['results'] : (data is List ? data : null);
    final list = <ProductHit>[
      if (raw is List)
        for (final e in raw)
          if (e is Map) ProductHit.fromJson(e.cast<String, dynamic>()),
    ];
    return (list, null);
  }

  Future<(ProductHit?, String?)> productById(BuildContext context, int id) async {
    final (data, err) = await _get(context, '${AppUrls.product}$id/');
    if (err != null || data is! Map) return (null, err ?? 'Product not found');
    return (ProductHit.fromJson(data.cast<String, dynamic>()), null);
  }

  Future<(List<({int id, String name})>?, String?)> categories(BuildContext context) async {
    final (data, err) = await _get(context, AppUrls.category, {'no_pagination': 'true'});
    if (err != null) return (null, err);
    final raw = data is Map ? data['results'] : data;
    final out = <({int id, String name})>[
      if (raw is List)
        for (final e in raw)
          if (e is Map && e['id'] != null) (id: (e['id'] as num).toInt(), name: '${e['name'] ?? ''}'),
    ];
    return (out, null);
  }

  // ───────── stock adjustment ─────────

  Future<(AdjustmentPage?, String?)> adjustments(
    BuildContext context, {
    String q = '',
    String reason = '',
    int page = 1,
  }) async {
    final query = <String, dynamic>{'page': '$page', 'page_size': '30'};
    if (q.trim().isNotEmpty) query['q'] = q.trim();
    if (reason.isNotEmpty) query['reason'] = reason;
    final (data, err) = await _get(context, AppUrls.stockAdjustments, query);
    if (err != null) return (null, err);
    return (AdjustmentPage.fromJson(_map(data)), null);
  }

  /// newQty বা change — একটাই দিন
  Future<(String?, String?)> adjust(
    int productId, {
    int? newQty,
    int? change,
    required String reason,
    String note = '',
  }) async {
    final (r, err) = await _post(AppUrls.stockAdjustments, {
      'product_id': productId,
      if (newQty != null) 'new_qty': newQty,
      if (change != null) 'change': change,
      'reason': reason,
      'note': note,
    });
    if (err != null) return (null, err);
    return (_unpack(r).$2, null);
  }

  // ───────── stocktake ─────────

  Future<(List<StocktakeHead>?, String?)> counts(BuildContext context) async {
    final (data, err) = await _get(context, AppUrls.stockCounts);
    if (err != null) return (null, err);
    return ([
      if (data is List)
        for (final e in data)
          if (e is Map) StocktakeHead.fromJson(e.cast<String, dynamic>()),
    ], null);
  }

  Future<(StocktakeHead?, String?)> startCount({String title = '', int? categoryId, String note = ''}) async {
    final (r, err) = await _post(AppUrls.stockCounts, {
      'title': title,
      if (categoryId != null) 'category_id': categoryId,
      'note': note,
    });
    if (err != null) return (null, err);
    return (StocktakeHead.fromJson(_unpack(r).$1), null);
  }

  Future<(StocktakeDetail?, String?)> countDetail(BuildContext context, int id) async {
    final (data, err) = await _get(context, AppUrls.stockCount(id));
    if (err != null) return (null, err);
    return (StocktakeDetail.fromJson(_map(data)), null);
  }

  /// rows: [{line_id, counted_qty (null = গণনা মুছে ফেলা)}]
  Future<(StocktakeSummary?, String?)> saveCounts(int id, List<Map<String, dynamic>> rows) async {
    final (r, err) = await _post(AppUrls.stockCountSave(id), {'rows': rows});
    if (err != null) return (null, err);
    return (StocktakeSummary.fromJson(_unpack(r).$1), null);
  }

  Future<(String?, String?)> applyCount(int id) async {
    final (r, err) = await _post(AppUrls.stockCountApply(id));
    if (err != null) return (null, err);
    return (_unpack(r).$2, null);
  }

  Future<(String?, String?)> cancelCount(int id) async {
    final (r, err) = await _post(AppUrls.stockCountCancel(id));
    if (err != null) return (null, err);
    return (_unpack(r).$2, null);
  }

  // ───────── expiry ─────────

  Future<(ExpiryReport?, String?)> expiry(
    BuildContext context, {
    int days = 30,
    String status = 'alerts',
    int? limit,
  }) async {
    final (data, err) = await _get(context, AppUrls.expiryAlerts, {
      'days': '$days',
      'status': status,
      if (limit != null) 'limit': '$limit',
    });
    if (err != null) return (null, err);
    return (ExpiryReport.fromJson(_map(data)), null);
  }

  Future<(String?, String?)> writeOff(int batchId, {String reason = ''}) async {
    final (r, err) = await _post(AppUrls.expiryWriteOff(batchId), {'reason': reason});
    if (err != null) return (null, err);
    return (_unpack(r).$2, null);
  }

  // ───────── dashboard charts ─────────

  Future<(DashboardCharts?, String?)> charts(BuildContext context, {int months = 6, int days = 30}) async {
    final (data, err) = await _get(context, AppUrls.dashboardCharts, {'months': '$months', 'days': '$days'});
    if (err != null) return (null, err);
    return (DashboardCharts.fromJson(_map(data)), null);
  }
}
