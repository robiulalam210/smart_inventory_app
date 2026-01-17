import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/date_range.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../../../transactions/presentation/bloc/transactions/transaction_bloc.dart';
import '../../../transactions/presentation/widget/widget.dart';

class MobileTransactionScreen extends StatefulWidget {
  const MobileTransactionScreen({super.key});

  @override
  State<MobileTransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<MobileTransactionScreen> {
  final TextEditingController filterTextController = TextEditingController();
  final ValueNotifier<String?> selectedTransactionTypeNotifier = ValueNotifier(null);
  final ValueNotifier<String?> selectedStatusNotifier = ValueNotifier(null);
  final ValueNotifier<String?> selectedAccountNotifier = ValueNotifier(null);

  // Use DateRange instead of separate DateTime variables
  DateRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    filterTextController.clear();

    // Initialize with default date range (last month)
    final DateTime now = DateTime.now();

// First day of previous month
    final DateTime startDate = DateTime(
      now.year,
      now.month - 1,
      1,
    );

// Last day of previous month
    final DateTime endDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    selectedDateRange = DateRange(startDate, endDate);


    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTransactions();
    });
  }

  @override
  void dispose() {
    filterTextController.dispose();
    selectedTransactionTypeNotifier.dispose();
    selectedStatusNotifier.dispose();
    selectedAccountNotifier.dispose();
    super.dispose();
  }

  void _fetchTransactions({
    String filterText = '',
    String transactionType = '',
    String status = '',
    String accountId = '',
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    if (!mounted) return;

    context.read<TransactionBloc>().add(
      FetchTransactionList(
        context,
        filterText: filterText,
        transactionType: transactionType,
        status: status,
        accountId: accountId,
        // Use DateRange values
        startDate: selectedDateRange?.start,
        endDate: selectedDateRange?.end,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  void _fetchTransactionList({int pageNumber = 1, int pageSize = 10}) {
    _fetchTransactions(
      pageNumber: pageNumber,
      pageSize: pageSize,
      filterText: filterTextController.text,
      transactionType: selectedTransactionTypeNotifier.value?.toString() ?? '',
      status: selectedStatusNotifier.value?.toString() ?? '',
      accountId: selectedAccountNotifier.value?.toString() ?? '',
    );
  }


  void _clearDateRange() {
    setState(() {
      selectedDateRange = null;
    });
    _fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title:  Text("Transaction",style: AppTextStyle.titleMedium(context),)),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryColor(context),
          onRefresh: () async {
            _fetchTransactions();
          },
          child: SingleChildScrollView(
            padding: AppTextStyle.getResponsivePaddingBody(context),
            child: Column(
              children: [
                _buildMobileHeader(),
                const SizedBox(height: 8),
                SizedBox(
                  child: _buildTransactionList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildMobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: CustomSearchTextFormField(
                    isRequiredLabel: false,
                    controller: filterTextController,
                    onChanged: (value) => _fetchTransactions(filterText: value),
                    onClear: () {
                      filterTextController.clear();
                      _fetchTransactions();
                    },
                    hintText: "transactions...",
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Iconsax.filter,
                  color: AppColors.primaryColor(context),
                ),
                onPressed: () => _showMobileFilterSheet(context),
              ),
              IconButton(
                onPressed: () => _fetchTransactions(),
                icon: const Icon(Icons.refresh),
                tooltip: "Refresh",
              ),
            ],
          ),
        ),

        // Filter Chips
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            if (selectedTransactionTypeNotifier.value != null)
              Chip(
                label: Text(selectedTransactionTypeNotifier.value!),
                onDeleted: () {
                  selectedTransactionTypeNotifier.value = null;
                  _fetchTransactions();
                },
              ),
            if (selectedStatusNotifier.value != null)
              Chip(
                label: Text(selectedStatusNotifier.value!),
                onDeleted: () {
                  selectedStatusNotifier.value = null;
                  _fetchTransactions();
                },
              ),
            if (selectedDateRange != null)
              Chip(
                label: Text(
                  '${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}',
                ),
                onDeleted: _clearDateRange,
              ),
          ],
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildTransactionList() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionListLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TransactionListSuccess) {
          if (state.list.isEmpty) {
            return Center(child: Lottie.asset(AppImages.noData));
          } else {
            return Column(
              children: [
                SizedBox(
                  child: TransactionCard(
                    transactions: state.list,

                  ),
                ),
                const SizedBox(height: 16),
                PaginationBar(
                  count: state.count,
                  totalPages: state.totalPages,
                  currentPage: state.currentPage,
                  pageSize: state.pageSize,
                  from: state.from,
                  to: state.to,
                  onPageChanged: (page) => _fetchTransactionList(
                    pageNumber: page,
                    pageSize: state.pageSize,
                  ),
                  onPageSizeChanged: (newSize) => _fetchTransactionList(
                    pageNumber: 1,
                    pageSize: newSize,
                  ),
                ),
              ],
            );
          }
        } else if (state is TransactionListFailed) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load transactions',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  state.content,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                AppButton(
                  name: "Retry",
                  onPressed: () => _fetchTransactions(),
                ),
              ],
            ),
          );
        } else {
          return Center(child: Lottie.asset(AppImages.noData));
        }
      },
    );
  }

  void _showMobileFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Container(
                color: AppColors.bottomNavBg(context),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          "Filter Transactions",
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.text(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
              
                    // Date Range Picker - Using CustomDateRangeField
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          "Date Range",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.text(context),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomDateRangeField(
                          isLabel: false,
                          selectedDateRange: selectedDateRange,
                          onDateRangeSelected: (value) {
                            setState(() {
                              selectedDateRange = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
              
                    // Transaction Type Filter
                     Text(
                      "Transaction Type",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.text(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ["All", "Credit", "Debit"].map((type) {
                        final bool isSelected =
                            selectedTransactionTypeNotifier.value == type ||
                                (type == "All" && selectedTransactionTypeNotifier.value == null);
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedTransactionTypeNotifier.value = selected ? type : null;
                            });
                          },
                          selectedColor: AppColors.primaryColor(context).withValues(alpha: 0.2),
                          checkmarkColor: AppColors.primaryColor(context),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
              
                    // Status Filter
                     Text(
                      "Status",
                      style: TextStyle(
                        color: AppColors.text(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ["All", "Completed", "Pending", "Failed"].map((status) {
                        final bool isSelected =
                            selectedStatusNotifier.value == status ||
                                (status == "All" && selectedStatusNotifier.value == null);
                        return FilterChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedStatusNotifier.value = selected ? status : null;
                            });
                          },
                          selectedColor: AppColors.primaryColor(context).withValues(alpha: 0.2),
                          checkmarkColor: AppColors.primaryColor(context),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
              
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            color: AppColors.error,
                            onPressed: () {
                              setState(() {
                                filterTextController.clear();
                                selectedTransactionTypeNotifier.value = null;
                                selectedStatusNotifier.value = null;
                                selectedAccountNotifier.value = null;
                                selectedDateRange = null;
                              });
                              Navigator.pop(context);
                              _fetchTransactions();
                            },
                            name: "Clear All",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _fetchTransactions(
                                transactionType: selectedTransactionTypeNotifier.value.toString(),
                                status: selectedStatusNotifier.value.toString(),


                              );
                            },
              
                           name: "Apply Filters",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}