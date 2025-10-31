// To parse this JSON data, do
//
//     final salesInvoiceModel = salesInvoiceModelFromJson(jsonString);

import 'dart:convert';

List<SalesInvoiceModel> salesInvoiceModelFromJson(String str) => List<SalesInvoiceModel>.from(json.decode(str).map((x) => SalesInvoiceModel.fromJson(x)));

String salesInvoiceModelToJson(List<SalesInvoiceModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SalesInvoiceModel {
  final int? id;
  final String? invoiceNo;
  final int? customerId;
  final String? customerName;
  final String? saleType;
  final DateTime? saleDate;
  final String? saleByName;
  final String? createdByName;
  final dynamic? grossTotal;
  final dynamic? netTotal;
  final dynamic? grandTotal;
  final dynamic? payableAmount;
  final dynamic? paidAmount;
  final dynamic? dueAmount;
  final dynamic? changeAmount;
  final String? overallDiscount;
  final String? overallDiscountType;
  final String? overallDeliveryCharge;
  final String? overallDeliveryType;
  final String? overallServiceCharge;
  final String? overallServiceType;
  final String? overallVatAmount;
  final String? overallVatType;
  final String? paymentMethod;
  final int? accountId;
  final String? accountName;
  final String? customerType;
  final String? withMoneyReceipt;
  final String? remark;
  final List<Item>? items;

  SalesInvoiceModel({
    this.id,
    this.invoiceNo,
    this.customerId,
    this.customerName,
    this.saleType,
    this.saleDate,
    this.saleByName,
    this.createdByName,
    this.grossTotal,
    this.netTotal,
    this.grandTotal,
    this.payableAmount,
    this.paidAmount,
    this.dueAmount,
    this.changeAmount,
    this.overallDiscount,
    this.overallDiscountType,
    this.overallDeliveryCharge,
    this.overallDeliveryType,
    this.overallServiceCharge,
    this.overallServiceType,
    this.overallVatAmount,
    this.overallVatType,
    this.paymentMethod,
    this.accountId,
    this.accountName,
    this.customerType,
    this.withMoneyReceipt,
    this.remark,
    this.items,
  });

  @override
  String toString() {
    // TODO: implement toString
    return invoiceNo??'';
  }

  factory SalesInvoiceModel.fromJson(Map<String, dynamic> json) => SalesInvoiceModel(
    id: json["id"],
    invoiceNo: json["invoice_no"],
    customerId: json["customer_id"],
    customerName: json["customer_name"],
    saleType: json["sale_type"],
    saleDate: json["sale_date"] == null ? null : DateTime.parse(json["sale_date"]),
    saleByName: json["sale_by_name"],
    createdByName: json["created_by_name"],
    grossTotal: json["gross_total"],
    netTotal: json["net_total"],
    grandTotal: json["grand_total"],
    payableAmount: json["payable_amount"],
    paidAmount: json["paid_amount"],
    dueAmount: json["due_amount"],
    changeAmount: json["change_amount"],
    overallDiscount: json["overall_discount"],
    overallDiscountType: json["overall_discount_type"],
    overallDeliveryCharge: json["overall_delivery_charge"],
    overallDeliveryType: json["overall_delivery_type"],
    overallServiceCharge: json["overall_service_charge"],
    overallServiceType: json["overall_service_type"],
    overallVatAmount: json["overall_vat_amount"],
    overallVatType: json["overall_vat_type"],
    paymentMethod: json["payment_method"],
    accountId: json["account_id"],
    accountName: json["account_name"],
    customerType: json["customer_type"],
    withMoneyReceipt: json["with_money_receipt"],
    remark: json["remark"],
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "invoice_no": invoiceNo,
    "customer_id": customerId,
    "customer_name": customerName,
    "sale_type": saleType,
    "sale_date": saleDate?.toIso8601String(),
    "sale_by_name": saleByName,
    "created_by_name": createdByName,
    "gross_total": grossTotal,
    "net_total": netTotal,
    "grand_total": grandTotal,
    "payable_amount": payableAmount,
    "paid_amount": paidAmount,
    "due_amount": dueAmount,
    "change_amount": changeAmount,
    "overall_discount": overallDiscount,
    "overall_discount_type": overallDiscountType,
    "overall_delivery_charge": overallDeliveryCharge,
    "overall_delivery_type": overallDeliveryType,
    "overall_service_charge": overallServiceCharge,
    "overall_service_type": overallServiceType,
    "overall_vat_amount": overallVatAmount,
    "overall_vat_type": overallVatType,
    "payment_method": paymentMethod,
    "account_id": accountId,
    "account_name": accountName,
    "customer_type": customerType,
    "with_money_receipt": withMoneyReceipt,
    "remark": remark,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class Item {
  final int? id;
  final int? productId;
  final String? productName;
  final int? quantity;
  final dynamic? unitPrice;
  final String? discount;
  final String? discountType;
  final dynamic? subtotal;

  Item({
    this.id,
    this.productId,
    this.productName,
    this.quantity,
    this.unitPrice,
    this.discount,
    this.discountType,
    this.subtotal,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"],
    productId: json["product_id"],
    productName: json["product_name"],
    quantity: json["quantity"],
    unitPrice: json["unit_price"],
    discount: json["discount"],
    discountType: json["discount_type"],
    subtotal: json["subtotal"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
    "product_name": productName,
    "quantity": quantity,
    "unit_price": unitPrice,
    "discount": discount,
    "discount_type": discountType,
    "subtotal": subtotal,
  };
}
