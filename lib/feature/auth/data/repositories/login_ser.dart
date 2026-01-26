import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../../core/configs/app_constants.dart';
import '../../../../core/configs/app_urls.dart';
import '../models/login_mod.dart';

Future<LoginModel> loginService({required Map payload}) async {
  Uri url = Uri.parse(AppUrls.login);

  final headers = {"Content-Type": "application/json"};

  try {
    final response = await http
        .post(url, body: jsonEncode(payload), headers: headers)
        .timeout(const Duration(seconds: 120));

    logger.i("login url: $url");
    logger.i("login statusCode: ${response.statusCode}");
    logger.i("login response: ${response.body}");

    /// ✅ SUCCESS
    if (response.statusCode == 200) {
      final parsed = loginModelFromJson(response.body);

      if (parsed.tokens?.access != null &&
          parsed.tokens!.access!.isNotEmpty) {
        parsed.success = true;
        parsed.message = "Login successful";
      } else {
        parsed.success = false;
        parsed.message = "Invalid credentials";
      }
      return parsed;
    }

    /// ❌ UNAUTHORIZED (401)
    if (response.statusCode == 401) {
      final Map<String, dynamic> body = jsonDecode(response.body);

      return LoginModel(
        success: false,
        message: body['error'] ?? "Invalid username or password",
      );
    }

    /// ❌ OTHER ERRORS
    return LoginModel(
      success: false,
      message: "Server error (${response.statusCode})",
    );
  } on TimeoutException {
    return LoginModel(success: false, message: "Request timed out");
  } on SocketException catch (e) {
    logger.e("SocketException: $e");
    return LoginModel(success: false, message: "Cannot connect to server");
  }catch (e) {
    return LoginModel(success: false, message: "Unexpected error occurred");
  }
}
