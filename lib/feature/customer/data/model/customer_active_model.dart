// To parse this JSON data, do
//
//     final customerActiveModel = customerActiveModelFromJson(jsonString);

import 'dart:convert';

List<CustomerActiveModel> customerActiveModelFromJson(String str) => List<CustomerActiveModel>.from(json.decode(str).map((x) => CustomerActiveModel.fromJson(x)));

String customerActiveModelToJson(List<CustomerActiveModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CustomerActiveModel {
  final int? id;
  final String? name;
  final String? phone;
  final dynamic email;
  final String? address;
  final bool? isActive;
  final String? statusDisplay;
  final String? clientNo;
  final String? totalDue;
  final String? totalPaid;
  final String? amountType;
  final int? company;
  final int? totalSales;
  final DateTime? dateCreated;
  final int? createdBy;

  CustomerActiveModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.isActive,
    this.statusDisplay,
    this.clientNo,
    this.totalDue,
    this.totalPaid,
    this.amountType,
    this.company,
    this.totalSales,
    this.dateCreated,
    this.createdBy,
  });

  @override
  String toString() {
    // TODO: implement toString
    return name??'';
  }
  factory CustomerActiveModel.fromJson(Map<String, dynamic> json) => CustomerActiveModel(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    email: json["email"],
    address: json["address"],
    isActive: json["is_active"],
    statusDisplay: json["status_display"],
    clientNo: json["client_no"],
    totalDue: json["total_due"],
    totalPaid: json["total_paid"],
    amountType: json["amount_type"],
    company: json["company"],
    totalSales: json["total_sales"],
    dateCreated: json["date_created"] == null ? null : DateTime.parse(json["date_created"]),
    createdBy: json["created_by"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "email": email,
    "address": address,
    "is_active": isActive,
    "status_display": statusDisplay,
    "client_no": clientNo,
    "total_due": totalDue,
    "total_paid": totalPaid,
    "amount_type": amountType,
    "company": company,
    "total_sales": totalSales,
    "date_created": dateCreated?.toIso8601String(),
    "created_by": createdBy,
  };
}
