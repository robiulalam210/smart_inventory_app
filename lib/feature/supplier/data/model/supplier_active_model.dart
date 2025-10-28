
// To parse this JSON data, do
//
//     final supplierActiveModel = supplierActiveModelFromJson(jsonString);

import 'dart:convert';

List<SupplierActiveModel> supplierActiveModelFromJson(String str) => List<SupplierActiveModel>.from(json.decode(str).map((x) => SupplierActiveModel.fromJson(x)));

String supplierActiveModelToJson(List<SupplierActiveModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SupplierActiveModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? status;
  final String? supplierNo;
  final dynamic totalDue;
  final dynamic totalPaid;
  final dynamic totalPurchases;
  final int? purchaseCount;
  final String? amountType;
  final int? company;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;



  SupplierActiveModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.status,
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

  @override
  String toString() {
    // TODO: implement toString
    return name??"";
  }
  factory SupplierActiveModel.fromJson(Map<String, dynamic> json) => SupplierActiveModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    address: json["address"],
    status: json["status"],
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
    "status": status,
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
