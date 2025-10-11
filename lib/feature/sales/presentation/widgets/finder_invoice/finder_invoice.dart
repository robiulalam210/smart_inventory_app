import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/core/configs/gaps.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../../../core/configs/app_colors.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../transactions/data/models/invoice_sync_response_model.dart';
import '../../../../transactions/presentation/bloc/transaction_bloc/transaction_bloc.dart';
import '../../../../transactions/presentation/pages/invoice_details.dart';
import '../../bloc/finder_bloc/finder_bloc.dart';

class FinderTabView extends StatefulWidget {
  const FinderTabView({super.key});

  @override
  State<FinderTabView> createState() => _FinderTabViewState();
}

class _FinderTabViewState extends State<FinderTabView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // final ScrollController _verticalScrollController = ScrollController();
  // final ScrollController _horizontalScrollController = ScrollController();
// Create separate controllers for each tab
  final List<ScrollController> _verticalScrollControllers = [
    ScrollController(),
    ScrollController(),
  ];
  final List<ScrollController> _horizontalScrollControllers = [
    ScrollController(),
    ScrollController(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  void _loadInitialData() {
    final bloc = context.read<FinderBloc>();
    bloc.add(FetchInvoicesEvent());
    bloc.add(FetchInvoicesByUserEvent());
  }

  void _onSearchChanged() {
    final search = _searchController.text.trim();
    final bloc = context.read<FinderBloc>();

    if (_tabController.index == 0) {
      bloc.add(FetchInvoicesByUserEvent(search: search));
    } else {
      bloc.add(FetchInvoicesEvent(search: search));
    }
  }

  @override
  void dispose() {
    for (var c in _verticalScrollControllers) {
      c.dispose();
    }
    for (var c in _horizontalScrollControllers) {
      c.dispose();
    }
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12)),
          child: CustomSearchTextFormField(
            onClear: () {
              _searchController.clear();
              _onSearchChanged();
            },
            controller: _searchController,
            hintText: "Search Name, Invoice No",
            onChanged: (_) => _onSearchChanged(),
          ),
        ),
        gapH8,
        // Tabs
        Center(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),

          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: Colors.black87,
              dividerColor: Colors.transparent,
              // indicator: BoxDecoration(
              //   borderRadius: BorderRadius.circular(12),
              //   color: Theme.of(context).secondaryHeaderColor,
              // ),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.normal),
              tabs: const [
                Tab(text: 'User'),
                Tab(text: 'Invoices'),
              ],
              onTap: (_) => _onSearchChanged(),
            ),
          ),
        ),

        // Tab views
        Expanded(

          child: TabBarView(
            controller: _tabController,
            children: [
              _InvoiceListView(
                allInvoices: false,
                verticalScrollController: _verticalScrollControllers[1],
                horizontalScrollController: _horizontalScrollControllers[1],
              ),
              _InvoiceListView(
                allInvoices: true,
                verticalScrollController: _verticalScrollControllers[0],
                horizontalScrollController: _horizontalScrollControllers[0],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InvoiceListView extends StatelessWidget {
  final bool allInvoices;
  final ScrollController verticalScrollController;
  final ScrollController horizontalScrollController;

  const _InvoiceListView({
    required this.allInvoices,
    required this.verticalScrollController,
    required this.horizontalScrollController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinderBloc, FinderState>(
      buildWhen: (previous, current) {
        return allInvoices
                ? current is FinderLoading ||
                    current is FinderLoaded ||
                    current is FinderError
                // ||
                // current is FinderInitial
                : current is FinderInvoiceUserLoading ||
                    current is FinderInvoiceUserLoaded ||
                    current is FinderInvoiceUserError
            // ||
            // current is FinderInitial
            ;
      },
      builder: (context, state) {
        // Handle initial state
        if (state is FinderInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (allInvoices && state is FinderLoading ||
            !allInvoices && state is FinderInvoiceUserLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (allInvoices && state is FinderError ||
            !allInvoices && state is FinderInvoiceUserError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text('Error: ${state}'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => allInvoices
                      ? context.read<FinderBloc>().add(FetchInvoicesEvent())
                      : context
                          .read<FinderBloc>()
                          .add(FetchInvoicesByUserEvent()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final invoices = allInvoices
            ? (state as FinderLoaded).invoiceData.invoices ?? []
            : (state as FinderInvoiceUserLoaded).invoiceData.invoices ?? [];

        return InvoiceDataTable(
          invoices: invoices,
          verticalScrollController: verticalScrollController,
          horizontalScrollController: horizontalScrollController,
          onViewDetails: (invoice) => _showInvoiceDetails(invoice, context),
        );
      },
    );
  }

  void _showInvoiceDetails(InvoiceModelSync invoice, BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => InvoiceDetailsScreen(
        invoiceId: invoice.invoiceId.toString(),
        invoiceData: invoice,
      ),
    );
  }
}

class InvoiceDataTable extends StatelessWidget {
  final List<InvoiceModelSync> invoices;
  final Function(InvoiceModelSync) onViewDetails;
  final ScrollController verticalScrollController;
  final ScrollController horizontalScrollController;

  const InvoiceDataTable({
    super.key,
    required this.invoices,
    required this.onViewDetails,
    required this.verticalScrollController,
    required this.horizontalScrollController,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {

        final rows = invoices.isEmpty
            ? [_buildEmptyRow()]
            : invoices.map((e) => _buildDataRow(context, e)).toList();

        return Container(
          width: 1050,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Scrollbar(
            controller: verticalScrollController,
            thumbVisibility: true,
            thickness: 10,
            child: SingleChildScrollView(
              controller: verticalScrollController,
              scrollDirection: Axis.vertical,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Scrollbar(
                  controller: horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: horizontalScrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minWidth: constraints.minWidth),
                        child: DataTable(
                          dataRowMinHeight: 40,
                          dataRowMaxHeight: 40,
                          headingRowHeight: 40,
                          columnSpacing: 0,
                          checkboxHorizontalMargin: 0,
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          headingRowColor:
                              WidgetStateProperty.all(const Color(0xFF6ab129)),
                          columns: _buildDataColumns(constraints.maxWidth),
                          rows: rows,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildDataColumns(double maxWidth) {
    const columnLabels = [
      'Invoice',
      'Date',
      'Name',
      'Total Amount',
      'Discount',
      'Net Amount',
      'Received Amount',
      'Refund Amount',
      'Due',
      // 'P. Method',
      "Action"
    ];

    final columnWidth = (maxWidth / columnLabels.length)
        .toDouble()
        .clamp(60.0, double.infinity);
    return columnLabels.map((label) {
      return DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  DataRow _buildDataRow(BuildContext context, InvoiceModelSync invoice) {


    final discount = invoice.discount ?? 0.0;
    final total = invoice.totalBillAmount ?? 0.0;
    final netAmount = (total - discount).toStringAsFixed(2);

    return DataRow(
      cells: [
        _buildDataCell(invoice.invoiceNumber.toString()),
        _buildDataCell(_formatDate(invoice.createDate)),
        _buildDataCell(invoice.patient.name ?? ""),
        _buildDataCell((invoice.totalBillAmount ?? 0.0).toStringAsFixed(2)),
        _buildDataCell((invoice.discount ?? 0.0).toStringAsFixed(2)),
        _buildDataCell(netAmount),
        _buildDataCell((invoice.paidAmount ?? 0.0).toStringAsFixed(2)),
        _buildDataCell("0.0"), // Placeholder for refund
        _buildDataCell((invoice.due ?? 0.0).toStringAsFixed(2), isDue: true),
        _buildActionCell(context, invoice),
      ],
    );
  }
  DataRow _buildEmptyRow() {
    return DataRow(
      cells: [
        const DataCell(
          Center(
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                "",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        // Fill remaining cells with empty placeholders to match column count
        ...List.generate(9, (_) => const DataCell(Text(''))),
      ],
    );
  }

  DataCell _buildDataCell(String text, {bool isDue = false}) {
    final amount = isDue ? double.tryParse(text) ?? 0 : 0;
    return DataCell(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: isDue && amount > 0 ? Colors.red : Colors.black,
            fontWeight: isDue && amount > 0 ? FontWeight.w500 : null,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  DataCell _buildActionCell(BuildContext context, InvoiceModelSync invoice) {
    return DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'Print',
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(HugeIcons.strokeRoundedPrinter, size: 20),
              onPressed: () => _printInvoice(context, invoice),
            ),
          ),
          Tooltip(
            message: 'View Details',
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(HugeIcons.strokeRoundedFileView, size: 20),
              onPressed: () => onViewDetails(invoice),
            ),
          ),
        ],
      ),
    );
  }

  void _printInvoice(BuildContext context, InvoiceModelSync invoice) {
    final transactionBloc = context.read<TransactionBloc>();
    transactionBloc.add(LoadInvoiceTransactionDetails(
          invoice.invoiceNumber.toString(),  context, true));
    transactionBloc.add(LoadTransactionInvoices(pageSize: 10, pageNumber: 1));
  }


  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final parsedDate = DateTime.tryParse(date.toString());
    return parsedDate != null
        ? DateFormat('dd/MM/yyyy').format(parsedDate)
        : 'N/A';
  }
}

void showFinderInvoiceWidthDialog(BuildContext context) {
  final summaryBloc = context.read<FinderBloc>();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          backgroundColor: AppColors.white,
          child: BlocProvider.value(
            value: summaryBloc,
            child: SizedBox(
              width: 1100,
              height: 700, // total height adjusted to fit content
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // FinderTabView takes most of the height
                    Expanded(
                      child: FinderTabView(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppButton(
                          size: 150,
                          name: "Cancel",
                          color: AppColors.redColor,
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  });
}
