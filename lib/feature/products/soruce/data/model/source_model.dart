// To parse this JSON data, do
//
//     final sourceModel = sourceModelFromJson(jsonString);

import 'dart:convert';

List<SourceModel> sourceModelFromJson(String str) => List<SourceModel>.from(json.decode(str).map((x) => SourceModel.fromJson(x)));

String sourceModelToJson(List<SourceModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SourceModel {
  final int? id;
  final int? company;
  final int? createdBy;
  final String? name;
  final bool? isActive;

  SourceModel({
    this.id,
    this.company,
    this.createdBy,
    this.name,
    this.isActive,
  });

  factory SourceModel.fromJson(Map<String, dynamic> json) => SourceModel(
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
