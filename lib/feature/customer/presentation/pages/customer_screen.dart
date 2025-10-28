import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/custom_filter_ui.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../bloc/customer/customer_bloc.dart';
import '../widget/widget.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  TextEditingController filterTextController = TextEditingController();
  ValueNotifier<String?> selectedStatusNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    filterTextController.clear();
    _fetchApi();
  }

  void _fetchApi({
    String filterText = '',
    String status = '',
    int pageNumber = 1,
    int pageSize = 10,
  }) {
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
          child: BlocListener<CustomerBloc, CustomerState>(
            listener: (context, state) {
              if (state is CustomerAddLoading) {
                appLoader(context, "Creating Customer, please wait...");
              } else if (state is CustomerSwitchLoading) {
                appLoader(context, "Update Customer, please wait...");
              } else if (state is CustomerDeleteLoading) {
                appLoader(context, "Delete Customer, please wait...");
              } else if (state is CustomerSwitchSuccess) {
                Navigator.pop(context);
                _fetchApi();
              } else if (state is CustomerDeleteSuccess) {
                Navigator.pop(context);
                _fetchApi();
              } else if (state is CustomerAddSuccess) {
                Navigator.pop(context);
                Navigator.pop(context);
                _fetchApi();
              } else if (state is CustomerSwitchFailed) {
                Navigator.pop(context);
                _fetchApi();
                appAlertDialog(context, state.content,
                    title: state.title,
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Dismiss"))
                    ]);
              } else if (state is CustomerAddFailed) {
                Navigator.pop(context);
                Navigator.pop(context);
                _fetchApi();
                appAlertDialog(context, state.content,
                    title: state.title,
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Dismiss"))
                    ]);
              }
            },
            child: Column(
              children: [
                _buildFilterRow(),
                SizedBox(
                  child: BlocBuilder<CustomerBloc, CustomerState>(
                    builder: (context, state) {
                      if (state is CustomerListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is CustomerSuccess) {
                        if (state.list.isEmpty) {
                          return Center(
                            child: Lottie.asset(AppImages.noData),
                          );
                        } else {
                          return Column(
                            children: [
                              SizedBox(
                                child:  CustomerTableCard(customers: state.list,

                                ),
                              ),
                              PaginationBar(
                                count: state.count,
                                totalPages: state.totalPages,
                                currentPage: state.currentPage,
                                pageSize: state.pageSize,
                                from: state.from,
                                to: state.to,
                                onPageChanged: (page) =>
                                    _fetchCustomerList(pageNumber: page, pageSize: state.pageSize),
                                onPageSizeChanged: (newSize) =>
                                    _fetchCustomerList(pageNumber: 1, pageSize: newSize),
                              ),
                            ],
                          );
                        }
                      } else if (state is CustomerListFailed) {
                        return Center(
                          child: Text('Failed to load customer: ${state.content}'),
                        );
                      } else {
                        return Center(
                          child: Lottie.asset(AppImages.noData),
                        );
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
            hintText: "Customer Name, Phone, or Email",
          ),
        ),
        const SizedBox(width: 10),

        // 📊 Status Dropdown
        Expanded(
          child: AppDropdown<String>(
            context: context,
            isLabel: false,
            hint: "Select Status",
            isNeedAll: true,
            isRequired: false,
            value: selectedStatusNotifier.value,
            itemList: ['Active', 'Inactive', 'Blocked'],
            onChanged: (newVal) {
              selectedStatusNotifier.value = newVal;
              _fetchApi(
                status: newVal?.toLowerCase() ?? '',
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
            ), label: '',
          ),
        ),
        const SizedBox(width: 10),

        // 🔄 Refresh Button
        IconButton(
          onPressed: () => _fetchApi(),
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
        ),
      ],
    );
  }
}