import 'package:flutter/material.dart';
import 'package:smart_inventory/feature/supplier/data/model/supplier_list_model.dart';

class SupplierDataTableWidget extends StatelessWidget {
  final List<SupplierListModel> suppliers;

  const SupplierDataTableWidget({super.key, required this.suppliers});

  @override
  Widget build(BuildContext context) {
    final verticalController = ScrollController();
    final horizontalController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth - 70;
        const numColumns = 8; // Updated to match your 8 columns
        const minColumnWidth = 100.0;

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
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: totalWidth,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(12),
                      child: DataTable(
                        columns: _buildColumns(dynamicColumnWidth),
                        rows: suppliers.asMap().entries
                            .map((e) => _buildRow(e.key + 1, e.value))
                            .toList(),
                        headingRowColor: MaterialStateProperty.all(const Color(0xFF6AB129)),
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        dataRowMinHeight: 40,
                        columnSpacing: 10,
                        dataTextStyle: const TextStyle(fontSize: 12),
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
    final columns = [
      _DataColumnConfig("SL", columnWidth * 0.5), // Smaller for serial number
      _DataColumnConfig("Supplier No", columnWidth * 0.8),
      _DataColumnConfig("Name", columnWidth * 1.2), // Wider for names
      _DataColumnConfig("Phone", columnWidth),
      _DataColumnConfig("Total Purchases", columnWidth * 1.1),
      _DataColumnConfig("Total Paid", columnWidth * 1.1),
      _DataColumnConfig("Total Due", columnWidth * 1.1),
      _DataColumnConfig("Status", columnWidth * 0.8),
    ];

    return columns.map((col) => DataColumn(
      label: Container(
        width: col.width,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          col.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    )).toList();
  }

  DataRow _buildRow(int index, SupplierListModel supplier) {
    String formatCurrency(dynamic value) {
      if (value == null) return '0.00';
      final numValue = value is int ? value.toDouble() : (value is double ? value : 0.0);
      return numValue.toStringAsFixed(2);
    }

    Color getStatusColor(String? status) {
      switch (status?.toLowerCase()) {
        case 'active':
          return Colors.green;
        case 'inactive':
          return Colors.orange;
        case 'blocked':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return DataRow(cells: [
      _buildDataCell(index.toString(), TextAlign.center),
      _buildDataCell(supplier.supplierNo ?? '-', TextAlign.left),
      _buildDataCell(supplier.name ?? '-', TextAlign.left),
      _buildDataCell(supplier.address ?? '-', TextAlign.left),
      _buildDataCell(formatCurrency(supplier.totalPurchases), TextAlign.right),
      _buildDataCell(formatCurrency(supplier.totalPaid), TextAlign.right),
      _buildDataCell(formatCurrency(supplier.totalDue), TextAlign.right),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: getStatusColor(supplier.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: getStatusColor(supplier.status)),
          ),
          child: Text(
            supplier.status ?? '-',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: getStatusColor(supplier.status),
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ),
      ),
    ]);
  }

  DataCell _buildDataCell(String text, TextAlign align) {
    return DataCell(
      Text(
        text,
        textAlign: align,
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _DataColumnConfig {
  final String label;
  final double width;

  const _DataColumnConfig(this.label, this.width);
}