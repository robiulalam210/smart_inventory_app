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
  final double? purchasePrice;
  final double? sellingPrice;
  final int? openingStock;
  final int? stockQty;
  final int? alertQuantity;
  final String? description;
  final dynamic image;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Info? categoryInfo;
  final UnitInfo? unitInfo;
  final Info? brandInfo;
  final Info? groupInfo;
  final Info? sourceInfo;
  final CreatedByInfo? createdByInfo;
  final dynamic stockStatus;

  // --- Discount Fields ---
  final bool? discountApplied;
  final String? discountType;
  final double? discountValue;
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
    return "$name(${unitInfo?.name})";
  }

  // Helper method to parse dynamic to double
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Handle string with quotes or without
      final cleaned = value.replaceAll('"', '').trim();
      return double.tryParse(cleaned);
    }
    return null;
  }

  // Helper method to parse dynamic to bool
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final str = value.toLowerCase();
      return str == 'true' || str == '1' || str == 'yes';
    }
    if (value is int) return value == 1;
    return null;
  }

  factory ProductModelStockModel.fromJson(Map<String, dynamic> json) {
    return ProductModelStockModel(
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
      purchasePrice: _parseDouble(json["purchase_price"]),
      sellingPrice: _parseDouble(json["selling_price"]),
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
          : UnitInfo.fromJson(json["unit_info"]),
      brandInfo: json["brand_info"] == null
          ? null
          : Info.fromJson(json["brand_info"]),
      groupInfo: json["group_info"] == null
          ? null
          : Info.fromJson(json["group_info"]),
      sourceInfo: json["source_info"] == null
          ? null
          : Info.fromJson(json["source_info"]),
      createdByInfo: json["created_by_info"] == null
          ? null
          : CreatedByInfo.fromJson(json["created_by_info"]),
      stockStatus: json["stock_status"],

      // --- Discount --- with proper parsing
      discountApplied: _parseBool(json["discount_applied"]) ??
          _parseBool(json["discount_applied_on"]) ??
          false,
      discountType: json["discount_type"]?.toString(),
      discountValue: _parseDouble(json["discount_value"]),
      finalPrice: _parseDouble(json["final_price"]),
    );
  }

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
    "brand_info": brandInfo?.toJson(),
    "group_info": groupInfo?.toJson(),
    "source_info": sourceInfo?.toJson(),
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

class UnitInfo {
  final int? id;
  final String? name;
  final String? code;

  UnitInfo({
    this.id,
    this.name,
    this.code,
  });

  factory UnitInfo.fromJson(Map<String, dynamic> json) => UnitInfo(
    id: json["id"],
    name: json["name"],
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
  };
}

class CreatedByInfo {
  final int? id;
  final String? username;
  final String? email;

  CreatedByInfo({
    this.id,
    this.username,
    this.email,
  });

  factory CreatedByInfo.fromJson(Map<String, dynamic> json) => CreatedByInfo(
    id: json["id"],
    username: json["username"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
  };
}