// purchase_invoice.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../core/utilities/load_image_bytes.dart';
import '../../../../profile/data/model/profile_perrmission_model.dart';
import '../../../data/model/purchase_sale_model.dart';

Future<Uint8List> generatePurchasePdf(PurchaseModel purchase,  CompanyInfo? company,
    ) async {

  Uint8List? logoBytes;
  if (company?.logo != null && company!.logo.isNotEmpty) {
    try {
      logoBytes = await loadImageBytes(company.logo);
    } catch (e) {
      print('Failed to load logo: $e');
      logoBytes = null;
    }
  }
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

  final total = toDouble(purchase.total);
  final grandTotal = toDouble(purchase.grandTotal);
  final paidAmount = toDouble(purchase.paidAmount);
  final dueAmount = toDouble(purchase.dueAmount);
  final discount = toDouble(purchase.overallDiscount);
  final vat = toDouble(purchase.vat);
  final subTotal = toDouble(purchase.subTotal);

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(25),
        buildBackground: (context) => pw.Container(
          color: PdfColors.white, // Solid color background
        ),
      ),
      header: (context) => pw.Container(
        padding: const pw.EdgeInsets.fromLTRB(20, 30, 20, 20),
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
                    company?.name ?? "",
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  if (company?.address != null )
                    pw.Text(company?.address??"", style: const pw.TextStyle(fontSize: 10)),
                  if (company?.phone != null )
                    pw.Text(company?.phone??"", style: const pw.TextStyle(fontSize: 10)),
                  if (company?.email != null )
                    pw.Text(company?.email??"", style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),

            // Logo
            // Logo
            pw.Container(
              width: 80,
              height: 80,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: logoBytes != null
                  ? pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.cover)
                  : pw.Center(
                child: pw.Text(
                  "Logo",
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
              ),
            ),

          ],
        ),
      ),
      footer: (context) => _buildFooter(context),
      build: (context) => [
        _buildHeader(purchase),
        _buildSupplierInfo(purchase),
        _buildItemsTable(purchase),
        _buildSummarySection(
          purchase,
          subTotal,
          discount,
          vat,
          total,
          grandTotal,
        ),
        _buildPaymentSection(paidAmount, dueAmount),
      ],
    ),
  );

  return pdf.save();
}

// Header Section
pw.Widget _buildHeader(PurchaseModel purchase) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.blue800, width: 1.5),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    padding: const pw.EdgeInsets.all(12),
    margin: const pw.EdgeInsets.all(16),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'PURCHASE INVOICE',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 12),
            _buildHeaderRow('Invoice No:', purchase.invoiceNo ?? 'N/A'),
            _buildHeaderRow('Date:', _formatDate(purchase.purchaseDate)),
            _buildHeaderRow('Time:', _formatTime(purchase.purchaseDate)),
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: pw.BoxDecoration(
            color: _getStatusColor(purchase.paymentStatus ?? ''),
            borderRadius: pw.BorderRadius.circular(16),
          ),
          child: pw.Text(
            (purchase.paymentStatus ?? 'UNKNOWN').toUpperCase(),
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildHeaderRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      children: [
        pw.Container(
          width: 80,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
        ),
        pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
      ],
    ),
  );
}

// Supplier Information Section
pw.Widget _buildSupplierInfo(PurchaseModel purchase) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      color: PdfColors.grey50,
      borderRadius: pw.BorderRadius.circular(6),
      border: pw.Border.all(color: PdfColors.grey300),
    ),
    padding: const pw.EdgeInsets.all(16),
    margin: const pw.EdgeInsets.all(16),

    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SUPPLIER INFORMATION',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildInfoRow('Supplier Name:', purchase.supplierName ?? 'N/A'),
              _buildInfoRow(
                'Payment Method:',
                purchase.paymentMethod ?? 'Cash',
              ),
            ],
          ),
        ),
        if (purchase.accountName != null && purchase.accountName!.isNotEmpty)
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'ACCOUNT INFORMATION',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(height: 8),
                _buildInfoRow('Account:', purchase.accountName!),
              ],
            ),
          ),
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
          width: 100,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
          ),
        ),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    ),
  );
}

// Items Table Section
pw.Widget _buildItemsTable(PurchaseModel purchase) {
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

  return pw.Container(
    margin: const pw.EdgeInsets.all(16),

    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PURCHASE ITEMS',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3.5),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1.3),
            3: const pw.FlexColumnWidth(1.2),
            4: const pw.FlexColumnWidth(1.3),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue800),
              children: [
                _buildTableHeaderCell('PRODUCT'),
                _buildTableHeaderCell('QTY', center: true),
                _buildTableHeaderCell('PRICE', right: true),
                _buildTableHeaderCell('DISCOUNT', center: true),
                _buildTableHeaderCell('TOTAL', right: true),
              ],
            ),
            // Data rows
            ...(purchase.items ?? []).map((item) {
              final price = toDouble(item.price);
              final total = toDouble(item.productTotal);

              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey200),
                  ),
                ),
                children: [
                  _buildTableCell(item.productName ?? 'Unknown Product'),
                  _buildTableCell(item.qty?.toString() ?? '0', center: true),
                  _buildTableCell(price.toStringAsFixed(2), right: true),
                  _buildTableCell(
                    item.discount != null && item.discount != "0"
                        ? '${item.discount}${item.discountType == 'percent' ? '%' : ''}'
                        : '-',
                    center: true,
                  ),
                  _buildTableCell(total.toStringAsFixed(2), right: true),
                ],
              );
            }),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _buildTableHeaderCell(
  String text, {
  bool center = false,
  bool right = false,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(10),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 10,
      ),
      textAlign: center
          ? pw.TextAlign.center
          : (right ? pw.TextAlign.right : pw.TextAlign.left),
    ),
  );
}

