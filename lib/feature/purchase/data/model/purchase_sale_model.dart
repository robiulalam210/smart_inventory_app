// To parse this JSON data, do
//
//     final purchaseModel = purchaseModelFromJson(jsonString);

import 'dart:convert';

List<PurchaseModel> purchaseModelFromJson(String str) => List<PurchaseModel>.from(json.decode(str).map((x) => PurchaseModel.fromJson(x)));

String purchaseModelToJson(List<PurchaseModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PurchaseModel {
  final int? id;
  final int? company;
  final int? supplier;
  final String? supplierName;
  final String? total;
  final DateTime? date;
  final String? overallDiscount;
  final String? overallDiscountType;
  final String? overallDeliveryCharge;
  final String? overallDeliveryChargeType;
  final String? overallServiceCharge;
  final String? overallServiceChargeType;
  final String? vat;
  final String? vatType;
  final String? invoiceNo;
  final String? paymentStatus;
  final String? returnAmount;
  final int? accountId;
  final String? accountName;
  final String? paymentMethod;
  final List<Item>? items;

  PurchaseModel({
    this.id,
    this.company,
    this.supplier,
    this.supplierName,
    this.total,
    this.date,
    this.overallDiscount,
    this.overallDiscountType,
    this.overallDeliveryCharge,
    this.overallDeliveryChargeType,
    this.overallServiceCharge,
    this.overallServiceChargeType,
    this.vat,
    this.vatType,
    this.invoiceNo,
    this.paymentStatus,
    this.returnAmount,
    this.accountId,
    this.accountName,
    this.paymentMethod,
    this.items,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) => PurchaseModel(
    id: json["id"],
    company: json["company"],
    supplier: json["supplier"],
    supplierName: json["supplier_name"],
    total: json["total"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    overallDiscount: json["overall_discount"],
    overallDiscountType: json["overall_discount_type"],
    overallDeliveryCharge: json["overall_delivery_charge"],
    overallDeliveryChargeType: json["overall_delivery_charge_type"],
    overallServiceCharge: json["overall_service_charge"],
    overallServiceChargeType: json["overall_service_charge_type"],
    vat: json["vat"],
    vatType: json["vat_type"],
    invoiceNo: json["invoice_no"],
    paymentStatus: json["payment_status"],
    returnAmount: json["return_amount"],
    accountId: json["account_id"],
    accountName: json["account_name"],
    paymentMethod: json["payment_method"],
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company": company,
    "supplier": supplier,
    "supplier_name": supplierName,
    "total": total,
    "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "overall_discount": overallDiscount,
    "overall_discount_type": overallDiscountType,
    "overall_delivery_charge": overallDeliveryCharge,
    "overall_delivery_charge_type": overallDeliveryChargeType,
    "overall_service_charge": overallServiceCharge,
    "overall_service_charge_type": overallServiceChargeType,
    "vat": vat,
    "vat_type": vatType,
    "invoice_no": invoiceNo,
    "payment_status": paymentStatus,
    "return_amount": returnAmount,
    "account_id": accountId,
    "account_name": accountName,
    "payment_method": paymentMethod,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class Item {
  final int? id;
  final String? productName;
  final int? qty;
  final String? price;
  final String? discount;
  final String? discountType;

  Item({
    this.id,
    this.productName,
    this.qty,
    this.price,
    this.discount,
    this.discountType,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"],
    productName: json["product_name"],
    qty: json["qty"],
    price: json["price"],
    discount: json["discount"],
    discountType: json["discount_type"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_name": productName,
    "qty": qty,
    "price": price,
    "discount": discount,
    "discount_type": discountType,
  };
}
