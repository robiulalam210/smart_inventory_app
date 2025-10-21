// To parse this JSON data, do
//
//     final supplierPaymentModel = supplierPaymentModelFromJson(jsonString);

import 'dart:convert';

List<SupplierPaymentModel> supplierPaymentModelFromJson(String str) => List<SupplierPaymentModel>.from(json.decode(str).map((x) => SupplierPaymentModel.fromJson(x)));

String supplierPaymentModelToJson(List<SupplierPaymentModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SupplierPaymentModel {
  final int? id;
  final String? spNo;
  final int? company;
  final int? supplier;
  final String? supplierName;
  final String? supplierPhone;
  final String? paymentType;
  final bool? specificBill;
  final int? purchase;
  final String? purchaseInvoiceNo;
  final dynamic amount;
  final String? paymentMethod;
  final DateTime? paymentDate;
  final String? remark;
  final int? account;
  final int? preparedBy;
  final String? preparedByName;
  final dynamic chequeStatus;
  final dynamic chequeNo;
  final dynamic chequeDate;
  final dynamic bankName;
  final DateTime? createdAt;
  final PaymentSummary? paymentSummary;

  SupplierPaymentModel({
    this.id,
    this.spNo,
    this.company,
    this.supplier,
    this.supplierName,
    this.supplierPhone,
    this.paymentType,
    this.specificBill,
    this.purchase,
    this.purchaseInvoiceNo,
    this.amount,
    this.paymentMethod,
    this.paymentDate,
    this.remark,
    this.account,
    this.preparedBy,
    this.preparedByName,
    this.chequeStatus,
    this.chequeNo,
    this.chequeDate,
    this.bankName,
    this.createdAt,
    this.paymentSummary,
  });

  factory SupplierPaymentModel.fromJson(Map<String, dynamic> json) => SupplierPaymentModel(
    id: json["id"],
    spNo: json["sp_no"],
    company: json["company"],
    supplier: json["supplier"],
    supplierName: json["supplier_name"],
    supplierPhone: json["supplier_phone"],
    paymentType: json["payment_type"],
    specificBill: json["specific_bill"],
    purchase: json["purchase"],
    purchaseInvoiceNo: json["purchase_invoice_no"],
    amount: json["amount"],
    paymentMethod: json["payment_method"],
    paymentDate: json["payment_date"] == null ? null : DateTime.parse(json["payment_date"]),
    remark: json["remark"],
    account: json["account"],
    preparedBy: json["prepared_by"],
    preparedByName: json["prepared_by_name"],
    chequeStatus: json["cheque_status"],
    chequeNo: json["cheque_no"],
    chequeDate: json["cheque_date"],
    bankName: json["bank_name"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    paymentSummary: json["payment_summary"] == null ? null : PaymentSummary.fromJson(json["payment_summary"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sp_no": spNo,
    "company": company,
    "supplier": supplier,
    "supplier_name": supplierName,
    "supplier_phone": supplierPhone,
    "payment_type": paymentType,
    "specific_bill": specificBill,
    "purchase": purchase,
    "purchase_invoice_no": purchaseInvoiceNo,
    "amount": amount,
    "payment_method": paymentMethod,
    "payment_date": paymentDate?.toIso8601String(),
    "remark": remark,
    "account": account,
    "prepared_by": preparedBy,
    "prepared_by_name": preparedByName,
    "cheque_status": chequeStatus,
    "cheque_no": chequeNo,
    "cheque_date": chequeDate,
    "bank_name": bankName,
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
  final String? invoiceNo;

  PaymentSummary({
    this.paymentType,
    this.beforePayment,
    this.afterPayment,
    this.affectedInvoices,
    this.status,
    this.invoiceNo,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) => PaymentSummary(
    paymentType: json["payment_type"],
    beforePayment: json["before_payment"] == null ? null : BeforePayment.fromJson(json["before_payment"]),
    afterPayment: json["after_payment"] == null ? null : AfterPayment.fromJson(json["after_payment"]),
    affectedInvoices: json["affected_invoices"] == null ? [] : List<AffectedInvoice>.from(json["affected_invoices"]!.map((x) => AffectedInvoice.fromJson(x))),
    status: json["status"],
    invoiceNo: json["invoice_no"],
  );

  Map<String, dynamic> toJson() => {
    "payment_type": paymentType,
    "before_payment": beforePayment?.toJson(),
    "after_payment": afterPayment?.toJson(),
    "affected_invoices": affectedInvoices == null ? [] : List<dynamic>.from(affectedInvoices!.map((x) => x.toJson())),
    "status": status,
    "invoice_no": invoiceNo,
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
  final dynamic currentPaid;
  final dynamic currentDue;

  AfterPayment({
    this.totalDue,
    this.paymentApplied,
    this.currentPaid,
    this.currentDue,
  });

  factory AfterPayment.fromJson(Map<String, dynamic> json) => AfterPayment(
    totalDue: json["total_due"],
    paymentApplied: json["payment_applied"],
    currentPaid: json["current_paid"],
    currentDue: json["current_due"],
  );

  Map<String, dynamic> toJson() => {
    "total_due": totalDue,
    "payment_applied": paymentApplied,
    "current_paid": currentPaid,
    "current_due": currentDue,
  };
}

class BeforePayment {
  final dynamic totalDue;
  final dynamic invoiceTotal;
  final dynamic previousPaid;
  final dynamic previousDue;

  BeforePayment({
    this.totalDue,
    this.invoiceTotal,
    this.previousPaid,
    this.previousDue,
  });

  factory BeforePayment.fromJson(Map<String, dynamic> json) => BeforePayment(
    totalDue: json["total_due"],
    invoiceTotal: json["invoice_total"],
    previousPaid: json["previous_paid"],
    previousDue: json["previous_due"],
  );

  Map<String, dynamic> toJson() => {
    "total_due": totalDue,
    "invoice_total": invoiceTotal,
    "previous_paid": previousPaid,
    "previous_due": previousDue,
  };
}
