// To parse this JSON data, do
//
//     final unitsModel = unitsModelFromJson(jsonString);

import 'dart:convert';

List<UnitsModel> unitsModelFromJson(String str) => List<UnitsModel>.from(json.decode(str).map((x) => UnitsModel.fromJson(x)));

String unitsModelToJson(List<UnitsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UnitsModel {
  final int? id;
  final int? company;
  final String? name;
  final String? code;



  UnitsModel({
    this.id,
    this.company,
    this.name,
    this.code,
  });

  @override
  String toString() {
    // TODO: implement toString
    return name??"";
  }

  factory UnitsModel.fromJson(Map<String, dynamic> json) => UnitsModel(
    id: json["id"],
    company: json["company"],
    name: json["name"],
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company": company,
    "name": name,
    "code": code,
  };
}
