// To parse this JSON data, do
//
//     final purchaseInvoiceModel = purchaseInvoiceModelFromJson(jsonString);

import 'dart:convert';

List<PurchaseInvoiceModel> purchaseInvoiceModelFromJson(String str) => List<PurchaseInvoiceModel>.from(json.decode(str).map((x) => PurchaseInvoiceModel.fromJson(x)));

String purchaseInvoiceModelToJson(List<PurchaseInvoiceModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PurchaseInvoiceModel {
  final int? id;
  final int? company;
  final int? supplier;
  final String? supplierName;
  final DateTime? purchaseDate;
  final dynamic total;
  final dynamic grandTotal;
  final dynamic paidAmount;
  final dynamic dueAmount;
  final dynamic changeAmount;
  final dynamic overallDiscount;
  final String? overallDiscountType;
  final dynamic overallDeliveryCharge;
  final String? overallDeliveryChargeType;
  final dynamic overallServiceCharge;
  final String? overallServiceChargeType;
  final dynamic vat;
  final String? vatType;
  final String? invoiceNo;
  final String? paymentStatus;
  final dynamic returnAmount;
  final String? accountName;
  final String? paymentMethod;
  final dynamic remark;
  final List<Item>? items;
  final dynamic subTotal;



  PurchaseInvoiceModel({
    this.id,
    this.company,
    this.supplier,
    this.supplierName,
    this.purchaseDate,
    this.total,
    this.grandTotal,
    this.paidAmount,
    this.dueAmount,
    this.changeAmount,
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
    this.accountName,
    this.paymentMethod,
    this.remark,
    this.items,
    this.subTotal,
  });

  @override
  String toString() {
    // TODO: implement toString
    return invoiceNo??"";
  }
  factory PurchaseInvoiceModel.fromJson(Map<String, dynamic> json) => PurchaseInvoiceModel(
    id: json["id"],
    company: json["company"],
    supplier: json["supplier"],
    supplierName: json["supplier_name"],
    purchaseDate: json["purchase_date"] == null ? null : DateTime.parse(json["purchase_date"]),
    total: json["total"],
    grandTotal: json["grand_total"],
    paidAmount: json["paid_amount"],
    dueAmount: json["due_amount"],
    changeAmount: json["change_amount"],
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
    accountName: json["account_name"],
    paymentMethod: json["payment_method"],
    remark: json["remark"],
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    subTotal: json["sub_total"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company": company,
    "supplier": supplier,
    "supplier_name": supplierName,
    "purchase_date": "${purchaseDate!.year.toString().padLeft(4, '0')}-${purchaseDate!.month.toString().padLeft(2, '0')}-${purchaseDate!.day.toString().padLeft(2, '0')}",
    "total": total,
    "grand_total": grandTotal,
    "paid_amount": paidAmount,
    "due_amount": dueAmount,
    "change_amount": changeAmount,
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
    "account_name": accountName,
    "payment_method": paymentMethod,
    "remark": remark,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "sub_total": subTotal,
  };
}

class Item {
  final int? id;
  final String? productName;
  final int? qty;
  final dynamic price;
  final dynamic discount;
  final String? discountType;
  final dynamic productTotal;

  Item({
    this.id,
    this.productName,
    this.qty,
    this.price,
    this.discount,
    this.discountType,
    this.productTotal,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"],
    productName: json["product_name"],
    qty: json["qty"],
    price: json["price"],
    discount: json["discount"],
    discountType: json["discount_type"],
    productTotal: json["product_total"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_name": productName,
    "qty": qty,
    "price": price,
    "discount": discount,
    "discount_type": discountType,
    "product_total": productTotal,
  };
}
