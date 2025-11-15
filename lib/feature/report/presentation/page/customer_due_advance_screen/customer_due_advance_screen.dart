// lib/feature/report/presentation/screens/customer_due_advance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';
import 'package:smart_inventory/core/configs/app_colors.dart';
import 'package:smart_inventory/core/configs/app_images.dart';
import 'package:smart_inventory/core/configs/app_text.dart';
import 'package:smart_inventory/core/shared/widgets/sideMenu/sidebar.dart';
import 'package:smart_inventory/core/widgets/app_button.dart';
import 'package:smart_inventory/core/widgets/app_dropdown.dart';
import 'package:smart_inventory/core/widgets/date_range.dart';
import 'package:smart_inventory/feature/customer/data/model/customer_active_model.dart';
import 'package:smart_inventory/feature/customer/presentation/bloc/customer/customer_bloc.dart';
import 'package:smart_inventory/feature/report/presentation/page/customer_due_advance_screen/pdf.dart';

import '../../../../../core/configs/app_routes.dart';
import '../../../../../responsive.dart';
import '../../../data/model/customer_due_advance_report_model.dart';
import '../../bloc/customer_due_advance_bloc/customer_due_advance_bloc.dart';
import '../customer_ledger_screen/pdf.dart';

class CustomerDueAdvanceScreen extends StatefulWidget {
  const CustomerDueAdvanceScreen({super.key});

  @override
  State<CustomerDueAdvanceScreen> createState() => _CustomerDueAdvanceScreenState();
}

class _CustomerDueAdvanceScreenState extends State<CustomerDueAdvanceScreen> {
  DateRange? selectedDateRange;
  CustomerActiveModel? _selectedCustomer;
  String? _selectedStatus;

