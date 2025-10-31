// To parse this JSON data, do
//
//     final salesReturnModel = salesReturnModelFromJson(jsonString);

import 'dart:convert';

List<SalesReturnModel> salesReturnModelFromJson(String str) => List<SalesReturnModel>.from(json.decode(str).map((x) => SalesReturnModel.fromJson(x)));

String salesReturnModelToJson(List<SalesReturnModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SalesReturnModel {
  final int? id;
  final String? receiptNo;
  final dynamic customerName;
  final DateTime? returnDate;
  final dynamic accountId;
  final dynamic paymentMethod;
  final String? reason;
  final String? returnCharge;
  final dynamic returnChargeType;
  final String? returnAmount;
  final String? status;
  final int? companyId;
  final List<Item>? items;

  SalesReturnModel({
    this.id,
    this.receiptNo,
    this.customerName,
    this.returnDate,
    this.accountId,
    this.paymentMethod,
    this.reason,
    this.returnCharge,
    this.returnChargeType,
    this.returnAmount,
    this.status,
    this.companyId,
    this.items,
  });

  factory SalesReturnModel.fromJson(Map<String, dynamic> json) => SalesReturnModel(
    id: json["id"],
    receiptNo: json["receipt_no"],
    customerName: json["customer_name"],
    returnDate: json["return_date"] == null ? null : DateTime.parse(json["return_date"]),
    accountId: json["account_id"],
    paymentMethod: json["payment_method"],
    reason: json["reason"],
    returnCharge: json["return_charge"],
    returnChargeType: json["return_charge_type"],
    returnAmount: json["return_amount"],
    status: json["status"],
    companyId: json["company_id"],
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "receipt_no": receiptNo,
    "customer_name": customerName,
    "return_date": "${returnDate!.year.toString().padLeft(4, '0')}-${returnDate!.month.toString().padLeft(2, '0')}-${returnDate!.day.toString().padLeft(2, '0')}",
    "account_id": accountId,
    "payment_method": paymentMethod,
    "reason": reason,
    "return_charge": returnCharge,
    "return_charge_type": returnChargeType,
    "return_amount": returnAmount,
    "status": status,
    "company_id": companyId,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class Item {
  final int? id;
  final String? productName;
  final int? quantity;
  final int? damageQuantity;
  final String? unitPrice;
  final String? discount;
  final dynamic discountType;
  final String? total;

  Item({
    this.id,
    this.productName,
    this.quantity,
    this.damageQuantity,
    this.unitPrice,
    this.discount,
    this.discountType,
    this.total,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"],
    productName: json["product_name"],
    quantity: json["quantity"],
    damageQuantity: json["damage_quantity"],
    unitPrice: json["unit_price"],
    discount: json["discount"],
    discountType: json["discount_type"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_name": productName,
    "quantity": quantity,
    "damage_quantity": damageQuantity,
    "unit_price": unitPrice,
    "discount": discount,
    "discount_type": discountType,
    "total": total,
  };
}
