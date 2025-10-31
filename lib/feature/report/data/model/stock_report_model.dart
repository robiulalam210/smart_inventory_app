// lib/feature/report/data/models/stock_report_model.dart
import '../../../../core/configs/configs.dart';

class StockProduct {
  final int sl;
  final int productNo;
  final String productName;
  final String category;
  final String brand;
  final double avgPurchasePrice;
  final double sellingPrice;
  final int currentStock;
  final double value;

  StockProduct({
    required this.sl,
    required this.productNo,
    required this.productName,
    required this.category,
    required this.brand,
    required this.avgPurchasePrice,
    required this.sellingPrice,
    required this.currentStock,
    required this.value,
  });

  factory StockProduct.fromJson(Map<String, dynamic> json) {
    return StockProduct(
      sl: json['sl'] ?? 0,
      productNo: json['product_no'] ?? 0,
      productName: json['product_name'] ?? '',
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      avgPurchasePrice: (json['avg_purchase_price'] ?? 0).toDouble(),
      sellingPrice: (json['selling_price'] ?? 0).toDouble(),
      currentStock: json['current_stock'] ?? 0,
      value: (json['value'] ?? 0).toDouble(),
    );
  }

  // Calculate profit margin percentage
  double get profitMargin {
    if (sellingPrice == 0) return 0;
    return ((sellingPrice - avgPurchasePrice) / sellingPrice * 100);
  }

  // Calculate total potential value at selling price
  double get potentialValue {
    return currentStock * sellingPrice;
  }

  // Stock status indicator
  String get stockStatus {
    if (currentStock == 0) return 'Out of Stock';
    if (currentStock <= 10) return 'Low Stock';
    if (currentStock <= 25) return 'Medium Stock';
    return 'High Stock';
  }

  Color get stockStatusColor {
    if (currentStock == 0) return Colors.red;
    if (currentStock <= 10) return Colors.orange;
    if (currentStock <= 25) return Colors.blue;
    return Colors.green;
  }

  // Profitability indicator
  String get profitability {
    if (profitMargin > 50) return 'High';
    if (profitMargin > 20) return 'Medium';
    if (profitMargin > 0) return 'Low';
    return 'Loss';
  }

  Color get profitabilityColor {
    if (profitMargin > 50) return Colors.green;
    if (profitMargin > 20) return Colors.blue;
    if (profitMargin > 0) return Colors.orange;
    return Colors.red;
  }
}

class StockSummary {
  final int totalProducts;
  final double totalStockValue;
  final int totalStockQuantity;

  StockSummary({
    required this.totalProducts,
    required this.totalStockValue,
    required this.totalStockQuantity,
  });

  factory StockSummary.fromJson(Map<String, dynamic> json) {
    return StockSummary(
      totalProducts: json['total_products'] ?? 0,
      totalStockValue: (json['total_stock_value'] ?? 0).toDouble(),
      totalStockQuantity: json['total_stock_quantity'] ?? 0,
    );
  }

  // Calculate average stock value per product
  double get averageStockValue {
    return totalProducts > 0 ? totalStockValue / totalProducts : 0;
  }

  // Calculate average quantity per product
  double get averageQuantity {
    return totalProducts > 0 ? totalStockQuantity / totalProducts : 0;
  }
}

class StockReportResponse {
  final List<StockProduct> report;
  final StockSummary summary;
  final Map<String, dynamic> filtersApplied;

  StockReportResponse({
    required this.report,
    required this.summary,
    required this.filtersApplied,
  });

  factory StockReportResponse.fromJson(Map<String, dynamic> json) {
    final reportData = json['report'] ?? {};
    final results = reportData['results'] as List? ?? [];

    return StockReportResponse(
      report: results.map((item) => StockProduct.fromJson(item)).toList(),
      summary: StockSummary.fromJson(json['summary'] ?? {}),
      filtersApplied: json['filters_applied'] ?? {},
    );
  }
}