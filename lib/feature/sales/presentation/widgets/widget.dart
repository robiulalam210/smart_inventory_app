import '../../../../core/configs/configs.dart';
import '../../data/models/pos_sale_model.dart';

class PosSaleDataTableWidget extends StatelessWidget {
  final List<PosSaleModel> sales;

  const PosSaleDataTableWidget({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 12;
        const minColumnWidth = 100.0;

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
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
                          dataRowMinHeight: 30,
                          columnSpacing: 0,
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          headingRowColor: WidgetStateProperty.all(
                              AppColors.primaryColor
                          ),
                          headingRowHeight: 40,
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: sales
                              .asMap()
                              .entries
                              .map(
                                (entry) => _buildDataRow(
                              entry.key + 1,
                              entry.value,
                              dynamicColumnWidth,
                            ),
                          )
                              .toList(),
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
    const labels = [
      "SL",
      "Receipt No",
      "Sale Date",
      "Customer Name",
      "Sales By",
      "Created By",
      "Grand Total",
      "Paid Amount",
      "Due/Advance", // CHANGED: More descriptive column name
      "Status",
    ];

    return labels
        .map(
          (label) => DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    )
        .toList();
  }

  DataRow _buildDataRow(int index, PosSaleModel sale, double columnWidth) {
    // FIX: Calculate proper due/advance display
    final dueAmount = sale.dueAmount is String
        ? double.tryParse(sale.dueAmount!) ?? 0.0
        : (sale.dueAmount ?? 0.0).toDouble();

    final paidAmount = sale.paidAmount is String
        ? double.tryParse(sale.paidAmount!) ?? 0.0
        : (sale.paidAmount ?? 0.0).toDouble();

    final payableAmount = sale.payableAmount is String
        ? double.tryParse(sale.payableAmount!) ?? 0.0
        : (sale.payableAmount ?? 0.0).toDouble();

    // Determine if it's due or advance
    final isAdvance = dueAmount < 0;
    final displayAmount = isAdvance ? dueAmount.abs() : dueAmount;
    final status = _getPaymentStatus(paidAmount, payableAmount);

    return DataRow(
      cells: [
        _buildDataCell(index.toString(), columnWidth),
        _buildDataCell(sale.invoiceNo.toString(), columnWidth),
        _buildDataCell(
          appWidgets.convertDateTimeDDMMMYYYY(sale.saleDate),
          columnWidth,
        ),
        _buildDataCell(sale.customerName.toString(), columnWidth),
        _buildDataCell(sale.saleByName.toString(), columnWidth),
        _buildDataCell(sale.createdByName.toString(), columnWidth),
        _buildDataCell(
          _formatCurrency(payableAmount),
          columnWidth,
        ),
        _buildDataCell(
          _formatCurrency(paidAmount),
          columnWidth,
        ),
        // FIXED: Due/Advance column
        _buildDataCell(
          isAdvance
              ? _formatCurrency(displayAmount)
              : _formatCurrency(displayAmount),
          columnWidth,
          isDue: !isAdvance && dueAmount > 0,
          isAdvance: isAdvance,
        ),
        _buildDataCell(status, columnWidth, status: status),
      ],
    );
  }

  DataCell _buildDataCell(
      String text,
      double width, {
        bool isDue = false,
        bool isAdvance = false,
        String status = '',
      }) {
    Color textColor = Colors.black;

    // Set colors based on status
    if (isDue) {
      textColor = Colors.red; // Due amount in red
    } else if (isAdvance) {
      textColor = Colors.green; // Advance amount in green
    } else if (status.isNotEmpty) {
      // Status color coding
      switch (status.toLowerCase()) {
        case 'paid':
          textColor = Colors.green;
          break;
        case 'partial':
          textColor = Colors.orange;
          break;
        case 'pending':
          textColor = Colors.red;
          break;
        default:
          textColor = Colors.black;
      }
    }

    return DataCell(
      SizedBox(
        width: width,
        child: SelectableText(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Helper method to format currency
  String _formatCurrency(double amount) {
    return '৳${amount.toStringAsFixed(2)}';
  }

  // Helper method to determine payment status
  String _getPaymentStatus(double paidAmount, double payableAmount) {
    if (paidAmount >= payableAmount) {
      return 'Paid';
    } else if (paidAmount > 0) {
      return 'Partial';
    } else {
      return 'Pending';
    }
  }
}