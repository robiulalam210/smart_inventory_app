// In your view model or controller


// purchase_report_pdf.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../data/model/purchase_report_model.dart';


Future<Uint8List> generatePurchaseReportPdf(
    PurchaseReportResponse reportResponse,
    ) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(0),
        buildBackground: (context) => pw.Container(
          color: PdfColors.white,
        ),
      ),
      header: (context) => _buildHeader(reportResponse),
      footer: (context) => _buildFooter(context),
      build: (context) => [
        _buildReportTitle(),
        pw.SizedBox(height: 0),
        _buildSummarySection(
          reportResponse.summary,
          reportResponse.filtersApplied,
        ),
        _buildPurchaseTable(reportResponse.report),
        _buildFinancialInsights(reportResponse.summary),
      ],
    ),
  );

  return pdf.save();
}

// Header with Report Info
pw.Widget _buildHeader(PurchaseReportResponse report) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    margin: const pw.EdgeInsets.all(8),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'PURCHASE ANALYSIS REPORT',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.orange800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Comprehensive Purchase Overview',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Generated: ${_formatDateTime(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.Text(
              'Total Records: ${report.report.length}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    ),
  );
}

// Report Title
pw.Widget _buildReportTitle() {
  return pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.all(8),
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: PdfColors.orange800,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          'PURCHASE REPORT',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Supplier Transactions & Payments',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
        ),
      ],
    ),
  );
}

// Summary Section
pw.Widget _buildSummarySection(
    PurchaseReportSummary summary,
    Map<String, dynamic> filters,
    ) {
  final paymentRate = summary.totalPurchases > 0
      ? (summary.totalPaid / summary.totalPurchases) * 100
      : 0;

  return pw.Container(
    margin: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        // Header
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: const pw.BoxDecoration(
            color: PdfColors.orange800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'PURCHASE SUMMARY',
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
          padding: const pw.EdgeInsets.all(8),
          child: pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildSummaryCard(
                'Total Purchases',
                '\$${summary.totalPurchases.toStringAsFixed(2)}',
                'Gross Amount',
                PdfColors.orange800,
              ),
              _buildSummaryCard(
                'Total Paid',
                '\$${summary.totalPaid.toStringAsFixed(2)}',
                'Amount Settled',
                PdfColors.green,
              ),
              _buildSummaryCard(
                'Total Due',
                '\$${summary.totalDue.toStringAsFixed(2)}',
                'Outstanding',
                summary.totalDue > 0 ? PdfColors.orange : PdfColors.green,
              ),
              _buildSummaryCard(
                'Payment Rate',
                '${paymentRate.toStringAsFixed(2)}%',
                'Payment Efficiency',
                paymentRate >= 90
                    ? PdfColors.green
                    : paymentRate >= 70
                    ? PdfColors.orange
                    : PdfColors.red,
              ),
              _buildSummaryCard(
                'Transactions',
                summary.totalTransactions.toString(),
                'Total Orders',
                PdfColors.teal,
              ),
              _buildSummaryCard(
                'Avg. Order Value',
                '\$${(summary.totalPurchases / summary.totalTransactions).toStringAsFixed(2)}',
                'Per Transaction',
                PdfColors.purple,
              ),
              // Filters
              pw.Wrap(
                spacing: 12,
                runSpacing: 8,
                children: filters.entries.map((entry) {
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.orange50,
                      border: pw.Border.all(color: PdfColors.orange300),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      '${entry.key}: ${entry.value}',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.orange800,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildSummaryCard(
    String title,
    String value,
    String subtitle,
    PdfColor color,
    ) {
  final backgroundColor = _getLightBackgroundColor(color);

  return pw.Container(
    width: 130,
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: backgroundColor,
      border: pw.Border.all(color: color, width: 1.5),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          subtitle,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          textAlign: pw.TextAlign.center,
        ),
      ],
    ),
  );
}

// Purchase Data Table
pw.Widget _buildPurchaseTable(List<PurchaseReportModel> reports) {
  return pw.Container(
    margin: const pw.EdgeInsets.all(8),
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
            color: PdfColors.orange800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'DETAILED PURCHASE TRANSACTIONS',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ),
        // Table
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.8), // SL
              1: const pw.FlexColumnWidth(1.5), // Invoice
              2: const pw.FlexColumnWidth(1.2), // Date
              3: const pw.FlexColumnWidth(2.0), // Supplier
              4: const pw.FlexColumnWidth(1.2), // Net Total
              5: const pw.FlexColumnWidth(1.2), // Paid
              6: const pw.FlexColumnWidth(1.2), // Due
              7: const pw.FlexColumnWidth(1.2), // Status
              8: const pw.FlexColumnWidth(1.2), // Payment Status
            },
            children: [
              // Table Header
              _buildTableHeader(),
              // Table Rows
              ...reports.map((report) => _buildTableRow(report)),
              // Total Row
              _buildTotalRow(reports),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.TableRow _buildTableHeader() {
  return pw.TableRow(
    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
    children: [
      _buildHeaderCell('SL'),
      _buildHeaderCell('Invoice No'),
      _buildHeaderCell('Date'),
      _buildHeaderCell('Supplier'),
      _buildHeaderCell('Net Total'),
      _buildHeaderCell('Paid'),
      _buildHeaderCell('Due'),
      _buildHeaderCell('Status'),
      _buildHeaderCell('Payment'),
    ],
  );
}

pw.Widget _buildHeaderCell(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.orange800,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

pw.TableRow _buildTableRow(PurchaseReportModel report) {
  final double paymentPercentage = report.netTotal > 0
      ? (report.paidTotal / report.netTotal) * 100
      : 0;

  return pw.TableRow(
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
    ),
    children: [
      _buildDataCell(report.sl.toString(), alignment: pw.TextAlign.center),
      _buildDataCell(report.invoiceNo),
      _buildDataCell(_formatDate(report.purchaseDate)),
      _buildDataCell(_truncateText(report.supplier, 20)),
      _buildDataCell(
        '\$${report.netTotal.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
      ),
      _buildDataCell(
        '\$${report.paidTotal.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
      ),
      _buildDataCell(
        '\$${report.dueTotal.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: report.dueTotal > 0 ? PdfColors.orange : PdfColors.green,
      ),
      _buildStatusCell(report.status),
      _buildPaymentStatusCell(report.paymentStatus, paymentPercentage),
    ],
  );
}

pw.Widget _buildDataCell(
    String text, {
      pw.TextAlign alignment = pw.TextAlign.left,
      PdfColor? color,
    }) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 8, color: color ?? PdfColors.black),
      textAlign: alignment,
    ),
  );
}

