import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../configs/app_constants.dart';
import '../database/login.dart';
import '../offline/offline_gateway.dart';
import '../offline/connectivity_monitor.dart';
import '../offline/uuid_v4.dart';

Future<Map<String, dynamic>> deleteResponse({
  required String url,
  bool retried = false,
}) async {
  Uri uriUrl = Uri.parse(url);
  // Offline এ edit/delete করা যায় না (conflict ও হিসাবের গরমিল এড়াতে)
  final gateway = OfflineGateway.instance;
  if (gateway.isOffline) return gateway.offlineBlocked();
  final opId = uuidV4();
  final token = await LocalDB.getLoginInfo();

  final Map<String, String> header = {
    "Content-Type": "application/json",
    'Authorization': 'Bearer ${token?['token']}',
  };
  header.addAll(await gateway.extraHeaders(opId: opId));

  logger.i("deleteResponse uriUrl: $uriUrl");

  try {
    final response = await http
        .delete(uriUrl, headers: header)
        .timeout(const Duration(seconds: 60));

    logger.i("deleteResponse statusCode: ${response.statusCode}");
    logger.i("deleteResponse body: ${response.body}");

    // Token expire (401) → নতুন token নিয়ে একবার আবার চেষ্টা (mobile + desktop)
    if (response.statusCode == 401 && !retried && await SessionKeeper.renew()) {
      return deleteResponse(url: url, retried: true);
    }

    // ✅ Handle 204 No Content response
    if (response.statusCode == 204) {
      return {
        "status": true,
        "title": "Deleted",
        "message": "Deleted successfully",
        "data": null
      };
    }

    // ✅ Handle empty response body
    if (response.body.isEmpty) {
      return {
        "status": false,
        "title": "Empty Response",
        "message": "Server returned empty response",
        "data": null
      };
    }

    // ✅ Parse JSON response
    final Map<String, dynamic> responseData = json.decode(response.body);
    return responseData;

  } on TimeoutException {
    return {
      "status": false,
      "title": "Timeout",
      "message": "The request timed out. Please try again later.",
      "data": null
    };
  } on SocketException {
    if (gateway.enabled) ConnectivityMonitor.instance.markOffline();
    return {
      "status": false,
      "title": "Connection Failed",
      "message": "Unable to connect to the server. Please check your network connection and try again.",
      "data": null
    };
  } catch (e) {
    logger.e("Delete request error: $e");
    return {
      "status": false,
      "title": "Failed",
      "message": "An error occurred while communicating with the server: $e",
      "data": null
    };
  }
}