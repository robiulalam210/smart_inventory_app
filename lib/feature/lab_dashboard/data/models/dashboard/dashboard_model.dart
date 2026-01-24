// To parse this JSON data, do
//
//     final dashboardData = dashboardDataFromJson(jsonString);

import 'dart:convert';

DashboardData dashboardDataFromJson(String str) => DashboardData.fromJson(json.decode(str));

String dashboardDataToJson(DashboardData data) => json.encode(data.toJson());

class DashboardData {
  final TodayMetrics? todayMetrics;
  final ProfitLoss? profitLoss;
  final FinancialSummary? financialSummary;
  final StockAlerts? stockAlerts;
  final RecentActivities? recentActivities;
  final DateFilterInfo? dateFilterInfo;

  DashboardData({
    this.todayMetrics,
    this.profitLoss,
    this.financialSummary,
    this.stockAlerts,
    this.recentActivities,
    this.dateFilterInfo,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    todayMetrics: json["today_metrics"] == null ? null : TodayMetrics.fromJson(json["today_metrics"]),
    profitLoss: json["profit_loss"] == null ? null : ProfitLoss.fromJson(json["profit_loss"]),
    financialSummary: json["financial_summary"] == null ? null : FinancialSummary.fromJson(json["financial_summary"]),
    stockAlerts: json["stock_alerts"] == null ? null : StockAlerts.fromJson(json["stock_alerts"]),
    recentActivities: json["recent_activities"] == null ? null : RecentActivities.fromJson(json["recent_activities"]),
    dateFilterInfo: json["date_filter_info"] == null ? null : DateFilterInfo.fromJson(json["date_filter_info"]),
  );

  Map<String, dynamic> toJson() => {
    "today_metrics": todayMetrics?.toJson(),
    "profit_loss": profitLoss?.toJson(),
    "financial_summary": financialSummary?.toJson(),
    "stock_alerts": stockAlerts?.toJson(),
    "recent_activities": recentActivities?.toJson(),
    "date_filter_info": dateFilterInfo?.toJson(),
  };
}

class DateFilterInfo {
  final String? filterType;
  final DateTime? startDate;
  final DateTime? endDate;

  DateFilterInfo({
    this.filterType,
    this.startDate,
    this.endDate,
  });

  factory DateFilterInfo.fromJson(Map<String, dynamic> json) => DateFilterInfo(
    filterType: json["filter_type"],
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
  );

  Map<String, dynamic> toJson() => {
    "filter_type": filterType,
    "start_date": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "end_date": "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
  };
}

class FinancialSummary {
  final dynamic netSales;
  final dynamic netPurchases;
  final dynamic grossProfit;
  final dynamic netProfit;
  final dynamic operatingCashFlow;
  final CashComponents? cashComponents;

  FinancialSummary({
    this.netSales,
    this.netPurchases,
    this.grossProfit,
    this.netProfit,
    this.operatingCashFlow,
    this.cashComponents,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) => FinancialSummary(
    netSales: json["net_sales"],
    netPurchases: json["net_purchases"],
    grossProfit: json["gross_profit"],
    netProfit: json["net_profit"],
    operatingCashFlow: json["operating_cash_flow"],
    cashComponents: json["cash_components"] == null ? null : CashComponents.fromJson(json["cash_components"]),
  );

  Map<String, dynamic> toJson() => {
    "net_sales": netSales,
    "net_purchases": netPurchases,
    "gross_profit": grossProfit,
    "net_profit": netProfit,
    "operating_cash_flow": operatingCashFlow,
    "cash_components": cashComponents?.toJson(),
  };
}

class CashComponents {
  final dynamic cashIn;
  final dynamic cashOutPurchases;
  final dynamic cashOutExpenses;

  CashComponents({
    this.cashIn,
    this.cashOutPurchases,
    this.cashOutExpenses,
  });

  factory CashComponents.fromJson(Map<String, dynamic> json) => CashComponents(
    cashIn: json["cash_in"],
    cashOutPurchases: json["cash_out_purchases"],
    cashOutExpenses: json["cash_out_expenses"],
  );

  Map<String, dynamic> toJson() => {
    "cash_in": cashIn,
    "cash_out_purchases": cashOutPurchases,
    "cash_out_expenses": cashOutExpenses,
  };
}

class ProfitLoss {
  final dynamic grossProfit;
  final dynamic netProfit;
  final double? profitMargin;

  ProfitLoss({
    this.grossProfit,
    this.netProfit,
    this.profitMargin,
  });

  factory ProfitLoss.fromJson(Map<String, dynamic> json) => ProfitLoss(
    grossProfit: json["gross_profit"],
    netProfit: json["net_profit"],
    profitMargin: json["profit_margin"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "gross_profit": grossProfit,
    "net_profit": netProfit,
    "profit_margin": profitMargin,
  };
}

class RecentActivities {
  final List<Purchase>? sales;
  final List<Purchase>? purchases;

