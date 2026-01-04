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
import '../../../products/product/presentation/widget/pagination.dart';
import '../../../users_list/data/model/user_model.dart';
import '../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../bloc/money_receipt/money_receipt_bloc.dart';
import '../bloc/money_receipt/money_receipt_state.dart';
import '../widgets/widget.dart';

class MoneyReceiptScreen extends StatefulWidget {
  const MoneyReceiptScreen({super.key});

  @override
  State<MoneyReceiptScreen> createState() => _MoneyReceiptScreenState();
}

class _MoneyReceiptScreenState extends State<MoneyReceiptScreen> {
  final TextEditingController filterTextController = TextEditingController();
  DateRange? selectedDateRange;
  DateTime now = DateTime.now();

  final ValueNotifier<String?> selectedCustomerNotifier = ValueNotifier(null);
  final ValueNotifier<String?> selectedSellerNotifier = ValueNotifier(null);
  final ValueNotifier<String?> selectedPaymentMethodNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      filterTextController.clear();
      context.read<MoneyReceiptBloc>().selectUserModel = null;
      context.read<MoneyReceiptBloc>().selectCustomerModel = null;

      context.read<UserBloc>().add(
        FetchUserList(context, dropdownFilter: "?status=1"),
      );
      context.read<CustomerBloc>().add(
        FetchCustomerActiveList(context),
      );

      selectedDateRange = DateRange(
        DateTime(now.year, now.month - 1, now.day),
        DateTime(now.year, now.month, now.day),
      );

