import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';


import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/date_range.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../../expense_head/data/model/expense_head_model.dart';
import '../../expense_head/presentation/bloc/expense_head/expense_head_bloc.dart';
import '../../expense_sub_head/data/model/expense_sub_head_model.dart';
import '../../expense_sub_head/presentation/bloc/expense_sub_head/expense_sub_head_bloc.dart';
import '../bloc/expense_list/expense_bloc.dart';
import '../widget/widget.dart';
import 'expense_create.dart';

class MobileExpenseListScreen extends StatefulWidget {
  const MobileExpenseListScreen({super.key});

  @override
  State<MobileExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<MobileExpenseListScreen> {
  DateRange? selectedDateRange;
  DateTime now = DateTime.now();
  ExpenseHeadModel? _selectedExpenseHead;
  ExpenseSubHeadModel? _selectedExpenseSubHead;
  late ExpenseBloc dataBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDateRange = DateRange(
      DateTime(now.year, now.month - 1, now.day),
      DateTime(now.year, now.month, now.day),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseHeadBloc>().add(FetchExpenseHeadList(context));
      context.read<ExpenseSubHeadBloc>().add(FetchSubExpenseHeadList(context));
      _fetchApi(from: selectedDateRange?.start, to: selectedDateRange?.end);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dataBloc = context.read<ExpenseBloc>();
    dataBloc.filterTextController;
  }

  @override
  void dispose() {
    _searchController.dispose();
    dataBloc.filterTextController.dispose();
      super.dispose();
  }



  void _fetchApi({
    String filterText = '',
    DateTime? from,
    DateTime? to,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    if (!mounted) return;

    context.read<ExpenseBloc>().add(
      FetchExpenseList(
        context,
        filterText: filterText,
        startDate: from,
        endDate: to,
        pageNumber: pageNumber,
        pageSize: pageSize,
        headId: _selectedExpenseHead?.id?.toString(),
        subHeadId: _selectedExpenseSubHead?.id?.toString(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
     appBar: AppBar(title: Text("Expense List"),),
      body: SafeArea(
        child:    _buildContentArea(),
      ),
    );
  }


  Widget _buildContentArea() {
    return ResponsiveCol(
      xs: 12,
      sm: 12,
      md: 12,
      lg: 10,
      xl: 10,
      child: Container(
        padding: AppTextStyle.getResponsivePaddingBody(context),
        child: BlocConsumer<ExpenseBloc, ExpenseState>(
          listener: (context, state) {
            _handleBlocState(state);
          },
          builder: (context, state) {
            return Column(
              children: [

                  _buildMobileHeader(context),
                const SizedBox(height: 8),
                SizedBox(
                  child: _buildExpenseList(state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleBlocState(ExpenseState state) {
    if (state is ExpenseAddLoading) {
      appLoader(context, "Creating Expense, please wait...");
    } else if (state is ExpenseAddSuccess) {
      Navigator.pop(context);
      _fetchApi();
    } else if (state is ExpenseAddFailed) {
      if (context.mounted) {
        Navigator.pop(context);
        appAlertDialog(
          context,
          state.content,
          title: state.title,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Dismiss"),
            ),
          ],
        );
      }
    } else if (state is ExpenseDeleteLoading) {
      appLoader(context, "Deleting Expense, please wait...");
    } else if (state is ExpenseDeleteSuccess) {
      Navigator.pop(context);
      _fetchApi();
    } else if (state is ExpenseDeleteFailed) {
      if (context.mounted) {
        Navigator.pop(context);
        appAlertDialog(
          context,
          state.content,
          title: state.title,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Dismiss"),
            ),
          ],
        );
      }
    }
  }


  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
                    controller: dataBloc.filterTextController,
                    onChanged: (value) {
                      _fetchApi(filterText: value);
                    },
                    onClear: () {
                      dataBloc.filterTextController.clear();
                                          _fetchApi();
                    },
                    hintText: "Search expenses...",
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Iconsax.filter,
                  color: AppColors.primaryColor,
                ),
                onPressed: () => _showMobileFilterSheet(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Filter Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (_selectedExpenseHead != null)
              Chip(
                label: Text(_selectedExpenseHead!.name ?? 'Head'),
                onDeleted: () {
                  setState(() {
                    _selectedExpenseHead = null;
                    _selectedExpenseSubHead = null;
                  });
                  _fetchApi();
                },
              ),
            if (_selectedExpenseSubHead != null)
              Chip(
                label: Text(_selectedExpenseSubHead!.name ?? 'Sub Head'),
                onDeleted: () {
                  setState(() => _selectedExpenseSubHead = null);
                  _fetchApi();
                },
              ),
            if (selectedDateRange != null)
              Chip(
                label: Text(
                  '${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}',
                ),
                onDeleted: () {
                  setState(() => selectedDateRange = null);
                  _fetchApi();
                },
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showMobileFilterSheet(context),
                icon: const Icon(Iconsax.filter, size: 16),
                label: const Text('More Filters'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                name: "Create",
                onPressed: () => _showCreateDialog(context),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpenseList(ExpenseState state) {
    if (state is ExpenseListLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ExpenseListSuccess) {
      if (state.list.isEmpty) {
        return _buildEmptyState();
      } else {
        return Column(
          children: [
            SizedBox(
              child: ExpenseTableCard(
                expenses: state.list,
                onExpenseTap: () {},
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
              onPageChanged: (page) => _fetchApi(pageNumber: page),
              onPageSizeChanged: (newSize) => _fetchApi(pageSize: newSize),
            ),
          ],
        );
      }
    } else if (state is ExpenseListFailed) {
      return _buildErrorState(state);
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AppImages.noData, width: 200, height: 200),
          const SizedBox(height: 16),
          const Text(
            'No expenses found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          AppButton(
            name: "Refresh",
            onPressed: () => _fetchApi(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ExpenseListFailed state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load expenses',
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
            onPressed: () => _fetchApi(),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.isMobile(context)
                  ? AppSizes.width(context)
                  : AppSizes.width(context) * 0.5,
              maxHeight: AppSizes.height(context) * 0.8,
              minHeight: AppSizes.height(context) * 0.6,
            ),
            child: const ExpenseCreateScreen(),
          ),
        );
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
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter Expenses",
                        style: TextStyle(
                          fontSize: 18,
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

                  // Expense Head Filter
                  BlocBuilder<ExpenseHeadBloc, ExpenseHeadState>(
                    builder: (context, state) {
                      if (state is ExpenseHeadListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Expense Head",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppDropdown<ExpenseHeadModel>(
                            context: context,
                            hint: "Select Expense Head",
                            isNeedAll: true,
                            value: _selectedExpenseHead,
                            itemList: context.read<ExpenseHeadBloc>().list,
                            onChanged: (value) {
                              setState(() {
                                _selectedExpenseHead = value;
                                _selectedExpenseSubHead = null;
                              });
                            },
                            itemBuilder: (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.name ?? 'Unnamed Head'),
                            ), label: '',
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date Range
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Date Range",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomDateRangeField(
                        isLabel: false,
                        selectedDateRange: selectedDateRange,
                        onDateRangeSelected: (value) {
                          setState(() => selectedDateRange = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedExpenseHead = null;
                              _selectedExpenseSubHead = null;
                              selectedDateRange = null;
                            });
                            Navigator.pop(context);
                            _fetchApi();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Clear All"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _fetchApi();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Apply Filters"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
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