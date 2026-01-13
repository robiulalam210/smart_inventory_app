// lib/feature/report/presentation/screens/expense_report_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';
import '/core/configs/app_colors.dart';
import '/core/configs/app_images.dart';
import '/core/configs/app_text.dart';
import '/core/shared/widgets/sideMenu/sidebar.dart';
import '/core/widgets/app_button.dart';
import '/core/widgets/app_dropdown.dart';
import '/core/widgets/date_range.dart';
import '/feature/report/presentation/page/expense_report_screen/pdf.dart';

import '../../../../../core/configs/app_routes.dart';
import '../../../../../core/widgets/show_custom_toast.dart';
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

  final List<String> paymentMethods = [
    'Cash',
    'Bank',
    'Card',
    'Mobile Banking',
  ];
  Timer? _filterDebounceTimer;

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
    context.read<ExpenseReportBloc>().add(
      FetchExpenseReport(
        context: context,
        from: from,
        to: to,
        head: head,
        subHead: subHead,
        paymentMethod: paymentMethod,
      ),
    );
  }

  void _fetchApiWithDebounce({
    DateTime? from,
    DateTime? to,
    String? head,
    String? subHead,
    String? paymentMethod,
  }) {
    _filterDebounceTimer?.cancel();
    _filterDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchApi(
        from: from,
        to: to,
        head: head,
        subHead: subHead,
        paymentMethod: paymentMethod,
      );
    });
  }

  void _onExpenseHeadChanged(ExpenseHeadModel? newValue) {
    setState(() {
      _selectedExpenseHead = newValue;
      _selectedExpenseSubHead = null; // Reset subhead when head changes
    });
    _fetchApiWithDebounce(
      head: newValue?.id?.toString(),
      subHead: null,
      from: selectedDateRange?.start,
      to: selectedDateRange?.end,
      paymentMethod: _selectedPaymentMethod,
    );
  }


  void _onPaymentMethodChanged(String? newValue) {
    setState(() {
      _selectedPaymentMethod = newValue;
    });
    _fetchApiWithDebounce(
      head: _selectedExpenseHead?.id?.toString(),
      subHead: _selectedExpenseSubHead?.id?.toString(),
      from: selectedDateRange?.start,
      to: selectedDateRange?.end,
      paymentMethod: newValue,
    );
  }

  void _onDateRangeSelected(DateRange? value) {
    setState(() => selectedDateRange = value);

    if (value != null && value.start.isAfter(value.end)) {
      showCustomToast(
        context: context,
        title: 'Alert!',
        description:
        'End date cannot be before start date',
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );

      return;
    }

    _fetchApiWithDebounce(
      from: value?.start,
      to: value?.end,
      head: _selectedExpenseHead?.id?.toString(),
      subHead: _selectedExpenseSubHead?.id?.toString(),
      paymentMethod: _selectedPaymentMethod,
    );
  }

  @override
  void dispose() {
    _filterDebounceTimer?.cancel();
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
      lg: 12,
      child: RefreshIndicator(
        onRefresh: () async => _fetchApi(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 6),
              _buildFilterRow(),
              const SizedBox(height: 0),
              _buildSummaryCards(),
              const SizedBox(height: 4),
              SizedBox(child: _buildExpenseTable()),
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
              "Expense Report",
              style: AppTextStyle.cardTitle(
                context,
              ).copyWith(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Track and analyze your business expenses",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
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
            SizedBox(
              width: 260,
              child: CustomDateRangeField(
                isLabel: false,
                selectedDateRange: selectedDateRange,
                onDateRangeSelected: _onDateRangeSelected,
              ),
            ),
            const SizedBox(width: 8),

            // Payment Method Dropdown
            SizedBox(
              width: 240,
              child: AppDropdown<String>(
                context: context,
                label: "Payment Method",
                hint: "Select Payment Method",
                isNeedAll: true,
                isRequired: false,
                isLabel: true,
                value: _selectedPaymentMethod,
                itemList: paymentMethods,
                onChanged: _onPaymentMethodChanged,
                itemBuilder: (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style:  TextStyle(
                      color:AppColors.blackColor(context),
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 240,
              child: BlocBuilder<ExpenseHeadBloc, ExpenseHeadState>(
                builder: (context, state) {
                  if (state is ExpenseHeadListLoading) {
                    return AppDropdown<ExpenseHeadModel>(
                      context: context,
                      label: "Expense Head",
                      hint: "Loading expense heads...",
                      isNeedAll: true,
                      isRequired: false,
                      isLabel: true,
                      value: null,
                      itemList: [],
                      onChanged: (v) {},
                      itemBuilder: (item) =>
                          const DropdownMenuItem<ExpenseHeadModel>(
                            value: null,
                            child: Text('Loading...'),
                          ),
                    );
                  }

                  if (state is ExpenseHeadListFailed) {
                    return AppDropdown<ExpenseHeadModel>(
                      context: context,
                      label: "Expense Head",
                      hint: "Failed to load expense heads",
                      isNeedAll: true,
                      isRequired: false,
                      value: null,
                      isLabel: true,
                      itemList: [],
                      onChanged: (v) {},
                      itemBuilder: (item) =>
                          const DropdownMenuItem<ExpenseHeadModel>(
                            value: null,
                            child: Text('Error loading heads'),
                          ),
                    );
                  }

                  return AppDropdown<ExpenseHeadModel>(
                    context: context,
                    label: "Expense Head",
                    hint: "Select Expense Head",
                    isNeedAll: true,
                    isRequired: false,
                    isLabel: true,
                    value: _selectedExpenseHead,
                    itemList: context.read<ExpenseHeadBloc>().list,
                    onChanged: _onExpenseHeadChanged,
                    itemBuilder: (item) => DropdownMenuItem<ExpenseHeadModel>(
                      value: item,
                      child: Text(
                        item.name ?? 'Unnamed Head',
                        style:  TextStyle(
                          color:AppColors.blackColor(context),
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 4),

            AppButton(
              name: "Clear",
              color: AppColors.error,
              onPressed: () {
                setState(() {
                  selectedDateRange = null;
                  _selectedExpenseHead = null;
                  _selectedExpenseSubHead = null;
                  _selectedPaymentMethod = null;
                });
                context.read<ExpenseReportBloc>().add(
                  ClearExpenseReportFilters(),
                );
                _fetchApi();
              },
            ),

            // Clear Filters Button
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<ExpenseReportBloc, ExpenseReportState>(
      builder: (context, state) {
        if (state is! ExpenseReportSuccess) {
          return Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 48,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Apply Filters to View Expense Summary",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Select date range and expense criteria to see summary statistics",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final summary = state.response.summary;

        return Wrap(
          spacing: 12,
          runSpacing: 0,
          children: [
            _buildSummaryCard(
              "Total Expenses",
              summary.totalCount.toString(),
              Icons.receipt_long,
              AppColors.primaryColor(context),
            ),
            _buildSummaryCard(
              "Total Amount",
              "\$${summary.totalAmount.toStringAsFixed(2)}",
              Icons.attach_money,
              Colors.red,
            ),
            _buildSummaryCard(
              "Average Expense",
              "\$${(summary.totalAmount / summary.totalCount).toStringAsFixed(2)}",
              Icons.trending_up,
              Colors.green,
            ),
            _buildSummaryCard(
              "Date Range",
              "${_formatDate(DateTime.parse(summary.dateRange['start'] ?? DateTime.now().toIso8601String()))} - ${_formatDate(DateTime.parse(summary.dateRange['end'] ?? DateTime.now().toIso8601String()))}",
              Icons.calendar_today,
              Colors.blue,
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
                      build: (format) => generateExpenseReportPdf(
                        state.response,

                      ),
                      pdfPreviewPageDecoration:
                      BoxDecoration(color: AppColors.white),
                      actionBarTheme: PdfActionBarTheme(
                        backgroundColor: AppColors.primaryColor(context),
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

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 4),
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
            return _buildEmptyState();
          }
          return ExpenseReportDataTable(expenses: state.response.report);
        } else if (state is ExpenseReportFailed) {
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
            "No Expense Data Found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Expense data will appear here when available",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchApi, child: const Text("Refresh")),
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
            "Error Loading Expense Report",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(fontSize: 14, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchApi, child: const Text("Retry")),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class ExpenseReportDataTable extends StatelessWidget {
  final List<ExpenseReport> expenses;

  const ExpenseReportDataTable({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final totalAmount = expenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            // Summary row
            _buildTableSummary(totalAmount),
            const SizedBox(height: 4),
            // Data table
            SizedBox(child: _buildDataTable()),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSummary(double totalAmount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(
            'Total Expenses: ${expenses.length}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const Spacer(),
          Text(
            'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns =
            8; // #, Date, Head, Sub Head, Amount, Payment Method, Note, Actions
        const minColumnWidth = 100.0;

        final dynamicColumnWidth = (totalWidth / numColumns).clamp(
          minColumnWidth,
          double.infinity,
        );

        return Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.resolveWith<Color>(
                  (states) => AppColors.primaryColor(context),
                ),
                columnSpacing: 12,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 40,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 12,
                ),
                dataTextStyle: const TextStyle(
                  fontSize: 11,
                  color: Colors.black87,
                ),
                columns: [
                  DataColumn(
                    label: SizedBox(
                      width: dynamicColumnWidth * 0.6,
                      child: const Text('#', textAlign: TextAlign.center),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: dynamicColumnWidth,
                      child: const Text('Date', textAlign: TextAlign.center),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: dynamicColumnWidth,
                      child: const Text('Head', textAlign: TextAlign.center),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: dynamicColumnWidth,
                      child: const Text(
                        'Sub Head',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: dynamicColumnWidth,
                      child: const Text('Amount', textAlign: TextAlign.center),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: dynamicColumnWidth,
                      child: const Text(
                        'Payment Method',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: dynamicColumnWidth * 1.5,
                      child: const Text(
                        'Note',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: SizedBox(
                      width: dynamicColumnWidth * 0.8,
                      child: const Text('Actions', textAlign: TextAlign.center),
                    ),
                  ),
                ],
                rows: expenses.map((expense) {
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: dynamicColumnWidth * 0.6,
                          child: Center(
                            child: Text(
                              '${expense.sl}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dynamicColumnWidth,
                          child: Center(
                            child: Text(
                              _formatDate(expense.expenseDate),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dynamicColumnWidth,
                          child: Tooltip(
                            message: expense.head,
                            child: Text(
                              expense.head,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dynamicColumnWidth,
                          child: Center(
                            child: Text(
                              expense.subhead ?? '-',
                              style: TextStyle(
                                color: expense.subhead == null
                                    ? Colors.grey
                                    : Colors.black87,
                                fontStyle: expense.subhead == null
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dynamicColumnWidth,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                expense.amount.toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dynamicColumnWidth,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _getPaymentMethodColor(
                                  expense.paymentMethod,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                expense.paymentMethod,
                                style: TextStyle(
                                  color: _getPaymentMethodColor(
                                    expense.paymentMethod,
                                  ),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dynamicColumnWidth * 1.5,
                          child: Tooltip(
                            message: expense.note ?? 'No description',
                            child: Text(
                              expense.note ?? 'No note',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: expense.note == null
                                    ? Colors.grey
                                    : Colors.black87,
                                fontStyle: expense.note == null
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: dynamicColumnWidth * 0.8,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility, size: 16),
                                  tooltip: 'View details',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'bank':
        return Colors.blue;
      case 'card':
        return Colors.orange;
      case 'mobile banking':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
