import 'package:google_fonts/google_fonts.dart';

import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/widgets/delete_dialog.dart';
import '../../../data/model/purchase_return_model.dart';
import '../../bloc/purchase_return/purchase_return_bloc.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

class PurchaseReturnTableCard extends StatelessWidget {
  final List<PurchaseReturnModel> purchaseReturns;
  final VoidCallback? onPurchaseReturnTap;

  const PurchaseReturnTableCard({
    super.key,
    required this.purchaseReturns,
    this.onPurchaseReturnTap,
  });

  @override
  Widget build(BuildContext context) {
    if (purchaseReturns.isEmpty) return _buildEmptyState();

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600; // breakpoint - adjust if needed

    if (isMobile) return _buildMobileList(context);

    // Desktop / Tablet: AppDataTable
    const columns = [
      AppTableColumn('Return No', flex: 2, minWidth: 110),
      AppTableColumn('Supplier', flex: 3, minWidth: 150),
      AppTableColumn('Date', flex: 2, minWidth: 100),
      AppTableColumn.numeric('Amount', flex: 2, minWidth: 110),
      AppTableColumn('Reason', flex: 3, minWidth: 140),
      AppTableColumn.center('Status', flex: 2, minWidth: 104),
      AppTableColumn.center('Actions', flex: 3, minWidth: 150),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: purchaseReturns.length,
      onRowTap:
          onPurchaseReturnTap == null ? null : (_) => onPurchaseReturnTap!(),
      cellBuilder: (context, row, col) {
        final pr = purchaseReturns[row];
        final status = (pr.status ?? '').toLowerCase();
        switch (col) {
          case 0:
            return AppTableText(pr.invoiceNo ?? '-',
                bold: true, color: AppColors.primaryColor(context));
          case 1:
            return AppTableText(pr.supplier ?? '-');
          case 2:
            return AppTableText(pr.returnDate != null
                ? _formatDateSafe(pr.returnDate!)
                : '-');
          case 3:
            return AppTableMoney(AppTableMoney.parse(pr.returnAmount),
                bold: true);
          case 4:
            return AppTableText(pr.reason ?? '-', muted: true);
          case 5:
            return AppStatusPill((pr.status ?? '-').capitalize(),
                color: _getStatusColor(pr.status ?? ''));
          default:
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTableAction(
                  icon: Icons.visibility_outlined,
                  tooltip: 'View',
                  color: AppColors.info,
                  onPressed: () => _showViewDialog(context, pr),
                ),
                if (status == 'pending') ...[
                  AppTableAction(
                    icon: Icons.edit_outlined,
                    tooltip: 'Edit',
                    color: AppColors.info,
                    onPressed: () => _showEditDialog(context, pr),
                  ),
                  AppTableAction(
                    icon: Icons.check_circle_outline,
                    tooltip: 'Approve',
                    color: AppColors.success,
                    onPressed: () => _confirmApprove(context, pr),
                  ),
                  AppTableAction(
                    icon: Icons.block_outlined,
                    tooltip: 'Reject',
                    color: AppColors.warning,
                    onPressed: () => _confirmReject(context, pr),
                  ),
                ],
                if (status == 'approved')
                  AppTableAction(
                    icon: Icons.done_all_rounded,
                    tooltip: 'Complete',
                    color: AppColors.success,
                    onPressed: () => _confirmComplete(context, pr),
                  ),
                if (status == 'pending' || status == 'rejected')
                  AppTableAction(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete',
                    color: AppColors.danger,
                    onPressed: () => _confirmDelete(context, pr),
                  ),
              ],
            );
        }
      },
    );
  }

  // MOBILE LIST VIEW
  Widget _buildMobileList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: purchaseReturns.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final pr = purchaseReturns[index];
        final statusColor = _getStatusColor(pr.status ?? '');
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryColor(context).withValues(alpha: 0.1),
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
                            pr.invoiceNo ?? 'N/A',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pr.supplier ?? 'N/A',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          pr.returnAmount != null ? pr.returnAmount!.toString() : '0.00',
                          style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            (pr.status ?? 'N/A').toUpperCase(),
                            style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if ((pr.reason ?? '').isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Reason:', style: TextStyle(fontWeight: FontWeight.w700, color:AppColors.text(context))),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(pr.reason ?? 'No reason provided', style: const TextStyle(fontSize: 13)),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _mobileActionButtons(context, pr),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _mobileActionButtons(BuildContext context, PurchaseReturnModel pr) {
    final List<Widget> actions = [];

    actions.add(_mobileIconButton(
      icon: Icons.visibility,
      color: AppColors.success,
      tooltip: 'View',
      onPressed: () => _showViewDialog(context, pr),
    ));

    final status = pr.status?.toLowerCase() ?? 'pending';

    if (status == 'pending') {
      actions.add(const SizedBox(width: 8));
      actions.add(_mobileIconButton(
        icon: Icons.edit,
        color: AppColors.info,
        tooltip: 'Edit',
        onPressed: () => _showEditDialog(context, pr),
      ));
      actions.add(const SizedBox(width: 8));
      actions.add(_mobileIconButton(
        icon: Icons.check,
        color: AppColors.success,
        tooltip: 'Approve',
        onPressed: () => _confirmApprove(context, pr),
      ));
      actions.add(const SizedBox(width: 8));
      actions.add(_mobileIconButton(
        icon: Icons.close,
        color: AppColors.danger,
        tooltip: 'Reject',
        onPressed: () => _confirmReject(context, pr),
      ));
    } else if (status == 'approved') {
      actions.add(const SizedBox(width: 8));
      actions.add(_mobileIconButton(
        icon: Icons.done,
        color: AppColors.success,
        tooltip: 'Complete',
        onPressed: () => _confirmComplete(context, pr),
      ));
    }

    if (status == 'pending' || status == 'rejected') {
      actions.add(const SizedBox(width: 8));
      actions.add(_mobileIconButton(
        icon: Icons.delete,
        color: AppColors.danger,
        tooltip: 'Delete',
        onPressed: () => _confirmDelete(context, pr),
      ));
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

  // ----- TABLE HELPERS -----
  Widget _buildActionButton({required IconData icon, required Color color, required String tooltip, required VoidCallback onPressed}) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
    );
  }

  // ----- UTILITIES & DIALOGS -----
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

  String _formatDateSafe(String dateString) {
    try {
      final d = DateTime.parse(dateString);
      return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
    } catch (_) {
      return dateString;
    }
  }

  Future<void> _confirmDelete(BuildContext context, PurchaseReturnModel pr) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (shouldDelete && context.mounted) {
      // adjust the event payload to match your bloc event signature
      // context.read<PurchaseReturnBloc>().add(DeletePurchaseReturn(id: pr.id.toString()));
    }
  }

  Future<void> _confirmApprove(BuildContext context, PurchaseReturnModel pr) async {
    final confirmed = await _showConfirmationDialog(context, title: 'Approve Purchase Return', content: 'Are you sure you want to approve this purchase return?');
    if (confirmed && context.mounted) {
      context.read<PurchaseReturnBloc>().add(PurchaseReturnApprove(id: pr.id.toString()));
    }
  }

  Future<void> _confirmReject(BuildContext context, PurchaseReturnModel pr) async {
    final confirmed = await _showConfirmationDialog(context, title: 'Reject Purchase Return', content: 'Are you sure you want to reject this purchase return?');
    if (confirmed && context.mounted) {
      context.read<PurchaseReturnBloc>().add(PurchaseReturnReject(id: pr.id.toString()));
    }
  }

  Future<void> _confirmComplete(BuildContext context, PurchaseReturnModel pr) async {
    final confirmed = await _showConfirmationDialog(context, title: 'Complete Purchase Return', content: 'Are you sure you want to mark this purchase return as complete?');
    if (confirmed && context.mounted) {
      context.read<PurchaseReturnBloc>().add(PurchaseReturnComplete(id: pr.id.toString()));
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context, {required String title, required String content}) async {
    final res = await showAppPopover<bool>(
      context: context,
      builder: (context) => AppPopoverCard(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor(context)), child: const Text('Confirm')),
        ],
      ),
    );
    return res ?? false;
  }

  void _showViewDialog(BuildContext context, PurchaseReturnModel pr) {
    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverShell(
          child: Container(
            width: AppSizes.width(context) * 0.50,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Purchase Return Details - ${pr.invoiceNo ?? "N/A"}', style: AppTextStyle.cardLevelHead(context)),
                  const SizedBox(height: 16),
                  _buildDetailRow('Return No:', pr.invoiceNo ?? 'N/A'),
                  _buildDetailRow('Supplier:', pr.supplier ?? 'N/A'),
                  _buildDetailRow('Return Date:', pr.returnDate != null ? _formatDateSafe(pr.returnDate!) : 'N/A'),
                  _buildDetailRow('Total Amount:', pr.returnAmount != null ? pr.returnAmount!.toString() : '0.00'),
                  _buildDetailRow('Status:', pr.status?.toUpperCase() ?? 'PENDING'),
                  _buildDetailRow('Reason:', pr.reason ?? 'No reason provided'),
                  if (pr.items?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 16),
                    const Text('Returned Items:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    ...pr.items!.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(4)),
                      child: Row(
                        children: [
                          Expanded(child: Text(item.productName ?? 'Unknown Product', style: const TextStyle(fontWeight: FontWeight.w500))),
                          Text('Qty: ${item.quantity ?? 0}'),
                          const SizedBox(width: 16),
                          Text(item.total?.toString() ?? "0.00", style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.danger)),
                        ],
                      ),
                    )),
                  ],
                  const SizedBox(height: 20),
                  Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, PurchaseReturnModel pr) {
    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverShell(
          child: Container(
            width: AppSizes.width(context) * 0.60,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit Purchase Return - ${pr.invoiceNo}', style: AppTextStyle.cardLevelHead(context)),
                const SizedBox(height: 20),
                const Text('Edit functionality would be implemented here'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Save Changes')),
                  ],
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
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AppImages.noData, width: 200, height: 200),
          const SizedBox(height: 16),
          Text('No Purchase Returns Found', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Purchase returns will appear here when created', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}