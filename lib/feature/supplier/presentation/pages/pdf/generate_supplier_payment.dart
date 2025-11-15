// supplier_payment_pdf.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../data/model/supplier_payment/suppler_payment_model.dart';

Future<Uint8List> generateSupplierPaymentPdf(SupplierPaymentModel payment) async {
  final pdf = pw.Document();

  final amount = double.tryParse(payment.amount ?? '0') ?? 0;
  final summary = payment.paymentSummary;


  pdf.addPage(
    pw.MultiPage(
      pageTheme: const pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(25),
      ),
      header: (context) => _buildHeader(),
      footer: (context) => _buildFooter(context),
      build: (context) => [
        _buildPaymentHeader(payment),
        pw.SizedBox(height: 20),
        _buildSupplierInfo(payment),
        pw.SizedBox(height: 20),
        _buildPaymentDetails(payment, amount),
        pw.SizedBox(height: 20),
        if (summary != null) _buildPaymentSummary(summary),
        pw.SizedBox(height: 20),
        _buildAuthorizationSection(),
      ],
    ),
  );

  return pdf.save();
}

// Header with Company Info
pw.Widget _buildHeader() {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 20),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'SUPPLIER PAYMENT RECEIPT',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Official Payment Document',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
        pw.Text(
          '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    ),
  );
}

// Payment Header
pw.Widget _buildPaymentHeader(SupplierPaymentModel payment) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.blue800, width: 1.5),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    padding: const pw.EdgeInsets.all(16),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'PAYMENT NO: ${payment.spNo ?? 'N/A'}',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Supplier Payment Receipt',
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
            color: _getStatusColor(payment.paymentSummary?.status ?? ''),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Text(
            (payment.paymentSummary?.status ?? 'UNKNOWN').toUpperCase(),
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

// Supplier Information
pw.Widget _buildSupplierInfo(SupplierPaymentModel payment) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      color: PdfColors.grey50,
      borderRadius: pw.BorderRadius.circular(6),
      border: pw.Border.all(color: PdfColors.grey300),
    ),
    padding: const pw.EdgeInsets.all(16),
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
              _buildInfoRow('Supplier Name:', payment.supplierName ?? 'N/A'),
              _buildInfoRow('Phone:', payment.supplierPhone ?? 'N/A'),
              if (payment.purchaseInvoiceNo != null)
                _buildInfoRow('Purchase Invoice:', payment.purchaseInvoiceNo!),
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
              _buildInfoRow('Prepared By:', payment.preparedByName ?? 'N/A'),
              _buildInfoRow('Payment Type:', payment.paymentType ?? 'N/A'),
              _buildInfoRow('Payment Method:', payment.paymentMethod ?? 'N/A'),
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

// Payment Details
pw.Widget _buildPaymentDetails(SupplierPaymentModel payment, double amount) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(20),
    decoration: pw.BoxDecoration(
      color: PdfColors.blue50,
      border: pw.Border.all(color: PdfColors.blue200),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          'PAYMENT MADE',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: PdfColors.blue300),
          ),
          child: pw.Column(
            children: [
              pw.Text(
                '৳${amount.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Amount Paid to Supplier',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            _buildDetailItem('Payment Date', _formatDate(payment.paymentDate)),
            _buildDetailItem('Payment Method', payment.paymentMethod ?? 'N/A'),
            _buildDetailItem('Payment Type', payment.paymentType ?? 'N/A'),
            if (payment.chequeNo != null)
              _buildDetailItem('Cheque No', payment.chequeNo!),
            if (payment.chequeDate != null)
              _buildDetailItem('Cheque Date', _formatDate(payment.chequeDate)),
            if (payment.bankName != null)
              _buildDetailItem('Bank Name', payment.bankName!),
          ],
        ),
        if (payment.remark != null && payment.remark!.isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'Remarks: ${payment.remark}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ],
    ),
  );
}

pw.Widget _buildDetailItem(String label, String value) {
  return pw.Container(
    width: 150,
    child: pw.Column(
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
          style:  pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// Payment Summary
pw.Widget _buildPaymentSummary(PaymentSummary summary) {
  final before = summary.beforePayment;
  final after = summary.afterPayment;

  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        // Header
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
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
        // Content
        pw.Padding(
          padding: const pw.EdgeInsets.all(16),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (before != null)
                pw.Expanded(
                  child: _buildSummarySection('BEFORE PAYMENT', before),
                ),
              if (after != null) ...[
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: _buildSummarySection('AFTER PAYMENT', after),
                ),
              ],
            ],
          ),
        ),
        // Affected Invoices
        if (summary.affectedInvoices != null && summary.affectedInvoices!.isNotEmpty)
          _buildAffectedInvoices(summary.affectedInvoices!),
      ],
    ),
  );
}

pw.Widget _buildSummarySection(String title, dynamic paymentData) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
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
        ] else if (paymentData is AfterPayment) ...[
          _buildSummaryRow('Total Due', paymentData.totalDue),
          _buildSummaryRow('Payment Applied', paymentData.paymentApplied),
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
          '৳${amount.toStringAsFixed(2)}',
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
          'AFFECTED PURCHASE INVOICES',
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
          style:  pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// Authorization Section
pw.Widget _buildAuthorizationSection() {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 20),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        pw.Column(
          children: [
            pw.Container(
              width: 120,
              height: 1,
              color: PdfColors.black,
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Supplier Signature',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
        pw.Column(
          children: [
            pw.Container(
              width: 120,
              height: 1,
              color: PdfColors.black,
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Authorized Signature',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
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
      'Page ${context.pageNumber} of ${context.pagesCount} • Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
    ),
  );
}

// Helper functions
String _formatDate(dynamic date) {
  if (date == null) return 'N/A';
  if (date is DateTime) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
  if (date is String) {
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }
  return 'N/A';
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