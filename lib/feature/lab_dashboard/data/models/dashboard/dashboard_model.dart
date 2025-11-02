class DashboardData {
  final TodayMetrics todayMetrics;
  final ProfitLoss profitLoss;
  final FinancialSummary financialSummary;
  final StockAlerts stockAlerts;
  final RecentActivities recentActivities;

  DashboardData({
    required this.todayMetrics,
    required this.profitLoss,
    required this.financialSummary,
    required this.stockAlerts,
    required this.recentActivities,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      todayMetrics: TodayMetrics.fromJson(json['today_metrics']),
      profitLoss: ProfitLoss.fromJson(json['profit_loss']),
      financialSummary: FinancialSummary.fromJson(json['financial_summary']),
      stockAlerts: StockAlerts.fromJson(json['stock_alerts']),
      recentActivities: RecentActivities.fromJson(json['recent_activities']),
    );
  }
}

class TodayMetrics {
  final SalesData sales;
  final SalesReturnsData salesReturns;
  final PurchaseData purchases;
  final PurchaseReturnsData purchaseReturns;
  final ExpenseData expenses;

  TodayMetrics({
    required this.sales,
    required this.salesReturns,
    required this.purchases,
    required this.purchaseReturns,
    required this.expenses,
  });

  factory TodayMetrics.fromJson(Map<String, dynamic> json) {
    return TodayMetrics(
      sales: SalesData.fromJson(json['sales']),
      salesReturns: SalesReturnsData.fromJson(json['sales_returns']),
      purchases: PurchaseData.fromJson(json['purchases']),
      purchaseReturns: PurchaseReturnsData.fromJson(json['purchase_returns']),
      expenses: ExpenseData.fromJson(json['expenses']),
    );
  }
}

class SalesData {
  final double total;
  final int count;
  final int totalQuantity;
  final double totalDue;
  final double netTotal;

  SalesData({
    required this.total,
    required this.count,
    required this.totalQuantity,
    required this.totalDue,
    required this.netTotal,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      total: (json['total'] as num).toDouble(),
      count: json['count'] as int,
      totalQuantity: json['total_quantity'] as int,
      totalDue: (json['total_due'] as num).toDouble(),
      netTotal: (json['net_total'] as num).toDouble(),
    );
  }
}

class SalesReturnsData {
  final double totalAmount;
  final int totalQuantity;
  final int count;

  SalesReturnsData({
    required this.totalAmount,
    required this.totalQuantity,
    required this.count,
  });

  factory SalesReturnsData.fromJson(Map<String, dynamic> json) {
    return SalesReturnsData(
      totalAmount: (json['total_amount'] as num).toDouble(),
      totalQuantity: json['total_quantity'] as int,
      count: json['count'] as int,
    );
  }
}

class PurchaseData {
  final double total;
  final int count;
  final int totalQuantity;
  final double totalDue;
  final double netTotal;

  PurchaseData({
    required this.total,
    required this.count,
    required this.totalQuantity,
    required this.totalDue,
    required this.netTotal,
  });

  factory PurchaseData.fromJson(Map<String, dynamic> json) {
    return PurchaseData(
      total: (json['total'] as num).toDouble(),
      count: json['count'] as int,
      totalQuantity: json['total_quantity'] as int,
      totalDue: (json['total_due'] as num).toDouble(),
      netTotal: (json['net_total'] as num).toDouble(),
    );
  }
}

class PurchaseReturnsData {
  final double totalAmount;
  final int totalQuantity;
  final int count;

  PurchaseReturnsData({
    required this.totalAmount,
    required this.totalQuantity,
    required this.count,
  });

  factory PurchaseReturnsData.fromJson(Map<String, dynamic> json) {
    return PurchaseReturnsData(
      totalAmount: (json['total_amount'] as num).toDouble(),
      totalQuantity: json['total_quantity'] as int,
      count: json['count'] as int,
    );
  }
}

class ExpenseData {
  final double total;
  final int count;

  ExpenseData({
    required this.total,
    required this.count,
  });

  factory ExpenseData.fromJson(Map<String, dynamic> json) {
    return ExpenseData(
      total: (json['total'] as num).toDouble(),
      count: json['count'] as int,
    );
  }
}

class ProfitLoss {
  final double grossProfit;
  final double netProfit;
  final double profitMargin;

  ProfitLoss({
    required this.grossProfit,
    required this.netProfit,
    required this.profitMargin,
  });

  factory ProfitLoss.fromJson(Map<String, dynamic> json) {
    return ProfitLoss(
      grossProfit: (json['gross_profit'] as num).toDouble(),
      netProfit: (json['net_profit'] as num).toDouble(),
      profitMargin: (json['profit_margin'] as num).toDouble(),
    );
  }
}

class FinancialSummary {
  final double netSales;
  final double netPurchases;
  final double grossProfit;
  final double netProfit;
  final double totalCashFlow;

  FinancialSummary({
    required this.netSales,
    required this.netPurchases,
    required this.grossProfit,
    required this.netProfit,
    required this.totalCashFlow,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      netSales: (json['net_sales'] as num).toDouble(),
      netPurchases: (json['net_purchases'] as num).toDouble(),
      grossProfit: (json['gross_profit'] as num).toDouble(),
      netProfit: (json['net_profit'] as num).toDouble(),
      totalCashFlow: (json['total_cash_flow'] as num).toDouble(),
    );
  }
}

class StockAlerts {
  final int lowStock;
  final int outOfStock;

  StockAlerts({
    required this.lowStock,
    required this.outOfStock,
  });

  factory StockAlerts.fromJson(Map<String, dynamic> json) {
    return StockAlerts(
      lowStock: json['low_stock'] as int,
      outOfStock: json['out_of_stock'] as int,
    );
  }
}

class RecentActivities {
  final List<RecentSale> sales;
  final List<RecentPurchase> purchases;

  RecentActivities({
    required this.sales,
    required this.purchases,
  });

  factory RecentActivities.fromJson(Map<String, dynamic> json) {
    return RecentActivities(
      sales: (json['sales'] as List)
          .map((item) => RecentSale.fromJson(item))
          .toList(),
      purchases: (json['purchases'] as List)
          .map((item) => RecentPurchase.fromJson(item))
          .toList(),
    );
  }
}

class RecentSale {
  final String invoiceNo;
  final String customer;
  final double amount;
  final double dueAmount;
  final int quantity;
  final String date;

  RecentSale({
    required this.invoiceNo,
    required this.customer,
    required this.amount,
    required this.dueAmount,
    required this.quantity,
    required this.date,
  });

  factory RecentSale.fromJson(Map<String, dynamic> json) {
    return RecentSale(
      invoiceNo: json['invoice_no'] as String,
      customer: json['customer'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueAmount: (json['due_amount'] as num).toDouble(),
      quantity: json['quantity'] as int,
      date: json['date'] as String,
    );
  }
}

class RecentPurchase {
  final String invoiceNo;
  final String supplier;
  final double amount;
  final double dueAmount;
  final int quantity;
  final String date;

  RecentPurchase({
    required this.invoiceNo,
    required this.supplier,
    required this.amount,
    required this.dueAmount,
    required this.quantity,
    required this.date,
  });

  factory RecentPurchase.fromJson(Map<String, dynamic> json) {
    return RecentPurchase(
      invoiceNo: json['invoice_no'] as String,
      supplier: json['supplier'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueAmount: (json['due_amount'] as num).toDouble(),
      quantity: json['quantity'] as int,
      date: json['date'] as String,
    );
  }
}