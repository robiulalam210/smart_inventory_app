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
  final dynamic totalDue;
  final dynamic totalPaid;
  final String? amountType;
  final int? company;
  final dynamic totalSales;
  final DateTime? dateCreated;
  final int? createdBy;

  // নতুন ফিল্ড
  final bool? specialCustomer;
  final String? customerType;

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
    this.specialCustomer,
    this.customerType,
  });

  @override
  String toString() {
    final specialLabel = (specialCustomer == true) ? "[Special]" : "[Regular]";

    final due = totalDue ?? 0;
    final advance = (toJson()['advance_balance'] ?? 0);

    // শুধু non-zero value দেখানো
    List<String> info = [];
    if (due > 0) info.add("Due: $due");
    if (advance > 0) info.add("Advance: $advance");

    final infoString = info.isNotEmpty ? info.join(" | ") : "";

    return "$specialLabel $name${infoString.isNotEmpty ? ' | $infoString' : ''}";
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CustomerActiveModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory CustomerActiveModel.fromJson(Map<String, dynamic> json) =>
      CustomerActiveModel(
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
        dateCreated: json["date_created"] == null
            ? null
            : DateTime.parse(json["date_created"]),
        createdBy: json["created_by"],
        specialCustomer: json["special_customer"] ?? false,
        customerType: json["customer_type"] ?? "Regular",
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
    "special_customer": specialCustomer,
    "customer_type": customerType,
  };
}
