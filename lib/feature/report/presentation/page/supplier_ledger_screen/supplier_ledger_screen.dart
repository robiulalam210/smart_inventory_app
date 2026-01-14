import 'package:flutter/material.dart';
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
import '/core/shared/widgets/sideMenu/sidebar.dart';
import '/core/widgets/app_button.dart';
import '/core/widgets/app_dropdown.dart';
import '/core/widgets/date_range.dart';
import '/feature/report/presentation/page/supplier_ledger_screen/pdf.dart';
import '/feature/supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';

import '../../../../../core/configs/app_routes.dart';
import '../../../../../responsive.dart';
import '../../../../supplier/data/model/supplier_active_model.dart';
import '../../../data/model/supplier_ledger_model.dart';
import '../../bloc/supplier_ledger_bloc/supplier_ledger_bloc.dart';

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
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  isLabel: true,
                  itemList: [],
                  onChanged: (v){},
                );
              }

              if (state is SupplierActiveListFailed) {
                return AppDropdown<SupplierActiveModel>(
                  label: "Supplier",
                  hint: "Failed to load suppliers",
                  isRequired: false,   isLabel: true,
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
                  isRequired: false,   isLabel: true,
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
                  _buildSummaryItem("Opening Balance", "\$${summary.openingBalance.toStringAsFixed(2)}", Icons.account_balance_wallet, Colors.blue),
                  _buildSummaryItem(
                      "Closing Balance",
                      "\$${summary.closingBalance.toStringAsFixed(2)}",
                      summary.closingBalance > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      summary.closingBalance > 0 ? Colors.red : Colors.green,
                      // subtitle: summary.closingBalance > 0 ? 'Due' : 'Advance'
                  ),
                  _buildSummaryItem("Total Debit", "\$${summary.totalDebit.toStringAsFixed(2)}", Icons.arrow_circle_up, Colors.red),
                  _buildSummaryItem("Total Credit", "\$${summary.totalCredit.toStringAsFixed(2)}", Icons.arrow_circle_down, Colors.green),
                  _buildSummaryItem("Total Transactions", summary.totalTransactions.toString(), Icons.receipt_long, Colors.purple),


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
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
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
            style: const TextStyle(fontSize: 14, color: Colors.red),
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
  Widget build(BuildContext context) {
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 11; // #, Date, Voucher No, Type, Particular, Details, Method, Debit, Credit, Balance, Actions
        const minColumnWidth = 100.0;

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
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
                          headingRowColor: WidgetStateProperty.all(
                            AppColors.primaryColor(context),
                          ),
                          dataTextStyle: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: ledgers.asMap().entries.map((entry) {
                            final ledger = entry.value;
                            return DataRow(
                              onSelectChanged: onLedgerTap != null
                                  ? (_) => onLedgerTap!()
                                  : null,
                              cells: [
                                _buildIndexCell(entry.key + 1, dynamicColumnWidth * 0.6),
                                _buildDateCell(ledger.date, dynamicColumnWidth),
                                _buildVoucherCell(ledger.voucherNo, dynamicColumnWidth),
                                _buildTypeCell(ledger, dynamicColumnWidth),
                                _buildParticularCell(ledger.particular, dynamicColumnWidth),
                                _buildDetailsCell(ledger.details, dynamicColumnWidth),
                                _buildMethodCell(ledger.method, dynamicColumnWidth),
                                _buildDebitCell(ledger.debit, dynamicColumnWidth),
                                _buildCreditCell(ledger.credit, dynamicColumnWidth),
                                _buildBalanceCell(ledger.due, dynamicColumnWidth),
                                _buildActionCell(ledger, context, dynamicColumnWidth),
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
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Actions', textAlign: TextAlign.center),
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

  DataCell _buildTypeCell(SupplierLedger ledger, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: ledger.typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(ledger.typeIcon, size: 12, color: ledger.typeColor),
                const SizedBox(width: 4),
                Text(
                  ledger.type,
                  style: TextStyle(
                    color: ledger.typeColor,
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
              color: Colors.red.withValues(alpha: 0.1),
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
              color: Colors.green.withValues(alpha: 0.1),
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
    final isPositive = balance > 0;

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isPositive ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
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

  DataCell _buildActionCell(SupplierLedger ledger, BuildContext context, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // View Details Button
            _buildActionButton(
              icon: HugeIcons.strokeRoundedView,
              color: Colors.blue,
              tooltip: 'View transaction details',
              onPressed: () => _showTransactionDetails(context, ledger),
            ),

            // Payment Button (if balance is positive/owed)
            if (ledger.due > 0)
              _buildActionButton(
                icon: Iconsax.money_send,
                color: Colors.orange,
                tooltip: 'Make payment',
                onPressed: () => _makePayment(context, ledger),
              ),
          ],
        ),
      ),
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
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
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
                _buildDetailRow('Debit:', '\$${ledger.debit.toStringAsFixed(2)}'),
                _buildDetailRow('Credit:', '\$${ledger.credit.toStringAsFixed(2)}'),
                _buildDetailRow('Balance:', '\$${ledger.due.toStringAsFixed(2)}'),

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