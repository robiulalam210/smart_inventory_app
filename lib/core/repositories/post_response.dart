import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:developer'as d;
import '../configs/app_constants.dart';
import '../database/login.dart';

Future<String> postResponse({
  required String url,
  Map<String, dynamic>? payload,
}) async {


  Uri uriUrl = Uri.parse(url);
  logger.i("Uri : $uriUrl");
  final token = await LocalDB.getLoginInfo();

  final Map<String, String> header = {
    "Accept": "application/json",
    "Content-Type": "application/json",
    'Authorization': 'Bearer ${token?['token']}',
    "branch-id": " ${token?['branchId']}",
    "branch-name": " ${token?['branchName']}",
    "bs-type": " ${token?['bsType']}",
    "user-id": " ${token?['userId']}",
    "is-super-admin": "false",
  };


  logger.i("header : $header");
  logger.i("payload : $payload");
  d.log(jsonEncode(payload));
  try {
    final response = await http
        .post(uriUrl,
            body: jsonEncode(payload), headers: header)
        .timeout(const Duration(seconds: 30));
    logger.i("postResponse body: ${response.body}");
    logger.i("postResponse statusCode: ${response.statusCode}");

    return response.body;
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
    logger.e("postResponse e: $e");
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
