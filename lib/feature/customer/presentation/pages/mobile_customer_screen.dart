
import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../bloc/customer/customer_bloc.dart';
import '../widget/widget.dart';
import 'mobile_create_customer_screen.dart';

class MobileCustomerScreen extends StatefulWidget {
  const MobileCustomerScreen({super.key});

  @override
  State<MobileCustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<MobileCustomerScreen> {
  final TextEditingController filterTextController = TextEditingController();
  final ValueNotifier<String?> selectedStatusNotifier = ValueNotifier(null);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    filterTextController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchApi();
    });
  }

  @override
  void dispose() {
    filterTextController.dispose();
    selectedStatusNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchApi({
    String filterText = '',
    String status = '',
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    if (!mounted) return;

    context.read<CustomerBloc>().add(
      FetchCustomerList(
        context,
        filterText: filterText,
        status: status,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  void _fetchCustomerList({int pageNumber = 1, int pageSize = 10}) {
    _fetchApi(
      pageNumber: pageNumber,
      pageSize: pageSize,
      filterText: filterTextController.text,
      status: selectedStatusNotifier.value?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: FloatingActionButton(  onPressed: () => _showCreateCustomerDialog(context),child: Icon(Icons.add),),
      appBar: AppBar(title: Text("Customer",style: AppTextStyle.titleMedium(context),),),
      body: SafeArea(
        child:   _buildContentArea(),
      ),
    );
  }


  Widget _buildContentArea() {
    return ResponsiveCol(
      xs: 12,
      sm: 12,
      md: 12,
      lg: 10,
      xl: 10,
      child: RefreshIndicator(
        color: AppColors.primaryColor(context),
        onRefresh: () async {
          _fetchApi();
        },
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: BlocConsumer<CustomerBloc, CustomerState>(
            listener: (context, state) {
              _handleBlocState(state);
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                
                      _buildMobileHeader(),
                    const SizedBox(height: 8),
                    SizedBox(
                      child: _buildCustomerList(state),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleBlocState(CustomerState state) {
    if (state is CustomerAddLoading) {
      appLoader(context, "Creating Customer, please wait...");
    } else if (state is CustomerSwitchLoading) {
      appLoader(context, "Updating Customer, please wait...");
    } else if (state is CustomerDeleteLoading) {
      appLoader(context, "Deleting Customer, please wait...");
    } else if (state is CustomerSwitchSuccess) {
      Navigator.pop(context);
      _fetchApi();
    } else if (state is CustomerDeleteSuccess) {
      if (context.mounted) {
        showCustomToast(
          context: context,
          title: 'Success!',
          description: state.message,
          icon: Icons.check_circle,
          primaryColor: Colors.green,
        );
        Navigator.pop(context);
        _fetchApi();
      }
    } else if (state is CustomerAddSuccess) {
      Navigator.pop(context);
      _fetchApi();
    } else if (state is CustomerSwitchFailed) {
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
    } else if (state is CustomerAddFailed) {
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
                      selectedStatusNotifier.value = null;
                      _fetchApi();
                    },
                    isRequiredLabel: false,
                    hintText: "Search customers...",
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
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Filter Chips
        ValueListenableBuilder<String?>(
          valueListenable: selectedStatusNotifier,
          builder: (context, status, child) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (status != null && status != "All")
                  Chip(
                    label: Text(status),
                    onDeleted: () {
                      selectedStatusNotifier.value = null;
                      _fetchApi();
                    },
                  ),
              ],
            );
          },
        ),


      ],
    );
  }

  Widget _buildCustomerList(CustomerState state) {
    if (state is CustomerListLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is CustomerSuccess) {
      if (state.list.isEmpty) {
        return Center(child: Lottie.asset(AppImages.noData));
      } else {
        return Column(
          children: [
            SizedBox(
              child: CustomerTableCard(
                customers: state.list,
                onCustomerTap: () {
                  // Handle customer tap if needed
                },
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
              onPageChanged: (page) => _fetchCustomerList(
                pageNumber: page,
                pageSize: state.pageSize,
              ),
              onPageSizeChanged: (newSize) => _fetchCustomerList(
                pageNumber: 1,
                pageSize: newSize,
              ),
            ),
          ],
        );
      }
    } else if (state is CustomerListFailed) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load customers',
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
  }

  void _showCreateCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // maxWidth: Responsive.isMobile(context)
              //     ? AppSizes.width(context)
              //     : AppSizes.width(context) * 0.55,
              // maxHeight: AppSizes.height(context) * 0.8,
            ),
            child: const MobileCreateCustomerScreen(),
          ),
        );
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
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter Customers",
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
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ["All", "Active", "Inactive"].map((status) {
                      final bool isSelected =
                          selectedStatusNotifier.value == status ||
                              (status == "All" && selectedStatusNotifier.value == null);
                      return FilterChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedStatusNotifier.value = selected ? status : null;
                          });
                        },
                        selectedColor: AppColors.primaryColor(context).withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primaryColor(context),
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
                              filterTextController.clear();
                              selectedStatusNotifier.value = null;
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
                              status: selectedStatusNotifier.value?.toLowerCase() ?? '',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor(context),
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
}