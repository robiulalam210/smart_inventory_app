import 'package:flutter/material.dart';
import 'package:meherinMart/core/widgets/app_data_table.dart';
import 'package:meherinMart/core/widgets/app_popover_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';
import '/core/configs/app_colors.dart';
import '/core/configs/app_images.dart';
import '/core/configs/app_text.dart';
import '/desktop/widgets/sidebar.dart';
import '/core/widgets/app_button.dart';
import '/core/widgets/app_dropdown.dart';
import '/core/widgets/date_range.dart';
import '/feature/report/presentation/shared/supplier_ledger_screen/pdf.dart';
import '/feature/supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';

import '../../../../../core/configs/app_routes.dart';
import '../../../../../responsive.dart';
import '../../../../supplier/data/model/supplier_active_model.dart';
import '../../../data/model/supplier_ledger_model.dart';
import '../../bloc/supplier_ledger_bloc/supplier_ledger_bloc.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

class SupplierLedgerScreen extends StatefulWidget {
  const SupplierLedgerScreen({super.key});

  @override
  State<SupplierLedgerScreen> createState() => _SupplierLedgerScreenState();
}

class _SupplierLedgerScreenState extends State<SupplierLedgerScreen> {
  SupplierActiveModel? _selectedSupplier;
  DateRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    context.read<SupplierInvoiceBloc>().add(FetchSupplierActiveList(context));
    _fetchApi();
  }

  void _fetchApi({
    String? supplier,
    DateTime? from,
    DateTime? to,
  }) {
    context.read<SupplierLedgerBloc>().add(FetchSupplierLedgerReport(
      context: context,
      supplierId: supplier != null ? int.tryParse(supplier) : null,
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
        onRefresh: () async => _fetchApi(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 4),
              _buildFilterRow(),
              _buildSummaryCards(),
              const SizedBox(height: 4),
              SizedBox(child: _buildLedgerTable()),
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
              "Supplier Ledger Report",
              style: AppTextStyle.cardTitle(context).copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Monitor supplier transactions and balances",
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
      crossAxisAlignment: CrossAxisAlignment.end,
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
                  supplier: _selectedSupplier?.id?.toString(),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 12),

        // 👥 Supplier Dropdown
        SizedBox(
          width: 220,
          child: BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
            builder: (context, state) {
              if (state is SupplierActiveListLoading) {
                return AppDropdown<SupplierActiveModel>(
                  label: "Supplier",
                  hint: "Loading suppliers...",
                  isRequired: false,
                  isLabel: false,
                  itemList: [],
                  onChanged: (v){},
                );
              }

              if (state is SupplierActiveListFailed) {
                return AppDropdown<SupplierActiveModel>(
                  label: "Supplier",
                  hint: "Failed to load suppliers",
                  isRequired: false,   isLabel: false,
                  itemList: [],
                  onChanged: (v){},
                );
              }

              if (state is SupplierActiveListSuccess) {
                final supplierList = context.read<SupplierInvoiceBloc>().supplierActiveList;

                final List<SupplierActiveModel> options = [

                  ...supplierList,
                ];

                return AppDropdown<SupplierActiveModel>(
                  label: "Supplier",
                  hint: "Select Supplier",
                  isRequired: false,   isLabel: false,
                  value: _selectedSupplier,
                  itemList: options,
                  onChanged: (newVal) {
                    setState(() {
                      _selectedSupplier = newVal;
                    });
                    _fetchApi(
                      supplier: newVal?.id?.toString(),
                      from: selectedDateRange?.start,
                      to: selectedDateRange?.end,
                    );
                  },
                );
              }

              return AppDropdown<SupplierActiveModel>(
                label: "Supplier",
                hint: "Loading suppliers...",
                isRequired: false,
                itemList: [],
                onChanged: (v){},
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        AppButton(name: "Clear", onPressed: (){
          setState(() {
            selectedDateRange = null;
            _selectedSupplier = null;
          });
          context.read<SupplierLedgerBloc>().add(ClearSupplierLedgerFilters());
          _fetchApi();
        }),
        // 🧹 Clear Filters Button

      ],
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<SupplierLedgerBloc, SupplierLedgerState>(
      builder: (context, state) {
        if (state is! SupplierLedgerSuccess) {
          return Container(
            padding: const EdgeInsets.all(10),
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
                    Icons.business_outlined,
                    size: 48,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Select a Supplier to View Ledger",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choose a supplier from the dropdown above to see their transaction history",
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

        return Container(
          padding: const EdgeInsets.all(10),
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
                "Supplier: ${_selectedSupplier?.name ?? summary.supplierName}",
                style: AppTextStyle.cardTitle(context).copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildSummaryItem("Opening Balance", summary.openingBalance.toStringAsFixed(2), Icons.account_balance_wallet, AppColors.info),
                  _buildSummaryItem(
                      "Closing Balance",
                      summary.closingBalance.toStringAsFixed(2),
                      summary.closingBalance > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      summary.closingBalance > 0 ? AppColors.danger : AppColors.success,
                      // subtitle: summary.closingBalance > 0 ? 'Due' : 'Advance'
                  ),
                  _buildSummaryItem("Total Debit", summary.totalDebit.toStringAsFixed(2), Icons.arrow_circle_up, AppColors.danger),
                  _buildSummaryItem("Total Credit", summary.totalCredit.toStringAsFixed(2), Icons.arrow_circle_down, AppColors.success),
                  _buildSummaryItem("Total Transactions", summary.totalTransactions.toString(), Icons.receipt_long, Colors.purple),


                  AppButton(
                      size: 100,
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
                            build: (format) => generateSupplierLedgerReportPdf(
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

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerTable() {
    return BlocBuilder<SupplierLedgerBloc, SupplierLedgerState>(
      builder: (context, state) {
        if (state is SupplierLedgerLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading supplier ledger report..."),
              ],
            ),
          );
        } else if (state is SupplierLedgerSuccess) {
          if (state.response.report.isEmpty) {
            return _buildEmptyState();
          }
          return SupplierLedgerTableCard(ledgers: state.response.report);
        } else if (state is SupplierLedgerFailed) {
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
            "No Supplier Ledger Data Found",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Supplier ledger data will appear here when available",
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
          const Icon(Icons.error_outline, size: 60, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(
            "Error Loading Supplier Ledger Report",
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
          ElevatedButton(
            onPressed: _fetchApi,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

class SupplierLedgerTableCard extends StatelessWidget {
  final List<SupplierLedger> ledgers;
  final VoidCallback? onLedgerTap;

  const SupplierLedgerTableCard({
    super.key,
    required this.ledgers,
    this.onLedgerTap,
  });

  @override
  // Desktop টেবিল — AppDataTable
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
      AppTableColumn.center('Actions', flex: 1, minWidth: 90),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: ledgers.length,
      onRowTap: onLedgerTap == null ? null : (_) => onLedgerTap!(),
      cellBuilder: (context, row, col) {
        final l = ledgers[row];
        final muted = AppColors.text(context).withValues(alpha: 0.4);
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(_formatDate(l.date));
          case 2:
            return AppTableText(l.voucherNo,
                bold: true, color: AppColors.primaryColor(context));
          case 3:
            return AppStatusPill(l.type, color: l.typeColor);
          case 4:
            return AppTableText(l.particular, subtitle: l.details);
          case 5:
            return AppTableText(l.method, muted: true);
          case 6:
            return l.debit > 0
                ? AppTableMoney(l.debit, color: AppColors.danger)
                : AppTableText('-', align: AppCellAlign.end, color: muted);
          case 7:
            return l.credit > 0
                ? AppTableMoney(l.credit, color: AppColors.success)
                : AppTableText('-', align: AppCellAlign.end, color: muted);
          case 8:
            return AppTableMoney(l.due.abs(),
                bold: true,
                color: l.due > 0 ? AppColors.danger : AppColors.success);
          default:
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTableAction(
                  icon: Icons.visibility_outlined,
                  tooltip: 'Details',
                  color: AppColors.info,
                  onPressed: () => _showTransactionDetails(context, l),
                ),
                if (l.due > 0)
                  AppTableAction(
                    icon: Icons.payments_outlined,
                    tooltip: 'Make payment',
                    color: AppColors.warning,
                    onPressed: () => _makePayment(context, l),
                  ),
              ],
            );
        }
      },
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

  void _showTransactionDetails(BuildContext context, SupplierLedger ledger) {
    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverShell(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.40,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Transaction Details",
                  style: AppTextStyle.cardLevelHead(context),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Voucher No:', ledger.voucherNo),
                _buildDetailRow('Date:', _formatDate(ledger.date)),
                _buildDetailRow('Type:', ledger.type),
                _buildDetailRow('Particular:', ledger.particular),
                _buildDetailRow('Details:', ledger.details),
                _buildDetailRow('Method:', ledger.method),
                _buildDetailRow('Debit:', ledger.debit.toStringAsFixed(2)),
                _buildDetailRow('Credit:', ledger.credit.toStringAsFixed(2)),
                _buildDetailRow('Balance:', ledger.due.toStringAsFixed(2)),

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
            width: 100,
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

  void _makePayment(BuildContext context, SupplierLedger ledger) {
    // Implement payment functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Making payment for voucher ${ledger.voucherNo}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}