// name=lib/core/services/image_upload_service.dart
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class ImageUploadService {
  final Dio _dio;

  ImageUploadService({Dio? dio}) : _dio = dio ?? Dio() {
    // default config
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
  }

  void configureBadCertForDev() {
    try {
      final adapter = _dio.httpClientAdapter;
      if (adapter is DefaultHttpClientAdapter) {
        adapter.onHttpClientCreate = (client) {
          client.badCertificateCallback = (cert, host, port) => false;
          return client;
        };
      }
    } catch (_) {}
  }

  Future<Response?> uploadWithPatchFallback({
    required String url,
    required String token,
    required FormData formData,
    required void Function(int sent, int total) onProgress,
    Options? options,
  }) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    try {
      final response = await _dio.patch(
        url,
        data: formData,
        onSendProgress: onProgress,
        options: options ?? Options(validateStatus: (s) => s != null && s < 500),
      );

      if (response.statusCode == 404) {
        final postResponse = await _dio.post(
          url,
          data: formData,
          onSendProgress: onProgress,
          options: options ?? Options(validateStatus: (s) => s != null && s < 500),
        );
        return postResponse;
      }
      return response;
    } on DioError {
      rethrow;
    }
  }
}