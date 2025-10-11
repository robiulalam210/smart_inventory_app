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
    "branch-id": " ${token?['branchId']}",
    "branch-name": "${token?['branchName']}",
    "bs-type": " ${token?['bsType']}",
    "user-id": " ${token?['userId']}",
    "is-super-admin": "false",  };
  try {
    final response = await http
        .delete(uriUrl, headers: header)
        .timeout(const Duration(seconds: 15));
    logger.i("deleteResponse body: ${response.body}");
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