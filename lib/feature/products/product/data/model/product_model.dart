class ProductModel {
  final int? id;
  final int? company;
  final int? category;
  final int? unit;
  final int? brand;
  final int? group;
  final int? source;
  final Info? categoryInfo;
  final Info? unitInfo;
  final Info? brandInfo;
  final Info? groupInfo;
  final Info? sourceInfo;
  final String? name;
  final String? sku;
  final dynamic purchasePrice;
  final dynamic sellingPrice;
  final int? openingStock;
  final int? stockQty;
  final int? alertQuantity;
  final String? description;
  final dynamic image;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ⭐ New discount fields
  final bool? discountApplied;
  final String? discountType;
  final String? discountValue;
  final dynamic finalPrice;

  ProductModel({
    this.id,
    this.company,
    this.category,
    this.unit,
    this.brand,
    this.group,
    this.source,
    this.categoryInfo,
    this.unitInfo,
    this.brandInfo,
    this.groupInfo,
    this.sourceInfo,
    this.name,
    this.sku,
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
    this.discountApplied,
    this.discountType,
    this.discountValue,
    this.finalPrice,
  });

  @override
  String toString() => name ?? "";

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json["id"],
    company: json["company"],
    category: json["category"],
    unit: json["unit"],
    brand: json["brand"],
    group: json["group"],
    source: json["source"],
    categoryInfo:
    json["category_info"] == null ? null : Info.fromJson(json["category_info"]),
    unitInfo:
    json["unit_info"] == null ? null : Info.fromJson(json["unit_info"]),
    brandInfo:
    json["brand_info"] == null ? null : Info.fromJson(json["brand_info"]),
    groupInfo:
    json["group_info"] == null ? null : Info.fromJson(json["group_info"]),
    sourceInfo:
    json["source_info"] == null ? null : Info.fromJson(json["source_info"]),
    name: json["name"],
    sku: json["sku"],
    purchasePrice: json["purchase_price"],
    sellingPrice: json["selling_price"],
    openingStock: json["opening_stock"],
    stockQty: json["stock_qty"],
    alertQuantity: json["alert_quantity"],
    description: json["description"],
    image: json["image"],
    isActive: json["is_active"],
    createdAt:
    json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
    json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),

    discountApplied: json["discount_applied"],
    discountType: json["discount_type"],
    discountValue: json["discount_value"],
    finalPrice: json["final_price"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company": company,
    "category": category,
    "unit": unit,
    "brand": brand,
    "group": group,
    "source": source,
    "category_info": categoryInfo?.toJson(),
    "unit_info": unitInfo?.toJson(),
    "brand_info": brandInfo?.toJson(),
    "group_info": groupInfo?.toJson(),
    "source_info": sourceInfo?.toJson(),
    "name": name,
    "sku": sku,
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

    // ⭐ To JSON
    "discount_applied": discountApplied,
    "discount_type": discountType,
    "discount_value": discountValue,
    "final_price": finalPrice,
  };
}
class Info { final int? id; final String? name; Info({ this.id, this.name, }); factory Info.fromJson(Map<String, dynamic> json) => Info( id: json["id"], name: json["name"], ); Map<String, dynamic> toJson() => { "id": id, "name": name, }; }