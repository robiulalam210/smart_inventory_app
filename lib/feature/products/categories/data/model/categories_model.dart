// To parse this JSON data, do
//
//     final categoryModel = categoryModelFromJson(jsonString);

import 'dart:convert';

List<CategoryModel> categoryModelFromJson(String str) => List<CategoryModel>.from(json.decode(str).map((x) => CategoryModel.fromJson(x)));

String categoryModelToJson(List<CategoryModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoryModel {
  final int? id;
  final int? company;
  final int? createdBy;
  final String? name;
  final dynamic description;
  final bool? isActive;

  CategoryModel({
    this.id,
    this.company,
    this.createdBy,
    this.name,
    this.description,
    this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json["id"],
    company: json["company"],
    createdBy: json["created_by"],
    name: json["name"],
    description: json["description"],
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company": company,
    "created_by": createdBy,
    "name": name,
    "description": description,
    "is_active": isActive,
  };
}
