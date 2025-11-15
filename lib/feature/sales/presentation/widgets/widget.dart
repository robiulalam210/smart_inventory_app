import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../../core/configs/configs.dart';
import '../../../../core/configs/pdf/lab_billing_preview_invoice.dart';
import '../../data/models/pos_sale_model.dart';
import '../pages/sales_details_screen.dart';
import 'pdf/sales_invocei.dart';

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
                      padding: const EdgeInsets.only(bottom: 5),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: totalWidth),
                        child: DataTable(
                          dataRowMinHeight: 30,
                          columnSpacing: 0,
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          headingRowColor: WidgetStateProperty.all(
                              AppColors.primaryColor),
                          headingRowHeight: 40,
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: sales
                              .asMap()
                              .entries
                              .map(
                                (entry) => _buildDataRow(
                              context, // Add context parameter
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
      "Paid Amount",
      "Due/Advance",
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

  DataRow _buildDataRow(
      BuildContext context, int index, PosSaleModel sale, double columnWidth) {
    // FIX: Calculate proper due/advance display
    final dueAmount = sale.dueAmount is String
        ? double.tryParse(sale.dueAmount!) ?? 0.0
        : (sale.dueAmount ?? 0.0).toDouble();

    final paidAmount = sale.paidAmount is String
        ? double.tryParse(sale.paidAmount!) ?? 0.0
        : (sale.paidAmount ?? 0.0).toDouble();

    final payableAmount = sale.payableAmount is String
        ? double.tryParse(sale.payableAmount!) ?? 0.0
        : (sale.payableAmount ?? 0.0).toDouble();

    // Determine if it's due or advance
    final isAdvance = dueAmount < 0;
    final displayAmount = isAdvance ? dueAmount.abs() : dueAmount;
    final status = _getPaymentStatus(paidAmount, payableAmount);

    return DataRow(
      cells: [
        _buildDataCell(index.toString(), columnWidth),
        _buildDataCell(sale.invoiceNo.toString(), columnWidth),
        _buildDataCell(
          _formatDate(sale.saleDate),
          columnWidth,
        ),
        _buildDataCell(sale.customerName.toString(), columnWidth),
        _buildDataCell(sale.saleByName.toString(), columnWidth),
        _buildDataCell(sale.createdByName.toString(), columnWidth),
        _buildDataCell(
          _formatCurrency(payableAmount),
          columnWidth,
        ),
        _buildDataCell(
          _formatCurrency(paidAmount),
          columnWidth,
        ),
        // FIXED: Due/Advance column
        _buildDataCell(
          isAdvance
              ? _formatCurrency(displayAmount)
              : _formatCurrency(displayAmount),
          columnWidth,
          isDue: !isAdvance && dueAmount > 0,
          isAdvance: isAdvance,
        ),
        _buildDataCell(status, columnWidth, status: status),
        _buildActionsCell(context, sale, columnWidth),
      ],
    );
  }

  DataCell _buildActionsCell(BuildContext context, PosSaleModel sale, double width) {
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
                    builder: (context) => SalesDetailsScreen(sale: sale),
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
                        build: (format) => generateSalesPdf(
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

  DataCell _buildDataCell(
      String text,
      double width, {
        bool isDue = false,
        bool isAdvance = false,
        String status = '',
      }) {
    Color textColor = Colors.black;

    // Set colors based on status
    if (isDue) {
      textColor = Colors.red; // Due amount in red
    } else if (isAdvance) {
      textColor = Colors.green; // Advance amount in green
    } else if (status.isNotEmpty) {
      // Status color coding
      switch (status.toLowerCase()) {
        case 'paid':
          textColor = Colors.green;
          break;
        case 'partial':
          textColor = Colors.orange;
          break;
        case 'pending':
          textColor = Colors.red;
          break;
        default:
          textColor = Colors.black;
      }
    }

    return DataCell(
      SizedBox(
        width: width,
        child: SelectableText(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Helper method to format currency
  String _formatCurrency(double amount) {
    return '৳${amount.toStringAsFixed(2)}';
  }

  // Helper method to format date
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to determine payment status
  String _getPaymentStatus(double paidAmount, double payableAmount) {
    if (paidAmount >= payableAmount) {
      return 'Paid';
    } else if (paidAmount > 0) {
      return 'Partial';
    } else {
      return 'Pending';
    }
  }
}