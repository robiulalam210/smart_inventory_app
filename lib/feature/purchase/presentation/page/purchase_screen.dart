
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:smart_inventory/feature/purchase/presentation/bloc/create_purchase/create_purchase_bloc.dart';
import 'package:smart_inventory/feature/purchase/presentation/bloc/purchase_bloc.dart';
import 'package:smart_inventory/feature/supplier/data/model/supplier_active_model.dart';
import 'package:smart_inventory/feature/supplier/presentation/bloc/supplier/supplier_list_bloc.dart';
import 'package:smart_inventory/feature/supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/date_range.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../widget.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key, this.posSale});

  final String? posSale;

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  DateTime now = DateTime.now();
  DateRange? selectedDateRange;

  TextEditingController filterTextController = TextEditingController();
  String selectedQuickOption = "";
  ValueNotifier<String?> selectedPaymentMethodNotifier = ValueNotifier(null);
  ValueNotifier<String?> selectedSupplierNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    filterTextController.clear();

    context.read<UserBloc>().add(
      FetchUserList(context, dropdownFilter: "?status=1"),
    );
    context.read<SupplierListBloc>().add(
      FetchSupplierList(context),
    );
    _fetchApi(
      from: selectedDateRange?.start,
      to: selectedDateRange?.end,
    );
  }

  void _fetchApi({
    String filterText = '',
    String supplier = '',
    String paymentStatus = '',
    DateTime? from,
    DateTime? to,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    context.read<PurchaseBloc>().add(
      FetchPurchaseList(
        context,
        filterText: filterText,
        supplier: supplier,
        paymentStatus: paymentStatus,
        startDate: from,
        endDate: to,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  void _fetchPurchaseList({int pageNumber = 1, int pageSize = 10}) {
    _fetchApi(
      pageNumber: pageNumber,
      pageSize: pageSize,
      from: selectedDateRange?.start,
      to: selectedDateRange?.end,
      supplier: selectedSupplierNotifier.value?.toString() ?? '',
      paymentStatus: selectedPaymentMethodNotifier.value?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    filterTextController.dispose();
    super.dispose();
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
          child: MultiBlocListener(
            listeners: [
              BlocListener<CreatePurchaseBloc, CreatePurchaseState>(
                listener: (context, state) {
                  if (state is CreatePurchaseLoading) {
                    appLoader(context, "Creating Purchase, please wait...");
                  } else if (state is CreatePurchaseSuccess) {
                    Navigator.pop(context);
                    _fetchApi();
                  } else if (state is CreatePurchaseFailed) {
                    Navigator.pop(context);
                    _fetchApi();
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
                SizedBox(
                  child: BlocBuilder<PurchaseBloc, PurchaseState>(
                    builder: (context, state) {
                      if (state is PurchaseListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is PurchaseListSuccess) {
                        if (state.list.isEmpty) {
                          return Center(child: Lottie.asset(AppImages.noData));
                        } else {
                          return Column(
                            children: [
                              SizedBox(
                                child: PurchaseDataTableWidget(sales: state.list),
                              ),
                              PaginationBar(
                                count: state.count,
                                totalPages: state.totalPages,
                                currentPage: state.currentPage,
                                pageSize: state.pageSize,
                                from: state.from,
                                to: state.to,
                                onPageChanged: (page) =>
                                    _fetchPurchaseList(pageNumber: page, pageSize: state.pageSize),
                                onPageSizeChanged: (newSize) =>
                                    _fetchPurchaseList(pageNumber: 1, pageSize: newSize),
                              ),
                            ],
                          );
                        }
                      } else if (state is PurchaseListFailed) {
                        return Center(
                          child: Text(state.content),
                        );
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
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.start,
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

        // 👤 Supplier Dropdown
        Expanded(
          flex: 1,
          child: BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
            builder: (context, state) {
              return AppDropdown<SupplierActiveModel>(
                label: "",
                context: context,
                hint: "Select Supplier",
                isLabel: true,
                isRequired: false,
                isNeedAll: true,
                value: null, // You might want to store selected supplier in a variable
                itemList: context.read<SupplierInvoiceBloc>().supplierActiveList,
                onChanged: (newVal) {
                  selectedSupplierNotifier.value = newVal?.id?.toString();
                  _fetchApi(
                    supplier: newVal?.id?.toString() ?? '',
                  );
                },
                validator: (value) => null,
                itemBuilder: (item) => DropdownMenuItem<SupplierActiveModel>(
                  value: item,
                  child: Text(
                    item.name ?? 'Unknown Supplier',
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
        const SizedBox(width: 5),

        // 💰 Payment Status Dropdown
        Expanded(
          child: AppDropdown<String>(
            label: "Payment Status",
            context: context,
            hint: "Select Payment Status",
            isNeedAll: true,
            isRequired: false,
            isLabel: true,
            value: selectedPaymentMethodNotifier.value,
            itemList: ['Paid', 'Pending', 'Partial'],
            onChanged: (newVal) {
              selectedPaymentMethodNotifier.value = newVal;
              _fetchApi(
                paymentStatus: newVal?.toLowerCase() ?? '',
              );
            },
            validator: (value) => null,
            itemBuilder: (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  color: AppColors.blackColor,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),

        // 📅 Date Range Picker
        SizedBox(
          width: 280,
          child: CustomDateRangeField(
            isLabel: false
            ,
            selectedDateRange: selectedDateRange,
            onDateRangeSelected: (value) {
              setState(() => selectedDateRange = value);
              if (value != null) {
                _fetchApi(from: value.start, to: value.end);
              }
            },
          ),
        ),
        const SizedBox(width: 5),

        IconButton(
          onPressed: () => _fetchApi(),
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
        ),
      ],
    );
  }
}