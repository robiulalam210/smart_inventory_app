// lib/feature/report/data/models/customer_ledger_model.dart
import 'dart:ui';

import '../../../../core/configs/configs.dart';

class CustomerLedgerTransaction {
  final int sl;
  final String voucherNo;
  final DateTime date;
  final String particular;
  final String details;
  final String type;
  final String method;
  final double debit;
  final double credit;
  final double due;
  final int customerId;
  final String customerName;

  CustomerLedgerTransaction({
    required this.sl,
    required this.voucherNo,
    required this.date,
    required this.particular,
    required this.details,
    required this.type,
    required this.method,
    required this.debit,
    required this.credit,
    required this.due,
    required this.customerId,
    required this.customerName,
  });

  factory CustomerLedgerTransaction.fromJson(Map<String, dynamic> json) {
    return CustomerLedgerTransaction(
      sl: json['sl'] ?? 0,
      voucherNo: json['voucher_no'] ?? '',
      date: DateTime.parse(json['date']),
      particular: json['particular'] ?? '',
      details: json['details'] ?? '',
      type: json['type'] ?? '',
      method: json['method'] ?? '',
      debit: (json['debit'] ?? 0).toDouble(),
      credit: (json['credit'] ?? 0).toDouble(),
      due: (json['due'] ?? 0).toDouble(),
      customerId: json['customer_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
    );
  }

  // Helper method to determine transaction type color
  Color get typeColor {
    switch (type.toLowerCase()) {
      case 'sale':
        return Colors.red;
      case 'payment':
        return Colors.green;
      case 'return':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get transaction icon
  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'sale':
        return Icons.shopping_cart;
      case 'payment':
        return Icons.payment;
      case 'return':
        return Icons.assignment_return;
      default:
        return Icons.receipt;
    }
  }
}

class CustomerLedgerSummary {
  final int customerId;
  final String customerName;
  final double closingBalance;
  final int totalTransactions;
  final Map<String, dynamic> dateRange;

  CustomerLedgerSummary({
    required this.customerId,
    required this.customerName,
    required this.closingBalance,
    required this.totalTransactions,
    required this.dateRange,
  });

  factory CustomerLedgerSummary.fromJson(Map<String, dynamic> json) {
    return CustomerLedgerSummary(
      customerId: json['customer_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      closingBalance: (json['closing_balance'] ?? 0).toDouble(),
      totalTransactions: json['total_transactions'] ?? 0,
      dateRange: json['date_range'] ?? {},
    );
  }

  // Calculate opening balance (first transaction's due - first transaction amount)
  double calculateOpeningBalance(List<CustomerLedgerTransaction> transactions) {
    if (transactions.isEmpty) return 0.0;
    final firstTransaction = transactions.first;
    return firstTransaction.due - (firstTransaction.debit - firstTransaction.credit);
  }
}

class CustomerLedgerResponse {
  final List<CustomerLedgerTransaction> report;
  final CustomerLedgerSummary summary;
  final Map<String, dynamic> filtersApplied;

  CustomerLedgerResponse({
    required this.report,
    required this.summary,
    required this.filtersApplied,
  });

  factory CustomerLedgerResponse.fromJson(Map<String, dynamic> json) {
    final reportData = json['report'] ?? {};
    final results = reportData['results'] as List? ?? [];

    return CustomerLedgerResponse(
      report: results.map((item) => CustomerLedgerTransaction.fromJson(item)).toList(),
      summary: CustomerLedgerSummary.fromJson(json['summary'] ?? {}),
      filtersApplied: json['filters_applied'] ?? {},
    );
  }
}