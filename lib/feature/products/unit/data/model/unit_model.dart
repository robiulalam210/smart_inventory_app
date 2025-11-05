// To parse this JSON data, do
//
//     final unitsModel = unitsModelFromJson(jsonString);

import 'dart:convert';

List<UnitsModel> unitsModelFromJson(String str) => List<UnitsModel>.from(json.decode(str).map((x) => UnitsModel.fromJson(x)));

String unitsModelToJson(List<UnitsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UnitsModel {
  final int? id;
  final int? company;
  final int? createdBy;
  final String? name;
  final String? code;
  final bool? isActive;

  UnitsModel({
    this.id,
    this.company,
    this.createdBy,
    this.name,
    this.code,
    this.isActive,
  });

  factory UnitsModel.fromJson(Map<String, dynamic> json) => UnitsModel(
    id: json["id"],
    company: json["company"],
    createdBy: json["created_by"],
    name: json["name"],
    code: json["code"],
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company": company,
    "created_by": createdBy,
    "name": name,
    "code": code,
    "is_active": isActive,
  };
}