pw.Widget _buildTableCell(
  String text, {
  bool center = false,
  bool right = false,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: const pw.TextStyle(fontSize: 9),
      textAlign: center
          ? pw.TextAlign.center
          : (right ? pw.TextAlign.right : pw.TextAlign.left),
    ),
  );
}

// Summary Section
pw.Widget _buildSummarySection(
  PurchaseModel purchase,
  double subTotal,
  double discount,
  double vat,
  double total,
  double grandTotal,
) {
  return pw.Container(
    margin: const pw.EdgeInsets.all(16),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(flex: 3, child: _buildRemarksSection(purchase)),
        pw.SizedBox(width: 16),
        pw.Expanded(
          flex: 2,
          child: _buildTotalSection(subTotal, discount, vat, total, grandTotal),
        ),
      ],
    ),
  );
}

pw.Widget _buildRemarksSection(PurchaseModel purchase) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: PdfColors.green50,
      borderRadius: pw.BorderRadius.circular(6),
      border: pw.Border.all(color: PdfColors.green200),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Purchase Details',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green800,
            fontSize: 12,
          ),
        ),
        if (purchase.remark != null &&
            purchase.remark.toString().isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Text(
            'Remarks: ${purchase.remark}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ],
    ),
  );
}

pw.Widget _buildTotalSection(
  double subTotal,
  double discount,
  double vat,
  double total,
  double grandTotal,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: PdfColors.blue50,
      border: pw.Border.all(color: PdfColors.blue200),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      children: [
        if (subTotal > 0)
          _buildSummaryRow('Subtotal:', subTotal.toStringAsFixed(2)),
        if (discount > 0)
          _buildSummaryRow('Discount:', '-${discount.toStringAsFixed(2)}'),
        if (vat > 0) _buildSummaryRow('VAT:', vat.toStringAsFixed(2)),
        if (total > 0)
          _buildSummaryRow('Total:', total.toStringAsFixed(2), isTotal: true),
        pw.SizedBox(height: 6),
        pw.Divider(color: PdfColors.blue400, height: 1),
        pw.SizedBox(height: 6),
        _buildSummaryRow(
          'GRAND TOTAL:',
          grandTotal.toStringAsFixed(2),
          isGrandTotal: true,
        ),
      ],
    ),
  );
}

// Payment Section
pw.Widget _buildPaymentSection(double paidAmount, double dueAmount) {
  return pw.Container(
    margin: const pw.EdgeInsets.all(16),
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: dueAmount > 0 ? PdfColors.orange50 : PdfColors.green50,
      border: pw.Border.all(
        color: dueAmount > 0 ? PdfColors.orange200 : PdfColors.green200,
      ),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _buildPaymentItem('Paid Amount', paidAmount.toStringAsFixed(2)),
        _buildPaymentItem(
          'Due Amount',
          dueAmount.toStringAsFixed(2),
          isDue: dueAmount > 0,
        ),
      ],
    ),
  );
}

pw.Widget _buildPaymentItem(String label, String value, {bool isDue = false}) {
  return pw.Column(
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 11,
          color: isDue ? PdfColors.red : PdfColors.green,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        value,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 12,
          color: isDue ? PdfColors.red : PdfColors.green,
        ),
      ),
    ],
  );
}

pw.Widget _buildSummaryRow(
  String label,
  String value, {
  bool isTotal = false,
  bool isGrandTotal = false,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontWeight: isTotal || isGrandTotal
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
            fontSize: isGrandTotal ? 11 : 10,
            color: isGrandTotal ? PdfColors.blue800 : PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: isTotal || isGrandTotal
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
            fontSize: isGrandTotal ? 11 : 10,
            color: isGrandTotal ? PdfColors.blue800 : PdfColors.grey700,
          ),
        ),
      ],
    ),
  );
}

// Footer
pw.Widget _buildFooter(pw.Context context) {
  return pw.Container(
    alignment: pw.Alignment.center,
    margin: const pw.EdgeInsets.only(top: 20),
    child: pw.Text(
      'Page ${context.pageNumber} of ${context.pagesCount}',
      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
    ),
  );
}

// Helper functions
String _formatDate(DateTime? date) {
  if (date == null) return 'N/A';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _formatTime(DateTime? date) {
  if (date == null) return 'N/A';
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

PdfColor _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
      return PdfColors.green;
    case 'pending':
      return PdfColors.orange;
    case 'partial':
      return PdfColors.blue;
    case 'cancelled':
      return PdfColors.red;
    default:
      return PdfColors.grey;
  }
}
