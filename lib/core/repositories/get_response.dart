import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:meherinMart/feature/auth/presentation/pages/mobile_login_scr.dart';
import '/core/core.dart';

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
    logger.i("getResponse content-type: ${response.headers['content-type']}");

    // 401 Unauthorized -> force logout
    if (response.statusCode == 401) {
      await _handleTokenExpiration(context);
      return _buildErrorResponse("Unauthorized", "Your session has expired. Please log in again.");
    }

    // If server returned HTML or non-JSON (likely 500 HTML page)
    final contentType = response.headers['content-type'] ?? '';
    final isHtml = contentType.contains('text/html') || response.body.trimLeft().startsWith('<!DOCTYPE html>');

    // Try to parse JSON body (if any)
    dynamic bodyJson;
    try {
      bodyJson = json.decode(response.body);
    } catch (_) {
      bodyJson = null;
    }

    // Check for authentication errors using structured JSON or raw body
    final authError = _checkAuthenticationError(
      statusCode: response.statusCode,
      bodyJson: bodyJson,
      bodyText: response.body,
    );

    if (authError != null) {
      await _handleTokenExpiration(context);
      return _buildErrorResponse(authError.item1, authError.item2);
    }

    // If response is HTML (server error page), return server error without logging out
    if (isHtml) {
      return _buildErrorResponse("Server Error", "Internal Server Error. Please try again later.");
    }

    // For other non-2xx statuses, return a structured error (but don't log out)
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Try to extract server message
      String message = "An error occurred";
      if (bodyJson is Map && (bodyJson['message'] != null || bodyJson['detail'] != null)) {
        message = bodyJson['message']?.toString() ?? bodyJson['detail']?.toString() ?? message;
      } else if (response.body.isNotEmpty) {
        message = response.body;
      }
      return _buildErrorResponse("Failed (${response.statusCode})", message);
    }

    // Successful response
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

Tuple2<String, String>? _checkAuthenticationError({
  required int statusCode,
  dynamic bodyJson,
  required String bodyText,
}) {
  try {
    // If status is 401, already handled earlier, but be safe:
    if (statusCode == 401) {
      return Tuple2("Authentication Failed", "Your session has expired. Please log in again.");
    }

    // If bodyJson is Map, inspect common keys
    if (bodyJson is Map) {
      // Check specific keys that Django REST Framework or custom APIs use
      final candidates = <String?>[
        bodyJson['detail']?.toString(),
        bodyJson['message']?.toString(),
        bodyJson['error']?.toString(),
      ];

      // Some APIs put errors in arrays or nested structures. Flatten and join.
      if (bodyJson.containsKey('non_field_errors')) {
        final nfe = bodyJson['non_field_errors'];
        if (nfe is List && nfe.isNotEmpty) candidates.add(nfe.join(' '));
      }

      // Also check if keys themselves (like 'token_not_valid') are present
      if (bodyJson.containsKey('code') && bodyJson['code']?.toString().toLowerCase().contains('token') == true) {
        return Tuple2("Authentication Failed", "Your session has expired. Please log in again.");
      }

      // Inspect candidate messages for known token phrases
      for (final c in candidates) {
        if (c == null) continue;
        final lower = c.toLowerCase();
        if (lower.contains('token_not_valid') ||
            lower.contains('token is expired') ||
            lower.contains('token is invalid') ||
            lower.contains('token_expired') ||
            lower.contains('invalid_token') ||
            lower.contains('access_token_expired') ||
            lower.contains('authentication_failed') ||
            lower.contains('user_not_found') ||
            lower.contains('user not found')) {
          final title = lower.contains('user') ? "User Not Found" : "Authentication Failed";
          final msg = lower.contains('user') ? "Your account was not found. Please log in again." : "Your session has expired. Please log in again.";
          return Tuple2(title, msg);
        }
      }
    }

    // Fallback: check raw body text for token phrases (older non-JSON responses)
    final lowerBody = bodyText.toLowerCase();
    if (lowerBody.contains('token_not_valid') ||
        lowerBody.contains('token is expired') ||
        lowerBody.contains('token_expired') ||
        lowerBody.contains('invalid_token') ||
        lowerBody.contains('access_token_expired') ||
        lowerBody.contains('authentication_failed')) {
      return Tuple2("Authentication Failed", "Your session has expired. Please log in again.");
    }
    if (lowerBody.contains('user_not_found') || lowerBody.contains('user not found')) {
      return Tuple2("User Not Found", "Your account was not found. Please log in again.");
    }
  } catch (e) {
    // ignore parsing errors
    logger.w("_checkAuthenticationError parse error: $e");
  }
  return null;
}

Future<void> _handleTokenExpiration(BuildContext context) async {
  await LocalDB.delLoginInfo();
  final isMobile = Responsive.isMobile(context);

  // Use a post-frame callback to ensure the context is still valid
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) {
      showCustomToast(
        context: context,
        title: 'Success!',
        description: 'Your session has expired. Please log in again.',
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );
      if (isMobile) {
        AppRoutes.pushAndRemoveUntil(context, const MobileLoginScr());
      } else {
        AppRoutes.pushAndRemoveUntil(context, const LogInScreen());
      }
    }
  });
}

String _buildErrorResponse(String title, String message) {
  final map = {
    "success": false,
    "title": title,
    "message": message,
    "data": null,
  };
  return json.encode(map);
}

/// Small tuple helper (since Dart doesn't have built-in pair type)
class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;
  Tuple2(this.item1, this.item2);
}