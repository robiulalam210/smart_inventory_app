// transactions/presentation/screens/transaction_screen.dart

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
  TextEditingController filterTextController = TextEditingController();
  ValueNotifier<String?> selectedTransactionTypeNotifier = ValueNotifier(null);
  ValueNotifier<String?> selectedStatusNotifier = ValueNotifier(null);
  ValueNotifier<String?> selectedAccountNotifier = ValueNotifier(null);
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    filterTextController.clear();
    _fetchTransactions();
  }

  void _fetchTransactions({
    String filterText = '',
    String transactionType = '',
    String status = '',
    String accountId = '',
    int pageNumber = 1,
    int pageSize = 10,
  }) {
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
      color: AppColors.bg,
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
        color: AppColors.primaryColor,
        onRefresh: () async {
          _fetchTransactions();
        },
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            children: [
              _buildFilterRow(),
              SizedBox(
                child: BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    if (state is TransactionListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TransactionListSuccess) {
                      if (state.list.isEmpty) {
                        return Center(child: Lottie.asset(AppImages.noData));
                      } else {
                        return Column(
                          children: [
                            TransactionCard(
                              transactions: state.list,
                              onReverse: (transaction) async {
                                // bool shouldReverse = await showDeleteConfirmationDialog(
                                //   context,
                                //   title: "Reverse Transaction",
                                //   content: "Are you sure you want to reverse this transaction?",
                                // );
                                // if (!shouldReverse) return;
                                //
                                // context.read<TransactionBloc>().add(
                                //   ReverseTransaction(context, transaction.id.toString()),
                                // );
                              },
                            ),
                            PaginationBar(
                              count: state.count,
                              totalPages: state.totalPages,
                              currentPage: state.currentPage,
                              pageSize: state.pageSize,
                              from: state.from,
                              to: state.to,
                              onPageChanged: (page) =>
                                  _fetchTransactionList(pageNumber: page, pageSize: state.pageSize),
                              onPageSizeChanged: (newSize) =>
                                  _fetchTransactionList(pageNumber: 1, pageSize: newSize),
                            ),
                          ],
                        );
                      }
                    } else if (state is TransactionListFailed) {
                      return Center(
                        child: Text(
                          'Failed to load transactions: ${state.content}',
                        ),
                      );
                    } else {
                      return Center(child: Lottie.asset(AppImages.noData));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Column(
      children: [
        // First Row - Search and Basic Filters
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                hintText: "Search Transaction No, Description, or Account",
              ),
            ),
            const SizedBox(width: 10),

            // 💰 Transaction Type Dropdown
            Expanded(
              child: AppDropdown<String>(
                context: context,
                hint: "Transaction Type",
                isNeedAll: true,
                isLabel: false,
                isRequired: false,
                value: selectedTransactionTypeNotifier.value,
                itemList: ['Credit', 'Debit'],
                onChanged: (newVal) {
                  selectedTransactionTypeNotifier.value = newVal;
                  _fetchTransactions(
                    transactionType: newVal?.toLowerCase() ?? '',
                  );
                },
                validator: (value) => null,
                itemBuilder: (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: AppColors.blackColor,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                label: '',
              ),
            ),
            const SizedBox(width: 10),

            // 📊 Status Dropdown
            Expanded(
              child: AppDropdown<String>(
                context: context,
                hint: "Status",
                isNeedAll: true,
                isLabel: false,
                isRequired: false,
                value: selectedStatusNotifier.value,
                itemList: ['Completed', 'Pending', 'Failed'],
                onChanged: (newVal) {
                  selectedStatusNotifier.value = newVal;
                  _fetchTransactions(
                    status: newVal?.toLowerCase() ?? '',
                  );
                },
                validator: (value) => null,
                itemBuilder: (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: AppColors.blackColor,
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                label: '',
              ),
            ),
            gapW16,

            // 📅 Date Range Button
            AppButton(
              name: "Date Range",
              onPressed: () => _selectDateRange(context),
              // backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              textColor: AppColors.primaryColor,
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

        // Second Row - Date Range Display and Clear Button
        if (startDate != null || endDate != null)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: AppColors.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        '${startDate != null ? _formatDate(startDate!) : "Any"} - ${endDate != null ? _formatDate(endDate!) : "Any"}',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.clear, size: 16, color: AppColors.primaryColor),
                        onPressed: _clearDateRange,
                        tooltip: "Clear Date Range",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}