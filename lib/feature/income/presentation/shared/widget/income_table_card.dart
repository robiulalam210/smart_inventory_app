import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../../../../responsive.dart';
import '../../../data/model/income_model.dart';
import '../../IncomeBloc/income_bloc.dart';
import '../income_create_screen/income_create_screen.dart';

class IncomeTableCard extends StatelessWidget {
  final List<IncomeModel> incomes;
  final VoidCallback? onIncomeTap;

  const IncomeTableCard({Key? key, required this.incomes, this.onIncomeTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (incomes.isEmpty) {
      return Center(child: Text('No Incomes Found'));
    }

    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    if (isMobile || isTablet) {
      return _buildMobileCardView(context, isMobile);
    } else {
      return _IncomeDesktopTable(
        incomes: incomes,
        onEdit: (i) => _showEditDialog(context, i, false),
        onView: (i) => _showViewDialog(context, i, false),
        onDelete: (i) => _confirmDelete(context, i),
      );
    }
  }

  // Mobile / Tablet Cards
  Widget _buildMobileCardView(BuildContext context, bool isMobile) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: incomes.length,
      itemBuilder: (context, index) {
        final income = incomes[index];
        return _buildIncomeCard(income, index + 1, context, isMobile);
      },
    );
  }

  Widget _buildIncomeCard(
      IncomeModel income, int index, BuildContext context, bool isMobile) {
    final amountValue = double.tryParse(income.amount ?? '0') ?? 0;

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
          // Header
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
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            income.invoiceNumber?.capitalize() ?? 'N/A',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.text(context),
                              fontSize: 14,
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
                    color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF16A34A),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '৳${amountValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF16A34A),
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
                _buildDetailRow(
                  context: context,
                  icon: Iconsax.category,
                  label: 'Income Head',
                  value: income.headName ?? 'N/A',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  context: context,
                  icon: Iconsax.calendar,
                  label: 'Date',
                  value: AppWidgets().convertDateTimeDDMMYYYY(
                      DateTime.tryParse(income.incomeDate ?? '')),
                ),
                const SizedBox(height: 8),
                if (income.note?.isNotEmpty == true)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Iconsax.note, size: 16, color: Colors.grey.shade600),
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
                          income.note!,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bottomNavBg(context),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showViewDialog(context, income, true),
                    icon: const Icon(HugeIcons.strokeRoundedView, size: 16),
                    label: const Text('View'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: BorderSide(color: Colors.green.shade300),
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
                    onPressed: () => _showEditBottomSheet(context, income),
                    icon: const Icon(Iconsax.edit, size: 16),
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
                    onPressed: () => _confirmDelete(context, income),
                    icon: const Icon(HugeIcons.strokeRoundedDeleteThrow, size: 16),
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

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.text(context)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text(context),
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

  // Desktop Table
  Future<void> _confirmDelete(BuildContext context, IncomeModel income) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (!shouldDelete) return;

    if (context.mounted) {
      context.read<IncomeBloc>().add(DeleteIncome(id: income.id.toString()));
    }
  }
  void _showEditBottomSheet(BuildContext context, IncomeModel income) {
    showAppPopoverSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7, // প্রথমে 70% of screen
          minChildSize: 0.4,     // minimum 40%
          maxChildSize: 0.95,    // maximum 95%
          expand: false,         // content অনুযায়ী expand
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radius),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radius),
                ),
                child: MobileIncomeCreate(
                  incomeModel: income,
                  scrollController: scrollController,
                  // id: income.id.toString(),

                ),
              ),
            );
          },
        );
      },
    );
  }


  void _showEditDialog(BuildContext context, IncomeModel income, bool isMobile) {
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
            ),
            child: MobileIncomeCreate(
              incomeModel: income,
              id: income.id.toString(),

              // accountId: income.account.toString(),
              // name: "Update",
            ),
          ),
        );
      },
    );
  }

  void _showViewDialog(BuildContext context, IncomeModel income, bool isMobile) {
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
                    'Income Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildViewDetailRow(context, 'Invoice No:', income.invoiceNumber ?? 'N/A'),
                  _buildViewDetailRow(context, 'Income Head:', income.headName ?? 'N/A'),
                  _buildViewDetailRow(context, 'Account:', income.accountName ?? 'N/A'),
                  _buildViewDetailRow(context, 'Date:', AppWidgets().convertDateTimeDDMMYYYY(
                      DateTime.tryParse(income.incomeDate ?? ''))),
                  _buildViewDetailRow(context, 'Amount:', income.amount ?? 'N/A'),
                  if (income.note?.isNotEmpty == true)
                    _buildViewDetailRow(context, 'Note:', income.note ?? 'N/A'),
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

  Widget _buildViewDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.text(context)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppColors.text(context)),
            ),
          ),
        ],
      ),
    );
  }
}


// ───────────────────────── Desktop table (নতুন ডিজাইন) ─────────────────────────
class _IncomeDesktopTable extends StatelessWidget {
  final List<IncomeModel> incomes;
  final void Function(IncomeModel) onEdit;
  final void Function(IncomeModel) onView;
  final void Function(IncomeModel) onDelete;

  const _IncomeDesktopTable({
    required this.incomes,
    required this.onEdit,
    required this.onView,
    required this.onDelete,
  });

  static const _columns = [
    AppTableColumn.center('SL', flex: 1, minWidth: 52),
    AppTableColumn('Invoice No.', flex: 2, minWidth: 120),
    AppTableColumn('Income Head', flex: 3, minWidth: 150),
    AppTableColumn('Account', flex: 2, minWidth: 120),
    AppTableColumn('Date', flex: 2, minWidth: 100),
    AppTableColumn.numeric('Amount', flex: 2, minWidth: 120),
    AppTableColumn('Note', flex: 3, minWidth: 140),
    AppTableColumn.center('Actions', flex: 2, minWidth: 120),
  ];

  @override
  Widget build(BuildContext context) {
    return AppDataTable(
      columns: _columns,
      rowCount: incomes.length,
      cellBuilder: (context, row, col) {
        final income = incomes[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(income.invoiceNumber ?? '-',
                bold: true, color: AppColors.primaryColor(context));
          case 2:
            return AppTableText(income.headName ?? '-');
          case 3:
            return AppTableText(income.accountName ?? '-', muted: true);
          case 4:
            return AppTableText(AppWidgets().convertDateTimeDDMMYYYY(
                DateTime.tryParse(income.incomeDate ?? '')));
          case 5:
            return AppTableMoney(AppTableMoney.parse(income.amount),
                bold: true, color: AppColors.success);
          case 6:
            return AppTableText(income.note ?? '-', muted: true);
          default:
            return AppTableEditDelete(
              onView: () => onView(income),
              onEdit: () => onEdit(income),
              onDelete: () => onDelete(income),
            );
        }
      },
    );
  }
}
