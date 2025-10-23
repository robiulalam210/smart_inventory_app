import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:lottie/lottie.dart';

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
  TextEditingController filterTextController = TextEditingController();
  DateRange? selectedDateRange;

  // Add missing variables
  late DateTime now;
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    startDate = DateTime(now.year, now.month - 1, now.day);
    endDate = DateTime(now.year, now.month, now.day);

    filterTextController.clear();
    context.read<MoneyReceiptBloc>().selectUserModel = null;
    context.read<MoneyReceiptBloc>().selectCustomerModel = null;

    context.read<UserBloc>().add(
      FetchUserList(context, dropdownFilter: "?status=1"),
    );
    context.read<CustomerBloc>().add(
      FetchCustomerList(context, dropdownFilter: "?status=1"),
    );
    _fetchApi(from: startDate, to: endDate);
  }

  String selectedQuickOption = "";
  ValueNotifier<String?> selectedPaymentMethodNotifier = ValueNotifier(null);

  void _fetchApi({
    String filterText = '',
    String customer = '',
    String seller = '',
    String location = '',
    String paymentMethod = '',
    DateTime? from,
    DateTime? to,
    int pageNumber = 1, // Changed from 0 to 1 for pagination
    int pageSize = 10, // Added pageSize parameter
  }) {
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
        pageSize: pageSize, // Add pageSize
      ),
    );
  }

  // Fixed method name and parameters
  void _fetchMoneyReceiptList({int pageNumber = 1, int pageSize = 10}) {
    _fetchApi(
      pageNumber: pageNumber,
      pageSize: pageSize,
      from: selectedDateRange?.start ?? startDate,
      to: selectedDateRange?.end ?? endDate,
      customer: context.read<MoneyReceiptBloc>().selectCustomerModel?.id.toString() ?? '',
      seller: context.read<MoneyReceiptBloc>().selectUserModel?.id.toString() ?? '',
      paymentMethod: selectedPaymentMethodNotifier.value?.toString() ?? '',
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
          _fetchApi(
            from: startDate,
            to: endDate,
            customer: context.read<MoneyReceiptBloc>().selectCustomerModel?.id.toString() ?? '',
            seller: context.read<MoneyReceiptBloc>().selectUserModel?.id.toString() ?? '',
            paymentMethod: selectedPaymentMethodNotifier.value?.toString() ?? '',
          );
        },
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: BlocListener<MoneyReceiptBloc, MoneyReceiptState>(
            listener: (context, state) {
              if (state is MoneyReceiptAddLoading) {
                appLoader(context, "Money receipt, please wait...");
              } else if (state is MoneyReceiptAddSuccess) {
                Navigator.pop(context); // Close loader dialog
                _fetchApi(
                  from: startDate,
                  to: endDate,
                  customer: context.read<MoneyReceiptBloc>().selectCustomerModel?.id.toString() ?? '',
                  seller: context.read<MoneyReceiptBloc>().selectUserModel?.id.toString() ?? '',
                  paymentMethod: selectedPaymentMethodNotifier.value?.toString() ?? '',
                );
              } else if (state is MoneyReceiptDetailsSuccess) {
                // AppRoutes.pop(context);
              } else if (state is MoneyReceiptAddFailed) {
                Navigator.pop(context); // Close loader dialog
                _fetchApi(
                  from: startDate,
                  to: endDate,
                  customer: context.read<MoneyReceiptBloc>().selectCustomerModel?.id.toString() ?? '',
                  seller: context.read<MoneyReceiptBloc>().selectUserModel?.id.toString() ?? '',
                  paymentMethod: selectedPaymentMethodNotifier.value?.toString() ?? '',
                );
                appAlertDialog(context, state.content,
                    title: state.title,
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Dismiss"))
                    ]);
              } else if (state is MoneyReceiptDeleteLoading) {
                appLoader(context, "Delete MoneyReceipt, please wait...");
              } else if (state is MoneyReceiptDeleteSuccess) {
                Navigator.pop(context); // Close loader dialog
                _fetchApi(
                  from: startDate,
                  to: endDate,
                  customer: context.read<MoneyReceiptBloc>().selectCustomerModel?.id.toString() ?? '',
                  seller: context.read<MoneyReceiptBloc>().selectUserModel?.id.toString() ?? '',
                  paymentMethod: selectedPaymentMethodNotifier.value?.toString() ?? '',
                );
              } else if (state is MoneyReceiptDeleteFailed) {
                Navigator.pop(context); // Close loader dialog
                _fetchApi(
                  from: startDate,
                  to: endDate,
                  customer: context.read<MoneyReceiptBloc>().selectCustomerModel?.id.toString() ?? '',
                  seller: context.read<MoneyReceiptBloc>().selectUserModel?.id.toString() ?? '',
                  paymentMethod: selectedPaymentMethodNotifier.value?.toString() ?? '',
                );
                appAlertDialog(context, state.content,
                    title: state.title,
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Dismiss"))
                    ]);
              }
            },
            child: Column(
              children: [
                _buildFilterRow(),
                const SizedBox(height: 16),
                SizedBox(
                  child: BlocBuilder<MoneyReceiptBloc, MoneyReceiptState>(
                    builder: (context, state) {
                      if (state is MoneyReceiptListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is MoneyReceiptListSuccess) {
                        if (state.list.isEmpty) {
                          return Center(
                            child: Lottie.asset(AppImages.noData),
                          );
                        } else {
                          return Column(
                            children: [
                              SizedBox(
                                child: MoneyReciptDataTableWidget(sales: state.list),
                              ),
                              PaginationBar(
                                count: state.count,
                                totalPages: state.totalPages,
                                currentPage: state.currentPage,
                                pageSize: state.pageSize,
                                from: state.from,
                                to: state.to,
                                onPageChanged: (page) =>
                                    _fetchMoneyReceiptList(pageNumber: page, pageSize: state.pageSize),
                                onPageSizeChanged: (newSize) =>
                                    _fetchMoneyReceiptList(pageNumber: 1, pageSize: newSize),
                              ),
                            ],
                          );
                        }
                      } else if (state is MoneyReceiptListFailed) {
                        return Center(
                          child: Text('Failed to load money receipt: ${state.content}'),
                        );
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
                hint: context.read<MoneyReceiptBloc>().selectCustomerModel?.name?.toString() ?? "Select Customer",
                isNeedAll: true,
                isRequired: false,
                value: context.read<MoneyReceiptBloc>().selectCustomerModel,
                itemList: context.read<CustomerBloc>().list ?? [],
                onChanged: (newVal) {
                  print('Customer selected: ${newVal?.id} - ${newVal?.name}');

                  context.read<MoneyReceiptBloc>().selectCustomerModel = newVal;

                  _fetchApi(
                    from: selectedDateRange?.start ?? startDate,
                    to: selectedDateRange?.end ?? endDate,
                    customer: newVal?.id.toString() ?? '',
                    seller: context.read<MoneyReceiptBloc>().selectUserModel?.id.toString() ?? '',
                  );
                },
                validator: (value) => null,
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
              return AppDropdown<UsersListModel>(
                label: "Seller",
                context: context,
                hint: context.read<MoneyReceiptBloc>().selectUserModel?.username?.toString() ?? "Select Seller",
                isLabel: false,
                isRequired: false,
                isNeedAll: true,
                value: context.read<MoneyReceiptBloc>().selectUserModel,
                itemList: context.read<UserBloc>().list ?? [],
                onChanged: (newVal) {
                  print('Seller selected: ${newVal?.id} - ${newVal?.username}');

                  context.read<MoneyReceiptBloc>().selectUserModel = newVal;

                  _fetchApi(
                    from: selectedDateRange?.start ?? startDate,
                    to: selectedDateRange?.end ?? endDate,
                    customer: context.read<MoneyReceiptBloc>().selectCustomerModel?.id.toString() ?? '',
                    seller: newVal?.id.toString() ?? '',
                  );
                },
                validator: (value) => null,
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
              } else {
                _fetchApi(from: startDate, to: endDate);
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
    );
  }
}