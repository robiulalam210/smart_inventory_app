import 'package:meherinMart/core/core.dart';

import '../../../customer/data/model/customer_active_model.dart';
import '../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../supplier/data/model/supplier_active_model.dart';
import '../../../supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';
import '../../data/model/customer_due_advance_report_model.dart';
import '../../data/model/customer_ledger_model.dart';
import '../../data/model/supplier_due_advance_report_model.dart';
import '../../data/model/supplier_ledger_model.dart';
import '../bloc/customer_due_advance_bloc/customer_due_advance_bloc.dart';
import '../bloc/customer_ledger_bloc/customer_ledger_bloc.dart';
import '../bloc/supplier_due_advance_bloc/supplier_due_advance_bloc.dart';
import '../bloc/supplier_ledger_bloc/supplier_ledger_bloc.dart';
import '../kit/report_kit.dart';

/// Due / Advance এর অবস্থা — বাকি আছে, অগ্রিম আছে, নাকি হিসাব মিটে গেছে
String _balanceState(double due, double advance) => due > 0
    ? 'Due'
    : advance > 0
        ? 'Advance'
        : 'Settled';

Color _balanceColor(String s) => switch (s) {
      'Due' => AppColors.danger,
      'Advance' => AppColors.success,
      _ => const Color(0xFF64748B),
    };

/// "আগে একজন বাছুন" — ledger একজনের হিসাব, তাই customer / supplier ছাড়া দেখানো হয় না
Widget _pickPrompt(String who, IconData icon, Color color) => ReportMessage(
      icon: icon,
      color: color,
      title: 'Select a $who',
      message: 'A ledger shows every sale, payment and the running balance for one $who. '
          'Choose a $who above to see it.',
    );

const _statusOptions = ['due', 'advance'];
String _statusLabel(String s) => s == 'due' ? 'Due only' : 'Advance only';

// ═════════════════════════ Customer ledger ═════════════════════════

class CustomerLedgerView extends StatefulWidget {
  final bool mobile;

  const CustomerLedgerView({super.key, this.mobile = false});

  @override
  State<CustomerLedgerView> createState() => _CustomerLedgerViewState();
}

class _CustomerLedgerViewState extends State<CustomerLedgerView> with ReportPeriodMixin {
  static const _title = 'Customer Ledger';
  static const _color = Color(0xFF4F46E5);

  CustomerActiveModel? _customer;

  @override
  ReportRangePreset get defaultPreset => ReportRangePreset.allTime;

  @override
  void initState() {
    super.initState();
    initPeriod();
    context.read<CustomerBloc>().add(FetchCustomerActiveList(context));
  }

  @override
  void reload() {
    if (_customer == null) return;
    context.read<CustomerLedgerBloc>().add(FetchCustomerLedger(
          context: context,
          customer: _customer!.id?.toString(),
          from: range?.start,
          to: range?.end,
        ));
  }

  void _clear() {
    setState(() {
      _customer = null;
      initPeriod();
    });
  }

  String get _period => [
        if (_customer != null) _customer!.name ?? '',
        periodText,
      ].join('  ·  ');

  static final List<ReportColumn<CustomerLedgerTransaction>> _columns = [
    const ReportColumn.serial(),
    ReportColumn('Date', value: (r) => r.date, kind: ReportKind.date, secondary: true, minWidth: 100),
    ReportColumn('Voucher', value: (r) => r.voucherNo, bold: true, minWidth: 110, color: (_) => _color),
    ReportColumn('Particular', value: (r) => r.particular, primary: true, flex: 4, minWidth: 180,
        subtitle: (r) => r.details.trim().isEmpty ? null : r.details),
    ReportColumn('Method', value: (r) => ReportFmt.titleCase(r.method), minWidth: 90),
    ReportColumn('Debit', value: (r) => r.debit, kind: ReportKind.money, minWidth: 104),
    ReportColumn('Credit', value: (r) => r.credit, kind: ReportKind.money, minWidth: 104,
        color: (r) => r.credit > 0 ? AppColors.success : null),
    ReportColumn('Balance', value: (r) => r.due, kind: ReportKind.money, bold: true, highlight: true, minWidth: 114,
        color: (r) => r.due > 0 ? AppColors.danger : (r.due < 0 ? AppColors.success : null)),
  ];

