// To parse this JSON data, do
//
//     final productModelStockModel = productModelStockModelFromJson(jsonString);

import 'dart:convert';

List<ProductModelStockModel> productModelStockModelFromJson(String str) => List<ProductModelStockModel>.from(json.decode(str).map((x) => ProductModelStockModel.fromJson(x)));

String productModelStockModelToJson(List<ProductModelStockModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductModelStockModel {
  final int? id;
  final int? company;
  final int? createdBy;
  final String? name;
  final String? sku;
  final int? category;
  final int? unit;
  final dynamic brand;
  final dynamic group;
  final dynamic source;
  final String? purchasePrice;
  final String? sellingPrice;
  final int? openingStock;
  final int? stockQty;
  final int? alertQuantity;
  final String? description;
  final dynamic image;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Info? categoryInfo;
  final Info? unitInfo;
  final dynamic brandInfo;
  final dynamic groupInfo;
  final dynamic sourceInfo;
  final CreatedByInfo? createdByInfo;
  final dynamic stockStatus;

  // --- Discount Fields ---
  final bool? discountApplied;
  final String? discountType;
  final String? discountValue;
  final double? finalPrice;

  ProductModelStockModel({
    this.id,
    this.company,
    this.createdBy,
    this.name,
    this.sku,
    this.category,
    this.unit,
    this.brand,
    this.group,
    this.source,
    this.purchasePrice,
    this.sellingPrice,
    this.openingStock,
    this.stockQty,
    this.alertQuantity,
    this.description,
    this.image,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.categoryInfo,
    this.unitInfo,
    this.brandInfo,
    this.groupInfo,
    this.sourceInfo,
    this.createdByInfo,
    this.stockStatus,
    this.discountApplied,
    this.discountType,
    this.discountValue,
    this.finalPrice,
  });

  @override
  String toString() {
    // TODO: implement toString
    return name??"";
  }
  factory ProductModelStockModel.fromJson(Map<String, dynamic> json) =>
      ProductModelStockModel(
        id: json["id"],
        company: json["company"],
        createdBy: json["created_by"],
        name: json["name"],
        sku: json["sku"],
        category: json["category"],
        unit: json["unit"],
        brand: json["brand"],
        group: json["group"],
        source: json["source"],
        purchasePrice: json["purchase_price"],
        sellingPrice: json["selling_price"],
        openingStock: json["opening_stock"],
        stockQty: json["stock_qty"],
        alertQuantity: json["alert_quantity"],
        description: json["description"],
        image: json["image"],
        isActive: json["is_active"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        categoryInfo: json["category_info"] == null
            ? null
            : Info.fromJson(json["category_info"]),
        unitInfo: json["unit_info"] == null
            ? null
            : Info.fromJson(json["unit_info"]),
        brandInfo: json["brand_info"],
        groupInfo: json["group_info"],
        sourceInfo: json["source_info"],
        createdByInfo: json["created_by_info"] == null
            ? null
            : CreatedByInfo.fromJson(json["created_by_info"]),
        stockStatus: json["stock_status"],

        // --- Discount ---
        discountApplied: json["discount_applied"],
        discountType: json["discount_type"],
        discountValue: json["discount_value"],
        finalPrice: json["final_price"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company": company,
    "created_by": createdBy,
    "name": name,
    "sku": sku,
    "category": category,
    "unit": unit,
    "brand": brand,
    "group": group,
    "source": source,
    "purchase_price": purchasePrice,
    "selling_price": sellingPrice,
    "opening_stock": openingStock,
    "stock_qty": stockQty,
    "alert_quantity": alertQuantity,
    "description": description,
    "image": image,
    "is_active": isActive,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "category_info": categoryInfo?.toJson(),
    "unit_info": unitInfo?.toJson(),
    "brand_info": brandInfo,
    "group_info": groupInfo,
    "source_info": sourceInfo,
    "created_by_info": createdByInfo?.toJson(),
    "stock_status": stockStatus,

    // --- Discount ---
    "discount_applied": discountApplied,
    "discount_type": discountType,
    "discount_value": discountValue,
    "final_price": finalPrice,
  };
}

class Info {
  final int? id;
  final String? name;

  Info({
    this.id,
    this.name,
  });

  factory Info.fromJson(Map<String, dynamic> json) => Info(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class CreatedByInfo {
  final int? id;
  final String? username;

  CreatedByInfo({
    this.id,
    this.username,
  });

  factory CreatedByInfo.fromJson(Map<String, dynamic> json) => CreatedByInfo(
    id: json["id"],
    username: json["username"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
  };
}
