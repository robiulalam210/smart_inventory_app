import 'package:flutter/material.dart';
import 'package:smart_inventory/feature/supplier/data/model/supplier_list_model.dart';
import 'package:smart_inventory/feature/supplier/data/model/supplier_payment/suppler_payment_model.dart';

class SupplierPaymentWidget extends StatelessWidget {
  final List<SupplierPaymentModel> suppliers;

  const SupplierPaymentWidget({super.key, required this.suppliers});

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
              rows: suppliers.asMap().entries.map((e) => _buildRow(e.key + 1, e.value)).toList(),
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
      "Supplier No",
      "Name",
      "Phone",
      "Total Purchases",
      "Total Paid",

    ];

    return labels.map((label) => DataColumn(label: Text(label, textAlign: TextAlign.center))).toList();
  }

  DataRow _buildRow(int index, SupplierPaymentModel supplier) {
    String formatDate(DateTime? date) {
      if (date == null) return '-';
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }

    String formatCurrency(dynamic value) {
      if (value == null) return '0.00';
      final numValue = value is int ? value.toDouble() : (value is double ? value : 0.0);
      return numValue.toStringAsFixed(2);
    }

    return DataRow(cells: [
      DataCell(Text(index.toString())),
      DataCell(Text(supplier.spNo ?? '-')),
      DataCell(Text(supplier.supplierName ?? '-')),
      DataCell(Text(supplier.supplierPhone ?? '-')),
      DataCell(Text(formatCurrency(supplier.amount))),
      DataCell(Text(formatCurrency(supplier.purchaseInvoiceNo))),

    ]);
  }
}