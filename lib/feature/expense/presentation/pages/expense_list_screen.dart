
import 'package:smart_inventory/feature/expense/expense_head/data/model/expense_head_model.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/custom_date_range.dart';
import '../../../../core/widgets/custom_filter_ui.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../../expense_head/presentation/bloc/expense_head/expense_head_bloc.dart';
import '../bloc/expense_list/expense_bloc.dart';
import '../widget/widget.dart';
import 'expense_create.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  DateTime? startDate;
  DateTime? endDate;
  DateTime now = DateTime.now();

  late var dataBloc = context.read<ExpenseBloc>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dataBloc.filterTextController = TextEditingController();
    _fetchApi(from: startDate, to: endDate);
  }

  @override
  void dispose() {
    dataBloc.filterTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startDate = DateTime(now.year, now.month - 1, now.day);
    endDate = DateTime(now.year, now.month, now.day);

    context.read<ExpenseHeadBloc>().add(FetchExpenseHeadList(context));
    _fetchApi(from: startDate, to: endDate);
  }

  Future<void> _selectDateRange(StateSetter setState) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: startDate ?? DateTime.now().subtract(const Duration(days: 7)),
        end: endDate ?? DateTime.now(),
      ),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _fetchApi(from: startDate, to: endDate, );
    }
  }

  void _fetchApi({
    String filterText = '',
    DateTime? from,
    DateTime? to,
    int pageNumber = 1, // Changed to 1-based for pagination
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
      ),
    );
  }

  void _fetchProductList({int pageNumber = 1, int pageSize = 10}) {
    _fetchApi(
      pageNumber: pageNumber,
      pageSize: pageSize,
      filterText: context.read<ExpenseBloc>().filterTextController.text,
      from: startDate,
      to: endDate,
    );
  }


  void _clearFilters() {
    setState(() {
      startDate = null;
      endDate = null;
    });
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
              Navigator.pop(context); // Close loader dialog
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
            }  if (state is ExpenseDeleteLoading) {
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
                        _fetchApi(filterText: value, );
                      },
                      onClear: () {
                        context.read<ExpenseBloc>().filterTextController.clear();
                        _fetchApi(from: startDate, to: endDate, );
                      },
                      hintText: "Search by description, amount, etc.",
                    ),
                  ),
                  gapW16,
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
                  gapW16,
                  CustomFilterBox(
                    onTapDown: (TapDownDetails details) {
                      _showFilterMenu(context, details.globalPosition);
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
                        return Center(child: Lottie.asset(AppImages.noData));
                      } else {
                        return Column(
                          children: [
                            SizedBox(
                              child: ExpenseTableCard(

                                 expenses: state.list,
                              )
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
                      if (state.content.toString() == "No Data") {
                        return Center(child: Lottie.asset(AppImages.noData));
                      } else {
                        return Center(
                          child: Text('Failed to load data: ${state.content}'),
                        );
                      }
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

  void _showFilterMenu(BuildContext context, Offset offset) async {
    final screenSize = MediaQuery.of(context).size;
    final left = offset.dx;
    final top = offset.dy;
    final right = screenSize.width - left;
    final bottom = screenSize.height - top;

    await showMenu(
      color: const Color.fromARGB(255, 248, 248, 248),
      context: context,
      position: RelativeRect.fromLTRB(left, top, right, bottom),
      items: [
        PopupMenuItem(
          padding: const EdgeInsets.all(0),
          enabled: false,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.only(
                      top: 5,
                      bottom: 10,
                      left: 10,
                      right: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 248, 248, 248),
                    ),
                    child: Text(
                      'Filter',
                      style: AppTextStyle.cardLevelText(context),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: CustomDateRange(
                                      label: "Start Date",
                                      date: startDate,
                                      onTap: () => _selectDateRange(setState),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: CustomDateRange(
                                      label: "End Date",
                                      date: endDate,
                                      onTap: () => _selectDateRange(setState),
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
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
                        GestureDetector(
                          onTap: () {
                            _fetchApi(from: startDate, to: endDate, );
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Apply',
                            style: AppTextStyle.cardLevelText(context).copyWith(color: Colors.green),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Close',
                            style: AppTextStyle.cardLevelText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}