  (double, double) _sums(List<CustomerLedgerTransaction> rows) => (
        rows.fold<double>(0, (s, r) => s + r.debit),
        rows.fold<double>(0, (s, r) => s + r.credit),
      );

  List<ReportStat> _stats(CustomerLedgerResponse d) {
    final (debit, credit) = _sums(d.report);
    final close = d.summary.closingBalance;
    return [
      ReportStat('Transactions', '${d.summary.totalTransactions}', icon: Icons.swap_vert_rounded, color: _color),
      ReportStat('Total debit (sales)', ReportFmt.taka(debit), icon: Icons.north_east_rounded, color: AppColors.info),
      ReportStat('Total credit (paid)', ReportFmt.taka(credit), icon: Icons.south_west_rounded, color: AppColors.success),
      ReportStat(close > 0 ? 'Closing due' : (close < 0 ? 'Closing advance' : 'Closing balance'),
          ReportFmt.taka(close.abs()),
          icon: Icons.account_balance_wallet_outlined, color: close > 0 ? AppColors.danger : AppColors.success),
    ];
  }

  List<ReportTotal> _totals(CustomerLedgerResponse d) {
    final (debit, credit) = _sums(d.report);
    final close = d.summary.closingBalance;
    return [
      ReportTotal('Total debit', ReportFmt.taka(debit)),
      ReportTotal('Total credit', ReportFmt.taka(credit), color: AppColors.success),
      ReportTotal('Closing balance', ReportFmt.taka(close), color: close > 0 ? AppColors.danger : AppColors.success),
    ];
  }

  void _pdf(CustomerLedgerResponse d) {
    final company = reportCompany(context);
    final period = _period;
    openReportPdf(
      context,
      title: _title,
      build: () => ReportPdf.build<CustomerLedgerTransaction>(
        title: _title,
        period: period,
        company: company,
        accent: _color,
        stats: _stats(d),
        columns: _columns,
        rows: d.report,
        totals: _totals(d),
        note: 'Debit = amount the customer owes (sales). Credit = payments received. '
            'Balance = running due (negative means advance).',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerLedgerBloc, CustomerLedgerState>(
      builder: (context, state) {
        final data = _customer != null && state is CustomerLedgerSuccess ? state.response : null;
        final page = ReportPage(
          title: _title,
          subtitle: _customer == null ? 'Select a customer to see their ledger' : _period,
          icon: Icons.menu_book_outlined,
          color: _color,
          compact: widget.mobile,
          preset: preset,
          range: range,
          onRangeChanged: onPeriodChanged,
          filters: [
            ReportFilter(
              width: 280,
              child: BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, _) => AppDropdown<CustomerActiveModel>(
                  key: ValueKey('ledger-customer-${_customer?.id}'),
                  label: 'Customer',
                  hint: 'Select customer',
                  value: _customer,
                  itemList: context.read<CustomerBloc>().activeCustomer,
                  itemLabel: (c) => [c.name ?? '', if ((c.phone ?? '').isNotEmpty) c.phone!].join(' · '),
                  onChanged: (v) {
                    setState(() => _customer = v);
                    reload();
                  },
                ),
              ),
            ),
          ],
          onClear: _clear,
          onRefresh: reload,
          onPdf: data == null ? null : () => _pdf(data),
          stats: data == null ? const [] : _stats(data),
          prompt: _customer == null ? _pickPrompt('customer', Icons.person_search_outlined, _color) : null,
          loading: _customer != null && (state is CustomerLedgerLoading || state is CustomerLedgerInitial),
          error: _customer != null && state is CustomerLedgerFailed ? state.content : null,
          isEmpty: data != null && data.report.isEmpty,
          emptyTitle: 'No transactions in this period',
          child: data == null
              ? null
              : ReportTable<CustomerLedgerTransaction>(
                  columns: _columns,
                  rows: data.report,
                  totals: _totals(data),
                  searchHint: 'Search voucher or particular',
                ),
        );
        return wrapReport(mobile: widget.mobile, title: _title, page: page);
      },
    );
  }
}

// ═════════════════════════ Customer due / advance ═════════════════════════

class CustomerDueAdvanceView extends StatefulWidget {
  final bool mobile;

  const CustomerDueAdvanceView({super.key, this.mobile = false});

