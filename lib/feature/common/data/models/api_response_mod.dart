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
    // 🔹 outer status
    final bool outerStatus = json['status'] == true;

    // 🔹 inner data object (if exists)
    final inner = json['data'];

    // 🔹 inner status (preferred if exists)
    final bool finalStatus =
    inner is Map && inner['status'] is bool
        ? inner['status']
        : outerStatus;

    return ApiResponse<T>(
      success: finalStatus,
      total: json['total'],
      title: json['title']?.toString(),
      message: (inner is Map && inner['message'] != null)
          ? inner['message'].toString()
          : json['message']?.toString(),
      data: (inner is Map && inner['data'] != null)
          ? fromJsonT(inner['data'])
          : null,
    );
  }
}
