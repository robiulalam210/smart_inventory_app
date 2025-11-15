// lib/feature/report/data/models/supplier_ledger_model.dart

import '../../../../core/configs/configs.dart';

class SupplierLedger {
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
  final int supplierId;
  final String supplierName;

  SupplierLedger({
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
    required this.supplierId,
    required this.supplierName,
  });

  factory SupplierLedger.fromJson(Map<String, dynamic> json) {
    return SupplierLedger(
      sl: json['sl'] ?? 0,
      voucherNo: json['voucher_no'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      particular: json['particular'] ?? '',
      details: json['details'] ?? '',
      type: json['type'] ?? '',
      method: json['method'] ?? '',
      debit: (json['debit'] ?? 0).toDouble(),
      credit: (json['credit'] ?? 0).toDouble(),
      due: (json['due'] ?? 0).toDouble(),
      supplierId: json['supplier_id'] ?? 0,
      supplierName: json['supplier_name'] ?? '',
    );
  }

  // Helper methods for UI
  bool get isOpening => type == 'Opening';
  bool get isPurchase => type == 'Purchase';
  bool get isPayment => type == 'Payment';

  Color get typeColor {
    switch (type) {
      case 'Opening': return Colors.orange;
      case 'Purchase': return Colors.blue;
      case 'Payment': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'Opening': return Icons.account_balance_wallet;
      case 'Purchase': return Icons.shopping_cart;
      case 'Payment': return Icons.payment;
      default: return Icons.receipt;
    }
  }
}

class SupplierLedgerSummary {
  final int supplierId;
  final String supplierName;
  final double openingBalance;
  final double closingBalance;
  final double totalDebit;
  final double totalCredit;
  final int totalTransactions;
  final Map<String, dynamic> dateRange;

  SupplierLedgerSummary({
    required this.supplierId,
    required this.supplierName,
    required this.openingBalance,
    required this.closingBalance,
    required this.totalDebit,
    required this.totalCredit,
    required this.totalTransactions,
    required this.dateRange,
  });

  factory SupplierLedgerSummary.fromJson(Map<String, dynamic> json) {
    return SupplierLedgerSummary(
      supplierId: json['supplier_id'] ?? 0,
      supplierName: json['supplier_name'] ?? '',
      openingBalance: (json['opening_balance'] ?? 0).toDouble(),
      closingBalance: (json['closing_balance'] ?? 0).toDouble(),
      totalDebit: (json['total_debit'] ?? 0).toDouble(),
      totalCredit: (json['total_credit'] ?? 0).toDouble(),
      totalTransactions: json['total_transactions'] ?? 0,
      dateRange: json['date_range'] ?? {},
    );
  }

  // Helper methods
  double get netMovement => totalDebit - totalCredit;
  String get balanceStatus => closingBalance > 0 ? 'Due' : 'Advance';
  Color get balanceStatusColor => closingBalance > 0 ? Colors.red : Colors.green;
}

class SupplierLedgerResponse {
  final List<SupplierLedger> report;
  final SupplierLedgerSummary summary;

  SupplierLedgerResponse({
    required this.report,
    required this.summary,
  });

  factory SupplierLedgerResponse.fromJson(Map<String, dynamic> json) {
    final reportData = json['report'] ?? {};
    final results = reportData['results'] as List? ?? [];

    return SupplierLedgerResponse(
      report: results.map((item) => SupplierLedger.fromJson(item)).toList(),
      summary: SupplierLedgerSummary.fromJson(json['summary'] ?? {}),
    );
  }
}