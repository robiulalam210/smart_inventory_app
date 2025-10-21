// To parse this JSON data, do
//
//     final supplierPaymentDetailsModel = supplierPaymentDetailsModelFromJson(jsonString);

import 'dart:convert';

SupplierPaymentDetailsModel supplierPaymentDetailsModelFromJson(String str) => SupplierPaymentDetailsModel.fromJson(json.decode(str));

String supplierPaymentDetailsModelToJson(SupplierPaymentDetailsModel data) => json.encode(data.toJson());

class SupplierPaymentDetailsModel {
  int? id;
  String? paymentNo;
  String? locationName;
  int? locationId;
  String? locationType;
  String? locationAddress;
  String? supplierName;
  String? supplierPhone;
  dynamic supplierAddress;
  String? amount;
  String? paymentMethod;
  DateTime? paymentDate;
  String? remark;
  String? accountName;
  int? accountId;
  String? signature;

  SupplierPaymentDetailsModel({
    this.id,
    this.paymentNo,
    this.locationName,
    this.locationId,
    this.locationType,
    this.locationAddress,
    this.supplierName,
    this.supplierPhone,
    this.supplierAddress,
    this.amount,
    this.paymentMethod,
    this.paymentDate,
    this.remark,
    this.accountName,
    this.accountId,
    this.signature,
  });

  factory SupplierPaymentDetailsModel.fromJson(Map<String, dynamic> json) => SupplierPaymentDetailsModel(
    id: json["id"],
    paymentNo: json["payment_no"],
    locationName: json["location_name"],
    locationId: json["location_id"],
    locationType: json["location_type"],
    locationAddress: json["location_address"],
    supplierName: json["supplier_name"],
    supplierPhone: json["supplier_phone"],
    supplierAddress: json["supplier_address"],
    amount: json["amount"],
    paymentMethod: json["payment_method"],
    paymentDate: json["payment_date"] == null ? null : DateTime.parse(json["payment_date"]),
    remark: json["remark"],
    accountName: json["account_name"],
    accountId: json["account_id"],
    signature: json["signature"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "payment_no": paymentNo,
    "location_name": locationName,
    "location_id": locationId,
    "location_type": locationType,
    "location_address": locationAddress,
    "supplier_name": supplierName,
    "supplier_phone": supplierPhone,
    "supplier_address": supplierAddress,
    "amount": amount,
    "payment_method": paymentMethod,
    "payment_date": "${paymentDate!.year.toString().padLeft(4, '0')}-${paymentDate!.month.toString().padLeft(2, '0')}-${paymentDate!.day.toString().padLeft(2, '0')}",
    "remark": remark,
    "account_name": accountName,
    "account_id": accountId,
    "signature": signature,
  };
}
