import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

import '../../../../profile/data/model/profile_perrmission_model.dart';
import '../../../data/models/pos_sale_model.dart';
import '../../../../../core/configs/configs.dart';
import '../../../../../core/core.dart';

// Function to load image from network or asset
Future<Uint8List> _loadImageBytes(String? imageUrl) async {
  if (imageUrl == null || imageUrl.isEmpty) {
    // Return empty bytes for placeholder
    return Uint8List(0);
  }

  try {
    final fullUrl = imageUrl.startsWith('http')
        ? imageUrl
        : '${AppUrls.baseUrlMain}$imageUrl';

    print(fullUrl);
    final response = await http.get(Uri.parse(fullUrl));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image: ${response.statusCode}');
    }
  } catch (e) {
    print('Error loading image: $e');
    return Uint8List(0);
  }
}

// Main function for generating final sales PDF
Future<Uint8List> generateSalesPdf(
    PosSaleModel sale,
    CompanyInfo? company,
    ) async {
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

  // Calculate all totals
  final grossTotal = toDouble(sale.grossTotal);
  final netTotal = toDouble(sale.netTotal);
  final grandTotal = toDouble(sale.grandTotal);
  final discount = toDouble(sale.overallDiscount);
  final vat = toDouble(sale.overallVatAmount);
  final serviceCharge = toDouble(sale.overallServiceCharge);
  final deliveryCharge = toDouble(sale.overallDeliveryCharge);


  // Load company logo asynchronously
  Uint8List? logoBytes;
  if (company?.logo != null && company!.logo.isNotEmpty) {
    try {
      logoBytes = await _loadImageBytes(company.logo);
    } catch (e) {
      print('Failed to load logo: $e');
      logoBytes = null;
    }
  }

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(25),
        
        buildBackground: (context) => pw.Container(
          color: PdfColors.white,
        ),
      ),

      // Header with company logo
      header: (context) {
        return pw.Container(
          padding: const pw.EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Company Info
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      company?.name ?? "Your Company",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    if (company?.address != null)
                      pw.Text(
                        company!.address!,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    if (company?.phone != null)
                      pw.Text(
                        "Phone: ${company!.phone!}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    if (company?.email != null)
                      pw.Text(
                        "Email: ${company!.email!}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    if (company?.website != null)
                      pw.Text(
                        "Web: ${company!.website!}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                  ],
                ),
              ),

              // Logo
              pw.Container(
                width: 80,
                height: 80,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: logoBytes != null && logoBytes!.isNotEmpty
                    ? pw.Image(
                  pw.MemoryImage(logoBytes!),
                  fit: pw.BoxFit.cover,
                )
                    : pw.Center(
                  child: pw.Text(
                    "LOGO",
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },

      // Footer

      build: (context) => [
        // Invoice Header
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue800, width: 2),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          padding: const pw.EdgeInsets.all(8),
          margin:const pw.EdgeInsets.all(12),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'SALES INVOICE',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  _buildInvoiceInfoRow('Invoice No:', sale.invoiceNo ?? 'N/A'),
                  _buildInvoiceInfoRow('Date:', sale.formattedSaleDate),
                  _buildInvoiceInfoRow('Time:', sale.formattedTime),
                  _buildInvoiceInfoRow('Sale Type:', sale.saleType ?? 'Retail'),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: pw.BoxDecoration(
                  color: _getStatusColor(sale.paymentStatus ?? ""),
                  borderRadius: pw.BorderRadius.circular(20),
                ),
                child: pw.Text(
                  (sale.paymentStatus ?? "N/A").toUpperCase(),
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

        // Customer and Payment Info
        pw.Container(
          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          padding: const pw.EdgeInsets.all(8),
          margin:const pw.EdgeInsets.all(12),
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
                    _buildInfoRow(
                      'Customer:',
                      sale.customerName ?? 'Walk-in Customer',
                    ),
                    _buildInfoRow('Sales Person:', sale.saleByName ?? 'N/A'),
                    _buildInfoRow('Created By:', sale.createdByName ?? 'N/A'),
                    _buildInfoRow('Customer Type:',
                        sale.customerType == 'walk_in' ? 'Walk-in' : 'Saved Customer'),
                  ],
                ),
              ),
              pw.VerticalDivider(
                width: 1,
                color: PdfColors.grey400,
              ),
              pw.SizedBox(width: 12),
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
                    pw.SizedBox(height: 8),
                    _buildInfoRow(
                      'Payment Method:',
                      sale.paymentMethod ?? 'Cash',
                    ),
                    _buildInfoRow('Account:', sale.accountName ?? 'N/A'),
                    _buildInfoRow('Money Receipt:',
                        sale.withMoneyReceipt == 'Yes' ? 'Yes' : 'No'),
                    if (sale.remark != null && sale.remark!.isNotEmpty)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'REMARKS:',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          pw.Text(
                            sale.remark!,
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Items Table
  pw.Padding(padding: const pw.EdgeInsets.only(left: 12),
  child:  pw.Text(
          'ITEMS DETAILS',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),),

        pw.Padding(padding: const pw.EdgeInsets.all(12),
        child:
        pw.Table(

          border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
          columnWidths: {
            0: const pw.FlexColumnWidth(4),
            1: const pw.FlexColumnWidth(1.2),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Header row
            pw.TableRow(

              decoration: const pw.BoxDecoration(
                color: PdfColors.blue800,
              ),
              children: [
                _buildTableHeader('PRODUCT'),
                _buildTableHeader('QTY', center: true),
                _buildTableHeader('PRICE', right: true),
                _buildTableHeader('TOTAL', right: true),
              ],
            ),
            // Data rows
            ...(sale.items ?? []).map((item) {
              final unitPrice = toDouble(item.unitPrice);
              final subtotal = toDouble(item.subtotal);
              final quantity = item.quantityWithUnit;

              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300),
                  ),
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
                      quantity.toString(),
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


        pw.SizedBox(height: 5),

        // Summary Section
        pw.Padding(
          padding:    pw.EdgeInsets.symmetric(horizontal: 10),
          child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'NOTES',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green50,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColors.green200),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Terms & Conditions:',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green800,
                            fontSize: 12,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          ' Goods sold are not returnable\n'
                              ' Payment due within 15 days\n'
                              ' Subject to jurisdiction of local courts\n'
                              ' All prices include applicable taxes',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'SUMMARY',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 6),

                    // Gross Total
                    _buildSummaryRow('Gross Total:', grossTotal),

                    // Discount
                    if (discount > 0)
                      _buildSummaryRow('Discount (-):', -discount, isNegative: true),

                    // VAT
                    if (vat > 0)
                      _buildSummaryRow('VAT (+):', vat),

                    // Service Charge
                    if (serviceCharge > 0)
                      _buildSummaryRow('Service Charge (+):', serviceCharge),

                    // Delivery Charge
                    if (deliveryCharge > 0)
                      _buildSummaryRow('Delivery Charge (+):', deliveryCharge),

                    pw.Divider(color: PdfColors.blue400, thickness: 1),

                    // Net Total
                    _buildSummaryRow('Net Total:', netTotal, isBold: true),

                    pw.Divider(color: PdfColors.blue800, thickness: 2),

                    // Grand Total
                    _buildSummaryRow('GRAND TOTAL:', grandTotal, isTotal: true),



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

// Function for preview PDF (simpler version)
Future<Uint8List> generateSalesPreviewPdf(
    PosSaleModel sale,
    CompanyInfo? company,
    ) async {
  final pdf = pw.Document();

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

  final grandTotal = toDouble(sale.grandTotal);
  final netTotal = toDouble(sale.netTotal);
  final discount = toDouble(sale.overallDiscount);
  final vat = toDouble(sale.overallVatAmount);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(25),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SALES INVOICE PREVIEW',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      company?.name ?? "Your Company",
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                pw.Text(
                  'PREVIEW ONLY',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.orange,
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),
            pw.Divider(),

            // Invoice Info
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Invoice: ${sale.invoiceNo ?? "PREVIEW"}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Date: ${sale.formattedSaleDate}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green,
                    borderRadius: pw.BorderRadius.circular(20),
                  ),
                  child: pw.Text(
                    'PAID',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Customer Info
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Customer: ${sale.customerName ?? "Walk-in Customer"}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Sales By: ${sale.saleByName ?? "N/A"}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  if (sale.remark != null && sale.remark!.isNotEmpty)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Remarks: ${sale.remark}',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Items Table (Simplified)
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Product',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Qty',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Total',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
                ...(sale.items ?? []).map((item) {
                  final subtotal = toDouble(item.subtotal);
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          item.productName ?? 'Product',
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
                          '৳${subtotal.toStringAsFixed(2)}',
                          style: const pw.TextStyle(fontSize: 11),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 10),

            // Summary
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 250,
                padding: const pw.EdgeInsets.all(16),

                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue800),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _buildPreviewSummaryRow('Subtotal:', netTotal),
                    if (discount > 0)
                      _buildPreviewSummaryRow('Discount:', -discount, isNegative: true),
                    if (vat > 0)
                      _buildPreviewSummaryRow('VAT:', vat),
                    pw.Divider(),
                    _buildPreviewSummaryRow('GRAND TOTAL:', grandTotal, isTotal: true),
                  ],
                ),
              ),
            ),

            pw.SizedBox(height: 40),

            // Footer
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'This is a preview only. Actual invoice will be generated upon sale completion.',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Preview Generated: ${DateTime.now().toLocal()}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

// Helper functions
pw.Widget _buildInvoiceInfoRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      children: [
        pw.Text(
          '$label ',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        ),
        pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
      ],
    ),
  );
}

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
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
        ),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ),
      ],
    ),
  );
}

