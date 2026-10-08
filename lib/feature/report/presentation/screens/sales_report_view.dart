import 'package:meherinMart/core/core.dart';

import '../../../customer/data/model/customer_active_model.dart';
import '../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../users_list/data/model/user_model.dart';
import '../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../../data/model/sales_report_model.dart';
import '../bloc/sales_report_bloc/sales_report_bloc.dart';
import '../kit/report_kit.dart';

/// Sales Report — কোন সময়ে কত বিক্রি, লাভ, আদায় আর বাকি (customer / বিক্রেতা ধরে)
class SalesReportView extends StatefulWidget {
  final bool mobile;

  const SalesReportView({super.key, this.mobile = false});

  @override
  State<SalesReportView> createState() => _SalesReportViewState();
}

class _SalesReportViewState extends State<SalesReportView> with ReportPeriodMixin {
  static const _title = 'Sales Report';
  static const _color = Color(0xFF2563EB);

  CustomerActiveModel? _customer;
  UsersListModel? _seller;

  @override
  void initState() {
    super.initState();
    initPeriod();
    context.read<CustomerBloc>().add(FetchCustomerActiveList(context));
    context.read<UserBloc>().add(FetchUserList(context, dropdownFilter: '?status=1'));
    reload();
  }

  @override
  void reload() {
    context.read<SalesReportBloc>().add(FetchSalesReport(
          context: context,
          customer: _customer?.id?.toString() ?? '',
          seller: _seller?.id?.toString() ?? '',
          from: range?.start,
          to: range?.end,
        ));
  }

  void _clear() {
    setState(() {
      _customer = null;
      _seller = null;
      initPeriod();
    });
    reload();
  }

  String get _period => [
        periodText,
        if (_customer != null) 'Customer: ${_customer!.name ?? ''}',
        if (_seller != null) 'Sold by: $_seller',
      ].join('  ·  ');

  static final List<ReportColumn<SalesReportModel>> _columns = [
    const ReportColumn.serial(),
    ReportColumn('Invoice', value: (r) => r.invoiceNo, bold: true, primary: true, flex: 2, minWidth: 120,
        color: (_) => _color),
    ReportColumn('Date', value: (r) => r.saleDate, kind: ReportKind.date, minWidth: 100),
    ReportColumn('Customer', value: (r) => r.customerName, secondary: true, flex: 3, minWidth: 150),
    ReportColumn('Sold by', value: (r) => r.salesBy, minWidth: 110),
    ReportColumn('Sales', value: (r) => r.salesPrice, kind: ReportKind.money, bold: true, highlight: true,
        minWidth: 110),
    ReportColumn('Cost', value: (r) => r.costPrice, kind: ReportKind.money, minWidth: 100),
    ReportColumn('Profit', value: (r) => r.profit, kind: ReportKind.money, minWidth: 100,
        color: (r) => r.profit < 0 ? AppColors.danger : AppColors.success),
    ReportColumn('Collected', value: (r) => r.collectAmount, kind: ReportKind.money, minWidth: 104),
    ReportColumn('Due', value: (r) => r.dueAmount, kind: ReportKind.money, minWidth: 96,
        color: (r) => r.dueAmount > 0 ? AppColors.danger : null),
    ReportColumn('Status', value: (r) => r.paymentStatus, kind: ReportKind.status, minWidth: 96),
  ];

  List<ReportStat> _stats(SalesReportSummary s) => [
        ReportStat('Total sales', ReportFmt.taka(s.totalSales), icon: Icons.point_of_sale_rounded, color: _color),
        ReportStat('Profit', ReportFmt.taka(s.totalProfit),
            icon: Icons.trending_up_rounded,
            color: s.totalProfit < 0 ? AppColors.danger : AppColors.success,
            hint: 'Average margin ${s.averageProfitMargin.toStringAsFixed(1)}%'),
        ReportStat('Collected', ReportFmt.taka(s.totalCollected),
            icon: Icons.payments_outlined, color: const Color(0xFF0D9488)),
        ReportStat('Due', ReportFmt.taka(s.totalDue), icon: Icons.hourglass_bottom_rounded, color: AppColors.danger),
        ReportStat('Invoices', '${s.totalTransactions}',
            icon: Icons.receipt_long_outlined, color: const Color(0xFF7C3AED)),
      ];

  List<ReportTotal> _totals(SalesReportSummary s) => [
        ReportTotal('Total sales', ReportFmt.taka(s.totalSales)),
        ReportTotal('Total cost', ReportFmt.taka(s.totalCost)),
        ReportTotal('Profit', ReportFmt.taka(s.totalProfit),
            color: s.totalProfit < 0 ? AppColors.danger : AppColors.success),
        ReportTotal('Collected', ReportFmt.taka(s.totalCollected)),
        ReportTotal('Due', ReportFmt.taka(s.totalDue), color: s.totalDue > 0 ? AppColors.danger : null),
      ];

  void _pdf(SalesReportResponse d) {
    final company = reportCompany(context);
    final period = _period;
    openReportPdf(
      context,
      title: _title,
      build: () => ReportPdf.build<SalesReportModel>(
        title: _title,
        period: period,
        company: company,
        accent: _color,
        stats: _stats(d.summary),
        columns: _columns,
        rows: d.report,
        totals: _totals(d.summary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesReportBloc, SalesReportState>(
      builder: (context, state) {
        final data = state is SalesReportSuccess ? state.response : null;
        final page = ReportPage(
          title: _title,
          subtitle: _period,
          icon: Icons.point_of_sale_rounded,
          color: _color,
          compact: widget.mobile,
          preset: preset,
          range: range,
          onRangeChanged: onPeriodChanged,
          filters: [
            ReportFilter(
              child: BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, _) => AppDropdown<CustomerActiveModel>(
                  key: ValueKey('customer-${_customer?.id}'),
                  label: 'Customer',
                  hint: 'All customers',
                  value: _customer,
                  itemList: context.read<CustomerBloc>().activeCustomer,
                  itemLabel: (c) => c.name ?? '',
                  onChanged: (v) {
                    setState(() => _customer = v);
                    reload();
                  },
                ),
              ),
            ),
            ReportFilter(
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, _) => AppDropdown<UsersListModel>(
                  key: ValueKey('seller-${_seller?.id}'),
                  label: 'Sold by',
                  hint: 'All sellers',
                  value: _seller,
                  itemList: context.read<UserBloc>().list,
                  onChanged: (v) {
                    setState(() => _seller = v);
                    reload();
                  },
                ),
              ),
            ),
          ],
          onClear: _clear,
          onRefresh: reload,
          onPdf: data == null ? null : () => _pdf(data),
          stats: data == null ? const [] : _stats(data.summary),
          loading: state is SalesReportLoading || state is SalesReportInitial,
          error: state is SalesReportFailed ? state.content : null,
          isEmpty: data != null && data.report.isEmpty,
          emptyTitle: 'No sales in this period',
          child: data == null
              ? null
              : ReportTable<SalesReportModel>(
                  columns: _columns,
                  rows: data.report,
                  totals: _totals(data.summary),
                  searchHint: 'Search invoice, customer or seller',
                ),
        );
        return wrapReport(mobile: widget.mobile, title: _title, page: page);
      },
    );
  }
}
