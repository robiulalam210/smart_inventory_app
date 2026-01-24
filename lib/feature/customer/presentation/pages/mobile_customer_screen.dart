import 'package:meherinMart/core/widgets/app_scaffold.dart';
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
  final ValueNotifier<String?> selectedCustomerTypeNotifier = ValueNotifier(null);
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
    selectedCustomerTypeNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchApi({
    String filterText = '',
    String status = '',
    String customerType = '',
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    if (!mounted) return;

    context.read<CustomerBloc>().add(
      FetchCustomerList(
        context,
        filterText: filterText,
        status: status,
        customerType: customerType,
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
      customerType: selectedCustomerTypeNotifier.value?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor(context),
        onPressed: () => _showCreateCustomerDialog(context),
        child: Icon(Icons.add, color: AppColors.whiteColor(context)),
      ),
      appBar: AppBar(
        title: Text("Customer", style: AppTextStyle.titleMedium(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _showMobileFilterSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildContentArea(),
      ),
    );
  }

  Widget _buildContentArea() {
    return RefreshIndicator(
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
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildMobileHeader(),
                  const SizedBox(height: 16),
                  SizedBox(
                    child: _buildCustomerList(state),
                  ),
                ],
              ),
            );
          },
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
      _fetchApi();
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
    } else if (state is CustomerToggleSpecialSuccess) {
      if (context.mounted) {
        showCustomToast(
          context: context,
          title: 'Success!',
          description: state.message,
          icon: Icons.check_circle,
          primaryColor: Colors.green,
        );
        _fetchApi();
      }
    } else if (state is CustomerToggleSpecialFailed) {
      _fetchApi();
      if (context.mounted) {
        showCustomToast(
          context: context,
          title: 'Error!',
          description: state.message,
          icon: Icons.error,
          primaryColor: Colors.red,
        );
      }
    }
  }

  Widget _buildMobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Bar
        Row(
          children: [
            Expanded(
              child: CustomSearchTextFormField(
                controller: filterTextController,
                onChanged: (value) => _fetchApi(filterText: value),
                onClear: () {
                  filterTextController.clear();
                  selectedStatusNotifier.value = null;
                  selectedCustomerTypeNotifier.value = null;
                  _fetchApi();
                  FocusScope.of(context).unfocus();
                },
                isRequiredLabel: false,
                hintText: "Search customers...",
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                filterTextController.clear();
                selectedStatusNotifier.value = null;
                selectedCustomerTypeNotifier.value = null;
                _fetchApi();
              },
              tooltip: "Refresh",
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Active Filter Chips
        ValueListenableBuilder<String?>(
          valueListenable: selectedStatusNotifier,
          builder: (context, status, child) {
            return ValueListenableBuilder<String?>(
              valueListenable: selectedCustomerTypeNotifier,
              builder: (context, customerType, child) {
                final List<String> activeFilters = [];

                if (status != null && status != "All") {
                  activeFilters.add("Status: $status");
                }

                if (customerType != null && customerType != "All") {
                  activeFilters.add("Type: $customerType");
                }

                if (activeFilters.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ...activeFilters.map((filter) => Chip(
                      label: Text(filter),
                      onDeleted: () {
                        if (filter.startsWith("Status:")) {
                          selectedStatusNotifier.value = null;
                        } else if (filter.startsWith("Type:")) {
                          selectedCustomerTypeNotifier.value = null;
                        }
                        _fetchApi();
                      },
                    )).toList(),
                  ],
                );
              },
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
            CustomerTableCard(
              customers: state.list,
              onCustomerTap: (v) {
                print(v);
                _showCustomerOptions(context, v);
              },
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.95,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: const MobileCreateCustomerScreen(),
            ),
          ),
        );
      },
    );
  }

  void _showCustomerOptions(BuildContext context, Map<String, dynamic> customer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Customer Info Header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bottomNavBg(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          customer['special_customer'] == true
                              ? Icons.star
                              : Icons.person,
                          color: customer['special_customer'] == true
                              ? Colors.amber
                              : AppColors.primaryColor(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer['name'] ?? '',
                              style: AppTextStyle.bodyLarge(context).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              customer['phone'] ?? '',
                              style: AppTextStyle.body(context),
                            ),
                          ],
                        ),
                      ),
                      if (customer['special_customer'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                "Special",
                                style: AppTextStyle.body(context).copyWith(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Options
                _buildOptionItem(
                  icon: Icons.edit,
                  title: "Edit Customer",
                  onTap: () {
                    Navigator.pop(context);
                    _showEditCustomerDialog(context, customer);
                  },
                ),
                _buildOptionItem(
                  icon: customer['special_customer'] == true
                      ? Icons.star_border
                      : Icons.star,
                  title: customer['special_customer'] == true
                      ? "Remove from Special"
                      : "Mark as Special",
                  onTap: () {
                    Navigator.pop(context);
                    _toggleSpecialCustomer(customer);
                  },
                ),
                _buildOptionItem(
                  icon: Icons.delete,
                  title: "Delete Customer",
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, customer);
                  },
                ),
                const SizedBox(height: 8),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: AppTextStyle.body(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primaryColor(context)),
      title: Text(
        title,
        style: AppTextStyle.bodyLarge(context).copyWith(
          color: color ?? AppColors.text(context),
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showEditCustomerDialog(BuildContext context, Map<String, dynamic> customer) {
    // Pre-fill the form with customer data
    final customerBloc = context.read<CustomerBloc>();
    customerBloc.customerNameController.text = customer['name'] ?? '';
    customerBloc.customerNumberController.text = customer['phone'] ?? '';
    customerBloc.customerEmailController.text = customer['email'] ?? '';
    customerBloc.addressController.text = customer['address'] ?? '';
    customerBloc.selectedState = customer['is_active'] == true ? "Active" : "Inactive";

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.95,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: MobileCreateCustomerScreen(
                id: customer['id'].toString(),
                submitText: "Update",
                customer: customer,
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleSpecialCustomer(Map<String, dynamic> customer) {
    final customerBloc = context.read<CustomerBloc>();
    final action = customer['special_customer'] == true ? 'set_false' : 'set_true';

    customerBloc.add(ToggleSpecialCustomer(
      context: context,
      customerId: customer['id'].toString(),
      action: action,
    ));
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Delete Customer",
            style: AppTextStyle.titleMedium(context),
          ),
          content: Text(
            "Are you sure you want to delete ${customer['name']}?",
            style: AppTextStyle.bodyLarge(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: AppTextStyle.body(context).copyWith(
                  color: AppColors.text(context),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<CustomerBloc>().add(
                  DeleteCustomer(
                    customer['id'].toString(),

                  ),
                );
              },
              child: Text(
                "Delete",
                style: AppTextStyle.body(context).copyWith(
                  color: Colors.red,
                ),
              ),
            ),
          ],
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
            return SafeArea(
              child: Container(
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
                          "Filter Customers",
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
                      style: TextStyle(
                        color: AppColors.text(context),
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
                          selectedColor: AppColors.primaryColor(context).withOpacity(0.2),
                          checkmarkColor: AppColors.primaryColor(context),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Customer Type Filter
                    Text(
                      "Customer Type",
                      style: TextStyle(
                        color: AppColors.text(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ["All", "Special", "Regular"].map((type) {
                        final bool isSelected =
                            selectedCustomerTypeNotifier.value == type ||
                                (type == "All" && selectedCustomerTypeNotifier.value == null);
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedCustomerTypeNotifier.value = selected ? type : null;
                            });
                          },
                          selectedColor: type == "Special"
                              ? Colors.amber.withOpacity(0.2)
                              : AppColors.primaryColor(context).withOpacity(0.2),
                          checkmarkColor: type == "Special"
                              ? Colors.amber
                              : AppColors.primaryColor(context),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                filterTextController.clear();
                                selectedStatusNotifier.value = null;
                                selectedCustomerTypeNotifier.value = null;
                              });
                              Navigator.pop(context);
                              _fetchApi();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Clear All",
                              style: AppTextStyle.body(context).copyWith(
                                color: AppColors.error,
                              ),
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
                                status: selectedStatusNotifier.value?.toLowerCase() ?? '',
                                customerType: selectedCustomerTypeNotifier.value?.toLowerCase() ?? '',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor(context),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Apply Filters",
                              style: AppTextStyle.body(context).copyWith(
                                color: AppColors.whiteColor(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
}