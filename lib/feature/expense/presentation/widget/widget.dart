import 'package:google_fonts/google_fonts.dart';
import 'package:smart_inventory/feature/expense/expense_sub_head/data/model/expense_sub_head_model.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../data/model/expense.dart';
import '../../expense_head/data/model/expense_head_model.dart';
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

    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth ;
        const numColumns = 9; // Adjusted for expense fields
        const minColumnWidth = 120.0;

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
                          dataRowMinHeight: 35,
                          dataRowMaxHeight: 35,
                          dividerThickness: 0.5,
                          headingRowHeight: 40,
                          headingTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          headingRowColor: WidgetStateProperty.all(
                            AppColors.primaryColor,
                          ),
                          dataTextStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: expenses.asMap().entries.map((entry) {
                            final expense = entry.value;
                            return DataRow(
                              onSelectChanged: onExpenseTap != null
                                  ? (_) => onExpenseTap!()
                                  : null,
                              cells: [
                                _buildDataCell('${entry.key + 1}', dynamicColumnWidth * 0.6),
                                _buildDataCell(expense.invoiceNumber?.capitalize() ?? "N/A", dynamicColumnWidth),
                                _buildDataCell(expense.headName ?? "N/A", dynamicColumnWidth),
                                _buildDataCell(expense.subheadName ?? "N/A", dynamicColumnWidth),
                                _buildDataCell(
                                    AppWidgets().convertDateTimeDDMMYYYY(expense.expenseDate),
                                    dynamicColumnWidth
                                ),
                                _buildDataCell(expense.paymentMethod ?? "N/A", dynamicColumnWidth),
                                _buildAmountCell(expense.amount, dynamicColumnWidth),
                                _buildDataCell(expense.note ?? "N/A", dynamicColumnWidth * 1.2),
                                _buildActionCell(expense, context, dynamicColumnWidth),
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

  DataCell _buildDataCell(String text, double width) {
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
          textAlign: TextAlign.center,
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
              color: color.withOpacity(0.1),
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

  DataCell _buildActionCell(ExpenseModel expense, BuildContext context, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Edit Button
            IconButton(
              onPressed: () {
                _showEditDialog(context, expense);
              },
              icon: const Icon(
                Icons.edit,
                size: 18,
                color: Colors.blue,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),
            ),

            // View Button
            IconButton(
              onPressed: () {
                _showViewDialog(context, expense);
              },
              icon: const Icon(
                HugeIcons.strokeRoundedView,
                size: 18,
                color: Colors.green,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),
            ),

            // Delete Button
            IconButton(
              onPressed: () async {
                bool shouldDelete = await showDeleteConfirmationDialog(context);
                if (!shouldDelete) return;

                context.read<ExpenseBloc>().add(
                    DeleteExpense(id: expense.id.toString())
                );
              },
              icon: const Icon(
                HugeIcons.strokeRoundedDeleteThrow,
                size: 18,
                color: Colors.red,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }



  void _showEditDialog(BuildContext context, ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: AppSizes.width(context) * 0.50,
            child: ExpenseCreateScreen(
              id: expense.id.toString(),
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

  void _showViewDialog(BuildContext context, ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: AppSizes.width(context) * 0.40,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expense Details',
                  style: AppTextStyle.cardLevelHead(context),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Invoice No:', expense.invoiceNumber ?? 'N/A'),
                _buildDetailRow('Expense Head:', expense.headName ?? 'N/A'),
                _buildDetailRow('Sub Head:', expense.subheadName ?? 'N/A'),
                // _buildDetailRow('Date:', z(expense.expenseDate)),
                _buildDetailRow('Payment Method:', expense.paymentMethod ?? 'N/A'),
                _buildDetailRow('Amount:', expense.amount ?? 'N/A'),
                _buildDetailRow('Note:', expense.note ?? 'N/A'),
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
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
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

  Widget _buildEmptyState() {
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
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}