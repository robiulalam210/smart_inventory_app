// transactions/presentation/widgets/transaction_card.dart
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/configs/configs.dart';
import '../../data/model/transactions_model.dart';

class TransactionCard extends StatelessWidget {
  final List<TransactionsModel> transactions;
  final VoidCallback? onTransactionTap;

  const TransactionCard({
    super.key,
    required this.transactions,
    this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    return Responsive.isMobile(context)
        ? _buildMobileListView(context)
        : _buildDesktopTable();
  }

  // Desktop টেবিল — AppDataTable
  // (আগে header এ "Actions" লেখা ছিল কিন্তু cell এ expense head দেখাত —
  // এখন header "Head", আর টাকা $ নয় ৳ দিয়ে)
  Widget _buildDesktopTable() {
    const columns = [
      AppTableColumn('Transaction No', flex: 2, minWidth: 120),
      AppTableColumn('Account', flex: 3, minWidth: 140),
      AppTableColumn.center('Type', flex: 2, minWidth: 96),
      AppTableColumn.numeric('Amount', flex: 2, minWidth: 110),
      AppTableColumn('Description', flex: 3, minWidth: 150),
      AppTableColumn('Date', flex: 2, minWidth: 100),
      AppTableColumn.center('Status', flex: 2, minWidth: 104),
      AppTableColumn('Head', flex: 2, minWidth: 120),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: transactions.length,
      onRowTap:
          onTransactionTap == null ? null : (_) => onTransactionTap!(),
      cellBuilder: (context, row, col) {
        final t = transactions[row];
        final isCredit = t.transactionType?.toLowerCase() == 'credit';
        switch (col) {
          case 0:
            return AppTableText(t.transactionNo ?? '-',
                bold: true, color: AppColors.primaryColor(context));
          case 1:
            return AppTableText(t.accountName ?? '-');
          case 2:
            return AppStatusPill(isCredit ? 'Credit' : 'Debit',
                color: isCredit ? AppColors.success : AppColors.danger);
          case 3:
            final amount = AppTableMoney.parse(t.amount);
            return AppTableText(
              '${isCredit ? '+' : '−'} ৳${amount.toStringAsFixed(2)}',
              align: AppCellAlign.end,
              bold: true,
              color: isCredit ? AppColors.success : AppColors.danger,
            );
          case 4:
            return AppTableText(t.description ?? '-', muted: true);
          case 5:
            final d = t.transactionDate;
            return AppTableText(d == null
                ? '-'
                : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}');
          case 6:
            return AppStatusPill((t.status ?? '-').capitalize(),
                color: _txStatusColor(t.status));
          default:
            return AppTableText(t.expenseHead?.toString() ?? '-', muted: true);
        }
      },
    );
  }

  Color _txStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
        return AppColors.danger;
      case 'reversed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMobileListView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.bottomNavBg(context),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildMobileTransactionCard(transaction, index,context);
        },
      ),
    );
  }

  Widget _buildMobileTransactionCard(TransactionsModel transaction, int index,BuildContext context) {
    final isCredit = transaction.transactionType?.toLowerCase() == 'credit';
    final amountColor = isCredit ? AppColors.success : AppColors.danger;
    final prefix = isCredit ? '+' : '-';
    final amount = double.tryParse(transaction.amount ?? "0") ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
          // Header: Transaction No and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  transaction.transactionNo ?? "N/A",
                  style:  TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.text(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusChip(transaction.status),
            ],
          ),

          const SizedBox(height: 4),

          // Account and Type
          Row(
            children: [
              Expanded(
                child: Text(
                  transaction.accountName ?? "N/A",
                  style:  TextStyle(
                    fontSize: 13,
                    color: AppColors.text(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildTypeChip(transaction.transactionType),
            ],
          ),

          const SizedBox(height: 6),

          // Amount and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$prefix\$${amount.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  color: amountColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                transaction.transactionDate != null
                    ? '${transaction.transactionDate!.day}/${transaction.transactionDate!.month}/${transaction.transactionDate!.year}'
                    : 'N/A',
                style:  TextStyle(
                  fontSize: 12,
                  color: AppColors.text(context),
                ),
              ),
            ],
          ),

          // Description
          if (transaction.description?.isNotEmpty == true)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  'Description:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.description!,
                  style:  TextStyle(
                    fontSize: 13,
                    color: AppColors.text(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),


        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    Color getStatusColor() {
      switch (status?.toLowerCase()) {
        case 'completed':
          return AppColors.success;
        case 'pending':
          return AppColors.warning;
        case 'failed':
          return AppColors.danger;
        case 'reversed':
          return Colors.purple;
        default:
          return Colors.grey;
      }
    }

    final color = getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status?.toUpperCase() ?? 'N/A',
        style: GoogleFonts.inter(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildTypeChip(String? type) {
    final isCredit = type?.toLowerCase() == 'credit';
    final color = isCredit ? AppColors.success : AppColors.danger;
    final icon = isCredit ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            type?.toUpperCase() ?? 'N/A',
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
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
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first transaction to get started',
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