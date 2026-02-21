import 'dart:convert';

DashboardData dashboardDataFromJson(String str) =>
    DashboardData.fromJson(json.decode(str));

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
    todayMetrics: json["today_metrics"] == null
        ? null
        : TodayMetrics.fromJson(json["today_metrics"]),
    profitLoss: json["profit_loss"] == null
        ? null
        : ProfitLoss.fromJson(json["profit_loss"]),
    financialSummary: json["financial_summary"] == null
        ? null
        : FinancialSummary.fromJson(json["financial_summary"]),
    stockAlerts: json["stock_alerts"] == null
        ? null
        : StockAlerts.fromJson(json["stock_alerts"]),
    recentActivities: json["recent_activities"] == null
        ? null
        : RecentActivities.fromJson(json["recent_activities"]),
    dateFilterInfo: json["date_filter_info"] == null
        ? null
        : DateFilterInfo.fromJson(json["date_filter_info"]),
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

  DateFilterInfo({this.filterType, this.startDate, this.endDate});

  factory DateFilterInfo.fromJson(Map<String, dynamic> json) => DateFilterInfo(
    filterType: json["filter_type"],
    startDate: json["start_date"] == null
        ? null
        : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null
        ? null
        : DateTime.parse(json["end_date"]),
  );

  Map<String, dynamic> toJson() => {
    "filter_type": filterType,
    "start_date":
    "${startDate?.year.toString().padLeft(4, '0')}-${startDate?.month.toString().padLeft(2, '0')}-${startDate?.day.toString().padLeft(2, '0')}",
    "end_date":
    "${endDate?.year.toString().padLeft(4, '0')}-${endDate?.month.toString().padLeft(2, '0')}-${endDate?.day.toString().padLeft(2, '0')}",
  };
}

/// TODAY METRICS
class TodayMetrics {
  final Purchases? sales;
  final Returns? salesReturns;
  final Purchases? purchases;
  final Returns? purchaseReturns;
  final Expenses? expenses;
  final Expenses? incomes;

  TodayMetrics({
    this.sales,
    this.salesReturns,
    this.purchases,
    this.purchaseReturns,
    this.expenses,
    this.incomes,
  });

  factory TodayMetrics.fromJson(Map<String, dynamic> json) => TodayMetrics(
    sales: json["sales"] == null ? null : Purchases.fromJson(json["sales"]),
    salesReturns: json["sales_returns"] == null
        ? null
        : Returns.fromJson(json["sales_returns"]),
    purchases: json["purchases"] == null
        ? null
        : Purchases.fromJson(json["purchases"]),
    purchaseReturns: json["purchase_returns"] == null
        ? null
        : Returns.fromJson(json["purchase_returns"]),
    expenses:
    json["expenses"] == null ? null : Expenses.fromJson(json["expenses"]),
    incomes:
    json["incomes"] == null ? null : Expenses.fromJson(json["incomes"]),
  );

  Map<String, dynamic> toJson() => {
    "sales": sales?.toJson(),
    "sales_returns": salesReturns?.toJson(),
    "purchases": purchases?.toJson(),
    "purchase_returns": purchaseReturns?.toJson(),
    "expenses": expenses?.toJson(),
    "incomes": incomes?.toJson(),
  };
}

/// PURCHASES
class Purchases {
  final dynamic total;
  final int? count;
  final dynamic totalQuantity;
  final dynamic totalDue;
  final dynamic netTotal;
  final dynamic baseQuantity;
  final dynamic saleQuantity;

  Purchases({
    this.total,
    this.count,
    this.totalQuantity,
    this.totalDue,
    this.netTotal,
    this.baseQuantity,
    this.saleQuantity,
  });

  factory Purchases.fromJson(Map<String, dynamic> json) => Purchases(
    total: json["total"],
    count: json["count"],
    totalQuantity: json["total_quantity"] ?? 0,
    totalDue: json["total_due"],
    netTotal: json["net_total"],
    baseQuantity: json["base_quantity"],
    saleQuantity: json["sale_quantity"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "count": count,
    "total_quantity": totalQuantity,
    "total_due": totalDue,
    "net_total": netTotal,
    "base_quantity": baseQuantity,
    "sale_quantity": saleQuantity,
  };
}

/// RETURNS
class Returns {
  final dynamic totalAmount;
  final int? totalQuantity;
  final int? count;

  Returns({this.totalAmount, this.totalQuantity, this.count});

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

/// EXPENSES / INCOMES
class Expenses {
  final dynamic total;
  final int? count;

  Expenses({this.total, this.count});

  factory Expenses.fromJson(Map<String, dynamic> json) =>
      Expenses(total: json["total"], count: json["count"]);

  Map<String, dynamic> toJson() => {"total": total, "count": count};
}

/// PROFIT LOSS
class ProfitLoss {
  final dynamic grossProfit;
  final dynamic netProfit;
  final dynamic netProfitWithIncomes;
  final double? profitMargin;

  ProfitLoss({this.grossProfit, this.netProfit, this.netProfitWithIncomes, this.profitMargin});

