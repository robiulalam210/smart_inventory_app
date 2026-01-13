
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

import '/core/configs/configs.dart';
import '/feature/supplier/data/model/supplier_active_model.dart';
import '/feature/supplier/presentation/bloc/supplier/supplier_list_bloc.dart';
import '/feature/supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierInvoiceBloc>().add(FetchSupplierActiveList(context));
      context.read<SupplierListBloc>().add(FetchSupplierList(context));
      _fetchPurchaseReturnList(from: startDate, to: endDate);
    });
  }

  void _fetchPurchaseReturnList({
    String filterText = '',
    DateTime? from,
    DateTime? to,
    int pageNumber = 0,
    String? supplierId,
  }) {
    // Pass supplier ID if selected

    context.read<PurchaseReturnBloc>().add(FetchPurchaseReturn(
       context,
      startDate: from,
      endDate: to,
      filterText: filterText.isNotEmpty ? filterText : null,
      pageNumber: pageNumber,
      // supplierId: supplierIdToUse
    ));
  }

  void _clearFilters() {
    setState(() {
      filterTextController.clear();
      _selectedSupplier = null;
      selectedDateRange = null;
      startDate = DateTime(now.year, now.month - 1, now.day);
      endDate = DateTime(now.year, now.month, now.day);
    });
    _fetchPurchaseReturnList();
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen = Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return SafeArea(
      child: ResponsiveRow(
        children: [
          if (isBigScreen) _buildSidebar(),
          _buildContentArea(isBigScreen),
        ],
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
        onRefresh: () async {
          _fetchPurchaseReturnList();
          return Future.delayed(const Duration(milliseconds: 500));
        },
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: BlocListener<PurchaseReturnBloc, PurchaseReturnState>(
            listener: (context, state) {
              if (state is PurchaseReturnCreateLoading) {
                appLoader(context, "Creating Purchase Return...");
              } else if (state is PurchaseReturnCreateSuccess) {
                Navigator.pop(context); // Close loader
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
                Navigator.pop(context); // Close loader
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
                // Check if loader is showing before popping
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.pop(context);
                }
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

              // Handle status change events
              if (state is PurchaseReturnApproveSuccess ||
                  state is PurchaseReturnRejectSuccess ||
                  state is PurchaseReturnCompleteSuccess) {
                _fetchPurchaseReturnList(from: startDate, to: endDate);
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title
                Row(
                  children: [
                    Text(
                      'Purchase Returns',
                      style: AppTextStyle.bodyLarge(context),
                    ),
                    const Spacer(),
                    // Clear Filters Button
                    if (filterTextController.text.isNotEmpty ||
                        _selectedSupplier != null ||
                        selectedDateRange != null)
                      TextButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Clear Filters'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryColor(context),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildFilterRow(),
                const SizedBox(height: 16),
                SizedBox(child: _buildDataTable()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 🔍 Search Field
            Expanded(
              flex: 2,
              child: CustomSearchTextFormField(
                isRequiredLabel: false,
                controller: filterTextController,
                onChanged: (value) {
                  if (value.length > 2 || value.isEmpty) {
                    _fetchPurchaseReturnList(filterText: value);
                  }
                },
                onClear: () {
                  filterTextController.clear();
                  _fetchPurchaseReturnList();
                },
                hintText: "Search by Receipt No, Supplier, or Reason",
              ),
            ),
            const SizedBox(width: 12),

            // 👤 Supplier Dropdown
            Expanded(
              flex: 1,
              child: BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
                builder: (context, state) {
                  List<SupplierActiveModel> suppliers = [];

                  if (state is SupplierActiveListSuccess) {
                    suppliers = state.list;
                  } else if (state is SupplierInvoiceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Add "All Suppliers" option
                  final allSuppliersList = [
                    SupplierActiveModel(id: null, name: 'All Suppliers', phone: ''),
                    ...suppliers
                  ];

                  return AppDropdown<SupplierActiveModel>(
                    label: "Supplier",
                    context: context,
                    isSearch: true,
                    hint: "Select Supplier",
                    isNeedAll: false, // We handle "All" manually
                    isRequired: false,
                    isLabel: true,
                    value: _selectedSupplier,
                    itemList: allSuppliersList,
                    onChanged: (newVal) {
                      setState(() {
                        _selectedSupplier = newVal?.id != null ? newVal : null;
                      });
                      _fetchPurchaseReturnList(
                        from: selectedDateRange?.start ?? startDate,
                        to: selectedDateRange?.end ?? endDate,
                        supplierId: _selectedSupplier?.id?.toString(),
                      );
                    },
                    itemBuilder: (item) {
                      final isAllOption = item.id == null;
                      return DropdownMenuItem<SupplierActiveModel>(
                        value: item,
                        child: Text(
                          isAllOption ? 'All Suppliers' : '${item.name} (${item.phone})',
                          style: TextStyle(
                            color: isAllOption ? AppColors.primaryColor(context) :AppColors.blackColor(context),
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
            const SizedBox(width: 12),

            // 📅 Date Range Picker
            SizedBox(
              width: 260,
              child: CustomDateRangeField(
                isLabel: true,
                // label: "Date Range",
                selectedDateRange: selectedDateRange,
                onDateRangeSelected: (value) {
                  setState(() => selectedDateRange = value);
                  if (value != null) {
                    _fetchPurchaseReturnList(from: value.start, to: value.end);
                  } else {
                    // Reset to default dates when cleared
                    _fetchPurchaseReturnList(
                      from: startDate,
                      to: endDate,
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),

            // Create Button
            AppButton(
              name: "Create Purchase Return",
              // icon: Icons.add,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      insetPadding: const EdgeInsets.all(20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: AppSizes.width(context) * 0.70,
                          maxHeight: AppSizes.height(context) * 0.85,
                        ),
                        child: const CreatePurchaseReturnScreen(),
                      ),
                    );
                  },
                ).then((_) {
                  // Refresh list after dialog closes
                  _fetchPurchaseReturnList(from: startDate, to: endDate);
                });
              },
            ),
            const SizedBox(width: 8),

            // 🔄 Refresh Button
            IconButton(
              onPressed: () => _fetchPurchaseReturnList(),
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh",
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primaryColor(context).withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
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
                    from: selectedDateRange?.start ?? startDate,
                    to: selectedDateRange?.end ?? endDate,
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

  Widget _noDataWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            AppImages.noData,
            width: 200,
            height: 200,
            repeat: false,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton( // Now properly imported
            onPressed: () => _fetchPurchaseReturnList(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor(context),
              foregroundColor: Colors.white,
            ),
            child: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _errorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            "Error: $error",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton( // Now properly imported
            onPressed: () => _fetchPurchaseReturnList(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}