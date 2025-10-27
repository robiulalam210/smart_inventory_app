
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
                          headingRowColor: MaterialStateProperty.all(
                            const Color(0xFF6AB129),
                          ),
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
      "Due",

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

        _buildDataCell(sale.payableAmount.toString(), columnWidth),

        _buildDataCell(
          sale.dueAmount.toString(),
          columnWidth,
          isDue: true,
        ),

      ],
    );
  }

  DataCell _buildDataCell(String text, double width, {bool isDue = false}) {
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
              color: isDue && (double.tryParse(text) ?? 0) > 0
                  ? Colors.red
                  : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
