import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_inventory/core/configs/app_colors.dart';
import 'package:smart_inventory/core/configs/app_images.dart';
import 'package:smart_inventory/core/configs/app_text.dart';
import 'package:smart_inventory/core/shared/widgets/sideMenu/sidebar.dart';
import 'package:smart_inventory/core/widgets/app_button.dart';
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
  }

  void _fetchCustomerLedger({
    required String customer,
    DateTime? from,
    DateTime? to,
  }) {
    if (customer.isEmpty) return;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterRow(),
              _buildCustomerSummary(),
              const SizedBox(height: 12),
              SizedBox(child: _buildLedgerTable()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 👤 Customer Dropdown
        SizedBox(
          width: 220,

          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              return AppDropdown<CustomerActiveModel>(
                label: "Customer",
                context: context,
                isSearch: true,
                hint: context.read<CustomerLedgerBloc>().selectedCustomer?.name ?? "Select Customer",
                isNeedAll: false,
                isRequired: true,
                isLabel: true,
                value: context.read<CustomerLedgerBloc>().selectedCustomer,
                itemList: context.read<CustomerBloc>().activeCustomer,
                onChanged: (newVal) {
                  if (newVal != null) {
                    context.read<CustomerLedgerBloc>().selectedCustomer = newVal;
                    _fetchCustomerLedger(
                      customer: newVal.id.toString(),
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
        const SizedBox(width: 12),

        // 📅 Date Range Picker
        SizedBox(
          width: 260,
          child: CustomDateRangeField(
            isLabel: false,
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
        const SizedBox(width: 12),

        AppButton(name: "Clear", onPressed: (){
          setState(() => selectedDateRange = null);
          context.read<CustomerLedgerBloc>().add(ClearCustomerLedgerFilters());
        }),
        // Clear Filters Button


      ],
    );
  }

  Widget _buildCustomerSummary() {
    return BlocBuilder<CustomerLedgerBloc, CustomerLedgerState>(
      builder: (context, state) {
        if (state is! CustomerLedgerSuccess) {
          return Container(
            padding: const EdgeInsets.all(10),
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
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Select a Customer to View Ledger",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choose a customer from the dropdown above to see their transaction history",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
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
        final transactions = state.response.report;

        // Calculate additional metrics
        final openingBalance = _calculateOpeningBalance(transactions);
        final totalDebit = transactions.fold(0.0, (sum, t) => sum + t.debit);
        final totalCredit = transactions.fold(0.0, (sum, t) => sum + t.credit);
        final salesCount = transactions.where((t) => t.type.toLowerCase() == 'sale').length;
        final paymentsCount = transactions.where((t) => t.type.toLowerCase() == 'payment').length;

        return Container(
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
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSummaryItem("Opening Balance", "\$${openingBalance.toStringAsFixed(2)}", Icons.account_balance_wallet, Colors.blue),
                  _buildSummaryItem(
                      "Closing Balance",
                      "\$${summary.closingBalance.toStringAsFixed(2)}",
                      summary.closingBalance >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      summary.closingBalance >= 0 ? Colors.green : Colors.red
                  ),
                  _buildSummaryItem("Total Debit", "\$${totalDebit.toStringAsFixed(2)}", Icons.arrow_downward, Colors.red),
                  _buildSummaryItem("Total Credit", "\$${totalCredit.toStringAsFixed(2)}", Icons.arrow_upward, Colors.green),
                  _buildSummaryItem("Sales Transactions", salesCount.toString(), Icons.shopping_cart, Colors.orange),
                  _buildSummaryItem("Payment Transactions", paymentsCount.toString(), Icons.payment, Colors.purple),
                  _buildSummaryItem("Total Transactions", summary.totalTransactions.toString(), Icons.receipt, AppColors.primaryColor),
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

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
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
            return _buildEmptyState("No ledger transactions found for the selected period");
          }
          return CustomerLedgerTableCard(transactions: state.response.report);
        } else if (state is CustomerLedgerFailed) {
          return _buildErrorState(state.content);
        }
        return _buildEmptyState("Select a customer to view ledger transactions");
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AppImages.noData, width: 200, height: 200),
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
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            "Error Loading Customer Ledger",
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
}

class CustomerLedgerTableCard extends StatelessWidget {
  final List<CustomerLedgerTransaction> transactions;
  final VoidCallback? onTransactionTap;

  const CustomerLedgerTableCard({
    super.key,
    required this.transactions,
    this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 10; // #, Date, Voucher No, Type, Particular, Details, Method, Debit, Credit, Balance
        const minColumnWidth = 100.0;

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
                          rows: transactions.asMap().entries.map((entry) {
                            final transaction = entry.value;
                            return DataRow(
                              onSelectChanged: onTransactionTap != null
                                  ? (_) => onTransactionTap!()
                                  : null,
                              cells: [
                                _buildIndexCell(entry.key + 1, dynamicColumnWidth * 0.6),
                                _buildDateCell(transaction.date, dynamicColumnWidth),
                                _buildVoucherCell(transaction.voucherNo, dynamicColumnWidth),
                                _buildTypeCell(transaction, dynamicColumnWidth),
                                _buildParticularCell(transaction.particular, dynamicColumnWidth),
                                _buildDetailsCell(transaction.details, dynamicColumnWidth),
                                _buildMethodCell(transaction.method, dynamicColumnWidth),
                                _buildDebitCell(transaction.debit, dynamicColumnWidth),
                                _buildCreditCell(transaction.credit, dynamicColumnWidth),
                                _buildBalanceCell(transaction.due, dynamicColumnWidth),
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
          child: const Text('Date', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Voucher No', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Type', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Particular', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth * 1.2,
          child: const Text('Details', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Method', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Debit', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Credit', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Balance', textAlign: TextAlign.center),
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

  DataCell _buildDateCell(DateTime date, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          _formatDate(date),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  DataCell _buildVoucherCell(String voucherNo, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          voucherNo,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  DataCell _buildTypeCell(CustomerLedgerTransaction transaction, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: transaction.typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(transaction.typeIcon, size: 12, color: transaction.typeColor),
                const SizedBox(width: 4),
                Text(
                  transaction.type,
                  style: TextStyle(
                    color: transaction.typeColor,
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

  DataCell _buildParticularCell(String particular, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          particular,
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

  DataCell _buildDetailsCell(String details, double width) {
    return DataCell(
      Tooltip(
        message: details,
        child: SizedBox(
          width: width,
          child: Text(
            details.length > 30 ? '${details.substring(0, 30)}...' : details,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  DataCell _buildMethodCell(String method, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          method,
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

  DataCell _buildDebitCell(double debit, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: debit > 0
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '\$${debit.toStringAsFixed(2)}',
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

  DataCell _buildCreditCell(double credit, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: credit > 0
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '\$${credit.toStringAsFixed(2)}',
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

  DataCell _buildBalanceCell(double balance, double width) {
    final isPositive = balance >= 0;

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isPositive ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isPositive ? Colors.red : Colors.green,
              ),
            ),
            child: Text(
              '\$${balance.abs().toStringAsFixed(2)}',
              style: TextStyle(
                color: isPositive ? Colors.red : Colors.green,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}