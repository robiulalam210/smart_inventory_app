import 'package:meherinMart/desktop/widgets/sidebar.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import '../../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '/core/core.dart';

import '../../../../../core/widgets/date_range.dart';
import '../../../../customer/data/model/customer_active_model.dart';
import '../../../../customer/presentation/bloc/customer/customer_bloc.dart';
import '../../../../users_list/data/model/user_model.dart';
import '../../../../users_list/presentation/bloc/users/user_bloc.dart';
import '../../../data/model/sales_report_model.dart';
import '../../bloc/sales_report_bloc/sales_report_bloc.dart';
import '../../shared/sales_report_page/pdf/sales_report.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

class SaleReportScreen extends StatefulWidget {
  const SaleReportScreen({super.key});

  @override
  State<SaleReportScreen> createState() => _SaleReportScreenState();
}

class _SaleReportScreenState extends State<SaleReportScreen> {
  TextEditingController filterTextController = TextEditingController();
  DateRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    filterTextController.clear();

    // Load dropdown data
    context.read<UserBloc>().add(
      FetchUserList(context, dropdownFilter: "?status=1"),
    );
    context.read<CustomerBloc>().add(FetchCustomerActiveList(context));

    // Fetch initial sales report
    _fetchSalesReport();
  }

  void _fetchSalesReport({
    String customer = '',
    String seller = '',
    DateTime? from,
    DateTime? to,
  }) {
    context.read<SalesReportBloc>().add(
      FetchSalesReport(
        context: context,
        customer: customer,
        seller: seller,
        from: from,
        to: to,
      ),
    );
  }

  @override
  void dispose() {
    filterTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return Container(
      color: AppColors.bottomNavBg(context),
      child: SafeArea(
        child: ResponsiveRow(
          children: [
            if (isBigScreen) _buildSidebar(),
            _buildContentArea(isBigScreen),
          ],
        ),
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
        onRefresh: () async => _fetchSalesReport(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterRow(),
              const SizedBox(height: 8),

              _buildSummaryCards(),
              const SizedBox(height: 8),
              SizedBox(child: _buildDataTable()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 👤 Customer Dropdown
        SizedBox(
          width: 220,

          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              return AppDropdown<CustomerActiveModel>(
                label: "Customer",
                isSearch: true,
                isLabel: false,
                hint: "Select Customer",
                isNeedAll: true,
                isRequired: false,
                value: context.read<SalesReportBloc>().selectedCustomer,
                itemList: context.read<CustomerBloc>().activeCustomer,
                onChanged: (newVal) {
                  _fetchSalesReport(
                    from: selectedDateRange?.start,
                    to: selectedDateRange?.end,
                    customer: newVal?.id.toString() ?? '',
                    seller:
                        context
                            .read<SalesReportBloc>()
                            .selectedSeller
                            ?.id
                            .toString() ??
                        '',
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(width: 6),

        // 🧑‍💼 Seller Dropdown
        SizedBox(
          width: 200,
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              return AppDropdown<UsersListModel>(
                label: "Seller",
                hint: "Select Seller",
                isLabel: false,
                isRequired: false,
                isNeedAll: true,
                value: context.read<SalesReportBloc>().selectedSeller,
                itemList: context.read<UserBloc>().list,
                onChanged: (newVal) {
                  _fetchSalesReport(
                    from: selectedDateRange?.start,
                    to: selectedDateRange?.end,
                    customer:
                        context
                            .read<SalesReportBloc>()
                            .selectedCustomer
                            ?.id
                            .toString() ??
                        '',
                    seller: newVal?.id.toString() ?? '',
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(width: 6),

        // 📅 Date Range Picker
        SizedBox(
          width: 260,
          child: CustomDateRangeField(
            isLabel: false,
            selectedDateRange: selectedDateRange,
            onDateRangeSelected: (value) {
              setState(() => selectedDateRange = value);
              if (value != null) {
                _fetchSalesReport(
                  from: value.start,
                  to: value.end,
                  customer:
                      context
                          .read<SalesReportBloc>()
                          .selectedCustomer
                          ?.id
                          .toString() ??
                      '',
                  seller:
                      context
                          .read<SalesReportBloc>()
                          .selectedSeller
                          ?.id
                          .toString() ??
                      '',
                );
              }
            },
          ),
        ),
        const SizedBox(width: 6),

        AppButton(
          name: "Clear",
          onPressed: () {
            setState(() => selectedDateRange = null);
            context.read<SalesReportBloc>().add(ClearSalesReportFilters());
            _fetchSalesReport();
          },
        ),
gapW8,
        BlocBuilder<SalesReportBloc, SalesReportState>(
          builder: (context, state) {
            if (state is! SalesReportSuccess) return const SizedBox();


            return   AppButton(
              size: 100,
              isOutlined: true,
              textColor: AppColors.errorColor(context),
              name: "Pdf",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      backgroundColor: AppColors.danger,
                      body: PdfPreview.builder(
                        useActions: true,
                        allowSharing: false,
                        canDebug: false,
                        canChangeOrientation: false,
                        canChangePageFormat: false,
                        dynamicLayout: true,
                        build: (format) =>
                            generateSalesReportPdf(state.response, context.read<ProfileBloc>().permissionModel?.data?.companyInfo),
                        pdfPreviewPageDecoration: BoxDecoration(
                          color: AppColors.white,
                        ),
                        actionBarTheme: PdfActionBarTheme(
                          backgroundColor: AppColors.primaryColor(context),
                          iconColor: Colors.white,
                          textStyle: const TextStyle(color: Colors.white),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () => AppRoutes.pop(context),
                            icon: const Icon(
                              Icons.cancel,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                        pagesBuilder: (context, pages) {
                          debugPrint('Rendering ${pages.length} pages');
                          return PageView.builder(
                            itemCount: pages.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              final page = pages[index];
                              return Container(
                                color: Colors.grey,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8.0),
                                child: Image(
                                  image: page.image,
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),

        // Clear Filters Button
      ],
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<SalesReportBloc, SalesReportState>(
      builder: (context, state) {
        if (state is! SalesReportSuccess) return const SizedBox();

        final summary = state.response.summary;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSummaryCard(
              "Total Sales",
              summary.totalSales.toStringAsFixed(2),
              Icons.shopping_cart,
              AppColors.primaryColor(context),
            ),
            _buildSummaryCard(
              "Total Profit",
              summary.totalProfit.toStringAsFixed(2),
              Icons.trending_up,
              AppColors.success,
            ),
            _buildSummaryCard(
              "Total Collected",
              summary.totalCollected.toStringAsFixed(2),
              Icons.payment,
              AppColors.info,
            ),
            _buildSummaryCard(
              "Total Due",
              summary.totalDue.toStringAsFixed(2),
              Icons.money_off,
              AppColors.warning,
            ),
            _buildSummaryCard(
              "Transactions",
              summary.totalTransactions.toString(),
              Icons.receipt,
              Colors.purple,
            ),


          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.greyColor(context).withValues(alpha: 0.5),width: 0.5
        ),
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(8),
    
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return BlocBuilder<SalesReportBloc, SalesReportState>(
      builder: (context, state) {
        if (state is SalesReportLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading sales report..."),
              ],
            ),
          );
        } else if (state is SalesReportSuccess) {
          if (state.response.report.isEmpty) {
            return _buildEmptyState();
          }
          return SalesReportTableCard(reports: state.response.report);
        } else if (state is SalesReportFailed) {
          return _buildErrorState(state.content);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AppImages.noData, width: 200, height: 200),
          const SizedBox(height: 16),
          Text(
            "No Sales Report Data Found",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Sales report data will appear here when available",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchSalesReport,
            child: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(
            "Error Loading Sales Report",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(fontSize: 14, color: AppColors.danger),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchSalesReport,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

class SalesReportTableCard extends StatelessWidget {
  final List<SalesReportModel> reports;
  final VoidCallback? onReportTap;

  const SalesReportTableCard({
    super.key,
    required this.reports,
    this.onReportTap,
  });

  @override
  // Desktop টেবিল — AppDataTable
  Widget build(BuildContext context) {
    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 52),
      AppTableColumn('Invoice No', flex: 2, minWidth: 120),
      AppTableColumn('Date', flex: 2, minWidth: 100),
      AppTableColumn('Customer', flex: 3, minWidth: 160),
      AppTableColumn.numeric('Sales Price', flex: 2, minWidth: 120),
      AppTableColumn.numeric('Profit', flex: 2, minWidth: 110),
      AppTableColumn.center('Status', flex: 2, minWidth: 104),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: reports.length,
      onRowTap: onReportTap == null ? null : (_) => onReportTap!(),
      cellBuilder: (context, row, col) {
        final r = reports[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(r.invoiceNo,
                bold: true, color: AppColors.primaryColor(context));
          case 2:
            return AppTableText(_formatDate(r.saleDate));
          case 3:
            return AppTableText(r.customerName);
          case 4:
            return AppTableMoney(r.salesPrice, bold: true);
          case 5:
            return AppTableMoney(r.profit, bold: true, signColor: true);
          default:
            return AppStatusPill(r.paymentStatus.capitalize(),
                color: _getStatusColor(r.paymentStatus));
        }
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'due':
      case 'overdue':
        return AppColors.danger;
      case 'partial':
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
