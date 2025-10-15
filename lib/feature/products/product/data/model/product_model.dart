// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';

List<ProductModel> productModelFromJson(String str) => List<ProductModel>.from(json.decode(str).map((x) => ProductModel.fromJson(x)));

String productModelToJson(List<ProductModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductModel {
  final int? id;
  final int? company;
  final int? category;
  final int? unit;
  final dynamic brand;
  final dynamic group;
  final dynamic source;
  final String? name;
  final String? sku;
  final dynamic barCode;
  final String? purchasePrice;
  final String? sellingPrice;
  final int? openingStock;
  final int? stockQty;
  final int? alertQuantity;
  final dynamic description;
  final dynamic image;
  final bool? isActive;
  final dynamic unitName;
  final dynamic unitSubName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    this.id,
    this.company,
    this.category,
    this.unit,
    this.brand,
    this.group,
    this.source,
    this.name,
    this.sku,
    this.barCode,
    this.purchasePrice,
    this.sellingPrice,
    this.openingStock,
    this.stockQty,
    this.alertQuantity,
    this.description,
    this.image,
    this.isActive,
    this.unitName,
    this.unitSubName,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json["id"],
    company: json["company"],
    category: json["category"],
    unit: json["unit"],
    brand: json["brand"],
    group: json["group"],
    source: json["source"],
    name: json["name"],
    sku: json["sku"],
    barCode: json["bar_code"],
    purchasePrice: json["purchase_price"],
    sellingPrice: json["selling_price"],
    openingStock: json["opening_stock"],
    stockQty: json["stock_qty"],
    alertQuantity: json["alert_quantity"],
    description: json["description"],
    image: json["image"],
    isActive: json["is_active"],
    unitName: json["unit_name"],
    unitSubName: json["unit_sub_name"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company": company,
    "category": category,
    "unit": unit,
    "brand": brand,
    "group": group,
    "source": source,
    "name": name,
    "sku": sku,
    "bar_code": barCode,
    "purchase_price": purchasePrice,
    "selling_price": sellingPrice,
    "opening_stock": openingStock,
    "stock_qty": stockQty,
    "alert_quantity": alertQuantity,
    "description": description,
    "image": image,
    "is_active": isActive,
    "unit_name": unitName,
    "unit_sub_name": unitSubName,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