  final List<String> statusOptions = ['all', 'due', 'advance', 'settled'];
  final Map<String, String> statusLabels = {
    'all': 'All Status',
    'due': 'Due Only',
    'advance': 'Advance Only',
    'settled': 'Settled Only',
  };

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(FetchCustomerActiveList(context));
    _fetchApi();
  }

  void _fetchApi({
    DateTime? from,
    DateTime? to,
    int? customerId,
    String? status,
  }) {
    context.read<CustomerDueAdvanceBloc>().add(FetchCustomerDueAdvanceReport(
      context: context,
      from: from,
      to: to,
      customerId: customerId,
      status: status,
    ));
  }

  void _onCustomerChanged(CustomerActiveModel? newValue) {
    setState(() {
      _selectedCustomer = newValue;
    });
    _fetchApi(
      from: selectedDateRange?.start,
      to: selectedDateRange?.end,
      customerId: newValue?.id,
      status: _selectedStatus,
    );
  }

  void _onStatusChanged(String? newValue) {
    setState(() {
      _selectedStatus = newValue;
    });
    _fetchApi(
      from: selectedDateRange?.start,
      to: selectedDateRange?.end,
      customerId: _selectedCustomer?.id,
      status: newValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen = Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return Container(
      color: AppColors.bg,
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
        onRefresh: () async => _fetchApi(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 6),
              _buildFilterRow(),
              _buildSummaryCards(),              const SizedBox(height: 6),

              SizedBox(child: _buildCustomerTable()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Customer Due & Advance Report",
              style: AppTextStyle.cardTitle(context).copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Monitor customer balances and payment status",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),

      ],
    );
  }

  Widget _buildFilterRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 📅 Date Range Picker
        SizedBox(
          width: 260,
          child: CustomDateRangeField(
            isLabel: false,
            selectedDateRange: selectedDateRange,
            onDateRangeSelected: (value) {
              setState(() => selectedDateRange = value);
              if (value != null) {
                _fetchApi(
                  from: value.start,
                  to: value.end,
                  customerId: _selectedCustomer?.id,
                  status: _selectedStatus,
                );
              }
            },
          ),
        ),
        const SizedBox(width: 12),

        // 👥 Customer Dropdown
        SizedBox(
         width: 220,
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              if (state is CustomerListLoading) {
                return AppDropdown<CustomerActiveModel>(
                  context: context,
                  label: "Customer",
                  hint: "Loading customers...",
                  isNeedAll: true,
                  isRequired: false,
                  isLabel: false,
                  itemList: [],
                  onChanged: (v){},
                  itemBuilder: (item) => const DropdownMenuItem<CustomerActiveModel>(
                    value: null,
                    child: Text('Loading...'),
                  ),
                );
              }

              return AppDropdown<CustomerActiveModel>(
                context: context,
                label: "Customer", isLabel: true,
                hint: "Select Customer",
                isNeedAll: true,
                isRequired: false,
                value: _selectedCustomer,
                itemList: context.read<CustomerBloc>().activeCustomer,
                onChanged: _onCustomerChanged,
                itemBuilder: (item) {
                  final isAllOption = item.id == null;
                  return DropdownMenuItem<CustomerActiveModel>(
                    value: item,
                    child: Text(
                      isAllOption ? 'All Customers' : '${item.name} (${item.phone})',
                      style: TextStyle(
                        color: isAllOption ? AppColors.primaryColor : AppColors.blackColor,
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

        // 📊 Status Dropdown
        SizedBox(
          width: 200,

          child: AppDropdown<String>(
            context: context,
            label: "Status",
            hint: "Select Status",
            isNeedAll: false,
            isRequired: false,
            isLabel: true,
            value: _selectedStatus,
            itemList: statusOptions,
            onChanged: _onStatusChanged,
            itemBuilder: (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                statusLabels[item] ?? item,
                style: const TextStyle(
                  color: AppColors.blackColor,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
AppButton(name: "Clear", onPressed: (){
  setState(() {
    selectedDateRange = null;
    _selectedCustomer = null;
    _selectedStatus = null;
  });
  context.read<CustomerDueAdvanceBloc>().add(ClearCustomerDueAdvanceFilters());
  _fetchApi();
})
        // 🧹 Clear Filters Button

      ],
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<CustomerDueAdvanceBloc, CustomerDueAdvanceState>(
      builder: (context, state) {
        if (state is! CustomerDueAdvanceSuccess) return const SizedBox();

        final summary = state.response.summary;
        final customers = state.response.report;

        // Calculate additional metrics
        final customersWithDue = customers.where((c) => c.presentDue > 0).length;
        final customersWithAdvance = customers.where((c) => c.presentAdvance > 0).length;
        final settledCustomers = customers.where((c) => c.presentDue == 0 && c.presentAdvance == 0).length;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSummaryCard(
              "Total Customers",
              summary.totalCustomers.toString(),
              Icons.people,
              AppColors.primaryColor,
            ),
            _buildSummaryCard(
              "Total Due Amount",
              "\$${summary.totalDueAmount.toStringAsFixed(2)}",
              Icons.money_off,
              Colors.red,
            ),
            _buildSummaryCard(
              "Total Advance Amount",
              "\$${summary.totalAdvanceAmount.toStringAsFixed(2)}",
              Icons.attach_money,
              Colors.green,
            ),
            _buildSummaryCard(
              "Net Balance",
              "\$${summary.netBalance.abs().toStringAsFixed(2)}",
              summary.netBalance >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
              summary.overallStatusColor,
              // subtitle: summary.overallStatus,
            ),
            _buildSummaryCard(
              "Customers with Due",
              customersWithDue.toString(),
              Icons.warning,
              Colors.orange,
            ),
            _buildSummaryCard(
              "Customers with Advance",
              customersWithAdvance.toString(),
              Icons.thumb_up,
              Colors.blue,
            ),
            _buildSummaryCard(
              "Settled Customers",
              settledCustomers.toString(),
              Icons.check_circle,
              Colors.green,
            ),

            AppButton(
                size: 100,
                name: "Pdf", onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    backgroundColor: Colors.red,
                    body: PdfPreview.builder(
                      useActions: true,
                      allowSharing: false,
                      canDebug: false,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      dynamicLayout: true,
                      build: (format) => generateCustomerDueAdvanceReportPdf(
                        state.response,

                      ),
                      pdfPreviewPageDecoration:
                      BoxDecoration(color: AppColors.white),
                      actionBarTheme: PdfActionBarTheme(
                        backgroundColor: AppColors.primaryColor,
                        iconColor: Colors.white,
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () => AppRoutes.pop(context),
                          icon: const Icon(Icons.cancel, color: Colors.red),
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
                              child: Image(image: page.image, fit: BoxFit.contain),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              );

            }),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
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
                    color: color,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerTable() {
    return BlocBuilder<CustomerDueAdvanceBloc, CustomerDueAdvanceState>(
      builder: (context, state) {
        if (state is CustomerDueAdvanceLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading customer due & advance report..."),
              ],
            ),
          );
        } else if (state is CustomerDueAdvanceSuccess) {
          if (state.response.report.isEmpty) {
            return _buildEmptyState();
          }
          return CustomerDueAdvanceTableCard(customers: state.response.report);
        } else if (state is CustomerDueAdvanceFailed) {
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
            "No Customer Due & Advance Data Found",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Customer due and advance data will appear here when available",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchApi,
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
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            "Error Loading Customer Due & Advance Report",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(fontSize: 14, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchApi,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

class CustomerDueAdvanceTableCard extends StatelessWidget {
  final List<CustomerDueAdvance> customers;
  final VoidCallback? onCustomerTap;

  const CustomerDueAdvanceTableCard({
    super.key,
    required this.customers,
    this.onCustomerTap,
  });

  @override
  Widget build(BuildContext context) {
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 9; // #, Customer Name, Phone, Email, Due Amount, Advance Amount, Net Balance, Status, Actions
        const minColumnWidth = 120.0;

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Scrollbar(
            controller: verticalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: verticalScrollController,
              scrollDirection: Axis.vertical,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Scrollbar(
                  controller: horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: totalWidth),
                        child: DataTable(
                          dataRowMinHeight: 40,
                          dataRowMaxHeight: 40,
                          columnSpacing: 8,
                          horizontalMargin: 12,
                          dividerThickness: 0.5,
                          headingRowHeight: 40,
                          headingTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          headingRowColor: MaterialStateProperty.all(
                            AppColors.primaryColor,
                          ),
                          dataTextStyle: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: customers.asMap().entries.map((entry) {
                            final customer = entry.value;
                            return DataRow(
                              onSelectChanged: onCustomerTap != null
                                  ? (_) => onCustomerTap!()
                                  : null,
                              cells: [
                                _buildIndexCell(entry.key + 1, dynamicColumnWidth * 0.6),
                                _buildCustomerNameCell(customer.customerName, dynamicColumnWidth),
                                _buildPhoneCell(customer.phone, dynamicColumnWidth),
                                _buildEmailCell(customer.email, dynamicColumnWidth),
                                _buildDueAmountCell(customer, dynamicColumnWidth),
                                _buildAdvanceAmountCell(customer, dynamicColumnWidth),
                                _buildNetBalanceCell(customer, dynamicColumnWidth),
                                _buildStatusCell(customer, dynamicColumnWidth),
                                _buildActionCell(customer, context, dynamicColumnWidth),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildColumns(double columnWidth) {
    return [
      DataColumn(
        label: SizedBox(
          width: columnWidth * 0.6,
          child: const Text('#', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Customer Name', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Phone', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Email', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Due Amount', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Advance Amount', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Net Balance', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Status', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Actions', textAlign: TextAlign.center),
        ),
      ),
    ];
  }

  DataCell _buildIndexCell(int index, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Text(
            index.toString(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildCustomerNameCell(String customerName, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Tooltip(
          message: customerName,
          child: Text(
            customerName,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ),
    );
  }

  DataCell _buildPhoneCell(String phone, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          phone,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  DataCell _buildEmailCell(String email, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          email,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  DataCell _buildDueAmountCell(CustomerDueAdvance customer, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: customer.presentDue > 0
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '\$${customer.presentDue.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          )
              : const Text(
            '-',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  DataCell _buildAdvanceAmountCell(CustomerDueAdvance customer, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: customer.presentAdvance > 0
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '\$${customer.presentAdvance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          )
              : const Text(
            '-',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  DataCell _buildNetBalanceCell(CustomerDueAdvance customer, double width) {

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: customer.balanceStatusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: customer.balanceStatusColor),
            ),
            child: Text(
              '\$${customer.netBalance.abs().toStringAsFixed(2)}',
              style: TextStyle(
                color: customer.balanceStatusColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildStatusCell(CustomerDueAdvance customer, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: customer.balanceStatusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(customer.balanceStatusIcon, size: 12, color: customer.balanceStatusColor),
                const SizedBox(width: 4),
                Text(
                  customer.balanceStatus,
                  style: TextStyle(
                    color: customer.balanceStatusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildActionCell(CustomerDueAdvance customer, BuildContext context, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // View Details Button
            _buildActionButton(
              icon: HugeIcons.strokeRoundedView,
              color: Colors.blue,
              tooltip: 'View customer details',
              onPressed: () => _showCustomerDetails(context, customer),
            ),

            // Ledger Button
            _buildActionButton(
              icon: Iconsax.book,
              color: Colors.green,
              tooltip: 'View customer ledger',
              onPressed: () => _viewCustomerLedger(context, customer),
            ),

            // Payment Button (if due exists)
            if (customer.presentDue > 0)
              _buildActionButton(
                icon: Iconsax.money_recive,
                color: Colors.orange,
                tooltip: 'Record payment',
                onPressed: () => _recordPayment(context, customer),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 25, minHeight: 25),
    );
  }

  void _showCustomerDetails(BuildContext context, CustomerDueAdvance customer) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.40,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.customerName,
                  style: AppTextStyle.cardLevelHead(context),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Phone:', customer.phone),
                _buildDetailRow('Email:', customer.email),
                _buildDetailRow('Due Amount:', '\$${customer.presentDue.toStringAsFixed(2)}'),
                _buildDetailRow('Advance Amount:', '\$${customer.presentAdvance.toStringAsFixed(2)}'),
                _buildDetailRow('Net Balance:', '\$${customer.netBalance.abs().toStringAsFixed(2)}'),
                _buildDetailRow('Status:', customer.balanceStatus),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewCustomerLedger(BuildContext context, CustomerDueAdvance customer) {
    // Implement navigation to customer ledger
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ledger for ${customer.customerName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _recordPayment(BuildContext context, CustomerDueAdvance customer) {
    // Implement payment recording
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recording payment for ${customer.customerName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}