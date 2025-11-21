import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:meherin_mart/core/core.dart';

import '../../feature/auth/presentation/pages/login_scr.dart';

Future<String> getResponse({
  required BuildContext context,
  required String url,
  Map<String, dynamic>? queryParams,
}) async {
  // Build URI with query parameters
  Uri uriUrl;
  if (queryParams != null && queryParams.isNotEmpty) {
    uriUrl = Uri.parse(url).replace(queryParameters: queryParams);
  } else {
    uriUrl = Uri.parse(url);
  }

  final token = await LocalDB.getLoginInfo();
  if (kDebugMode) {
    print(uriUrl);
  }

  final Map<String, String> header = {
    "Content-Type": "application/json",
    'Authorization': 'Bearer ${token?['token']}',
  };
  logger.i("getResponse header: $header");

  try {
    final response = await http
        .get(uriUrl, headers: header)
        .timeout(const Duration(seconds: 80));

    logger.i("getResponse statusCode: ${response.statusCode}");
    logger.i("getResponse body: ${response.body}");

    // Check for 401 Unauthorized error
    if (response.statusCode == 401) {
      await _handleTokenExpiration(context);
      return _buildErrorResponse("Unauthorized", "Your session has expired. Please log in again.");
    }

    // Check response body for authentication errors (even if status code is 200)
    final authError = _checkAuthenticationError(response.body);
    if (authError != null) {
      await _handleTokenExpiration(context);
      return _buildErrorResponse(authError.$1, authError.$2);
    }

    return response.body;
  } on TimeoutException {
    return _buildErrorResponse("Timeout", "The request timed out. Please try again later.");
  } on SocketException {
    return _buildErrorResponse("Connection Failed", "Unable to connect to the server. Please check your network connection and try again.");
  } catch (e) {
    logger.e("getResponse error: $e");
    return _buildErrorResponse("Failed", "An error occurred while communicating with the server");
  }
}

(String, String)? _checkAuthenticationError(String responseBody) {
  try {
    // Check for various authentication errors
    if (responseBody.contains('token_not_valid') ||
        responseBody.contains('token is expired') ||
        responseBody.contains('Token is expired') ||
        responseBody.contains('token_expired') ||
        responseBody.contains('invalid_token') ||
        responseBody.contains('access_token_expired') ||
        responseBody.contains('authentication_failed')) {
      return ("Authentication Failed", "Your session has expired. Please log in again.");
    }

    // Check for user not found specifically
    if (responseBody.contains('user_not_found') ||
        responseBody.contains('User not found')) {
      return ("User Not Found", "Your account was not found. Please log in again.");
    }

    return null;
  } catch (e) {
    return null;
  }
}

Future<void> _handleTokenExpiration(BuildContext context) async {
  await LocalDB.delLoginInfo();

  // Use a post-frame callback to ensure the context is still valid
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) {
      AppRoutes.pushAndRemoveUntil(context, const LogInScreen());
      showCustomToast(
        context: context,
        title: 'Success!',
        description: 'Your session has expired. Please log in again.',
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );
    }
  });
}

String _buildErrorResponse(String title, String message) {
  return '''
  {
     "success": false,
     "title": "$title",
     "message": "$message",
     "data": null
  }
  ''';
}