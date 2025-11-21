import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:meherin_mart/core/configs/configs.dart';
import 'package:meherin_mart/feature/customer/data/model/customer_active_model.dart';
import 'package:meherin_mart/feature/return/sales_return/presentation/page/widget/widget.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/date_range.dart';
import '../../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../../products/product/presentation/widget/pagination.dart';
import '../sales_return_bloc/sales_return_bloc.dart';
import 'create_sales_return_screnn.dart';

class SalesReturnScreen extends StatefulWidget {
  const SalesReturnScreen({super.key});

  @override
  State<SalesReturnScreen> createState() => _SalesReturnScreenState();
}

class _SalesReturnScreenState extends State<SalesReturnScreen> {
  DateTime? startDate;
  DateTime? endDate;
  DateTime now = DateTime.now();
  TextEditingController filterTextController = TextEditingController();
  DateRange? selectedDateRange;
  CustomerActiveModel? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    startDate = DateTime(now.year, now.month - 1, now.day);
    endDate = DateTime(now.year, now.month, now.day);
    context.read<SalesReturnBloc>().add(FetchInvoiceList(context));

    // // Load initial data
    context.read<CustomerBloc>().add(FetchCustomerActiveList(context));
    _fetchSalesReturnList(from: startDate, to: endDate);
  }

  void _fetchSalesReturnList({
    String filterText = '',
    DateTime? from,
    DateTime? to,
    int pageNumber = 0,
  }) {
    context.read<SalesReturnBloc>().add(FetchSalesReturn(
      context,
      startDate: from,
      endDate: to,
      filterText: filterText,
      pageNumber: pageNumber,
    ));
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
        onRefresh: () async => _fetchSalesReturnList(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: BlocListener<SalesReturnBloc, SalesReturnState>(
            listener: (context, state) {
              if (state is SalesReturnCreateLoading) {
                appLoader(context, "Creating Sales Return...");
              } else if (state is SalesReturnCreateSuccess) {
                Navigator.pop(context);
                _fetchSalesReturnList(from: startDate, to: endDate);
                appAlertDialog(
                  context,
                  state.message,
                  title: "Success",
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                );
              } else if (state is SalesReturnDeleteLoading) {
                appLoader(context, "Deleting Sales Return...");
              } else if (state is SalesReturnDeleteSuccess) {
                Navigator.pop(context);
                _fetchSalesReturnList(from: startDate, to: endDate);
                appAlertDialog(
                  context,
                  state.message,
                  title: "Success",
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                );
              } else if (state is SalesReturnError) {
                // Navigator.pop(context);
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
            child: Column(
              children: [
                _buildFilterRow(),
                SizedBox(child: _buildDataTable()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 🔍 Search Field
        Expanded(
          flex: 2,
          child: CustomSearchTextFormField(
            controller: filterTextController,
            isRequiredLabel: false,
            onChanged: (value) => _fetchSalesReturnList(filterText: value),
            onClear: () {
              filterTextController.clear();
              _fetchSalesReturnList();
            },
            hintText: "by Receipt No, Customer, or Reason",
          ),
        ),
        const SizedBox(width: 6),

        // 👤 Customer Dropdown
        Expanded(
          flex: 1,
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              return AppDropdown<CustomerActiveModel>(
                label: "Customer",
                context: context,
                isSearch: true,
                hint: _selectedCustomer?.name ?? "Select Customer",
                isNeedAll: true,
                isRequired: false,
                isLabel: true,
                value: _selectedCustomer,
                itemList: context.read<CustomerBloc>().activeCustomer,
                onChanged: (newVal) {
                  setState(() {
                    _selectedCustomer = newVal;
                  });
                  _fetchSalesReturnList(
                    from: selectedDateRange?.start,
                    to: selectedDateRange?.end,
                  );
                },
                itemBuilder: (item) {
                  final isAllOption = item.id == null;
                  return DropdownMenuItem<CustomerActiveModel>(
                    value: item,
                    child: Text(
                      isAllOption ? 'All Customers' : '${item.name} (${item.phone})',
                      style: TextStyle(
                        color: isAllOption ? AppColors.primaryColor : AppColors.blackColor,
                        fontFamily: 'Quicksand',
                        fontWeight: isAllOption ? FontWeight.bold : FontWeight.w300,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(width: 6),

        // 📅 Date Range Picker
        SizedBox(
          width: 260,
          child: CustomDateRangeField(
            isLabel: false,
            selectedDateRange: selectedDateRange,
            onDateRangeSelected: (value) {
              setState(() => selectedDateRange = value);
              if (value != null) {
                _fetchSalesReturnList(from: value.start, to: value.end);
              }
            },
          ),
        ),
        const SizedBox(width: 6),
        gapW16,
        AppButton(
          name: "Create Sales Return", // Fixed button text
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: SizedBox(
                    width: AppSizes.width(context) * 0.70,
                    child: CreateSalesReturnScreen(),
                  ),
                );
              },
            );
          },
        ),
        // 🔄 Refresh Button
        IconButton(
          onPressed: () => _fetchSalesReturnList(),
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return BlocBuilder<SalesReturnBloc, SalesReturnState>(

      buildWhen: (previous, current) {
        return current is SalesReturnLoading ||
            current is SalesReturnSuccess ||
            current is SalesReturnError;
      },

         builder: (context, state) {
        if (state is SalesReturnLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading sales returns..."),
              ],
            ),
          );
        } else if (state is SalesReturnSuccess) {
          if (state.list.isEmpty) {
            return _noDataWidget("No sales returns found");
          }
          return Column(
            children: [
              SizedBox(
                child: SalesReturnTableCard(salesReturns: state.list),
              ),
              const SizedBox(height: 16),
              PaginationBar(
                count: state.count,
                totalPages: state.totalPages,
                currentPage: state.currentPage,
                pageSize: state.pageSize,
                from: state.from,
                to: state.to,
                onPageChanged: (page) {
                  _fetchSalesReturnList(
                    pageNumber: page,
                    from: selectedDateRange?.start,
                    to: selectedDateRange?.end,
                  );
                },
                onPageSizeChanged: (newSize) {
                  // Reset to page 1 when changing page size
                  _fetchSalesReturnList(
                    pageNumber: 1, // Changed from 0 to 1
                    // pageSize: newSize,
                    from: selectedDateRange?.start,
                    to: selectedDateRange?.end,
                  );
                },
              ),
            ],
          );
        } else if (state is SalesReturnError) {
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
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
            onPressed: () => _fetchSalesReturnList(),
            child: const Text("Refresh")
        ),
      ],
    ),
  );

  Widget _errorWidget(String error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 60, color: Colors.red),
        const SizedBox(height: 16),
        Text(
          "Error: $error",
          style: const TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
            onPressed: () => _fetchSalesReturnList(),
            child: const Text("Retry")
        ),
      ],
    ),
  );
}