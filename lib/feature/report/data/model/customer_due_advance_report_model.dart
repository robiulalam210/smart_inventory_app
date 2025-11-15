// lib/feature/report/data/models/customer_due_advance_model.dart

import '../../../../core/configs/configs.dart';

class CustomerDueAdvance {
  final int sl;
  final String customerNo;
  final String customerName;
  final String phone;
  final String email;
  final double presentDue;
  final double presentAdvance;
  final int customerId;

  CustomerDueAdvance({
    required this.sl,
    required this.customerNo,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.presentDue,
    required this.presentAdvance,
    required this.customerId,
  });

  factory CustomerDueAdvance.fromJson(Map<String, dynamic> json) {
    return CustomerDueAdvance(
      sl: json['sl'] ?? 0,
      customerNo: json['customer_no']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      presentDue: (json['present_due'] ?? 0).toDouble(),
      presentAdvance: (json['present_advance'] ?? 0).toDouble(),
      customerId: json['customer_id'] ?? 0,
    );
  }

  // Calculate net balance (advance - due)
  double get netBalance {
    return presentAdvance - presentDue;
  }

  // Determine balance status
  String get balanceStatus {
    if (presentDue > 0) return 'Due';
    if (presentAdvance > 0) return 'Advance';
    return 'Settled';
  }

  Color get balanceStatusColor {
    if (presentDue > 0) return Colors.red;
    if (presentAdvance > 0) return Colors.green;
    return Colors.grey;
  }

  IconData get balanceStatusIcon {
    if (presentDue > 0) return Icons.arrow_downward;
    if (presentAdvance > 0) return Icons.arrow_upward;
    return Icons.check_circle;
  }

  String get formattedDue => presentDue > 0 ? '\$${presentDue.toStringAsFixed(2)}' : '-';
  String get formattedAdvance => presentAdvance > 0 ? '\$${presentAdvance.toStringAsFixed(2)}' : '-';
}

class CustomerDueAdvanceSummary {
  final int totalCustomers;
  final double totalDueAmount;
  final double totalAdvanceAmount;
  final double netBalance;
  final Map<String, dynamic> dateRange;

  CustomerDueAdvanceSummary({
    required this.totalCustomers,
    required this.totalDueAmount,
    required this.totalAdvanceAmount,
    required this.netBalance,
    required this.dateRange,
  });

  factory CustomerDueAdvanceSummary.fromJson(Map<String, dynamic> json) {
    return CustomerDueAdvanceSummary(
      totalCustomers: json['total_customers'] ?? 0,
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

class CustomerDueAdvanceResponse {
  final List<CustomerDueAdvance> report;
  final CustomerDueAdvanceSummary summary;

  CustomerDueAdvanceResponse({
    required this.report,
    required this.summary,
  });

  factory CustomerDueAdvanceResponse.fromJson(Map<String, dynamic> json) {
    final reportData = json['report'] ?? {};
    final results = reportData['results'] as List? ?? [];

    return CustomerDueAdvanceResponse(
      report: results.map((item) => CustomerDueAdvance.fromJson(item)).toList(),
      summary: CustomerDueAdvanceSummary.fromJson(json['summary'] ?? {}),
    );
  }
}