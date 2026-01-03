import 'package:google_fonts/google_fonts.dart';
// Add this import

import '../../../../../../core/configs/configs.dart'; // Add this for AppImages
import '../../../../../../core/widgets/delete_dialog.dart';
import '../../../data/model/purchase_return_model.dart';
import '../../bloc/purchase_return/purchase_return_bloc.dart';

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
    if (purchaseReturns.isEmpty) {
      return _buildEmptyState();
    }

    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 7;
        const minColumnWidth = 120.0;

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1), // FIXED: withOpacity instead of withValues
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
                          dataRowMinHeight: 40,
                          dataRowMaxHeight: 40,
                          columnSpacing: 8,
                          horizontalMargin: 12,
                          dividerThickness: 0.5,
                          headingRowHeight: 40,
                          headingTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          headingRowColor: MaterialStateProperty.all( // FIXED: MaterialStateProperty instead of WidgetStateProperty
                            AppColors.primaryColor,
                          ),
                          dataTextStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: purchaseReturns.asMap().entries.map((entry) {
                            final purchaseReturn = entry.value;
                            return DataRow(
                              onSelectChanged: onPurchaseReturnTap != null
                                  ? (_) => onPurchaseReturnTap!()
                                  : null,
                              cells: [
                                _buildDataCell(purchaseReturn.invoiceNo ?? 'N/A', dynamicColumnWidth),
                                _buildDataCell(purchaseReturn.supplier ?? 'N/A', dynamicColumnWidth),
                                _buildDataCell(
                                  purchaseReturn.returnDate != null
                                      ? _formatDate(DateTime.parse(purchaseReturn.returnDate!))
                                      : 'N/A',
                                  dynamicColumnWidth,
                                ),
                                _buildDataCell(
                                  '${purchaseReturn.returnAmount?.toString() ?? "0.00"}',
                                  dynamicColumnWidth,
                                ),
                                _buildReasonCell(purchaseReturn.reason, dynamicColumnWidth),
                                _buildStatusCell(purchaseReturn.status, dynamicColumnWidth),
                                _buildActionCell(purchaseReturn, context, dynamicColumnWidth),
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
          width: columnWidth,
          child: const Text('Return No', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Supplier', textAlign: TextAlign.center),
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
          child: const Text('Total Amount', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Reason', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Status', textAlign: TextAlign.center),
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
        ),
      ),
    );
  }

  DataCell _buildReasonCell(String? reason, double width) {
    return DataCell(
      Tooltip(
        message: reason ?? 'No reason provided',
        child: SizedBox(
          width: width,
          child: Text(
            reason ?? 'N/A',
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
      ),
    );
  }

  DataCell _buildStatusCell(String? status, double width) {
    final statusText = status ?? 'Pending';
    final statusColor = _getStatusColor(statusText);

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1), // FIXED: withOpacity instead of withValues
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusText.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildActionCell(PurchaseReturnModel purchaseReturn, BuildContext context, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // View Button
            _buildActionButton(
              icon: HugeIcons.strokeRoundedView,
              color: Colors.green,
              tooltip: 'View purchase return details',
              onPressed: () => _showViewDialog(context, purchaseReturn),
            ),

            // Edit Button (only for pending status)
            if (purchaseReturn.status?.toLowerCase() == 'pending') ...[
              _buildActionButton(
                icon: Iconsax.edit,
                color: Colors.blue,
                tooltip: 'Edit purchase return',
                onPressed: () => _showEditDialog(context, purchaseReturn),
              ),
            ],

            // Status Action Buttons
            if (purchaseReturn.status?.toLowerCase() == 'pending') ...[
              _buildActionButton(
                icon: Iconsax.tick_circle,
                color: Colors.green,
                tooltip: 'Approve purchase return',
                onPressed: () => _confirmApprove(context, purchaseReturn),
              ),
              _buildActionButton(
                icon: Iconsax.close_circle,
                color: Colors.red,
                tooltip: 'Reject purchase return',
                onPressed: () => _confirmReject(context, purchaseReturn),
              ),
            ],

            if (purchaseReturn.status?.toLowerCase() == 'approved') ...[
              const SizedBox(width: 4),
              _buildActionButton(
                icon: Iconsax.tick_circle,
                color: Colors.green,
                tooltip: 'Complete purchase return',
                onPressed: () => _confirmComplete(context, purchaseReturn),
              ),
            ],

            // Delete Button (only for pending or rejected)
            if (purchaseReturn.status?.toLowerCase() == 'pending' ||
                purchaseReturn.status?.toLowerCase() == 'rejected') ...[
              const SizedBox(width: 4),
              _buildActionButton(
                icon: HugeIcons.strokeRoundedDeleteThrow,
                color: Colors.red,
                tooltip: 'Delete purchase return',
                onPressed: () => _confirmDelete(context, purchaseReturn),
              ),
            ],
          ],
        ),
      ),
    );
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'approved':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Future<void> _confirmDelete(BuildContext context, PurchaseReturnModel purchaseReturn) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (shouldDelete && context.mounted) {
      // FIXED: Proper DeletePurchaseReturn event call
      context.read<PurchaseReturnBloc>().add(
        DeletePurchaseReturn(
          id: purchaseReturn.id.toString(),
        context,
        ),
      );
    }
  }

  Future<void> _confirmApprove(BuildContext context, PurchaseReturnModel purchaseReturn) async {
    final shouldApprove = await _showConfirmationDialog(
      context,
      title: 'Approve Purchase Return',
      content: 'Are you sure you want to approve this purchase return?',
    );
    if (shouldApprove && context.mounted) {
      context.read<PurchaseReturnBloc>().add(
        PurchaseReturnApprove(id: purchaseReturn.id.toString()),
      );
    }
  }

  Future<void> _confirmReject(BuildContext context, PurchaseReturnModel purchaseReturn) async {
    final shouldReject = await _showConfirmationDialog(
      context,
      title: 'Reject Purchase Return',
      content: 'Are you sure you want to reject this purchase return?',
    );
    if (shouldReject && context.mounted) {
      context.read<PurchaseReturnBloc>().add(
        PurchaseReturnReject(id: purchaseReturn.id.toString()),
      );
    }
  }

  Future<void> _confirmComplete(BuildContext context, PurchaseReturnModel purchaseReturn) async {
    final shouldComplete = await _showConfirmationDialog(
      context,
      title: 'Complete Purchase Return',
      content: 'Are you sure you want to mark this purchase return as complete?',
    );
    if (shouldComplete && context.mounted) {
      context.read<PurchaseReturnBloc>().add(
        PurchaseReturnComplete(id: purchaseReturn.id.toString()),
      );
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context, {required String title, required String content}) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showViewDialog(BuildContext context, PurchaseReturnModel purchaseReturn) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: AppSizes.width(context) * 0.50,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Purchase Return Details - ${purchaseReturn.invoiceNo ?? "N/A"}',
                  style: AppTextStyle.cardLevelHead(context),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Return No:', purchaseReturn.invoiceNo ?? 'N/A'),
                _buildDetailRow('Supplier:', purchaseReturn.supplier ?? 'N/A'),
                _buildDetailRow(
                  'Return Date:',
                  purchaseReturn.returnDate != null
                      ? _formatDate(DateTime.parse(purchaseReturn.returnDate!))
                      : 'N/A',
                ),
                _buildDetailRow(
                  'Total Amount:',
                  '\$${purchaseReturn.returnAmount?.toString() ?? "0.00"}',
                ),
                _buildDetailRow('Status:', purchaseReturn.status?.toUpperCase() ?? 'PENDING'),
                _buildDetailRow('Reason:', purchaseReturn.reason ?? 'No reason provided'),

                // Add items list if available
                if (purchaseReturn.items?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Returned Items:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...purchaseReturn.items!.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05), // FIXED
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.productName ?? 'Unknown Product',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text('Qty: ${item.quantity ?? 0}'),
                        const SizedBox(width: 16),
                        Text(
                          '\$${item.total?.toString() ?? "0.00"}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  )),
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
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, PurchaseReturnModel purchaseReturn) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: AppSizes.width(context) * 0.60,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Purchase Return - ${purchaseReturn.invoiceNo}',
                  style: AppTextStyle.cardLevelHead(context),
                ),
                const SizedBox(height: 20),
                const Text('Edit functionality would be implemented here'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Save changes
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save Changes'),
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
            color: Colors.grey.withOpacity(0.1), // FIXED
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset( // FIXED: Now Lottie is imported
            AppImages.noData, // Make sure AppImages is imported
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          Text(
            'No Purchase Returns Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Purchase returns will appear here when created',
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