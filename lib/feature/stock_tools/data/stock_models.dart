// Stock tools — Stock Adjustment, Stocktake, Expiry Alerts, Dashboard charts এর data model।
// সব model সহনশীলভাবে parse করে (null / string-সংখ্যা মিললেও ভাঙে না)।

num _n(dynamic v) {
  if (v is num) return v;
  return num.tryParse('${v ?? ''}') ?? 0;
}

int _i(dynamic v) => _n(v).toInt();
String _s(dynamic v) => v == null ? '' : '$v';
DateTime? _d(dynamic v) => v == null ? null : DateTime.tryParse('$v');
Map<String, dynamic> _m(dynamic v) => v is Map ? v.cast<String, dynamic>() : <String, dynamic>{};
List<Map<String, dynamic>> _l(dynamic v) =>
    v is List ? [for (final e in v) if (e is Map) e.cast<String, dynamic>()] : <Map<String, dynamic>>[];

/// পণ্য খোঁজার ফল
class ProductHit {
  final int id;
  final String name;
  final String sku;
  final int stock;
  final double cost;
  final double price;

  const ProductHit({
    required this.id,
    required this.name,
    required this.sku,
    required this.stock,
    required this.cost,
    required this.price,
  });

  factory ProductHit.fromJson(Map<String, dynamic> j) {
    final discounted = j['discount_applied'] == true;
    return ProductHit(
      id: _i(j['id']),
      name: _s(j['name']),
      sku: _s(j['sku']),
      stock: _i(j['stock_qty']),
      cost: _n(j['purchase_price']).toDouble(),
      price: _n(discounted ? j['final_price'] : j['selling_price']).toDouble(),
    );
  }
}

class StockReason {
  final String key;
  final String label;
  const StockReason(this.key, this.label);
}

/// Stock Adjustment এ হাতে বাছার কারণ ('count' শুধু Stocktake এর)
const List<StockReason> kManualReasons = [
  StockReason('damaged', 'Damaged'),
  StockReason('expired', 'Expired'),
  StockReason('lost', 'Lost / stolen'),
  StockReason('found', 'Found / extra'),
  StockReason('correction', 'Entry mistake'),
  StockReason('opening', 'Opening stock'),
  StockReason('other', 'Other'),
];

class AdjustmentEntry {
  final int id;
  final String number;
  final int productId;
  final String productName;
  final String sku;
  final int before;
  final int after;
  final int change;
  final double valueChange;
  final String reason;
  final String reasonLabel;
  final String note;
  final String stocktakeNumber;
  final String createdBy;
  final DateTime? createdAt;

  const AdjustmentEntry({
    required this.id,
    required this.number,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.before,
    required this.after,
    required this.change,
    required this.valueChange,
    required this.reason,
    required this.reasonLabel,
    required this.note,
    required this.stocktakeNumber,
    required this.createdBy,
    required this.createdAt,
  });

  factory AdjustmentEntry.fromJson(Map<String, dynamic> j) => AdjustmentEntry(
        id: _i(j['id']),
        number: _s(j['number']),
        productId: _i(j['product_id']),
        productName: _s(j['product_name']),
        sku: _s(j['sku']),
        before: _i(j['qty_before']),
        after: _i(j['qty_after']),
        change: _i(j['change']),
        valueChange: _n(j['value_change']).toDouble(),
        reason: _s(j['reason']),
        reasonLabel: _s(j['reason_label']),
        note: _s(j['note']),
        stocktakeNumber: _s(j['stocktake_number']),
        createdBy: _s(j['created_by']),
        createdAt: _d(j['created_at']),
      );
}

class AdjustmentPage {
  final List<AdjustmentEntry> items;
  final int count;
  final int page;
  final int totalPages;
  final double netValue;
  final double lossValue;
  final double gainValue;

  const AdjustmentPage({
    required this.items,
    required this.count,
    required this.page,
    required this.totalPages,
    required this.netValue,
    required this.lossValue,
    required this.gainValue,
  });

  bool get hasMore => page < totalPages;

  factory AdjustmentPage.fromJson(Map<String, dynamic> j) {
    final t = _m(j['totals']);
    return AdjustmentPage(
      items: _l(j['results']).map(AdjustmentEntry.fromJson).toList(),
      count: _i(j['count']),
      page: _i(j['page']) == 0 ? 1 : _i(j['page']),
      totalPages: _i(j['total_pages']) == 0 ? 1 : _i(j['total_pages']),
      netValue: _n(t['net_value']).toDouble(),
      lossValue: _n(t['loss_value']).toDouble(),
      gainValue: _n(t['gain_value']).toDouble(),
    );
  }
}

