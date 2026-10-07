import 'package:google_fonts/google_fonts.dart';
import '/core/configs/configs.dart';

import '../../../data/model/account_transfer_model.dart';




class MobileAccountTransferCard extends StatelessWidget {
  final List<AccountTransferModel> transfers;
  final Function(AccountTransferModel)? onExecute;
  final Function(AccountTransferModel)? onReverse;
  final Function(AccountTransferModel)? onCancel;
  final VoidCallback? onTransferTap;

  const MobileAccountTransferCard({
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transfers.length,
      itemBuilder: (context, index) {
        final transfer = transfers[index];
        return _buildTransferCard(context, transfer);
      },
    );
  }

  Widget _buildTransferCard(BuildContext context, AccountTransferModel transfer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(AppSizes.radius),

        border: Border.all(
          color: AppColors.greyColor(context).withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: () => _showTransferDetails(context, transfer),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Transfer #${transfer.transferNo}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.text(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(transfer.status),
                ],
              ),

              const SizedBox(height: 6),

              // Transfer Details
              _buildDetailRow('Date:', _formatDate(transfer.transferDate),context),
              _buildDetailRow('From:', transfer.fromAccount?.name ?? 'N/A',context),
              _buildDetailRow('To:', transfer.toAccount?.name ?? 'N/A',context),