      _fetchApi();
    });
  }

  @override
  void dispose() {
    filterTextController.dispose();
    selectedCustomerNotifier.dispose();
    selectedSellerNotifier.dispose();
    selectedPaymentMethodNotifier.dispose();
    super.dispose();
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
    selectedPaymentMethodNotifier.value = null;

    // Clear bloc states
    context.read<MoneyReceiptBloc>().selectCustomerModel = null;
    context.read<MoneyReceiptBloc>().selectUserModel = null;

    _fetchApi();
  }

  void _fetchApi({
    String filterText = '',
    String customer = '',
    String seller = '',
    String paymentMethod = '',
    DateTime? from,
    DateTime? to,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    if (!mounted) return;

    context.read<MoneyReceiptBloc>().add(
      FetchMoneyReceiptList(
        context,
        filterText: filterText,
        customer: customer,
        seller: seller,
        paymentMethod: paymentMethod,
        startDate: from,
        endDate: to,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  void _fetchMoneyReceiptList({int pageNumber = 1, int pageSize = 10}) {
    _fetchApi(
      pageNumber: pageNumber,
      pageSize: pageSize,
      filterText: filterTextController.text,
      from: selectedDateRange?.start,
      to: selectedDateRange?.end,
      customer: selectedCustomerNotifier.value ?? '',
      seller: selectedSellerNotifier.value ?? '',
      paymentMethod: selectedPaymentMethodNotifier.value ?? '',
    );
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
          _fetchApi();
        },
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: BlocConsumer<MoneyReceiptBloc, MoneyReceiptState>(
            listener: (context, state) {
              _handleBlocState(state);
            },
            builder: (context, state) {
              return Column(
                children: [
                  if (isBigScreen)
                    _buildDesktopHeader()
                  else
                    _buildMobileHeader(),
                  const SizedBox(height: 16),
                  SizedBox(
                    child: _buildMoneyReceiptList(state),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleBlocState(MoneyReceiptState state) {
    if (state is MoneyReceiptAddLoading) {
      appLoader(context, "Processing money receipt, please wait...");
    } else if (state is MoneyReceiptAddSuccess) {
      Navigator.pop(context);
      _fetchApi();
    } else if (state is MoneyReceiptAddFailed) {
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
    } else if (state is MoneyReceiptDeleteLoading) {
      appLoader(context, "Deleting money receipt, please wait...");
    } else if (state is MoneyReceiptDeleteSuccess) {
      Navigator.pop(context);
      _fetchApi();
    } else if (state is MoneyReceiptDeleteFailed) {
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
                          .read<MoneyReceiptBloc>()
                          .selectCustomerModel;

                      return AppDropdown<CustomerActiveModel>(
                        label: "Customer",
                        context: context,
                        isSearch: true,
                        isLabel: true,
                        hint: selectedCustomer?.name ?? "Select Customer",
                        isNeedAll: true,
                        isRequired: false,
                        value: selectedCustomer,
                        itemList: context.read<CustomerBloc>().activeCustomer,
                        onChanged: (newVal) {
                          context.read<MoneyReceiptBloc>().selectCustomerModel = newVal;
                          selectedCustomerNotifier.value = newVal?.id.toString();
                          _fetchApi(
                            customer: newVal?.id.toString() ?? '',
                          );
                        },
                        itemBuilder: (item) => DropdownMenuItem<CustomerActiveModel>(
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
                      final selectedSeller = context.read<MoneyReceiptBloc>().selectUserModel;

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
                          context.read<MoneyReceiptBloc>().selectUserModel = newVal;
                          selectedSellerNotifier.value = newVal?.id.toString();
                          _fetchApi(
                            seller: newVal?.id.toString() ?? '',
                          );
                        },
                        itemBuilder: (item) => DropdownMenuItem<UsersListModel>(
                          value: item,
                          child: Text(
                            item.username ?? 'Unknown Seller',
                            style: const TextStyle(
                              color: AppColors.blackColor,
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
            const SizedBox(width: 10),

            // 📅 Date Range Picker
            SizedBox(
              width: 280,
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
            const SizedBox(width: 10),

            IconButton(
              onPressed: () => _fetchApi(),
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh",
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
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
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: CustomSearchTextFormField(
                    controller: filterTextController,
                    onChanged: (value) => _fetchApi(filterText: value),
                    onClear: () {
                      filterTextController.clear();
                      _fetchApi();
                    },
                    hintText: "Search money receipts...",
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
                onPressed: () => _fetchApi(),
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
                  context.read<MoneyReceiptBloc>().selectCustomerModel = null;
                  _fetchApi();
                },
              ),
            if (selectedSellerNotifier.value != null)
              Chip(
                label: const Text('Seller Filtered'),
                onDeleted: () {
                  selectedSellerNotifier.value = null;
                  context.read<MoneyReceiptBloc>().selectUserModel = null;
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
              child: OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear All'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoneyReceiptList(MoneyReceiptState state) {
    if (state is MoneyReceiptListLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is MoneyReceiptListSuccess) {
      if (state.list.isEmpty) {
        return Center(child: Lottie.asset(AppImages.noData));
      } else {
        return Column(
          children: [
            SizedBox(
              child: MoneyReceiptDataTableWidget(sales: state.list),
            ),
            const SizedBox(height: 16),
            PaginationBar(
              count: state.count,
              totalPages: state.totalPages,
              currentPage: state.currentPage,
              pageSize: state.pageSize,
              from: state.from,
              to: state.to,
              onPageChanged: (page) => _fetchMoneyReceiptList(
                pageNumber: page,
                pageSize: state.pageSize,
              ),
              onPageSizeChanged: (newSize) => _fetchMoneyReceiptList(
                pageNumber: 1,
                pageSize: newSize,
              ),
            ),
          ],
        );
      }
    } else if (state is MoneyReceiptListFailed) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load money receipts',
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
    } else {
      return Center(child: Lottie.asset(AppImages.noData));
    }
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
                        "Filter Money Receipts",
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
                            isSearch: true,
                            isLabel: false,
                            hint: "Select Customer",
                            isNeedAll: true,
                            isRequired: false,
                            value: context.read<MoneyReceiptBloc>().selectCustomerModel,
                            itemList: context.read<CustomerBloc>().activeCustomer,
                            onChanged: (newVal) {
                              setState(() {
                                context.read<MoneyReceiptBloc>().selectCustomerModel = newVal;
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
                            value: context.read<MoneyReceiptBloc>().selectUserModel,
                            itemList: context.read<UserBloc>().list,
                            onChanged: (newVal) {
                              setState(() {
                                context.read<MoneyReceiptBloc>().selectUserModel = newVal;
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
                              context.read<MoneyReceiptBloc>().selectCustomerModel = null;
                              context.read<MoneyReceiptBloc>().selectUserModel = null;
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