import 'package:flutter/material.dart';
import 'package:smart_inventory/feature/supplier/data/model/supplier_list_model.dart';

import '../../../../core/configs/app_colors.dart';

class SupplierDataTableWidget extends StatelessWidget {
  final List<SupplierListModel> suppliers;
  final Function(SupplierListModel)? onEdit;
  final Function(SupplierListModel)? onDelete;

  const SupplierDataTableWidget({
    super.key,
    required this.suppliers,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final verticalController = ScrollController();
    final horizontalController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth ;
        const numColumns = 11; // Added one column for actions
        const minColumnWidth = 100.0;

        final dynamicColumnWidth = (totalWidth / numColumns).clamp(
          minColumnWidth,
          double.infinity,
        );

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
                    constraints: BoxConstraints(minWidth: totalWidth),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: DataTable(
                        columns: _buildColumns(dynamicColumnWidth),
                        rows: suppliers
                            .asMap()
                            .entries
                            .map((e) => _buildRow(e.key + 1, e.value))
                            .toList(),
                        headingRowColor: WidgetStateProperty.all(
                            AppColors.primaryColor

                        ),
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        dataRowMinHeight: 40,
                        headingRowHeight: 40,
                        columnSpacing: 0,
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
      _DataColumnConfig("SL", columnWidth ),
      _DataColumnConfig("Supplier No", columnWidth ),
      _DataColumnConfig("Name", columnWidth ),
      _DataColumnConfig("Phone", columnWidth),
      _DataColumnConfig("Address", columnWidth ),
      _DataColumnConfig("Total Purchases", columnWidth ),
      _DataColumnConfig("Total Paid", columnWidth ),
      _DataColumnConfig("Total Due", columnWidth ),
      _DataColumnConfig("Status", columnWidth ),
      _DataColumnConfig("Actions", columnWidth),
    ];

    return columns
        .map(
          (col) => DataColumn(
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
          ),
        )
        .toList();
  }

  DataRow _buildRow(int index, SupplierListModel supplier) {
    Color getStatusColor(bool isActive) {
      return isActive ? Colors.green : Colors.orange;
    }

    String getStatusText(bool isActive) {
      return isActive ? 'Active' : 'Inactive';
    }

    return DataRow(
      cells: [
        _buildDataCell(index.toString(), TextAlign.center),
        _buildDataCell(supplier.supplierNo ?? '-', TextAlign.left),
        _buildDataCell(supplier.name ?? '-', TextAlign.left),
        _buildDataCell(supplier.phone ?? '-', TextAlign.left),
        _buildDataCell(supplier.address ?? '-', TextAlign.left),
        _buildDataCell(supplier.totalPurchases.toString(), TextAlign.right),
        _buildDataCell(supplier.totalPaid.toString(), TextAlign.right),
        _buildDataCell(supplier.totalDue.toString(), TextAlign.right),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: getStatusColor(
                supplier.isActive ?? false,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: getStatusColor(supplier.isActive ?? false),
              ),
            ),
            child: Text(
              getStatusText(supplier.isActive ?? false),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: getStatusColor(supplier.isActive ?? false),
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                color: Colors.blue,
                onPressed: () => onEdit?.call(supplier),
              ),
              // IconButton(
              //   icon: const Icon(Icons.delete, size: 18),
              //   color: Colors.red,
              //   onPressed: () => onDelete?.call(supplier),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  DataCell _buildDataCell(String text, TextAlign align) {
    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          textAlign: align,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _DataColumnConfig {
  final String label;
  final double width;

  const _DataColumnConfig(this.label, this.width);
}
