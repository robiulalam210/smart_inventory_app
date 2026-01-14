import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';
import '/core/configs/app_colors.dart';
import '/core/configs/app_images.dart';
import '/core/configs/app_text.dart';
import '/core/widgets/app_button.dart';
import '/core/widgets/app_dropdown.dart';
import '/core/widgets/date_range.dart';
import '/core/widgets/show_custom_toast.dart';
import '/feature/report/presentation/page/expense_report_screen/pdf.dart';

import '../../../../../core/configs/app_routes.dart';
import '../../../../../responsive.dart';
import '../../../../expense/expense_head/data/model/expense_head_model.dart';
import '../../../../expense/expense_head/presentation/bloc/expense_head/expense_head_bloc.dart';
import '../../../data/model/expense_report_model.dart';
import '../../bloc/expense_report_bloc/expense_report_bloc.dart';

class MobileExpenseReportScreen extends StatefulWidget {
  const MobileExpenseReportScreen({super.key});

  @override
  State<MobileExpenseReportScreen> createState() => _MobileExpenseReportScreenState();
}

class _MobileExpenseReportScreenState extends State<MobileExpenseReportScreen> {
  DateRange? selectedDateRange;
  ExpenseHeadModel? _selectedExpenseHead;
  String? _selectedPaymentMethod;
  bool _isFilterExpanded = false;

  final List<String> paymentMethods = ['Cash', 'Bank', 'Mobile Banking'];
  Timer? _filterDebounceTimer;

  @override
  void initState() {
    super.initState();
    context.read<ExpenseHeadBloc>().add(FetchExpenseHeadList(context));
    _fetchApi();
  }

  void _fetchApi({
    DateTime? from,
    DateTime? to,
    String? head,
    String? paymentMethod,
  }) {
    context.read<ExpenseReportBloc>().add(
      FetchExpenseReport(
        context: context,
        from: from,
        to: to,
        head: head,
        paymentMethod: paymentMethod,
      ),
    );
  }