  @override
  State<CustomerDueAdvanceView> createState() => _CustomerDueAdvanceViewState();
}

class _CustomerDueAdvanceViewState extends State<CustomerDueAdvanceView> with ReportPeriodMixin {
  static const _title = 'Customer Due & Advance';
  static const _color = Color(0xFFEA580C);

  CustomerActiveModel? _customer;
  String? _status;

  /// "এখন কার কাছে কত পাওনা" — তাই সব সময়ের হিসাব দিয়ে শুরু
  @override
  ReportRangePreset get defaultPreset => ReportRangePreset.allTime;

  @override
  void initState() {
    super.initState();
    initPeriod();
    context.read<CustomerBloc>().add(FetchCustomerActiveList(context));
    reload();
  }

  @override
  void reload() {
    context.read<CustomerDueAdvanceBloc>().add(FetchCustomerDueAdvanceReport(
          context: context,
          from: range?.start,
          to: range?.end,
          customerId: _customer?.id,
          status: _status,
        ));
  }

  void _clear() {
    setState(() {
      _customer = null;
      _status = null;
      initPeriod();
    });
    reload();
  }

  String get _period => [
        periodText,
        if (_customer != null) 'Customer: ${_customer!.name ?? ''}',
        if (_status != null) _statusLabel(_status!),
      ].join('  ·  ');

  static final List<ReportColumn<CustomerDueAdvance>> _columns = [
    const ReportColumn.serial(),
    ReportColumn('Customer', value: (r) => r.customerName, bold: true, primary: true, flex: 4, minWidth: 190,
        subtitle: (r) => r.customerNo.isEmpty ? null : r.customerNo),
    ReportColumn('Phone', value: (r) => r.phone, secondary: true, minWidth: 120),
    ReportColumn('Due', value: (r) => r.presentDue, kind: ReportKind.money, bold: true, highlight: true,
        minWidth: 120, color: (r) => r.presentDue > 0 ? AppColors.danger : null),
    ReportColumn('Advance', value: (r) => r.presentAdvance, kind: ReportKind.money, minWidth: 120,
        color: (r) => r.presentAdvance > 0 ? AppColors.success : null),
    ReportColumn('Status', value: (r) => _balanceState(r.presentDue, r.presentAdvance), kind: ReportKind.status,
        minWidth: 100, color: (r) => _balanceColor(_balanceState(r.presentDue, r.presentAdvance))),
  ];

  List<ReportStat> _stats(CustomerDueAdvanceSummary s) => [
        ReportStat('Customers', '${s.totalCustomers}', icon: Icons.people_alt_outlined, color: _color),
        ReportStat('Total due (receivable)', ReportFmt.taka(s.totalDueAmount),
            icon: Icons.call_received_rounded, color: AppColors.danger),
        ReportStat('Total advance', ReportFmt.taka(s.totalAdvanceAmount),
            icon: Icons.savings_outlined, color: AppColors.success),
        ReportStat('Net receivable', ReportFmt.taka(s.netBalance),
            icon: Icons.account_balance_outlined, color: AppColors.info, hint: 'Due minus advance'),
      ];

  List<ReportTotal> _totals(CustomerDueAdvanceSummary s) => [
        ReportTotal('Total due', ReportFmt.taka(s.totalDueAmount), color: AppColors.danger),
        ReportTotal('Total advance', ReportFmt.taka(s.totalAdvanceAmount), color: AppColors.success),
        ReportTotal('Net receivable', ReportFmt.taka(s.netBalance)),
      ];

