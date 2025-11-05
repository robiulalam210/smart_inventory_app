// To parse this JSON data, do
//
//     final brandModel = brandModelFromJson(jsonString);

import 'dart:convert';

List<BrandModel> brandModelFromJson(String str) => List<BrandModel>.from(json.decode(str).map((x) => BrandModel.fromJson(x)));

String brandModelToJson(List<BrandModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BrandModel {
  final int? id;
  final int? company;
  final int? createdBy;
  final String? name;
  final bool? isActive;

  BrandModel({
    this.id,
    this.company,
    this.createdBy,
    this.name,
    this.isActive,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
    id: json["id"],
    company: json["company"],
    createdBy: json["created_by"],
    name: json["name"],
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company": company,
    "created_by": createdBy,
    "name": name,
    "is_active": isActive,
  };
}
