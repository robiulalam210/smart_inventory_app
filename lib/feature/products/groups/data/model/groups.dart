// To parse this JSON data, do
//
//     final groupsModel = groupsModelFromJson(jsonString);

import 'dart:convert';

List<GroupsModel> groupsModelFromJson(String str) => List<GroupsModel>.from(json.decode(str).map((x) => GroupsModel.fromJson(x)));

String groupsModelToJson(List<GroupsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GroupsModel {
  final int? id;
  final int? company;
  final int? createdBy;
  final String? name;
  final bool? isActive;

  GroupsModel({
    this.id,
    this.company,
    this.createdBy,
    this.name,
    this.isActive,
  });

  factory GroupsModel.fromJson(Map<String, dynamic> json) => GroupsModel(
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
