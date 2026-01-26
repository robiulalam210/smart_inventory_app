// money_receipt_pdf.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/utilities/load_image_bytes.dart';
import '../../../../profile/data/model/profile_perrmission_model.dart';
import '../../../data/model/money_receipt_model/money_receipt_model.dart';
import 'package:http/http.dart'as http;


Future<Uint8List> generateMoneyReceiptPdf(MoneyreceiptModel receipt, CompanyInfo? company,) async {
  // Fetch company logo as Uint8List

  // Load company logo asynchronously
  Uint8List? logoBytes;
  if (company?.logo != null && company!.logo.isNotEmpty) {
    try {
      logoBytes = await loadImageBytes(company.logo);
    } catch (e) {
      logoBytes = null;
    }
  }
  final pdf = pw.Document();
  final amount = double.tryParse(receipt.amount ?? '0') ?? 0;
  final summary = receipt.paymentSummary;
  // Load fonts
  final roboto = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
  final robotoBold = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));
  final notoSans = pw.Font.ttf(await rootBundle.load("assets/fonts/NotoSans-Regular.ttf"));
  // Global Teme with fallback
  final theme = pw.ThemeData.withFont(
    base: roboto,
    bold: robotoBold,
    fontFallback: [notoSans],
  );

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        theme:theme ,
        pageFormat: PdfPageFormat.a4,
        buildBackground: (context) => pw.Container(color: PdfColors.white),
        margin: const pw.EdgeInsets.all(25),
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
            pw.Container(
              width: 80,
              height: 80,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: logoBytes != null && logoBytes.isNotEmpty
                  ? pw.Image(
                pw.MemoryImage(logoBytes),
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
      ),
      build: (context) => [
        _buildReceiptHeader(receipt),
        _buildCustomerInfo(receipt),
        pw.SizedBox(height: 4),
        _buildPaymentDetails(receipt, amount),
        pw.SizedBox(height: 4),
        if (summary != null) _buildPaymentSummary(summary),
        pw.SizedBox(height: 4),
        _buildAuthorizationSection(),
      ],
    ),
  );

  return pdf.save();
}

// ---------------------- HEADER ----------------------

// ---------------------- RECEIPT HEADER ----------------------
pw.Widget _buildReceiptHeader(MoneyreceiptModel receipt) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.blue800, width: 1.5),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    padding: const pw.EdgeInsets.all(8),
    margin: const pw.EdgeInsets.all(8),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'RECEIPT NO: ${receipt.mrNo ?? 'N/A'}',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Payment Receipt',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: pw.BoxDecoration(
            color: _getStatusColor(receipt.paymentSummary?.status ?? ''),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Text(
            (receipt.paymentSummary?.status ?? 'UNKNOWN').toUpperCase(),
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

// ---------------------- CUSTOMER INFO ----------------------
pw.Widget _buildCustomerInfo(MoneyreceiptModel receipt) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    margin: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey50,
      borderRadius: pw.BorderRadius.circular(6),
      border: pw.Border.all(color: PdfColors.grey300),
    ),
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
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildInfoRow('Customer Name:', receipt.customerName ?? 'N/A'),
              _buildInfoRow('Phone:', receipt.customerPhone?.toString() ?? 'N/A'),
              if (receipt.saleInvoiceNo != null)
                _buildInfoRow('Invoice No:', receipt.saleInvoiceNo!),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PAYMENT DETAILS',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildInfoRow('Seller:', receipt.sellerName ?? 'N/A'),
              _buildInfoRow('Payment Type:', receipt.paymentType ?? 'N/A'),
              _buildInfoRow('Payment Method:', receipt.paymentMethod ?? 'N/A'),
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
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
      ],
    ),
  );
}