  RecentActivities({
    this.sales,
    this.purchases,
  });

  factory RecentActivities.fromJson(Map<String, dynamic> json) => RecentActivities(
    sales: json["sales"] == null ? [] : List<Purchase>.from(json["sales"]!.map((x) => Purchase.fromJson(x))),
    purchases: json["purchases"] == null ? [] : List<Purchase>.from(json["purchases"]!.map((x) => Purchase.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "sales": sales == null ? [] : List<dynamic>.from(sales!.map((x) => x.toJson())),
    "purchases": purchases == null ? [] : List<dynamic>.from(purchases!.map((x) => x.toJson())),
  };
}

class Purchase {
  final String? invoiceNo;
  final String? supplier;
  final dynamic amount;
  final dynamic dueAmount;
  final dynamic quantity;
  final DateTime? date;
  final String? customer;

  Purchase({
    this.invoiceNo,
    this.supplier,
    this.amount,
    this.dueAmount,
    this.quantity,
    this.date,
    this.customer,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
    invoiceNo: json["invoice_no"],
    supplier: json["supplier"],
    amount: json["amount"],
    dueAmount: json["due_amount"],
    quantity: json["quantity"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    customer: json["customer"],
  );

  Map<String, dynamic> toJson() => {
    "invoice_no": invoiceNo,
    "supplier": supplier,
    "amount": amount,
    "due_amount": dueAmount,
    "quantity": quantity,
    "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "customer": customer,
  };
}

class StockAlerts {
  final int? lowStock;
  final int? outOfStock;

  StockAlerts({
    this.lowStock,
    this.outOfStock,
  });

  factory StockAlerts.fromJson(Map<String, dynamic> json) => StockAlerts(
    lowStock: json["low_stock"],
    outOfStock: json["out_of_stock"],
  );

  Map<String, dynamic> toJson() => {
    "low_stock": lowStock,
    "out_of_stock": outOfStock,
  };
}

class TodayMetrics {
  final Purchases? sales;
  final Returns? salesReturns;
  final Purchases? purchases;
  final Returns? purchaseReturns;
  final Expenses? expenses;

  TodayMetrics({
    this.sales,
    this.salesReturns,
    this.purchases,
    this.purchaseReturns,
    this.expenses,
  });

  factory TodayMetrics.fromJson(Map<String, dynamic> json) => TodayMetrics(
    sales: json["sales"] == null ? null : Purchases.fromJson(json["sales"]),
    salesReturns: json["sales_returns"] == null ? null : Returns.fromJson(json["sales_returns"]),
    purchases: json["purchases"] == null ? null : Purchases.fromJson(json["purchases"]),
    purchaseReturns: json["purchase_returns"] == null ? null : Returns.fromJson(json["purchase_returns"]),
    expenses: json["expenses"] == null ? null : Expenses.fromJson(json["expenses"]),
  );

  Map<String, dynamic> toJson() => {
    "sales": sales?.toJson(),
    "sales_returns": salesReturns?.toJson(),
    "purchases": purchases?.toJson(),
    "purchase_returns": purchaseReturns?.toJson(),
    "expenses": expenses?.toJson(),
  };
}

class Expenses {
  final dynamic total;
  final int? count;

  Expenses({
    this.total,
    this.count,
  });

  factory Expenses.fromJson(Map<String, dynamic> json) => Expenses(
    total: json["total"],
    count: json["count"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "count": count,
  };
}

class Returns {
  final dynamic totalAmount;
  final int? totalQuantity;
  final int? count;

  Returns({
    this.totalAmount,
    this.totalQuantity,
    this.count,
  });

  factory Returns.fromJson(Map<String, dynamic> json) => Returns(
    totalAmount: json["total_amount"],
    totalQuantity: json["total_quantity"],
    count: json["count"],
  );

  Map<String, dynamic> toJson() => {
    "total_amount": totalAmount,
    "total_quantity": totalQuantity,
    "count": count,
  };
}

class Purchases {
  final dynamic total;
  final int? count;
  final int? totalQuantity;
  final dynamic totalDue;
  final dynamic netTotal;

  Purchases({
    this.total,
    this.count,
    this.totalQuantity,
    this.totalDue,
    this.netTotal,
  });

  factory Purchases.fromJson(Map<String, dynamic> json) => Purchases(
    total: json["total"],
    count: json["count"],
    totalQuantity: json["total_quantity"],
    totalDue: json["total_due"],
    netTotal: json["net_total"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "count": count,
    "total_quantity": totalQuantity,
    "total_due": totalDue,
    "net_total": netTotal,
  };
}
