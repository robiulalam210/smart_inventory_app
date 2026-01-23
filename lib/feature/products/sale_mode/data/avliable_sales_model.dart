// To parse this JSON data, do
//
//     final avlibleSaleModeModel = avlibleSaleModeModelFromJson(jsonString);

import 'dart:convert';

List<AvlibleSaleModeModel> avlibleSaleModeModelFromJson(String str) => List<AvlibleSaleModeModel>.from(json.decode(str).map((x) => AvlibleSaleModeModel.fromJson(x)));

String avlibleSaleModeModelToJson(List<AvlibleSaleModeModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AvlibleSaleModeModel {
  int? id;
  String? name;
  String? code;
  String? priceType;
  dynamic? conversionFactor;
  bool? configured;
  dynamic unitPrice;
  dynamic flatPrice;
  dynamic discountType;
  dynamic discountValue;
  bool? isActive;

  AvlibleSaleModeModel({
    this.id,
    this.name,
    this.code,
    this.priceType,
    this.conversionFactor,
    this.configured,
    this.unitPrice,
    this.flatPrice,
    this.discountType,
    this.discountValue,
    this.isActive,
  });

  AvlibleSaleModeModel copyWith({
    int? id,
    String? name,
    String? code,
    String? priceType,
    int? conversionFactor,
    bool? configured,
    dynamic unitPrice,
    dynamic flatPrice,
    dynamic discountType,
    dynamic discountValue,
    bool? isActive,
  }) =>
      AvlibleSaleModeModel(
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
        priceType: priceType ?? this.priceType,
        conversionFactor: conversionFactor ?? this.conversionFactor,
        configured: configured ?? this.configured,
        unitPrice: unitPrice ?? this.unitPrice,
        flatPrice: flatPrice ?? this.flatPrice,
        discountType: discountType ?? this.discountType,
        discountValue: discountValue ?? this.discountValue,
        isActive: isActive ?? this.isActive,
      );

  factory AvlibleSaleModeModel.fromJson(Map<String, dynamic> json) => AvlibleSaleModeModel(
    id: json["id"],
    name: json["name"],
    code: json["code"],
    priceType: json["price_type"],
    conversionFactor: json["conversion_factor"],
    configured: json["configured"],
    unitPrice: json["unit_price"],
    flatPrice: json["flat_price"],
    discountType: json["discount_type"],
    discountValue: json["discount_value"],
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "price_type": priceType,
    "conversion_factor": conversionFactor,
    "configured": configured,
    "unit_price": unitPrice,
    "flat_price": flatPrice,
    "discount_type": discountType,
    "discount_value": discountValue,
    "is_active": isActive,
  };
}
