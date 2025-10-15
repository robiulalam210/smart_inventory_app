// To parse this JSON data, do
//
//     final brandModel = brandModelFromJson(jsonString);

import 'dart:convert';

List<BrandModel> brandModelFromJson(String str) => List<BrandModel>.from(json.decode(str).map((x) => BrandModel.fromJson(x)));

String brandModelToJson(List<BrandModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BrandModel {
  final int? id;
  final int? company;
  final String? name;

  BrandModel({
    this.id,
    this.company,
    this.name,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
    id: json["id"],
    company: json["company"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company": company,
    "name": name,
  };
}
