// To parse this JSON data, do
//
//     final badStockReturnModel = badStockReturnModelFromJson(jsonString);

import 'dart:convert';

List<BadStockReturnModel> badStockReturnModelFromJson(String str) => List<BadStockReturnModel>.from(json.decode(str).map((x) => BadStockReturnModel.fromJson(x)));

String badStockReturnModelToJson(List<BadStockReturnModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BadStockReturnModel {
  final int? id;
  final int? product;
  final String? productName;
  final int? quantity;
  final int? companyId;
  final String? reason;
  final DateTime? date;
  final String? referenceType;
  final int? referenceId;

  BadStockReturnModel({
    this.id,
    this.product,
    this.productName,
    this.quantity,
    this.companyId,
    this.reason,
    this.date,
    this.referenceType,
    this.referenceId,
  });

  factory BadStockReturnModel.fromJson(Map<String, dynamic> json) => BadStockReturnModel(
    id: json["id"],
    product: json["product"],
    productName: json["product_name"],
    quantity: json["quantity"],
    companyId: json["company_id"],
    reason: json["reason"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    referenceType: json["reference_type"],
    referenceId: json["reference_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product": product,
    "product_name": productName,
    "quantity": quantity,
    "company_id": companyId,
    "reason": reason,
    "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "reference_type": referenceType,
    "reference_id": referenceId,
  };
}
