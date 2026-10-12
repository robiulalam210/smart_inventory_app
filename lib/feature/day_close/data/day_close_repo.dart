import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../../core/configs/app_urls.dart';
import '../../../core/repositories/delete_response.dart';
import '../../../core/repositories/get_response.dart';
import '../../../core/repositories/post_response.dart';

double dcNum(dynamic v) => v is num ? v.toDouble() : (double.tryParse('${v ?? ''}') ?? 0);

Map<String, dynamic> dcMap(dynamic v) => v is Map ? v.cast<String, dynamic>() : <String, dynamic>{};

List<Map<String, dynamic>> dcList(dynamic v) =>
    v is List ? v.map((e) => dcMap(e)).toList() : <Map<String, dynamic>>[];

/// Day Close API — প্রতিটা কল `(ফল, ত্রুটির বার্তা)`; ত্রুটি না থাকলে বার্তা null।
class DayCloseRepo {
  const DayCloseRepo();

  String _msg(dynamic json, String fallback) =>
      json is Map && json['message'] != null ? '${json['message']}' : fallback;

  /// ওই দিনের সারাংশ: { summary, closed, can_close, can_reopen }
  Future<(Map<String, dynamic>?, String?)> summary(BuildContext context, String date) async {
    try {
      final res = await getResponse(context: context, url: AppUrls.dayCloseSummary, queryParams: {'date': date});
      final json = jsonDecode(res);
      if (json is Map && json['status'] == true) return (dcMap(json['data']), null);
      return (null, _msg(json, 'Could not load this day'));
    } catch (e) {
      return (null, 'Could not load this day: $e');
    }
  }

  Future<(List<Map<String, dynamic>>?, String?)> history(BuildContext context) async {
    try {
      final res = await getResponse(context: context, url: AppUrls.dayClose, queryParams: {'page_size': '14'});
      final json = jsonDecode(res);
      if (json is Map && json['status'] == true) return (dcList(dcMap(json['data'])['results']), null);
      return (null, _msg(json, 'Could not load history'));
    } catch (e) {
      return (null, 'Could not load history: $e');
    }
  }

  Future<String?> close(String date, Map<String, double> counts, String note) async {
    try {
      final res = await postResponse(url: AppUrls.dayClose, payload: {
        'date': date,
        'counts': counts.map((k, v) => MapEntry(k, v)),
        'note': note,
      });
      if (res['status'] == true) return null;
      final body = res['data'];
      return _msg(body, '${res['message'] ?? 'Could not close the day'}');
    } catch (e) {
      return 'Could not close the day: $e';
    }
  }

  Future<String?> reopen(int id) async {
    try {
      final res = await deleteResponse(url: AppUrls.dayCloseDetail(id));
      if (res['status'] == true) return null;
      return '${res['message'] ?? 'Could not reopen the day'}';
    } catch (e) {
      return 'Could not reopen the day: $e';
    }
  }
}
