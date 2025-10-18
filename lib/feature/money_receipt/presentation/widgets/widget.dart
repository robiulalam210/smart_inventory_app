import '../../../../core/configs/configs.dart';
import '../../data/model/money_receipt_model/money_receipt_model.dart';

import 'package:flutter/material.dart';


class MoneyReciptDataTableWidget extends StatelessWidget {
  final List<MoneyreceiptModel> sales;

  const MoneyReciptDataTableWidget({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    final verticalController = ScrollController();
    final horizontalController = ScrollController();

    return Scrollbar(
      controller: verticalController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: verticalController,
        child: Scrollbar(
          controller: horizontalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: horizontalController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: _buildColumns(),
              rows: sales.asMap().entries.map((e) => _buildRow(e.key + 1, e.value)).toList(),
              headingRowColor: MaterialStateProperty.all(const Color(0xFF6AB129)),
              headingTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              dataRowMinHeight: 40,
              columnSpacing: 10,
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    const labels = [
      "SL",
      "MR No",
      "Customer",
      "Seller",
      "Payment Date",
      "Payment Method",
      "Customer Phone",
      "Amount",
      "Total Due Before",
      "Total Due After",
      "Applied Invoice No",
      "Status"
    ];

    return labels.map((label) => DataColumn(label: Text(label, textAlign: TextAlign.center))).toList();
  }

  DataRow _buildRow(int index, MoneyreceiptModel sale) {
    String formatDate(DateTime? date) {
      if (date == null) return '-';
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }

    final summary = sale.paymentSummary;
    final totalBefore = summary?.beforePayment?.totalDue?.toDouble() ?? 0;
    final totalAfter = summary?.afterPayment?.totalDue?.toDouble() ?? 0;
    final affectedInvoice = (summary?.affectedInvoices != null && summary!.affectedInvoices!.isNotEmpty)
        ? summary.affectedInvoices!.first.invoiceNo ?? '-'
        : '-';
    final status = summary?.status ?? '-';
    final amount = double.tryParse(sale.amount ?? '0') ?? 0;

    return DataRow(cells: [
      DataCell(Text(index.toString())),
      DataCell(Text(sale.mrNo ?? '-')),
      DataCell(Text(sale.customerName ?? '-')),
      DataCell(Text(sale.sellerName ?? '-')),
      DataCell(Text(formatDate(sale.paymentDate))),
      DataCell(Text(sale.paymentMethod ?? '-')),
      DataCell(Text(sale.customerPhone?.toString() ?? '-')),
      DataCell(Text(amount.toStringAsFixed(2))),
      DataCell(Text(totalBefore.toStringAsFixed(2))),
      DataCell(Text(totalAfter.toStringAsFixed(2))),
      DataCell(Text(affectedInvoice)),
      DataCell(Text(status)),
    ]);
  }
}
