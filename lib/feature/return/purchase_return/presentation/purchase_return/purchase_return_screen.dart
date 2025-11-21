import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:meherin_mart/core/configs/configs.dart';
import 'package:meherin_mart/feature/supplier/data/model/supplier_active_model.dart';
import 'package:meherin_mart/feature/supplier/presentation/bloc/supplier/supplier_list_bloc.dart';
import 'package:meherin_mart/feature/supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_alert_dialog.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/date_range.dart';
import '../../../../products/product/presentation/widget/pagination.dart';
import '../bloc/purchase_return/purchase_return_bloc.dart';
import 'create_purchase_return/create_purchase_return_screen.dart';
import 'widget/widget.dart';

class PurchaseReturnScreen extends StatefulWidget {
  const PurchaseReturnScreen({super.key});

  @override
  State<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> {
  DateTime? startDate;
  DateTime? endDate;
  DateTime now = DateTime.now();
  TextEditingController filterTextController = TextEditingController();
  DateRange? selectedDateRange;
  SupplierActiveModel? _selectedSupplier;

  @override
  void initState() {
    super.initState();
    startDate = DateTime(now.year, now.month - 1, now.day);
    endDate = DateTime(now.year, now.month, now.day);
    // Load initial data
    context.read<SupplierInvoiceBloc>().add(FetchSupplierActiveList(context));

    context.read<SupplierListBloc>().add(FetchSupplierList(context));
    _fetchPurchaseReturnList(from: startDate, to: endDate);
  }

  void _fetchPurchaseReturnList({
    String filterText = '',
    DateTime? from,
    DateTime? to,
    int pageNumber = 0,
  }) {
    context.read<PurchaseReturnBloc>().add(FetchPurchaseReturn(
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
        onRefresh: () async => _fetchPurchaseReturnList(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: BlocListener<PurchaseReturnBloc, PurchaseReturnState>(
            listener: (context, state) {
              if (state is PurchaseReturnCreateLoading) {
                appLoader(context, "Creating Purchase Return...");
              } else if (state is PurchaseReturnCreateSuccess) {
                Navigator.pop(context);
                _fetchPurchaseReturnList(from: startDate, to: endDate);
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
              } else if (state is PurchaseReturnDeleteLoading) {
                appLoader(context, "Deleting Purchase Return...");
              } else if (state is PurchaseReturnDeleteSuccess) {
                Navigator.pop(context);
                _fetchPurchaseReturnList(from: startDate, to: endDate);
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
              } else if (state is PurchaseReturnError) {
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 🔍 Search Field
        Expanded(
          flex: 2,
          child: CustomSearchTextFormField(
            isRequiredLabel: false,
            controller: filterTextController,
            onChanged: (value) => _fetchPurchaseReturnList(filterText: value),
            onClear: () {
              filterTextController.clear();
              _fetchPurchaseReturnList();
            },
            hintText: "by Receipt No, Supplier, or Reason",
          ),
        ),
        const SizedBox(width: 6),

        // 👤 Supplier Dropdown
        Expanded(
          flex: 1,
          child: BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
            builder: (context, state) {
              return AppDropdown<SupplierActiveModel>(
                label: "Supplier",
                context: context,
                isSearch: true,
                hint: _selectedSupplier?.name ?? "Select Supplier",
                isNeedAll: true,
                isRequired: false,
                isLabel: true,
                value: _selectedSupplier,
                itemList: context.read<SupplierInvoiceBloc>().supplierActiveList,
                onChanged: (newVal) {
                  setState(() {
                    _selectedSupplier = newVal;
                  });
                  _fetchPurchaseReturnList(
                    from: selectedDateRange?.start,
                    to: selectedDateRange?.end,
                  );
                },
                itemBuilder: (item) {
                  final isAllOption = item.id == null;
                  return DropdownMenuItem<SupplierActiveModel>(
                    value: item,
                    child: Text(
                      isAllOption ? 'All Suppliers' : '${item.name} (${item.phone})',
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
                _fetchPurchaseReturnList(from: value.start, to: value.end);
              }
            },
          ),
        ),
        const SizedBox(width: 6),
        gapW16,
        AppButton(
          name: "Create Purchase Return",
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: SizedBox(
                    width: AppSizes.width(context) * 0.70,
                    child: CreatePurchaseReturnScreen(),
                  ),
                );
              },
            );
          },
        ),
        // 🔄 Refresh Button
        IconButton(
          onPressed: () => _fetchPurchaseReturnList(),
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return BlocBuilder<PurchaseReturnBloc, PurchaseReturnState>(
      builder: (context, state) {
        if (state is PurchaseReturnLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading purchase returns..."),
              ],
            ),
          );
        } else if (state is PurchaseReturnSuccess) {
          if (state.list.isEmpty) {
            return _noDataWidget("No purchase returns found");
          }
          return Column(
            children: [
              SizedBox(
                child: PurchaseReturnTableCard(purchaseReturns: state.list),
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
                  _fetchPurchaseReturnList(
                    pageNumber: page,
                    from: selectedDateRange?.start,
                    to: selectedDateRange?.end,
                  );
                },
                onPageSizeChanged: (newSize) {
                  _fetchPurchaseReturnList(pageNumber: 0);
                },
              ),
            ],
          );
        } else if (state is PurchaseReturnError) {
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
            onPressed: () => _fetchPurchaseReturnList(),
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
            onPressed: () => _fetchPurchaseReturnList(),
            child: const Text("Retry")
        ),
      ],
    ),
  );
}