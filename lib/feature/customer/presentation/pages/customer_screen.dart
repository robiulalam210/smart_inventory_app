
import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../bloc/customer/customer_bloc.dart';
import '../widget/widget.dart';
import 'create_customer_screen.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
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
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
    return Container(
      color: AppColors.bottomNavBg(context),
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
              return Column(
                children: [
                    _buildDesktopHeader(),

                  SizedBox(
                    child: _buildCustomerList(state),
                  ),
                ],
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

  Widget _buildDesktopHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 🔍 Search Field
        Expanded(
          child: CustomSearchTextFormField(
            controller: filterTextController,
            onChanged: (value) => _fetchApi(filterText: value),
            onClear: () {
              filterTextController.clear();
              selectedStatusNotifier.value = null;
              _fetchApi();
            },
            isRequiredLabel: false,
            hintText: "Customer Name, Phone, or Email",
          ),
        ),
        const SizedBox(width: 10),

        // 📊 Status Dropdown
        Expanded(
          child: ValueListenableBuilder<String?>(
            valueListenable: selectedStatusNotifier,
            builder: (context, value, child) {
              return AppDropdown<String>(
                isLabel: true,
                hint: "Select Status",
                label: "Status",
                isNeedAll: true,
                isRequired: false,
                value: value,
                itemList: ['Active', 'Inactive'],
                onChanged: (newVal) {
                  selectedStatusNotifier.value = newVal;
                  _fetchApi(status: newVal?.toLowerCase() ?? '');
                },
                validator: (value) => null,

              );
            },
          ),
        ),
        gapW16,
        AppButton(
          name: "Create Customer",
          onPressed: () => _showCreateCustomerDialog(context),
        ),
        gapW16,

        // 🔄 Refresh Button
        IconButton(
          onPressed: () => _fetchApi(),
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
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
              maxWidth: Responsive.isMobile(context)
                  ? AppSizes.width(context)
                  : AppSizes.width(context) * 0.55,
              maxHeight: AppSizes.height(context) * 0.8,
            ),
            child: const CreateCustomerScreen(),
          ),
        );
      },
    );
  }

}