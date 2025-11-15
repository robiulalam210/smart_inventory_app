// To parse this JSON data, do
//
//     final transactionsModel = transactionsModelFromJson(jsonString);

import 'dart:convert';

List<TransactionsModel> transactionsModelFromJson(String str) => List<TransactionsModel>.from(json.decode(str).map((x) => TransactionsModel.fromJson(x)));

String transactionsModelToJson(List<TransactionsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TransactionsModel {
  final int? id;
  final String? transactionNo;
  final String? transactionType;
  final String? amount;
  final int? account;
  final String? accountName;
  final String? accountType;
  final String? paymentMethod;
  final dynamic chequeNo;
  final dynamic referenceNo;
  final DateTime? transactionDate;
  final String? status;
  final String? description;
  final int? sale;
  final String? saleInvoiceNo;
  final int? moneyReceipt;
  final String? moneyReceiptNo;
  final dynamic expense;
  final dynamic expenseInvoiceNumber;
  final dynamic expenseHead;
  final dynamic purchase;
  final dynamic purchaseInvoiceNo;
  final int? supplierPayment;
  final dynamic supplierPaymentReference;
  final int? createdBy;
  final String? createdByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? company;

  TransactionsModel({
    this.id,
    this.transactionNo,
    this.transactionType,
    this.amount,
    this.account,
    this.accountName,
    this.accountType,
    this.paymentMethod,
    this.chequeNo,
    this.referenceNo,
    this.transactionDate,
    this.status,
    this.description,
    this.sale,
    this.saleInvoiceNo,
    this.moneyReceipt,
    this.moneyReceiptNo,
    this.expense,
    this.expenseInvoiceNumber,
    this.expenseHead,
    this.purchase,
    this.purchaseInvoiceNo,
    this.supplierPayment,
    this.supplierPaymentReference,
    this.createdBy,
    this.createdByName,
    this.createdAt,
    this.updatedAt,
    this.company,
  });

  factory TransactionsModel.fromJson(Map<String, dynamic> json) => TransactionsModel(
    id: json["id"],
    transactionNo: json["transaction_no"],
    transactionType: json["transaction_type"],
    amount: json["amount"],
    account: json["account"],
    accountName: json["account_name"],
    accountType: json["account_type"],
    paymentMethod: json["payment_method"],
    chequeNo: json["cheque_no"],
    referenceNo: json["reference_no"],
    transactionDate: json["transaction_date"] == null ? null : DateTime.parse(json["transaction_date"]),
    status: json["status"],
    description: json["description"],
    sale: json["sale"],
    saleInvoiceNo: json["sale_invoice_no"],
    moneyReceipt: json["money_receipt"],
    moneyReceiptNo: json["money_receipt_no"],
    expense: json["expense"],
    expenseInvoiceNumber: json["expense_invoice_number"],
    expenseHead: json["expense_head"],
    purchase: json["purchase"],
    purchaseInvoiceNo: json["purchase_invoice_no"],
    supplierPayment: json["supplier_payment"],
    supplierPaymentReference: json["supplier_payment_reference"],
    createdBy: json["created_by"],
    createdByName: json["created_by_name"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    company: json["company"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "transaction_no": transactionNo,
    "transaction_type": transactionType,
    "amount": amount,
    "account": account,
    "account_name": accountName,
    "account_type": accountType,
    "payment_method": paymentMethod,
    "cheque_no": chequeNo,
    "reference_no": referenceNo,
    "transaction_date": transactionDate?.toIso8601String(),
    "status": status,
    "description": description,
    "sale": sale,
    "sale_invoice_no": saleInvoiceNo,
    "money_receipt": moneyReceipt,
    "money_receipt_no": moneyReceiptNo,
    "expense": expense,
    "expense_invoice_number": expenseInvoiceNumber,
    "expense_head": expenseHead,
    "purchase": purchase,
    "purchase_invoice_no": purchaseInvoiceNo,
    "supplier_payment": supplierPayment,
    "supplier_payment_reference": supplierPaymentReference,
    "created_by": createdBy,
    "created_by_name": createdByName,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "company": company,
  };
}
