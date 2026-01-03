// lib/account_transfer/presentation/widget/account_transfer_card.dart
import 'package:google_fonts/google_fonts.dart';
import '/core/configs/configs.dart';

import '../../../data/model/account_transfer_model.dart';

class AccountTransferCard extends StatelessWidget {
  final List<AccountTransferModel> transfers;
  final Function(AccountTransferModel)? onExecute;
  final Function(AccountTransferModel)? onReverse;
  final Function(AccountTransferModel)? onCancel;
  final VoidCallback? onTransferTap;

  const AccountTransferCard({
    super.key,
    required this.transfers,
    this.onExecute,
    this.onReverse,
    this.onCancel,
    this.onTransferTap,
  });

  @override
  Widget build(BuildContext context) {
    if (transfers.isEmpty) {
      return _buildEmptyState();
    }

    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        const numColumns = 9; // Added columns for actions
        const columnSpacing = 10.0;
        const horizontalMargin = 12.0;
        const minColumnWidth = 120.0;

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
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: minColumnWidth * numColumns + (columnSpacing * (numColumns - 1)) + (horizontalMargin * 2),
                        minHeight: 200,
                      ),
                      child: DataTable(
                        dataRowMinHeight: 50,
                        dataRowMaxHeight: 60,
                        columnSpacing: columnSpacing,
                        horizontalMargin: horizontalMargin,
                        dividerThickness: 0.5,
                        headingRowHeight: 50,
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
                        columns: _buildColumns(minColumnWidth),
                        rows: transfers.asMap().entries.map((entry) {
                          final transfer = entry.value;
                          return DataRow(
                            color: WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                if (entry.key.isEven) {
                                  return Colors.grey.withValues(alpha: 0.03);
                                }
                                return null;
                              },
                            ),
                            onSelectChanged: onTransferTap != null
                                ? (_) => onTransferTap!()
                                : null,
                            cells: [
                              _buildDataCell(transfer.transferNo ?? "N/A", minColumnWidth * 0.8),
                              _buildDataCell(_formatDate(transfer.transferDate), minColumnWidth),
                              _buildDataCell(transfer.fromAccount?.name ?? "N/A", minColumnWidth * 1.2),
                              _buildDataCell(transfer.toAccount?.name ?? "N/A", minColumnWidth * 1.2),
                              _buildAmountCell(transfer.amount, minColumnWidth),
                              _buildStatusCell(transfer.status, minColumnWidth),
                              _buildTypeCell(transfer.transferType, minColumnWidth),
                              _buildReversalCell(transfer.isReversal, minColumnWidth * 0.6),
                              _buildActionsCell(context, transfer, minColumnWidth * 1.0),
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
        );
      },
    );
  }

  List<DataColumn> _buildColumns(double columnWidth) {
    return [
      DataColumn(
        label: SizedBox(
          width: columnWidth * 0.8,
          child: const Text(
            'Transfer No',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text(
            'Date',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth * 1.2,
          child: const Text(
            'From Account',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth * 1.2,
          child: const Text(
            'To Account',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text(
            'Amount',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text(
            'Status',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text(
            'Type',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth * 0.6,
          child: const Text(
            'Reversal',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth * 1.0,
          child: const Text(
            'Actions',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ];
  }

  DataCell _buildDataCell(String text, double width) {
    return DataCell(
      Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 4),
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
    final amountValue = double.tryParse(amount ?? '0') ?? 0;
    final isNegative = amountValue < 0;
    final color = isNegative ? Colors.red : Colors.green;

    return DataCell(
      Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            constraints: const BoxConstraints(
              minWidth: 80,
            ),
            child: Text(
              amountValue.abs().toStringAsFixed(2),
              style: GoogleFonts.inter(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildStatusCell(String? status, double width) {
    final statusText = status?.toUpperCase() ?? 'UNKNOWN';
    final color = _getStatusColor(status);

    return DataCell(
      Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            constraints: const BoxConstraints(
              minWidth: 80,
            ),
            child: Text(
              statusText,
              style: GoogleFonts.inter(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildTypeCell(String? type, double width) {
    final typeText = type?.replaceAll('_', ' ').toUpperCase() ?? 'UNKNOWN';
    final color = _getTypeColor(type);

    return DataCell(
      Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            constraints: const BoxConstraints(
              minWidth: 80,
            ),
            child: Text(
              typeText,
              style: GoogleFonts.inter(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildReversalCell(bool? isReversal, double width) {
    final isRev = isReversal ?? false;
    final color = isRev ? Colors.orange : Colors.grey;

    return DataCell(
      Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              isRev ? Icons.refresh : Icons.arrow_forward,
              size: 14,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildActionsCell(BuildContext context, AccountTransferModel transfer, double width) {
    final status = transfer.status?.toLowerCase();
    final isReversal = transfer.isReversal ?? false;

    return DataCell(
      Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Execute Button (only for pending transfers)
            if (status == 'pending' && !isReversal)
              IconButton(
                icon: const Icon(
                  Icons.play_arrow,
                  size: 16,
                  color: Colors.green,
                ),
                onPressed: () => onExecute?.call(transfer),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                tooltip: 'Execute Transfer',
              ),

            // Reverse Button (only for completed transfers that are not reversals)
            if (status == 'completed' && !isReversal)
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 16,
                  color: Colors.orange,
                ),
                onPressed: () => onReverse?.call(transfer),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                tooltip: 'Reverse Transfer',
              ),

            // Cancel Button (only for pending transfers)
            if (status == 'pending')
              IconButton(
                icon: const Icon(
                  Icons.cancel,
                  size: 16,
                  color: Colors.red,
                ),
                onPressed: () => onCancel?.call(transfer),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                tooltip: 'Cancel Transfer',
              ),

            // View Details Button (always visible)
            IconButton(
              icon: const Icon(
                Icons.visibility,
                size: 16,
                color: Colors.blue,
              ),
              onPressed: () {
                _showTransferDetails(context, transfer);
              },
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              tooltip: 'View Details',
            ),
          ],
        ),
      ),
    );
  }

  void _showTransferDetails(BuildContext context, AccountTransferModel transfer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Transfer Details',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Transfer No:', transfer.transferNo ?? 'N/A'),
              _buildDetailRow('Date:', _formatDateTime(transfer.transferDate)),
              _buildDetailRow('From Account:', transfer.fromAccount?.name ?? 'N/A'),
              _buildDetailRow('To Account:', transfer.toAccount?.name ?? 'N/A'),
              _buildDetailRow('Amount:', transfer.amount ?? '0.00'),
              _buildDetailRow('Status:', transfer.status?.toUpperCase() ?? 'UNKNOWN',
                color: _getStatusColor(transfer.status),
              ),
              _buildDetailRow('Type:', transfer.transferType?.replaceAll('_', ' ').toUpperCase() ?? 'UNKNOWN',
                color: _getTypeColor(transfer.transferType),
              ),
              _buildDetailRow('Is Reversal:', (transfer.isReversal ?? false) ? 'Yes' : 'No'),
              if (transfer.description != null && transfer.description!.isNotEmpty)
                _buildDetailRow('Description:', transfer.description!),
              if (transfer.referenceNo != null && transfer.referenceNo!.isNotEmpty)
                _buildDetailRow('Reference No:', transfer.referenceNo!),
              if (transfer.remarks != null && transfer.remarks!.isNotEmpty)
                _buildDetailRow('Remarks:', transfer.remarks!),
              if (transfer.createdByName != null && transfer.createdByName!.isNotEmpty)
                _buildDetailRow('Created By:', transfer.createdByName!),
              if (transfer.approvedByName != null && transfer.approvedByName!.isNotEmpty)
                _buildDetailRow('Approved By:', transfer.approvedByName!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'internal':
        return Colors.blue;
      case 'external':
        return Colors.purple;
      case 'adjustment':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
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
            Icons.compare_arrows,
            size: 48,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Transfers Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first transfer to get started',
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