import 'package:flutter/material.dart';
import 'package:meherinMart/core/widgets/app_data_table.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';
import '../../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '/core/configs/app_colors.dart';
import '/core/configs/app_images.dart';
import '/core/configs/app_text.dart';
import '/desktop/widgets/sidebar.dart';
import '/core/widgets/app_button.dart';
import '/core/widgets/app_dropdown.dart';
import '/core/widgets/date_range.dart';
import '/feature/customer/data/model/customer_active_model.dart';
import '/feature/customer/presentation/bloc/customer/customer_bloc.dart';
import '/feature/report/presentation/shared/customer_ledger_screen/pdf.dart';

import '../../../../../core/configs/app_routes.dart';
import '../../../../../responsive.dart';
import '../../../data/model/customer_ledger_model.dart';
import '../../bloc/customer_ledger_bloc/customer_ledger_bloc.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

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
                hint:  "Select Customer",
                isNeedAll: false,
                isRequired: true,
                isLabel: false,
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
              );
            },
          ),
        ),
        const SizedBox(width: 8),

        // 📅 Date Range Picker
        SizedBox(
          width: 270,
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
            padding: const EdgeInsets.all(8),
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
                    Icons.people_outline,
                    size: 45,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
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
                color: Colors.grey.withValues(alpha: 0.1),
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
                  _buildSummaryItem("Opening Balance", openingBalance.toStringAsFixed(2), Icons.account_balance_wallet, AppColors.info),
                  _buildSummaryItem(
                      "Closing Balance",
                      summary.closingBalance.toStringAsFixed(2),
                      summary.closingBalance >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      summary.closingBalance >= 0 ? AppColors.success : AppColors.danger
                  ),
                  _buildSummaryItem("Total Debit", totalDebit.toStringAsFixed(2), Icons.arrow_downward, AppColors.danger),
                  _buildSummaryItem("Total Credit", totalCredit.toStringAsFixed(2), Icons.arrow_upward, AppColors.success),
                  _buildSummaryItem("Sales Transactions", salesCount.toString(), Icons.shopping_cart, AppColors.warning),
                  _buildSummaryItem("Payment Transactions", paymentsCount.toString(), Icons.payment, Colors.purple),
                  _buildSummaryItem("Total Transactions", summary.totalTransactions.toString(), Icons.receipt, AppColors.primaryColor(context)),
                  AppButton(
                      size: 80,
                      name: "Pdf", onPressed: (){
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
                            build: (format) => generateCustomerLedgerReportPdf(
                             state.response,context.read<ProfileBloc>().permissionModel?.data?.companyInfo

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
                                icon: const Icon(Icons.cancel, color: AppColors.danger),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
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
          const Icon(Icons.error_outline, size: 60, color: AppColors.danger),
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
            style: const TextStyle(fontSize: 14, color: AppColors.danger),
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
  // Desktop টেবিল — AppDataTable
  // Ledger: Debit লাল, Credit সবুজ, Balance ডানে — হিসাবের খাতার মতো
  Widget build(BuildContext context) {
    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 52),
      AppTableColumn('Date', flex: 2, minWidth: 100),
      AppTableColumn('Voucher', flex: 2, minWidth: 110),
      AppTableColumn.center('Type', flex: 2, minWidth: 110),
      AppTableColumn('Particular', flex: 3, minWidth: 150),
      AppTableColumn('Method', flex: 2, minWidth: 90),
      AppTableColumn.numeric('Debit', flex: 2, minWidth: 100),
      AppTableColumn.numeric('Credit', flex: 2, minWidth: 100),
      AppTableColumn.numeric('Balance', flex: 2, minWidth: 110),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: transactions.length,
      onRowTap: onTransactionTap == null ? null : (_) => onTransactionTap!(),
      cellBuilder: (context, row, col) {
        final t = transactions[row];
        final muted = AppColors.text(context).withValues(alpha: 0.4);
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(_formatDate(t.date));
          case 2:
            return AppTableText(t.voucherNo,
                bold: true, color: AppColors.primaryColor(context));
          case 3:
            return AppStatusPill(t.type, color: t.typeColor);
          case 4:
            return AppTableText(t.particular, subtitle: t.details);
          case 5:
            return AppTableText(t.method, muted: true);
          case 6:
            return t.debit > 0
                ? AppTableMoney(t.debit, color: AppColors.danger)
                : AppTableText('-', align: AppCellAlign.end, color: muted);
          case 7:
            return t.credit > 0
                ? AppTableMoney(t.credit, color: AppColors.success)
                : AppTableText('-', align: AppCellAlign.end, color: muted);
          default:
            return AppTableMoney(t.due.abs(),
                bold: true,
                color: t.due >= 0 ? AppColors.danger : AppColors.success);
        }
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}