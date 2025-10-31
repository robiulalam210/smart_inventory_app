// lib/feature/report/data/models/profit_loss_model.dart
class ExpenseBreakdown {
  final String head;
  final String subhead;
  final double total;

  ExpenseBreakdown({
    required this.head,
    required this.subhead,
    required this.total,
  });

  factory ExpenseBreakdown.fromJson(Map<String, dynamic> json) {
    return ExpenseBreakdown(
      head: json['head'] ?? '',
      subhead: json['subhead'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

class ProfitLossSummary {
  final double totalSales;
  final double totalPurchase;
  final double totalExpenses;
  final double grossProfit;
  final double netProfit;
  final List<ExpenseBreakdown> expenseBreakdown;
  final Map<String, dynamic> dateRange;

  ProfitLossSummary({
    required this.totalSales,
    required this.totalPurchase,
    required this.totalExpenses,
    required this.grossProfit,
    required this.netProfit,
    required this.expenseBreakdown,
    required this.dateRange,
  });

  factory ProfitLossSummary.fromJson(Map<String, dynamic> json) {
    final breakdownData = json['expense_breakdown'] as List? ?? [];

    return ProfitLossSummary(
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      totalPurchase: (json['total_purchase'] ?? 0).toDouble(),
      totalExpenses: (json['total_expenses'] ?? 0).toDouble(),
      grossProfit: (json['gross_profit'] ?? 0).toDouble(),
      netProfit: (json['net_profit'] ?? 0).toDouble(),
      expenseBreakdown: breakdownData.map((item) => ExpenseBreakdown.fromJson(item)).toList(),
      dateRange: json['date_range'] ?? {},
    );
  }
}

class ProfitLossResponse {
  final ProfitLossSummary summary;
  final Map<String, dynamic> filtersApplied;

  ProfitLossResponse({
    required this.summary,
    required this.filtersApplied,
  });

  factory ProfitLossResponse.fromJson(Map<String, dynamic> json) {
    return ProfitLossResponse(
      summary: ProfitLossSummary.fromJson(json),
      filtersApplied: json['filters_applied'] ?? {},
    );
  }
}