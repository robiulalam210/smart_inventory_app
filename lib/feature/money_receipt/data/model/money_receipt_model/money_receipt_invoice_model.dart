// To parse this JSON data, do
//
//     final moneyReceiptInvoiceModel = moneyReceiptInvoiceModelFromJson(jsonString);

import 'dart:convert';

MoneyReceiptInvoiceModel moneyReceiptInvoiceModelFromJson(String str) => MoneyReceiptInvoiceModel.fromJson(json.decode(str));

String moneyReceiptInvoiceModelToJson(MoneyReceiptInvoiceModel data) => json.encode(data.toJson());

class MoneyReceiptInvoiceModel {
  int? id;
  String? mrNo;
  String? amount;
  String? paymentMethod;
  DateTime? paymentDate;
  String? remark;
  dynamic guestClientNumber;
  dynamic chequeNo;
  dynamic bankName;
  String? locationName;
  int? locationId;
  String? locationType;
  String? locationAddress;
  String? customerName;
  int? customerId;
  String? savedClientPhone;
  dynamic sellerName;
  dynamic sellerId;
  String? accountName;
  int? accountId;
  List<InvoiceItem>? invoiceItems;

  MoneyReceiptInvoiceModel({
    this.id,
    this.mrNo,
    this.amount,
    this.paymentMethod,
    this.paymentDate,
    this.remark,
    this.guestClientNumber,
    this.chequeNo,
    this.bankName,
    this.locationName,
    this.locationId,
    this.locationType,
    this.locationAddress,
    this.customerName,
    this.customerId,
    this.savedClientPhone,
    this.sellerName,
    this.sellerId,
    this.accountName,
    this.accountId,
    this.invoiceItems,
  });

  factory MoneyReceiptInvoiceModel.fromJson(Map<String, dynamic> json) => MoneyReceiptInvoiceModel(
    id: json["id"],
    mrNo: json["mr_no"],
    amount: json["amount"],
    paymentMethod: json["payment_method"],
    paymentDate: json["payment_date"] == null ? null : DateTime.parse(json["payment_date"]),
    remark: json["remark"],
    guestClientNumber: json["guest_client_number"],
    chequeNo: json["cheque_no"],
    bankName: json["bank_name"],
    locationName: json["location_name"],
    locationId: json["location_id"],
    locationType: json["location_type"],
    locationAddress: json["location_address"],
    customerName: json["customer_name"],
    customerId: json["customer_id"],
    savedClientPhone: json["saved_client_phone"],
    sellerName: json["seller_name"],
    sellerId: json["seller_id"],
    accountName: json["account_name"],
    accountId: json["account_id"],
    invoiceItems: json["invoice_items"] == null ? [] : List<InvoiceItem>.from(json["invoice_items"]!.map((x) => InvoiceItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "mr_no": mrNo,
    "amount": amount,
    "payment_method": paymentMethod,
    "payment_date": paymentDate?.toIso8601String(),
    "remark": remark,
    "guest_client_number": guestClientNumber,
    "cheque_no": chequeNo,
    "bank_name": bankName,
    "location_name": locationName,
    "location_id": locationId,
    "location_type": locationType,
    "location_address": locationAddress,
    "customer_name": customerName,
    "customer_id": customerId,
    "saved_client_phone": savedClientPhone,
    "seller_name": sellerName,
    "seller_id": sellerId,
    "account_name": accountName,
    "account_id": accountId,
    "invoice_items": invoiceItems == null ? [] : List<dynamic>.from(invoiceItems!.map((x) => x.toJson())),
  };
}

class InvoiceItem {
  String? productName;
  int? productId;
  String? unitPrice;
  int? quantity;
  String? due;

  InvoiceItem({
    this.productName,
    this.productId,
    this.unitPrice,
    this.quantity,
    this.due,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
    productName: json["product_name"],
    productId: json["product_id"],
    unitPrice: json["unit_price"],
    quantity: json["quantity"],
    due: json["due"],
  );

  Map<String, dynamic> toJson() => {
    "product_name": productName,
    "product_id": productId,
    "unit_price": unitPrice,
    "quantity": quantity,
    "due": due,
  };
}
