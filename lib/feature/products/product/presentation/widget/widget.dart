import 'package:flutter/material.dart';
import '../../data/model/product_model.dart';

class ProductDataTableWidget extends StatelessWidget {
  final List<ProductModel> products;

  const ProductDataTableWidget({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 14;
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
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: totalWidth),
                        child: DataTable(
                          dataRowMinHeight: 40,
                          columnSpacing: 0,
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          headingRowColor:
                          MaterialStateProperty.all(const Color(0xFF6ab129)),
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: products
                              .asMap() // get index + product
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
      'ID',
      'Name',
      'SKU',
      'Category',
      'Brand',
      'Unit',
      'Group',
      'Source',
      'Purchase Price',
      'Selling Price',
      'Stock Qty',
      'Alert Qty',
      'Status',
      'Description',
    ];

    return columnLabels
        .map(
          (label) => DataColumn(
        label: Container(
          width: columnWidth,
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

  DataRow _buildDataRow(int index,ProductModel product, double columnWidth) {
    return DataRow(
      cells: [
        _buildDataCell(index.toString(), columnWidth),
        _buildDataCell(product.name ?? 'N/A', columnWidth),
        _buildDataCell(product.sku ?? 'N/A', columnWidth),
        _buildDataCell(product.categoryInfo?.name ?? 'N/A', columnWidth),
        _buildDataCell(product.brandInfo?.name ?? 'N/A', columnWidth),
        _buildDataCell(product.unitInfo?.name ?? 'N/A', columnWidth),
        _buildDataCell(product.groupInfo?.name ?? 'N/A', columnWidth),
        _buildDataCell(product.sourceInfo?.name ?? 'N/A', columnWidth),
        _buildDataCell(
            double.tryParse(product.purchasePrice.toString())
                ?.toStringAsFixed(2) ??
                '0.00',
            columnWidth),
        _buildDataCell(
            double.tryParse(product.sellingPrice.toString())
                ?.toStringAsFixed(2) ??
                '0.00',
            columnWidth),
        _buildDataCell(product.stockQty.toString(), columnWidth),
        _buildDataCell(product.alertQuantity.toString(), columnWidth),
        _buildDataCell(product.isActive??false ? 'Active' : 'Inactive', columnWidth,
            isStatus: true),
        _buildDataCell(product.description ?? 'N/A', columnWidth),
      ],
    );
  }

  DataCell _buildDataCell(String text, double columnWidth,
      {bool isStatus = false}) {
    return DataCell(
      SizedBox(
        width: columnWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: SelectableText(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isStatus ? FontWeight.w600 : FontWeight.normal,
              color: isStatus
                  ? (text == 'Active' ? Colors.green : Colors.red)
                  : Colors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
        ),
      ),
    );
  }
}
