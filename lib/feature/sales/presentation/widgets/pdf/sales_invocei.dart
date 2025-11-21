import 'dart:typed_data';

import '../../../data/models/pos_sale_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
Future<Uint8List> generateSalesPdf(PosSaleModel sale) async {
  final pdf = pw.Document();

  // Helper function for safe double conversion
  double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  final netTotal = toDouble(sale.netTotal);
  final grandTotal = toDouble(sale.grandTotal);
  final discount = toDouble(sale.overallDiscount);
  final vat = toDouble(sale.overallVatAmount);

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(25),
        buildBackground:(context) =>  pw.Container(
          color: PdfColors.white, // Solid color background
        ),
      ),
      header: (context) {
        return pw.Container();
      },

      build: (context) => [
        // Header Section with improved styling
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue800, width: 2),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          padding: const pw.EdgeInsets.all(8),
          margin: const pw.EdgeInsets.all(12),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'SALES INVOICE',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    children: [
                      pw.Container(
                        width: 120,
                        child: pw.Text('Invoice No:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Text(sale.invoiceNo ?? 'N/A'),
                    ],
                  ),
                  pw.Row(
                    children: [
                      pw.Container(
                        width: 120,
                        child: pw.Text('Date:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Text(sale.formattedSaleDate),
                    ],
                  ),
                  pw.Row(
                    children: [
                      pw.Container(
                        width: 120,
                        child: pw.Text('Time:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Text(sale.formattedTime),
                    ],
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: _getStatusColor(sale.paymentStatus),
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  (sale.paymentStatus).toUpperCase(),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),


        // Customer Info Section
        pw.Container(
          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          padding: const pw.EdgeInsets.symmetric(horizontal: 12),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CUSTOMER INFORMATION',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    _buildInfoRow('Customer:', sale.customerName ?? 'Walk-in Customer'),
                    _buildInfoRow('Sales Person:', sale.saleByName ?? 'N/A'),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PAYMENT INFORMATION',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),

                    _buildInfoRow('Payment Method:', sale.paymentMethod ?? 'Cash'),
                    if (sale.accountName != null && sale.accountName!.isNotEmpty)
                      _buildInfoRow('Account:', sale.accountName!),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 4),

        // Items Table Section
        pw.Padding(padding: pw.EdgeInsets.symmetric(horizontal: 12),child: pw.Text(
          'ITEMS DETAILS',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),),

        pw.Padding(padding: pw.EdgeInsets.all(8),child: pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColors.blue800,
                borderRadius: pw.BorderRadius.only(
                  topLeft: pw.Radius.circular(4),
                  topRight: pw.Radius.circular(4),
                ),
              ),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'PRODUCT',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'QTY',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'PRICE',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
            // Data rows
            ...(sale.items ?? []).map((item) {
              final unitPrice = toDouble(item.unitPrice);
              final subtotal = toDouble(item.subtotal);

              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
                ),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      item.productName ?? 'Unknown Product',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      (item.quantity ?? 0).toString(),
                      style: const pw.TextStyle(fontSize: 11),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      unitPrice.toStringAsFixed(2),
                      style: const pw.TextStyle(fontSize: 11),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      subtotal.toStringAsFixed(2),
                      style: const pw.TextStyle(fontSize: 11),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
        ),
        pw.SizedBox(height: 25),

        // Summary Section
        pw.Padding(padding: pw.EdgeInsets.all(8),child:  pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green50,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColors.green200),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Thank you for your business!',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green800,
                            fontSize: 14,
                          ),
                        ),
                        if (sale.remark != null && sale.remark!.isNotEmpty) ...[
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Remarks: ${sale.remark}',
                            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  children: [
                    _buildSummaryRow('Subtotal:', '\$${netTotal.toStringAsFixed(2)}'),
                    if (discount > 0) _buildSummaryRow('Discount:', '-\$${discount.toStringAsFixed(2)}'),
                    if (vat > 0) _buildSummaryRow('Vat:', '\$${vat.toStringAsFixed(2)}'),
                    pw.SizedBox(height: 4),
                    pw.Divider(color: PdfColors.blue400, height: 1, thickness: 1),
                    pw.SizedBox(height: 4),
                    _buildSummaryRow(
                      'GRAND TOTAL:',
                      grandTotal.toStringAsFixed(2),
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),)
      ],
    ),
  );

  return pdf.save();
}

// Helper function for info rows
pw.Widget _buildInfoRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 11),
          ),
        ),
      ],
    ),
  );
}

// Helper function for summary rows
pw.Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: isTotal ? 12 : 11,
            color: isTotal ? PdfColors.blue800 : PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: isTotal ? 12 : 11,
            color: isTotal ? PdfColors.blue800 : PdfColors.grey700,
          ),
        ),
      ],
    ),
  );
}

// Helper function to get status color
PdfColor _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
      return PdfColors.green;
    case 'pending':
      return PdfColors.orange;
    case 'cancelled':
      return PdfColors.red;
    default:
      return PdfColors.grey;
  }
}