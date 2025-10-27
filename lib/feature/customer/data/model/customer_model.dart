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

  CustomerModel({
    this.id,
    this.name,
    this.phone,
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
  });

  @override
  String toString() {
    // TODO: implement toString
    return name??'';
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
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
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
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
  };
}
