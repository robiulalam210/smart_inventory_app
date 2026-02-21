import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/date_range.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../../income_expense/data/model/income_head_model.dart';
import '../../income_expense/presentation/income_expense_bloc/income_expense_head_bloc.dart';
import '../IncomeBloc/income_bloc.dart';
import 'income_create_screen/income_create_screen.dart';
import 'widget/income_table_card.dart';

class MobileIncomeListScreen extends StatefulWidget {
  const MobileIncomeListScreen({super.key});

  @override
  State<MobileIncomeListScreen> createState() => _IncomeListScreenState();
}

class _IncomeListScreenState extends State<MobileIncomeListScreen> {
  DateRange? selectedDateRange;
  DateTime now = DateTime.now();
  IncomeHeadModel? _selectedIncomeHead;
  String? _selectedAccountId;
  late IncomeBloc dataBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDateRange = DateRange(
      DateTime(now.year, now.month - 1, now.day),
      DateTime(now.year, now.month, now.day),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncomeHeadBloc>().add(FetchIncomeHeadList(context: context));
      _fetchApi(from: selectedDateRange?.start, to: selectedDateRange?.end);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dataBloc = context.read<IncomeBloc>();
    dataBloc.filterTextController;
  }

  @override
  void dispose() {
    _searchController.dispose();
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

    context.read<IncomeBloc>().add(
      FetchIncomeList(
        context: context,
        filterText: filterText,
        startDate: from,
        endDate: to,
        pageNumber: pageNumber,
        pageSize: pageSize,
        headId: _selectedIncomeHead?.id?.toString(),
        accountId: _selectedAccountId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor(context),
        onPressed: () => _showCreateBottomSheet(context),
        child: Icon(Icons.add, color: AppColors.whiteColor(context)),
      ),
      appBar: AppBar(title: Text("Income List")),
      body: SafeArea(child: _buildContentArea()),
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
        child: BlocConsumer<IncomeBloc, IncomeState>(
          listener: (context, state) {
            _handleBlocState(state);
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildMobileHeader(context),
                  const SizedBox(height: 8),
                  SizedBox(child: _buildIncomeList(state)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleBlocState(IncomeState state) {
    if (state is IncomeAddLoading) {
      appLoader(context, "Creating Income, please wait...");
    } else if (state is IncomeAddSuccess) {
      Navigator.pop(context);
      // Navigator.pop(context);
      _fetchApi();
    } else if (state is IncomeAddFailed) {
      if (context.mounted) {
        Navigator.pop(context);
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
    } else if (state is IncomeDeleteLoading) {
      appLoader(context, "Deleting Income, please wait...");
    } else if (state is IncomeDeleteSuccess) {
      Navigator.pop(context);
      _fetchApi();
    } else if (state is IncomeDeleteFailed) {
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
        Row(
          children: [
            Expanded(
              child: CustomSearchTextFormField(
                controller: dataBloc.filterTextController,
                onChanged: (value) {
                  _fetchApi(filterText: value);
                },
                onClear: () {
                  dataBloc.filterTextController.clear();
                  _fetchApi();
                },
                hintText: "Incomes...",
              ),
            ),
            IconButton(
              icon: Icon(
                Iconsax.filter,
                color: AppColors.primaryColor(context),
              ),
              onPressed: () => _showMobileFilterSheet(context),
            ),
          ],
        ),
        // Filter Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (_selectedIncomeHead != null)
              Chip(
                label: Text(_selectedIncomeHead!.name ?? 'Head'),
                onDeleted: () {
                  setState(() {
                    _selectedIncomeHead = null;
                  });
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
      ],
    );
  }

  Widget _buildIncomeList(IncomeState state) {
    if (state is IncomeListLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is IncomeListSuccess) {
      if (state.list.isEmpty) {
        return _buildEmptyState();
      } else {
        return Column(
          children: [
            SizedBox(
              child: IncomeTableCard(
                incomes: state.list,
                onIncomeTap: () {},
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
    } else if (state is IncomeListFailed) {
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
            'No incomes found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          AppButton(name: "Refresh", onPressed: () => _fetchApi()),
        ],
      ),
    );
  }

  Widget _buildErrorState(IncomeListFailed state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load incomes',
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
          AppButton(name: "Retry", onPressed: () => _fetchApi()),
        ],
      ),
    );
  }

  void _showCreateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6, // প্রথমে 60% of screen
          minChildSize: 0.6,     // minimum 40%
          maxChildSize: 0.9,     // maximum 90%
          expand: false,         // content অনুযায়ী expand
          builder: (context, scrollController) {
            return SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radius),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radius),
                  ),
                  child: MobileIncomeCreate(),
                ),
              ),
            );
          },
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
        return SafeArea(
          child: StatefulBuilder(
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
                        Text(
                          "Filter Incomes",
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
                    const SizedBox(height: 10),
          
                    // Income Head Filter
                    BlocBuilder<IncomeHeadBloc, IncomeHeadState>(
                      builder: (context, state) {
                        if (state is IncomeHeadListLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Income Head",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.text(context),
                              ),
                            ),
                            AppDropdown<IncomeHeadModel>(
                              hint: "Select Income Head",
                              isNeedAll: true,
                              value: _selectedIncomeHead,
                              itemList: context.read<IncomeHeadBloc>().list,
                              onChanged: (value) {
                                setState(() {
                                  _selectedIncomeHead = value;
                                });
                              },
                              label: '',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 4),
          
                    // Date Range
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date Range",
                          style: TextStyle(
                            color: AppColors.text(context),
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
                    const SizedBox(height: 20),
          
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(child: AppButton(
                            isOutlined: true,
                            name: "Clear All", onPressed: (){
                          setState(() {
                            _selectedIncomeHead = null;
                            selectedDateRange = null;
                          });
                          Navigator.pop(context);
                          _fetchApi();
                        })),
                        const SizedBox(width: 12),

                        Expanded(child: AppButton(name:   "Apply Filters",onPressed: (){
                          Navigator.pop(context);
                          _fetchApi();
                        })),


                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}