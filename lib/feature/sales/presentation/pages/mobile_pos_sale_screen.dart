import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/date_range.dart';
import '../../../customer/data/model/customer_active_model.dart';
import '../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../products/product/presentation/bloc/products/products_bloc.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../../../users_list/data/model/user_model.dart';
import '../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../bloc/possale/crate_pos_sale/create_pos_sale_bloc.dart';
import '../bloc/possale/possale_bloc.dart';
import '../widgets/widget.dart';

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

    selectedDateRange = DateRange(
      DateTime(now.year, now.month - 1, now.day),
      DateTime(now.year, now.month, now.day),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(
        FetchUserList(context, dropdownFilter: "?status=1"),
      );
      context.read<CustomerBloc>().add(FetchCustomerActiveList(context));
      context.read<ProductsBloc>().add(FetchProductsStockList(context));



      _fetchApi(

      );


    });
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

    if (filterText.isNotEmpty) filter += "&search=$filterText";
    if (customer.isNotEmpty) filter += "&customer=$customer";
    if (seller.isNotEmpty) filter += "&seller=$seller";
    if (from != null && to != null) {
      filter += "&start_date=${from.toIso8601String()}&end_date=${to.toIso8601String()}";
    }

    context.read<PosSaleBloc>().add(
      FetchPosSaleList(context, dropdownFilter: filter),
    );
  }

  void _fetchProductList({required int pageNumber, required int pageSize}) {
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
      selectedDateRange = DateRange(
        DateTime(now.year, now.month - 1, now.day),
        DateTime(now.year, now.month, now.day),
      );
    });
    filterTextController.clear();
    selectedCustomerNotifier.value = null;
    selectedSellerNotifier.value = null;

    // Clear bloc states
    context.read<PosSaleBloc>().selectCustomerModel = null;
    context.read<PosSaleBloc>().selectUserModel = null;

    _fetchApi();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text("Sales List",style: AppTextStyle.titleMedium(context),),
      ),
      body: SafeArea(
        child:ResponsiveCol(
          xs: 12,
          lg: 10,
          child: RefreshIndicator(
            onRefresh: () async => _fetchApi(),
            color: AppColors.primaryColor,
            child: Container(
              padding: AppTextStyle.getResponsivePaddingBody(context),
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    _buildMobileHeader(),
                    const SizedBox(height: 8),
                    SizedBox(
                      child: _buildDataTable(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
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
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
              ),
              IconButton(
                icon: Icon(
                  Iconsax.filter,
                  color: AppColors.primaryColor,
                ),
                onPressed: () => _showMobileFilterSheet(context),
              ),

              IconButton(
                onPressed: () => _clearFilters,
                icon: const Icon(Icons.refresh),
                tooltip: "Refresh",
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
              SizedBox(
                child: PosSaleDataTableWidget(sales: state.list),
              ),
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
                onPageSizeChanged: (newSize) => _fetchProductList(
                  pageNumber: 1,
                  pageSize: newSize,
                ),
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
                        "Filter POS Sales",
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

                  // Customer Filter
                  BlocBuilder<CustomerBloc, CustomerState>(
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Customer",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppDropdown<CustomerActiveModel>(
                            label: "",
                            context: context,
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
                            itemBuilder: (item) => DropdownMenuItem<CustomerActiveModel>(
                              value: item,
                              child: Text(item.name ?? 'Unknown Customer'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Seller Filter
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Seller",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppDropdown<UsersListModel>(
                            label: "",
                            context: context,
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
                            itemBuilder: (item) => DropdownMenuItem<UsersListModel>(
                              value: item,
                              child: Text(item.username ?? 'Unknown Seller'),
                            ),
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