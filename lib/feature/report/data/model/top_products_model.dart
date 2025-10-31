// lib/feature/report/data/models/top_products_model.dart
class TopProductModel {
  final int sl;
  final String productName;
  final double sellingPrice;
  final int totalSoldQuantity;
  final double totalSoldPrice;
  final int productId;

  TopProductModel({
    required this.sl,
    required this.productName,
    required this.sellingPrice,
    required this.totalSoldQuantity,
    required this.totalSoldPrice,
    required this.productId,
  });

  factory TopProductModel.fromJson(Map<String, dynamic> json) {
    return TopProductModel(
      sl: json['sl'] ?? 0,
      productName: json['product_name'] ?? '',
      sellingPrice: (json['selling_price'] ?? 0).toDouble(),
      totalSoldQuantity: json['total_sold_quantity'] ?? 0,
      totalSoldPrice: (json['total_sold_price'] ?? 0).toDouble(),
      productId: json['product_id'] ?? 0,
    );
  }
}

class TopProductsSummary {
  final int totalProducts;
  final int totalQuantitySold;
  final double totalSales;
  final Map<String, dynamic> dateRange;

  TopProductsSummary({
    required this.totalProducts,
    required this.totalQuantitySold,
    required this.totalSales,
    required this.dateRange,
  });

  factory TopProductsSummary.fromJson(Map<String, dynamic> json) {
    return TopProductsSummary(
      totalProducts: json['total_products'] ?? 0,
      totalQuantitySold: json['total_quantity_sold'] ?? 0,
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      dateRange: json['date_range'] ?? {},
    );
  }
}

class TopProductsResponse {
  final List<TopProductModel> report;
  final TopProductsSummary summary;
  final Map<String, dynamic> filtersApplied;

  TopProductsResponse({
    required this.report,
    required this.summary,
    required this.filtersApplied,
  });

  factory TopProductsResponse.fromJson(Map<String, dynamic> json) {
    final reportData = json['report'] as List? ?? [];

    return TopProductsResponse(
      report: reportData.map((item) => TopProductModel.fromJson(item)).toList(),
      summary: TopProductsSummary.fromJson(json['summary'] ?? {}),
      filtersApplied: json['filters_applied'] ?? {},
    );
  }
}