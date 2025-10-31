// lib/feature/reports/data/models/sales_report_model.dart
class SalesReportModel {
  final int sl;
  final String invoiceNo;
  final DateTime saleDate;
  final String customerName;
  final String salesBy;
  final double salesPrice;
  final double costPrice;
  final double profit;
  final double collectAmount;
  final double dueAmount;
  final int? customerId;
  final String paymentStatus;
  final String saleType;

  SalesReportModel({
    required this.sl,
    required this.invoiceNo,
    required this.saleDate,
    required this.customerName,
    required this.salesBy,
    required this.salesPrice,
    required this.costPrice,
    required this.profit,
    required this.collectAmount,
    required this.dueAmount,
    this.customerId,
    required this.paymentStatus,
    required this.saleType,
  });

  factory SalesReportModel.fromJson(Map<String, dynamic> json) {
    return SalesReportModel(
      sl: json['sl'] ?? 0,
      invoiceNo: json['invoice_no'] ?? '',
      saleDate: DateTime.parse(json['sale_date']),
      customerName: json['customer_name'] ?? '',
      salesBy: json['sales_by'] ?? '',
      salesPrice: (json['sales_price'] ?? 0).toDouble(),
      costPrice: (json['cost_price'] ?? 0).toDouble(),
      profit: (json['profit'] ?? 0).toDouble(),
      collectAmount: (json['collect_amount'] ?? 0).toDouble(),
      dueAmount: (json['due_amount'] ?? 0).toDouble(),
      customerId: json['customer_id'],
      paymentStatus: json['payment_status'] ?? '',
      saleType: json['sale_type'] ?? '',
    );
  }
}

class SalesReportSummary {
  final double totalSales;
  final double totalCost;
  final double totalProfit;
  final double totalCollected;
  final double totalDue;
  final double averageProfitMargin;
  final int totalTransactions;
  final Map<String, dynamic> dateRange;

  SalesReportSummary({
    required this.totalSales,
    required this.totalCost,
    required this.totalProfit,
    required this.totalCollected,
    required this.totalDue,
    required this.averageProfitMargin,
    required this.totalTransactions,
    required this.dateRange,
  });

  factory SalesReportSummary.fromJson(Map<String, dynamic> json) {
    return SalesReportSummary(
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      totalCost: (json['total_cost'] ?? 0).toDouble(),
      totalProfit: (json['total_profit'] ?? 0).toDouble(),
      totalCollected: (json['total_collected'] ?? 0).toDouble(),
      totalDue: (json['total_due'] ?? 0).toDouble(),
      averageProfitMargin: (json['average_profit_margin'] ?? 0).toDouble(),
      totalTransactions: json['total_transactions'] ?? 0,
      dateRange: json['date_range'] ?? {},
    );
  }
}

class SalesReportResponse {
  final List<SalesReportModel> report;
  final SalesReportSummary summary;
  final Map<String, dynamic> filtersApplied;

  SalesReportResponse({
    required this.report,
    required this.summary,
    required this.filtersApplied,
  });

  factory SalesReportResponse.fromJson(Map<String, dynamic> json) {
    final reportData = json['report'] ?? {};
    final results = reportData['results'] as List? ?? [];

    return SalesReportResponse(
      report: results.map((item) => SalesReportModel.fromJson(item)).toList(),
      summary: SalesReportSummary.fromJson(json['summary'] ?? {}),
      filtersApplied: json['filters_applied'] ?? {},
    );
  }
}