class StocktakeSummary {
  final int total;
  final int counted;
  final int uncounted;
  final int differing;
  final int shortQty;
  final int overQty;
  final double shortValue;
  final double overValue;
  final double netValue;

  const StocktakeSummary({
    this.total = 0,
    this.counted = 0,
    this.uncounted = 0,
    this.differing = 0,
    this.shortQty = 0,
    this.overQty = 0,
    this.shortValue = 0,
    this.overValue = 0,
    this.netValue = 0,
  });

  double get progress => total == 0 ? 0 : counted / total;

  factory StocktakeSummary.fromJson(Map<String, dynamic> j) => StocktakeSummary(
        total: _i(j['total']),
        counted: _i(j['counted']),
        uncounted: _i(j['uncounted']),
        differing: _i(j['differing']),
        shortQty: _i(j['short_qty']),
        overQty: _i(j['over_qty']),
        shortValue: _n(j['short_value']).toDouble(),
        overValue: _n(j['over_value']).toDouble(),
        netValue: _n(j['net_value']).toDouble(),
      );
}

class StocktakeHead {
  final int id;
  final String number;
  final String title;
  final String note;
  final String status; // draft | applied | cancelled
  final String statusLabel;
  final String categoryName;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? appliedAt;
  final StocktakeSummary summary;

  const StocktakeHead({
    required this.id,
    required this.number,
    required this.title,
    required this.note,
    required this.status,
    required this.statusLabel,
    required this.categoryName,
    required this.createdBy,
    required this.createdAt,
    required this.appliedAt,
    required this.summary,
  });

  bool get isDraft => status == 'draft';

  factory StocktakeHead.fromJson(Map<String, dynamic> j) => StocktakeHead(
        id: _i(j['id']),
        number: _s(j['number']),
        title: _s(j['title']),
        note: _s(j['note']),
        status: _s(j['status']),
        statusLabel: _s(j['status_label']),
        categoryName: _s(j['category_name']),
        createdBy: _s(j['created_by']),
        createdAt: _d(j['created_at']),
        appliedAt: _d(j['applied_at']),
        summary: StocktakeSummary.fromJson(_m(j['summary'])),
      );
}

class StocktakeLine {
  final int id;
  final int productId;
  final String name;
  final String sku;
  final String category;
  final int systemQty;
  int? countedQty;
  final double unitCost;
  final int? systemNow;
  final bool moved;
  final int? appliedChange;

  StocktakeLine({
    required this.id,
    required this.productId,
    required this.name,
    required this.sku,
    required this.category,
    required this.systemQty,
    required this.countedQty,
    required this.unitCost,
    required this.systemNow,
    required this.moved,
    required this.appliedChange,
  });

  int? get variance => countedQty == null ? null : countedQty! - systemQty;

  factory StocktakeLine.fromJson(Map<String, dynamic> j) => StocktakeLine(
        id: _i(j['id']),
        productId: _i(j['product_id']),
        name: _s(j['name']),
        sku: _s(j['sku']),
        category: _s(j['category']),
        systemQty: _i(j['system_qty']),
        countedQty: j['counted_qty'] == null ? null : _i(j['counted_qty']),
        unitCost: _n(j['unit_cost']).toDouble(),
        systemNow: j['system_now'] == null ? null : _i(j['system_now']),
        moved: j['moved'] == true,
        appliedChange: j['applied_change'] == null ? null : _i(j['applied_change']),
      );
}

class StocktakeDetail {
  final StocktakeHead head;
  final List<StocktakeLine> lines;
  const StocktakeDetail(this.head, this.lines);

  factory StocktakeDetail.fromJson(Map<String, dynamic> j) =>
      StocktakeDetail(StocktakeHead.fromJson(j), _l(j['lines']).map(StocktakeLine.fromJson).toList());
}

/// মেয়াদের এক ব্যাচ
class ExpiryBatch {
  final int id;
  final int productId;
  final String productName;
  final String sku;
  final String category;
  final String batchNo;
  final DateTime? expiryDate;
  final int daysLeft;
  final String status; // expired | expiring | ok
  final double qtyRemaining;
  final double unitCost;
  final double costValue;
  final String supplier;
  final String invoice;