// ---------------------- PAYMENT DETAILS ----------------------
pw.Widget _buildPaymentDetails(MoneyreceiptModel receipt, double amount) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    margin: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: PdfColors.green50,
      border: pw.Border.all(color: PdfColors.green200),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          'PAYMENT RECEIVED',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green800,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: PdfColors.green300),
          ),
          child: pw.Column(
            children: [
              pw.Text(
                amount.toStringAsFixed(2),
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green800,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Amount Received',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            _buildDetailItem('Payment Date', _formatDate(receipt.paymentDate)),
            _buildDetailItem('Payment Method', receipt.paymentMethod ?? 'N/A'),
            _buildDetailItem('Payment Type', receipt.paymentType ?? 'N/A'),
          ],
        ),
        if (receipt.remark != null && receipt.remark!.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'Remarks: ${receipt.remark}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ],
    ),
  );
}

pw.Widget _buildDetailItem(String label, String value) {
  return pw.Column(
    children: [
      pw.Text(
        label,
        style: const pw.TextStyle(
          fontSize: 9,
          color: PdfColors.grey600,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        value,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    ],
  );
}

// ---------------------- PAYMENT SUMMARY ----------------------
pw.Widget _buildPaymentSummary(PaymentSummary summary) {
  final before = summary.beforePayment;
  final after = summary.afterPayment;

  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    margin: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: const pw.BoxDecoration(
            color: PdfColors.blue800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'PAYMENT SUMMARY',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (before != null) pw.Expanded(child: _buildSummarySection('BEFORE PAYMENT', before)),
              if (after != null) ...[
                pw.SizedBox(width: 16),
                pw.Expanded(child: _buildSummarySection('AFTER PAYMENT', after)),
              ],
            ],
          ),
        ),
        if (summary.affectedInvoices != null && summary.affectedInvoices!.isNotEmpty)
          _buildAffectedInvoices(summary.affectedInvoices!),
      ],
    ),
  );
}

pw.Widget _buildSummarySection(String title, dynamic paymentData) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 8),
        if (paymentData is BeforePayment) ...[
          _buildSummaryRow('Total Due', paymentData.totalDue),
          _buildSummaryRow('Invoice Total', paymentData.invoiceTotal),
          _buildSummaryRow('Previous Paid', paymentData.previousPaid),
          _buildSummaryRow('Previous Due', paymentData.previousDue),
        ] else if (paymentData is AfterPayment) ...[
          _buildSummaryRow('Total Due', paymentData.totalDue),
          _buildSummaryRow('Payment Applied', paymentData.paymentApplied),
          _buildSummaryRow('Current Paid', paymentData.currentPaid),
          _buildSummaryRow('Current Due', paymentData.currentDue),
        ],
      ],
    ),
  );
}

pw.Widget _buildSummaryRow(String label, dynamic value) {
  final amount = double.tryParse(value?.toString() ?? '0') ?? 0;
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.Text(
          amount.toStringAsFixed(2),
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: amount < 0 ? PdfColors.red : PdfColors.black,
          ),
        ),
      ],
    ),
  );
}

// ---------------------- AFFECTED INVOICES ----------------------
pw.Widget _buildAffectedInvoices(List<AffectedInvoice> invoices) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'AFFECTED INVOICES',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 8),
        ...invoices.map((invoice) => _buildInvoiceRow(invoice)),
      ],
    ),
  );
}

pw.Widget _buildInvoiceRow(AffectedInvoice invoice) {
  final amount = double.tryParse(invoice.amountApplied?.toString() ?? '0') ?? 0;
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          invoice.invoiceNo ?? 'Unknown Invoice',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.Text(
          '৳${amount.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// ---------------------- AUTHORIZATION ----------------------
pw.Widget _buildAuthorizationSection() {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 20),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        pw.Column(
          children: [
            pw.Container(width: 120, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 4),
            pw.Text('Customer Signature', style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
        pw.Column(
          children: [
            pw.Container(width: 120, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 4),
            pw.Text('Authorized Signature', style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
      ],
    ),
  );
}

// ---------------------- HELPERS ----------------------
String _formatDate(DateTime? date) {
  if (date == null) return 'N/A';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

PdfColor _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
    case 'success':
    case 'paid':
      return PdfColors.green;
    case 'pending':
      return PdfColors.orange;
    case 'failed':
    case 'cancelled':
      return PdfColors.red;
    default:
      return PdfColors.grey;
  }
}
