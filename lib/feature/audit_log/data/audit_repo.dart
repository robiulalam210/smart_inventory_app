import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../../core/configs/app_urls.dart';
import '../../../core/repositories/get_response.dart';
import 'audit_models.dart';

class AuditPage {
  final List<AuditEntry> items;
  final int count;
  final int page;
  final int totalPages;

  const AuditPage(this.items, this.count, this.page, this.totalPages);

  bool get hasMore => page < totalPages;
}

/// Audit log API — GET /api/sync/audit/ আর /api/sync/audit/meta/
class AuditRepo {
  const AuditRepo();

  /// বর্তমান filter পাঠানো হয় — server প্রতিটা dropdown এর বিকল্প বাকি filter মেনে গোনে
  Future<(AuditMeta?, String?)> meta(BuildContext context, AuditFilter filter) async {
    try {
      final query = filter.toQuery(page: 1)
        ..remove('page')
        ..remove('page_size');
      final res = await getResponse(
        context: context,
        url: AppUrls.auditMeta,
        queryParams: query,
      );
      final json = jsonDecode(res);
      if (json is Map && json['status'] == true && json['data'] is Map) {
        return (AuditMeta.fromJson((json['data'] as Map).cast<String, dynamic>()), null);
      }
      return (null, _message(json, 'Could not load audit summary'));
    } catch (e) {
      return (null, 'Could not load audit summary: $e');
    }
  }

  Future<(AuditPage?, String?)> list(BuildContext context, AuditFilter filter, {int page = 1}) async {
    try {
      final res = await getResponse(
        context: context,
        url: AppUrls.auditLog,
        queryParams: filter.toQuery(page: page),
      );
      final json = jsonDecode(res);
      if (json is Map && json['status'] == true && json['data'] is Map) {
        final d = (json['data'] as Map).cast<String, dynamic>();
        final items = [
          for (final r in (d['results'] as List? ?? const []))
            if (r is Map) AuditEntry.fromJson(r.cast<String, dynamic>()),
        ];
        return (
          AuditPage(
            items,
            (d['count'] as num?)?.toInt() ?? items.length,
            (d['current_page'] as num?)?.toInt() ?? page,
            (d['total_pages'] as num?)?.toInt() ?? page,
          ),
          null,
        );
      }
      return (null, _message(json, 'Could not load audit log'));
    } catch (e) {
      return (null, 'Could not load audit log: $e');
    }
  }

  String _message(dynamic json, String fallback) =>
      json is Map && json['message'] != null ? '${json['message']}' : fallback;
}