  const ExpiryBatch({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.category,
    required this.batchNo,
    required this.expiryDate,
    required this.daysLeft,
    required this.status,
    required this.qtyRemaining,
    required this.unitCost,
    required this.costValue,
    required this.supplier,
    required this.invoice,
  });

  factory ExpiryBatch.fromJson(Map<String, dynamic> j) => ExpiryBatch(
        id: _i(j['id']),
        productId: _i(j['product_id']),
        productName: _s(j['product_name']),
        sku: _s(j['sku']),
        category: _s(j['category']),
        batchNo: _s(j['batch_no']),
        expiryDate: _d(j['expiry_date']),
        daysLeft: _i(j['days_left']),
        status: _s(j['status']),
        qtyRemaining: _n(j['qty_remaining']).toDouble(),
        unitCost: _n(j['unit_cost']).toDouble(),
        costValue: _n(j['cost_value']).toDouble(),
        supplier: _s(j['supplier']),
        invoice: _s(j['purchase_invoice']),
      );
}

class ExpiryReport {
  final int days;
  final int expired;
  final int expiring;
  final int ok;
  final double expiredValue;
  final double expiringValue;
  final List<ExpiryBatch> batches;

  const ExpiryReport({
    this.days = 30,
    this.expired = 0,
    this.expiring = 0,
    this.ok = 0,
    this.expiredValue = 0,
    this.expiringValue = 0,
    this.batches = const [],
  });

  int get alerts => expired + expiring;

  factory ExpiryReport.fromJson(Map<String, dynamic> j) {
    final c = _m(j['counts']);
    final v = _m(j['value']);
    return ExpiryReport(
      days: _i(j['days']) == 0 ? 30 : _i(j['days']),
      expired: _i(c['expired']),
      expiring: _i(c['expiring']),
      ok: _i(c['ok']),
      expiredValue: _n(v['expired']).toDouble(),
      expiringValue: _n(v['expiring']).toDouble(),
      batches: _l(j['batches']).map(ExpiryBatch.fromJson).toList(),
    );
  }
}

/// Dashboard এর অতিরিক্ত চার্টের তথ্য
class CategoryStock {
  final String name;
  final double costValue;
  final double retailValue;
  final int qty;
  final int products;

  const CategoryStock(this.name, this.costValue, this.retailValue, this.qty, this.products);
}

class DashboardCharts {
  final List<String> monthLabels; // 2026-03
  final List<double> sales;
  final List<double> grossProfit;
  final List<double> expenses;
  final List<double> netProfit;
  final List<String> dayLabels; // 2026-03-21
  final List<double> dayNet;
  final double stockCost;
  final double stockRetail;
  final double stockMargin;
  final int stockProducts;
  final List<CategoryStock> byCategory;

  const DashboardCharts({
    required this.monthLabels,
    required this.sales,
    required this.grossProfit,
    required this.expenses,
    required this.netProfit,
    required this.dayLabels,
    required this.dayNet,
    required this.stockCost,
    required this.stockRetail,
    required this.stockMargin,
    required this.stockProducts,
    required this.byCategory,
  });

  static List<double> _nums(dynamic v) => v is List ? [for (final e in v) _n(e).toDouble()] : <double>[];
  static List<String> _strs(dynamic v) => v is List ? [for (final e in v) '$e'] : <String>[];

  factory DashboardCharts.fromJson(Map<String, dynamic> j) {
    final mo = _m(j['monthly']);
    final tr = _m(j['profit_trend']);
    final st = _m(j['stock_value']);
    return DashboardCharts(
      monthLabels: _strs(mo['labels']),
      sales: _nums(mo['sales']),
      grossProfit: _nums(mo['gross_profit']),
      expenses: _nums(mo['expenses']),
      netProfit: _nums(mo['net_profit']),
      dayLabels: _strs(tr['labels']),
      dayNet: _nums(tr['net_profit']),
      stockCost: _n(st['total_cost']).toDouble(),
      stockRetail: _n(st['total_retail']).toDouble(),
      stockMargin: _n(st['expected_margin']).toDouble(),
      stockProducts: _i(st['product_count']),
      byCategory: [
        for (final c in _l(st['by_category']))
          CategoryStock(_s(c['name']), _n(c['cost_value']).toDouble(), _n(c['retail_value']).toDouble(),
              _i(c['qty']), _i(c['products'])),
      ],
    );
  }
}
