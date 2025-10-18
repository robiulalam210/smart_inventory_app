// To parse this JSON data, do
//
//     final moneyreceiptModel = moneyreceiptModelFromJson(jsonString);

import 'dart:convert';

List<MoneyreceiptModel> moneyreceiptModelFromJson(String str) => List<MoneyreceiptModel>.from(json.decode(str).map((x) => MoneyreceiptModel.fromJson(x)));

String moneyreceiptModelToJson(List<MoneyreceiptModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MoneyreceiptModel {
  final int? id;
  final String? mrNo;
  final String? locationName;
  final int? locationId;
  final dynamic customerName;
  final dynamic customerId;
  final dynamic customerPhone;
  final dynamic customerAddress;
  final String? amount;
  final String? paymentMethod;
  final DateTime? paymentDate;
  final String? remark;
  final String? sellerName;
  final int? sellerId;
  final dynamic chequeStatus;
  final dynamic chequeId;

  MoneyreceiptModel({
    this.id,
    this.mrNo,
    this.locationName,
    this.locationId,
    this.customerName,
    this.customerId,
    this.customerPhone,
    this.customerAddress,
    this.amount,
    this.paymentMethod,
    this.paymentDate,
    this.remark,
    this.sellerName,
    this.sellerId,
    this.chequeStatus,
    this.chequeId,
  });

  factory MoneyreceiptModel.fromJson(Map<String, dynamic> json) => MoneyreceiptModel(
    id: json["id"],
    mrNo: json["mr_no"],
    locationName: json["location_name"],
    locationId: json["location_id"],
    customerName: json["customer_name"],
    customerId: json["customer_id"],
    customerPhone: json["customer_phone"],
    customerAddress: json["customer_address"],
    amount: json["amount"],
    paymentMethod: json["payment_method"],
    paymentDate: json["payment_date"] == null ? null : DateTime.parse(json["payment_date"]),
    remark: json["remark"],
    sellerName: json["seller_name"],
    sellerId: json["seller_id"],
    chequeStatus: json["cheque_status"],
    chequeId: json["cheque_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "mr_no": mrNo,
    "location_name": locationName,
    "location_id": locationId,
    "customer_name": customerName,
    "customer_id": customerId,
    "customer_phone": customerPhone,
    "customer_address": customerAddress,
    "amount": amount,
    "payment_method": paymentMethod,
    "payment_date": paymentDate?.toIso8601String(),
    "remark": remark,
    "seller_name": sellerName,
    "seller_id": sellerId,
    "cheque_status": chequeStatus,
    "cheque_id": chequeId,
  };
}
