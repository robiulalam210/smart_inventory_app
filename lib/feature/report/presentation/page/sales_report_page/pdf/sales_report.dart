// sales_report_pdf.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../data/model/sales_report_model.dart';

Future<Uint8List> generateSalesReportPdf(
  SalesReportResponse reportResponse,
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(0),
        buildBackground: (context) => pw.Container(
          color: PdfColors.white, // Solid white background
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
        _buildSalesTable(reportResponse.report),
        _buildPerformanceInsights(reportResponse.summary),
      ],
    ),
  );

  return pdf.save();
}

// Header with Report Info
pw.Widget _buildHeader(SalesReportResponse report) {
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
              'SALES ANALYSIS REPORT',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Comprehensive Sales Performance',
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
      color: PdfColors.blue800,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          'SALES REPORT',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Detailed Transaction Analysis',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
        ),
      ],
    ),
  );
}

// Summary Section
pw.Widget _buildSummarySection(
  SalesReportSummary summary,
  Map<String, dynamic> filters,
) {
  final profitMargin = summary.totalSales > 0
      ? (summary.totalProfit / summary.totalSales) * 100
      : 0;
  final collectionRate = summary.totalSales > 0
      ? (summary.totalCollected / summary.totalSales) * 100
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
            color: PdfColors.blue800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'EXECUTIVE SUMMARY',
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
                'Total Sales',
                '\$${summary.totalSales.toStringAsFixed(2)}',
                'Gross Revenue',
                PdfColors.blue800,
              ),
              _buildSummaryCard(
                'Total Profit',
                '\$${summary.totalProfit.toStringAsFixed(2)}',
                'Net Profit',
                summary.totalProfit >= 0 ? PdfColors.green : PdfColors.red,
              ),
              _buildSummaryCard(
                'Profit Margin',
                '${profitMargin.toStringAsFixed(2)}%',
                'Average Margin',
                profitMargin >= 20
                    ? PdfColors.green
                    : profitMargin >= 10
                    ? PdfColors.orange
                    : PdfColors.red,
              ),
              _buildSummaryCard(
                'Total Collected',
                '\$${summary.totalCollected.toStringAsFixed(2)}',
                'Amount Received',
                PdfColors.purple,
              ),
              _buildSummaryCard(
                'Total Due',
                '\$${summary.totalDue.toStringAsFixed(2)}',
                'Outstanding',
                summary.totalDue > 0 ? PdfColors.orange : PdfColors.green,
              ),
              _buildSummaryCard(
                'Collection Rate',
                '${collectionRate.toStringAsFixed(2)}%',
                'Collection Efficiency',
                collectionRate >= 90
                    ? PdfColors.green
                    : collectionRate >= 70
                    ? PdfColors.orange
                    : PdfColors.red,
              ),
              _buildSummaryCard(
                'Transactions',
                summary.totalTransactions.toString(),
                'Total Orders',
                PdfColors.teal,
              ),
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
                      color: PdfColors.blue50,
                      border: pw.Border.all(color: PdfColors.blue300),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      ' ${entry.value}',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.blue800,
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
  // Use lighter background colors for better readability
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

// Filters Section