  void _fetchApiWithDebounce({
    DateTime? from,
    DateTime? to,
    String? head,
    String? paymentMethod,
  }) {
    _filterDebounceTimer?.cancel();
    _filterDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchApi(
        from: from,
        to: to,
        head: head,
        paymentMethod: paymentMethod,
      );
    });
  }

  void _onExpenseHeadChanged(ExpenseHeadModel? newValue) {
    setState(() => _selectedExpenseHead = newValue);
    _fetchApiWithDebounce(
      head: newValue?.id?.toString(),
      from: selectedDateRange?.start,
      to: selectedDateRange?.end,
      paymentMethod: _selectedPaymentMethod,
    );
  }

  void _onPaymentMethodChanged(String? newValue) {
    setState(() => _selectedPaymentMethod = newValue);
    _fetchApiWithDebounce(
      head: _selectedExpenseHead?.id?.toString(),
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
        description: 'End date cannot be before start date',
        icon: Icons.error,
        primaryColor: Colors.redAccent,
      );
      return;
    }

    _fetchApiWithDebounce(
      from: value?.start,
      to: value?.end,
      head: _selectedExpenseHead?.id?.toString(),
      paymentMethod: _selectedPaymentMethod,
    );
  }

  @override
  void dispose() {
    _filterDebounceTimer?.cancel();
    super.dispose();
  }

  String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bottomNavBg(context),
      appBar: AppBar(
        title: const Text('Expense Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchApi(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchApi(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter Section
              _buildMobileFilterSection(),
              const SizedBox(height: 16),

              // Summary Cards
              _buildSummaryCards(),
              const SizedBox(height: 16),

              // Expense List
              _buildExpenseList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _isFilterExpanded = !_isFilterExpanded);
        },
        child: Icon(_isFilterExpanded ? Icons.filter_alt_off : Icons.filter_alt),
        tooltip: 'Toggle Filters',
      ),
    );
  }

  Widget _buildMobileFilterSection() {
    return Card(
      child: ExpansionPanelList(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        expansionCallback: (int index, bool isExpanded) {
          setState(() => _isFilterExpanded = !isExpanded);
        },
        children: [
          ExpansionPanel(
            headerBuilder: (context, isExpanded) {
              return const ListTile(
                leading: Icon(Icons.filter_alt),
                title: Text('Filters'),
              );
            },
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Date Range Picker
                  CustomDateRangeField(
                    isLabel: true,
                    selectedDateRange: selectedDateRange,
                    onDateRangeSelected: _onDateRangeSelected,
                  ),
                  const SizedBox(height: 12),

                  // Expense Head Dropdown
                  BlocBuilder<ExpenseHeadBloc, ExpenseHeadState>(
                    builder: (context, state) {
                      if (state is ExpenseHeadListLoading) {
                        return AppDropdown<ExpenseHeadModel>(
                          label: "Expense Head",
                          hint: "Loading expense heads...",
                          isNeedAll: true,
                          isLabel: true,
                          value: null,
                          itemList: [],
                          onChanged: (v) {},
                        );
                      }

                      if (state is ExpenseHeadListFailed) {
                        return AppDropdown<ExpenseHeadModel>(
                          label: "Expense Head",
                          hint: "Failed to load expense heads",
                          isNeedAll: true,
                          isLabel: true,
                          value: null,
                          itemList: [],
                          onChanged: (v) {},
                        );
                      }

                      return AppDropdown<ExpenseHeadModel>(
                        label: "Expense Head",
                        hint: "Select Expense Head",
                        isNeedAll: true,
                        isLabel: true,
                        value: _selectedExpenseHead,
                        itemList: context.read<ExpenseHeadBloc>().list,
                        onChanged: _onExpenseHeadChanged,
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Payment Method Dropdown
                  AppDropdown<String>(
                    label: "Payment Method",
                    hint: "Select Payment Method",
                    isNeedAll: true,
                    isLabel: true,
                    value: _selectedPaymentMethod,
                    itemList: paymentMethods,
                    onChanged: _onPaymentMethodChanged,
                  ),
                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedDateRange = null;
                              _selectedExpenseHead = null;
                              _selectedPaymentMethod = null;
                              _isFilterExpanded = false;
                            });
                            context.read<ExpenseReportBloc>().add(
                              ClearExpenseReportFilters(),
                            );
                            _fetchApi();
                          },
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Clear Filters'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.grey[800],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _generatePdf,
                          icon: const Icon(Icons.picture_as_pdf, size: 18),
                          label: const Text('PDF Report'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            isExpanded: _isFilterExpanded,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<ExpenseReportBloc, ExpenseReportState>(
      builder: (context, state) {
        if (state is! ExpenseReportSuccess) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 60,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Expense Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Apply filters to view expense statistics",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final summary = state.response.summary;
        final avgExpense = summary.totalCount > 0 ? (summary.totalAmount / summary.totalCount) : 0.0;

        return Column(
          children: [
            // First row
            Row(
              children: [
                _buildMobileSummaryCard(
                  "Total Expenses",
                  summary.totalCount.toString(),
                  Icons.receipt_long,
                  AppColors.primaryColor(context),
                ),
                const SizedBox(width: 8),
                _buildMobileSummaryCard(
                  "Total Amount",
                  _formatCurrency(summary.totalAmount),
                  Icons.attach_money,
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Second row
            Row(
              children: [
                _buildMobileSummaryCard(
                  "Average Expense",
                  _formatCurrency(avgExpense),
                  Icons.trending_up,
                  Colors.green,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(12),
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
                      Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Date Range",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Text(
                          //   _formatDateRange(summary.dateRange),
                          //   style: const TextStyle(
                          //     fontSize: 12,
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.blue,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
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
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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
                    style: const TextStyle(
                      fontSize: 10,
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
      ),
    );
  }

  Widget _buildExpenseList() {
    return BlocBuilder<ExpenseReportBloc, ExpenseReportState>(
      builder: (context, state) {
        if (state is ExpenseReportLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading expenses..."),
              ],
            ),
          );
        } else if (state is ExpenseReportSuccess) {
          if (state.response.report.isEmpty) {
            return _buildEmptyState();
          }
          return _buildMobileExpenseList(state.response.report);
        } else if (state is ExpenseReportFailed) {
          return _buildErrorState(state.content);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildMobileExpenseList(List<ExpenseReport> expenses) {
    final totalAmount = expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Total Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Expenses',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      expenses.length.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      _formatCurrency(totalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Expense List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expense Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            expense.head,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatCurrency(expense.amount),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Details Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatDate(expense.expenseDate),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPaymentMethodColor(expense.paymentMethod).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            expense.paymentMethod,
                            style: TextStyle(
                              fontSize: 10,
                              color: _getPaymentMethodColor(expense.paymentMethod),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Subhead and Note
                    if (expense.subhead != null || expense.note != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (expense.subhead != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                expense.subhead!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          if (expense.note != null)
                            Text(
                              expense.note!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),

                    // View Details Button
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _showExpenseDetails(context, expense),
                        icon: const Icon(Icons.remove_red_eye, size: 14),
                        label: const Text('View Details'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
            "No Expense Data Found",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Expense data will appear here when available",
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
            "Error Loading Expenses",
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

  void _showExpenseDetails(BuildContext context, ExpenseReport expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
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
                    'Expense Details',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Expense Details
              _buildMobileDetailRow('Expense Head:', expense.head),
              if (expense.subhead != null)
                _buildMobileDetailRow('Expense Subhead:', expense.subhead!),
              _buildMobileDetailRow('Date:', _formatDate(expense.expenseDate)),
              _buildMobileDetailRow('Amount:', _formatCurrency(expense.amount)),
              _buildMobileDetailRow('Payment Method:', expense.paymentMethod),
              if (expense.note != null) _buildMobileDetailRow('Note:', expense.note!),

              // Payment Method Badge
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getPaymentMethodColor(expense.paymentMethod).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getPaymentMethodColor(expense.paymentMethod)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPaymentMethodIcon(expense.paymentMethod),
                      color: _getPaymentMethodColor(expense.paymentMethod),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Paid via ${expense.paymentMethod}',
                        style: TextStyle(
                          color: _getPaymentMethodColor(expense.paymentMethod),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _generatePdf() {
    final state = context.read<ExpenseReportBloc>().state;
    if (state is ExpenseReportSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Expense Report PDF'),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            body: PdfPreview(
              build: (format) => generateExpenseReportPdf(state.response),
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
          content: Text('No expense data available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Color _getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'bank':
        return Colors.blue;
      case 'mobile banking':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'bank':
        return Icons.account_balance;
      case 'mobile banking':
        return Icons.phone_android;
      default:
        return Icons.payment;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateRange(Map<String, String> dateRange) {
    try {
      final start = DateTime.parse(dateRange['start'] ?? DateTime.now().toIso8601String());
      final end = DateTime.parse(dateRange['end'] ?? DateTime.now().toIso8601String());
      return '${_formatDate(start)} - ${_formatDate(end)}';
    } catch (e) {
      return 'Date Range';
    }
  }
}