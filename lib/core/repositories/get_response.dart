// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
//
// import '../../feature/auth/presentation/pages/login_scr.dart';
// import '../configs/configs.dart';
// Future<String> getResponse({
//   required BuildContext context,
//   required String url,
//   Map<String, dynamic>? queryParams, // Add this parameter
// }) async {
//   // Build URI with query parameters
//   Uri uriUrl;
//   if (queryParams != null && queryParams.isNotEmpty) {
//     uriUrl = Uri.parse(url).replace(queryParameters: queryParams);
//   } else {
//     uriUrl = Uri.parse(url);
//   }
//
//   final token = await LocalDB.getLoginInfo();
//   if (kDebugMode) {
//     print(uriUrl);
//   }
//
//   final Map<String, String> header = {
//     "Content-Type": "application/json",
//     'Authorization': 'Bearer ${token?['token']}',
//   };
//   logger.i("getResponse header: $header");
//
//   try {
//     final response = await http
//         .get(uriUrl, headers: header)
//         .timeout(const Duration(seconds: 80));
//
//     logger.i("getResponse statusCode: ${response.statusCode}");
//     logger.i("getResponse body: ${response.body}");
//
//     // Check for 401 Unauthorized error
//     if (response.statusCode == 401) {
//       await LocalDB.delLoginInfo();
//       AppRoutes.pushAndRemoveUntil(context, const LogInScreen());
//       return '''
//       {
//          "success": false,
//          "title": "Unauthorized",
//          "message": "Your session has expired. Please log in again.",
//          "data": null
//       }
//       ''';
//     }
//
//     return response.body;
//   } on TimeoutException {
//     return '''
//     {
//        "success": false,
//        "title": "Timeout",
//        "message": "The request timed out. Please try again later.",
//        "data": null
//     }
//     ''';
//   } on SocketException {
//     return '''
//     {
//        "success": false,
//        "title": "Connection Failed",
//        "message": "Unable to connect to the server. Please check your network connection and try again.",
//        "data": null
//     }
//     ''';
//   } catch (e) {
//     return '''
//     {
//        "success": false,
//        "title": "Failed",
//        "message": "An error occurred while communicating with the server",
//        "data": null
//     }
//     ''';
//   }
// }


import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:smart_inventory/core/core.dart';

import '../../feature/auth/presentation/pages/login_scr.dart';
import '../configs/configs.dart';

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

    // Check response body for token expiration errors (even if status code is 200)
    if (_isTokenExpired(response.body)) {
      await _handleTokenExpiration(context);
      return _buildErrorResponse("Token Expired", "Your session has expired. Please log in again.");
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

bool _isTokenExpired(String responseBody) {
  try {
    // Check for common token expiration patterns in the response
    return responseBody.contains('token_not_valid') ||
        responseBody.contains('token is expired') ||
        responseBody.contains('Token is expired') ||
        responseBody.contains('token_expired') ||
        responseBody.contains('invalid_token') ||
        responseBody.contains('access_token_expired');
  } catch (e) {
    return false;
  }
}

Future<void> _handleTokenExpiration(BuildContext context) async {
  await LocalDB.delLoginInfo();

  // Use a post-frame callback to ensure the context is still valid
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted) {
      AppRoutes.pushAndRemoveUntil(context, const LogInScreen());

     appSnackBar(context, 'Your session has expired. Please log in again.');
      // Show a snackbar to inform the user
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: const Text(),
      //     backgroundColor: Colors.red,
      //     duration: const Duration(seconds: 5),
      //     action: SnackBarAction(
      //       label: 'OK',
      //       textColor: Colors.white,
      //       onPressed: () {
      //         ScaffoldMessenger.of(context).hideCurrentSnackBar();
      //       },
      //     ),
      //   ),
      // );
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