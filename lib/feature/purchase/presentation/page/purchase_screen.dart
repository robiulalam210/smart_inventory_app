import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/date_range.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../../../supplier/data/model/supplier_active_model.dart';
import '../../../supplier/presentation/bloc/supplier/supplier_list_bloc.dart';
import '../../../supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';
import '../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../bloc/create_purchase/create_purchase_bloc.dart';
import '../bloc/purchase_bloc.dart';
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

  final TextEditingController filterTextController = TextEditingController();
  String selectedQuickOption = "";
  final ValueNotifier<String?> selectedPaymentMethodNotifier = ValueNotifier(null);
  final ValueNotifier<String?> selectedSupplierNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    filterTextController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(
        FetchUserList(context, dropdownFilter: "?status=1"),
      );
      context.read<SupplierListBloc>().add(
        FetchSupplierList(context),
      );
      context.read<SupplierInvoiceBloc>().add(FetchSupplierActiveList(context));

      selectedDateRange = DateRange(
        DateTime(now.year, now.month - 1, now.day),
        DateTime(now.year, now.month, now.day),
      );

      _fetchApi(
        from: selectedDateRange?.start,
        to: selectedDateRange?.end,
      );
    });
  }

  @override
  void dispose() {
    filterTextController.dispose();
    selectedPaymentMethodNotifier.dispose();
    selectedSupplierNotifier.dispose();
    super.dispose();
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
    if (!mounted) return;

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

  void _clearFilters() {
    setState(() {
      selectedDateRange = DateRange(
        DateTime(now.year, now.month - 1, now.day),
        DateTime(now.year, now.month, now.day),
      );
    });
    filterTextController.clear();
    selectedSupplierNotifier.value = null;
    selectedPaymentMethodNotifier.value = null;
    _fetchApi();
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

                  _buildDesktopHeader(),

                const SizedBox(height: 16),
                SizedBox(
                  child: _buildPurchaseList(),
                ),
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
          mainAxisAlignment: MainAxisAlignment.start,
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
                    value: null,
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
              child: ValueListenableBuilder<String?>(
                valueListenable: selectedPaymentMethodNotifier,
                builder: (context, value, child) {
                  return AppDropdown<String>(
                    label: "Payment Status",
                    context: context,
                    hint: "Select Payment Status",
                    isNeedAll: true,
                    isRequired: false,
                    isLabel: true,
                    value: value,
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
                  );
                },
              ),
            ),
            const SizedBox(width: 5),

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
                  }
                },
              ),
            ),
            const SizedBox(width: 5),

            IconButton(
              onPressed: _clearFilters,
              icon:  Icon(HugeIcons.strokeRoundedCancelCircle,color: AppColors.redAccent,),
              tooltip: "Cancel",
            ),
            IconButton(
              onPressed: () => _fetchApi(),
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh",
            ),
          ],
        ),

      ],
    );
  }


  Widget _buildPurchaseList() {
    return BlocBuilder<PurchaseBloc, PurchaseState>(
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
                  child: PurchaseDataTableWidget(
                    sales: state.list,
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
                  onPageChanged: (page) => _fetchPurchaseList(
                    pageNumber: page,
                    pageSize: state.pageSize,
                  ),
                  onPageSizeChanged: (newSize) => _fetchPurchaseList(
                    pageNumber: 1,
                    pageSize: newSize,
                  ),
                ),
              ],
            );
          }
        } else if (state is PurchaseListFailed) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load purchases',
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
                AppButton(
                  name: "Retry",
                  onPressed: () => _fetchApi(),
                ),
              ],
            ),
          );
        } else {
          return Center(child: Lottie.asset(AppImages.noData));
        }
      },
    );
  }


}