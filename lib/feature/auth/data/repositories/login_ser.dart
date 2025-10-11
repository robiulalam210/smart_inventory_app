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

  final Map<String, String> header = {
    "Content-Type": "application/json",
  };

  try {
    final response =
        await http.post(url, body: jsonEncode(payload), headers: header);
    logger.i("login response: ${response.body}");

    final parsed = loginModelFromJson(response.body);

    // You can determine success by checking for access_token or status/message
    if (parsed.accessToken != null && parsed.accessToken!.isNotEmpty) {
      parsed.success = true;
    } else {
      parsed.success = false;
    }

    return parsed;
  } on TimeoutException catch (e) {
    logger.e("TimeoutException in loginService: $e");
    return LoginModel(success: false, message: "Request timed out");
  } on SocketException catch (e) {
    logger.e("SocketException in loginService: $e");
    return LoginModel(success: false, message: "No Internet connection");
  } catch (e) {
    logger.e("Exception in loginService: $e");
    return LoginModel(success: false, message: "Unexpected error");
  }
}
