// To parse this JSON data, do
//
//     final branchReportModel = branchReportModelFromJson(jsonString);

import 'dart:convert';

BranchReportModel branchReportModelFromJson(String str) => BranchReportModel.fromJson(json.decode(str));

String branchReportModelToJson(BranchReportModel data) => json.encode(data.toJson());

class BranchReportModel {
  bool? success;
  Data? data;

  BranchReportModel({
    this.success,
    this.data,
  });

  factory BranchReportModel.fromJson(Map<String, dynamic> json) => BranchReportModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data?.toJson(),
  };
}

class Data {
  List<ProductBranch>? products;
  Summary? summary;

  Data({
    this.products,
    this.summary,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    products: json["products"] == null ? [] : List<ProductBranch>.from(json["products"]!.map((x) => ProductBranch.fromJson(x))),
    summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
  );

  Map<String, dynamic> toJson() => {
    "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
    "summary": summary?.toJson(),
  };
}

class ProductBranch {
  int? id;
  String? name;
  String? image;
  String? purchasePrice;
  String? barCode;
  String? categoryName;
  String? price;
  String? stock;
  String? sold;
  int? status;
  int? openingStock;
  String? openingCost;
  String? brandName;
  String? averagePurchasePrice;
  String? averageSalePrice;
  String? salesAmount;
  String? stockValue;

  ProductBranch({
    this.id,
    this.name,
    this.image,
    this.purchasePrice,
    this.barCode,
    this.categoryName,
    this.price,
    this.stock,
    this.sold,
    this.status,
    this.openingStock,
    this.openingCost,
    this.brandName,
    this.averagePurchasePrice,
    this.averageSalePrice,
    this.salesAmount,
    this.stockValue,
  });

  factory ProductBranch.fromJson(Map<String, dynamic> json) => ProductBranch(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    purchasePrice: json["purchase_price"],
    barCode: json["bar_code"],
    categoryName: json["category_name"],
    price: json["price"],
    stock: json["stock"],
    sold: json["sold"],
    status: json["status"],
    openingStock: json["opening_stock"],
    openingCost: json["opening_cost"],
    brandName: json["brand_name"],
    averagePurchasePrice: json["average_purchase_price"],
    averageSalePrice: json["average_sale_price"],
    salesAmount: json["sales_amount"],
    stockValue: json["stock_value"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "purchase_price": purchasePrice,
    "bar_code": barCode,
    "category_name": categoryName,
    "price": price,
    "stock": stock,
    "sold": sold,
    "status": status,
    "opening_stock": openingStock,
    "opening_cost": openingCost,
    "brand_name": brandName,
    "average_purchase_price": averagePurchasePrice,
    "average_sale_price": averageSalePrice,
    "sales_amount": salesAmount,
    "stock_value": stockValue,
  };
}

class Summary {
  String? totalSales;
  int? totalStock;
  String? totalStockValue;

  Summary({
    this.totalSales,
    this.totalStock,
    this.totalStockValue,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    totalSales: json["total_sales"],
    totalStock: json["total_stock"],
    totalStockValue: json["total_stock_value"],
  );

  Map<String, dynamic> toJson() => {
    "total_sales": totalSales,
    "total_stock": totalStock,
    "total_stock_value": totalStockValue,
  };
}
