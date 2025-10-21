import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../configs/app_constants.dart';
import '../database/login.dart';
Future<String> deleteResponse({
  required String url,
}) async {
  Uri uriUrl = Uri.parse(url);
  final token = await LocalDB.getLoginInfo();

  final Map<String, String> header = {
    "Content-Type": "application/json",
    'Authorization': 'Bearer ${token?['token']}',
  };

  logger.i("deleteResponse uriUrl: $uriUrl");

  try {
    final response = await http
        .delete(uriUrl, headers: header)
        .timeout(const Duration(seconds: 60));

    logger.i("deleteResponse statusCode: ${response.statusCode}");
    logger.i("deleteResponse body: ${response.body}");

    // ✅ যদি statusCode 204 হয়, body খালি থাকে → valid JSON return করা
    if (response.statusCode == 204) {
      return '''
{
  "success": true,
  "title": "Deleted",
  "message": "Deleted successfully",
  "data": null
}
''';
    }

    return response.body.isEmpty
        ? '''
{
  "success": false,
  "title": "Empty Response",
  "message": "Server returned empty response",
  "data": null
}
'''
        : response.body;
  } on TimeoutException {
    return '''
{
   "success": false,
   "title": "Timeout",
   "message": "The request timed out. Please try again later.",
   "data": null
}
''';
  } on SocketException {
    return '''
{
   "success": false,
   "title": "Connection Failed",
   "message": "Unable to connect to the server. Please check your network connection and try again.",
   "data": null
}
''';
  } catch (e) {
    return '''
{
   "success": false,
   "title": "Failed",
   "message": "An error occurred while communicating with the server",
   "data": null
}
''';
  }
}