pw.Widget _buildTableHeader(String text, {bool center = false, bool right = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      textAlign: center ? pw.TextAlign.center : (right ? pw.TextAlign.right : pw.TextAlign.left),
    ),
  );
}

pw.Widget _buildSummaryRow(String label, double value, {bool isNegative = false, bool isBold = false, bool isTotal = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: isBold || isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: isTotal ? 12 : 11,
            color: isTotal ? PdfColors.blue800 : PdfColors.grey700,
          ),
        ),
        pw.Text(
          value.abs().toStringAsFixed(2),
          style: pw.TextStyle(
            fontWeight: isBold || isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: isTotal ? 12 : 11,
            color: isTotal ? PdfColors.blue800 : (isNegative ? PdfColors.red : PdfColors.grey700),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildPaymentRow(String label, double value, {PdfColor? color}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 11),
        ),
        pw.Text(
          '৳${value.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: color ?? PdfColors.blue800,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildPreviewSummaryRow(String label, double value, {bool isNegative = false, bool isTotal = false}) {
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
          ),
        ),
        pw.Text(
          '৳${value.abs().toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontSize: isTotal ? 12 : 11,
            color: isNegative ? PdfColors.red : PdfColors.black,
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
    case 'partial':
      return PdfColors.amber;
    case 'cancelled':
    case 'refunded':
      return PdfColors.red;
    case 'due':
      return PdfColors.pink;
    default:
      return PdfColors.grey;
  }
}