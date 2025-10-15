// To parse this JSON data, do
//
//     final groupsModel = groupsModelFromJson(jsonString);

import 'dart:convert';

List<GroupsModel> groupsModelFromJson(String str) => List<GroupsModel>.from(json.decode(str).map((x) => GroupsModel.fromJson(x)));

String groupsModelToJson(List<GroupsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GroupsModel {
  final int? id;
  final int? company;
  final String? name;

  GroupsModel({
    this.id,
    this.company,
    this.name,
  });

  factory GroupsModel.fromJson(Map<String, dynamic> json) => GroupsModel(
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
