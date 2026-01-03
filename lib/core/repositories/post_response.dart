import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as d;
import '../configs/app_constants.dart';
import '../database/login.dart';

Future<Map<String, dynamic>> postResponse({
  required String url,
  Map<String, dynamic>? payload,
}) async {
  Uri uriUrl = Uri.parse(url);
  logger.i("Uri : $uriUrl");
  final token = await LocalDB.getLoginInfo();

  if (kDebugMode) {
    print(uriUrl);
  }

  final Map<String, String> header = {
    "Content-Type": "application/json",
    'Authorization': 'Bearer ${token?['token']}',
  };

  logger.i("header : $header");
  logger.i("payload : $payload");
  d.log(jsonEncode(payload));

  try {
    final response = await http
        .post(uriUrl, body: jsonEncode(payload), headers: header)
        .timeout(const Duration(seconds: 90));

    logger.i("postResponse body: ${response.body}");
    logger.i("postResponse statusCode: ${response.statusCode}");

    // Parse the JSON response
    final Map<String, dynamic> responseData = jsonDecode(response.body);

    // Check if status code indicates success (200-299)
    if (response.statusCode >= 201 && response.statusCode < 300) {
      return {
        "status": true,
        "statusCode": response.statusCode,
        "data": responseData,
        "message": "Request successful"
      };
    } else {
      // Server returned error status code
      return {
        "status": false,
        "statusCode": response.statusCode,
        "data": responseData,
        "message": responseData['message'] ?? "Request failed",
        "title": responseData['title'] ?? "Error"
      };
    }

  } on TimeoutException {
    return {
      "status": false,
      "statusCode": 408,
      "title": "Timeout",
      "message": "The request timed out. Please try again later.",
      "data": null
    };
  } on SocketException {
    return {
      "status": false,
      "statusCode": 503,
      "title": "Connection Failed",
      "message": "Unable to connect to the server. Please check your network connection and try again.",
      "data": null
    };
  } catch (e) {

    logger.e("postResponse e: $e");
    return {
      "status": false,
      "statusCode": 500,
      "title": "Failed",
      "message": "An error occurred while communicating with the server",
      "data": null
    };
  }
}