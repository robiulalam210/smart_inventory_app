
import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../../lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../../../products/soruce/presentation/bloc/source/source_bloc.dart';
import '../../data/model/supplier_list_model.dart';
import '../bloc/supplier/supplier_list_bloc.dart';
import '../widget/widget.dart';
import 'create_supplierr_screen.dart';
import 'mobile_create_supplier_screen.dart';

class MobileSupplierListScreen extends StatefulWidget {
  const MobileSupplierListScreen({super.key});

  @override
  State<MobileSupplierListScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<MobileSupplierListScreen> {
  late final SupplierListBloc dataBloc;
  final TextEditingController filterTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dataBloc = context.read<SupplierListBloc>();

    // Initialize source bloc
    context.read<SourceBloc>().add(FetchSourceList(context));

    _fetchApi();
  }

  @override
  void dispose() {
    filterTextController.dispose();
    super.dispose();
  }

  void _fetchApi({
    String filterText = '',
    String status = '',
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    context.read<SupplierListBloc>().add(
      FetchSupplierList(
        context,
        filterText: filterText,
        state: status,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  void _fetchSupplierList({int pageNumber = 1, int pageSize = 10}) {
    _fetchApi(
      pageNumber: pageNumber,
      pageSize: pageSize,
      filterText: filterTextController.text,
      status: dataBloc.selectedState == "All" ? "" : dataBloc.selectedState,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text("Supplier List", style: AppTextStyle.titleMedium(context)),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor(context),
        onPressed: (){
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              insetPadding: const EdgeInsets.all(20),
              child: SizedBox(

                height: AppSizes.height(context) * 0.5,
                child: const MobileCreateSupplierScreen(),
              ),
            );
          },
        );

      },child: Icon(Icons.add,color: AppColors.whiteColor(context),),),
      body: SafeArea(
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: BlocListener<SupplierListBloc, SupplierListState>(
            listener: (context, state) {
              if (state is SupplierAddLoading) {
                appLoader(context, "Creating Supplier, please wait...");
              } else if (state is SupplierDeleteLoading) {
                appLoader(context, "Delete Customer, please wait...");
              } else if (state is SupplierAddSuccess) {
                Navigator.pop(context); // Close loader dialog
                Navigator.pop(context); // Close loader dialog
                _fetchApi(); // Reload supplier list

                context.read<DashboardBloc>().add(
                  ChangeDashboardScreen(index: 10),
                );
              } else if (state is SupplierAddFailed) {
                Navigator.pop(context); // Close loader dialog
                appAlertDialog(
                  context,
                  state.content,
                  title: state.title,
                  actions: [
                    TextButton(
                      onPressed: () => AppRoutes.pop(context),
                      child: const Text("Dismiss"),
                    ),
                  ],
                );
              } else if (state is SupplierDeleteSuccess) {
                showCustomToast(
                  context: context,
                  title: 'Success!',
                  description: state.message,
                  icon: Icons.check_circle,
                  primaryColor: Colors.green,
                );

                Navigator.pop(context); // Close loader dialog
                _fetchApi(); // Reload warehouse list
              } else if (state is SupplierDeleteFailed) {
                Navigator.pop(context); // Close loader dialog
                _fetchApi();
                appAlertDialog(
                  context,
                  state.content,
                  title: state.title,
                  actions: [
                    TextButton(
                      onPressed: () => AppRoutes.pop(context),
                      child: const Text("Dismiss"),
                    ),
                  ],
                );
              }
            },
            child:  RefreshIndicator(
              onRefresh: ()async{
                _fetchApi();
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Mobile/Tablet layout
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Search Bar with Icon Button
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
                                child: CustomSearchTextFormField(
                                  controller: filterTextController,
                                  forSearch: true,
                                  isRequiredLabel: false,
                                  onClear: () {
                                    filterTextController.clear();
                                    _fetchApi();
                                    FocusScope.of(context).unfocus();

                                  },
                                  onChanged: (value) {
                                    _fetchApi(filterText: value);
                                  },
                                  hintText: " suppliers...",
                                ),
                              ),
                              // Filter Icon Button
                              Container(
                                margin: const EdgeInsets.only(right: 0),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor(context).withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Iconsax.filter,
                                    color: AppColors.primaryColor(context),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _showMobileFilterSheet(context);
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: (){
                                  dataBloc.selectedState = "";
                                  filterTextController.clear();

                      _fetchApi();
                                },
                                icon: const Icon(Icons.refresh),
                                tooltip: "Refresh",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Filter Chips and Create Button
                        Row(
                          children: [
                            // Filter Chip
                            if (dataBloc.selectedState.isNotEmpty &&
                                dataBloc.selectedState != "All")
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Chip(
                                  label: Text(dataBloc.selectedState),
                                  backgroundColor: AppColors.primaryColor(context)
                                      .withValues(alpha: 0.1),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setState(() {
                                      dataBloc.selectedState = "";
                                    });
                                    _fetchApi(
                                      filterText: filterTextController.text,
                                    );
                                  },
                                ),
                              ),
                            const Spacer(),

                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      child: BlocBuilder<SupplierListBloc, SupplierListState>(
                        builder: (context, state) {
                          if (state is SupplierListLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (state is SupplierListSuccess) {
                            if (state.list.isEmpty) {
                              return Center(child: Lottie.asset(AppImages.noData));
                            } else {
                              return Column(
                                children: [
                                  SizedBox(
                                    child: SupplierDataTableWidget(
                                      suppliers: state.list,
                                      onEdit: (v) {
                                        final supplierBloc = context.read<SupplierListBloc>();

                                        supplierBloc.customerNameController.text = v.name ?? "";
                                        supplierBloc.customerNumberController.text = v.phone ?? "";
                                        context
                                                .read<SupplierListBloc>()
                                                .customerNameController
                                                .text =
                                            v.name ?? "";
                                        context
                                                .read<SupplierListBloc>()
                                                .customerNumberController
                                                .text =
                                            v.phone ?? "";
                                        context
                                                .read<SupplierListBloc>()
                                                .addressController
                                                .text =
                                            v.address ?? "";
                                        context
                                                .read<SupplierListBloc>()
                                                .customerEmailController
                                                .text =
                                            v.email ?? "";
                                        context
                                            .read<SupplierListBloc>()
                                            .selectedState = v.isActive == true
                                            ? "Active"
                                            : "Inactive";
                                        _showEditDialog(context, v);
                                      },
                                      onEditMobile: (v) {
                                        final supplierBloc = context.read<SupplierListBloc>();

                                        supplierBloc.customerNameController.text = v.name ?? "";
                                        supplierBloc.customerNumberController.text = v.phone ?? "";
                                        context
                                            .read<SupplierListBloc>()
                                            .customerNameController
                                            .text =
                                            v.name ?? "";
                                        context
                                            .read<SupplierListBloc>()
                                            .customerNumberController
                                            .text =
                                            v.phone ?? "";
                                        context
                                            .read<SupplierListBloc>()
                                            .addressController
                                            .text =
                                            v.address ?? "";
                                        context
                                            .read<SupplierListBloc>()
                                            .customerEmailController
                                            .text =
                                            v.email ?? "";
                                        context
                                            .read<SupplierListBloc>()
                                            .selectedState = v.isActive == true
                                            ? "Active"
                                            : "Inactive";
                                        _showEditDialogMobile(context, v);
                                      },
                                      onDelete: (v) async {
                                        bool shouldDelete =
                                            await showDeleteConfirmationDialog(
                                              context,
                                            );
                                        if (!shouldDelete) return;

                                        context.read<SupplierListBloc>().add(
                                          DeleteSupplierList(v.id.toString()),
                                        );
                                      },
                                    ),
                                  ),
                                  // Add pagination
                                  PaginationBar(
                                    count: state.count,
                                    totalPages: state.totalPages,
                                    currentPage: state.currentPage,
                                    pageSize: state.pageSize,
                                    from: state.from,
                                    to: state.to,
                                    onPageChanged: (page) =>
                                        _fetchSupplierList(pageNumber: page),
                                    onPageSizeChanged: (newSize) =>
                                        _fetchSupplierList(pageSize: newSize),
                                  ),
                                ],
                              );
                            }
                          } else if (state is SupplierListFailed) {
                            return Center(
                              child: Text(
                                'Failed to load suppliers: ${state.content}',
                              ),
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
        ),
      ),
    );
  }

  // Helper function for mobile filter sheet
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
            return SafeArea(
              child: Container(
                color: AppColors.bottomNavBg(context),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          "Filter Suppliers",
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.text(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Status Filter
                     Text(
                      "Status",
                      style: TextStyle(fontWeight: FontWeight.w600,
                        color: AppColors.text(context),
                        fontSize: 14,),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: ["All", "Active", "Inactive"].map((status) {
                        final bool isSelected =
                            dataBloc.selectedState == status ||
                            (status == "All" && dataBloc.selectedState.isEmpty);
                        return FilterChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              dataBloc.selectedState = selected ? status : "";
                            });
                          },
                          selectedColor: AppColors.primaryColor(context).withValues(alpha:0.2),
                          checkmarkColor: AppColors.primaryColor(context),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                dataBloc.selectedState = "";
                                filterTextController.clear();
                              });
                              Navigator.pop(context);
                              _fetchApi();
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
                              _fetchApi(
                                filterText: filterTextController.text,
                                status: dataBloc.selectedState == "All"
                                    ? ""
                                    : dataBloc.selectedState,
                              );
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
              ),
            );
          },
        );
      },
    );
  }
  void _showEditDialogMobile(BuildContext context, SupplierListModel customer) {
    // Implement edit dialog logic
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: AppSizes.width(context) * 0.80,
            child: MobileCreateSupplierScreen(
              id: customer.id.toString(),
              submitText: "Update Supplier",
            ),
          ),
        );
      },
    );
  }
  void _showEditDialog(BuildContext context, SupplierListModel customer) {
    // Implement edit dialog logic
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: AppSizes.width(context) * 0.80,
            child: CreateSupplierScreen(
              id: customer.id.toString(),
              submitText: "Update Supplier",
            ),
          ),
        );
      },
    );
  }
}
