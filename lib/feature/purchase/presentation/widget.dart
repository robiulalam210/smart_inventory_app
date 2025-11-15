import 'package:printing/printing.dart';
import 'package:smart_inventory/feature/purchase/presentation/page/purchase_details.dart';

import '../../../../core/configs/configs.dart';
import '../data/model/purchase_sale_model.dart';
import 'page/pdf/generate_purchase_pdf.dart';

class PurchaseDataTableWidget extends StatelessWidget {
  final List<PurchaseModel> sales;

  const PurchaseDataTableWidget({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth-50;
        const numColumns = 9;
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
                          headingRowHeight: 40,
                          columnSpacing: 0,
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          headingRowColor: WidgetStateProperty.all(
                              AppColors.primaryColor

                          ),
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: sales
                              .asMap()
                              .entries
                              .map(
                                (entry) => _buildDataRow(context,
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

  // --- Build Column Headers ---
  List<DataColumn> _buildColumns(double columnWidth) {
    const labels = [
      "SL",
      "Invoice No",
      "Date",
      "Supplier",
      "Gross Total",
      "Payment Status",
      "Paid",
      "Due",
      "Payment Method",
      "Actions",

    ];

    return labels
        .map(
          (label) => DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: Padding(
            padding: const EdgeInsets.all(0),
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

  // --- Build Each Row ---
  DataRow _buildDataRow(BuildContext context,int index, PurchaseModel sale, double columnWidth) {
    return DataRow(
      cells: [
        _buildDataCell(index.toString(), columnWidth),
        _buildDataCell(sale.invoiceNo ?? '-', columnWidth),
        _buildDataCell(
         AppWidgets().convertDateTimeDDMMYYYY(sale.purchaseDate),
          columnWidth,
        ),
        _buildDataCell(sale.supplierName ?? '-', columnWidth),
        _buildDataCell(sale.total?.toString() ?? '0.00', columnWidth),
        _buildDataCell(sale.paymentStatus ?? '-', columnWidth),
        _buildDataCell(sale.paidAmount?.toString() ?? '0.00', columnWidth),
        _buildDataCell(
          sale.dueAmount?.toString() ?? '0.00',
          columnWidth,
          isDue: true,
        ),
        _buildDataCell(sale.paymentMethod ?? '-', columnWidth),
        _buildActionsCell(context, sale, columnWidth),

      ],
    );
  }
  DataCell _buildActionsCell(BuildContext context, PurchaseModel purchase, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, size: 16),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PurchaseDetailsScreen(purchase: purchase),
                  ),
                );
              },
              tooltip: 'View Details',
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, size: 16),
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      backgroundColor: Colors.red,
                      body: PdfPreview.builder(
                        useActions: true,
                        allowSharing: false,
                        canDebug: false,
                        canChangeOrientation: false,
                        canChangePageFormat: false,
                        dynamicLayout: true,
                        build: (format) => generatePurchasePdf(
                          purchase,

                        ),
                        pdfPreviewPageDecoration:
                        BoxDecoration(color: AppColors.white),
                        actionBarTheme: PdfActionBarTheme(
                          backgroundColor: AppColors.primaryColor,
                          iconColor: Colors.white,
                          textStyle: const TextStyle(color: Colors.white),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () => AppRoutes.pop(context),
                            icon: const Icon(Icons.cancel, color: Colors.red),
                          ),
                        ],
                        pagesBuilder: (context, pages) {
                          debugPrint('Rendering ${pages.length} pages');
                          return PageView.builder(
                            itemCount: pages.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              final page = pages[index];
                              return Container(
                                color: Colors.grey,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8.0),
                                child: Image(image: page.image, fit: BoxFit.contain),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );

              },
              tooltip: 'Generate PDF',
            ),
          ],
        ),
      ),
    );
  }

  // --- Custom Cell Builder ---
  DataCell _buildDataCell(String text, double width, {bool isDue = false}) {
    return DataCell(
      SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
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
