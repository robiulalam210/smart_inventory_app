// To parse this JSON data, do
//
//     final sourceModel = sourceModelFromJson(jsonString);

import 'dart:convert';

List<SourceModel> sourceModelFromJson(String str) => List<SourceModel>.from(json.decode(str).map((x) => SourceModel.fromJson(x)));

String sourceModelToJson(List<SourceModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SourceModel {
  final int? id;
  final int? company;
  final String? name;

  SourceModel({
    this.id,
    this.company,
    this.name,
  });

  factory SourceModel.fromJson(Map<String, dynamic> json) => SourceModel(
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
