import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../../core/configs/app_constants.dart';
import '../../../../core/configs/app_urls.dart';
import '../models/login_mod.dart';

Future<LoginModel> loginService({required Map payload}) async {
  logger.f("call loginService");
  Uri url = Uri.parse(AppUrls.login);
  logger.f("url $url");
  logger.f("payload $payload");

  final headers = {"Content-Type": "application/json"};

  try {
    final response = await http
        .post(url, body: jsonEncode(payload), headers: headers)
        .timeout(const Duration(seconds: 120));

    logger.i("login response: ${response.body}");

    if (response.statusCode == 200) {
      final parsed = loginModelFromJson(response.body);

      // Determine success by token availability
      if (parsed.tokens?.access != null &&
          parsed.tokens!.access!.isNotEmpty) {
        parsed.success = true;
        parsed.message = "Login successful";
      } else {
        parsed.success = false;
        parsed.message = "Invalid credentials or missing token";
      }

      return parsed;
    } else {
      return LoginModel(
        success: false,
        message: "Server error: ${response.statusCode}",
      );
    }
  } on TimeoutException catch (e) {
    logger.e("TimeoutException in loginService: $e");
    return LoginModel(success: false, message: "Request timed out");
  } on SocketException catch (e) {
    logger.e("SocketException in loginService: $e");
    return LoginModel(success: false, message: "No internet connection");
  } catch (e) {
    logger.e("Exception in loginService: $e");
    return LoginModel(success: false, message: "Unexpected error occurred");
  }
}
