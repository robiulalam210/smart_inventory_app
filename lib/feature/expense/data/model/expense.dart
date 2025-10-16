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
  final String? description;
  final String? amount;
  final String? paymentMethod;
  final int? account;
  final DateTime? expenseDate;
  final String? note;
  final DateTime? createdAt;

  ExpenseModel({
    this.id,
    this.company,
    this.head,
    this.subhead,
    this.description,
    this.amount,
    this.paymentMethod,
    this.account,
    this.expenseDate,
    this.note,
    this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
    id: json["id"],
    company: json["company"],
    head: json["head"],
    subhead: json["subhead"],
    description: json["description"],
    amount: json["amount"],
    paymentMethod: json["payment_method"],
    account: json["account"],
    expenseDate: json["expense_date"] == null ? null : DateTime.parse(json["expense_date"]),
    note: json["note"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company": company,
    "head": head,
    "subhead": subhead,
    "description": description,
    "amount": amount,
    "payment_method": paymentMethod,
    "account": account,
    "expense_date": "${expenseDate!.year.toString().padLeft(4, '0')}-${expenseDate!.month.toString().padLeft(2, '0')}-${expenseDate!.day.toString().padLeft(2, '0')}",
    "note": note,
    "created_at": createdAt?.toIso8601String(),
  };
}
