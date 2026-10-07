import 'package:google_fonts/google_fonts.dart';
import 'package:meherinMart/core/core.dart';
import '/feature/return/sales_return/data/model/sales_return_model.dart';

import '../../sales_return_bloc/sales_return_bloc.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

class SalesReturnTableCard extends StatelessWidget {
  final List<SalesReturnModel> salesReturns;
  final VoidCallback? onSalesReturnTap;

  const SalesReturnTableCard({
    super.key,
    required this.salesReturns,
    this.onSalesReturnTap,
  });

  @override
  Widget build(BuildContext context) {
    if (salesReturns.isEmpty) {
      return _buildEmptyState();
    }

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600; // threshold for mobile view

    if (isMobile) {
      return _buildMobileList(context);
    }

    // Desktop: AppDataTable
    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 52),
      AppTableColumn('Receipt No', flex: 2, minWidth: 110),
      AppTableColumn('Customer', flex: 3, minWidth: 150),
      AppTableColumn('Return Date', flex: 2, minWidth: 104),
      AppTableColumn.numeric('Amount', flex: 2, minWidth: 110),
      AppTableColumn('Method', flex: 2, minWidth: 100),
      AppTableColumn('Reason', flex: 3, minWidth: 140),
      AppTableColumn.numeric('Items', flex: 1, minWidth: 70),
      AppTableColumn.center('Status', flex: 2, minWidth: 104),
      AppTableColumn.center('Actions', flex: 3, minWidth: 140),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: salesReturns.length,
      onRowTap: onSalesReturnTap == null ? null : (_) => onSalesReturnTap!(),
      cellBuilder: (context, row, col) {
        final r = salesReturns[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(r.receiptNo ?? '-',
                bold: true, color: AppColors.primaryColor(context));
          case 2:
            return AppTableText(r.customerName ?? '-');
          case 3:
            return AppTableText(_formatDate(r.returnDate));
          case 4:
            return AppTableMoney(AppTableMoney.parse(r.returnAmount),
                bold: true);
          case 5:
            return AppTableText(r.paymentMethod ?? '-', muted: true);
          case 6:
            return AppTableText(r.reason ?? '-', muted: true);
          case 7:
            return AppTableText('${r.items?.length ?? 0}',
                align: AppCellAlign.end);
          case 8:
            return AppStatusPill((r.status ?? '-').capitalize(),
                color: _getStatusColor(r.status ?? ''));
          default:
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTableAction(
                  icon: Icons.visibility_outlined,
                  tooltip: 'View details',
                  color: AppColors.info,
                  onPressed: () => _showViewDialog(context, r),
                ),
                if (r.status == 'pending') ...[
                  AppTableAction(
                    icon: Icons.check_circle_outline,
                    tooltip: 'Approve return',
                    color: AppColors.success,
                    onPressed: () => _confirmApprove(context, r),
                  ),
                  AppTableAction(
                    icon: Icons.block_outlined,
                    tooltip: 'Reject return',
                    color: AppColors.warning,
                    onPressed: () => _confirmReject(context, r),
                  ),
                ],
                if (r.status == 'approved')
                  AppTableAction(
                    icon: Icons.done_all_rounded,
                    tooltip: 'Mark as completed',
                    color: AppColors.success,
                    onPressed: () => _confirmComplete(context, r),
                  ),
                if (r.status == 'pending' || r.status == 'rejected')
                  AppTableAction(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete return',
                    color: AppColors.danger,
                    onPressed: () => _confirmDelete(context, r),
                  ),
              ],
            );
        }
      },
    );
  }

  Widget _buildMobileList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: salesReturns.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final salesReturn = salesReturns[index];
        final statusColor = _getStatusColor(salesReturn.status ?? '');
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          color: AppColors.bottomNavBg(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryColor(
                        context,
                      ).withValues(alpha: 0.1),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppColors.primaryColor(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            salesReturn.receiptNo ?? 'N/A',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.text(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            salesReturn.customerName ?? 'N/A',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.text(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '৳${(salesReturn.returnAmount ?? 0).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            (salesReturn.status ?? 'N/A').toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(salesReturn.returnDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.text(context),
                        ),
                      ),
                    ],
                  ),
                  childrenPadding: const EdgeInsets.only(top: 4),
                  children: [
                    if ((salesReturn.reason ?? '').isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Reason:',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.text(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          salesReturn.reason ?? 'No reason provided',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.text(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if ((salesReturn.items).isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Returned Items (${salesReturn.items.length}):',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.text(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...salesReturn.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.productName ?? 'Unknown',
                                  style: AppTextStyle.body(context),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Qty: ${item.quantity}',
                                style: AppTextStyle.body(context),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '৳${item.total?.toStringAsFixed(2) ?? "0.00"}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: _mobileActionButtons(context, salesReturn),
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

  List<Widget> _mobileActionButtons(
    BuildContext context,
    SalesReturnModel salesReturn,
  ) {
    final List<Widget> actions = [];

    if (salesReturn.status == 'pending') {
      actions.add(
        _mobileIconButton(
          icon: Icons.check,
          color: AppColors.success,
          tooltip: 'Approve',
          onPressed: () => _confirmApprove(context, salesReturn),
        ),
      );
      actions.add(const SizedBox(width: 8));
      actions.add(
        _mobileIconButton(
          icon: Icons.close,
          color: AppColors.danger,
          tooltip: 'Reject',
          onPressed: () => _confirmReject(context, salesReturn),
        ),
      );
      actions.add(const SizedBox(width: 8));
    }

    if (salesReturn.status == 'approved') {
      actions.add(
        _mobileIconButton(
          icon: Icons.done_all,
          color: AppColors.info,
          tooltip: 'Complete',
          onPressed: () => _confirmComplete(context, salesReturn),
        ),
      );
      actions.add(const SizedBox(width: 8));
    }

    actions.add(
      _mobileIconButton(
        icon: Icons.visibility,
        color: AppColors.success,
        tooltip: 'View',
        onPressed: () => _showViewDialog(context, salesReturn),
      ),
    );
    actions.add(const SizedBox(width: 8));

    if (salesReturn.status == 'pending' || salesReturn.status == 'rejected') {
      actions.add(
        _mobileIconButton(
          icon: Icons.delete,
          color: AppColors.danger,
          tooltip: 'Delete',
          onPressed: () => _confirmDelete(context, salesReturn),
        ),
      );
    }

    return actions;
  }

  Widget _mobileIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: color),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }

  // ----- EXISTING TABLE BUILDERS -----
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'approved':
        return AppColors.info;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.danger;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SalesReturnModel salesReturn,
  ) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (shouldDelete && context.mounted) {
      context.read<SalesReturnBloc>().add(
        DeleteSalesReturn(context: context, id: salesReturn.id),
      );
    }
  }

  Future<void> _confirmApprove(
    BuildContext context,
    SalesReturnModel salesReturn,
  ) async {
    final confirmed = await showAppPopover<bool>(
      context: context,
      builder: (context) => AppPopoverCard(
        backgroundColor: AppColors.bottomNavBg(context),
        title: Text(
          'Approve Sales Return',
          style: AppTextStyle.titleMedium(context),
        ),
        content: Text(
          'Are you sure you want to approve sales return ${salesReturn.receiptNo ?? ''}?',
      style: AppTextStyle.body(context),  ),
        actions: [

          AppButton(
            size: 100,
            isOutlined: true,
            textColor: AppColors.errorColor(context),
            onPressed: () => Navigator.pop(context, false),
            name: "Cancel",
          ),
          AppButton(
            size: 100,
            onPressed: () => Navigator.pop(context, true),
            name: "Approve",
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<SalesReturnBloc>().add(
        SalesReturnApprove(context: context, id: salesReturn.id),
      );
    }
  }

  Future<void> _confirmReject(
    BuildContext context,
    SalesReturnModel salesReturn,
  ) async {
    final confirmed = await showAppPopover<bool>(
      context: context,
      builder: (context) => AppPopoverCard(
        backgroundColor: AppColors.bottomNavBg(context),
        title:  Text('Reject Sales Return',style: AppTextStyle.titleMedium(context),),
        content: Text(
          'Are you sure you want to reject sales return ${salesReturn.receiptNo ?? ''}?',
        style: AppTextStyle.body(context),),
        actions: [
          AppButton(
            size: 100,
            isOutlined: true,
            textColor: AppColors.errorColor(context),
            onPressed: () => Navigator.pop(context, false),
            name: "Cancel",
          ),
          AppButton(
            size: 100,
            onPressed: () => Navigator.pop(context, true),
            name: "Approve",
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<SalesReturnBloc>().add(
        SalesReturnReject(context: context, id: salesReturn.id),
      );
    }
  }

  Future<void> _confirmComplete(
    BuildContext context,
    SalesReturnModel salesReturn,
  ) async {
    final confirmed = await showAppPopover<bool>(
      context: context,
      builder: (context) => AppPopoverCard(
        title: const Text('Complete Sales Return'),
        content: Text(
          'Are you sure you want to mark sales return ${salesReturn.receiptNo ?? ''} as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<SalesReturnBloc>().add(
        SalesReturnComplete(context: context, id: salesReturn.id),
      );
    }
  }

  void _showViewDialog(BuildContext context, SalesReturnModel salesReturn) {
    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverShell(
          backgroundColor: AppColors.bottomNavBg(context),
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: AppSizes.width(context) * 0.50,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sales Return Details - ${salesReturn.receiptNo ?? "N/A"}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Customer:',
                    salesReturn.customerName ?? 'N/A',context
                  ),
                  _buildDetailRow(
                    'Return Date:',
                    _formatDate(salesReturn.returnDate),context
                  ),
                  _buildDetailRow(
                    'Return Amount:',
                    '৳${(salesReturn.returnAmount ?? 0).toStringAsFixed(2)}',context
                  ),
                  _buildDetailRow(
                    'Status:',
                    salesReturn.status?.toUpperCase() ?? 'N/A',context
                  ),
                  _buildDetailRow(
                    'Payment Method:',
                    salesReturn.paymentMethod ?? 'N/A',context
                  ),
                  _buildDetailRow(
                    'Reason:',
                    salesReturn.reason ?? 'No reason provided',context
                  ),
                  if (salesReturn.items.isNotEmpty) ...[
                    const SizedBox(height: 8),
                     Text(
                      'Returned Items:',
                      style: AppTextStyle.bodyLarge(context)
                    ),
                    const SizedBox(height: 8),
                    ...salesReturn.items.map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.productName ?? 'Unknown Product',
                                style:  TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.text(context)
                                ),
                              ),
                            ),
                            Text('Qty: ${item.quantity}',style: AppTextStyle.body(context),),
                            const SizedBox(width: 8),
                            Text('Damage: ${item.damageQuantity}',style: AppTextStyle.body(context)),
                            const SizedBox(width: 16),
                            Text(
                              '৳${item.total?.toStringAsFixed(2) ?? "0.00"}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildDetailRow(String label, String value,BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style:
              AppTextStyle.body(context)
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: AppTextStyle.body(context))),
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
            color: Colors.grey.withValues(alpha: 0.1),
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
            Icons.assignment_return_outlined,
            size: 48,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Sales Returns Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sales returns will appear here when created',
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
