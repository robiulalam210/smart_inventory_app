import 'package:printing/printing.dart';
import 'package:meherin_mart/feature/money_receipt/presentation/page/money_receipt_details.dart';

import '../../../../core/configs/configs.dart';
import '../../data/model/money_receipt_model/money_receipt_model.dart';
import '../page/pdf/generate_money_receipt.dart';

class MoneyReceiptDataTableWidget extends StatelessWidget {
  final List<MoneyreceiptModel> sales;

  const MoneyReceiptDataTableWidget({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    final verticalController = ScrollController();
    final horizontalController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth-50;
        const numColumns = 10;
        const minColumnWidth = 100.0;

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);


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
                      padding: const EdgeInsets.only(bottom: 5),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: totalWidth),
                        child: DataTable(
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: sales
                              .asMap()
                              .entries
                              .map(
                                (entry) => _buildRow(context,
                              entry.key + 1,
                              entry.value,
                              dynamicColumnWidth,
                            ),
                          )
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
      "Actions",

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

  DataRow _buildRow(BuildContext context,int index, MoneyreceiptModel sale, double columnWidth) {
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
    final totalBefore = double.tryParse(summary?.beforePayment?.totalDue.toString() ?? "0");
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

        _buildActionsCell(context, sale, columnWidth),
      ],
    );
  }
  DataCell _buildActionsCell(BuildContext context, MoneyreceiptModel sale, double width) {
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
                    builder: (context) => MoneyReceiptDetailsScreen(receipt: sale),
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
                        build: (format) => generateMoneyReceiptPdf(
                          sale,

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