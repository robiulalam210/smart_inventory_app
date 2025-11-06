// To parse this JSON data, do
//
//     final expenseSubHeadModel = expenseSubHeadModelFromJson(jsonString);

import 'dart:convert';

List<ExpenseSubHeadModel> expenseSubHeadModelFromJson(String str) => List<ExpenseSubHeadModel>.from(json.decode(str).map((x) => ExpenseSubHeadModel.fromJson(x)));

String expenseSubHeadModelToJson(List<ExpenseSubHeadModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ExpenseSubHeadModel {
  final int? id;
  final String? name;
  final int? head;
  final String? headName;
  final int? company;
  final bool? isActive;

  ExpenseSubHeadModel({
    this.id,
    this.name,
    this.head,
    this.headName,
    this.company,
    this.isActive,
  });


  @override
  String toString() {
    // TODO: implement toString
    return name??'';
  }

  factory ExpenseSubHeadModel.fromJson(Map<String, dynamic> json) => ExpenseSubHeadModel(
    id: json["id"],
    name: json["name"],
    head: json["head"],
    headName: json["head_name"],
    company: json["company"],
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "head": head,
    "head_name": headName,
    "company": company,
    "is_active": isActive,
  };
}
