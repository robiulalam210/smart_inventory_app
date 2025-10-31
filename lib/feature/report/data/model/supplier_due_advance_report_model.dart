// lib/feature/report/data/models/supplier_due_advance_model.dart
import '../../../../core/configs/configs.dart';

class SupplierDueAdvance {
  final int sl;
  final int supplierNo;
  final String supplierName;
  final String phone;
  final String email;
  final double presentDue;
  final double presentAdvance;
  final int supplierId;

  SupplierDueAdvance({
    required this.sl,
    required this.supplierNo,
    required this.supplierName,
    required this.phone,
    required this.email,
    required this.presentDue,
    required this.presentAdvance,
    required this.supplierId,
  });

  factory SupplierDueAdvance.fromJson(Map<String, dynamic> json) {
    return SupplierDueAdvance(
      sl: json['sl'] ?? 0,
      supplierNo: json['supplier_no'] ?? 0,
      supplierName: json['supplier_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      presentDue: (json['present_due'] ?? 0).toDouble(),
      presentAdvance: (json['present_advance'] ?? 0).toDouble(),
      supplierId: json['supplier_id'] ?? 0,
    );
  }

  // Calculate net balance (advance - due)
  double get netBalance {
    return presentAdvance - presentDue;
  }

  // Determine balance status
  String get balanceStatus {
    if (netBalance > 0) return 'Advance';
    if (netBalance < 0) return 'Due';
    return 'Settled';
  }

  Color get balanceStatusColor {
    if (netBalance > 0) return Colors.green;
    if (netBalance < 0) return Colors.red;
    return Colors.grey;
  }

  IconData get balanceStatusIcon {
    if (netBalance > 0) return Icons.arrow_upward;
    if (netBalance < 0) return Icons.arrow_downward;
    return Icons.check_circle;
  }
}

class SupplierDueAdvanceSummary {
  final int totalSuppliers;
  final double totalDueAmount;
  final double totalAdvanceAmount;
  final double netBalance;
  final Map<String, dynamic> dateRange;

  SupplierDueAdvanceSummary({
    required this.totalSuppliers,
    required this.totalDueAmount,
    required this.totalAdvanceAmount,
    required this.netBalance,
    required this.dateRange,
  });

  factory SupplierDueAdvanceSummary.fromJson(Map<String, dynamic> json) {
    return SupplierDueAdvanceSummary(
      totalSuppliers: json['total_suppliers'] ?? 0,
      totalDueAmount: (json['total_due_amount'] ?? 0).toDouble(),
      totalAdvanceAmount: (json['total_advance_amount'] ?? 0).toDouble(),
      netBalance: (json['net_balance'] ?? 0).toDouble(),
      dateRange: json['date_range'] ?? {},
    );
  }

  // Determine overall balance status
  String get overallStatus {
    if (netBalance > 0) return 'Net Advance';
    if (netBalance < 0) return 'Net Due';
    return 'Balanced';
  }

  Color get overallStatusColor {
    if (netBalance > 0) return Colors.green;
    if (netBalance < 0) return Colors.red;
    return Colors.blue;
  }
}

class SupplierDueAdvanceResponse {
  final List<SupplierDueAdvance> report;
  final SupplierDueAdvanceSummary summary;
  final Map<String, dynamic> filtersApplied;

  SupplierDueAdvanceResponse({
    required this.report,
    required this.summary,
    required this.filtersApplied,
  });

  factory SupplierDueAdvanceResponse.fromJson(Map<String, dynamic> json) {
    final reportData = json['report'] ?? {};
    final results = reportData['results'] as List? ?? [];

    return SupplierDueAdvanceResponse(
      report: results.map((item) => SupplierDueAdvance.fromJson(item)).toList(),
      summary: SupplierDueAdvanceSummary.fromJson(json['summary'] ?? {}),
      filtersApplied: json['filters_applied'] ?? {},
    );
  }
}