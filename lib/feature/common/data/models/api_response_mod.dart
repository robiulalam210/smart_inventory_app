
class ApiResponse<T> {
  bool? success;
  int? total;

  String? title;
  String? message;
  T? data;

  ApiResponse({this.success, this.title = "Failed", this.message, this.data, this.total});

  factory ApiResponse.fromJson(Map<String, dynamic> json, Function fromJsonT) {
    return ApiResponse(
      success: json['status'] ?? false, // 👈 fix: map 'status' to 'success'
      total: json['total'],
      title: json['title'],
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}