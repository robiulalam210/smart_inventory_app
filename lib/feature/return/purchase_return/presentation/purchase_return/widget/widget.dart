import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../core/configs/app_colors.dart';
import '../../../../../../core/configs/app_sizes.dart';
import '../../../../../../core/configs/app_text.dart';
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
        const numColumns = 7; // Return No, Supplier, Date, Total Amount, Reason, Status, Actions
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
                          headingRowColor: MaterialStateProperty.all(
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
                                _buildDataCell(purchaseReturn.returnDate.toString(), dynamicColumnWidth),
                                _buildDataCell(purchaseReturn.returnAmount.toString(), dynamicColumnWidth),
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
              color: statusColor.withOpacity(0.1),
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

            // Edit Button
            _buildActionButton(
              icon: Iconsax.edit,
              color: Colors.blue,
              tooltip: 'Edit purchase return',
              onPressed: () => _showEditDialog(context, purchaseReturn),
            ),

            // Delete Button
            _buildActionButton(
              icon: HugeIcons.strokeRoundedDeleteThrow,
              color: Colors.red,
              tooltip: 'Delete purchase return',
              onPressed: () => _confirmDelete(context, purchaseReturn),
            ),
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


  Future<void> _confirmDelete(BuildContext context, PurchaseReturnModel purchaseReturn) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (shouldDelete && context.mounted) {
      context.read<PurchaseReturnBloc>().add(
          DeletePurchaseReturn(context,id: purchaseReturn.id.toString(),  )
      );
    }
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
                _buildDetailRow('Return Date:', purchaseReturn.returnDate.toString()),
                _buildDetailRow('Total Amount:', '${purchaseReturn.returnAmount?.toString() ?? "0.00"}'),
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
                  ...purchaseReturn.items!.map((item) =>
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
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
                      )
                  ).toList(),
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
    // Implement edit dialog logic
    // This would typically open a form to edit the purchase return
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
            Icons.assignment_return_outlined,
            size: 48,
            color: Colors.grey.withOpacity(0.5),
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