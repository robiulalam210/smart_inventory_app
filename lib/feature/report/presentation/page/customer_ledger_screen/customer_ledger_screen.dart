import 'dart:async';
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
import 'package:smart_inventory/feature/customer/presentation/bloc/customer/customer_bloc.dart';

import '../../../../../responsive.dart';
import '../../../data/model/customer_ledger_model.dart';
import '../../bloc/customer_ledger_bloc/customer_ledger_bloc.dart';

class CustomerLedgerScreen extends StatefulWidget {
  const CustomerLedgerScreen({super.key});

  @override
  State<CustomerLedgerScreen> createState() => _CustomerLedgerScreenState();
}

class _CustomerLedgerScreenState extends State<CustomerLedgerScreen> {
  DateRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(FetchCustomerActiveList(context));
    // Don't fetch ledger initially - wait for customer selection
  }

  void _fetchCustomerLedger({
    required String customer, // Make customer required
    DateTime? from,
    DateTime? to,
  }) {
    if (customer.isEmpty) {
      print('⚠️ No customer selected for ledger report');
      return;
    }

    print('🔍 Fetching ledger for customer: $customer');
    context.read<CustomerLedgerBloc>().add(FetchCustomerLedger(
      context: context,
      customer: customer,
      from: from,
      to: to,
    ));
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
        onRefresh: () async {
          final customer = context.read<CustomerLedgerBloc>().selectedCustomer;
          if (customer != null) {
            _fetchCustomerLedger(customer: customer.id.toString());
          }
        },
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            children: [
              _buildFilterRow(),
              const SizedBox(height: 16),
              _buildCustomerSummary(),
              const SizedBox(height: 16),
              _buildLedgerTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 👤 Customer Dropdown
        Expanded(
          flex: 1,
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              return AppDropdown<CustomerActiveModel>(
                label: "Customer",
                context: context,
                isSearch: true,
                hint: context.read<CustomerLedgerBloc>().selectedCustomer?.name ?? "Select Customer",
                isNeedAll: true,
                isRequired: true,
                value: context.read<CustomerLedgerBloc>().selectedCustomer,
                itemList: context.read<CustomerBloc>().activeCustomer,
                onChanged: (newVal) {
                  print('Customer selected for ledger: ${newVal?.id} - ${newVal?.name}');

                  if (newVal != null) {
                    // Update CustomerLedgerBloc state
                    context.read<CustomerLedgerBloc>().selectedCustomer = newVal;

                    // Fetch customer ledger with the selected customer
                    _fetchCustomerLedger(
                      customer: newVal.id.toString(), // This is now required
                      from: selectedDateRange?.start,
                      to: selectedDateRange?.end,
                    );
                  }
                },
                validator: (value) {
                  return value == null ? 'Please select Customer' : null;
                },
                itemBuilder: (item) => DropdownMenuItem<CustomerActiveModel>(
                  value: item,
                  child: Text(
                    item.name ?? 'Unknown Customer',
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
        const SizedBox(width: 5),

        // 📅 Date Range Picker
        SizedBox(
          width: 260,
          child: CustomDateRangeField(
            selectedDateRange: selectedDateRange,
            onDateRangeSelected: (value) {
              setState(() => selectedDateRange = value);
              final customer = context.read<CustomerLedgerBloc>().selectedCustomer;
              if (value != null && customer != null) {
                _fetchCustomerLedger(
                  customer: customer.id.toString(),
                  from: value.start,
                  to: value.end,
                );
              }
            },
          ),
        ),
        const SizedBox(width: 5),

        // Clear Filters Button
        ElevatedButton.icon(
          onPressed: () {
            setState(() => selectedDateRange = null);
            context.read<CustomerLedgerBloc>().add(ClearCustomerLedgerFilters());
            // Don't fetch after clear - wait for customer selection
          },
          icon: const Icon(Icons.clear_all),
          label: const Text("Clear"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.grey,
            foregroundColor: AppColors.blackColor,
          ),
        ),
        const SizedBox(width: 5),

        // Refresh Button
        BlocBuilder<CustomerLedgerBloc, CustomerLedgerState>(
          builder: (context, state) {
            final customer = context.read<CustomerLedgerBloc>().selectedCustomer;
            return IconButton(
              onPressed: customer != null
                  ? () => _fetchCustomerLedger(customer: customer.id.toString())
                  : null,
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh",
            );
          },
        ),
      ],
    );
  }

  Widget _buildCustomerSummary() {
    return BlocBuilder<CustomerLedgerBloc, CustomerLedgerState>(
      builder: (context, state) {
        if (state is! CustomerLedgerSuccess) {
          return Container(
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
            child: Center(
              child: Text(
                "Select a customer to view ledger",
                style: AppTextStyle.cardTitle(context).copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        final summary = state.response.summary;
        final transactions = state.response.report;

        // Calculate additional metrics
        final openingBalance = _calculateOpeningBalance(transactions);
        final totalDebit = transactions.fold(0.0, (sum, t) => sum + t.debit);
        final totalCredit = transactions.fold(0.0, (sum, t) => sum + t.credit);
        final salesCount = transactions.where((t) => t.type.toLowerCase() == 'sale').length;
        final paymentsCount = transactions.where((t) => t.type.toLowerCase() == 'payment').length;

        return Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Customer: ${summary.customerName}",
                style: AppTextStyle.cardTitle(context).copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _buildSummaryItem("Opening Balance", "\$${openingBalance.toStringAsFixed(2)}", Icons.account_balance_wallet),
                  _buildSummaryItem("Closing Balance", "\$${summary.closingBalance.toStringAsFixed(2)}",
                      summary.closingBalance >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: summary.closingBalance >= 0 ? Colors.green : Colors.red
                  ),
                  _buildSummaryItem("Total Debit", "\$${totalDebit.toStringAsFixed(2)}", Icons.arrow_downward, color: Colors.red),
                  _buildSummaryItem("Total Credit", "\$${totalCredit.toStringAsFixed(2)}", Icons.arrow_upward, color: Colors.green),
                  _buildSummaryItem("Sales Transactions", salesCount.toString(), Icons.shopping_cart),
                  _buildSummaryItem("Payment Transactions", paymentsCount.toString(), Icons.payment),
                  _buildSummaryItem("Total Transactions", summary.totalTransactions.toString(), Icons.receipt),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateOpeningBalance(List<CustomerLedgerTransaction> transactions) {
    if (transactions.isEmpty) return 0.0;
    final firstTransaction = transactions.first;
    return firstTransaction.due - (firstTransaction.debit - firstTransaction.credit);
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, {Color color = AppColors.primaryColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
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
        ],
      ),
    );
  }

  Widget _buildLedgerTable() {
    return BlocBuilder<CustomerLedgerBloc, CustomerLedgerState>(
      builder: (context, state) {
        if (state is CustomerLedgerLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading customer ledger..."),
              ],
            ),
          );
        } else if (state is CustomerLedgerSuccess) {
          if (state.response.report.isEmpty) {
            return _noDataWidget("No ledger transactions found for the selected period");
          }
          return CustomerLedgerDataTableWidget(transactions: state.response.report);
        } else if (state is CustomerLedgerFailed) {
          return _errorWidget(state.content);
        }
        return _noDataWidget("Select a customer to view ledger transactions");
      },
    );
  }

  Widget CustomerLedgerDataTableWidget({required List<CustomerLedgerTransaction> transactions}) {
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
            DataColumn(label: Text('Voucher No', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Particular', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Details', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Method', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Debit', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('Credit', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
            DataColumn(label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
          ],
          rows: transactions.asMap().entries.map((entry) {
            final index = entry.key;
            final transaction = entry.value;

            return DataRow(
              color: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return index % 2 == 0 ? Colors.grey.withOpacity(0.05) : Colors.transparent;
                },
              ),
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(transaction.date.toString().split(' ')[0])),
                DataCell(
                  Text(
                    transaction.voucherNo,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: transaction.typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(transaction.typeIcon, size: 14, color: transaction.typeColor),
                        const SizedBox(width: 4),
                        Text(
                          transaction.type,
                          style: TextStyle(
                            color: transaction.typeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(Text(transaction.particular)),
                DataCell(
                  Tooltip(
                    message: transaction.details,
                    child: Text(
                      transaction.details.length > 30
                          ? '${transaction.details.substring(0, 30)}...'
                          : transaction.details,
                    ),
                  ),
                ),
                DataCell(Text(transaction.method)),
                DataCell(
                  transaction.debit > 0
                      ? Text(
                    '\$${transaction.debit.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  )
                      : const Text('-'),
                ),
                DataCell(
                  transaction.credit > 0
                      ? Text(
                    '\$${transaction.credit.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  )
                      : const Text('-'),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: transaction.due >= 0 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: transaction.due >= 0 ? Colors.red : Colors.green,
                      ),
                    ),
                    child: Text(
                      '\$${transaction.due.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: transaction.due >= 0 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
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
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        BlocBuilder<CustomerLedgerBloc, CustomerLedgerState>(
          builder: (context, state) {
            final customer = context.read<CustomerLedgerBloc>().selectedCustomer;
            return ElevatedButton(
              onPressed: customer != null
                  ? () => _fetchCustomerLedger(customer: customer.id.toString())
                  : null,
              child: const Text("Refresh"),
            );
          },
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
        Text(
          "Error: $error",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        BlocBuilder<CustomerLedgerBloc, CustomerLedgerState>(
          builder: (context, state) {
            final customer = context.read<CustomerLedgerBloc>().selectedCustomer;
            return ElevatedButton(
              onPressed: customer != null
                  ? () => _fetchCustomerLedger(customer: customer.id.toString())
                  : null,
              child: const Text("Retry"),
            );
          },
        ),
      ],
    ),
  );
}