// lib/feature/report/data/models/purchase_report_model.dart
class PurchaseReportModel {
  final int sl;
  final String invoiceNo;
  final DateTime purchaseDate;
  final String supplier;
  final double netTotal;
  final double paidTotal;
  final double dueTotal;
  final int supplierId;
  final String status;
  final String paymentStatus;
  final String location;

  PurchaseReportModel({
    required this.sl,
    required this.invoiceNo,
    required this.purchaseDate,
    required this.supplier,
    required this.netTotal,
    required this.paidTotal,
    required this.dueTotal,
    required this.supplierId,
    required this.status,
    required this.paymentStatus,
    required this.location,
  });

  factory PurchaseReportModel.fromJson(Map<String, dynamic> json) {
    return PurchaseReportModel(
      sl: json['sl'] ?? 0,
      invoiceNo: json['invoice_no'] ?? '',
      purchaseDate: DateTime.parse(json['purchase_date']),
      supplier: json['supplier'] ?? '',
      netTotal: (json['net_total'] ?? 0).toDouble(),
      paidTotal: (json['paid_total'] ?? 0).toDouble(),
      dueTotal: (json['due_total'] ?? 0).toDouble(),
      supplierId: json['supplier_id'] ?? 0,
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      location: json['location'] ?? '',
    );
  }
}

class PurchaseReportSummary {
  final double totalPurchases;
  final double totalPaid;
  final double totalDue;
  final int totalTransactions;
  final Map<String, dynamic> dateRange;

  PurchaseReportSummary({
    required this.totalPurchases,
    required this.totalPaid,
    required this.totalDue,
    required this.totalTransactions,
    required this.dateRange,
  });

  factory PurchaseReportSummary.fromJson(Map<String, dynamic> json) {
    return PurchaseReportSummary(
      totalPurchases: (json['total_purchases'] ?? 0).toDouble(),
      totalPaid: (json['total_paid'] ?? 0).toDouble(),
      totalDue: (json['total_due'] ?? 0).toDouble(),
      totalTransactions: json['total_transactions'] ?? 0,
      dateRange: json['date_range'] ?? {},
    );
  }
}

class PurchaseReportResponse {
  final List<PurchaseReportModel> report;
  final PurchaseReportSummary summary;
  final Map<String, dynamic> filtersApplied;

  PurchaseReportResponse({
    required this.report,
    required this.summary,
    required this.filtersApplied,
  });

  factory PurchaseReportResponse.fromJson(Map<String, dynamic> json) {
    final reportData = json['report'] ?? {};
    final results = reportData['results'] as List? ?? [];

    return PurchaseReportResponse(
      report: results.map((item) => PurchaseReportModel.fromJson(item)).toList(),
      summary: PurchaseReportSummary.fromJson(json['summary'] ?? {}),
      filtersApplied: json['filters_applied'] ?? {},
    );
  }
}