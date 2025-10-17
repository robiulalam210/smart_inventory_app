import 'dart:convert';

import '../models/api_response_mod.dart';

ApiResponse<T> appParseJson<T>(String jsonString, Function fromJsonT) {
  try {
    final jsonData = json.decode(jsonString);

    // Log the parsed JSON data

    return ApiResponse.fromJson(jsonData, fromJsonT);
  } on FormatException catch (e) {
    return ApiResponse(success: false, message: "Invalid JSON format: $e", title: "JSON Decoding Error");
  } catch (e,s) {
    print(s);
    return ApiResponse(success: false, message: "Failed to parse JSON data: $e", title: "JSON Decoding Error");
  }
}
