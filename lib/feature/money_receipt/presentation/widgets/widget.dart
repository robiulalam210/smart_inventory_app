import '../../../../core/configs/configs.dart';
import '../../data/model/money_receipt_model/money_receipt_model.dart';
import 'package:flutter/material.dart';

class MoneyReceiptDataTableWidget extends StatelessWidget {
  final List<MoneyreceiptModel> sales;

  const MoneyReceiptDataTableWidget({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    final verticalController = ScrollController();
    final horizontalController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 10;
        const minColumnWidth = 100.0;

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);
        print(dynamicColumnWidth);


        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Scrollbar(
            controller: verticalController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: verticalController,
              scrollDirection: Axis.vertical,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Scrollbar(
                  controller: horizontalController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: horizontalController,
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: totalWidth),
                        child: DataTable(
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: sales
                              .asMap()
                              .entries
                              .map(
                                (entry) => _buildRow(
                              entry.key + 1,
                              entry.value,
                              dynamicColumnWidth,
                            ),
                          )
                              .toList(),
                          headingRowColor: MaterialStateProperty.all(
                            const Color(0xFF6AB129),
                          ),
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          dataRowMinHeight: 40,
                          columnSpacing: 0,
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
      "MR No",
      "Customer",
      "Seller",
      "Payment Date",
      "Payment Method",
      "Phone",
      "Amount",
      "Total Before",
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

  DataRow _buildRow(int index, MoneyreceiptModel sale, double columnWidth) {
    // Format date safely
    String formatDate(DateTime? date) {
      if (date == null) return '-';
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }

    // Format text safely
    String formatText(String? text) {
      if (text == null || text.isEmpty) return '-';
      return text;
    }

    // Format currency safely
    String formatCurrency(double? value) {
      if (value == null) return '0.00';
      return value.toStringAsFixed(2);
    }

    final summary = sale.paymentSummary;
    final totalBefore = double.tryParse(summary?.beforePayment?.totalDue ?? "0");
    final amount = double.tryParse(sale.amount ?? '0') ?? 0;
    final status = summary?.status ?? '-';

    return DataRow(
      cells: [
        _buildDataCell(index.toString(), columnWidth),
        _buildDataCell(formatText(sale.mrNo), columnWidth),
        _buildDataCell(formatText(sale.customerName), columnWidth),
        _buildDataCell(formatText(sale.sellerName), columnWidth),
        _buildDataCell(formatDate(sale.paymentDate), columnWidth),
        _buildDataCell(formatText(sale.paymentMethod), columnWidth),
        _buildDataCell(formatText(sale.customerPhone?.toString()), columnWidth),
        _buildDataCell(formatCurrency(amount), columnWidth),
        _buildDataCell(formatCurrency(totalBefore), columnWidth),
        _buildDataCell(
          formatText(status),
          columnWidth,
          statusColor: _getStatusColor(status),
        ),
      ],
    );
  }

  DataCell _buildDataCell(String text, double width, {Color? statusColor}) {
    return DataCell(
      SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: SelectableText(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: statusColor ?? Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}