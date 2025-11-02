import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/configs/app_colors.dart';
import '../../../../core/configs/app_images.dart';
import '../../../../core/configs/app_sizes.dart';
import '../../../../core/configs/app_text.dart';
import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/custom_filter_ui.dart';
import '../../../../responsive.dart';
import '../../../products/product/presentation/widget/pagination.dart';
import '../bloc/supplier_payment/supplier_payment_bloc.dart';
import '../widget/supplier_payment_widget.dart';
import 'supplier_payment_create.dart';

class SupplierPaymentScreen extends StatefulWidget {
  const SupplierPaymentScreen({super.key});

  @override
  State<SupplierPaymentScreen> createState() => _SupplierPaymentScreenState();
}

class _SupplierPaymentScreenState extends State<SupplierPaymentScreen> {
  ValueNotifier<DateTimeRange?> dateRange = ValueNotifier<DateTimeRange?>(
    DateTimeRange(
      start: DateTime(DateTime.now().year, DateTime.now().month - 1, 1),
      end: DateTime.now(),
    ),
  );

  ValueNotifier<String> selectedQuickOptionNotifier = ValueNotifier<String>("");
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchApi(from: dateRange.value?.start, to: dateRange.value?.end);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchApi({
    String filterText = '',
    DateTime? from,
    DateTime? to,
    int pageNumber = 0,
  }) {
    context.read<SupplierPaymentBloc>().add(
      FetchSupplierPaymentList(
        context: context,
        filterText: filterText,
        startDate: from,
        endDate: to,
        pageNumber: pageNumber,
      ),
    );
  }

  void _fetchSupplierList({int pageNumber = 0, int? pageSize}) {
    _fetchApi(
      filterText: _searchController.text,
      from: dateRange.value?.start,
      to: dateRange.value?.end,
      pageNumber: pageNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen = Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

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
        child: Column(
          children: [
            _buildFilterSection(),
            const SizedBox(height: 16),
            _buildSupplierPaymentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomSearchTextFormField(
                  isRequiredLabel: false,
                  controller: _searchController,
                  onClear: () {
                    _searchController.clear();
                    _fetchApi();
                  },
                  onChanged: (value) {
                    _fetchApi(filterText: value);
                  },
                  hintText: "Search by supplier name or phone",
                ),
              ),
              const SizedBox(width: 16),
              // Date Filter - You can add this back if needed
              // Expanded(
              //   child: CustomFilterUI(
              //     dateRange: dateRange,
              //     selectedQuickOptionNotifier: selectedQuickOptionNotifier,
              //     onDateRangeSelected: (range) {
              //       dateRange.value = range;
              //       if (range != null) {
              //         _fetchApi(from: range.start, to: range.end);
              //       }
              //     },
              //   ),
              // ),
              const SizedBox(width: 16),
              AppButton(
                name: "Create Payment",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: SizedBox(
                          width: AppSizes.width(context) * 0.50,
                          child: const SupplierPaymentForm(),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierPaymentList() {
    return SizedBox(
      child: BlocConsumer<SupplierPaymentBloc, SupplierPaymentState>(
        listener: (context, state) {
          if (state is SupplierPaymentAddLoading) {
            appLoader(context, "Creating payment, please wait...");
          } else if (state is SupplierPaymentAddSuccess) {
            Navigator.pop(context); // Close loader dialog
            _fetchApi(); // Reload payment list
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment created successfully')),
            );
          } else if (state is SupplierPaymentAddFailed) {
            Navigator.pop(context); // Close loader dialog
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
          } else if (state is SupplierPaymentDeleteSuccess) {
            _fetchApi(); // Reload payment list
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment deleted successfully')),
            );
          } else if (state is SupplierPaymentDeleteFailed) {
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
        builder: (context, state) {
          if (state is SupplierPaymentListLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is SupplierPaymentListSuccess) {
            if (state.list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      AppImages.noData,
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No payment records found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      name: "Refresh",
                      onPressed: () => _fetchApi(),
                    ),
                  ],
                ),
              );
            } else {
              return Column(
                children: [
                  SizedBox(
                    child: SupplierPaymentWidget(suppliers: state.list),
                  ),
                  const SizedBox(height: 16),
                  _buildPagination(state),
                ],
              );
            }
          } else if (state is SupplierPaymentListFailed) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load payments: ${state.content}',
                    style: const TextStyle(fontSize: 16),
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
            return Center(
              child: Lottie.asset(AppImages.noData),
            );
          }
        },
      ),
    );
  }

  Widget _buildPagination(SupplierPaymentListSuccess state) {
    return PaginationBar(
      count: state.list.length, // Use list length as count
      totalPages: state.totalPages,
      currentPage: state.currentPage,
      pageSize: 30, // Use your _itemsPerPage value
      from: (state.currentPage * 30) + 1, // Calculate from
      to: ((state.currentPage + 1) * 30) > state.list.length
          ? state.list.length
          : ((state.currentPage + 1) * 30), // Calculate to
      onPageChanged: (page) => _fetchSupplierList(pageNumber: page),
      onPageSizeChanged: (newSize) {
        // Handle page size change if needed
        _fetchSupplierList();
      },
    );
  }
}

// Add missing gap widget if not defined elsewhere
const Widget gapW16 = SizedBox(width: 16);