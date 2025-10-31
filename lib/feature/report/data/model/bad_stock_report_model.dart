// To parse this JSON data, do
//
//     final badStockReportModel = badStockReportModelFromJson(jsonString);

import 'dart:convert';

BadStockReportModel badStockReportModelFromJson(String str) => BadStockReportModel.fromJson(json.decode(str));

String badStockReportModelToJson(BadStockReportModel data) => json.encode(data.toJson());

class BadStockReportModel {
  final bool? success;
  final List<BadStockReportList>? data;
  final Summary? summary;

  BadStockReportModel({
    this.success,
    this.data,
    this.summary,
  });

  factory BadStockReportModel.fromJson(Map<String, dynamic> json) => BadStockReportModel(
    success: json["success"],
    data: json["data"] == null ? [] : List<BadStockReportList>.from(json["data"]!.map((x) => BadStockReportList.fromJson(x))),
    summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "summary": summary?.toJson(),
  };
}

class BadStockReportList {
  final String? productName;
  final int? productId;
  final DateTime? badStockDate;
  final String? totalAmount;
  final String? totalQuantity;

  BadStockReportList({
    this.productName,
    this.productId,
    this.badStockDate,
    this.totalAmount,
    this.totalQuantity,
  });

  factory BadStockReportList.fromJson(Map<String, dynamic> json) => BadStockReportList(
    productName: json["product_name"],
    productId: json["product_id"],
    badStockDate: json["bad_stock_date"] == null ? null : DateTime.parse(json["bad_stock_date"]),
    totalAmount: json["total_amount"],
    totalQuantity: json["total_quantity"],
  );

  Map<String, dynamic> toJson() => {
    "product_name": productName,
    "product_id": productId,
    "bad_stock_date": "${badStockDate!.year.toString().padLeft(4, '0')}-${badStockDate!.month.toString().padLeft(2, '0')}-${badStockDate!.day.toString().padLeft(2, '0')}",
    "total_amount": totalAmount,
    "total_quantity": totalQuantity,
  };
}

class Summary {
  final String? totalQuantity;
  final String? totalAmount;

  Summary({
    this.totalQuantity,
    this.totalAmount,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    totalQuantity: json["total_quantity"],
    totalAmount: json["total_amount"],
  );

  Map<String, dynamic> toJson() => {
    "total_quantity": totalQuantity,
    "total_amount": totalAmount,
  };
}
