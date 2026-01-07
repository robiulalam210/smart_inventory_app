import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:meherinMart/feature/auth/presentation/pages/mobile_login_scr.dart';

import '../../../../core/configs/app_routes.dart';
import '../../../../core/configs/app_urls.dart';
import '../models/version_response_model.dart';
abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class AppExceptionMessage{
  static const String timeout = "The request timed out. Please try again later";
  static const String socket = "Unable to connect to the server. Please check your network connection and try again";
  static const String serverDefault = "Something went wrong";
  static const String format = "Data format is incorrect.";
  static const String type = "Type mismatch occurred.";
  static const String unknown = "An unknown error occurred.";
  static const String empty = "No data available at the moment. Please try again later.";
}
Failure handleException(dynamic e, StackTrace stackTrace) {
  if (kDebugMode) {
    log("_____________________Error____________________", error: e, stackTrace: stackTrace);
  }

  if (e is FormatException) {
    return ApiFailure(AppExceptionMessage.format);
  } else if (e is TypeError) {
    return ApiFailure(AppExceptionMessage.type);
  } else if (e is TimeoutException) {
    return ApiFailure(AppExceptionMessage.timeout);
  } else if (e is SocketException) {
    return ApiFailure(AppExceptionMessage.socket);
  } else if (e is ServerException) {
    return ApiFailure(e.message);
  } else {
    return ApiFailure(AppExceptionMessage.unknown);
  }
}
class ApiFailure extends Failure {
  ApiFailure(super.message);
}
class ApiClient {

  static Future<dynamic> getVersion({
    required String url,
    required dynamic context,
  }) async {

    final response = await http.get(
      Uri.parse(url),
// headers: headers,
    );

    if (response.statusCode == 500) {
// await AuthLocalDB.clear();


      AppRoutes.pushAndRemoveUntil(context, MobileLoginScr());
// cc.read<AuthBloc>().add(
//   LogoutRequested(),
// );
      throw ServerException("Session expired. Please login again.");
    }
// logger.i("getResponse body: ${response.body}");
    return _handleResponseGet(response, context);
  }
  static dynamic _handleResponseGet(http.Response response,
      BuildContext cc,) async {

    // 🔴 Handle 500 FIRST
    if (response.statusCode == 500) {
      // AuthLocalDB.clear();
      AppRoutes.pushAndRemoveUntil(
        cc,
        MobileLoginScr(),

      );
      throw ServerException("Server error. Please login again.");
    }

    dynamic data;

    // ✅ Decode JSON safely
    try {
      data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (e) {
      throw ServerException("Invalid server response");
    }

    // ✅ Success
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      return data;
    }

    // 🔐 Token invalid
    if (response.statusCode == 400 &&
        data is Map &&
        data["message"] == "Token is not valid") {
      throw ServerException("Session expired. Please login again.");
    }

    throw ServerException(
      data is Map ? data["message"] ?? "Server error" : "Server error",
    );
  }
}




class VersionRemoteDataSource {
  static Future<Either<Failure, VersionResponseModel>> getVersion(BuildContext context) async {
    try {
      final response = await ApiClient.getVersion(url: AppUrls.versionUrl,context: context);
      final result = versionResponseModelFromJson(jsonEncode(response));
      return Right(result);
    } catch (e, stackTrace) {
      return Left(handleException(e, stackTrace));
    }
  } 
}