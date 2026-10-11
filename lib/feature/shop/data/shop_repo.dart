import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../../core/configs/app_urls.dart';
import '../../../core/repositories/get_response.dart';
import '../../../core/repositories/patch_response.dart';
import '../../../core/repositories/post_response.dart';
import 'shop_models.dart';

/// Online Shop API — /api/shop/… (দেখা = sales.view, বদলানো = sales.edit)
/// পড়ার method (T?, String?) ফেরত দেয়; লেখার method error বার্তা ফেরত দেয় (null = সফল)।
class ShopRepo {
  const ShopRepo();

  static const statuses = ['pending', 'confirmed', 'delivered', 'cancelled', 'all'];

  Future<(ShopOrderPage?, String?)> orders(BuildContext context,
      {required String status, String q = '', int page = 1}) async {
    try {
      final d = await _get(context, AppUrls.shopOrders, {
        'status': status,
        if (q.trim().isNotEmpty) 'q': q.trim(),
        'page': '$page',
      });
      if (d.$1 == null) return (null, d.$2);
      final m = d.$1 as Map<String, dynamic>;
      final counts = <String, int>{};
      ((m['counts'] ?? {}) as Map).forEach((k, v) => counts['$k'] = (v as num?)?.toInt() ?? 0);
      return (
        ShopOrderPage(
          items: [
            for (final r in (m['results'] as List? ?? const []))
              if (r is Map) ShopOrder.fromJson(r.cast<String, dynamic>()),
          ],
          count: (m['count'] as num?)?.toInt() ?? 0,
          totalPages: (m['total_pages'] as num?)?.toInt() ?? 1,
          counts: counts,
          shopIsOpen: m['shop_is_open'] != false,
          canEdit: m['can_edit'] == true,
          shopUrl: '${m['shop_url'] ?? ''}',
        ),
        null,
      );
    } catch (e) {
      return (null, 'Could not load orders: $e');
    }
  }

  Future<(ShopOrder?, String?)> order(BuildContext context, int id) async {
    try {
      final d = await _get(context, AppUrls.shopOrderDetail(id), null);
      if (d.$1 == null) return (null, d.$2);
      return (ShopOrder.fromJson((d.$1 as Map).cast<String, dynamic>()), null);
    } catch (e) {
      return (null, 'Could not load the order: $e');
    }
  }

  /// action: confirm | deliver | cancel
  Future<String?> changeStatus(int id, String action, {bool cashReceived = false}) =>
      _write(postResponse(
        url: AppUrls.shopOrderStatus(id),
        payload: {'action': action, if (action == 'deliver') 'cash_received': cashReceived},
      ));

  Future<(ShopSettingsData?, String?)> settings(BuildContext context) async {
    try {
      final d = await _get(context, AppUrls.shopSettings, null);
      if (d.$1 == null) return (null, d.$2);
      return (ShopSettingsData((d.$1 as Map).cast<String, dynamic>()), null);
    } catch (e) {
      return (null, 'Could not load shop settings: $e');
    }
  }

  Future<String?> saveSettings(Map<String, dynamic> payload) =>
      _write(patchResponse(url: AppUrls.shopSettings, payload: payload));

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
