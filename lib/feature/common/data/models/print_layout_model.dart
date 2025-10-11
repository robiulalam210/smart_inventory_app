// To parse this JSON data, do
//
//     final printLayoutModel = printLayoutModelFromJson(jsonString);

import 'dart:convert';

PrintLayoutModel printLayoutModelFromJson(String str) => PrintLayoutModel.fromJson(json.decode(str));

String printLayoutModelToJson(PrintLayoutModel data) => json.encode(data.toJson());

class PrintLayoutModel {
  final int? id;
  final String? billing;
  final String? letter;
  final String? sticker;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PrintLayoutModel({
    this.id,
    this.billing,
    this.letter,
    this.sticker,
    this.createdAt,
    this.updatedAt,
  });

  factory PrintLayoutModel.fromJson(Map<String, dynamic> json) => PrintLayoutModel(
    id: json["id"],
    billing: json["billing"],
    letter: json["letter"],
    sticker: json["sticker"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "billing": billing,
    "letter": letter,
    "sticker": sticker,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