              // Amount and Type Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAmountWidget(transfer.amount),
                  _buildTypeChip(transfer.transferType),
                ],
              ),


              // Actions Row
              if (_shouldShowActions(transfer))
                _buildActionButtons(context, transfer),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    final statusText = status?.toUpperCase() ?? 'UNKNOWN';
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTypeChip(String? type) {
    final typeText = type?.replaceAll('_', ' ').toUpperCase() ?? 'UNKNOWN';
    final color = _getTypeColor(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTypeIcon(type),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            typeText,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountWidget(String? amount) {
    final amountValue = double.tryParse(amount ?? '0') ?? 0;
    final isNegative = amountValue < 0;
    final color = isNegative ? AppColors.danger : AppColors.success;

    return Text(
      '\$${amountValue.abs().toStringAsFixed(2)}',
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.text(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.text(context),
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowActions(AccountTransferModel transfer) {
    final status = transfer.status?.toLowerCase();
    final isReversal = transfer.isReversal ?? false;

    return (status == 'pending' && !isReversal) ||
        (status == 'completed' && !isReversal) ||
        status == 'pending';
  }

  Widget _buildActionButtons(BuildContext context, AccountTransferModel transfer) {
    final status = transfer.status?.toLowerCase();
    final isReversal = transfer.isReversal ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Execute Button
        if (status == 'pending' && !isReversal)
          Expanded(
            child: _buildActionButton(
              context,
              'Execute',
              Icons.play_arrow,
              AppColors.success,
                  () => onExecute?.call(transfer),
            ),
          ),

        // Reverse Button
        if (status == 'completed' && !isReversal)
          Expanded(
            child: _buildActionButton(
              context,
              'Reverse',
              Icons.refresh,
              AppColors.warning,
                  () => onReverse?.call(transfer),
            ),
          ),

        // Cancel Button
        if (status == 'pending')
          Expanded(
            child: _buildActionButton(
              context,
              'Cancel',
              Icons.cancel,
              AppColors.danger,
                  () => onCancel?.call(transfer),
            ),
          ),

        // Details Button (always visible)
        Expanded(
          child: _buildActionButton(
            context,
            'Details',
            Icons.visibility,
            AppColors.info,
                () => _showTransferDetails(context, transfer),
          ),
        ),
      ].where((element) => element != null).cast<Widget>().toList(),
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      String text,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14, color: color),
        label: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
          backgroundColor: color.withValues(alpha: 0.05),
        ),
      ),
    );
  }

  void _showTransferDetails(BuildContext context, AccountTransferModel transfer) {
    showAppPopoverSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bottomNavBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transfer Details',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text(context),
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildDetailRowModal(context,'Transfer No:', transfer.transferNo ?? 'N/A'),
              _buildDetailRowModal(context,'Date:', _formatDateTime(transfer.transferDate)),
              _buildDetailRowModal(context,'From Account:', transfer.fromAccount?.name ?? 'N/A'),
              _buildDetailRowModal(context,'To Account:', transfer.toAccount?.name ?? 'N/A'),
              _buildDetailRowModal(context,'Amount:', '\$${transfer.amount ?? "0.00"}'),
              _buildDetailRowModal(context,'Status:', transfer.status?.toUpperCase() ?? 'UNKNOWN',
                color: _getStatusColor(transfer.status),
              ),
              _buildDetailRowModal(context,'Type:', transfer.transferType?.replaceAll('_', ' ').toUpperCase() ?? 'UNKNOWN',
                color: _getTypeColor(transfer.transferType),
              ),
              _buildDetailRowModal(context,'Reversal:', (transfer.isReversal ?? false) ? 'Yes' : 'No'),

              if (transfer.description != null && transfer.description!.isNotEmpty)
                _buildDetailRowModal(context,'Description:', transfer.description!),

              if (transfer.referenceNo != null && transfer.referenceNo!.isNotEmpty)
                _buildDetailRowModal(context,'Reference No:', transfer.referenceNo!),

              if (transfer.remarks != null && transfer.remarks!.isNotEmpty)
                _buildDetailRowModal(context,'Remarks:', transfer.remarks!),

              if (transfer.createdByName != null && transfer.createdByName!.isNotEmpty)
                _buildDetailRowModal(context,'Created By:', transfer.createdByName!),

              if (transfer.approvedByName != null && transfer.approvedByName!.isNotEmpty)
                _buildDetailRowModal(context,'Approved By:', transfer.approvedByName!),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRowModal(BuildContext context,String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppColors.text(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: color ??               AppColors.text(context)
                ,
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
        return AppColors.warning;
      case 'completed':
        return AppColors.success;
      case 'failed':
        return AppColors.danger;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'internal':
        return AppColors.info;
      case 'external':
        return Colors.purple;
      case 'adjustment':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'internal':
        return Icons.swap_horiz;
      case 'external':
        return Icons.arrow_forward;
      case 'adjustment':
        return Icons.tune;
      default:
        return Icons.compare_arrows;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compare_arrows,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.5),
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
              fontSize: 14,
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
  // Desktop টেবিল — AppDataTable
  Widget build(BuildContext context) {
    if (transfers.isEmpty) {
      return _buildEmptyState();
    }

    const columns = [
      AppTableColumn('Transfer No', flex: 2, minWidth: 110),
      AppTableColumn('Date', flex: 2, minWidth: 100),
      AppTableColumn('From', flex: 3, minWidth: 140),
      AppTableColumn('To', flex: 3, minWidth: 140),
      AppTableColumn.numeric('Amount', flex: 2, minWidth: 110),
      AppTableColumn.center('Status', flex: 2, minWidth: 104),
      AppTableColumn.center('Type', flex: 2, minWidth: 100),
      AppTableColumn.center('Actions', flex: 2, minWidth: 130),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: transfers.length,
      onRowTap: onTransferTap == null ? null : (_) => onTransferTap!(),
      cellBuilder: (context, row, col) {
        final t = transfers[row];
        final status = t.status?.toLowerCase();
        final isReversal = t.isReversal ?? false;
        switch (col) {
          case 0:
            return AppTableText(t.transferNo ?? '-',
                bold: true,
                color: AppColors.primaryColor(context),
                subtitle: isReversal ? 'Reversal' : null);
          case 1:
            return AppTableText(_formatDate(t.transferDate));
          case 2:
            return AppTableText(t.fromAccount?.name ?? '-');
          case 3:
            return AppTableText(t.toAccount?.name ?? '-');
          case 4:
            return AppTableMoney(AppTableMoney.parse(t.amount), bold: true);
          case 5:
            return AppStatusPill((t.status ?? '-').capitalize(),
                color: _getStatusColor(t.status));
          case 6:
            return AppStatusPill((t.transferType ?? '-').capitalize(),
                color: _getTypeColor(t.transferType));
          default:
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status == 'pending' && !isReversal)
                  AppTableAction(
                    icon: Icons.play_arrow_rounded,
                    tooltip: 'Execute transfer',
                    color: AppColors.success,
                    onPressed: () => onExecute?.call(t),
                  ),
                if (status == 'completed' && !isReversal)
                  AppTableAction(
                    icon: Icons.undo_rounded,
                    tooltip: 'Reverse transfer',
                    color: AppColors.warning,
                    onPressed: () => onReverse?.call(t),
                  ),
                if (status == 'pending')
                  AppTableAction(
                    icon: Icons.cancel_outlined,
                    tooltip: 'Cancel transfer',
                    color: AppColors.danger,
                    onPressed: () => onCancel?.call(t),
                  ),
                AppTableAction(
                  icon: Icons.visibility_outlined,
                  tooltip: 'View details',
                  color: AppColors.info,
                  onPressed: () => _showTransferDetails(context, t),
                ),
              ],
            );
        }
      },
    );
  }

  void _showTransferDetails(BuildContext context, AccountTransferModel transfer) {
    showAppPopover(
      context: context,
      builder: (context) => AppPopoverCard(
        title: Row(
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: AppColors.primaryColor(context),
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
        return AppColors.warning;
      case 'completed':
        return AppColors.success;
      case 'failed':
        return AppColors.danger;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'internal':
        return AppColors.info;
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
            Icons.compare_arrows,
            size: 48,
            color: Colors.grey.withValues(alpha: 0.5),
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