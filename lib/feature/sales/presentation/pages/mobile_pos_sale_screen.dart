import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:meherinMart/core/configs/configs.dart';
import 'package:meherinMart/core/widgets/app_dropdown.dart';
import 'package:meherinMart/core/widgets/coustom_search_text_field.dart';
import 'package:meherinMart/core/widgets/date_range.dart';
import 'package:meherinMart/feature/customer/data/model/customer_active_model.dart';
import 'package:meherinMart/feature/customer/presentation/bloc/customer/customer_bloc.dart';
import 'package:meherinMart/feature/products/product/presentation/bloc/products/products_bloc.dart';
import 'package:meherinMart/feature/products/product/presentation/widget/pagination.dart';
import 'package:meherinMart/feature/users_list/data/model/user_model.dart';
import 'package:meherinMart/feature/users_list/presentation/bloc/users/user_bloc.dart';
import 'package:meherinMart/feature/sales/presentation/bloc/possale/possale_bloc.dart';
import 'package:meherinMart/feature/sales/presentation/widgets/widget.dart';
import 'package:lottie/lottie.dart';

class MobilePosSaleScreen extends StatefulWidget {
  const MobilePosSaleScreen({super.key, this.posSale});

  final String? posSale;

  @override
  State<MobilePosSaleScreen> createState() => _PosSaleScreenState();
}

class _PosSaleScreenState extends State<MobilePosSaleScreen> {
  DateTime now = DateTime.now();
  DateRange? selectedDateRange;
  final TextEditingController filterTextController = TextEditingController();
  final ValueNotifier<String?> selectedCustomerNotifier = ValueNotifier(null);
  final ValueNotifier<String?> selectedSellerNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    filterTextController.clear();

    // FIXED: Proper date calculation for last month
    // Don't use now.month - 1 directly - handle month rollover properly
    selectedDateRange = _getDefaultDateRange();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(
        FetchUserList(context, dropdownFilter: "?status=1"),
      );
      context.read<CustomerBloc>().add(FetchCustomerActiveList(context));
      context.read<ProductsBloc>().add(FetchProductsStockList(context));

      // Debug: Print the dates being used
      print('INIT STATE - Now: $now');
      print('INIT STATE - Now year: ${now.year}');
      print('INIT STATE - Selected range: $selectedDateRange');
      print('INIT STATE - Start year: ${selectedDateRange?.start?.year}');
      print('INIT STATE - End year: ${selectedDateRange?.end?.year}');

