// lib/feature/report/presentation/screens/customer_due_advance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_inventory/core/configs/app_colors.dart';
import 'package:smart_inventory/core/configs/app_images.dart';
import 'package:smart_inventory/core/configs/app_text.dart';
import 'package:smart_inventory/core/shared/widgets/sideMenu/sidebar.dart';
import 'package:smart_inventory/core/widgets/app_dropdown.dart';
import 'package:smart_inventory/core/widgets/date_range.dart';
import 'package:smart_inventory/feature/customer/data/model/customer_active_model.dart';
import 'package:smart_inventory/feature/customer/data/model/customer_model.dart';
import 'package:smart_inventory/feature/customer/presentation/bloc/customer/customer_bloc.dart';

import '../../../../../responsive.dart';
import '../../../data/model/customer_due_advance_report_model.dart';
import '../../bloc/customer_due_advance_bloc/customer_due_advance_bloc.dart';


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
    // Load customers list
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
              const SizedBox(height: 16),
              _buildFilterRow(),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 16),
              _buildCustomerTable(),
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
        Text(
          "Customer Due & Advance Report",
          style: AppTextStyle.cardTitle(context).copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => _fetchApi(),
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 📅 Date Range Picker
        Expanded(
          flex: 1,
          child: SizedBox(
            width: 260,
            child: CustomDateRangeField(
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
        ),
        const SizedBox(width: 12),

        // 👥 Customer Dropdown
        Expanded(
          flex: 1,
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              if (state is CustomerListLoading) {
                return AppDropdown<CustomerActiveModel>(
                  context: context,
                  label: "Customer",
                  hint: "Loading customers...",
                  isNeedAll: true,
                  isRequired: false,
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
                label: "Customer",
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
        Expanded(
          flex: 1,
          child: AppDropdown<String>(
            context: context,
            label: "Status",
            hint: "Select Status",
            isNeedAll: false,
            isRequired: false,
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

        // 🧹 Clear Filters Button
        Expanded(
          flex: 0,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                selectedDateRange = null;
                _selectedCustomer = null;
                _selectedStatus = null;
              });
              context.read<CustomerDueAdvanceBloc>().add(ClearCustomerDueAdvanceFilters());
              _fetchApi();
            },
            icon: const Icon(Icons.clear_all),
            label: const Text("Clear"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.grey,
              foregroundColor: AppColors.blackColor,
            ),
          ),
        ),
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
          spacing: 16,
          runSpacing: 16,
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
              subtitle: summary.overallStatus,
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
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
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
            return _noDataWidget("No customer due & advance data found");
          }
          return CustomerDueAdvanceDataTableWidget(customers: state.response.report);
        } else if (state is CustomerDueAdvanceFailed) {
          return _errorWidget(state.content);
        }
        return _noDataWidget("No data available");
      },
    );
  }

  Widget CustomerDueAdvanceDataTableWidget({required List<CustomerDueAdvance> customers}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DataTable(
          headingRowColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) => AppColors.primaryColor.withOpacity(0.1),
          ),
          columns: const [
            DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Due Amount', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('Advance Amount', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('Net Balance', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: customers.asMap().entries.map((entry) {
            final index = entry.key;
            final customer = entry.value;

            return DataRow(
              color: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return index % 2 == 0 ? Colors.grey.withOpacity(0.05) : Colors.transparent;
                },
              ),
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(
                  Text(
                    customer.customerName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(Text(customer.phone)),
                DataCell(Text(customer.email)),
                DataCell(
                  customer.presentDue > 0
                      ? Text(
                    customer.formattedDue,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  )
                      : const Text('-'),
                ),
                DataCell(
                  customer.presentAdvance > 0
                      ? Text(
                    customer.formattedAdvance,
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  )
                      : const Text('-'),
                ),
                DataCell(
                  Container(
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: customer.balanceStatusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(customer.balanceStatusIcon, size: 14, color: customer.balanceStatusColor),
                        const SizedBox(width: 4),
                        Text(
                          customer.balanceStatus,
                          style: TextStyle(
                            color: customer.balanceStatusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _noDataWidget(String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(AppImages.noData, width: 200, height: 200),
        const SizedBox(height: 12),
        Text(message),
        const SizedBox(height: 8),
        ElevatedButton(
            onPressed: _fetchApi,
            child: const Text("Refresh")
        ),
      ],
    ),
  );

  Widget _errorWidget(String error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 60, color: Colors.red),
        const SizedBox(height: 16),
        Text("Error: $error"),
        const SizedBox(height: 8),
        ElevatedButton(
            onPressed: _fetchApi,
            child: const Text("Retry")
        ),
      ],
    ),
  );
}