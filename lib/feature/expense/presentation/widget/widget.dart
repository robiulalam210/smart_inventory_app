import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../data/model/expense.dart';
import '../../expense_head/data/model/expense_head_model.dart';
import '../../expense_sub_head/data/model/expense_sub_head_model.dart';
import '../bloc/expense_list/expense_bloc.dart';
import '../pages/expense_create.dart';

class ExpenseTableCard extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final VoidCallback? onExpenseTap;

  const ExpenseTableCard({
    super.key,
    required this.expenses,
    this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return _buildEmptyState();
    }

    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    if (isMobile || isTablet) {
      return _buildMobileCardView(context, isMobile);
    } else {
      return _buildDesktopDataTable();
    }
  }

  Widget _buildMobileCardView(BuildContext context, bool isMobile) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _buildExpenseCard(expense, index + 1, context, isMobile);
      },
    );
  }

  Widget _buildExpenseCard(
      ExpenseModel expense,
      int index,
      BuildContext context,
      bool isMobile,
      ) {
    final amountValue = double.tryParse(expense.amount ?? '0') ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 8.0 : 16.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#$index',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.invoiceNumber?.capitalize() ?? 'N/A',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            expense.paymentMethod ?? 'N/A',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '৳${amountValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expense Head
                _buildDetailRow(
                  icon: Iconsax.category,
                  label: 'Expense Head',
                  value: expense.headName ?? 'N/A',
                ),
                const SizedBox(height: 8),

                // Sub Head
                _buildDetailRow(
                  icon: Iconsax.category_2,
                  label: 'Sub Head',
                  value: expense.subheadName ?? 'N/A',
                ),
                const SizedBox(height: 8),

                // Date
                _buildDetailRow(
                  icon: Iconsax.calendar,
                  label: 'Date',
                  value:  AppWidgets().convertDateTimeDDMMYYYY(expense.expenseDate )
                ),
                const SizedBox(height: 8),

                // Note
                if (expense.note?.isNotEmpty == true)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Iconsax.note,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Note:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Text(
                          expense.note!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // View Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showViewDialog(context, expense, true),
                    icon: const Icon(
                      HugeIcons.strokeRoundedView,
                      size: 16,
                    ),
                    label: const Text('View'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: BorderSide(color: Colors.green.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Edit Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditDialog(context, expense, true),
                    icon: const Icon(
                      Iconsax.edit,
                      size: 16,
                    ),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: BorderSide(color: Colors.blue.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Delete Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, expense),
                    icon: const Icon(
                      HugeIcons.strokeRoundedDeleteThrow,
                      size: 16,
                    ),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopDataTable() {
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 9;
        const minColumnWidth = 120.0;

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
              child: Scrollbar(
                controller: horizontalScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: totalWidth),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: DataTable(
                        dataRowMinHeight: 35,
                        dataRowMaxHeight: 35,
                        dividerThickness: 0.5,
                        headingRowHeight: 40,
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        headingRowColor: WidgetStateProperty.all(
                          AppColors.primaryColor,
                        ),
                        dataTextStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        columns: _buildColumns(dynamicColumnWidth),
                        rows: expenses
                            .asMap()
                            .entries
                            .map((entry) => _buildDataRow(context,
                          entry.key + 1,
                          entry.value,
                          dynamicColumnWidth,
                        ))
                            .toList(),
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
          child: const Text('No.', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Invoice No.', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Expense Head', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Sub Head', textAlign: TextAlign.center),
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
          child: const Text('Payment', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Amount', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth * 1.2,
          child: const Text('Note', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth * 1.2,
          child: const Text('Actions', textAlign: TextAlign.center),
        ),
      ),
    ];
  }

  DataRow _buildDataRow(BuildContext context,int index, ExpenseModel expense, double columnWidth) {
    return DataRow(
      cells: [
        _buildDataCell('$index', columnWidth * 0.6, TextAlign.center),
        _buildDataCell(
          expense.invoiceNumber?.capitalize() ?? "N/A",
          columnWidth,
          TextAlign.center,
        ),
        _buildDataCell(expense.headName ?? "N/A", columnWidth, TextAlign.center),
        _buildDataCell(expense.subheadName ?? "N/A", columnWidth, TextAlign.center),
        _buildDataCell(
          AppWidgets().convertDateTimeDDMMYYYY(expense.expenseDate ),
          columnWidth,
          TextAlign.center,
        ),
        _buildDataCell(expense.paymentMethod ?? "N/A", columnWidth, TextAlign.center),
        _buildAmountCell(expense.amount, columnWidth),
        _buildDataCell(expense.note ?? "N/A", columnWidth * 1.2, TextAlign.center),
        _buildActionCell(context,expense, columnWidth),
      ],
    );
  }

  DataCell _buildDataCell(String text, double width, TextAlign align) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: align,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  DataCell _buildAmountCell(String? amount, double width) {
    final amountValue = double.tryParse(amount ?? '0');
    final color = amountValue != null && amountValue > 0 ? Colors.red : Colors.grey;

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              amount ?? "0",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildActionCell(BuildContext context,ExpenseModel expense, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => _showEditDialog(context, expense, false),
              icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            IconButton(
              onPressed: () => _showViewDialog(context, expense, false),
              icon: const Icon(
                HugeIcons.strokeRoundedView,
                size: 18,
                color: Colors.green,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            IconButton(
              onPressed: () => _confirmDelete(context, expense),
              icon: const Icon(
                HugeIcons.strokeRoundedDeleteThrow,
                size: 18,
                color: Colors.red,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ExpenseModel expense) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (!shouldDelete) return;

    if (context.mounted) {
      context.read<ExpenseBloc>().add(DeleteExpense(id: expense.id.toString()));
    }
  }

  void _showEditDialog(BuildContext context, ExpenseModel expense, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile
                  ? AppSizes.width(context)
                  : AppSizes.width(context) * 0.5,
              maxHeight: AppSizes.height(context) * 0.8,
            ),
            child: ExpenseCreateScreen(
              id: expense.id.toString(),
              accountId: expense.account.toString(),
              name: "Update",
              selectedExpenseHead: ExpenseHeadModel(
                id: expense.head,
                name: expense.headName,
              ),
              selectedExpenseSubHead: ExpenseSubHeadModel(
                id: expense.subhead,
                name: expense.subheadName,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showViewDialog(BuildContext context, ExpenseModel expense, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile
                  ? AppSizes.width(context)
                  : AppSizes.width(context) * 0.4,
              maxHeight: AppSizes.height(context) * 0.7,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expense Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildViewDetailRow('Invoice No:', expense.invoiceNumber ?? 'N/A'),
                  _buildViewDetailRow('Expense Head:', expense.headName ?? 'N/A'),
                  _buildViewDetailRow('Sub Head:', expense.subheadName ?? 'N/A'),
                  _buildViewDetailRow('Date:', AppWidgets().convertDateTimeDDMMYYYY(expense.expenseDate )),
                  _buildViewDetailRow('Payment Method:', expense.paymentMethod ?? 'N/A'),
                  _buildViewDetailRow('Amount:', expense.amount ?? 'N/A'),
                  if (expense.note?.isNotEmpty == true)
                    _buildViewDetailRow('Note:', expense.note ?? 'N/A'),
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
          ),
        );
      },
    );
  }

  Widget _buildViewDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            AppImages.noData,
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          Text(
            'No Expenses Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first expense to get started',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }


}

// Extension for string capitalization
