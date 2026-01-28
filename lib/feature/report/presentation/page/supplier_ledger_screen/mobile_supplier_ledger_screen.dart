import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:meherinMart/core/configs/app_text.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:printing/printing.dart';
import '../../../../../core/widgets/app_button.dart';
import '/core/configs/app_colors.dart';
import '/core/configs/app_images.dart';
import '/core/widgets/app_dropdown.dart';
import '/core/widgets/date_range.dart';
import '/feature/report/presentation/page/supplier_ledger_screen/pdf.dart';
import '/feature/supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';

import '../../../../supplier/data/model/supplier_active_model.dart';
import '../../../data/model/supplier_ledger_model.dart';
import '../../bloc/supplier_ledger_bloc/supplier_ledger_bloc.dart';

class MobileSupplierLedgerScreen extends StatefulWidget {
  const MobileSupplierLedgerScreen({super.key});

  @override
  State<MobileSupplierLedgerScreen> createState() =>
      _MobileSupplierLedgerScreenState();
}

class _MobileSupplierLedgerScreenState
    extends State<MobileSupplierLedgerScreen> {
  SupplierActiveModel? _selectedSupplier;
  DateRange? selectedDateRange;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    context.read<SupplierInvoiceBloc>().add(FetchSupplierActiveList(context));
    _fetchApi();
  }

  void _fetchApi({String? supplier, DateTime? from, DateTime? to}) {
    context.read<SupplierLedgerBloc>().add(
      FetchSupplierLedgerReport(
        context: context,
        supplierId: supplier != null ? int.tryParse(supplier) : null,
        from: from,
        to: to,
      ),
    );
  }

  String _formatCurrency(double value) => value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Supplier Ledger',
          style: AppTextStyle.titleMedium(context),
        ),
        actions: [
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedPdf02, color: AppColors.text(context)),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedReload, color: AppColors.text(context)),
            onPressed: () => _fetchApi(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchApi(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter Section
              _buildMobileFilterSection(),
              const SizedBox(height: 8),

              // Supplier Summary
              _buildSupplierSummary(),
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
          _isFilterExpanded ? HugeIcons.strokeRoundedFilterRemove:HugeIcons.strokeRoundedFilter,
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
          // --- Header with toggle ---
          InkWell(
            onTap: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(HugeIcons.strokeRoundedFilter, color: AppColors.text(context)),
                  const SizedBox(width: 8),
                  Text('Filters', style: AppTextStyle.body(context)),
                  const Spacer(),
                  // Custom arrow
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

          // --- Expandable body ---
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Date Range Picker
                  CustomDateRangeField(
                    isLabel: true,
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
                  const SizedBox(height: 8),

                  // Supplier Dropdown
                  BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
                    builder: (context, state) {
                      if (state is SupplierActiveListLoading) {
                        return AppDropdown<SupplierActiveModel>(
                          label: "Supplier",
                          hint: "Loading suppliers...",
                          isLabel: true,
                          itemList: const [],
                          onChanged: (v) {},
                        );
                      }

                      if (state is SupplierActiveListFailed) {
                        return AppDropdown<SupplierActiveModel>(
                          label: "Supplier",
                          hint: "Failed to load suppliers",
                          isLabel: true,
                          itemList: const [],
                          onChanged: (v) {},
                        );
                      }

                      final supplierList =
                          context.read<SupplierInvoiceBloc>().supplierActiveList;

                      return AppDropdown<SupplierActiveModel>(
                        label: "Supplier",
                        hint: "Select Supplier",
                        isLabel: true,
                        value: _selectedSupplier,
                        itemList: supplierList,
                        onChanged: (newVal) {
                          setState(() => _selectedSupplier = newVal);
                          _fetchApi(
                            supplier: newVal?.id?.toString(),
                            from: selectedDateRange?.start,
                            to: selectedDateRange?.end,
                          );
                        },
                      );
                    },
                  ),
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


  Widget _buildSupplierSummary() {
    return BlocBuilder<SupplierLedgerBloc, SupplierLedgerState>(
      builder: (context, state) {
        final supplier = _selectedSupplier;

        if (supplier == null) {
          return Card(
            elevation: 0,
            color: AppColors.bottomNavBg(context),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 60,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Select a Supplier",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choose a supplier from the dropdown to view their ledger",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.text(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! SupplierLedgerSuccess) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    supplier.name ?? "",
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
        final closingBalanceColor = summary.closingBalance > 0
            ? Colors.red
            : Colors.green;
        final balanceText = summary.closingBalance > 0 ? 'DUE' : 'ADVANCE';

        return Card(
          elevation: 0,
          color: AppColors.bottomNavBg(context),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                      child: const Icon(Icons.business, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        supplier.name ?? "",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.text(context),

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Balance Summary
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: closingBalanceColor.withValues(alpha: 0.1),
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
                                color: closingBalanceColor,
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
                          color: closingBalanceColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          balanceText,
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
                const SizedBox(height: 6),

                // Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: [
                    _buildMobileStatItem(
                      'Opening',
                      _formatCurrency(summary.openingBalance),
                      Icons.account_balance_wallet,
                      Colors.blue,
                    ),
                    _buildMobileStatItem(
                      'Total Debit',
                      _formatCurrency(summary.totalDebit),
                      Icons.arrow_circle_up,
                      Colors.red,
                    ),
                    _buildMobileStatItem(
                      'Total Credit',
                      _formatCurrency(summary.totalCredit),
                      Icons.arrow_circle_down,
                      Colors.green,
                    ),
                    _buildMobileStatItem(
                      'Transactions',
                      summary.totalTransactions.toString(),
                      Icons.receipt_long,
                      Colors.purple,
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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.text(context),
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

  Widget _buildLedgerTransactions() {
    return BlocBuilder<SupplierLedgerBloc, SupplierLedgerState>(
      builder: (context, state) {
        if (state is SupplierLedgerLoading) {
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
        } else if (state is SupplierLedgerSuccess) {
          if (state.response.report.isEmpty) {
            return _buildEmptyState(
              "No transactions found for the selected period",
            );
          }
          return _buildMobileTransactionList(state.response.report);
        } else if (state is SupplierLedgerFailed) {
          return _buildErrorState(state.content);
        }
        return _buildEmptyState("Select a supplier to view transactions");
      },
    );
  }

  Widget _buildMobileTransactionList(List<SupplierLedger> transactions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isDebit = transaction.debit > 0;
        final isCredit = transaction.credit > 0;
        final balanceColor = transaction.due > 0 ? Colors.red : Colors.green;

        return Card(
          color: AppColors.bottomNavBg(context),

          margin: const EdgeInsets.only(bottom: 6),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                        color: AppColors.bottomNavBg(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDate(transaction.date),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.text(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        transaction.particular,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.text(context),
                        ),
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
                          color: balanceColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: balanceColor),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'BALANCE',

                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.text(context),
                              ),
                            ),
                            Text(
                              _formatCurrency(transaction.due.abs()),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: balanceColor,
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
                      const SizedBox(height: 4),
                      if (transaction.details.isNotEmpty)
                        Text(
                          transaction.details,
                          style: TextStyle(
                            fontSize: 10,
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
                                  fontSize: 10,
                                  color: AppColors.text(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                  AppButton(
                    size: 90,
                    isOutlined: true,
                    name: "Details",


                    onPressed: () => _showTransactionDetails(context, transaction),

                  ),

                ],)
                // View Details Button

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
            onPressed: _fetchApi,
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    SupplierLedger transaction,
  ) {
    final balanceColor = transaction.due > 0 ? Colors.red : Colors.green;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
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
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Transaction Details
                _buildMobileDetailRow('Voucher No:', transaction.voucherNo,context),
                _buildMobileDetailRow('Date:', _formatDate(transaction.date),context),
                _buildMobileDetailRow('Type:', transaction.type.toUpperCase(),context),
                _buildMobileDetailRow('Particular:', transaction.particular,context),
                _buildMobileDetailRow('Details:', transaction.details,context),
                _buildMobileDetailRow('Payment Method:', transaction.method,context),
                _buildMobileDetailRow(
                  'Debit Amount:',
                  _formatCurrency(transaction.debit),context
                ),
                _buildMobileDetailRow(
                  'Credit Amount:',
                  _formatCurrency(transaction.credit),context
                ),
                _buildMobileDetailRow(
                  'Balance:',
                  _formatCurrency(transaction.due),context
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

                // Balance Status
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: balanceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: balanceColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        transaction.due > 0
                            ? Icons.arrow_circle_up
                            : Icons.arrow_circle_down,
                        color: balanceColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          transaction.due > 0
                              ? 'Supplier OWES you'
                              : 'You OWE supplier',
                          style: TextStyle(
                            color: balanceColor,
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
          ),
        );
      },
    );
  }

  Widget _buildMobileDetailRow(
    String label,
    String value,
    BuildContext context,
  ) {
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
              style:  TextStyle(
                  color: AppColors.text(context),

                  fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _generatePdf() {
    final state = context.read<SupplierLedgerBloc>().state;
    if (state is SupplierLedgerSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Supplier Ledger PDF'),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            body: PdfPreview(
              build: (format) =>
                  generateSupplierLedgerReportPdf(state.response),
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
          content: Text('No supplier ledger data available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
