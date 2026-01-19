import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:meherinMart/core/configs/app_text.dart';
import 'package:printing/printing.dart';
import '../../../../../core/widgets/app_button.dart';
import '/core/configs/app_colors.dart';
import '/core/configs/app_images.dart';
import '/core/widgets/app_dropdown.dart';
import '/core/widgets/date_range.dart';
import '/feature/customer/data/model/customer_active_model.dart';
import '/feature/customer/presentation/bloc/customer/customer_bloc.dart';
import '/feature/report/presentation/page/customer_ledger_screen/pdf.dart';

import '../../../data/model/customer_ledger_model.dart';
import '../../bloc/customer_ledger_bloc/customer_ledger_bloc.dart';

class MobileCustomerLedgerScreen extends StatefulWidget {
  const MobileCustomerLedgerScreen({super.key});

  @override
  State<MobileCustomerLedgerScreen> createState() =>
      _MobileCustomerLedgerScreenState();
}

class _MobileCustomerLedgerScreenState
    extends State<MobileCustomerLedgerScreen> {
  DateRange? selectedDateRange;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(FetchCustomerActiveList(context));
  }

  void _fetchCustomerLedger({
    required String customer,
    DateTime? from,
    DateTime? to,
  }) {
    if (customer.isEmpty) return;

    context.read<CustomerLedgerBloc>().add(
      FetchCustomerLedger(
        context: context,
        customer: customer,
        from: from,
        to: to,
      ),
    );
  }

  String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bottomNavBg(context),
      appBar: AppBar(
        title: Text(
          'Customer Ledger',
          style: AppTextStyle.titleMedium(context),
        ),
        actions: [
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedPdf02),
            color: AppColors.text(context),

            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedReload, color: AppColors.text(context)),
            onPressed: () {
              final customer = context
                  .read<CustomerLedgerBloc>()
                  .selectedCustomer;
              if (customer != null) {
                _fetchCustomerLedger(customer: customer.id.toString());
              }
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final customer = context.read<CustomerLedgerBloc>().selectedCustomer;
          if (customer != null) {
            _fetchCustomerLedger(customer: customer.id.toString());
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter Section
              _buildMobileFilterSection(),
              const SizedBox(height: 4),

              // Customer Summary
              _buildCustomerSummary(),
              const SizedBox(height: 8),

              // Ledger Transactions
              _buildLedgerTransactions(),
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
          _isFilterExpanded ? Icons.filter_alt_off : Icons.filter_alt,
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
          // Header: fully clickable
          InkWell(
            onTap: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(HugeIcons.strokeRoundedFilter, color: AppColors.text(context)),
                  const SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: AppTextStyle.bodyLarge(context),
                  ),
                  const Spacer(),
                  Icon(
                    _isFilterExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.text(context),
                  ),
                ],
              ),
            ),
          ),

          // Expandable body
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Customer Dropdown
                  BlocBuilder<CustomerBloc, CustomerState>(
                    builder: (context, state) {
                      return AppDropdown<CustomerActiveModel>(
                        label: "Customer",
                        isSearch: true,
                        hint: "Select Customer",
                        isNeedAll: false,
                        isRequired: true,
                        isLabel: true,
                        value: context
                            .read<CustomerLedgerBloc>()
                            .selectedCustomer,
                        itemList: context.read<CustomerBloc>().activeCustomer,
                        onChanged: (newVal) {
                          if (newVal != null) {
                            context
                                .read<CustomerLedgerBloc>()
                                .selectedCustomer = newVal;
                            _fetchCustomerLedger(
                              customer: newVal.id.toString(),
                              from: selectedDateRange?.start,
                              to: selectedDateRange?.end,
                            );
                          }
                        },
                        validator: (value) =>
                        value == null ? 'Please select Customer' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Date Range Picker
                  CustomDateRangeField(
                    isLabel: true,
                    selectedDateRange: selectedDateRange,
                    onDateRangeSelected: (value) {
                      setState(() => selectedDateRange = value);
                      final customer =
                          context.read<CustomerLedgerBloc>().selectedCustomer;
                      if (value != null && customer != null) {
                        _fetchCustomerLedger(
                          customer: customer.id.toString(),
                          from: value.start,
                          to: value.end,
                        );
                      }
                    },
                  ),

                  // TODO: Add Action Buttons here
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




  Widget _buildCustomerSummary() {
    return BlocBuilder<CustomerLedgerBloc, CustomerLedgerState>(
      builder: (context, state) {
        final customer = context.read<CustomerLedgerBloc>().selectedCustomer;

        if (customer == null) {
          return Card(
            color: AppColors.bottomNavBg(context),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 60,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Select a Customer",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choose a customer from the dropdown to view their ledger transactions",
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! CustomerLedgerSuccess) {
          return Card(
            color: AppColors.bottomNavBg(context),

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    customer.name ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Loading ledger data...",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          );
        }

        final summary = state.response.summary;
        final transactions = state.response.report;

        // Calculate metrics
        final openingBalance = _calculateOpeningBalance(transactions);
        final totalDebit = transactions.fold(0.0, (sum, t) => sum + t.debit);
        final totalCredit = transactions.fold(0.0, (sum, t) => sum + t.credit);
        // final salesCount = transactions.where((t) => t.type.toLowerCase() == 'sale').length;
        // final paymentsCount = transactions.where((t) => t.type.toLowerCase() == 'payment').length;

        return Card(
          color: AppColors.bottomNavBg(context),

          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        customer.name ?? "",
                        style: AppTextStyle.body(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Balance Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: summary.closingBalance >= 0
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Balance',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.text(context),
                              ),
                            ),
                            Text(
                              _formatCurrency(summary.closingBalance),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: summary.closingBalance >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: summary.closingBalance >= 0
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          summary.closingBalance >= 0
                              ? 'IN CREDIT'
                              : 'IN DEBIT',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.7,
                  children: [
                    _buildMobileStatItem(
                      'Opening',
                      _formatCurrency(openingBalance),
                      Icons.account_balance_wallet,
                      Colors.blue,
                    ),
                    _buildMobileStatItem(
                      'Total Debit',
                      _formatCurrency(totalDebit),
                      Icons.arrow_downward,
                      Colors.red,
                    ),
                    _buildMobileStatItem(
                      'Total Credit',
                      _formatCurrency(totalCredit),
                      Icons.arrow_upward,
                      Colors.green,
                    ),
                    _buildMobileStatItem(
                      'Transactions',
                      summary.totalTransactions.toString(),
                      Icons.receipt,
                      AppColors.primaryColor(context),
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

  Widget _buildMobileStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyle.bodySmall(context)),
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

  double _calculateOpeningBalance(
    List<CustomerLedgerTransaction> transactions,
  ) {
    if (transactions.isEmpty) return 0.0;
    final firstTransaction = transactions.first;
    return firstTransaction.due -
        (firstTransaction.debit - firstTransaction.credit);
  }

  Widget _buildLedgerTransactions() {
    return BlocBuilder<CustomerLedgerBloc, CustomerLedgerState>(
      builder: (context, state) {
        if (state is CustomerLedgerLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading transactions..."),
              ],
            ),
          );
        } else if (state is CustomerLedgerSuccess) {
          if (state.response.report.isEmpty) {
            return _buildEmptyState(
              "No transactions found for the selected period",
            );
          }
          return _buildMobileTransactionList(state.response.report);
        } else if (state is CustomerLedgerFailed) {
          return _buildErrorState(state.content);
        }
        return _buildEmptyState("Select a customer to view transactions");
      },
    );
  }

  Widget _buildMobileTransactionList(
    List<CustomerLedgerTransaction> transactions,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isDebit = transaction.debit > 0;
        final isCredit = transaction.credit > 0;

        return Card(
          color: AppColors.bottomNavBg(context),
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        transaction.voucherNo,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.text(context),

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: transaction.typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            transaction.typeIcon,
                            size: 12,
                            color: transaction.typeColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            transaction.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: transaction.typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Date and Particular
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDate(transaction.date),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        transaction.particular,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Amount Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isDebit)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'DEBIT',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red,
                                ),
                              ),
                              Text(
                                _formatCurrency(transaction.debit),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (isDebit && isCredit) const SizedBox(width: 8),
                    if (isCredit)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'CREDIT',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                _formatCurrency(transaction.credit),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: transaction.due >= 0
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: transaction.due >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'BALANCE',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              _formatCurrency(transaction.due.abs()),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: transaction.due >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Details and Method
                if (transaction.details.isNotEmpty ||
                    transaction.method.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      if (transaction.details.isNotEmpty)
                        Text(
                          transaction.details,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.text(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (transaction.method.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.payment,
                                size: 12,
                                color: AppColors.text(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                transaction.method,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.text(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                // View Details Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      size: 90,
                      isOutlined: true,
                      name: "Details",


                      onPressed: () => _showTransactionDetails(context, transaction),

                    ),

                  ],)      ,


              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AppImages.noData, width: 150, height: 150),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              final customer = context
                  .read<CustomerLedgerBloc>()
                  .selectedCustomer;
              if (customer != null) {
                _fetchCustomerLedger(customer: customer.id.toString());
              }
            },
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
            "Error Loading Transactions",
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
            onPressed: () {
              final customer = context
                  .read<CustomerLedgerBloc>()
                  .selectedCustomer;
              if (customer != null) {
                _fetchCustomerLedger(customer: customer.id.toString());
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    CustomerLedgerTransaction transaction,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
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
                    'Transaction Details',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.text(context),

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.text(context)),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Transaction Details
              _buildDetailRow('Voucher No:', transaction.voucherNo, context),
              _buildDetailRow('Date:', _formatDate(transaction.date), context),
              _buildDetailRow('Type:', transaction.type.toUpperCase(), context),
              _buildDetailRow('Particular:', transaction.particular, context),
              _buildDetailRow('Details:', transaction.details, context),
              _buildDetailRow('Payment Method:', transaction.method, context),
              _buildDetailRow(
                'Debit Amount:',
                _formatCurrency(transaction.debit),
                context,
              ),
              _buildDetailRow(
                'Credit Amount:',
                _formatCurrency(transaction.credit),
                context,
              ),
              _buildDetailRow(
                'Balance:',
                _formatCurrency(transaction.due),
                context,
              ),

              // Type Badge
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: transaction.typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: transaction.typeColor),
                ),
                child: Row(
                  children: [
                    Icon(transaction.typeIcon, color: transaction.typeColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Transaction Type: ${transaction.type}',
                        style: TextStyle(
                          color: transaction.typeColor,
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

  Widget _buildDetailRow(String label, String value, BuildContext context) {
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
                color: AppColors.text(context),

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
    final state = context.read<CustomerLedgerBloc>().state;
    if (state is CustomerLedgerSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Customer Ledger PDF'),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            body: PdfPreview(
              build: (format) =>
                  generateCustomerLedgerReportPdf(state.response),
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
          content: Text('No customer ledger data available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
