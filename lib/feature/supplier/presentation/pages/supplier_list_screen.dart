import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
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

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
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
          child: Column(
            children: [
              if (Responsive.isDesktop(context))
                // Desktop layout
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: CustomSearchTextFormField(
                        controller: filterTextController,
                        forSearch: true,
                        isRequiredLabel: false,
                        onClear: () {
                          filterTextController.clear();
                          _fetchApi();
                        },
                        onChanged: (value) {
                          _fetchApi(filterText: value);
                        },
                        hintText: "Search by Name",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: AppDropdown(
                        context: context,
                        hint: "Select Status",
                        isLabel: true,
                        isNeedAll: true,
                        value: dataBloc.selectedState.isEmpty
                            ? null
                            : dataBloc.selectedState,
                        itemList: dataBloc.statesList,
                        onChanged: (newVal) {
                          setState(() {
                            dataBloc.selectedState = newVal.toString();
                          });
                          _fetchApi(
                            filterText: filterTextController.text,
                            status: newVal.toString() == "All"
                                ? ""
                                : newVal.toString(),
                          );
                        },
                        itemBuilder: (item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item.toString(),
                            style: const TextStyle(
                              color: AppColors.blackColor,
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        label: '',
                      ),
                    ),
                    const SizedBox(width: 16),
                    AppButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              insetPadding: const EdgeInsets.all(20),
                              child: SizedBox(
                                width: AppSizes.width(context) * 0.5,
                                height: AppSizes.height(context) * 0.5,
                                child: const CreateSupplierScreen(),
                              ),
                            );
                          },
                        );
                      },
                      size: 150,
                      name: 'New Supplier',
                    ),
                  ],
                )
              else
                // Mobile/Tablet layout
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search Bar with Icon Button
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: CustomSearchTextFormField(
                                controller: filterTextController,
                                forSearch: true,
                                isRequiredLabel: false,
                                onClear: () {
                                  filterTextController.clear();
                                  _fetchApi();
                                },
                                onChanged: (value) {
                                  _fetchApi(filterText: value);
                                },
                                hintText: "Search suppliers...",
                              ),
                            ),
                          ),
                          // Filter Icon Button
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Iconsax.filter,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                              onPressed: () {
                                _showMobileFilterSheet(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

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
                              backgroundColor: AppColors.primaryColor
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
                        // Create Button
                        AppButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  insetPadding: const EdgeInsets.all(20),
                                  child: SizedBox(
                                    // width: AppSizes.width(context) * 0.5,
                                    height: AppSizes.height(context) * 0.5,
                                    child: const CreateSupplierScreen(),
                                  ),
                                );
                              },
                            );
                          },
                          size: 150,
                          name: 'New Supplier',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter Suppliers",
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
                  // Status Filter
                  const Text(
                    "Status",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
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
                        selectedColor: AppColors.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppColors.primaryColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons
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
                            _fetchApi(
                              filterText: filterTextController.text,
                              status: dataBloc.selectedState == "All"
                                  ? ""
                                  : dataBloc.selectedState,
                            );
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

  void _showEditDialog(BuildContext context, SupplierListModel customer) {
    // Implement edit dialog logic
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: AppSizes.width(context) * 0.50,
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
