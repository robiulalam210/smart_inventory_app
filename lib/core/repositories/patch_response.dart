import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../configs/app_constants.dart';
import '../database/login.dart';

Future<Map<String, dynamic>> patchResponse({
  required String url,
  required Map<String, dynamic> payload,
}) async {
  Uri uriUrl = Uri.parse(url);
  final token = await LocalDB.getLoginInfo();
  logger.i("patchResponse uriUrl: $uriUrl");

  final Map<String, String> header = {
    "Content-Type": "application/json",
    'Authorization': 'Bearer ${token?['token']}',
  };

  try {
    final response = await http
        .patch(uriUrl, body: jsonEncode(payload), headers: header)
        .timeout(const Duration(seconds: 60));

    logger.i("patchResponse statusCode: ${response.statusCode}");
    logger.i("patchResponse body: ${response.body}");

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    // Handle both response formats
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Check if it's a raw Django response (has 'id' field but no 'success' field)
      if (responseData.containsKey('id') && !responseData.containsKey('success')) {
        // Convert raw Django response to structured format
        return {
          "success": true,
          "message": "Updated successfully",
          "data": responseData
        };
      }
      // It's already a structured response
      return responseData;
    } else {
      // Error response
      return {
        "success": false,
        "message": responseData['message'] ?? "Update failed",
        "data": null
      };
    }

  } on TimeoutException {
    return {
      "success": false,
      "title": "Timeout",
      "message": "The request timed out. Please try again later.",
      "data": null
    };
  } on SocketException {
    return {
      "success": false,
      "title": "Connection Failed",
      "message": "Unable to connect to the server. Please check your network connection and try again.",
      "data": null
    };
  } catch (e) {
    return {
      "success": false,
      "title": "Failed",
      "message": "An error occurred while communicating with the server: $e",
      "data": null
    };
  }
}