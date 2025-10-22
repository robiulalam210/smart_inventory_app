// To parse this JSON data, do
//
//     final expenseModel = expenseModelFromJson(jsonString);

import 'dart:convert';

List<ExpenseModel> expenseModelFromJson(String str) => List<ExpenseModel>.from(json.decode(str).map((x) => ExpenseModel.fromJson(x)));

String expenseModelToJson(List<ExpenseModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExpenseModel {
  final int? id;
  final int? company;
  final int? head;
  final int? subhead;
  final String? headName;
  final String? subheadName;
  final String? amount;
  final String? paymentMethod;
  final int? account;
  final dynamic accountName;
  final DateTime? expenseDate;
  final dynamic note;
  final DateTime? createdAt;
  final int? createdBy;
  final DateTime? dateCreated;
  final String? invoiceNumber;

  ExpenseModel({
    this.id,
    this.company,
    this.head,
    this.subhead,
    this.headName,
    this.subheadName,
    this.amount,
    this.paymentMethod,
    this.account,
    this.accountName,
    this.expenseDate,
    this.note,
    this.createdAt,
    this.createdBy,
    this.dateCreated,
    this.invoiceNumber,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
    id: json["id"],
    company: json["company"],
    head: json["head"],
    subhead: json["subhead"],
    headName: json["head_name"],
    subheadName: json["subhead_name"],
    amount: json["amount"],
    paymentMethod: json["payment_method"],
    account: json["account"],
    accountName: json["account_name"],
    expenseDate: json["expense_date"] == null ? null : DateTime.parse(json["expense_date"]),
    note: json["note"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    createdBy: json["created_by"],
    dateCreated: json["date_created"] == null ? null : DateTime.parse(json["date_created"]),
    invoiceNumber: json["invoice_number"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company": company,
    "head": head,
    "subhead": subhead,
    "head_name": headName,
    "subhead_name": subheadName,
    "amount": amount,
    "payment_method": paymentMethod,
    "account": account,
    "account_name": accountName,
    "expense_date": "${expenseDate!.year.toString().padLeft(4, '0')}-${expenseDate!.month.toString().padLeft(2, '0')}-${expenseDate!.day.toString().padLeft(2, '0')}",
    "note": note,
    "created_at": createdAt?.toIso8601String(),
    "created_by": createdBy,
    "date_created": dateCreated?.toIso8601String(),
    "invoice_number": invoiceNumber,
  };
}