  void _pdf(CustomerDueAdvanceResponse d) {
    final company = reportCompany(context);
    final period = _period;
    openReportPdf(
      context,
      title: _title,
      build: () => ReportPdf.build<CustomerDueAdvance>(
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
    return BlocBuilder<CustomerDueAdvanceBloc, CustomerDueAdvanceState>(
      builder: (context, state) {
        final data = state is CustomerDueAdvanceSuccess ? state.response : null;
        final page = ReportPage(
          title: _title,
          subtitle: _period,
          icon: Icons.account_balance_wallet_outlined,
          color: _color,
          compact: widget.mobile,
          preset: preset,
          range: range,
          onRangeChanged: onPeriodChanged,
          filters: [
            ReportFilter(
              width: 260,
              child: BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, _) => AppDropdown<CustomerActiveModel>(
                  key: ValueKey('due-customer-${_customer?.id}'),
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
              width: 180,
              child: AppDropdown<String>(
                key: ValueKey('due-status-$_status'),
                label: 'Status',
                hint: 'Due & advance',
                value: _status,
                itemList: _statusOptions,
                itemLabel: _statusLabel,
                onChanged: (v) {
                  setState(() => _status = v);
                  reload();
                },
              ),
            ),
          ],
          onClear: _clear,
          onRefresh: reload,
          onPdf: data == null ? null : () => _pdf(data),
          stats: data == null ? const [] : _stats(data.summary),
          loading: state is CustomerDueAdvanceLoading || state is CustomerDueAdvanceInitial,
          error: state is CustomerDueAdvanceFailed ? state.content : null,
          isEmpty: data != null && data.report.isEmpty,
          emptyTitle: 'No dues or advances',
          emptyMessage: 'Every customer account is settled for this period.',
          child: data == null
              ? null
              : ReportTable<CustomerDueAdvance>(
                  columns: _columns,
                  rows: data.report,
                  totals: _totals(data.summary),
                  searchHint: 'Search customer or phone',
                ),
        );
        return wrapReport(mobile: widget.mobile, title: _title, page: page);
      },
    );
  }
}

// ═════════════════════════ Supplier ledger ═════════════════════════

class SupplierLedgerView extends StatefulWidget {
  final bool mobile;

  const SupplierLedgerView({super.key, this.mobile = false});

  @override
  State<SupplierLedgerView> createState() => _SupplierLedgerViewState();
}

class _SupplierLedgerViewState extends State<SupplierLedgerView> with ReportPeriodMixin {
  static const _title = 'Supplier Ledger';
  static const _color = Color(0xFF9333EA);

  SupplierActiveModel? _supplier;

  @override
  ReportRangePreset get defaultPreset => ReportRangePreset.allTime;

  @override
  void initState() {
    super.initState();
    initPeriod();
    context.read<SupplierInvoiceBloc>().add(FetchSupplierActiveList(context));
  }

  @override
  void reload() {
    if (_supplier == null) return;
    context.read<SupplierLedgerBloc>().add(FetchSupplierLedgerReport(
          context: context,
          supplierId: _supplier!.id,
          from: range?.start,
          to: range?.end,
        ));
  }

  void _clear() {
    setState(() {
      _supplier = null;
      initPeriod();
    });
  }

  String get _period => [
        if (_supplier != null) _supplier!.name ?? '',
        periodText,
      ].join('  ·  ');

  static final List<ReportColumn<SupplierLedger>> _columns = [
    const ReportColumn.serial(),
    ReportColumn('Date', value: (r) => r.date, kind: ReportKind.date, secondary: true, minWidth: 100),
    ReportColumn('Voucher', value: (r) => r.voucherNo, bold: true, minWidth: 110, color: (_) => _color),
    ReportColumn('Particular', value: (r) => r.particular, primary: true, flex: 4, minWidth: 180,
        subtitle: (r) => r.details.trim().isEmpty ? null : r.details),
    ReportColumn('Method', value: (r) => ReportFmt.titleCase(r.method), minWidth: 90),
    ReportColumn('Debit', value: (r) => r.debit, kind: ReportKind.money, minWidth: 104),
    ReportColumn('Credit', value: (r) => r.credit, kind: ReportKind.money, minWidth: 104),
    ReportColumn('Balance', value: (r) => r.due, kind: ReportKind.money, bold: true, highlight: true, minWidth: 114,
        color: (r) => r.due > 0 ? AppColors.danger : (r.due < 0 ? AppColors.success : null)),
  ];

  List<ReportStat> _stats(SupplierLedgerSummary s) => [
        ReportStat('Opening balance', ReportFmt.taka(s.openingBalance),
            icon: Icons.flag_outlined, color: const Color(0xFF64748B)),
        ReportStat('Total debit', ReportFmt.taka(s.totalDebit), icon: Icons.north_east_rounded, color: AppColors.info),
        ReportStat('Total credit', ReportFmt.taka(s.totalCredit),
            icon: Icons.south_west_rounded, color: AppColors.success),
        ReportStat('Closing balance', ReportFmt.taka(s.closingBalance),
            icon: Icons.account_balance_wallet_outlined,
            color: s.closingBalance > 0 ? AppColors.danger : AppColors.success),
        ReportStat('Transactions', '${s.totalTransactions}', icon: Icons.swap_vert_rounded, color: _color),
      ];

  List<ReportTotal> _totals(SupplierLedgerSummary s) => [
        ReportTotal('Opening', ReportFmt.taka(s.openingBalance)),
        ReportTotal('Total debit', ReportFmt.taka(s.totalDebit)),
        ReportTotal('Total credit', ReportFmt.taka(s.totalCredit)),
        ReportTotal('Closing balance', ReportFmt.taka(s.closingBalance),
            color: s.closingBalance > 0 ? AppColors.danger : AppColors.success),
      ];

  void _pdf(SupplierLedgerResponse d) {
    final company = reportCompany(context);
    final period = _period;
    openReportPdf(
      context,
      title: _title,
      build: () => ReportPdf.build<SupplierLedger>(
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
    return BlocBuilder<SupplierLedgerBloc, SupplierLedgerState>(
      builder: (context, state) {
        final data = _supplier != null && state is SupplierLedgerSuccess ? state.response : null;
        final page = ReportPage(
          title: _title,
          subtitle: _supplier == null ? 'Select a supplier to see their ledger' : _period,
          icon: Icons.menu_book_outlined,
          color: _color,
          compact: widget.mobile,
          preset: preset,
          range: range,
          onRangeChanged: onPeriodChanged,
          filters: [
            ReportFilter(
              width: 280,
              child: BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
                builder: (context, _) => AppDropdown<SupplierActiveModel>(
                  key: ValueKey('ledger-supplier-${_supplier?.id}'),
                  label: 'Supplier',
                  hint: 'Select supplier',
                  value: _supplier,
                  itemList: context.read<SupplierInvoiceBloc>().supplierActiveList,
                  itemLabel: (s) => [s.name ?? '', if ((s.phone ?? '').isNotEmpty) s.phone!].join(' · '),
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
          prompt: _supplier == null ? _pickPrompt('supplier', Icons.store_mall_directory_outlined, _color) : null,
          loading: _supplier != null && (state is SupplierLedgerLoading || state is SupplierLedgerInitial),
          error: _supplier != null && state is SupplierLedgerFailed ? state.content : null,
          isEmpty: data != null && data.report.isEmpty,
          emptyTitle: 'No transactions in this period',
          child: data == null
              ? null
              : ReportTable<SupplierLedger>(
                  columns: _columns,
                  rows: data.report,
                  totals: _totals(data.summary),
                  searchHint: 'Search voucher or particular',
                ),
        );
        return wrapReport(mobile: widget.mobile, title: _title, page: page);
      },
    );
  }
}

// ═════════════════════════ Supplier due / advance ═════════════════════════

class SupplierDueAdvanceView extends StatefulWidget {
  final bool mobile;

  const SupplierDueAdvanceView({super.key, this.mobile = false});

  @override
  State<SupplierDueAdvanceView> createState() => _SupplierDueAdvanceViewState();
}

class _SupplierDueAdvanceViewState extends State<SupplierDueAdvanceView> with ReportPeriodMixin {
  static const _title = 'Supplier Due & Advance';
  static const _color = Color(0xFF0891B2);

  /// server এ এই report এ status filter নেই — তাই screen এই বাছাই হয়
  String? _status;

  @override
  ReportRangePreset get defaultPreset => ReportRangePreset.allTime;

  @override
  void initState() {
    super.initState();
    initPeriod();
    reload();
  }

  @override
  void reload() {
    context
        .read<SupplierDueAdvanceBloc>()
        .add(FetchSupplierDueAdvanceReport(context: context, from: range?.start, to: range?.end));
  }

  void _clear() {
    setState(() {
      _status = null;
      initPeriod();
    });
    reload();
  }

  List<SupplierDueAdvance> _rows(List<SupplierDueAdvance> all) => switch (_status) {
        'due' => all.where((r) => r.presentDue > 0).toList(),
        'advance' => all.where((r) => r.presentAdvance > 0).toList(),
        _ => all,
      };

  String get _period => [periodText, if (_status != null) _statusLabel(_status!)].join('  ·  ');

  static final List<ReportColumn<SupplierDueAdvance>> _columns = [
    const ReportColumn.serial(),
    ReportColumn('Supplier', value: (r) => r.supplierName, bold: true, primary: true, flex: 4, minWidth: 190,
        subtitle: (r) => r.supplierNo == 0 ? null : 'No. ${r.supplierNo}'),
    ReportColumn('Phone', value: (r) => r.phone, secondary: true, minWidth: 120),
    ReportColumn('Due (payable)', value: (r) => r.presentDue, kind: ReportKind.money, bold: true, highlight: true,
        minWidth: 130, color: (r) => r.presentDue > 0 ? AppColors.danger : null),
    ReportColumn('Advance', value: (r) => r.presentAdvance, kind: ReportKind.money, minWidth: 120,
        color: (r) => r.presentAdvance > 0 ? AppColors.success : null),
    ReportColumn('Status', value: (r) => _balanceState(r.presentDue, r.presentAdvance), kind: ReportKind.status,
        minWidth: 100, color: (r) => _balanceColor(_balanceState(r.presentDue, r.presentAdvance))),
  ];

  List<ReportStat> _stats(SupplierDueAdvanceSummary s) => [
        ReportStat('Suppliers', '${s.totalSuppliers}', icon: Icons.storefront_outlined, color: _color),
        ReportStat('Total due (payable)', ReportFmt.taka(s.totalDueAmount),
            icon: Icons.call_made_rounded, color: AppColors.danger),
        ReportStat('Total advance', ReportFmt.taka(s.totalAdvanceAmount),
            icon: Icons.savings_outlined, color: AppColors.success),
        ReportStat('Net payable', ReportFmt.taka(s.netBalance),
            icon: Icons.account_balance_outlined, color: AppColors.info, hint: 'Due minus advance'),
      ];

  List<ReportTotal> _totals(List<SupplierDueAdvance> rows) => [
        ReportTotal('Total due', ReportFmt.taka(rows.fold<double>(0, (s, r) => s + r.presentDue)),
            color: AppColors.danger),
        ReportTotal('Total advance', ReportFmt.taka(rows.fold<double>(0, (s, r) => s + r.presentAdvance)),
            color: AppColors.success),
      ];

  void _pdf(SupplierDueAdvanceResponse d) {
    final company = reportCompany(context);
    final period = _period;
    final rows = _rows(d.report);
    openReportPdf(
      context,
      title: _title,
      build: () => ReportPdf.build<SupplierDueAdvance>(
        title: _title,
        period: period,
        company: company,
        accent: _color,
        stats: _stats(d.summary),
        columns: _columns,
        rows: rows,
        totals: _totals(rows),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupplierDueAdvanceBloc, SupplierDueAdvanceState>(
      builder: (context, state) {
        final data = state is SupplierDueAdvanceSuccess ? state.response : null;
        final rows = data == null ? const <SupplierDueAdvance>[] : _rows(data.report);
        final page = ReportPage(
          title: _title,
          subtitle: _period,
          icon: Icons.account_balance_outlined,
          color: _color,
          compact: widget.mobile,
          preset: preset,
          range: range,
          onRangeChanged: onPeriodChanged,
          filters: [
            ReportFilter(
              width: 180,
              child: AppDropdown<String>(
                key: ValueKey('sdue-status-$_status'),
                label: 'Status',
                hint: 'Due & advance',
                value: _status,
                itemList: _statusOptions,
                itemLabel: _statusLabel,
                onChanged: (v) => setState(() => _status = v),
              ),
            ),
          ],
          onClear: _clear,
          onRefresh: reload,
          onPdf: data == null ? null : () => _pdf(data),
          stats: data == null ? const [] : _stats(data.summary),
          loading: state is SupplierDueAdvanceLoading || state is SupplierDueAdvanceInitial,
          error: state is SupplierDueAdvanceFailed ? state.content : null,
          isEmpty: data != null && rows.isEmpty,
          emptyTitle: 'No dues or advances',
          emptyMessage: 'Every supplier account is settled for this period.',
          child: data == null
              ? null
              : ReportTable<SupplierDueAdvance>(
                  columns: _columns,
                  rows: rows,
                  totals: _totals(rows),
                  searchHint: 'Search supplier or phone',
                ),
        );
        return wrapReport(mobile: widget.mobile, title: _title, page: page);
      },
    );
  }
}
