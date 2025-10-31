import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:smart_inventory/feature/supplier/presentation/bloc/supplier/supplier_list_bloc.dart';

import '../../../../../core/configs/app_colors.dart';
import '../../../../../core/configs/app_text.dart';
import '../../../../../core/configs/configs.dart';
import '../../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../../core/widgets/app_dropdown.dart';
import '../../../../../core/widgets/date_range.dart';
import '../../../../../responsive.dart';
import '../../../../supplier/data/model/supplier_active_model.dart';
import '../../../../supplier/presentation/bloc/supplier_invoice/supplier_invoice_bloc.dart';
import '../../../data/model/supplier_ledger_model.dart';
import '../../bloc/supplier_ledger_bloc/supplier_ledger_bloc.dart';

class SupplierLedgerScreen extends StatefulWidget {
  const SupplierLedgerScreen({super.key});

  @override
  State<SupplierLedgerScreen> createState() => _SupplierLedgerScreenState();
}

class _SupplierLedgerScreenState extends State<SupplierLedgerScreen> {
  final ValueNotifier<String?> selectedSupplierNotifier = ValueNotifier<String?>(null);
  SupplierActiveModel? _selectedSupplier;
  DateRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    // Initialize supplier list when screen loads
    context.read<SupplierInvoiceBloc>().add(
      FetchSupplierActiveList(context),
    );
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
        onRefresh: () async => _fetchApi(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildFilterRow(),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 16),
              _buildLedgerTable(),
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
        Text(
          "Supplier Ledger Report",
          style: AppTextStyle.cardTitle(context).copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () => _fetchApi(),
          icon: const Icon(Icons.refresh),
          tooltip: "Refresh",
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 📅 Date Range Picker
        Expanded(
          flex: 1,
          child: SizedBox(
            width: 260,
            child: CustomDateRangeField(
              selectedDateRange: selectedDateRange,
              onDateRangeSelected: (value) {
                setState(() => selectedDateRange = value);
                if (value != null) {
                  _fetchApi(
                    from: value.start,
                    to: value.end,
                    supplier: selectedSupplierNotifier.value,
                  );
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 👥 Supplier Dropdown
        Expanded(
          flex: 1,
          child: BlocBuilder<SupplierInvoiceBloc, SupplierInvoiceState>(
            builder: (context, state) {
              // Handle different states of supplier list loading
              if (state is SupplierActiveListLoading) {
                return AppDropdown<SupplierActiveModel>(
                  label: "Supplier",
                  context: context,
                  hint: "Loading suppliers...",
                  isLabel: false,
                  isRequired: false,
                  itemList: [],
                  onChanged: (v){}, // Disable while loading
                  validator: (value) => null,
                  itemBuilder: (item) => const DropdownMenuItem<SupplierActiveModel>(
                    value: null,
                    child: Text('Loading...'),
                  ),
                );
              }

              if (state is SupplierActiveListFailed) {
                return AppDropdown<SupplierActiveModel>(
                  label: "Supplier",
                  context: context,
                  hint: "Failed to load suppliers",
                  isLabel: false,
                  isRequired: false,
                  itemList: [],
                  onChanged: (v){},
                  validator: (value) => null,
                  itemBuilder: (item) => const DropdownMenuItem<SupplierActiveModel>(
                    value: null,
                    child: Text('Error loading suppliers'),
                  ),
                );
              }

              if (state is SupplierActiveListSuccess) {
                // Get supplier list from bloc
                final supplierList = context.read<SupplierInvoiceBloc>().supplierActiveList;

                // Add "All Suppliers" option
                final List<SupplierActiveModel> options = [
                  SupplierActiveModel(
                    id: null,
                    name: "All Suppliers",
                    phone: "",
                    email: "",
                    address: "",
                    status: "",
                  ),
                  ...supplierList,
                ];

                return AppDropdown<SupplierActiveModel>(
                  label: "Supplier",
                  context: context,
                  hint: "Select Supplier",
                  isLabel: false,
                  isRequired: false,
                  value: _selectedSupplier,
                  itemList: options,
                  onChanged: (newVal) {
                    setState(() {
                      _selectedSupplier = newVal;
                    });
                    selectedSupplierNotifier.value = newVal?.id?.toString();

                    _fetchApi(
                      supplier: newVal?.id?.toString(),
                      from: selectedDateRange?.start,
                      to: selectedDateRange?.end,
                    );
                  },
                  validator: (value) => null,
                  itemBuilder: (item) {
                    final isAllOption = item.id == null;
                    return DropdownMenuItem<SupplierActiveModel>(
                      value: item,
                      child: Text(
                        item.name ?? 'Unknown Supplier',
                        style: TextStyle(
                          color: isAllOption ? AppColors.primaryColor : AppColors.blackColor,
                          fontFamily: 'Quicksand',
                          fontWeight: isAllOption ? FontWeight.bold : FontWeight.w300,
                        ),
                      ),
                    );
                  },
                );
              }

              // Default loading state
              return AppDropdown<SupplierActiveModel>(
                label: "Supplier",
                context: context,
                hint: "Loading suppliers...",
                isLabel: false,
                isRequired: false,
                itemList: [],
                onChanged: (v){},
                validator: (value) => null,
                itemBuilder: (item) => const DropdownMenuItem<SupplierActiveModel>(
                  value: null,
                  child: Text('Loading...'),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        // 🧹 Clear Filters Button
        Expanded(
          flex: 0,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                selectedDateRange = null;
                _selectedSupplier = null;
              });
              selectedSupplierNotifier.value = null;
              context.read<SupplierLedgerBloc>().add(ClearSupplierLedgerFilters());
              _fetchApi();
            },
            icon: const Icon(Icons.clear_all),
            label: const Text("Clear"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.grey,
              foregroundColor: AppColors.blackColor,
            ),
          ),
        ),
      ],
    );
  }

  // Add the missing methods that were referenced
  Widget _buildSummaryCards() {
    return BlocBuilder<SupplierLedgerBloc, SupplierLedgerState>(
      builder: (context, state) {
        if (state is! SupplierLedgerSuccess) return const SizedBox();

        final summary = state.response.summary;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildSummaryCard(
              "Supplier",
              _selectedSupplier?.name ?? summary.supplierName,
              Icons.business,
              AppColors.primaryColor,
            ),
            _buildSummaryCard(
              "Opening Balance",
              "\$${summary.openingBalance.toStringAsFixed(2)}",
              Icons.account_balance_wallet,
              Colors.orange,
            ),
            _buildSummaryCard(
              "Closing Balance",
              "\$${summary.closingBalance.toStringAsFixed(2)}",
              summary.closingBalance > 0 ? Icons.arrow_upward : Icons.arrow_downward,
              summary.closingBalance > 0 ? Colors.red : Colors.green,
              subtitle: summary.closingBalance > 0 ? 'Due' : 'Advance',
            ),
            _buildSummaryCard(
              "Total Debit",
              "\$${summary.totalDebit.toStringAsFixed(2)}",
              Icons.arrow_circle_up,
              Colors.red,
            ),
            _buildSummaryCard(
              "Total Credit",
              "\$${summary.totalCredit.toStringAsFixed(2)}",
              Icons.arrow_circle_down,
              Colors.green,
            ),
            _buildSummaryCard(
              "Total Transactions",
              summary.totalTransactions.toString(),
              Icons.receipt_long,
              Colors.blue,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      width: 220,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
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
            return _noDataWidget("No supplier ledger data found");
          }
          return SupplierLedgerDataTableWidget(ledgers: state.response.report);
        } else if (state is SupplierLedgerFailed) {
          return _errorWidget(state.content);
        }
        return _noDataWidget("No data available");
      },
    );
  }

  Widget SupplierLedgerDataTableWidget({required List<SupplierLedger> ledgers}) {
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
          rows: ledgers.map((ledger) => DataRow(
            cells: [
              DataCell(Text('${ledger.sl}')),
              DataCell(Text(_formatDate(ledger.date))),
              DataCell(Text(ledger.voucherNo)),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ledger.typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(ledger.typeIcon, size: 14, color: ledger.typeColor),
                      const SizedBox(width: 4),
                      Text(
                        ledger.type,
                        style: TextStyle(
                          color: ledger.typeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              DataCell(Text(ledger.particular)),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(
                    ledger.details,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
              DataCell(Text(ledger.method)),
              DataCell(
                Text(
                  '\$${ledger.debit.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: ledger.debit > 0 ? Colors.red : Colors.grey,
                    fontWeight: ledger.debit > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              DataCell(
                Text(
                  '\$${ledger.credit.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: ledger.credit > 0 ? Colors.green : Colors.grey,
                    fontWeight: ledger.credit > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ledger.due > 0 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: ledger.due > 0 ? Colors.red : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '\$${ledger.due.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: ledger.due > 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )).toList(),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _noDataWidget(String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(AppImages.noData, width: 200, height: 200),
        const SizedBox(height: 12),
        Text(message),
        const SizedBox(height: 8),
        ElevatedButton(
            onPressed: _fetchApi,
            child: const Text("Refresh")
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
        Text("Error: $error"),
        const SizedBox(height: 8),
        ElevatedButton(
            onPressed: _fetchApi,
            child: const Text("Retry")
        ),
      ],
    ),
  );

  @override
  void dispose() {
    selectedSupplierNotifier.dispose();
    super.dispose();
  }
}