// To parse this JSON data, do
//
//     final productModelStockModel = productModelStockModelFromJson(jsonString);

import 'dart:convert';

List<ProductModelStockModel> productModelStockModelFromJson(String str) => List<ProductModelStockModel>.from(json.decode(str)['data'].map((x) => ProductModelStockModel.fromJson(x)));

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
  final String? stockStatus;
  final String? stockStatusDisplay;
  final int? stockStatusCode;

  // --- Discount Fields ---
  final bool? discountApplied;
  final bool? discountAppliedOn;
  final String? discountType;
  final double? discountValue;
  final double? finalPrice;

  // --- Sale Modes ---
  final List<SaleMode>? saleModes;

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
    this.stockStatusDisplay,
    this.stockStatusCode,
    this.discountApplied,
    this.discountAppliedOn,
    this.discountType,
    this.discountValue,
    this.finalPrice,
    this.saleModes,
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
      stockStatus: json["stock_status"]?.toString(),
      stockStatusDisplay: json["stock_status_display"]?.toString(),
      stockStatusCode: json["stock_status_code"],
      discountApplied: _parseBool(json["discount_applied"]),
      discountAppliedOn: _parseBool(json["discount_applied_on"]),
      discountType: json["discount_type"]?.toString(),
      discountValue: _parseDouble(json["discount_value"]),
      finalPrice: _parseDouble(json["final_price"]),
      saleModes: json["sale_modes"] == null
          ? null
          : List<SaleMode>.from(json["sale_modes"].map((x) => SaleMode.fromJson(x))),
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
    "stock_status_display": stockStatusDisplay,
    "stock_status_code": stockStatusCode,
    "discount_applied": discountApplied,
    "discount_applied_on": discountAppliedOn,
    "discount_type": discountType,
    "discount_value": discountValue,
    "final_price": finalPrice,
    "sale_modes": saleModes == null
        ? null
        : List<SaleMode>.from(saleModes!.map((x) => x.toJson())),
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

class SaleMode {
  final int? id;
  final int? saleModeId;
  final String? saleModeName;
  final String? saleModeCode;
  final String? priceType;
  final double? unitPrice;
  final double? flatPrice;
  final String? discountType;
  final double? discountValue;
  final bool? isActive;
  final List<SaleModeTier>? tiers;
  final double? conversionFactor; // Add this
  final String? baseUnitName; // Add this

  SaleMode({
    this.id,
    this.saleModeId,
    this.saleModeName,
    this.saleModeCode,
    this.priceType,
    this.unitPrice,
    this.flatPrice,
    this.discountType,
    this.discountValue,
    this.isActive,
    this.tiers,
    this.conversionFactor, // Add this
    this.baseUnitName, // Add this
  });

  @override
  String toString() {
    return "${saleModeName} Price: ${unitPrice}, Conv: ${conversionFactor}, Base: ${baseUnitName}";
  }

  factory SaleMode.fromJson(Map<String, dynamic> json) {
    return SaleMode(
      id: json["id"],
      saleModeId: json["sale_mode_id"],
      saleModeName: json["sale_mode_name"]?.toString(),
      saleModeCode: json["sale_mode_code"]?.toString(),
      priceType: json["price_type"]?.toString(),
      unitPrice: ProductModelStockModel._parseDouble(json["unit_price"]),
      flatPrice: ProductModelStockModel._parseDouble(json["flat_price"]),
      discountType: json["discount_type"]?.toString(),
      discountValue: ProductModelStockModel._parseDouble(json["discount_value"]),
      isActive: ProductModelStockModel._parseBool(json["is_active"]),
      tiers: json['tiers'] != null
          ? List<SaleModeTier>.from(
          json['tiers'].map((x) => SaleModeTier.fromJson(x)))
          : null,
      conversionFactor: ProductModelStockModel._parseDouble(json["conversion_factor"]), // Add this
      baseUnitName: json["base_unit_name"]?.toString(), // Add this
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "sale_mode_id": saleModeId,
    "sale_mode_name": saleModeName,
    "sale_mode_code": saleModeCode,
    "price_type": priceType,
    "unit_price": unitPrice,
    "flat_price": flatPrice,
    "discount_type": discountType,
    "discount_value": discountValue,
    "is_active": isActive,
    "conversion_factor": conversionFactor, // Add this
    "base_unit_name": baseUnitName, // Add this
  };
}



class SaleModeTier {
  final int? id;
  final String minQuantity;
  final String maxQuantity;
  final String price;

  SaleModeTier({
    this.id,
    required this.minQuantity,
    required this.maxQuantity,
    required this.price,
  });

  factory SaleModeTier.fromJson(Map<String, dynamic> json) {
    return SaleModeTier(
      id: json['id'] as int?,
      minQuantity: json['min_quantity'].toString(),
      maxQuantity: json['max_quantity'].toString(),
      price: json['price'].toString(),
    );
  }
}