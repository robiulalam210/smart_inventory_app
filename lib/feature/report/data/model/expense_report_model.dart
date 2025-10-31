// lib/feature/report/data/models/expense_report_model.dart
import 'dart:ui';

import '../../../../core/configs/configs.dart';

class ExpenseReport {
  final int sl;
  final int id;
  final String head;
  final String? subhead;
  final double amount;
  final String paymentMethod;
  final DateTime expenseDate;
  final String? note;

  ExpenseReport({
    required this.sl,
    required this.id,
    required this.head,
    required this.subhead,
    required this.amount,
    required this.paymentMethod,
    required this.expenseDate,
    required this.note,
  });

  factory ExpenseReport.fromJson(Map<String, dynamic> json) {
    return ExpenseReport(
      sl: json['sl'] ?? 0,
      id: json['id'] ?? 0,
      head: json['head'] ?? '',
      subhead: json['subhead'],
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paymentMethod: json['payment_method'] ?? '',
      expenseDate: DateTime.parse(json['expense_date']),
      note: json['note'],
    );
  }

  // Helper methods for UI
  Color get amountColor => Colors.red;
  IconData get amountIcon => Icons.arrow_upward;
}

class ExpenseReportSummary {
  final int totalCount;
  final double totalAmount;
  final Map<String, dynamic> dateRange;

  ExpenseReportSummary({
    required this.totalCount,
    required this.totalAmount,
    required this.dateRange,
  });

  factory ExpenseReportSummary.fromJson(Map<String, dynamic> json) {
    return ExpenseReportSummary(
      totalCount: json['total_count'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      dateRange: json['date_range'] ?? {},
    );
  }
}

class ExpenseReportResponse {
  final List<ExpenseReport> report;
  final ExpenseReportSummary summary;

  ExpenseReportResponse({
    required this.report,
    required this.summary,
  });

  factory ExpenseReportResponse.fromJson(Map<String, dynamic> json) {
    final reportData = json['report'] ?? {};
    final results = reportData['results'] as List? ?? [];

    return ExpenseReportResponse(
      report: results.map((item) => ExpenseReport.fromJson(item)).toList(),
      summary: ExpenseReportSummary.fromJson(json['summary'] ?? {}),
    );
  }
}