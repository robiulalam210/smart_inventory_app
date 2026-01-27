class ProductModel {
  final int? id;
  final int? company;
  final int? createdBy;
  final int? category;
  final int? unit;
  final int? brand;
  final int? group;
  final int? source;
  final Info? categoryInfo;
  final UnitInfo? unitInfo;
  final Info? brandInfo;
  final Info? groupInfo;
  final Info? sourceInfo;
  final CreatedByInfo? createdByInfo;
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

  // Stock status fields
  final String? stockStatus;
  final String? stockStatusDisplay;
  final int? stockStatusCode;

  // ⭐ New discount fields
  final bool? discountApplied;
  final bool? discountAppliedOn;
  final String? discountType;
  final String? discountValue;
  final dynamic finalPrice;

  // Sale modes
  final List<SaleMode>? saleModes;

  ProductModel({
    this.id,
    this.company,
    this.createdBy,
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
    this.createdByInfo,
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

    // Stock status
    this.stockStatus,
    this.stockStatusDisplay,
    this.stockStatusCode,

    // Discount
    this.discountApplied,
    this.discountAppliedOn,
    this.discountType,
    this.discountValue,
    this.finalPrice,

    // Sale modes
    this.saleModes,
  });

  @override
  String toString() => name ?? "";

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json["id"],
    company: json["company"],
    createdBy: json["created_by"],
    category: json["category"],
    unit: json["unit"],
    brand: json["brand"],
    group: json["group"],
    source: json["source"],
    categoryInfo: json["category_info"] == null
        ? null
        : Info.fromJson(json["category_info"]),
    unitInfo: json["unit_info"] == null
        ? null
        : UnitInfo.fromJson(json["unit_info"]),
    brandInfo:
    json["brand_info"] == null ? null : Info.fromJson(json["brand_info"]),
    groupInfo:
    json["group_info"] == null ? null : Info.fromJson(json["group_info"]),
    sourceInfo: json["source_info"] == null
        ? null
        : Info.fromJson(json["source_info"]),
    createdByInfo: json["created_by_info"] == null
        ? null
        : CreatedByInfo.fromJson(json["created_by_info"]),
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
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),

    // Stock status
    stockStatus: json["stock_status"],
    stockStatusDisplay: json["stock_status_display"],
    stockStatusCode: json["stock_status_code"],

    // Discount
    discountApplied: json["discount_applied"],
    discountAppliedOn: json["discount_applied_on"],
    discountType: json["discount_type"],
    discountValue: json["discount_value"],
    finalPrice: json["final_price"],

    // Sale modes
    saleModes: json["sale_modes"] == null
        ? []
        : List<SaleMode>.from(
        json["sale_modes"].map((x) => SaleMode.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company": company,
    "created_by": createdBy,
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
    "created_by_info": createdByInfo?.toJson(),
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

    // Stock status
    "stock_status": stockStatus,
    "stock_status_display": stockStatusDisplay,
    "stock_status_code": stockStatusCode,

    // Discount
    "discount_applied": discountApplied,
    "discount_applied_on": discountAppliedOn,
    "discount_type": discountType,
    "discount_value": discountValue,
    "final_price": finalPrice,

    // Sale modes
    "sale_modes": saleModes == null
        ? []
        : List<dynamic>.from(saleModes!.map((x) => x.toJson())),
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

class UnitInfo extends Info {
  final String? code;

  UnitInfo({
    int? id,
    String? name,
    this.code,
  }) : super(id: id, name: name);

  factory UnitInfo.fromJson(Map<String, dynamic> json) => UnitInfo(
    id: json["id"],
    name: json["name"],
    code: json["code"],
  );

  @override
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
  final dynamic unitPrice;
  final dynamic flatPrice;
  final String? conversionFactor;
  final String? baseUnitName;
  final String? discountType;
  final dynamic discountValue;
  final bool? isActive;
  final List<Tier>? tiers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SaleMode({
    this.id,
    this.saleModeId,
    this.saleModeName,
    this.saleModeCode,
    this.priceType,
    this.unitPrice,
    this.flatPrice,
    this.conversionFactor,
    this.baseUnitName,
    this.discountType,
    this.discountValue,
    this.isActive,
    this.tiers,
    this.createdAt,
    this.updatedAt,
  });

  factory SaleMode.fromJson(Map<String, dynamic> json) => SaleMode(
    id: json["id"],
    saleModeId: json["sale_mode_id"],
    saleModeName: json["sale_mode_name"],
    saleModeCode: json["sale_mode_code"],
    priceType: json["price_type"],
    unitPrice: json["unit_price"],
    flatPrice: json["flat_price"],
    conversionFactor: json["conversion_factor"],
    baseUnitName: json["base_unit_name"],
    discountType: json["discount_type"],
    discountValue: json["discount_value"],
    isActive: json["is_active"],
    tiers: json["tiers"] == null
        ? []
        : List<Tier>.from(json["tiers"].map((x) => Tier.fromJson(x))),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sale_mode_id": saleModeId,
    "sale_mode_name": saleModeName,
    "sale_mode_code": saleModeCode,
    "price_type": priceType,
    "unit_price": unitPrice,
    "flat_price": flatPrice,
    "conversion_factor": conversionFactor,
    "base_unit_name": baseUnitName,
    "discount_type": discountType,
    "discount_value": discountValue,
    "is_active": isActive,
    "tiers": tiers == null
        ? []
        : List<dynamic>.from(tiers!.map((x) => x.toJson())),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Tier {
  final int? id;
  final String? minQuantity;
  final dynamic maxQuantity;
  final String? price;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? productSaleMode;

  Tier({
    this.id,
    this.minQuantity,
    this.maxQuantity,
    this.price,
    this.createdAt,
    this.updatedAt,
    this.productSaleMode,
  });

  factory Tier.fromJson(Map<String, dynamic> json) => Tier(
    id: json["id"],
    minQuantity: json["min_quantity"],
    maxQuantity: json["max_quantity"],
    price: json["price"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    productSaleMode: json["product_sale_mode"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "min_quantity": minQuantity,
    "max_quantity": maxQuantity,
    "price": price,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "product_sale_mode": productSaleMode,
  };
}

// Response wrapper model
class ProductListResponse {
  final bool? status;
  final String? message;
  final ProductListData? data;

  ProductListResponse({
    this.status,
    this.message,
    this.data,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) =>
      ProductListResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : ProductListData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class ProductListData {
  final List<ProductModel>? results;
  final Pagination? pagination;
  final List<dynamic>? filtersApplied;

  ProductListData({
    this.results,
    this.pagination,
    this.filtersApplied,
  });

  factory ProductListData.fromJson(Map<String, dynamic> json) => ProductListData(
    results: json["results"] == null
        ? []
        : List<ProductModel>.from(
        json["results"].map((x) => ProductModel.fromJson(x))),
    pagination: json["pagination"] == null
        ? null
        : Pagination.fromJson(json["pagination"]),
    filtersApplied: json["filters_applied"] == null
        ? []
        : List<dynamic>.from(json["filters_applied"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "results": results == null
        ? []
        : List<dynamic>.from(results!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
    "filters_applied": filtersApplied == null
        ? []
        : List<dynamic>.from(filtersApplied!.map((x) => x)),
  };
}

class Pagination {
  final int? count;
  final int? totalPages;
  final int? currentPage;
  final int? pageSize;
  final dynamic next;
  final dynamic previous;
  final int? from;
  final int? to;

  Pagination({
    this.count,
    this.totalPages,
    this.currentPage,
    this.pageSize,
    this.next,
    this.previous,
    this.from,
    this.to,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    count: json["count"],
    totalPages: json["total_pages"],
    currentPage: json["current_page"],
    pageSize: json["page_size"],
    next: json["next"],
    previous: json["previous"],
    from: json["from"],
    to: json["to"],
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "total_pages": totalPages,
    "current_page": currentPage,
    "page_size": pageSize,
    "next": next,
    "previous": previous,
    "from": from,
    "to": to,
  };
}