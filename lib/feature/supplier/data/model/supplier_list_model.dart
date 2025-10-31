// To parse this JSON data, do
//
//     final supplierListModel = supplierListModelFromJson(jsonString);

import 'dart:convert';

List<SupplierListModel> supplierListModelFromJson(String str) => List<SupplierListModel>.from(json.decode(str).map((x) => SupplierListModel.fromJson(x)));

String supplierListModelToJson(List<SupplierListModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SupplierListModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final bool? isActive;
  final String? supplierNo;
  final String? totalDue;
  final String? totalPaid;
  final String? totalPurchases;
  final int? purchaseCount;
  final String? amountType;
  final int? company;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SupplierListModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.isActive,
    this.supplierNo,
    this.totalDue,
    this.totalPaid,
    this.totalPurchases,
    this.purchaseCount,
    this.amountType,
    this.company,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory SupplierListModel.fromJson(Map<String, dynamic> json) => SupplierListModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    address: json["address"],
    isActive: json["is_active"],
    supplierNo: json["supplier_no"],
    totalDue: json["total_due"],
    totalPaid: json["total_paid"],
    totalPurchases: json["total_purchases"],
    purchaseCount: json["purchase_count"],
    amountType: json["amount_type"],
    company: json["company"],
    createdBy: json["created_by"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "address": address,
    "is_active": isActive,
    "supplier_no": supplierNo,
    "total_due": totalDue,
    "total_paid": totalPaid,
    "total_purchases": totalPurchases,
    "purchase_count": purchaseCount,
    "amount_type": amountType,
    "company": company,
    "created_by": createdBy,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
