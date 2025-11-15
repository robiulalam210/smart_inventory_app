// Update your ApiResponse class to handle the new structure
class ApiResponse<T> {
  bool? success;
  int? total;
  String? title;
  String? message;
  T? data;

  ApiResponse({this.success, this.title = "Failed", this.message, this.data, this.total});

  factory ApiResponse.fromJson(Map<String, dynamic> json, Function fromJsonT) {
    return ApiResponse(
      success: json['success'] ?? json['status'] ?? false,
      total: json['total'],
      title: json['title'],
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}