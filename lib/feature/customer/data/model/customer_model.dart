// To parse this JSON data, do
//
//     final customerModel = customerModelFromJson(jsonString);

import 'dart:convert';

List<CustomerModel> customerModelFromJson(String str) => List<CustomerModel>.from(json.decode(str).map((x) => CustomerModel.fromJson(x)));

String customerModelToJson(List<CustomerModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CustomerModel {
  final int? id;
  final String? name;
  final String? phone;
  final dynamic email;
  final String? address;
  final bool? isActive;
  final String? clientNo;
  final dynamic totalDue;
  final dynamic totalPaid;
  final String? amountType;
  final int? company;
  final dynamic totalSales;
  final DateTime? dateCreated;
  final int? createdBy;
  final dynamic advanceBalance; // 👈 NEW

  CustomerModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.isActive,
    this.clientNo,
    this.totalDue,
    this.totalPaid,
    this.amountType,
    this.company,
    this.totalSales,
    this.dateCreated,
    this.createdBy,
    this.advanceBalance, // 👈 NEW
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    email: json["email"],
    address: json["address"],
    isActive: json["is_active"],
    clientNo: json["client_no"],
    totalDue: json["total_due"],
    totalPaid: json["total_paid"],
    amountType: json["amount_type"],
    company: json["company"],
    totalSales: json["total_sales"],
    dateCreated: json["date_created"] == null
        ? null
        : DateTime.parse(json["date_created"]),
    createdBy: json["created_by"],
    advanceBalance: json["advance_balance"] ?? 0, // 👈 NEW
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "email": email,
    "address": address,
    "is_active": isActive,
    "client_no": clientNo,
    "total_due": totalDue,
    "total_paid": totalPaid,
    "amount_type": amountType,
    "company": company,
    "total_sales": totalSales,
    "date_created": dateCreated?.toIso8601String(),
    "created_by": createdBy,
    "advance_balance": advanceBalance, // 👈 NEW
  };
}
