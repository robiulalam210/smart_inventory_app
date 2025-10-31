// lib/feature/report/presentation/screens/expense_report_screen.dart
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

import '../../../../../responsive.dart';
import '../../../../expense/expense_head/data/model/expense_head_model.dart';
import '../../../../expense/expense_head/presentation/bloc/expense_head/expense_head_bloc.dart';
import '../../../../expense/expense_sub_head/data/model/expense_sub_head_model.dart';
import '../../../../expense/expense_sub_head/presentation/bloc/expense_sub_head/expense_sub_head_bloc.dart';
import '../../../data/model/expense_report_model.dart';
import '../../bloc/expense_report_bloc/expense_report_bloc.dart';


class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({super.key});

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  DateRange? selectedDateRange;
  ExpenseHeadModel? _selectedExpenseHead;
  ExpenseSubHeadModel? _selectedExpenseSubHead;
  String? _selectedPaymentMethod;

  final List<String> paymentMethods = ['Cash', 'Bank', 'Card', 'Mobile Banking'];

  @override
  void initState() {
    super.initState();
    // Load expense heads and subheads
    context.read<ExpenseHeadBloc>().add(FetchExpenseHeadList(context));
    context.read<ExpenseSubHeadBloc>().add(FetchSubExpenseHeadList(context));
    _fetchApi();
  }

  void _fetchApi({
    DateTime? from,
    DateTime? to,
    String? head,
    String? subHead,
    String? paymentMethod,
  }) {
    context.read<ExpenseReportBloc>().add(FetchExpenseReport(
      context: context,
      from: from,
      to: to,
      head: head,
      subHead: subHead,
      paymentMethod: paymentMethod,
    ));
  }

  void _onExpenseHeadChanged(ExpenseHeadModel? newValue) {
    setState(() {
      _selectedExpenseHead = newValue;
      _selectedExpenseSubHead = null; // Reset subhead when head changes
    });
    _fetchApi(
      head: newValue?.id?.toString(),
      subHead: null,
      from: selectedDateRange?.start,
      to: selectedDateRange?.end,
      paymentMethod: _selectedPaymentMethod,
    );
  }

  void _onExpenseSubHeadChanged(ExpenseSubHeadModel? newValue) {
    setState(() {
      _selectedExpenseSubHead = newValue;
    });
    _fetchApi(
      head: _selectedExpenseHead?.id?.toString(),
      subHead: newValue?.id?.toString(),
      from: selectedDateRange?.start,
      to: selectedDateRange?.end,
      paymentMethod: _selectedPaymentMethod,
    );
  }

  void _onPaymentMethodChanged(String? newValue) {
    setState(() {
      _selectedPaymentMethod = newValue;
    });
    _fetchApi(
      head: _selectedExpenseHead?.id?.toString(),
      subHead: _selectedExpenseSubHead?.id?.toString(),
      from: selectedDateRange?.start,
      to: selectedDateRange?.end,
      paymentMethod: newValue,
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
              _buildExpenseTable(),
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
          "Expense Report",
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
    return Column(
      children: [
        // First row: Date range and Clear button
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Picker
            Expanded(
              flex: 2,
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
                        head: _selectedExpenseHead?.id?.toString(),
                        subHead: _selectedExpenseSubHead?.id?.toString(),
                        paymentMethod: _selectedPaymentMethod,
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Payment Method Dropdown
            Expanded(
              flex: 1,
              child: AppDropdown<String>(
                context: context,
                label: "Payment Method",
                hint: "Select Payment Method",
                isNeedAll: true,
                isRequired: false,
                value: _selectedPaymentMethod,
                itemList: paymentMethods,
                onChanged: _onPaymentMethodChanged,
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
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Clear Filters Button
            Expanded(
              flex: 0,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    selectedDateRange = null;
                    _selectedExpenseHead = null;
                    _selectedExpenseSubHead = null;
                    _selectedPaymentMethod = null;
                  });
                  context.read<ExpenseReportBloc>().add(ClearExpenseReportFilters());
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
        ),
        const SizedBox(height: 16),

        // Second row: Expense Head and SubHead
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expense Head Dropdown
            Expanded(
              child: BlocBuilder<ExpenseHeadBloc, ExpenseHeadState>(
                builder: (context, state) {
                  if (state is ExpenseHeadListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return AppDropdown<ExpenseHeadModel>(
                    context: context,
                    label: "Expense Head",
                    hint: _selectedExpenseHead?.name ?? "Select Expense Head",
                    isNeedAll: true,
                    isRequired: false,
                    value: _selectedExpenseHead,
                    itemList: context.read<ExpenseHeadBloc>().list,
                    onChanged: _onExpenseHeadChanged,
                    itemBuilder: (item) => DropdownMenuItem<ExpenseHeadModel>(
                      value: item,
                      child: Text(
                        item.name ?? 'Unnamed Head',
                        style: const TextStyle(
                          color: AppColors.blackColor,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),

            // Expense SubHead Dropdown
            Expanded(
              child: BlocBuilder<ExpenseSubHeadBloc, ExpenseSubHeadState>(
                builder: (context, state) {
                  final subHeads = _selectedExpenseHead != null
                      ? (context.read<ExpenseSubHeadBloc>().list)
                      .where((subHead) => subHead.head == _selectedExpenseHead!.id)
                      .toList()
                      : <ExpenseSubHeadModel>[];

                  return AppDropdown<ExpenseSubHeadModel>(
                    context: context,
                    label: "Expense Sub Head (Optional)",
                    hint: _selectedExpenseSubHead?.name ?? "Select Expense Sub Head",
                    isNeedAll: true,
                    isRequired: false,
                    value: _selectedExpenseSubHead,
                    itemList: subHeads,
                    onChanged: _onExpenseSubHeadChanged,
                    itemBuilder: (item) => DropdownMenuItem<ExpenseSubHeadModel>(
                      value: item,
                      child: Text(
                        item.name ?? 'Unnamed Sub Head',
                        style: const TextStyle(
                          color: AppColors.blackColor,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<ExpenseReportBloc, ExpenseReportState>(
      builder: (context, state) {
        if (state is! ExpenseReportSuccess) return const SizedBox();

        final summary = state.response.summary;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildSummaryCard(
              "Total Expenses",
              summary.totalCount.toString(),
              Icons.receipt_long,
              AppColors.primaryColor,
            ),
            _buildSummaryCard(
              "Total Amount",
              "\$${summary.totalAmount.toStringAsFixed(2)}",
              Icons.attach_money,
              Colors.red,
            ),
            _buildSummaryCard(
              "Date Range",
              "${_formatDate(DateTime.parse(summary.dateRange['start'] ?? DateTime.now().toIso8601String()))} - ${_formatDate(DateTime.parse(summary.dateRange['end'] ?? DateTime.now().toIso8601String()))}",
              Icons.calendar_today,
              Colors.blue,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTable() {
    return BlocBuilder<ExpenseReportBloc, ExpenseReportState>(
      builder: (context, state) {
        if (state is ExpenseReportLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading expense report..."),
              ],
            ),
          );
        } else if (state is ExpenseReportSuccess) {
          if (state.response.report.isEmpty) {
            return _noDataWidget("No expense data found");
          }
          return ExpenseReportDataTableWidget(expenses: state.response.report);
        } else if (state is ExpenseReportFailed) {
          return _errorWidget(state.content);
        }
        return _noDataWidget("No data available");
      },
    );
  }

  Widget ExpenseReportDataTableWidget({required List<ExpenseReport> expenses}) {
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
            DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Head', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Sub Head', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Note', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: expenses.map((expense) => DataRow(
            cells: [
              DataCell(Text('${expense.sl}')),
              DataCell(Text(_formatDate(expense.expenseDate))),
              DataCell(Text(expense.head)),
              DataCell(Text(expense.subhead ?? '-')),
              DataCell(
                Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    expense.paymentMethod,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 150,
                  child: Text(
                    expense.note ?? 'No note',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: expense.note == null ? Colors.grey : Colors.black,
                      fontStyle: expense.note == null ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ],
          )).toList(),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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