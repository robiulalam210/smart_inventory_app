import 'package:meherinMart/core/core.dart';

import '../../data/model/low_stock_model.dart';
import '../../data/model/stock_report_model.dart';
import '../../data/model/top_products_model.dart';
import '../bloc/low_stock_bloc/low_stock_bloc.dart';
import '../bloc/stock_report_bloc/stock_report_bloc.dart';
import '../bloc/top_products_bloc/top_products_bloc.dart';
import '../kit/report_kit.dart';

// ═════════════════════════ Top selling products ═════════════════════════

/// কোন পণ্য সবচেয়ে বেশি বিক্রি হয়েছে — পরিমাণ, টাকা, আর মোট বিক্রির কত ভাগ
class TopProductsView extends StatefulWidget {
  final bool mobile;

  const TopProductsView({super.key, this.mobile = false});

  @override
  State<TopProductsView> createState() => _TopProductsViewState();
}

class _TopProductsViewState extends State<TopProductsView> with ReportPeriodMixin {
  static const _title = 'Top Selling Products';
  static const _color = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    initPeriod();
    reload();
  }

  @override
  void reload() {
    context.read<TopProductsBloc>().add(FetchTopProductsReport(context: context, from: range?.start, to: range?.end));
  }

  void _clear() {
    setState(initPeriod);
    reload();
  }

  List<ReportColumn<TopProductModel>> _columns(double totalSales) => [
        const ReportColumn.serial(),
        ReportColumn('Product', value: (r) => r.productName, bold: true, primary: true, flex: 4, minWidth: 200),
        ReportColumn('Price', value: (r) => r.sellingPrice, kind: ReportKind.money, minWidth: 100),
        ReportColumn('Qty sold', value: (r) => r.totalSoldQuantity, kind: ReportKind.qty, bold: true, minWidth: 90),
        ReportColumn('Sales', value: (r) => r.totalSoldPrice, kind: ReportKind.money, bold: true, highlight: true,
            minWidth: 120),
        ReportColumn('Share', value: (r) => totalSales == 0 ? 0 : r.totalSoldPrice / totalSales * 100,
            kind: ReportKind.percent, minWidth: 80, color: (_) => _color),
      ];

  List<ReportStat> _stats(TopProductsSummary s, List<TopProductModel> rows) => [
        ReportStat('Products sold', '${s.totalProducts}', icon: Icons.inventory_2_outlined, color: _color),
        ReportStat('Units sold', ReportFmt.qty(s.totalQuantitySold),
            icon: Icons.shopping_basket_outlined, color: AppColors.info),
        ReportStat('Sales value', ReportFmt.taka(s.totalSales), icon: Icons.point_of_sale_rounded, color: AppColors.success),
        if (rows.isNotEmpty)
          ReportStat('Best seller', rows.first.productName,
              icon: Icons.emoji_events_outlined, color: const Color(0xFFDB2777)),
      ];

  void _pdf(TopProductsResponse d) {
    final company = reportCompany(context);
    final period = periodText;
    openReportPdf(
      context,
      title: _title,
      build: () => ReportPdf.build<TopProductModel>(
        title: _title,
        period: period,
        company: company,
        accent: const Color(0xFFD97706),
        stats: _stats(d.summary, d.report),
        columns: _columns(d.summary.totalSales),
        rows: d.report,
        totals: [
          ReportTotal('Units sold', ReportFmt.qty(d.summary.totalQuantitySold)),
          ReportTotal('Sales value', ReportFmt.taka(d.summary.totalSales)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopProductsBloc, TopProductsState>(
      builder: (context, state) {
        final data = state is TopProductsSuccess ? state.response : null;
        final page = ReportPage(
          title: _title,
          subtitle: periodText,
          icon: Icons.emoji_events_outlined,
          color: _color,
          compact: widget.mobile,
          preset: preset,
          range: range,
          onRangeChanged: onPeriodChanged,
          onClear: _clear,
          onRefresh: reload,
          onPdf: data == null ? null : () => _pdf(data),
          stats: data == null ? const [] : _stats(data.summary, data.report),
          loading: state is TopProductsLoading || state is TopProductsInitial,
          error: state is TopProductsFailed ? state.content : null,
          isEmpty: data != null && data.report.isEmpty,
          emptyTitle: 'Nothing sold in this period',
          child: data == null
              ? null
              : ReportTable<TopProductModel>(
                  columns: _columns(data.summary.totalSales),
                  rows: data.report,
                  totals: [
                    ReportTotal('Units sold', ReportFmt.qty(data.summary.totalQuantitySold)),
                    ReportTotal('Sales value', ReportFmt.taka(data.summary.totalSales)),
                  ],
                  searchHint: 'Search product',
                ),
        );
        return wrapReport(mobile: widget.mobile, title: _title, page: page);
      },
    );
  }
}

// ═════════════════════════ Low stock ═════════════════════════

/// কোন পণ্য শেষ হয়ে আসছে — শেষ / জরুরি / কম, আবার কিনতে হবে
class LowStockView extends StatefulWidget {
  final bool mobile;

  const LowStockView({super.key, this.mobile = false});

  @override
  State<LowStockView> createState() => _LowStockViewState();
}

class _LowStockViewState extends State<LowStockView> with ReportPeriodMixin {
  static const _title = 'Low Stock Report';
  static const _color = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void reload() => context.read<LowStockBloc>().add(FetchLowStockReport(context: context));

  /// শেষ (০) → জরুরি (সতর্কতা সীমার অর্ধেক বা কম) → কম
  static String _level(LowStockProduct p) {
    if (p.totalStockQuantity <= 0) return 'Out of stock';
    if (p.totalStockQuantity <= (p.alertQuantity / 2).ceil()) return 'Critical';
    return 'Low';
  }

  static final List<ReportColumn<LowStockProduct>> _columns = [
    const ReportColumn.serial(),
    ReportColumn('Product', value: (r) => r.productName, bold: true, primary: true, flex: 4, minWidth: 200),
    ReportColumn('Category', value: (r) => r.category, secondary: true, minWidth: 110),
    ReportColumn('Brand', value: (r) => r.brand, minWidth: 100),
    ReportColumn('Price', value: (r) => r.sellingPrice, kind: ReportKind.money, minWidth: 96),
    ReportColumn('In stock', value: (r) => r.totalStockQuantity, kind: ReportKind.qty, bold: true, minWidth: 84,
        color: (r) => r.totalStockQuantity <= 0 ? AppColors.danger : AppColors.warning),
    ReportColumn('Alert at', value: (r) => r.alertQuantity, kind: ReportKind.qty, minWidth: 80),
    ReportColumn('Sold', value: (r) => r.totalSoldQuantity, kind: ReportKind.qty, minWidth: 76),
    ReportColumn('Level', value: _level, kind: ReportKind.status, minWidth: 110,
        color: (r) => switch (_level(r)) {
              'Out of stock' => AppColors.danger,
              'Critical' => const Color(0xFFEA580C),
              _ => AppColors.warning,
            }),
  ];

  List<ReportStat> _stats(LowStockResponse d) {
    final out = d.report.where((p) => p.totalStockQuantity <= 0).length;
    return [
      ReportStat('Low stock items', '${d.summary.totalLowStockItems}', icon: Icons.inventory_outlined, color: _color),
      ReportStat('Out of stock', '$out', icon: Icons.remove_shopping_cart_outlined, color: AppColors.danger),
      ReportStat('Critical', '${d.summary.criticalItems}',
          icon: Icons.warning_amber_rounded, color: const Color(0xFFEA580C)),
      ReportStat('Alert threshold', '${d.summary.threshold}',
          icon: Icons.tune_rounded, color: AppColors.info, hint: 'Default alert quantity'),
    ];
  }

  void _pdf(LowStockResponse d) {
    final company = reportCompany(context);
    openReportPdf(
      context,
      title: _title,
      build: () => ReportPdf.build<LowStockProduct>(
        title: _title,
        period: 'As of ${ReportFmt.date(DateTime.now())}',
        company: company,
        accent: _color,
        stats: _stats(d),
        columns: _columns,
        rows: d.report,
        note: 'Critical = stock at or below half of the alert quantity.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LowStockBloc, LowStockState>(
      builder: (context, state) {
        final data = state is LowStockSuccess ? state.response : null;
        final page = ReportPage(
          title: _title,
          subtitle: 'Products that need restocking · as of ${ReportFmt.date(DateTime.now())}',
          icon: Icons.inventory_outlined,
          color: _color,
          compact: widget.mobile,
          showDate: false,
          onRefresh: reload,
          onPdf: data == null ? null : () => _pdf(data),
          stats: data == null ? const [] : _stats(data),
          loading: state is LowStockLoading || state is LowStockInitial,
          error: state is LowStockFailed ? state.content : null,
          isEmpty: data != null && data.report.isEmpty,
          emptyTitle: 'All products are well stocked',
          emptyMessage: 'Nothing is below its alert quantity right now.',
          child: data == null
              ? null
              : ReportTable<LowStockProduct>(
                  columns: _columns,
                  rows: data.report,
                  searchHint: 'Search product, category or brand',
                ),
        );
        return wrapReport(mobile: widget.mobile, title: _title, page: page);
      },
    );
  }
}

// ═════════════════════════ Stock report ═════════════════════════

/// বর্তমান মজুদ — কত পরিমাণ, কেনা দামে কত টাকার, বিক্রি করলে কত লাভ সম্ভব
class StockReportView extends StatefulWidget {
  final bool mobile;

  const StockReportView({super.key, this.mobile = false});

  @override
  State<StockReportView> createState() => _StockReportViewState();
}

class _StockReportViewState extends State<StockReportView> with ReportPeriodMixin {
  static const _title = 'Stock Report';
  static const _color = Color(0xFF0D9488);

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void reload() => context.read<StockReportBloc>().add(FetchStockReport(context: context));

  static double _potential(StockProduct p) => (p.sellingPrice - p.avgPurchasePrice) * p.currentStock;

  static final List<ReportColumn<StockProduct>> _columns = [
    const ReportColumn.serial(),
    ReportColumn('Product', value: (r) => r.productName, bold: true, primary: true, flex: 4, minWidth: 200,
        subtitle: (r) => r.productNo == 0 ? null : 'No. ${r.productNo}'),
    ReportColumn('Category', value: (r) => r.category, secondary: true, minWidth: 110),
    ReportColumn('Brand', value: (r) => r.brand, minWidth: 100),
    ReportColumn('Avg cost', value: (r) => r.avgPurchasePrice, kind: ReportKind.money, minWidth: 100),
    ReportColumn('Sell price', value: (r) => r.sellingPrice, kind: ReportKind.money, minWidth: 100),
    ReportColumn('In stock', value: (r) => r.currentStock, kind: ReportKind.qty, bold: true, minWidth: 84,
        color: (r) => r.currentStock <= 0 ? AppColors.danger : null),
    ReportColumn('Stock value', value: (r) => r.value, kind: ReportKind.money, bold: true, highlight: true,
        minWidth: 120),
    ReportColumn('Potential profit', value: _potential, kind: ReportKind.money, minWidth: 120,
        color: (r) => _potential(r) < 0 ? AppColors.danger : AppColors.success),
  ];

  List<ReportStat> _stats(StockReportResponse d) {
    final potential = d.report.fold<double>(0, (s, p) => s + _potential(p));
    final out = d.report.where((p) => p.currentStock <= 0).length;
    return [
      ReportStat('Products', '${d.summary.totalProducts}', icon: Icons.inventory_2_outlined, color: _color),
      ReportStat('Units in stock', ReportFmt.qty(d.summary.totalStockQuantity),
          icon: Icons.all_inbox_outlined, color: AppColors.info),
      ReportStat('Stock value', ReportFmt.taka(d.summary.totalStockValue),
          icon: Icons.account_balance_wallet_outlined, color: const Color(0xFF7C3AED), hint: 'At average purchase cost'),
      ReportStat('Potential profit', ReportFmt.taka(potential),
          icon: Icons.trending_up_rounded, color: AppColors.success, hint: 'If all stock sells at selling price'),
      ReportStat('Out of stock', '$out', icon: Icons.remove_shopping_cart_outlined, color: AppColors.danger),
    ];
  }

  List<ReportTotal> _totals(StockReportResponse d) => [
        ReportTotal('Units', ReportFmt.qty(d.summary.totalStockQuantity)),
        ReportTotal('Stock value', ReportFmt.taka(d.summary.totalStockValue)),
        ReportTotal('Potential profit', ReportFmt.taka(d.report.fold<double>(0, (s, p) => s + _potential(p))),
            color: AppColors.success),
      ];

  void _pdf(StockReportResponse d) {
    final company = reportCompany(context);
    openReportPdf(
      context,
      title: _title,
      build: () => ReportPdf.build<StockProduct>(
        title: _title,
        period: 'As of ${ReportFmt.date(DateTime.now())}',
        company: company,
        accent: _color,
        stats: _stats(d),
        columns: _columns,
        rows: d.report,
        totals: _totals(d),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockReportBloc, StockReportState>(
      builder: (context, state) {
        final data = state is StockReportSuccess ? state.response : null;
        final page = ReportPage(
          title: _title,
          subtitle: 'Current stock and its value · as of ${ReportFmt.date(DateTime.now())}',
          icon: Icons.warehouse_outlined,
          color: _color,
          compact: widget.mobile,
          showDate: false,
          onRefresh: reload,
          onPdf: data == null ? null : () => _pdf(data),
          stats: data == null ? const [] : _stats(data),
          loading: state is StockReportLoading || state is StockReportInitial,
          error: state is StockReportFailed ? state.content : null,
          isEmpty: data != null && data.report.isEmpty,
          emptyTitle: 'No products in stock',
          emptyMessage: 'Add products and purchases to see stock here.',
          child: data == null
              ? null
              : ReportTable<StockProduct>(
                  columns: _columns,
                  rows: data.report,
                  totals: _totals(data),
                  searchHint: 'Search product, category or brand',
                ),
        );
        return wrapReport(mobile: widget.mobile, title: _title, page: page);
      },
    );
  }
}
