import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../core/widgets/app_alert_dialog.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../core/widgets/date_range.dart';
import '../../../../core/widgets/show_custom_toast.dart';
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
  // Use the correct type that CustomDateRangeField expects
  DateRange? selectedDateRange;

  final TextEditingController _searchController = TextEditingController();
  final int _defaultPageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchApi(
        from: selectedDateRange?.start,
        to: selectedDateRange?.end
    );
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
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    context.read<SupplierPaymentBloc>().add(
      FetchSupplierPaymentList(
        context: context,
        filterText: filterText,
        startDate: from,
        endDate: to,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  void _fetchSupplierList({int pageNumber = 1, int? pageSize}) {
    _fetchApi(
      filterText: _searchController.text,
      from: selectedDateRange?.start,
      to: selectedDateRange?.end,
      pageNumber: pageNumber,
      pageSize: pageSize ?? _defaultPageSize,
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
            _buildSupplierPaymentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          if (Responsive.isDesktop(context))
          // Desktop layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 400,
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
                SizedBox(
                  width: 260,
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
            )
          else
          // Mobile layout
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Bar
                CustomSearchTextFormField(
                  isRequiredLabel: false,
                  controller: _searchController,
                  onClear: () {
                    _searchController.clear();
                    _fetchApi();
                  },
                  onChanged: (value) {
                    _fetchApi(filterText: value);
                  },
                  hintText: "Search payments...",
                ),
                const SizedBox(height: 12),

                // Date Range and Create Button Row
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        // height: 50,
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
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 100,
                      child: AppButton(
                        name: "Create",
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                insetPadding: const EdgeInsets.all(16),
                                child: Container(
                                  width: double.infinity,
                                  height: AppSizes.height(context) * 0.8,
                                  child: const SupplierPaymentForm(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
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
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            _fetchApi();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment created successfully')),
            );
          } else if (state is SupplierPaymentAddFailed) {
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
          } else if (state is SupplierPaymentDeleteSuccess) {
            _fetchApi();
            showCustomToast(
              context: context,
              title: 'Alert!',
              description:
              'Payment deleted successfully',
              icon: Icons.error,
              primaryColor: Colors.redAccent,
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
      count: state.count,
      totalPages: state.totalPages,
      currentPage: state.currentPage,
      pageSize: state.pageSize,
      from: state.from,
      to: state.to,
      onPageChanged: (page) => _fetchSupplierList(pageNumber: page),
      onPageSizeChanged: (newPageSize) {
        _fetchSupplierList(pageNumber: 1, pageSize: newPageSize);
      },
    );
  }
}