import 'package:google_fonts/google_fonts.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/web_ui.dart';
import '../../../../core/widgets/delete_dialog.dart';
import '../../data/model/expense.dart';
import '../../expense_head/data/model/expense_head_model.dart';
import '../../expense_sub_head/data/model/expense_sub_head_model.dart';
import '../bloc/expense_list/expense_bloc.dart';
import '../shared/expense_create.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

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
        horizontal: isMobile ? 0.0 : 16.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: W.surface(context),
        borderRadius: BorderRadius.circular(W.rLg),
        border: Border.all(color: W.line(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: W.soft(context),
              border: Border(bottom: BorderSide(color: W.line(context))),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(W.rLg - 1),
                topRight: Radius.circular(W.rLg - 1),
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
                        color: W.tint(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#$index',
                        style: TextStyle(
                          color: W.ink2(context),
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
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: W.ink(context),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            expense.paymentMethod ?? 'N/A',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: W.muted(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: W.redWash(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '৳${amountValue.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: W.redInk(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFeatures: W.tabular,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expense Head
                _buildDetailRow(
                  context: context,
                  icon: Iconsax.category,
                  label: 'Expense Head',
                  value: expense.headName ?? 'N/A',
                ),
                const SizedBox(height: 8),

                // Sub Head


                Row(children: [
                  Expanded(child: _buildDetailRow(
                    context: context,
                    icon: Iconsax.category_2,
                    label: 'Sub Head',
                    value: expense.subheadName ?? 'N/A',
                  ),),
                  const SizedBox(width: 8),

                  Expanded(
                    child: _buildDetailRow(
                        context: context,
                        icon: Iconsax.calendar,
                        label: 'Date',
                        value:  AppWidgets().convertDateTimeDDMMYYYY(expense.expenseDate )
                    ),
                  ),
                ],),
                // Date

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
                            color: W.muted(context),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Note',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: W.muted(context),
                              fontSize: 12.5,
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
                            color: W.ink2(context),
                            fontSize: 13.5,
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: W.surface(context),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(W.rLg),
                bottomRight: Radius.circular(W.rLg),
              ),
              border: Border(top: BorderSide(color: W.line(context))),
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
                      foregroundColor: W.ink2(context),
                      side: BorderSide(color: W.line2(context)),
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
                      foregroundColor: W.blueInk(context),
                      side: BorderSide(color: W.blueLine(context)),
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
                      foregroundColor: W.redInk(context),
                      side: BorderSide(color: W.redLine(context)),
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

    required BuildContext context,
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
          color: W.muted(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: W.muted(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: W.ink(context),
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

  // Desktop টেবিল — AppDataTable
  Widget _buildDesktopDataTable() {
    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 52),
      AppTableColumn('Invoice No.', flex: 2, minWidth: 120),
      AppTableColumn('Expense Head', flex: 3, minWidth: 150),
      AppTableColumn('Date', flex: 2, minWidth: 100),
      AppTableColumn('Payment', flex: 2, minWidth: 100),
      AppTableColumn.numeric('Amount', flex: 2, minWidth: 110),
      AppTableColumn('Note', flex: 3, minWidth: 140),
      AppTableColumn.center('Actions', flex: 2, minWidth: 120),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: expenses.length,
      cellBuilder: (context, row, col) {
        final e = expenses[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(e.invoiceNumber?.capitalize() ?? '-',
                bold: true, color: AppColors.primaryColor(context));
          case 2:
            return AppTableText(e.headName ?? '-', subtitle: e.subheadName);
          case 3:
            return AppTableText(
                AppWidgets().convertDateTimeDDMMYYYY(e.expenseDate));
          case 4:
            return AppTableText(e.paymentMethod ?? '-');
          case 5:
            return AppTableMoney(AppTableMoney.parse(e.amount),
                bold: true, color: AppColors.danger);
          case 6:
            return AppTableText(e.note ?? '-', muted: true);
          default:
            return AppTableEditDelete(
              onView: () => _showViewDialog(context, e, false),
              onEdit: () => _showEditDialog(context, e, false),
              onDelete: () => _confirmDelete(context, e),
            );
        }
      },
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
    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverShell(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile
                  ? AppSizes.width(context)
                  : AppSizes.width(context) * 0.5,
              // maxHeight: AppSizes.height(context) * 0.8,
            ),
            child: ExpenseCreateScreen(
              expenseModel: expense,
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
    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverShell(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile
                  ? AppSizes.width(context)
                  : AppSizes.width(context) * 0.4,
              maxHeight: AppSizes.height(context) * 0.7,
            ),
            child: Container(
              color: AppColors.bottomNavBg(context),
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
                      color: AppColors.primaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildViewDetailRow(context,'Invoice No:', expense.invoiceNumber ?? 'N/A'),
                  _buildViewDetailRow(context,'Expense Head:', expense.headName ?? 'N/A'),
                  _buildViewDetailRow(context,'Sub Head:', expense.subheadName ?? 'N/A'),
                  _buildViewDetailRow(context,'Date:', AppWidgets().convertDateTimeDDMMYYYY(expense.expenseDate )),
                  _buildViewDetailRow(context,'Payment Method:', expense.paymentMethod ?? 'N/A'),
                  _buildViewDetailRow(context,'Amount:', expense.amount ?? 'N/A'),
                  if (expense.note?.isNotEmpty == true)
                    _buildViewDetailRow(context,'Note:', expense.note ?? 'N/A'),
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

  Widget _buildViewDetailRow(BuildContext context,String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style:  TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.text(context),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style:  TextStyle(fontSize: 13,color: AppColors.text(context)),
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
            style: GoogleFonts.ibmPlexSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first expense to get started',
            style: GoogleFonts.ibmPlexSans(
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
