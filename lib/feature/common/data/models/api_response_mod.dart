// // Update your ApiResponse class to handle the new structure
// class ApiResponse<T> {
//   bool? success;
//   int? total;
//   String? title;
//   String? message;
//   T? data;
//
//   ApiResponse({this.success, this.title = "Failed", this.message, this.data, this.total});
//
//   factory ApiResponse.fromJson(Map<String, dynamic> json, Function fromJsonT) {
//     return ApiResponse(
//       success: json['success'] ?? json['status'] ?? false,
//       total: json['total'],
//       title: json['title'],
//       message: json['message'],
//       data: json['data'] != null ? fromJsonT(json['data']) : null,
//     );
//   }
// }
class ApiResponse<T> {
  final bool success;
  final int? total;
  final String? title;
  final String? message;
  final T? data;

  ApiResponse({
    required this.success,
    this.total,
    this.title,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic data) fromJsonT,
      ) {
    final dynamic inner = json['data'];

    /// ✅ STATUS PRIORITY LOGIC
    /// 1️⃣ outer `status`
    /// 2️⃣ inner `data.status`
    /// 3️⃣ default false
    final bool finalStatus =
    json['status'] is bool
        ? json['status'] as bool
        : (inner is Map && inner['status'] is bool
        ? inner['status'] as bool
        : false);

    return ApiResponse<T>(
      success: finalStatus,
      total: _parseInt(json['total']),
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      data: inner != null ? fromJsonT(inner) : null,
    );
  }

  /// 🔹 helper
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
