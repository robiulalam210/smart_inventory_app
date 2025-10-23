import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_inventory/feature/users_list/data/model/user_model.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/date_range.dart';
import '../../../customer/data/model/customer_model.dart';
import '../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../../data/models/pos_sale_model.dart';
import '../bloc/possale/crate_pos_sale/create_pos_sale_bloc.dart';
import '../bloc/possale/possale_bloc.dart';
import '../widgets/widget.dart';

class PosSaleScreen extends StatefulWidget {
  const PosSaleScreen({super.key, this.posSale});
  final String? posSale;

  @override
  State<PosSaleScreen> createState() => _PosSaleScreenState();
}

class _PosSaleScreenState extends State<PosSaleScreen> {
  DateTime? startDate;
  TextEditingController filterTextController = TextEditingController();


  DateRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    filterTextController.clear();
    context.read<UserBloc>().add(FetchUserList(context, dropdownFilter: "?status=1"));
    context.read<CustomerBloc>().add(FetchCustomerList(context, dropdownFilter: "?status=1"));
    _fetchApi();
  }

  void _fetchApi({
    String filterText = '',
    String customer = '',
    String seller = '',
    DateTime? from,
    DateTime? to,
    int pageNumber = 1,
  }) {
    String filter = "?page=$pageNumber";

    if (filterText.isNotEmpty) filter += "&search=$filterText";
    if (customer.isNotEmpty) filter += "&customer=$customer";
    if (seller.isNotEmpty) filter += "&seller=$seller";
    if (from != null && to != null) {
      filter += "&start_date=${from.toIso8601String()}&end_date=${to.toIso8601String()}";
    }

    context.read<PosSaleBloc>().add(FetchPosSaleList(context, dropdownFilter: filter));
  }

  void _fetchProductList({required int pageNumber, required int pageSize}) {
    _fetchApi(pageNumber: pageNumber);
  }

  @override
  void dispose() {
    filterTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen = Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return Container(
      color: AppColors.bg,
      child: SafeArea(
        child: ResponsiveRow(
          children: [
            if (isBigScreen) _buildSidebar(),
            _buildContentArea(isBigScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() => ResponsiveCol(
    xs: 0,
    sm: 1,
    md: 1,
    lg: 2,
    xl: 2,
    child: Container(color: Colors.white, child: const Sidebar()),
  );

  Widget _buildContentArea(bool isBigScreen) {
    return ResponsiveCol(
      xs: 12,
      lg: 10,
      child: RefreshIndicator(
        onRefresh: () async => _fetchApi(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: MultiBlocListener(
            listeners: [
              BlocListener<CreatePosSaleBloc, CreatePosSaleState>(
                listener: (context, state) {
                  if (state is CreatePosSaleLoading) {
                    appLoader(context, "Creating POS Sale...");
                  } else if (state is CreatePosSaleSuccess) {
                    Navigator.pop(context);
                    _fetchApi();
                  } else if (state is CreatePosSaleFailed) {
                    Navigator.pop(context);
                    appAlertDialog(
                      context,
                      state.content,
                      title: state.title,
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Dismiss"),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
            child: Column(
              children: [
                _buildFilterRow(),
                const SizedBox(height: 16),
                _buildDataTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        // 🔍 Search Field
        Expanded(
          child: CustomSearchTextFormField(
            controller: filterTextController,
            onChanged: (value) => _fetchApi(filterText: value),
            onClear: () {
              filterTextController.clear();
              _fetchApi();
            },
            hintText: "Search InvoiceNo, Name, or Phone",
          ),
        ),
        const SizedBox(width: 10),

        // 👤 Customer Dropdown
        Expanded(
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              return AppDropdown<CustomerModel>(
                label: "Customer",
                context: context,
                isSearch: true,
                hint: context
                    .read<PosSaleBloc>()
                    .selectCustomerModel
                    ?.name
                    ?.toString() ??
                    "Select Customer",
                isNeedAll: true,
                isRequired: true,
                value: context.read<PosSaleBloc>().selectCustomerModel,
                itemList: context.read<CustomerBloc>().list,
                onChanged: (newVal) {
                  print('Customer selected: ${newVal?.id} - ${newVal?.name}');

                  // Update bloc state
                  context.read<PosSaleBloc>().selectCustomerModel = newVal;

                  _fetchApi(
                    from: selectedDateRange?.start,
                    to: selectedDateRange?.end,
                    customer: newVal?.id.toString() ?? '', // Use newVal
                    seller: context
                        .read<PosSaleBloc>()
                        .selectUserModel
                        ?.id.toString() ?? '',
                  );
                },
                validator: (value) {
                  return value == null
                      ? 'Please select Customer'
                      : null;
                },
                itemBuilder: (item) => DropdownMenuItem<CustomerModel>(
                  value: item,
                  child: Text(
                    item.name ?? 'Unknown Customer',
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
        const SizedBox(width: 10),

        // 🧑‍💼 Seller Dropdown
        Expanded(
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              return AppDropdown<UsersListModel>( // Use UserModel instead of UsersListModel
                label: "Seller",
                context: context,
                hint: context
                    .read<PosSaleBloc>()
                    .selectUserModel
                    ?.username
                    ?.toString() ??
                    "Select Seller",
                isLabel: false,
                isRequired: true,
                isNeedAll: true,
                value: context.read<PosSaleBloc>().selectUserModel,
                itemList: context.read<UserBloc>().list,
                onChanged: (newVal) {
                  print('Seller selected: ${newVal?.id} - ${newVal?.username}');

                  // Update bloc state - UNCOMMENT THIS
                  context.read<PosSaleBloc>().selectUserModel = newVal;

                  _fetchApi(
                    from: selectedDateRange?.start,
                    to: selectedDateRange?.end,
                    customer: context
                        .read<PosSaleBloc>()
                        .selectCustomerModel
                        ?.id.toString() ?? '',
                    seller: newVal?.id.toString() ?? '', // Use newVal instead of old value
                  );
                },
                validator: (value) {
                  return value == null
                      ? 'Please select Collected By'
                      : null;
                },
                itemBuilder: (item) => DropdownMenuItem<UsersListModel>(
                  value: item,
                  child: Text(
                    item.username ?? 'Unknown Seller', // Use username instead of toString()
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
        const SizedBox(width: 10),

        // 📅 Date Range Picker
        SizedBox(
          width: 280,
          child: CustomDateRangeField(
            selectedDateRange: selectedDateRange,
            onDateRangeSelected: (value) {
              setState(() => selectedDateRange = value);
              if (value != null) {
                _fetchApi(from: value.start, to: value.end);
              }
            },
          ),
        ),
        const SizedBox(width: 10),

        IconButton(
          onPressed: _fetchApi,
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
        ),
      ],
    );
  }
  Widget _buildDataTable() {
    return BlocBuilder<PosSaleBloc, PosSaleState>(
      builder: (context, state) {
        if (state is PosSaleListLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading sales data..."),
              ],
            ),
          );
        } else if (state is PosSaleListSuccess) {
          if (state.list.isEmpty) {
            return _noDataWidget("No sales data found");
          }
          return Column(
            children: [
              PosSaleDataTableWidget(sales: state.list),
              PaginationBar(
                count: state.count,
                totalPages: state.totalPages,
                currentPage: state.currentPage,
                pageSize: state.pageSize,
                from: state.from,
                to: state.to,
                onPageChanged: (page) =>
                    _fetchProductList(pageNumber: page, pageSize: state.pageSize),
                onPageSizeChanged: (newSize) =>
                    _fetchProductList(pageNumber: 1, pageSize: newSize),
              ),
            ],
          );
        } else if (state is PosSaleListFailed) {
          return _errorWidget(state.content);
        }
        return _noDataWidget("No data available");
      },
    );
  }

  Widget _noDataWidget(String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(AppImages.noData, width: 200, height: 200),
        const SizedBox(height: 12),
        Text(message),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: _fetchApi, child: const Text("Refresh")),
      ],
    ),
  );

  Widget _errorWidget(String error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 60, color: Colors.red),
        const SizedBox(height: 16),
        Text("Error: $error"),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: _fetchApi, child: const Text("Retry")),
      ],
    ),
  );
}
