// To parse this JSON data, do
//
//     final createMoneyReciptModel = createMoneyReciptModelFromJson(jsonString);

import 'dart:convert';

CreateMoneyReciptModel createMoneyReciptModelFromJson(String str) => CreateMoneyReciptModel.fromJson(json.decode(str));

String createMoneyReciptModelToJson(CreateMoneyReciptModel data) => json.encode(data.toJson());

class CreateMoneyReciptModel {
  final bool? status;
  final String? message;
  final Data? data;

  CreateMoneyReciptModel({
    this.status,
    this.message,
    this.data,
  });

  factory CreateMoneyReciptModel.fromJson(Map<String, dynamic> json) => CreateMoneyReciptModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  final int? id;
  final String? mrNo;
  final int? company;
  final int? customer;
  final String? customerName;
  final dynamic customerPhone;
  final String? paymentType;
  final bool? specificInvoice;
  final dynamic sale;
  final dynamic saleInvoiceNo;
  final String? amount;
  final String? paymentMethod;
  final DateTime? paymentDate;
  final String? remark;
  final int? account;
  final int? seller;
  final String? sellerName;
  final dynamic chequeStatus;
  final dynamic chequeId;
  final DateTime? createdAt;
  final PaymentSummary? paymentSummary;

  Data({
    this.id,
    this.mrNo,
    this.company,
    this.customer,
    this.customerName,
    this.customerPhone,
    this.paymentType,
    this.specificInvoice,
    this.sale,
    this.saleInvoiceNo,
    this.amount,
    this.paymentMethod,
    this.paymentDate,
    this.remark,
    this.account,
    this.seller,
    this.sellerName,
    this.chequeStatus,
    this.chequeId,
    this.createdAt,
    this.paymentSummary,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    mrNo: json["mr_no"],
    company: json["company"],
    customer: json["customer"],
    customerName: json["customer_name"],
    customerPhone: json["customer_phone"],
    paymentType: json["payment_type"],
    specificInvoice: json["specific_invoice"],
    sale: json["sale"],
    saleInvoiceNo: json["sale_invoice_no"],
    amount: json["amount"],
    paymentMethod: json["payment_method"],
    paymentDate: json["payment_date"] == null ? null : DateTime.parse(json["payment_date"]),
    remark: json["remark"],
    account: json["account"],
    seller: json["seller"],
    sellerName: json["seller_name"],
    chequeStatus: json["cheque_status"],
    chequeId: json["cheque_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    paymentSummary: json["payment_summary"] == null ? null : PaymentSummary.fromJson(json["payment_summary"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "mr_no": mrNo,
    "company": company,
    "customer": customer,
    "customer_name": customerName,
    "customer_phone": customerPhone,
    "payment_type": paymentType,
    "specific_invoice": specificInvoice,
    "sale": sale,
    "sale_invoice_no": saleInvoiceNo,
    "amount": amount,
    "payment_method": paymentMethod,
    "payment_date": paymentDate?.toIso8601String(),
    "remark": remark,
    "account": account,
    "seller": seller,
    "seller_name": sellerName,
    "cheque_status": chequeStatus,
    "cheque_id": chequeId,
    "created_at": createdAt?.toIso8601String(),
    "payment_summary": paymentSummary?.toJson(),
  };
}

class PaymentSummary {
  final String? paymentType;
  final BeforePayment? beforePayment;
  final AfterPayment? afterPayment;
  final List<AffectedInvoice>? affectedInvoices;
  final String? status;

  PaymentSummary({
    this.paymentType,
    this.beforePayment,
    this.afterPayment,
    this.affectedInvoices,
    this.status,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) => PaymentSummary(
    paymentType: json["payment_type"],
    beforePayment: json["before_payment"] == null ? null : BeforePayment.fromJson(json["before_payment"]),
    afterPayment: json["after_payment"] == null ? null : AfterPayment.fromJson(json["after_payment"]),
    affectedInvoices: json["affected_invoices"] == null ? [] : List<AffectedInvoice>.from(json["affected_invoices"]!.map((x) => AffectedInvoice.fromJson(x))),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "payment_type": paymentType,
    "before_payment": beforePayment?.toJson(),
    "after_payment": afterPayment?.toJson(),
    "affected_invoices": affectedInvoices == null ? [] : List<dynamic>.from(affectedInvoices!.map((x) => x.toJson())),
    "status": status,
  };
}

class AffectedInvoice {
  final String? invoiceNo;
  final dynamic amountApplied;

  AffectedInvoice({
    this.invoiceNo,
    this.amountApplied,
  });

  factory AffectedInvoice.fromJson(Map<String, dynamic> json) => AffectedInvoice(
    invoiceNo: json["invoice_no"],
    amountApplied: json["amount_applied"],
  );

  Map<String, dynamic> toJson() => {
    "invoice_no": invoiceNo,
    "amount_applied": amountApplied,
  };
}

class AfterPayment {
  final dynamic totalDue;
  final dynamic paymentApplied;

  AfterPayment({
    this.totalDue,
    this.paymentApplied,
  });

  factory AfterPayment.fromJson(Map<String, dynamic> json) => AfterPayment(
    totalDue: json["total_due"],
    paymentApplied: json["payment_applied"],
  );

  Map<String, dynamic> toJson() => {
    "total_due": totalDue,
    "payment_applied": paymentApplied,
  };
}

class BeforePayment {
  final dynamic totalDue;

  BeforePayment({
    this.totalDue,
  });

  factory BeforePayment.fromJson(Map<String, dynamic> json) => BeforePayment(
    totalDue: json["total_due"],
  );

  Map<String, dynamic> toJson() => {
    "total_due": totalDue,
  };
}
