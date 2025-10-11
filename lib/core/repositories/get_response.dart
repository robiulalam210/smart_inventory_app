import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../configs/configs.dart';

Future<String> getResponse({
  required BuildContext context,
  required String url,
}) async {
  Uri uriUrl = Uri.parse(url);
  final token = await LocalDB.getLoginInfo();
  if (kDebugMode) {
    print(uriUrl);
  }

  final Map<String, String> header = {
    "Content-Type": "application/json",
    'Authorization': 'Bearer ${token?['token']}',
    "branch-id": " ${token?['branchId']}",
    "branch-name": " ${token?['branchName']}",
    "bs-type": "${token?['bsType']}",
    "user-id": "${token?['userId']}",
    "is-super-admin": "false",
  };
  logger.i("getResponse header: $header");

  try {
    final response = await http
        .get(uriUrl, headers: header)
        .timeout(const Duration(seconds: 50));

    // logger.i("getResponse body: ${response.body}");
    logger.i("getResponse statusCode: ${response.statusCode}");

    // Check for 401 Unauthorized error
    if (response.statusCode == 401) {
      // Log out the user and redirect to login screen
      await LocalDB
          .delLoginInfo(); // Assuming a method to clear stored login info
      // Redirect to login screen
      // AppRoutes.pushAndRemoveUntil(context, const LogInScreen());
      return '''
      {
         "success": false,
         "title": "Unauthorized",
         "message": "Your session has expired. Please log in again.",
         "data": null
      }
      ''';
    }

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
