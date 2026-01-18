
import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../bloc/transactions/transaction_bloc.dart';
import '../widget/widget.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController filterTextController = TextEditingController();
  final ValueNotifier<String?> selectedTransactionTypeNotifier = ValueNotifier(null);
  final ValueNotifier<String?> selectedStatusNotifier = ValueNotifier(null);
  final ValueNotifier<String?> selectedAccountNotifier = ValueNotifier(null);
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    filterTextController.clear();
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
        startDate: startDate,
        endDate: endDate,
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

  void _clearFilters() {
    filterTextController.clear();
    selectedTransactionTypeNotifier.value = null;
    selectedStatusNotifier.value = null;
    selectedAccountNotifier.value = null;
    startDate = null;
    endDate = null;
    _fetchTransactions();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      currentDate: DateTime.now(),
      saveText: 'Apply',
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _fetchTransactions();
    }
  }

  void _clearDateRange() {
    setState(() {
      startDate = null;
      endDate = null;
    });
    _fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
    return Container(
      color: AppColors.bottomNavBg(context),
      child: SafeArea(
        child: ResponsiveRow(
          spacing: 0,
          runSpacing: 0,
          children: [
            if (isBigScreen) _buildSidebar(),
            _buildContentArea(isBigScreen),
          ],
        ),
      ),
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
      child: RefreshIndicator(
        color: AppColors.primaryColor(context),
        onRefresh: () async {
          _fetchTransactions();
        },
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            children: [

                _buildDesktopHeader()

              ,
              SizedBox(
                child: _buildTransactionList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔍 Search Field
            Expanded(
              child: CustomSearchTextFormField(
                isRequiredLabel: false,
                controller: filterTextController,
                onChanged: (value) => _fetchTransactions(filterText: value),
                onClear: () {
                  filterTextController.clear();
                  _fetchTransactions();
                },
                hintText: "Transaction No, Description, or Account",
              ),
            ),
            const SizedBox(width: 10),

            // 💰 Transaction Type Dropdown
            Expanded(
              child: ValueListenableBuilder<String?>(
                valueListenable: selectedTransactionTypeNotifier,
                builder: (context, value, child) {
                  return AppDropdown<String>(
                    hint: "Transaction Type",
                    isNeedAll: true,
                    isLabel: true,
                    isRequired: false,
                    value: value,
                    itemList: ['Credit', 'Debit'],
                    onChanged: (newVal) {
                      selectedTransactionTypeNotifier.value = newVal;
                      _fetchTransactions(
                        transactionType: newVal?.toLowerCase() ?? '',
                      );
                    },
                    validator: (value) => null,

                    label: '',
                  );
                },
              ),
            ),
            const SizedBox(width: 10),

            // 📊 Status Dropdown
            Expanded(
              child: ValueListenableBuilder<String?>(
                valueListenable: selectedStatusNotifier,
                builder: (context, value, child) {
                  return AppDropdown<String>(
                    hint: "Status",
                    isNeedAll: true,
                    isLabel: true,
                    isRequired: false,
                    value: value,
                    itemList: ['Completed', 'Pending', 'Failed'],
                    onChanged: (newVal) {
                      selectedStatusNotifier.value = newVal;
                      _fetchTransactions(
                        status: newVal?.toLowerCase() ?? '',
                      );
                    },
                    validator: (value) => null,

                    label: '',
                  );
                },
              ),
            ),
            gapW16,

            // 📅 Date Range Button
            AppButton(
              name: "Date Range",
              isOutlined: true,

              onPressed: () => _selectDateRange(context),
              textColor: AppColors.text(context),
            ),

            gapW16,

            // 🔄 Refresh Button
            IconButton(
              onPressed: () => _fetchTransactions(),
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh",
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Date Range Display
        if (startDate != null || endDate != null)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor(context).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryColor(context).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: AppColors.primaryColor(context)),
                      const SizedBox(width: 8),
                      Text(
                        '${startDate != null ? _formatDate(startDate!) : "Any"} - ${endDate != null ? _formatDate(endDate!) : "Any"}',
                        style: TextStyle(
                          color: AppColors.primaryColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.clear, size: 16, color: AppColors.primaryColor(context)),
                        onPressed: _clearDateRange,
                        tooltip: "Clear Date Range",
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: _clearFilters,
                child: Text(
                  'Clear All Filters',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
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


  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}