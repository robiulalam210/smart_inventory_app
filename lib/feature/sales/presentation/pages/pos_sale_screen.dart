import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
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

class PosSaleScreen extends StatefulWidget {
  const PosSaleScreen({super.key, this.posSale});

  final String? posSale;

  @override
  State<PosSaleScreen> createState() => _PosSaleScreenState();
}

class _PosSaleScreenState extends State<PosSaleScreen> {
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

      _fetchApi();
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
      filter +=
          "&start_date=${from.toIso8601String()}&end_date=${to.toIso8601String()}";
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
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return Container(
      color: AppColors.bottomNavBg(context),
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
        color: AppColors.primaryColor(context),
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
                    if (context.mounted) {
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
                  }
                },
              ),
            ],
            child: Column(
              children: [
                if (isBigScreen)
                  _buildDesktopHeader(),

                SizedBox(child: _buildDataTable()),
              ],
            ),
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
              flex: 2,
              child: CustomSearchTextFormField(
                controller: filterTextController,
                onChanged: (value) => _fetchApi(filterText: value),
                onClear: () {
                  filterTextController.clear();
                  _fetchApi();
                },
                hintText: "InvoiceNo, Name, or Phone",
              ),
            ),
            const SizedBox(width: 5),

            // 👤 Customer Dropdown
            Expanded(
              flex: 1,
              child: BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, state) {
                  return ValueListenableBuilder<String?>(
                    valueListenable: selectedCustomerNotifier,
                    builder: (context, customerId, child) {
                      final selectedCustomer = context
                          .read<PosSaleBloc>()
                          .selectCustomerModel;

                      return AppDropdown<CustomerActiveModel>(
                        label: "Customer",
                        context: context,
                        isSearch: true,
                        hint: selectedCustomer?.name ?? "Select Customer",
                        isNeedAll: true,
                        isRequired: false,
                        isLabel: true,
                        value: selectedCustomer,
                        itemList: context.read<CustomerBloc>().activeCustomer,
                        onChanged: (newVal) {
                          context.read<PosSaleBloc>().selectCustomerModel =
                              newVal;
                          selectedCustomerNotifier.value = newVal?.id
                              .toString();
                          _fetchApi(customer: newVal?.id.toString() ?? '');
                        },
                        validator: (value) => null,
                        itemBuilder: (item) =>
                            DropdownMenuItem<CustomerActiveModel>(
                              value: item,
                              child: Text(
                                item.name ?? 'Unknown Customer',
                                style:  TextStyle(
                                  color:AppColors.blackColor(context),
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 5),

            // 🧑‍💼 Seller Dropdown
            Expanded(
              flex: 1,
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  return ValueListenableBuilder<String?>(
                    valueListenable: selectedSellerNotifier,
                    builder: (context, sellerId, child) {
                      final selectedSeller = context
                          .read<PosSaleBloc>()
                          .selectUserModel;

                      return AppDropdown<UsersListModel>(
                        label: "Seller",
                        context: context,
                        hint: selectedSeller?.username ?? "Select Seller",
                        isLabel: true,
                        isRequired: false,
                        isNeedAll: true,
                        value: selectedSeller,
                        itemList: context.read<UserBloc>().list,
                        onChanged: (newVal) {
                          context.read<PosSaleBloc>().selectUserModel = newVal;
                          selectedSellerNotifier.value = newVal?.id.toString();
                          _fetchApi(seller: newVal?.id.toString() ?? '');
                        },
                        validator: (value) => null,
                        itemBuilder: (item) => DropdownMenuItem<UsersListModel>(
                          value: item,
                          child: Text(
                            item.username ?? 'Unknown Seller',
                            style:  TextStyle(
                              color:AppColors.blackColor(context),
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 5),

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
                    _fetchApi();
                  }
                },
              ),
            ),
            const SizedBox(width: 5),

            IconButton(
              onPressed: () => _clearFilters,
              icon:  Icon(HugeIcons.strokeRoundedCancelCircle,color: AppColors.errorColor(context),),
              tooltip: "Cancel",
            ),   IconButton(
              onPressed: () => _fetchApi(),
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh",
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


}
