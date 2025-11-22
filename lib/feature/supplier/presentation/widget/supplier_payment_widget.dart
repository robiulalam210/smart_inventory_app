import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:meherin_mart/core/configs/app_colors.dart';
import 'package:meherin_mart/feature/supplier/data/model/supplier_payment/suppler_payment_model.dart';
import 'package:meherin_mart/feature/supplier/presentation/pages/supplier_payment_details.dart';

import '../../../../core/configs/app_routes.dart';
import '../pages/pdf/generate_supplier_payment.dart';

class SupplierPaymentWidget extends StatelessWidget {
  final List<SupplierPaymentModel> suppliers;
  final Function(SupplierPaymentModel)? onTap;
  final Function(SupplierPaymentModel)? onEdit;
  final Function(SupplierPaymentModel)? onDelete;

  const SupplierPaymentWidget({
    super.key,
    required this.suppliers,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final verticalController = ScrollController();
    final horizontalController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 10; // Added one column for actions
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
                        columns: _buildColumns(context,dynamicColumnWidth),
                        rows: suppliers
                            .asMap()
                            .entries
                            .map(
                              (e) => _buildRow(context,
                                e.key + 1,
                                e.value,
                                dynamicColumnWidth,
                              ),
                            )
                            .toList(),
                        headingRowColor: WidgetStateProperty.all(
                         AppColors.primaryColor
                        ),
                        headingRowHeight: 40,
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        dataRowMinHeight: 35,
                        columnSpacing: 0,
                        horizontalMargin: 0,
                        dataTextStyle: const TextStyle(fontSize: 11),
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

  List<DataColumn> _buildColumns(BuildContext context,double columnWidth) {
    return [
      _buildDataColumn("SL", columnWidth * 0.6),
      _buildDataColumn("Payment No", columnWidth * 0.8),
      _buildDataColumn("Supplier Name", columnWidth * 1.2),
      _buildDataColumn("Phone", columnWidth * 0.9),
      _buildDataColumn("Amount", columnWidth),
      _buildDataColumn("Payment Method", columnWidth),
      _buildDataColumn("Payment Date", columnWidth),
      _buildDataColumn("Prepared By", columnWidth),
      _buildDataColumn("Status", columnWidth * 0.8),
      _buildDataColumn("Actions", columnWidth * 0.8),
    ];
  }

  DataColumn _buildDataColumn(String label, double width) {
    return DataColumn(
      label: SizedBox(
        width: width,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(
      BuildContext context,
    int index,
    SupplierPaymentModel supplier,
    double columnWidth,
  ) {

    String formatDate(DateTime? date) {
      if (date == null) return '-';
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    String getStatus(PaymentSummary? summary) {
      if (summary == null) return 'Unknown';
      return summary.status ?? 'Unknown';
    }

    return DataRow(
      cells: [
        _buildIndexCell(index, columnWidth * 0.6),
        _buildDataCell(supplier.spNo ?? '-', columnWidth * 0.8),
        _buildDataCell(supplier.supplierName ?? '-', columnWidth * 1.2),
        _buildDataCell(supplier.supplierPhone ?? '-', columnWidth * 0.9),
        _buildAmountCell(supplier.amount, columnWidth),
        // Fixed: Use _buildAmountCell instead of _buildDataCell
        _buildDataCell(supplier.paymentMethod ?? '-', columnWidth),
        _buildDataCell(formatDate(supplier.paymentDate), columnWidth),
        _buildDataCell(supplier.preparedByName ?? '-', columnWidth),
        _buildStatusCell(getStatus(supplier.paymentSummary), columnWidth * 0.8),
        _buildActionsCell(context,supplier, columnWidth * 0.8),
      ],
    );
  }

  DataCell _buildActionsCell(BuildContext context, SupplierPaymentModel sale, double width) {
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
                    builder: (context) => SupplierPaymentDetailsScreen(payment: sale),
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
                        build: (format) => generateSupplierPaymentPdf(
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

  DataCell _buildIndexCell(int index, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Text(
            index.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  DataCell _buildDataCell(String text, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  DataCell _buildAmountCell(dynamic amount, double width) {
    String formatCurrency(dynamic value) {
      if (value == null) return '0.00';
      if (value is String) {
        final numValue = double.tryParse(value) ?? 0.0;
        return numValue.toStringAsFixed(2);
      }
      final numValue = value is int
          ? value.toDouble()
          : (value is double ? value : 0.0);
      return numValue.toStringAsFixed(2);
    }

    final formattedAmount = formatCurrency(amount);

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Text(
            '\$$formattedAmount',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildStatusCell(String status, double width) {
    final (color, textColor) = _getStatusColors(status);

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            constraints: const BoxConstraints(minWidth: 70),
            child: Text(
              _formatStatusText(status),
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  String _formatStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return 'PAID';
      case 'pending':
        return 'PENDING';
      case 'failed':
      case 'cancelled':
        return 'FAILED';
      default:
        return status.toUpperCase();
    }
  }

  (Color color, Color textColor) _getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
      case 'success':
        return (Colors.green.withValues(alpha: 0.2), Colors.green);
      case 'pending':
      case 'processing':
        return (Colors.orange.withValues(alpha: 0.2), Colors.orange);
      case 'failed':
      case 'cancelled':
      case 'rejected':
        return (Colors.red.withValues(alpha: 0.2), Colors.red);
      default:
        return (Colors.grey.withValues(alpha: 0.2), Colors.grey);
    }
  }
}
