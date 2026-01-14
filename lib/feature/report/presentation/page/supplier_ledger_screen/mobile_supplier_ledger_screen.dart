import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';
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
  State<MobileSupplierLedgerScreen> createState() => _MobileSupplierLedgerScreenState();
}

class _MobileSupplierLedgerScreenState extends State<MobileSupplierLedgerScreen> {
  SupplierActiveModel? _selectedSupplier;
  DateRange? selectedDateRange;
  bool _isFilterExpanded = false;

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

  String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bottomNavBg(context),
      appBar: AppBar(
        title: const Text('Supplier Ledger'),
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

              // Supplier Summary
              _buildSupplierSummary(),
              const SizedBox(height: 16),

              // Ledger Transactions
              _buildLedgerTransactions(),
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
                  const SizedBox(height: 12),

                  // Supplier Dropdown
                  BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
                    builder: (context, state) {
                      if (state is SupplierActiveListLoading) {
                        return AppDropdown<SupplierActiveModel>(
                          label: "Supplier",
                          hint: "Loading suppliers...",
                          isLabel: true,
                          itemList: [],
                          onChanged: (v){},
                        );
                      }

                      if (state is SupplierActiveListFailed) {
                        return AppDropdown<SupplierActiveModel>(
                          label: "Supplier",
                          hint: "Failed to load suppliers",
                          isLabel: true,
                          itemList: [],
                          onChanged: (v){},
                        );
                      }

                      final supplierList = context.read<SupplierInvoiceBloc>().supplierActiveList;

                      return AppDropdown<SupplierActiveModel>(
                        label: "Supplier",
                        hint: "Select Supplier",
                        isLabel: true,
                        value: _selectedSupplier,
                        itemList: supplierList,
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
                    },
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
                              _selectedSupplier = null;
                              _isFilterExpanded = false;
                            });
                            context.read<SupplierLedgerBloc>().add(ClearSupplierLedgerFilters());
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

  Widget _buildSupplierSummary() {
    return BlocBuilder<SupplierLedgerBloc, SupplierLedgerState>(
      builder: (context, state) {
        final supplier = _selectedSupplier;

        if (supplier == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 60,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Select a Supplier",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choose a supplier from the dropdown to view their ledger",
                    style: GoogleFonts.inter(
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

        if (state is! SupplierLedgerSuccess) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    supplier.name??"",
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
        final closingBalanceColor = summary.closingBalance > 0 ? Colors.red : Colors.green;
        final balanceText = summary.closingBalance > 0 ? 'DUE' : 'ADVANCE';

        return Card(
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
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.business, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        supplier.name??"",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Balance Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: closingBalanceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Balance',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                const SizedBox(height: 16),

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

  Widget _buildMobileStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
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
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
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
            return _buildEmptyState("No transactions found for the selected period");
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: transaction.typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(transaction.typeIcon, size: 12, color: transaction.typeColor),
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
                const SizedBox(height: 8),

                // Date and Particular
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                const SizedBox(height: 12),

                // Amount Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isDebit)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
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
                            color: Colors.green.withOpacity(0.1),
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
                          color: balanceColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: balanceColor),
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
                if (transaction.details.isNotEmpty || transaction.method.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      if (transaction.details.isNotEmpty)
                        Text(
                          transaction.details,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (transaction.method.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.payment, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                transaction.method,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                // View Details Button
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _showTransactionDetails(context, transaction),
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

  void _showTransactionDetails(BuildContext context, SupplierLedger transaction) {
    final balanceColor = transaction.due > 0 ? Colors.red : Colors.green;

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
                    'Transaction Details',
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

              // Transaction Details
              _buildMobileDetailRow('Voucher No:', transaction.voucherNo),
              _buildMobileDetailRow('Date:', _formatDate(transaction.date)),
              _buildMobileDetailRow('Type:', transaction.type.toUpperCase()),
              _buildMobileDetailRow('Particular:', transaction.particular),
              _buildMobileDetailRow('Details:', transaction.details),
              _buildMobileDetailRow('Payment Method:', transaction.method),
              _buildMobileDetailRow('Debit Amount:', _formatCurrency(transaction.debit)),
              _buildMobileDetailRow('Credit Amount:', _formatCurrency(transaction.credit)),
              _buildMobileDetailRow('Balance:', _formatCurrency(transaction.due)),

              // Type Badge
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: transaction.typeColor.withOpacity(0.1),
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
                  color: balanceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: balanceColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      transaction.due > 0 ? Icons.arrow_circle_up : Icons.arrow_circle_down,
                      color: balanceColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        transaction.due > 0 ? 'Supplier OWES you' : 'You OWE supplier',
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
              build: (format) => generateSupplierLedgerReportPdf(state.response),
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