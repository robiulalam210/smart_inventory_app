// To parse this JSON data, do
//
//     final expenseHeadModel = expenseHeadModelFromJson(jsonString);

import 'dart:convert';

List<ExpenseHeadModel> expenseHeadModelFromJson(String str) => List<ExpenseHeadModel>.from(json.decode(str).map((x) => ExpenseHeadModel.fromJson(x)));

String expenseHeadModelToJson(List<ExpenseHeadModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExpenseHeadModel {
  final int? id;
  final String? name;
  final int? company;

  ExpenseHeadModel({
    this.id,
    this.name,
    this.company,
  });

  @override
  String toString() {
    // TODO: implement toString
    return name??"";
  }
  factory ExpenseHeadModel.fromJson(Map<String, dynamic> json) => ExpenseHeadModel(
    id: json["id"],
    name: json["name"],
    company: json["company"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "company": company,
  };
}