pw.Widget _buildStatusCell(String status) {
  final statusColor = _getPurchaseStatusColor(status);
  final backgroundColor = _getLightBackgroundColor(statusColor);

  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: backgroundColor,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: statusColor),
      ),
      child: pw.Text(
        status.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 7,
          fontWeight: pw.FontWeight.bold,
          color: statusColor,
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
  );
}

pw.Widget _buildPaymentStatusCell(String status, double paymentPercentage) {
  final statusColor = _getPaymentStatusColor(status, paymentPercentage);
  final backgroundColor = _getLightBackgroundColor(statusColor);

  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: backgroundColor,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: statusColor),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            status.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
              color: statusColor,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            '${paymentPercentage.toStringAsFixed(1)}%',
            style: pw.TextStyle(
              fontSize: 6,
              color: statusColor,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

pw.TableRow _buildTotalRow(List<PurchaseReportModel> reports) {
  final totalNet = reports.fold(0.0, (sum, report) => sum + report.netTotal);
  final totalPaid = reports.fold(0.0, (sum, report) => sum + report.paidTotal);
  final totalDue = reports.fold(0.0, (sum, report) => sum + report.dueTotal);

  return pw.TableRow(
    decoration: const pw.BoxDecoration(color: PdfColors.grey50),
    children: [
      _buildDataCell(
        'TOTAL',
        alignment: pw.TextAlign.center,
        color: PdfColors.orange800,
      ),
      _buildDataCell(
        '${reports.length} transactions',
        color: PdfColors.orange800,
      ),
      _buildDataCell('', color: PdfColors.orange800),
      _buildDataCell('', color: PdfColors.orange800),
      _buildDataCell(
        '\$${totalNet.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: PdfColors.orange800,
      ),
      _buildDataCell(
        '\$${totalPaid.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: PdfColors.orange800,
      ),
      _buildDataCell(
        '\$${totalDue.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: PdfColors.orange800,
      ),
      _buildDataCell('', color: PdfColors.orange800),
      _buildDataCell('', color: PdfColors.orange800),
    ],
  );
}

// Financial Insights
pw.Widget _buildFinancialInsights(PurchaseReportSummary summary) {
  final paymentRate = summary.totalPurchases > 0
      ? (summary.totalPaid / summary.totalPurchases) * 100
      : 0;
  final duePercentage = summary.totalPurchases > 0
      ? (summary.totalDue / summary.totalPurchases) * 100
      : 0;

  return pw.Container(
    margin: const pw.EdgeInsets.all(8),
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
            color: PdfColors.orange800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'FINANCIAL INSIGHTS',
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
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildInsightRow(
                'Payment Efficiency',
                '${paymentRate.toStringAsFixed(2)}%',
                paymentRate >= 90
                    ? 'Excellent'
                    : paymentRate >= 70
                    ? 'Good'
                    : 'Needs Attention',
                paymentRate >= 90
                    ? PdfColors.green
                    : paymentRate >= 70
                    ? PdfColors.orange
                    : PdfColors.red,
              ),
              pw.SizedBox(height: 8),
              _buildInsightRow(
                'Outstanding Balance',
                '\$${summary.totalDue.toStringAsFixed(2)}',
                duePercentage > 20 ? 'High Risk' : 'Manageable',
                duePercentage > 20 ? PdfColors.red : PdfColors.orange,
              ),
              pw.SizedBox(height: 8),
              _buildInsightRow(
                'Outstanding Percentage',
                '${duePercentage.toStringAsFixed(2)}%',
                duePercentage > 20 ? 'Review Required' : 'Under Control',
                duePercentage > 20 ? PdfColors.red : PdfColors.green,
              ),
              pw.SizedBox(height: 8),
              _buildInsightRow(
                'Average Purchase Value',
                '\$${(summary.totalPurchases / summary.totalTransactions).toStringAsFixed(2)}',
                'Per Transaction',
                PdfColors.purple,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildInsightRow(
    String metric,
    String value,
    String assessment,
    PdfColor color,
    ) {
  final backgroundColor = _getLightBackgroundColor(color);

  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Expanded(
        flex: 2,
        child: pw.Text(
          metric,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.Expanded(
        flex: 1,
        child: pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.Expanded(
        flex: 2,
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: pw.BoxDecoration(
            color: backgroundColor,
            border: pw.Border.all(color: color),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            assessment,
            style: pw.TextStyle(
              fontSize: 8,
              color: color,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ),
    ],
  );
}

// Footer
pw.Widget _buildFooter(pw.Context context) {
  return pw.Container(
    alignment: pw.Alignment.center,
    margin: const pw.EdgeInsets.only(top: 20),
    child: pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount} • '
              'Generated on ${_formatDateTime(DateTime.now())} • '
              'Confidential Business Document',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ],
    ),
  );
}

// Helper functions
String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _formatDateTime(DateTime date) {
  return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String _truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength - 3)}...';
}

PdfColor _getPurchaseStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
    case 'received':
      return PdfColors.green;
    case 'pending':
    case 'processing':
      return PdfColors.orange;
    case 'cancelled':
    case 'rejected':
      return PdfColors.red;
    case 'partial':
      return PdfColors.blue;
    default:
      return PdfColors.grey;
  }
}

PdfColor _getPaymentStatusColor(String status, double paymentPercentage) {
  switch (status.toLowerCase()) {
    case 'paid':
    case 'completed':
      return PdfColors.green;
    case 'pending':
      return PdfColors.orange;
    case 'due':
    case 'overdue':
      return PdfColors.red;
    case 'partial':
      return paymentPercentage >= 50 ? PdfColors.blue : PdfColors.orange;
    default:
      return PdfColors.grey;
  }
}

PdfColor _getLightBackgroundColor(PdfColor mainColor) {
  if (mainColor == PdfColors.orange800) return PdfColors.orange50;
  if (mainColor == PdfColors.green) return PdfColors.green50;
  if (mainColor == PdfColors.red) return PdfColors.red50;
  if (mainColor == PdfColors.orange) return PdfColors.orange50;
  if (mainColor == PdfColors.purple) return PdfColors.purple50;
  if (mainColor == PdfColors.teal) return PdfColors.cyan50;
  if (mainColor == PdfColors.blue) return PdfColors.blue50;
  return PdfColors.grey100;
}