// Sales Data Table
pw.Widget _buildSalesTable(List<SalesReportModel> reports) {
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
            color: PdfColors.blue800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'DETAILED TRANSACTIONS',
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
              3: const pw.FlexColumnWidth(2.0), // Customer
              4: const pw.FlexColumnWidth(1.2), // Sales Price
              5: const pw.FlexColumnWidth(1.2), // Profit
              6: const pw.FlexColumnWidth(1.2), // Collected
              7: const pw.FlexColumnWidth(1.2), // Due
              8: const pw.FlexColumnWidth(1.2), // Status
            },
            children: [
              // Table Header
              _buildTableHeader(),
              // Table Rows
              ...reports.map((report) => _buildTableRow(report)).toList(),
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
      _buildHeaderCell('Customer'),
      _buildHeaderCell('Sales Price'),
      _buildHeaderCell('Profit'),
      _buildHeaderCell('Collected'),
      _buildHeaderCell('Due'),
      _buildHeaderCell('Status'),
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
        color: PdfColors.blue800,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

pw.TableRow _buildTableRow(SalesReportModel report) {
  final profitMargin = report.salesPrice > 0
      ? (report.profit / report.salesPrice) * 100
      : 0;

  return pw.TableRow(
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
    ),
    children: [
      _buildDataCell(report.sl.toString(), alignment: pw.TextAlign.center),
      _buildDataCell(report.invoiceNo),
      _buildDataCell(_formatDate(report.saleDate)),
      _buildDataCell(_truncateText(report.customerName, 20)),
      _buildDataCell(
        '\$${report.salesPrice.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
      ),
      _buildDataCell(
        '${profitMargin.toStringAsFixed(1)}%',
        alignment: pw.TextAlign.right,
        color: profitMargin >= 0 ? PdfColors.green : PdfColors.red,
      ),
      _buildDataCell(
        '\$${report.collectAmount.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
      ),
      _buildDataCell(
        '\$${report.dueAmount.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: report.dueAmount > 0 ? PdfColors.orange : PdfColors.green,
      ),
      _buildStatusCell(report.paymentStatus),
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
  final statusColor = _getStatusColor(status);
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

pw.TableRow _buildTotalRow(List<SalesReportModel> reports) {
  final totalSales = reports.fold(
    0.0,
    (sum, report) => sum + report.salesPrice,
  );
  final totalProfit = reports.fold(0.0, (sum, report) => sum + report.profit);
  final totalCollected = reports.fold(
    0.0,
    (sum, report) => sum + report.collectAmount,
  );
  final totalDue = reports.fold(0.0, (sum, report) => sum + report.dueAmount);

  return pw.TableRow(
    decoration: const pw.BoxDecoration(color: PdfColors.grey50),
    children: [
      _buildDataCell(
        'TOTAL',
        alignment: pw.TextAlign.center,
        color: PdfColors.blue800,
      ),
      _buildDataCell(
        '${reports.length} transactions',
        color: PdfColors.blue800,
      ),
      _buildDataCell('', color: PdfColors.blue800),
      _buildDataCell('', color: PdfColors.blue800),
      _buildDataCell(
        '\$${totalSales.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: PdfColors.blue800,
      ),
      _buildDataCell(
        '\$${totalProfit.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: PdfColors.blue800,
      ),
      _buildDataCell(
        '\$${totalCollected.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: PdfColors.blue800,
      ),
      _buildDataCell(
        '\$${totalDue.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: PdfColors.blue800,
      ),
      _buildDataCell('', color: PdfColors.blue800),
    ],
  );
}

// Performance Insights
pw.Widget _buildPerformanceInsights(SalesReportSummary summary) {
  final profitMargin = summary.totalSales > 0
      ? (summary.totalProfit / summary.totalSales) * 100
      : 0;
  final collectionRate = summary.totalSales > 0
      ? (summary.totalCollected / summary.totalSales) * 100
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
            color: PdfColors.blue800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'PERFORMANCE INSIGHTS',
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
                'Overall Profitability',
                '${profitMargin.toStringAsFixed(2)}%',
                profitMargin >= 20
                    ? 'Excellent'
                    : profitMargin >= 10
                    ? 'Good'
                    : 'Needs Improvement',
                profitMargin >= 20
                    ? PdfColors.green
                    : profitMargin >= 10
                    ? PdfColors.orange
                    : PdfColors.red,
              ),
              pw.SizedBox(height: 8),
              _buildInsightRow(
                'Collection Efficiency',
                '${collectionRate.toStringAsFixed(2)}%',
                collectionRate >= 90
                    ? 'Excellent'
                    : collectionRate >= 70
                    ? 'Good'
                    : 'Needs Attention',
                collectionRate >= 90
                    ? PdfColors.green
                    : collectionRate >= 70
                    ? PdfColors.orange
                    : PdfColors.red,
              ),
              pw.SizedBox(height: 8),
              _buildInsightRow(
                'Outstanding Balance',
                '\$${summary.totalDue.toStringAsFixed(2)}',
                summary.totalDue > 0 ? 'Follow-up Required' : 'All Collected',
                summary.totalDue > 0 ? PdfColors.orange : PdfColors.green,
              ),
              pw.SizedBox(height: 8),
              _buildInsightRow(
                'Average Transaction Value',
                '\$${(summary.totalSales / summary.totalTransactions).toStringAsFixed(2)}',
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

PdfColor _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
    case 'completed':
    case 'success':
      return PdfColors.green;
    case 'pending':
    case 'processing':
      return PdfColors.orange;
    case 'due':
    case 'overdue':
    case 'failed':
    case 'cancelled':
      return PdfColors.red;
    case 'partial':
      return PdfColors.blue;
    default:
      return PdfColors.grey;
  }
}

// Helper function to get light background colors for better readability
// Helper function to get light background colors for better readability
PdfColor _getLightBackgroundColor(PdfColor mainColor) {
  if (mainColor == PdfColors.blue800) return PdfColors.blue50;
  if (mainColor == PdfColors.green) return PdfColors.green50;
  if (mainColor == PdfColors.red) return PdfColors.red50;
  if (mainColor == PdfColors.orange) return PdfColors.orange50;
  if (mainColor == PdfColors.purple) return PdfColors.purple50;
  if (mainColor == PdfColors.teal) return PdfColors.cyan50;
  if (mainColor == PdfColors.cyan) return PdfColors.cyan50;
  return PdfColors.grey100;
}
