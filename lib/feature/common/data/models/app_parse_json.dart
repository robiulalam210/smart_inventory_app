import 'dart:convert';

import '../models/api_response_mod.dart';
ApiResponse<T> appParseJson<T>(
    String jsonString,
    T Function(dynamic data) fromJsonT,
    ) {
  try {
    final dynamic decoded = json.decode(jsonString);

    if (decoded is! Map<String, dynamic>) {
      return ApiResponse<T>(
        success: false,
        title: "Invalid Response",
        message:
        "Expected JSON object but got ${decoded.runtimeType}",
      );
    }

    return ApiResponse<T>.fromJson(decoded, fromJsonT);
  } on FormatException catch (e) {
    return ApiResponse<T>(
      success: false,
      title: "JSON Decoding Error",
      message: e.message,
    );
  } catch (e) {
    return ApiResponse<T>(
      success: false,
      title: "JSON Parsing Error",
      message: e.toString(),
    );
  }
}
