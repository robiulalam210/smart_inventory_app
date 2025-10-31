// lib/feature/report/data/models/low_stock_model.dart
import 'dart:ui';

import '../../../../core/configs/configs.dart';

class LowStockProduct {
  final int sl;
  final String productName;
  final double sellingPrice;
  final int alertQuantity;
  final int totalStockQuantity;
  final int totalSoldQuantity;
  final int productId;
  final String category;
  final String brand;

  LowStockProduct({
    required this.sl,
    required this.productName,
    required this.sellingPrice,
    required this.alertQuantity,
    required this.totalStockQuantity,
    required this.totalSoldQuantity,
    required this.productId,
    required this.category,
    required this.brand,
  });

  factory LowStockProduct.fromJson(Map<String, dynamic> json) {
    return LowStockProduct(
      sl: json['sl'] ?? 0,
      productName: json['product_name'] ?? '',
      sellingPrice: (json['selling_price'] ?? 0).toDouble(),
      alertQuantity: json['alert_quantity'] ?? 0,
      totalStockQuantity: json['total_stock_quantity'] ?? 0,
      totalSoldQuantity: json['total_sold_quantity'] ?? 0,
      productId: json['product_id'] ?? 0,
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
    );
  }

  // Helper method to determine stock status
  String get stockStatus {
    if (totalStockQuantity == 0) return 'Out of Stock';
    if (totalStockQuantity <= alertQuantity) return 'Low Stock';
    return 'In Stock';
  }

  Color get statusColor {
    if (totalStockQuantity == 0) return Colors.red;
    if (totalStockQuantity <= alertQuantity) return Colors.orange;
    return Colors.green;
  }

  // Calculate how much below alert level
  int get belowAlertLevel {
    return alertQuantity - totalStockQuantity;
  }
}

class LowStockSummary {
  final int totalLowStockItems;
  final int threshold;
  final int criticalItems;

  LowStockSummary({
    required this.totalLowStockItems,
    required this.threshold,
    required this.criticalItems,
  });

  factory LowStockSummary.fromJson(Map<String, dynamic> json) {
    return LowStockSummary(
      totalLowStockItems: json['total_low_stock_items'] ?? 0,
      threshold: json['threshold'] ?? 10,
      criticalItems: json['critical_items'] ?? 0,
    );
  }
}

class LowStockResponse {
  final List<LowStockProduct> report;
  final LowStockSummary summary;
  final Map<String, dynamic> filtersApplied;

  LowStockResponse({
    required this.report,
    required this.summary,
    required this.filtersApplied,
  });

  factory LowStockResponse.fromJson(Map<String, dynamic> json) {
    final reportData = json['report'] as List? ?? [];

    return LowStockResponse(
      report: reportData.map((item) => LowStockProduct.fromJson(item)).toList(),
      summary: LowStockSummary.fromJson(json['summary'] ?? {}),
      filtersApplied: json['filters_applied'] ?? {},
    );
  }
}