      _fetchApi();
    });
  }

  // FIXED: Proper method to get default date range
  DateRange _getDefaultDateRange() {
    final today = DateTime.now();
    final lastMonth = DateTime(today.year, today.month - 1, today.day);

    // Handle year rollover if month is January
    if (today.month == 1) {
      return DateRange(
        DateTime(today.year - 1, 12, today.day), // December of last year
        today, // Today
      );
    } else {
      return DateRange(
        lastMonth, // Last month
        today, // Today
      );
    }
  }

  @override
  void dispose() {
    filterTextController.dispose();
    selectedCustomerNotifier.dispose();
    selectedSellerNotifier.dispose();
    super.dispose();
  }

  void _fetchApi({
    String filterText = '',
    String customer = '',
    String seller = '',
    DateTime? from,
    DateTime? to,
    int pageNumber = 1,
  }) {
    if (!mounted) return;

    String filter = "?page=$pageNumber";

    if (filterText.isNotEmpty) {
      filter += "&search=$filterText";
    }

    if (customer.isNotEmpty && customer != 'null') {
      filter += "&customer=$customer";
    }

    if (seller.isNotEmpty && seller != 'null') {
      filter += "&seller=$seller";
    }

    if (from != null && to != null) {
      // FIX: Make end date INCLUSIVE of entire day
      String formatDateStart(DateTime date) {
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T00:00:00';
      }

      String formatDateEnd(DateTime date) {
        // Add 1 day and subtract 1 second to include entire end date
        final nextDay = DateTime(date.year, date.month, date.day + 1);
        return '${nextDay.year}-${nextDay.month.toString().padLeft(2, '0')}-${nextDay.day.toString().padLeft(2, '0')}T00:00:00';
      }

      // Make sure 'from' is before 'to'
      if (from.isAfter(to)) {
        final temp = from;
        from = to;
        to = temp;
        print('Swapped dates: from was after to');
      }

      print('=== FILTERING WITH INCLUSIVE DATES ===');
      print('From (start of day): ${formatDateStart(from)}');
      print('To (end of day+1): ${formatDateEnd(to)}');

      filter += "&start_date=${formatDateStart(from)}&end_date=${formatDateEnd(to)}";
    }

    print('API URL: /api/sales/$filter');

    context.read<PosSaleBloc>().add(
      FetchPosSaleList(context, dropdownFilter: filter),
    );
  }
  void _fetchProductList({required int pageNumber, required int pageSize}) {
    // Debug: Print what's being sent
    print('=== DEBUG: Fetching Product List ===');
    print('Current date: ${DateTime.now()}');
    print('Selected date range: $selectedDateRange');

    if (selectedDateRange != null) {
      print('Start date: ${selectedDateRange!.start}');
      print('Start year: ${selectedDateRange!.start?.year}');
      print('End date: ${selectedDateRange!.end}');
      print('End year: ${selectedDateRange!.end?.year}');
    }

    _fetchApi(
      pageNumber: pageNumber,
      filterText: filterTextController.text,
      customer: selectedCustomerNotifier.value ?? '',
      seller: selectedSellerNotifier.value ?? '',
      from: selectedDateRange?.start,
      to: selectedDateRange?.end,
    );
  }

  void _clearFilters() {
    setState(() {
      selectedDateRange = _getDefaultDateRange(); // Use fixed method
    });
    filterTextController.clear();
    selectedCustomerNotifier.value = null;
    selectedSellerNotifier.value = null;

    // Clear bloc states
    context.read<PosSaleBloc>().selectCustomerModel = null;
    context.read<PosSaleBloc>().selectUserModel = null;

    print('Cleared filters, default date range set');
    _fetchApi();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bottomNavBg(context),
        title: Text("Sales List", style: AppTextStyle.titleMedium(context)),
      ),
      body: SafeArea(
        child: ResponsiveCol(
          xs: 12,
          lg: 10,
          child: RefreshIndicator(
            onRefresh: () async => _fetchApi(),
            color: AppColors.primaryColor(context),
            child: Container(
              padding: AppTextStyle.getResponsivePaddingBody(context),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMobileHeader(),
                    const SizedBox(height: 8),
                    SizedBox(child: _buildDataTable()),
                  ],
                ),
              ),
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
        Row(
          children: [
            Expanded(
              child: CustomSearchTextFormField(
                controller: filterTextController,
                onChanged: (value) => _fetchApi(filterText: value),
                onClear: () {
                  filterTextController.clear();
                  _fetchApi();
                },
                hintText: "sales...",
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
              onPressed: () {
                _clearFilters();
              },
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh",
            ),
          ],
        ),

        // Filter Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (selectedCustomerNotifier.value != null)
              Chip(
                label: const Text('Customer Filtered'),
                onDeleted: () {
                  selectedCustomerNotifier.value = null;
                  context.read<PosSaleBloc>().selectCustomerModel = null;
                  _fetchApi();
                },
              ),
            if (selectedSellerNotifier.value != null)
              Chip(
                label: const Text('Seller Filtered'),
                onDeleted: () {
                  selectedSellerNotifier.value = null;
                  context.read<PosSaleBloc>().selectUserModel = null;
                  _fetchApi();
                },
              ),
            if (selectedDateRange != null)
              Chip(
                label: Text(
                  '${AppWidgets().convertDateTimeDDMMYYYY(selectedDateRange!.start)} - ${AppWidgets().convertDateTimeDDMMYYYY(selectedDateRange!.end)}',
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

  Widget _buildDataTable() {
    return BlocBuilder<PosSaleBloc, PosSaleState>(
      builder: (context, state) {
        if (state is PosSaleListLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PosSaleListSuccess) {
          if (state.list.isEmpty) {
            return Center(child: Lottie.asset(AppImages.noData));
          }
          return Column(
            children: [
              SizedBox(child: PosSaleDataTableWidget(sales: state.list)),
              const SizedBox(height: 6),
              PaginationBar(
                count: state.count,
                totalPages: state.totalPages,
                currentPage: state.currentPage,
                pageSize: state.pageSize,
                from: state.from,
                to: state.to,
                onPageChanged: (page) => _fetchProductList(
                  pageNumber: page,
                  pageSize: state.pageSize,
                ),
                onPageSizeChanged: (newSize) =>
                    _fetchProductList(pageNumber: 1, pageSize: newSize),
              ),
            ],
          );
        } else if (state is PosSaleListFailed) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load sales',
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
                ElevatedButton(
                  onPressed: () => _fetchApi(),
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }
        return Center(child: Lottie.asset(AppImages.noData));
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Filter POS Sales",
                          style: AppTextStyle.titleMedium(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Customer Filter
                    BlocBuilder<CustomerBloc, CustomerState>(
                      builder: (context, state) {
                        return AppDropdown<CustomerActiveModel>(
                          label: "",
                          hint: "Select Customer",
                          isSearch: true,
                          isLabel: false,
                          isRequired: false,
                          isNeedAll: true,
                          value: context.read<PosSaleBloc>().selectCustomerModel,
                          itemList: context.read<CustomerBloc>().activeCustomer,
                          onChanged: (newVal) {
                            setState(() {
                              context.read<PosSaleBloc>().selectCustomerModel = newVal;
                              selectedCustomerNotifier.value = newVal?.id.toString();
                            });
                          },
                        );
                      },
                    ),

                    // Seller Filter
                    BlocBuilder<UserBloc, UserState>(
                      builder: (context, state) {
                        return AppDropdown<UsersListModel>(
                          label: "",
                          hint: "Select Seller",
                          isLabel: false,
                          isRequired: false,
                          isNeedAll: true,
                          value: context.read<PosSaleBloc>().selectUserModel,
                          itemList: context.read<UserBloc>().list,
                          onChanged: (newVal) {
                            setState(() {
                              context.read<PosSaleBloc>().selectUserModel = newVal;
                              selectedSellerNotifier.value = newVal?.id.toString();
                            });
                          },
                        );
                      },
                    ),

                    // Date Range
                    CustomDateRangeField(
                      isLabel: false,
                      selectedDateRange: selectedDateRange,
                      onDateRangeSelected: (value) {
                        setState(() => selectedDateRange = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                filterTextController.clear();
                                context.read<PosSaleBloc>().selectCustomerModel = null;
                                context.read<PosSaleBloc>().selectUserModel = null;
                                selectedCustomerNotifier.value = null;
                                selectedSellerNotifier.value = null;
                                selectedDateRange = null;
                              });
                              Navigator.pop(context);
                              _fetchApi();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Clear All",
                              style: AppTextStyle.body(context).copyWith(color: AppColors.error),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Debug before fetching
                              print('=== APPLYING FILTERS ===');
                              print('From: ${selectedDateRange?.start}');
                              print('To: ${selectedDateRange?.end}');

                              _fetchApi(
                                filterText: filterTextController.text,
                                from: selectedDateRange?.start,
                                to: selectedDateRange?.end,
                                customer: selectedCustomerNotifier.value?.toString() ?? '',
                                seller: selectedSellerNotifier.value?.toString() ?? '',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor(context),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Apply Filters",
                              style: AppTextStyle.body(context).copyWith(color: AppColors.text(context)),
                            ),
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
}