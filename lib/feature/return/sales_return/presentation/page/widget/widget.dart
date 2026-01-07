import 'package:google_fonts/google_fonts.dart';
import '/feature/return/sales_return/data/model/sales_return_model.dart';

import '../../../../../../core/configs/configs.dart';
import '../../../../../../core/widgets/delete_dialog.dart';
import '../../sales_return_bloc/sales_return_bloc.dart';

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

    // Existing desktop/table layout
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 11;
        const minColumnWidth = 100.0;

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
                          headingRowColor: WidgetStateProperty.all(
                            AppColors.primaryColor,
                          ),
                          dataTextStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          rows: _buildTableRows(context, dynamicColumnWidth),
                          columns: _buildColumns(dynamicColumnWidth),
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

  // MOBILE VIEW
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
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppColors.primaryColor,
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
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            salesReturn.customerName ?? 'N/A',
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
                          '৳${(salesReturn.returnAmount ?? 0).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                const SizedBox(height: 8),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(salesReturn.returnDate),
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                  childrenPadding: const EdgeInsets.only(top: 8),
                  children: [
                    if ((salesReturn.reason ?? '').isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Reason:',
                          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.blackColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          salesReturn.reason ?? 'No reason provided',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if ((salesReturn.items).isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Returned Items (${salesReturn.items.length}):',
                          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.blackColor),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...salesReturn.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(child: Text(item.productName ?? 'Unknown')),
                            const SizedBox(width: 8),
                            Text('Qty: ${item.quantity}'),
                            const SizedBox(width: 12),
                            Text('৳${item.total?.toStringAsFixed(2) ?? "0.00"}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, color: Colors.red)),
                          ],
                        ),
                      )),
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

  List<Widget> _mobileActionButtons(BuildContext context, SalesReturnModel salesReturn) {
    final List<Widget> actions = [];

    if (salesReturn.status == 'pending') {
      actions.add(_mobileIconButton(
        icon: Icons.check,
        color: Colors.green,
        tooltip: 'Approve',
        onPressed: () => _confirmApprove(context, salesReturn),
      ));
      actions.add(const SizedBox(width: 8));
      actions.add(_mobileIconButton(
        icon: Icons.close,
        color: Colors.red,
        tooltip: 'Reject',
        onPressed: () => _confirmReject(context, salesReturn),
      ));
      actions.add(const SizedBox(width: 8));
    }

    if (salesReturn.status == 'approved') {
      actions.add(_mobileIconButton(
        icon: Icons.done_all,
        color: Colors.blue,
        tooltip: 'Complete',
        onPressed: () => _confirmComplete(context, salesReturn),
      ));
      actions.add(const SizedBox(width: 8));
    }

    actions.add(_mobileIconButton(
      icon: Icons.visibility,
      color: Colors.green,
      tooltip: 'View',
      onPressed: () => _showViewDialog(context, salesReturn),
    ));
    actions.add(const SizedBox(width: 8));

    if (salesReturn.status == 'pending' || salesReturn.status == 'rejected') {
      actions.add(_mobileIconButton(
        icon: Icons.delete,
        color: Colors.red,
        tooltip: 'Delete',
        onPressed: () => _confirmDelete(context, salesReturn),
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

  // ----- EXISTING TABLE BUILDERS -----
  List<DataColumn> _buildColumns(double columnWidth) {
    return [
      DataColumn(
        label: SizedBox(
          width: columnWidth * 0.6,
          child: const Text('#', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Receipt No', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Customer', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Return Date', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Return Amount', textAlign: TextAlign.center),
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
          width: columnWidth,
          child: const Text('Payment Method', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth * 1.2,
          child: const Text('Reason', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth * 0.8,
          child: const Text('Items', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth * 1.5,
          child: const Text('Actions', textAlign: TextAlign.center),
        ),
      ),
    ];
  }

  List<DataRow> _buildTableRows(BuildContext context, double columnWidth) {
    return salesReturns.asMap().entries.map((entry) {
      final index = entry.key;
      final salesReturn = entry.value;

      return DataRow(
        color: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
            return index % 2 == 0 ? Colors.grey.withValues(alpha: 0.03) : Colors.transparent;
          },
        ),
        onSelectChanged: onSalesReturnTap != null ? (_) => onSalesReturnTap!() : null,
        cells: [
          _buildDataCell('${index + 1}', columnWidth * 0.6),
          _buildDataCell(salesReturn.receiptNo ?? 'N/A', columnWidth),
          _buildDataCell(salesReturn.customerName ?? 'N/A', columnWidth),
          _buildDataCell(_formatDate(salesReturn.returnDate), columnWidth),
          _buildAmountCell(double.tryParse(salesReturn.returnAmount.toString()), columnWidth),
          _buildStatusCell(salesReturn.status, columnWidth),
          _buildDataCell(salesReturn.paymentMethod ?? 'N/A', columnWidth),
          _buildReasonCell(salesReturn.reason, columnWidth * 1.2),
          _buildItemsCell(salesReturn.items, columnWidth * 0.8),
          _buildActionCell(salesReturn, context, columnWidth * 1.5),
        ],
      );
    }).toList();
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

  DataCell _buildAmountCell(double? amount, double width) {
    final amountText = amount != null ? amount.toStringAsFixed(2) : 'N/A';

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              amountText,
              style: const TextStyle(
                color: Colors.red,
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

  DataCell _buildStatusCell(String? status, double width) {
    final statusText = status ?? 'N/A';
    final statusColor = _getStatusColor(statusText);

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
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

  DataCell _buildReasonCell(String? reason, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          reason ?? 'No reason provided',
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

  DataCell _buildItemsCell(List<SalesReturnItem>? items, double width) {
    final itemsCount = items?.length ?? 0;

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              itemsCount.toString(),
              style: const TextStyle(
                color: Colors.blue,
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

  DataCell _buildActionCell(SalesReturnModel salesReturn, BuildContext context, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status-based actions
            if (salesReturn.status == 'pending') ...[
              _buildActionButton(
                icon: Icons.check,
                color: Colors.green,
                tooltip: 'Approve return',
                onPressed: () => _confirmApprove(context, salesReturn),
              ),
              const SizedBox(width: 4),
              _buildActionButton(
                icon: Icons.close,
                color: Colors.red,
                tooltip: 'Reject return',
                onPressed: () => _confirmReject(context, salesReturn),
              ),
              const SizedBox(width: 4),
            ],

            if (salesReturn.status == 'approved') ...[
              _buildActionButton(
                icon: Icons.done_all,
                color: Colors.blue,
                tooltip: 'Mark as completed',
                onPressed: () => _confirmComplete(context, salesReturn),
              ),
              const SizedBox(width: 4),
            ],

            // View Button
            _buildActionButton(
              icon: Icons.visibility,
              color: Colors.green,
              tooltip: 'View details',
              onPressed: () => _showViewDialog(context, salesReturn),
            ),
            const SizedBox(width: 4),

            // Delete Button (only for pending/rejected)
            if (salesReturn.status == 'pending' || salesReturn.status == 'rejected')
              _buildActionButton(
                icon: Icons.delete,
                color: Colors.red,
                tooltip: 'Delete return',
                onPressed: () => _confirmDelete(context, salesReturn),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _confirmDelete(BuildContext context, SalesReturnModel salesReturn) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (shouldDelete && context.mounted) {
      context.read<SalesReturnBloc>().add(
        DeleteSalesReturn(
          context: context,
          id: salesReturn.id,
        ),
      );
    }
  }

  Future<void> _confirmApprove(BuildContext context, SalesReturnModel salesReturn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Sales Return'),
        content: Text('Are you sure you want to approve sales return ${salesReturn.receiptNo ?? ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<SalesReturnBloc>().add(
        SalesReturnApprove(
          context: context,
          id: salesReturn.id,
        ),
      );
    }
  }

  Future<void> _confirmReject(BuildContext context, SalesReturnModel salesReturn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Sales Return'),
        content: Text('Are you sure you want to reject sales return ${salesReturn.receiptNo ?? ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<SalesReturnBloc>().add(
        SalesReturnReject(
          context: context,
          id: salesReturn.id,
        ),
      );
    }
  }

  Future<void> _confirmComplete(BuildContext context, SalesReturnModel salesReturn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Sales Return'),
        content: Text('Are you sure you want to mark sales return ${salesReturn.receiptNo ?? ''} as completed?'),
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
        SalesReturnComplete(
          context: context,
          id: salesReturn.id,
        ),
      );
    }
  }

  void _showViewDialog(BuildContext context, SalesReturnModel salesReturn) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Customer:', salesReturn.customerName ?? 'N/A'),
                  _buildDetailRow('Return Date:', _formatDate(salesReturn.returnDate)),
                  _buildDetailRow('Return Amount:', '৳${(salesReturn.returnAmount ?? 0).toStringAsFixed(2)}'),
                  _buildDetailRow('Status:', salesReturn.status?.toUpperCase() ?? 'N/A'),
                  _buildDetailRow('Payment Method:', salesReturn.paymentMethod ?? 'N/A'),
                  _buildDetailRow('Reason:', salesReturn.reason ?? 'No reason provided'),
                  if (salesReturn.items.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Returned Items:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...salesReturn.items.map((item) => Container(
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
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text('Qty: ${item.quantity}'),
                          const SizedBox(width: 8),
                          Text('Damage: ${item.damageQuantity}'),
                          const SizedBox(width: 16),
                          Text(
                            '৳${item.total?.toStringAsFixed(2) ?? "0.00"}',
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