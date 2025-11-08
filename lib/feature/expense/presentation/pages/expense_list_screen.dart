import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/custom_date_range.dart';
import '../../../../core/widgets/custom_filter_ui.dart';
import '../../../../core/widgets/date_range.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../../expense_head/data/model/expense_head_model.dart';
import '../../expense_head/presentation/bloc/expense_head/expense_head_bloc.dart';
import '../../expense_sub_head/data/model/expense_sub_head_model.dart';
import '../../expense_sub_head/presentation/bloc/expense_sub_head/expense_sub_head_bloc.dart';
import '../bloc/expense_list/expense_bloc.dart';
import '../widget/widget.dart';
import 'expense_create.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  DateRange? selectedDateRange;
  DateTime now = DateTime.now();

  // Add missing variables
  ExpenseHeadModel? _selectedExpenseHead;
  ExpenseSubHeadModel? _selectedExpenseSubHead;

  late var dataBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dataBloc = context.read<ExpenseBloc>();
    dataBloc.filterTextController = TextEditingController();

    // Initialize selectedDateRange if not set
    if (selectedDateRange == null) {
      selectedDateRange = DateRange(
       DateTime(now.year, now.month - 1, now.day),
       DateTime(now.year, now.month, now.day),
      );
    }

    _fetchApi(from: selectedDateRange?.start, to: selectedDateRange?.end);
  }

  @override
  void dispose() {
    dataBloc.filterTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Initialize with default date range
    selectedDateRange = DateRange(
       DateTime(now.year, now.month - 1, now.day),
      DateTime(now.year, now.month, now.day),
    );

    context.read<ExpenseHeadBloc>().add(FetchExpenseHeadList(context));
    context.read<ExpenseSubHeadBloc>().add(FetchSubExpenseHeadList(context));
    _fetchApi(from: selectedDateRange?.start, to: selectedDateRange?.end);
  }

  // Add missing methods
  void _onExpenseHeadChanged(ExpenseHeadModel? value) {
    setState(() {
      _selectedExpenseHead = value;
      _selectedExpenseSubHead = null; // Reset subhead when head changes
    });
    _fetchApi(); // Refresh data with new head filter
  }

  void _onExpenseSubHeadChanged(ExpenseSubHeadModel? value) {
    setState(() {
      _selectedExpenseSubHead = value;
    });
    _fetchApi(); // Refresh data with new subhead filter
  }

  Future<void> _selectDateRange(StateSetter setState) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: selectedDateRange?.start ?? DateTime.now().subtract(const Duration(days: 7)),
        end: selectedDateRange?.end ?? DateTime.now(),
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDateRange = DateRange( picked.start, picked.end);
      });
      _fetchApi(from: selectedDateRange?.start, to: selectedDateRange?.end);
    }
  }

  void _fetchApi({
    String filterText = '',
    DateTime? from,
    DateTime? to,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
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

  void _fetchProductList({int pageNumber = 1, int pageSize = 10}) {
    _fetchApi(
      pageNumber: pageNumber,
      pageSize: pageSize,
      filterText: context.read<ExpenseBloc>().filterTextController.text,
      from: selectedDateRange?.start,
      to: selectedDateRange?.end,
    );
  }

  void _clearFilters() {
    setState(() {
      selectedDateRange = DateRange(
       DateTime(now.year, now.month - 1, now.day),
         DateTime(now.year, now.month, now.day),
      );
      _selectedExpenseHead = null;
      _selectedExpenseSubHead = null;
    });
    context.read<ExpenseBloc>().filterTextController.clear();
    _fetchApi();
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
      child: Container(
        padding: AppTextStyle.getResponsivePaddingBody(context),
        child: BlocListener<ExpenseBloc, ExpenseState>(
          listener: (context, state) {
            if (state is ExpenseAddLoading) {
              appLoader(context, "Expense, please wait...");
            } else if (state is ExpenseAddSuccess) {
              Navigator.pop(context); // Close loader dialog
              Navigator.pop(context); // Close create dialog
              _fetchApi(); // Reload expense list
            } else if (state is ExpenseAddFailed) {
              Navigator.pop(context); // Close loader dialog
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
            if (state is ExpenseDeleteLoading) {
              appLoader(context, "Expense, please wait...");
            } else if (state is ExpenseDeleteSuccess) {
              Navigator.pop(context); // Close loader dialog
              _fetchApi(); // Reload expense list
            } else if (state is ExpenseDeleteFailed) {
              Navigator.pop(context); // Close loader dialog
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
          },
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomSearchTextFormField(
                      controller: context.read<ExpenseBloc>().filterTextController,
                      onChanged: (value) {
                        _fetchApi(filterText: value);
                      },
                      onClear: () {
                        context.read<ExpenseBloc>().filterTextController.clear();
                        _fetchApi(from: selectedDateRange?.start, to: selectedDateRange?.end);
                      },
                      hintText: "by description, amount, etc.",
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Expense Head Dropdown
                  Expanded(
                    child: BlocBuilder<ExpenseHeadBloc, ExpenseHeadState>(
                      builder: (context, state) {
                        if (state is ExpenseHeadListLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return AppDropdown<ExpenseHeadModel>(
                          context: context,
                          label: "Expense Head",
                          hint: _selectedExpenseHead?.name ?? "Select Expense Head",
                          isNeedAll: true,
                          isRequired: false,
                          value: _selectedExpenseHead,
                          itemList: context.read<ExpenseHeadBloc>().list,
                          onChanged: _onExpenseHeadChanged,
                          validator: (value) => null,
                          itemBuilder: (item) => DropdownMenuItem<ExpenseHeadModel>(
                            value: item,
                            child: Text(
                              item.name ?? 'Unnamed Head',
                              style: const TextStyle(
                                color: AppColors.blackColor,
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 4),


                  // 📅 Date Range Picker
                  SizedBox(
                    width: 260,
                    child: CustomDateRangeField(
                      isLabel: false,
                      selectedDateRange: selectedDateRange,
                      onDateRangeSelected: (value) {
                        setState(() => selectedDateRange = value);
                        if (value != null) {
                          _fetchApi(from: value.start, to: value.end);
                        } else {
                          _fetchApi(); // Fetch without date filter
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _clearFilters();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Clear All',
                            style: AppTextStyle.cardLevelText(context).copyWith(color: Colors.red),
                          ),
                        ),


                      ],
                    ),
                  ),
                  AppButton(
                    name: "Create Expense",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            child: SizedBox(
                              width: AppSizes.width(context) * 0.50,
                              child: const ExpenseCreateScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                child: BlocBuilder<ExpenseBloc, ExpenseState>(
                  builder: (context, state) {
                    if (state is ExpenseListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ExpenseListSuccess) {
                      if (state.list.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(AppImages.noData, width: 200, height: 200),
                              const SizedBox(height: 16),
                              const Text(
                                'No expenses found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              AppButton(
                                name: "Refresh",
                                onPressed: () => _fetchApi(),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Column(
                          children: [
                            SizedBox(
                              child: ExpenseTableCard(expenses: state.list),
                            ),
                            const SizedBox(height: 10),
                            PaginationBar(
                              count: state.count,
                              totalPages: state.totalPages,
                              currentPage: state.currentPage,
                              pageSize: state.pageSize,
                              from: state.from,
                              to: state.to,
                              onPageChanged: (page) {
                                _fetchProductList(pageNumber: page);
                              },
                              onPageSizeChanged: (newPageSize) {
                                _fetchProductList(pageNumber: 1, pageSize: newPageSize);
                              },
                            ),
                          ],
                        );
                      }
                    } else if (state is ExpenseListFailed) {
                      if (state.content.toString().toLowerCase().contains("no data")) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(AppImages.noData, width: 200, height: 200),
                              const SizedBox(height: 16),
                              const Text(
                                'No expenses found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              AppButton(
                                name: "Refresh",
                                onPressed: () => _fetchApi(),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 60, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load expenses: ${state.content}',
                                style: const TextStyle(fontSize: 16),
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
                    } else {
                      return Center(
                        child: Lottie.asset(AppImages.noData),
                      );
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

}