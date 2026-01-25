import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:meherinMart/core/configs/app_text.dart';
import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:printing/printing.dart';
import '../../../../../core/configs/app_sizes.dart';
import '../../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '/core/configs/app_colors.dart';
import '/core/configs/app_images.dart';
import '/core/widgets/app_dropdown.dart';
import '/core/widgets/date_range.dart';
import '/feature/customer/data/model/customer_active_model.dart';
import '/feature/customer/presentation/bloc/customer/customer_bloc.dart';
import '/feature/report/presentation/page/customer_due_advance_screen/pdf.dart';

import '../../../data/model/customer_due_advance_report_model.dart';
import '../../bloc/customer_due_advance_bloc/customer_due_advance_bloc.dart';

class MobileCustomerDueAdvanceScreen extends StatefulWidget {
  const MobileCustomerDueAdvanceScreen({super.key});

  @override
  State<MobileCustomerDueAdvanceScreen> createState() =>
      _MobileCustomerDueAdvanceScreenState();
}

class _MobileCustomerDueAdvanceScreenState
    extends State<MobileCustomerDueAdvanceScreen> {
  DateRange? selectedDateRange;
  CustomerActiveModel? _selectedCustomer;
  String? _selectedStatus;
  bool _isFilterExpanded = false;

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
    context.read<CustomerDueAdvanceBloc>().add(
      FetchCustomerDueAdvanceReport(
        context: context,
        from: from,
        to: to,
        customerId: customerId,
        status: status,
      ),
    );
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

  String _formatCurrencySigned(double value) {
    final absVal = value.abs().toStringAsFixed(2);
    return value >= 0 ? '\$$absVal' : '-\$$absVal';
  }

  String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Customer Due & Advance',
          style: AppTextStyle.titleMedium(context),
        ),
        actions: [
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedPdf02, color: AppColors.text(context)),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedReload, color: AppColors.text(context)),
            onPressed: () {
              setState(() {
                selectedDateRange = null;
                _selectedCustomer = null;
                _selectedStatus = null;
                _isFilterExpanded = false;
              });
              context.read<CustomerDueAdvanceBloc>().add(
                ClearCustomerDueAdvanceFilters(),
              );
              _fetchApi();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchApi(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter Section
              _buildMobileFilterSection(),
              const SizedBox(height: 8),

              // Summary Cards
              _buildSummaryCards(),

              // Customer List
              _buildCustomerList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor(context),
        onPressed: () {
          setState(() => _isFilterExpanded = !_isFilterExpanded);
        },
        tooltip: 'Toggle Filters',
        child: Icon(
          _isFilterExpanded ? HugeIcons.strokeRoundedFilterRemove:HugeIcons.strokeRoundedFilter,
          color: AppColors.whiteColor(context),
        ),
      ),
    );
  }

  Widget _buildMobileFilterSection() {
    return Card(
      elevation: 0,
      color: AppColors.bottomNavBg(context),
      child: Column(
        children: [
          // --- Header with clickable icon ---
          InkWell(
            onTap: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(HugeIcons.strokeRoundedFilter),
                  const SizedBox(width: 8),
                  const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Icon(
                    _isFilterExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),

          // --- Expandable body ---
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Date Range Picker
                  CustomDateRangeField(
                    isLabel: true,
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
                  const SizedBox(height: 12),

                  // Customer Dropdown
                  BlocBuilder<CustomerBloc, CustomerState>(
                    builder: (context, state) {
                      return AppDropdown<CustomerActiveModel>(
                        label: "Customer",
                        hint: 'Select Customer',
                        isNeedAll: true,
                        value: _selectedCustomer,
                        itemList: context.read<CustomerBloc>().activeCustomer,
                        onChanged: _onCustomerChanged,
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Status Dropdown
                  AppDropdown<String>(
                    label: "Status",
                    hint: "Select Status",
                    isNeedAll: false,
                    isRequired: false,
                    isLabel: true,
                    value: _selectedStatus,
                    itemList: statusOptions,
                    onChanged: _onStatusChanged,
                  ),

                  // TODO: Add action buttons here
                ],
              ),
            ),
            crossFadeState: _isFilterExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<CustomerDueAdvanceBloc, CustomerDueAdvanceState>(
      builder: (context, state) {
        if (state is! CustomerDueAdvanceSuccess) return const SizedBox();

        final summary = state.response.summary;
        final customers = state.response.report;

        // Calculate additional metrics
        final customersWithDue = customers
            .where((c) => c.presentDue > 0)
            .length;
        final customersWithAdvance = customers
            .where((c) => c.presentAdvance > 0)
            .length;
        final _ = customers
            .where((c) => c.presentDue == 0 && c.presentAdvance == 0)
            .length;

        return Column(
          children: [
            // First row
            Row(
              children: [
                _buildMobileSummaryCard(
                  "Total Customers",
                  summary.totalCustomers.toString(),
                  Icons.people,
                  AppColors.primaryColor(context),
                ),
                const SizedBox(width: 8),
                _buildMobileSummaryCard(
                  "Net Balance",
                  _formatCurrencySigned(summary.netBalance),
                  summary.netBalance >= 0
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  summary.overallStatusColor,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Second row
            Row(
              children: [
                _buildMobileSummaryCard(
                  "Total Due",
                  _formatCurrency(summary.totalDueAmount),
                  Icons.money_off,
                  Colors.red,
                ),
                const SizedBox(width: 8),
                _buildMobileSummaryCard(
                  "Total Advance",
                  _formatCurrency(summary.totalAdvanceAmount),
                  Icons.attach_money,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Third row (counts)
            Row(
              children: [
                if (customersWithDue > 0)
                  Expanded(
                    child: _buildMobileSummaryCard(
                      "With Due",
                      customersWithDue.toString(),
                      Icons.warning,
                      Colors.orange,
                    ),
                  ),
                if (customersWithDue > 0) const SizedBox(width: 8),
                if (customersWithAdvance > 0)
                  Expanded(
                    child: _buildMobileSummaryCard(
                      "With Advance",
                      customersWithAdvance.toString(),
                      Icons.thumb_up,
                      Colors.blue,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bottomNavBg(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.greyColor(context).withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.text(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerList() {
    return BlocBuilder<CustomerDueAdvanceBloc, CustomerDueAdvanceState>(
      builder: (context, state) {
        if (state is CustomerDueAdvanceLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading customer data..."),
              ],
            ),
          );
        } else if (state is CustomerDueAdvanceSuccess) {
          if (state.response.report.isEmpty) {
            return _buildEmptyState();
          }
          return _buildMobileCustomerList(state.response.report);
        } else if (state is CustomerDueAdvanceFailed) {
          return _buildErrorState(state.content);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildMobileCustomerList(List<CustomerDueAdvance> customers) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        final hasDue = customer.presentDue > 0;
        final hasAdvance = customer.presentAdvance > 0;
        final netBalanceText = customer.netBalance >= 0
            ? '\$${customer.netBalance.toStringAsFixed(2)}'
            : '-\$${customer.netBalance.abs().toStringAsFixed(2)}';

        return Container(
          decoration: BoxDecoration(
            color: AppColors.bottomNavBg(context),
            border: Border.all(
              color: AppColors.greyColor(context).withValues(alpha: 0.5),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: customer.balanceStatusColor.withValues(
                          alpha: 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        customer.balanceStatusIcon,
                        color: customer.balanceStatusColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.customerName,
                            style: AppTextStyle.body(context),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (customer.phone.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    customer.phone,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              if (customer.phone.isNotEmpty &&
                                  customer.email.isNotEmpty)
                                const SizedBox(width: 4),
                              if (customer.email.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    customer.email,
                                    style: AppTextStyle.bodySmall(context),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Amount Cards
                Row(
                  children: [
                    if (hasDue)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'DUE',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                ),
                              ),
                              Text(
                                customer.presentDue.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (hasDue) const SizedBox(width: 4),
                    if (hasAdvance)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'ADVANCE',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                customer.presentAdvance.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // Net Balance
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: customer.balanceStatusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: customer.balanceStatusColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NET BALANCE',
                        style: TextStyle(
                          fontSize: 12,
                          color: customer.balanceStatusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        netBalanceText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: customer.balanceStatusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Status Badge

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: customer.balanceStatusColor.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            customer.balanceStatusIcon,
                            size: 14,
                            color: customer.balanceStatusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            customer.balanceStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: customer.balanceStatusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppButton(
                      size: 90,
                      isOutlined: true,
                      name: "Details",
                      onPressed: () => _showCustomerDetails(context, customer),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AppImages.noData, width: 150, height: 150),
          const SizedBox(height: 16),
          Text(
            "No Customer Data Found",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Customer due and advance data will appear here when available",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchApi,
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            "Error Loading Customer Data",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(fontSize: 14, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchApi,
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetails(BuildContext context, CustomerDueAdvance customer) {
    final netBalanceText = customer.netBalance >= 0
        ? '\$${customer.netBalance.toStringAsFixed(2)}'
        : '-\$${customer.netBalance.abs().toStringAsFixed(2)}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bottomNavBg(context),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      customer.customerName,
                      style: AppTextStyle.bodyLarge(context),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 4),

                // Customer Details
                _buildMobileDetailRow('Phone:', customer.phone, context),
                _buildMobileDetailRow('Email:', customer.email, context),
                _buildMobileDetailRow(
                  'Due Amount:',
                  '\$${customer.presentDue.toStringAsFixed(2)}',
                  context,
                ),
                _buildMobileDetailRow(
                  'Advance Amount:',
                  '\$${customer.presentAdvance.toStringAsFixed(2)}',
                  context,
                ),
                _buildMobileDetailRow('Net Balance:', netBalanceText, context),
                _buildMobileDetailRow(
                  'Status:',
                  customer.balanceStatus,
                  context,
                ),

                // Status Card
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: customer.balanceStatusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: customer.balanceStatusColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        customer.balanceStatusIcon,
                        color: customer.balanceStatusColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Balance Status: ${customer.balanceStatus}',
                          style: TextStyle(
                            color: customer.balanceStatusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileDetailRow(
    String label,
    String value,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.text(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text(context),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _generatePdf() {
    final state = context.read<CustomerDueAdvanceBloc>().state;
    if (state is CustomerDueAdvanceSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title:  Text('Customer Due & Advance PDF',style: AppTextStyle.titleMedium(context),),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            body: PdfPreview(
              build: (format) =>
                  generateCustomerDueAdvanceReportPdf(state.response,context.read<ProfileBloc>().permissionModel?.data?.companyInfo),
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No customer data available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
