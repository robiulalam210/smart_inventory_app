import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '../../../../core/configs/configs.dart';
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

class MobilePurchaseScreen extends StatefulWidget {
  const MobilePurchaseScreen({super.key, this.posSale});

  final String? posSale;

  @override
  State<MobilePurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<MobilePurchaseScreen> {
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
        supplier: (supplier.isNotEmpty && supplier != 'null') ? supplier : '',
        paymentStatus:
        (paymentStatus.isNotEmpty && paymentStatus != 'null')
            ? paymentStatus
            : '',
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

    return AppScaffold(
       appBar: AppBar(title: Text("Purchase",style: AppTextStyle.titleMedium(context),),),
      body:  RefreshIndicator(
        color: AppColors.primaryColor(context),
        onRefresh: () async {
          _fetchApi();
        },
        child: Container(        color: AppColors.bottomNavBg(context),


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
            child: SingleChildScrollView(
              child: Column(
                children: [

                    _buildMobileHeader(),
                  const SizedBox(height: 6),
                  SizedBox(
                    child: _buildPurchaseList(),
                  ),
                ],
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
        Container(
          decoration: BoxDecoration(
            color: AppColors.bottomNavBg(context),
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
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: CustomSearchTextFormField(
                    controller: filterTextController,
                    onChanged: (value) => _fetchApi(filterText: value),
                    onClear: () {
                      filterTextController.clear();
                      _fetchApi();
                    },
                    hintText: "purchases...",
                  ),
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
                onPressed: () => _fetchApi(),
                icon: const Icon(Icons.refresh),
                tooltip: "Refresh",
              ),  IconButton(
                onPressed: (){ _clearFilters();

                },
                icon:  Icon(HugeIcons.strokeRoundedCancelSquare),
                tooltip: "Clear",
              ),
            ],
          ),
        ),

        // Filter Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (selectedSupplierNotifier.value != null)
              Chip(
                label: const Text('Supplier Filtered'),
                onDeleted: () {
                  selectedSupplierNotifier.value = null;
                  _fetchApi();
                },
              ),
            if (selectedPaymentMethodNotifier.value != null)
              Chip(
                label: Text(selectedPaymentMethodNotifier.value!),
                onDeleted: () {
                  selectedPaymentMethodNotifier.value = null;
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
              color: AppColors.bottomNavBg(context),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        "Filter Purchases",
                        style: AppTextStyle.titleMedium(context)
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Supplier Filter
                  BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
                    builder: (context, state) {
                      return AppDropdown<SupplierActiveModel>(
                        label: "",
                        hint: "Select Supplier",
                        isLabel: false,
                        isRequired: false,
                        isNeedAll: true,
                        value: null,
                        itemList: context.read<SupplierInvoiceBloc>().supplierActiveList,
                        onChanged: (newVal) {
                          setState(() {
                            selectedSupplierNotifier.value = newVal?.id?.toString();
                          });
                        },

                      );
                    },
                  ),
gapH16,
                  // Payment Status Filter
                  Wrap(
                    spacing: 8,
                    children: ["All", "Paid", "Pending", "Partial"].map((status) {
                      final bool isSelected =
                          selectedPaymentMethodNotifier.value == status ||
                              (status == "All" && selectedPaymentMethodNotifier.value == null);
                      return FilterChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedPaymentMethodNotifier.value = selected ? status : null;
                          });
                        },
                        selectedColor: AppColors.primaryColor(context).withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primaryColor(context),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),

                  // Date Range
                  CustomDateRangeField(
                    isLabel: false,
                    selectedDateRange: selectedDateRange,
                    onDateRangeSelected: (value) {
                      setState(() => selectedDateRange = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              filterTextController.clear();
                              selectedSupplierNotifier.value = null;
                              selectedPaymentMethodNotifier.value = null;
                              selectedDateRange = null;
                            });
                            Navigator.pop(context);
                            _fetchApi(
                              to: selectedDateRange?.start,
                              from: selectedDateRange?.end,
                              filterText: filterTextController.text,
                              supplier: selectedSupplierNotifier.value??"",
                              paymentStatus: selectedPaymentMethodNotifier.value??""
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Clear All",
                            style: AppTextStyle.body(
                              context,
                            ).copyWith(color: AppColors.error),
                          ),
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
                            backgroundColor: AppColors.primaryColor(context),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child:  Text("Apply Filters",style: AppTextStyle.body(
                            context,
                          ).copyWith(color: AppColors.text(context)),),
                        ),
                      ),
                    ],
                  ),
                  // Action Buttons

                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

}