  factory ProfitLoss.fromJson(Map<String, dynamic> json) => ProfitLoss(
    grossProfit: json["gross_profit"],
    netProfit: json["net_profit"],
    netProfitWithIncomes: json["net_profit_with_incomes"],
    profitMargin: (json["profit_margin"]?.toDouble()) ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "gross_profit": grossProfit,
    "net_profit": netProfit,
    "net_profit_with_incomes": netProfitWithIncomes,
    "profit_margin": profitMargin,
  };
}

/// FINANCIAL SUMMARY
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
    cashComponents: json["cash_components"] == null
        ? null
        : CashComponents.fromJson(json["cash_components"]),
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

/// CASH COMPONENTS
class CashComponents {
  final dynamic cashIn;
  final dynamic cashOutPurchases;
  final dynamic cashOutExpenses;
  final dynamic cashOutIncomes;

  CashComponents({
    this.cashIn,
    this.cashOutPurchases,
    this.cashOutExpenses,
    this.cashOutIncomes,
  });

  factory CashComponents.fromJson(Map<String, dynamic> json) => CashComponents(
    cashIn: json["cash_in"],
    cashOutPurchases: json["cash_out_purchases"],
    cashOutExpenses: json["cash_out_expenses"],
    cashOutIncomes: json["cash_out_incomes"],
  );

  Map<String, dynamic> toJson() => {
    "cash_in": cashIn,
    "cash_out_purchases": cashOutPurchases,
    "cash_out_expenses": cashOutExpenses,
    "cash_out_incomes": cashOutIncomes,
  };
}

/// STOCK ALERTS
class StockAlerts {
  final int? lowStock;
  final int? outOfStock;

  StockAlerts({this.lowStock, this.outOfStock});

  factory StockAlerts.fromJson(Map<String, dynamic> json) => StockAlerts(
    lowStock: json["low_stock"],
    outOfStock: json["out_of_stock"],
  );

  Map<String, dynamic> toJson() => {"low_stock": lowStock, "out_of_stock": outOfStock};
}

/// RECENT ACTIVITIES
class RecentActivities {
  final List<Purchase>? sales;
  final List<Purchase>? purchases;
  final List<ExpenseIncome>? expenses;
  final List<ExpenseIncome>? incomes;

  RecentActivities({this.sales, this.purchases, this.expenses, this.incomes});

  factory RecentActivities.fromJson(Map<String, dynamic> json) => RecentActivities(
    sales: json["sales"] == null
        ? []
        : List<Purchase>.from(json["sales"]!.map((x) => Purchase.fromJson(x))),
    purchases: json["purchases"] == null
        ? []
        : List<Purchase>.from(json["purchases"]!.map((x) => Purchase.fromJson(x))),
    expenses: json["expenses"] == null
        ? []
        : List<ExpenseIncome>.from(
        json["expenses"]!.map((x) => ExpenseIncome.fromJson(x))),
    incomes: json["incomes"] == null
        ? []
        : List<ExpenseIncome>.from(
        json["incomes"]!.map((x) => ExpenseIncome.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "sales": sales == null ? [] : sales!.map((x) => x.toJson()).toList(),
    "purchases": purchases == null ? [] : purchases!.map((x) => x.toJson()).toList(),
    "expenses": expenses == null ? [] : expenses!.map((x) => x.toJson()).toList(),
    "incomes": incomes == null ? [] : incomes!.map((x) => x.toJson()).toList(),
  };
}

/// PURCHASE MODEL
class Purchase {
  final String? invoiceNo;
  final String? supplier;
  final String? customer;
  final dynamic amount;
  final dynamic dueAmount;
  final dynamic quantity;
  final dynamic baseQuantity;
  final dynamic saleQuantity;
  final DateTime? date;

  Purchase({
    this.invoiceNo,
    this.supplier,
    this.customer,
    this.amount,
    this.dueAmount,
    this.quantity,
    this.baseQuantity,
    this.saleQuantity,
    this.date,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
    invoiceNo: json["invoice_no"],
    supplier: json["supplier"],
    customer: json["customer"],
    amount: json["amount"],
    dueAmount: json["due_amount"],
    quantity: json["quantity"],
    baseQuantity: json["base_quantity"],
    saleQuantity: json["sale_quantity"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
  );

  Map<String, dynamic> toJson() => {
    "invoice_no": invoiceNo,
    "supplier": supplier,
    "customer": customer,
    "amount": amount,
    "due_amount": dueAmount,
    "quantity": quantity,
    "base_quantity": baseQuantity,
    "sale_quantity": saleQuantity,
    "date": date?.toIso8601String(),
  };
}

/// EXPENSE / INCOME MODEL
class ExpenseIncome {
  final String? invoiceNo;
  final String? head;
  final dynamic amount;
  final String? account;
  final DateTime? date;
  final String? note;

  ExpenseIncome({
    this.invoiceNo,
    this.head,
    this.amount,
    this.account,
    this.date,
    this.note,
  });

  factory ExpenseIncome.fromJson(Map<String, dynamic> json) => ExpenseIncome(
    invoiceNo: json["invoice_no"],
    head: json["head"],
    amount: json["amount"],
    account: json["account"],
    date: json["income_date"] != null
        ? DateTime.parse(json["income_date"])
        : json["expense_date"] != null
        ? DateTime.parse(json["expense_date"])
        : null,
    note: json["note"],
  );

  Map<String, dynamic> toJson() => {
    "invoice_no": invoiceNo,
    "head": head,
    "amount": amount,
    "account": account,
    "income_date": date?.toIso8601String(),
    "expense_date": date?.toIso8601String(),
    "note": note,
  };
}
