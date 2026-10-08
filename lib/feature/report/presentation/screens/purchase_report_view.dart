import 'package:meherinMart/core/core.dart';

import '../../../supplier/data/model/supplier_active_model.dart';
import '../../../supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';
import '../../data/model/purchase_report_model.dart';
import '../bloc/purchase_report/purchase_report_bloc.dart';
import '../kit/report_kit.dart';

/// Purchase Report — কোন সময়ে কত কেনা, কত পরিশোধ, কত বাকি (supplier ধরে)
class PurchaseReportView extends StatefulWidget {
  final bool mobile;

  const PurchaseReportView({super.key, this.mobile = false});

  @override
  State<PurchaseReportView> createState() => _PurchaseReportViewState();
}

class _PurchaseReportViewState extends State<PurchaseReportView> with ReportPeriodMixin {
  static const _title = 'Purchase Report';
  static const _color = Color(0xFF7C3AED);

  SupplierActiveModel? _supplier;

  @override
  void initState() {
    super.initState();
    initPeriod();
    context.read<SupplierInvoiceBloc>().add(FetchSupplierActiveList(context));
    reload();
  }

  @override
  void reload() {
    context.read<PurchaseReportBloc>().add(FetchPurchaseReport(
          context: context,
          supplier: _supplier?.id?.toString() ?? '',
          from: range?.start,
          to: range?.end,
        ));
  }

  void _clear() {
    setState(() {
      _supplier = null;
      initPeriod();
    });
    reload();
  }

  String get _period => [
        periodText,
        if (_supplier != null) 'Supplier: ${_supplier!.name ?? ''}',
      ].join('  ·  ');

  static final List<ReportColumn<PurchaseReportModel>> _columns = [
    const ReportColumn.serial(),
    ReportColumn('Invoice', value: (r) => r.invoiceNo, bold: true, primary: true, minWidth: 120,
        color: (_) => _color),
    ReportColumn('Date', value: (r) => r.purchaseDate, kind: ReportKind.date, minWidth: 100),
    ReportColumn('Supplier', value: (r) => r.supplier, secondary: true, flex: 3, minWidth: 160),
    ReportColumn('Net total', value: (r) => r.netTotal, kind: ReportKind.money, bold: true, highlight: true,
        minWidth: 110),
    ReportColumn('Paid', value: (r) => r.paidTotal, kind: ReportKind.money, minWidth: 104,
        color: (_) => AppColors.success),
    ReportColumn('Due', value: (r) => r.dueTotal, kind: ReportKind.money, minWidth: 100,
        color: (r) => r.dueTotal > 0 ? AppColors.danger : null),
    ReportColumn('Payment', value: (r) => r.paymentStatus, kind: ReportKind.status, minWidth: 100),
    ReportColumn('Status', value: (r) => ReportFmt.titleCase(r.status), minWidth: 96),
  ];

  List<ReportStat> _stats(PurchaseReportSummary s) => [
        ReportStat('Total purchase', ReportFmt.taka(s.totalPurchases),
            icon: Icons.local_shipping_outlined, color: _color),
        ReportStat('Paid', ReportFmt.taka(s.totalPaid), icon: Icons.task_alt_rounded, color: AppColors.success),
        ReportStat('Due to suppliers', ReportFmt.taka(s.totalDue),
            icon: Icons.hourglass_bottom_rounded, color: AppColors.danger),
        ReportStat('Invoices', '${s.totalTransactions}',
            icon: Icons.receipt_long_outlined, color: const Color(0xFF2563EB)),
      ];

  List<ReportTotal> _totals(PurchaseReportSummary s) => [
        ReportTotal('Total purchase', ReportFmt.taka(s.totalPurchases)),
        ReportTotal('Paid', ReportFmt.taka(s.totalPaid), color: AppColors.success),
        ReportTotal('Due', ReportFmt.taka(s.totalDue), color: s.totalDue > 0 ? AppColors.danger : null),
      ];

  void _pdf(PurchaseReportResponse d) {
    final company = reportCompany(context);
    final period = _period;
    openReportPdf(
      context,
      title: _title,
      build: () => ReportPdf.build<PurchaseReportModel>(
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
    return BlocBuilder<PurchaseReportBloc, PurchaseReportState>(
      builder: (context, state) {
        final data = state is PurchaseReportSuccess ? state.response : null;
        final page = ReportPage(
          title: _title,
          subtitle: _period,
          icon: Icons.local_shipping_outlined,
          color: _color,
          compact: widget.mobile,
          preset: preset,
          range: range,
          onRangeChanged: onPeriodChanged,
          filters: [
            ReportFilter(
              width: 260,
              child: BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
                builder: (context, _) => AppDropdown<SupplierActiveModel>(
                  key: ValueKey('supplier-${_supplier?.id}'),
                  label: 'Supplier',
                  hint: 'All suppliers',
                  value: _supplier,
                  itemList: context.read<SupplierInvoiceBloc>().supplierActiveList,
                  itemLabel: (s) => s.name ?? '',
                  onChanged: (v) {
                    setState(() => _supplier = v);
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
          loading: state is PurchaseReportLoading || state is PurchaseReportInitial,
          error: state is PurchaseReportFailed ? state.content : null,
          isEmpty: data != null && data.report.isEmpty,
          emptyTitle: 'No purchases in this period',
          child: data == null
              ? null
              : ReportTable<PurchaseReportModel>(
                  columns: _columns,
                  rows: data.report,
                  totals: _totals(data.summary),
                  searchHint: 'Search invoice or supplier',
                ),
        );
        return wrapReport(mobile: widget.mobile, title: _title, page: page);
      },
    );
  }
}
