import 'dart:async';

import '/feature/transactions/presentation/bloc/refund/refund_bloc.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sidemenu/sidebar.dart';
import '../../../../core/utilities/app_date_time.dart';
import '../../../../core/utilities/app_debouncer.dart';
import '../../../../core/widgets/app_input_widgets.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/pagination_bar.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../../feature.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  final ValueNotifier<DateTimeRange?> _dateRange =
      ValueNotifier<DateTimeRange?>(null);
  final ValueNotifier<List<InvoiceModelSync>> _filteredInvoices =
      ValueNotifier<List<InvoiceModelSync>>([]);
  final AppDebouncer _searchDebouncer = AppDebouncer(millisecond: 500);

  List<InvoiceModelSync> _allInvoices = [];

// default value
  int currentPage = 1;
  int itemsPerPage = 20;

  @override
  void initState() {
    super.initState();
    _loadInvoices();

    // Add search listener with debounce
    _searchController.addListener(() {
      _searchDebouncer.run(() {
        _applyFiltersAndFetch();
      });
    });

    // Add date range listener to refetch when date range changes
    _dateRange.addListener(() {
      _applyFiltersAndFetch();
    });
  }

  Future<void> _loadInvoices({
    String? query,
    DateTime? from,
    DateTime? to,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    context.read<PrintLayoutBloc>().add(FetchPrintLayout());
    context.read<TransactionBloc>().add(LoadTransactionInvoices(
          query: query ?? '',
          fromDate: from,
          toDate: to,
          pageNumber: pageNumber,
          pageSize: pageSize,
        ));

    context.read<PrintLayoutBloc>().add(FetchPrintLayout());
  }

  void _applyFiltersAndFetch() {
    final query = _searchController.text.trim();
    final range = _dateRange.value;

    _filteredInvoices.value = []; // Clear old filtered list while loading
    _loadInvoices(
        query: query.isEmpty ? null : query,
        from: range?.start,
        to: range?.end,
        pageNumber: currentPage,
        pageSize: itemsPerPage);
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    _searchController.dispose();
    _filteredInvoices.dispose();
    _dateRange.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final syncBloc = context.read<SyncBloc>();
    return Container(
      color: AppColors.bg,
      child: SafeArea(
        child: Stack(
          children: [
            _buildMainContent(),
            BlocBuilder<SyncBloc, SyncState>(
              builder: (context, state) {
                if (state is SyncInProgress) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Synchronizing Data',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(
                              value: state.percentage / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${state.progress}/${state.total} (${state.percentage.toStringAsFixed(1)}%)',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          if (state.currentOperation.isNotEmpty)
                            Text(
                              state.currentOperation,
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMainContent() {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return ResponsiveRow(
      spacing: 0,
      runSpacing: 0,
      children: [
        if (isBigScreen) _buildSidebar(),
        _buildContentArea(isBigScreen),
      ],
    );
  }

  Widget _buildSidebar() {
    return ResponsiveCol(
      xs: 0,
      sm: 1,
      md: 1,
      lg: 2,
      xl: 2,
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: const Sidebar(),
      ),
    );
  }

  Widget _buildContentArea(bool isBigScreen) {
    return ResponsiveCol(
      xs: 12,
      sm: 12,
      md: 12,
      lg: 10,
      xl: 10,
      child: Container(
        color: AppColors.bg,
        child: _buildInvoiceContent(),
      ),
    );
  }

  Widget _buildInvoiceContent() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      buildWhen: (previous, current) =>
          current is TransactionInvoicesLoading ||
          current is TransactionInvoicesError ||
          current is TransactionInvoicesLoaded,
      builder: (context, state) {
        if (state is TransactionInvoicesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TransactionInvoicesError) {
          return Center(child: Text(state.error));
        }
        if (state is TransactionInvoicesLoaded) {
          _allInvoices = state.invoices.invoices ?? [];

          _filteredInvoices.value = _allInvoices;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchAndFilterSection(),
                InvoiceSummaryBoxes(summaryModel: state.invoices.summary),
                ValueListenableBuilder<List<InvoiceModelSync>>(
                  valueListenable: _filteredInvoices,
                  builder: (context, filteredInvoices, _) {
                    return _buildInvoiceTable(filteredInvoices);
                  },
                ),
                gapH8,
                if ((state.invoices.totalCount ?? 0) > 0)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PaginationFooter(
                        currentPage: currentPage,
                        totalItems: state.invoices.totalCount ?? 1,
                        itemsPerPage: itemsPerPage,
                        // ✅ use your local variable
                        onPageChanged: (newPage) {
                          setState(() {
                            currentPage = newPage;
                            _loadInvoices(
                              pageNumber: currentPage,
                              pageSize: itemsPerPage,
                            );
                          });
                        },
                        onPageSizeChanged: (newSize) {
                          setState(() {
                            itemsPerPage = newSize;
                            currentPage =
                                1; // ✅ reset to first page when page size changes
                            _loadInvoices(
                              pageNumber: currentPage,
                              pageSize: itemsPerPage,
                            );
                          });
                        },
                      ),
                    ],
                  )
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(color: Colors.white),
              child: CustomSearchTextFormField(
                onClear: () {
                  _searchController.clear();
                  _applyFiltersAndFetch();
                },
                controller: _searchController,
                hintText: "Search Name, Invoice No",
                onChanged: (String value) {
                  // No manual call needed, handled by listener + debounce
                },
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          _buildDateRangeFilter(),
          _buildClearFilterButton(),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return StatusButtonWhite(
      isSelected: true,
      onPressed: () {
        appDateRangePicker(context, initialDateRange: _dateRange.value)
            .then((value) {
          if (value != null) {
            _dateRange.value = value;
          }
        });
      },
      child: ValueListenableBuilder<DateTimeRange?>(
        valueListenable: _dateRange,
        builder: (_, value, __) {
          return Text(
            "${formatDateTime(dateTime: value?.start, format: "dd MMM yyyy") ?? "From"} - ${formatDateTime(dateTime: value?.end, format: "dd MMM yyyy") ?? "To"}",
            style: AppSizes.normalBold(context)
                .copyWith(color: AppColors.primary(context)),
          );
        },
      ),
    );
  }

  Widget _buildClearFilterButton() {
    return TextButton(
      onPressed: () {
        _dateRange.value = null;
        _searchController.clear();
        _applyFiltersAndFetch();
      },
      child: const Text("Clear"),
    );
  }

  Widget _buildInvoiceTable(List<InvoiceModelSync> invoices) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth * 1.5, // same trick here
          ),
          child: InvoiceDataTable(
            invoices: invoices,
            verticalScrollController: _verticalScrollController,
            horizontalScrollController: _horizontalScrollController,
            onViewDetails: _showInvoiceDetails,
            onCollectPayment: _showPaymentDialog,
          ),
        );
      },
    );
  }

  void _showInvoiceDetails(InvoiceModelSync invoice) {
    showDialog(
      context: context,
      builder: (_) => InvoiceDetailsScreen(
        invoiceId: invoice.invoiceId.toString(),
        invoiceData: invoice,
      ),
    );
  }

  void _showPaymentDialog(
      InvoiceModelSync invoice, double dueAmount, double paidAmount) {
    showDialog(
      context: context,
      builder: (context) => SizedBox(
        width: 750,
        height: 500,
        child: InvoiceDueCollectionDialog(
          invoiceId: invoice.invoiceId.toString(),
          dueAmount: dueAmount,
          items: invoice,
          paidAmount: paidAmount,
        ),
      ),
    );
  }
}
