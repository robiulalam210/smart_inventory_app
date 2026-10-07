import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../data/model/expense_head_model.dart';
import '../bloc/expense_head/expense_head_bloc.dart';
import '../shared/expense_head_create.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

class ExpenseHeadTableCard extends StatelessWidget {
  final List<ExpenseHeadModel> expenseHeads;
  final VoidCallback? onExpenseHeadTap;

  const ExpenseHeadTableCard({
    super.key,
    required this.expenseHeads,
    this.onExpenseHeadTap,
  });

  @override
  Widget build(BuildContext context) {
    if (expenseHeads.isEmpty) {
      return _buildEmptyState();
    }

    final bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return _buildMobileCardView(context, isMobile);
    } else {
        return _buildDesktopDataTable();

    }
  }


  // Desktop টেবিল — AppDataTable
  Widget _buildDesktopDataTable() {
    if (expenseHeads.isEmpty) {
      return _buildEmptyState();
    }

    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 60),
      AppTableColumn('Head Name', flex: 5, minWidth: 200),
      AppTableColumn.center('Status', flex: 2, minWidth: 110),
      AppTableColumn.center('Actions', flex: 2, minWidth: 110),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: expenseHeads.length,
      cellBuilder: (context, row, col) {
        final head = expenseHeads[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(head.name?.capitalize() ?? '-', bold: true);
          case 2:
            final active = _getExpenseSubHeadStatus(head);
            return AppStatusPill(active ? 'Active' : 'Inactive',
                color: active ? AppColors.success : AppColors.danger);
          default:
            return AppTableEditDelete(
              onEdit: () => _showEditDialog(context, head),
              onDelete: () => _confirmDelete(context, head),
            );
        }
      },
    );
  }

  bool _getExpenseSubHeadStatus(ExpenseHeadModel expenseSubHead) {
    return expenseSubHead.isActive ?? false;
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
    );
  }

  Widget _buildMobileCardView(BuildContext context, bool isMobile) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenseHeads.length,
      itemBuilder: (context, index) {
        final expenseHead = expenseHeads[index];
        return _buildExpenseHeadCard(expenseHead, index + 1, context, isMobile);
      },
    );
  }

  Widget _buildExpenseHeadCard(
      ExpenseHeadModel expenseHead,
      int index,
      BuildContext context,
      bool isMobile,
      ) {
    final isActive = _getExpenseHeadStatus(expenseHead);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 0.0 : 16.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(AppSizes.radius),

        border: Border.all(
          color: AppColors.greyColor(context).withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Serial No and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor(context).withValues(alpha: 0.05),
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
                        color: AppColors.primaryColor(context),
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
                    FittedBox(
                      child: Text(
                        expenseHead.name.toString().capitalize(),
                        style:  TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text(context),
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? AppColors.success : AppColors.danger,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: isActive ? AppColors.success : AppColors.danger,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),



          // Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bottomNavBg(context),
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
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditDialog(context, expenseHead),
                    icon: const Icon(
                      Iconsax.edit,
                      size: 16,
                    ),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.info,
                      side: BorderSide(color: Colors.blue.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, expenseHead),
                    icon: const Icon(
                      HugeIcons.strokeRoundedDeleteThrow,
                      size: 16,
                    ),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
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



  bool _getExpenseHeadStatus(ExpenseHeadModel expenseHead) {
    if (expenseHead.isActive != null) {
      if (expenseHead.isActive is bool) {
        return expenseHead.isActive as bool;
      } else if (expenseHead.isActive is String) {
        final status = expenseHead.isActive.toString().toLowerCase();
        return status == 'true' || status == 'active' || status == '1';
      }
    }
    return false;
  }



  Future<void> _confirmDelete(
      BuildContext context,
      ExpenseHeadModel expenseHead,
      ) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (!shouldDelete) return;

    // Show loading dialog
    showAppPopover(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AppPopoverShell(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Deleting...'),
            ],
          ),
        ),
      ),
    );

    // Send delete event
    if (context.mounted) {
      context.read<ExpenseHeadBloc>().add(
        DeleteExpenseHead(id: expenseHead.id.toString()),
      );
    }
  }

  void _showEditDialog(BuildContext context, ExpenseHeadModel expenseHead) {
    final expenseHeadBloc = context.read<ExpenseHeadBloc>();
    expenseHeadBloc.name.text = expenseHead.name ?? "";

    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverShell(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.isMobile(context)
                  ? AppSizes.width(context)
                  : AppSizes.width(context) * 0.5,
              maxHeight: AppSizes.height(context) * 0.7,
            ),
            child: ExpenseHeadCreate(
              id: expenseHead.id.toString(),
              name: expenseHead.name,
            ),
          ),
        );
      },
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
            'No Expense Heads Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first expense head to get started',
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

