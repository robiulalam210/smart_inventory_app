// transactions/presentation/widgets/transaction_card.dart
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/configs/configs.dart';
import '../../data/model/transactions_model.dart';

class TransactionCard extends StatelessWidget {
  final List<TransactionsModel> transactions;
  final Function(TransactionsModel)? onReverse;
  final VoidCallback? onTransactionTap;

  const TransactionCard({
    super.key,
    required this.transactions,
    this.onReverse,
    this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    return Responsive.isMobile(context)
        ? _buildMobileListView()
        : _buildDesktopTable();
  }

  Widget _buildDesktopTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const numColumns = 8;
        const columnSpacing = 10.0;
        const horizontalMargin = 12.0;
        const minColumnWidth = 120.0;

        final totalTableWidth = (constraints.maxWidth - 75) +
            (columnSpacing * (numColumns - 1)) +
            (horizontalMargin * 2);

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
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Scrollbar(
                  thumbVisibility: true,
                  scrollbarOrientation: ScrollbarOrientation.bottom,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: totalTableWidth,
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
                        headingRowColor: WidgetStateProperty.all(
                          AppColors.primaryColor,
                        ),
                        dataTextStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          fontFamily: GoogleFonts.inter().fontFamily,
                        ),
                        columns: _buildColumns(minColumnWidth),
                        rows: transactions.asMap().entries.map((entry) {
                          final transaction = entry.value;
                          return DataRow(
                            color: WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                if (entry.key.isEven) {
                                  return Colors.grey.withValues(alpha: 0.03);
                                }
                                return null;
                              },
                            ),
                            onSelectChanged: onTransactionTap != null
                                ? (_) => onTransactionTap!()
                                : null,
                            cells: [
                              _buildDataCell(transaction.transactionNo?? "N/A", minColumnWidth),
                              _buildDataCell(transaction.accountName ?? "N/A", minColumnWidth * 1.2),
                              _buildTypeCell(transaction.transactionType, minColumnWidth),
                              _buildAmountCell(double.tryParse(transaction.amount??"0"), transaction.transactionType, minColumnWidth),
                              _buildDataCell(transaction.description ?? "-", minColumnWidth * 1.3),
                              _buildDateCell(transaction.transactionDate, minColumnWidth),
                              _buildStatusCell(transaction.status, minColumnWidth),
                              _buildActionCell(transaction, minColumnWidth * 0.8),
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

  Widget _buildMobileListView() {
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildMobileTransactionCard(transaction, index);
        },
      ),
    );
  }

  Widget _buildMobileTransactionCard(TransactionsModel transaction, int index) {
    final isCredit = transaction.transactionType?.toLowerCase() == 'credit';
    final amountColor = isCredit ? Colors.green : Colors.red;
    final prefix = isCredit ? '+' : '-';
    final amount = double.tryParse(transaction.amount ?? "0") ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.grey.withOpacity(0.03) : Colors.white,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusChip(transaction.status),
            ],
          ),

          const SizedBox(height: 8),

          // Account and Type
          Row(
            children: [
              Expanded(
                child: Text(
                  transaction.accountName ?? "N/A",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildTypeChip(transaction.transactionType),
            ],
          ),

          const SizedBox(height: 12),

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
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          // Description
          if (transaction.description?.isNotEmpty == true)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Description:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.description!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

          // Reverse button
          if (onReverse != null && transaction.status?.toLowerCase() != 'reversed')
            Column(
              children: [
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => onReverse!(transaction),
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('Reverse Transaction'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                    ),
                  ),
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
          return Colors.green;
        case 'pending':
          return Colors.orange;
        case 'failed':
          return Colors.red;
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
        color: color.withOpacity(0.1),
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
    final color = isCredit ? Colors.green : Colors.red;
    final icon = isCredit ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
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

  List<DataColumn> _buildColumns(double columnWidth) {
    return [
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text(
            'Transaction No.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth * 1.2,
          child: const Text(
            'Account',
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
          width: columnWidth * 1.3,
          child: const Text(
            'Description',
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
          width: columnWidth * 0.8,
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

  DataCell _buildTypeCell(String? type, double width) {
    final isCredit = type?.toLowerCase() == 'credit';
    final color = isCredit ? Colors.green : Colors.red;
    final icon = isCredit ? Icons.arrow_upward : Icons.arrow_downward;

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
          ),
        ),
      ),
    );
  }

  DataCell _buildAmountCell(double? amount, String? type, double width) {
    final isCredit = type?.toLowerCase() == 'credit';
    final color = isCredit ? Colors.green : Colors.red;
    final prefix = isCredit ? '+' : '-';

    return DataCell(
      Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Center(
          child: Text(
            '$prefix\$${amount?.toStringAsFixed(2) ?? "0.00"}',
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  DataCell _buildDateCell(DateTime? date, double width) {
    final formattedDate = date != null
        ? '${date.day}/${date.month}/${date.year}'
        : 'N/A';

    return DataCell(
      Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  DataCell _buildStatusCell(String? status, double width) {
    Color getStatusColor() {
      switch (status?.toLowerCase()) {
        case 'completed':
          return Colors.green;
        case 'pending':
          return Colors.orange;
        case 'failed':
          return Colors.red;
        case 'reversed':
          return Colors.purple;
        default:
          return Colors.grey;
      }
    }

    final color = getStatusColor();

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
            ),
            child: Text(
              status?.toUpperCase() ?? 'N/A',
              style: GoogleFonts.inter(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildActionCell(TransactionsModel transaction, double width) {
    return DataCell(
      Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (onReverse != null && transaction.status?.toLowerCase() != 'reversed')
              IconButton(
                icon: const Icon(Icons.swap_horiz, size: 16),
                onPressed: () => onReverse!(transaction),
                tooltip: 'Reverse Transaction',
                color: Colors.orange,
              ),
          ],
        ),
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
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.grey.withOpacity(0.5),
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