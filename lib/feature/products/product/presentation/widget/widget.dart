import 'package:flutter/material.dart';
import '../../../../../core/configs/app_colors.dart';
import '../../data/model/product_model.dart';

class ProductDataTableWidget extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel)? onEdit;
  final Function(ProductModel)? onDelete;

  const ProductDataTableWidget({
    super.key,
    required this.products,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 8; // Added one column for actions
        const minColumnWidth = 100;

        final dynamicColumnWidth = (totalWidth / numColumns)
            .clamp(minColumnWidth, double.infinity)
            .toDouble();

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
                          dataRowMinHeight: 40,
                          headingRowHeight: 40,
                          columnSpacing: 0,
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          headingRowColor:
                          MaterialStateProperty.all(
                              AppColors.primaryColor
                          ),
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: products
                              .asMap()
                              .entries
                              .map((entry) => _buildDataRow(entry.key + 1, entry.value, dynamicColumnWidth))
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
    const columnLabels = [
      'SL',
      'Name',
      'SKU',
      'Category',
      'Brand',
      'Unit',
      'Status',
      'Actions',
    ];

    return columnLabels
        .map(
          (label) => DataColumn(
        label: Container(
          width: label == 'SL' ? columnWidth * 0.6 :
          label == 'Name' ? columnWidth * 1.2 :
          label == 'Actions' ? columnWidth * 0.8 :
          columnWidth,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700),
              maxLines: 2,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    )
        .toList();
  }

  DataRow _buildDataRow(int index, ProductModel product, double columnWidth) {
    return DataRow(
      cells: [
        _buildDataCell(index.toString(), columnWidth * 0.6),
        _buildDataCell(product.name ?? 'N/A', columnWidth * 1.2),
        _buildDataCell(product.sku ?? 'N/A', columnWidth),
        _buildDataCell(product.categoryInfo?.name ?? 'N/A', columnWidth),
        _buildDataCell(product.brandInfo?.name ?? 'N/A', columnWidth),
        _buildDataCell(product.unitInfo?.name ?? 'N/A', columnWidth),
        _buildStatusCell(product.isActive ?? false, columnWidth),
        _buildActionsCell(product, columnWidth * 0.8),
      ],
    );
  }

  DataCell _buildDataCell(String text, double columnWidth) {
    return DataCell(
      SizedBox(
        width: columnWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: SelectableText(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
        ),
      ),
    );
  }

  DataCell _buildStatusCell(bool isActive, double columnWidth) {
    final status = isActive ? 'Active' : 'Inactive';
    final color = isActive ? Colors.green : Colors.red;

    return DataCell(
      SizedBox(
        width: columnWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildActionsCell(ProductModel product, double columnWidth) {
    return DataCell(
      SizedBox(
        width: columnWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit Button
              IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
                onPressed: () => onEdit?.call(product),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                tooltip: 'Edit Product',
              ),

              // Delete Button
              IconButton(
                icon: Icon(
                  Icons.delete,
                  size: 16,
                  color: Colors.red.shade600,
                ),
                onPressed: () => onDelete?.call(product),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                tooltip: 'Delete Product',
              ),
            ],
          ),
        ),
      ),
    );
  }
}