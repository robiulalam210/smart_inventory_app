// supplier_due_advance_report_pdf.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../data/model/supplier_due_advance_report_model.dart';


Future<Uint8List> generateSupplierDueAdvanceReportPdf(
    SupplierDueAdvanceResponse reportResponse,
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
        _buildExecutiveSummary(reportResponse.summary, reportResponse.report),
        _buildBalanceOverview(reportResponse.report, reportResponse.summary),
        _buildSupplierDueAdvanceTable(reportResponse.report),
        _buildPaymentAnalysis(reportResponse.report, reportResponse.summary),
      ],
    ),
  );

  return pdf.save();
}

// Header with Report Info
pw.Widget _buildHeader(SupplierDueAdvanceResponse report) {
  final suppliersWithDue = report.report.where((s) => s.netBalance < 0).length;
  final suppliersWithAdvance = report.report.where((s) => s.netBalance > 0).length;

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
              'SUPPLIER BALANCE REPORT',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.deepOrange800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Supplier Due & Advance Analysis',
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
              '$suppliersWithDue with Due • $suppliersWithAdvance with Advance',
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
      color: PdfColors.deepOrange800,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          'SUPPLIER DUE & ADVANCE REPORT',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Supplier Payment & Credit Management',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
        ),
      ],
    ),
  );
}

// Executive Summary
pw.Widget _buildExecutiveSummary(SupplierDueAdvanceSummary summary, List<SupplierDueAdvance> report) {
  final suppliersWithDue = report.where((s) => s.netBalance < 0).length;
  final suppliersWithAdvance = report.where((s) => s.netBalance > 0).length;
  final duePercentage = summary.totalSuppliers > 0
      ? (suppliersWithDue / summary.totalSuppliers) * 100
      : 0;
  final advancePercentage = summary.totalSuppliers > 0
      ? (suppliersWithAdvance / summary.totalSuppliers) * 100
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
            color: PdfColors.deepOrange800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'FINANCIAL SUMMARY',
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
                'Total Due to Suppliers',
                '\$${summary.totalDueAmount.toStringAsFixed(2)}',
                'Payable Amount',
                PdfColors.red,
              ),
              _buildSummaryCard(
                'Total Advance to Suppliers',
                '\$${summary.totalAdvanceAmount.toStringAsFixed(2)}',
                'Prepaid Amount',
                PdfColors.green,
              ),
              _buildSummaryCard(
                'Net Balance',
                '\$${summary.netBalance.abs().toStringAsFixed(2)}',
                summary.overallStatus,
                _getNetBalanceColor(summary.netBalance),
              ),
              _buildSummaryCard(
                'Total Suppliers',
                summary.totalSuppliers.toString(),
                'Active Suppliers',
                PdfColors.blue,
              ),
              _buildSummaryCard(
                'Suppliers with Due',
                '${duePercentage.toStringAsFixed(1)}%',
                '$suppliersWithDue suppliers',
                PdfColors.orange,
              ),
              _buildSummaryCard(
                'Suppliers with Advance',
                '${advancePercentage.toStringAsFixed(1)}%',
                '$suppliersWithAdvance suppliers',
                PdfColors.teal,
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

// Balance Overview
pw.Widget _buildBalanceOverview(List<SupplierDueAdvance> suppliers, SupplierDueAdvanceSummary summary) {
  final balanceAnalysis = _analyzeBalances(suppliers);

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
            color: PdfColors.deepOrange800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'BALANCE DISTRIBUTION',
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
              // Balance Categories
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BALANCE CATEGORIES',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.deepOrange800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    ...balanceAnalysis['categories']!.entries.map((entry) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Row(
                          children: [
                            pw.Container(
                              width: 12,
                              height: 12,
                              decoration: pw.BoxDecoration(
                                color: _getBalanceCategoryColor(entry.key),
                                shape: pw.BoxShape.circle,
                              ),
                            ),
                            pw.SizedBox(width: 8),
                            pw.Expanded(
                              child: pw.Text(
                                entry.key,
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                            ),
                            pw.Text(
                              '${entry.value} suppliers',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              // Risk Analysis
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PAYMENT ANALYSIS',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.deepOrange800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'High Due (> \$1000): ${balanceAnalysis['highDueSuppliers']} suppliers',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Total High Due: \$${balanceAnalysis['highDueAmount'].toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Key Suppliers (Advance): ${balanceAnalysis['keySuppliers']}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Payment Priority: ${balanceAnalysis['paymentPriority']}',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: _getPriorityColor(balanceAnalysis['paymentPriority']!),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Supplier Due & Advance Data Table
pw.Widget _buildSupplierDueAdvanceTable(List<SupplierDueAdvance> suppliers) {
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
            color: PdfColors.deepOrange800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'SUPPLIER BALANCE DETAILS',
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
              1: const pw.FlexColumnWidth(1.2), // Supplier No
              2: const pw.FlexColumnWidth(2.5), // Supplier Name
              3: const pw.FlexColumnWidth(1.5), // Phone
              4: const pw.FlexColumnWidth(1.8), // Email
              5: const pw.FlexColumnWidth(1.2), // Due Amount
              6: const pw.FlexColumnWidth(1.2), // Advance Amount
              7: const pw.FlexColumnWidth(1.2), // Net Balance
              8: const pw.FlexColumnWidth(1.2), // Status
            },
            children: [
              // Table Header
              _buildTableHeader(),
              // Table Rows
              ...suppliers.map((supplier) => _buildTableRow(supplier)),
              // Total Row
              _buildTotalRow(suppliers),
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
      _buildHeaderCell('Supplier No'),
      _buildHeaderCell('Supplier Name'),
      _buildHeaderCell('Phone'),
      _buildHeaderCell('Email'),
      _buildHeaderCell('Due Amount'),
      _buildHeaderCell('Advance'),
      _buildHeaderCell('Net Balance'),
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
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.deepOrange800,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

pw.TableRow _buildTableRow(SupplierDueAdvance supplier) {
  final netBalance = supplier.netBalance;
  final status = supplier.balanceStatus;

  return pw.TableRow(
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
    ),
    children: [
      _buildDataCell(supplier.sl.toString(), alignment: pw.TextAlign.center),
      _buildDataCell(supplier.supplierNo.toString(), alignment: pw.TextAlign.center),
      _buildDataCell(_truncateText(supplier.supplierName, 20)),
      _buildDataCell(_formatPhone(supplier.phone)),
      _buildDataCell(_truncateText(supplier.email, 18)),
      _buildDataCell(
        supplier.presentDue > 0 ? '\$${supplier.presentDue.toStringAsFixed(2)}' : '-',
        alignment: pw.TextAlign.right,
        color: supplier.presentDue > 0 ? PdfColors.red : PdfColors.grey,
      ),
      _buildDataCell(
        supplier.presentAdvance > 0 ? '\$${supplier.presentAdvance.toStringAsFixed(2)}' : '-',
        alignment: pw.TextAlign.right,
        color: supplier.presentAdvance > 0 ? PdfColors.green : PdfColors.grey,
      ),
      _buildDataCell(
        '\$${netBalance.abs().toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: _getNetBalanceColor(netBalance),
      ),
      _buildStatusCell(status),
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
      style: pw.TextStyle(fontSize: 7, color: color ?? PdfColors.black),
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
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: pw.BoxDecoration(
        color: backgroundColor,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: statusColor),
      ),
      child: pw.Text(
        status.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 6,
          fontWeight: pw.FontWeight.bold,
          color: statusColor,
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
  );
}

pw.TableRow _buildTotalRow(List<SupplierDueAdvance> suppliers) {
  final totalDue = suppliers.fold(0.0, (sum, supplier) => sum + supplier.presentDue);
  final totalAdvance = suppliers.fold(0.0, (sum, supplier) => sum + supplier.presentAdvance);
  final netBalance = totalAdvance - totalDue;

  return pw.TableRow(
    decoration: const pw.BoxDecoration(color: PdfColors.grey50),
    children: [
      _buildDataCell(
        'TOTAL',
        alignment: pw.TextAlign.center,
        color: PdfColors.deepOrange800,
      ),
      _buildDataCell(
        '${suppliers.length} suppliers',
        color: PdfColors.deepOrange800,
      ),
      _buildDataCell('', color: PdfColors.deepOrange800),
      _buildDataCell('', color: PdfColors.deepOrange800),
      _buildDataCell('', color: PdfColors.deepOrange800),
      _buildDataCell(
        '\$${totalDue.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: PdfColors.deepOrange800,
      ),
      _buildDataCell(
        '\$${totalAdvance.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: PdfColors.deepOrange800,
      ),
      _buildDataCell(
        '\$${netBalance.abs().toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: _getNetBalanceColor(netBalance),
      ),
      _buildDataCell('', color: PdfColors.deepOrange800),
    ],
  );
}

// Payment Analysis
pw.Widget _buildPaymentAnalysis(List<SupplierDueAdvance> suppliers, SupplierDueAdvanceSummary summary) {
  final topDueSuppliers = suppliers.where((s) => s.netBalance < 0).toList()
    ..sort((a, b) => a.netBalance.compareTo(b.netBalance));
  final topAdvanceSuppliers = suppliers.where((s) => s.netBalance > 0).toList()
    ..sort((a, b) => b.netBalance.compareTo(a.netBalance));

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
            color: PdfColors.deepOrange800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'PAYMENT ANALYSIS & RECOMMENDATIONS',
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
              if (topDueSuppliers.isNotEmpty) ...[
                pw.Text(
                  '🔴 PRIORITY PAYMENTS:',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                  ),
                ),
                pw.SizedBox(height: 8),
                ...topDueSuppliers.take(3).map((supplier) {
                  final dueAmount = supplier.presentDue;
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      '• ${supplier.supplierName}: \$${dueAmount.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  );
                }),
                pw.SizedBox(height: 12),
              ],

              if (topAdvanceSuppliers.isNotEmpty) ...[
                pw.Text(
                  '🟢 ADVANCE SUPPLIERS:',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green,
                  ),
                ),
                pw.SizedBox(height: 8),
                ...topAdvanceSuppliers.take(3).map((supplier) {
                  final advanceAmount = supplier.presentAdvance;
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      '• ${supplier.supplierName}: \$${advanceAmount.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  );
                }),
                pw.SizedBox(height: 12),
              ],

              pw.Text(
                '💡 PAYMENT STRATEGY:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.deepOrange800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '• Schedule payments for ${topDueSuppliers.length} suppliers with due amounts',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '• Consider negotiating payment terms for high-due suppliers',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '• Utilize advance amounts with ${topAdvanceSuppliers.length} suppliers for future purchases',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '💰 CASH FLOW IMPACT:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.deepOrange800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '• Immediate payment requirement: \$${summary.totalDueAmount.toStringAsFixed(2)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '• Available credit with suppliers: \$${summary.totalAdvanceAmount.toStringAsFixed(2)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
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
    child: pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount} • '
              'Generated on ${_formatDateTime(DateTime.now())} • '
              'Confidential Financial Document',
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

String _formatPhone(String phone) {
  if (phone.isEmpty) return '-';
  if (phone.length <= 10) return phone;
  return '${phone.substring(0, 3)}-${phone.substring(3, 6)}-${phone.substring(6)}';
}

String _truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength - 3)}...';
}

Map<String, dynamic> _analyzeBalances(List<SupplierDueAdvance> suppliers) {
  final categories = <String, int>{
    'Due Only': 0,
    'Advance Only': 0,
    'Settled': 0,
    'Both Due & Advance': 0,
  };

  int highDueSuppliers = 0;
  double highDueAmount = 0;
  int keySuppliers = 0;

  for (final supplier in suppliers) {
    if (supplier.presentDue > 0 && supplier.presentAdvance > 0) {
      categories['Both Due & Advance'] = categories['Both Due & Advance']! + 1;
    } else if (supplier.presentDue > 0) {
      categories['Due Only'] = categories['Due Only']! + 1;
    } else if (supplier.presentAdvance > 0) {
      categories['Advance Only'] = categories['Advance Only']! + 1;
      keySuppliers++;
    } else {
      categories['Settled'] = categories['Settled']! + 1;
    }

    if (supplier.presentDue > 1000) {
      highDueSuppliers++;
      highDueAmount += supplier.presentDue;
    }
  }

  final totalDue = suppliers.fold(0.0, (sum, s) => sum + s.presentDue);
  String paymentPriority;
  if (totalDue > 20000) paymentPriority = 'High';
  else if (totalDue > 10000) paymentPriority = 'Medium';
  else if (totalDue > 5000) paymentPriority = 'Low';
  else paymentPriority = 'Normal';

  return {
    'categories': categories,
    'highDueSuppliers': highDueSuppliers,
    'highDueAmount': highDueAmount,
    'keySuppliers': keySuppliers,
    'paymentPriority': paymentPriority,
  };
}

PdfColor _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'due':
      return PdfColors.red;
    case 'advance':
      return PdfColors.green;
    case 'settled':
      return PdfColors.blue;
    default:
      return PdfColors.grey;
  }
}

PdfColor _getNetBalanceColor(double netBalance) {
  if (netBalance > 0) return PdfColors.green;
  if (netBalance < 0) return PdfColors.red;
  return PdfColors.blue;
}

PdfColor _getBalanceCategoryColor(String category) {
  switch (category) {
    case 'Due Only':
      return PdfColors.red;
    case 'Advance Only':
      return PdfColors.green;
    case 'Settled':
      return PdfColors.blue;
    case 'Both Due & Advance':
      return PdfColors.orange;
    default:
      return PdfColors.grey;
  }
}

PdfColor _getPriorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return PdfColors.red;
    case 'medium':
      return PdfColors.orange;
    case 'low':
      return PdfColors.yellow;
    case 'normal':
      return PdfColors.green;
    default:
      return PdfColors.grey;
  }
}

PdfColor _getLightBackgroundColor(PdfColor mainColor) {
  if (mainColor == PdfColors.deepOrange800) return PdfColors.orange50;
  if (mainColor == PdfColors.red) return PdfColors.red50;
  if (mainColor == PdfColors.green) return PdfColors.green50;
  if (mainColor == PdfColors.blue) return PdfColors.blue50;
  if (mainColor == PdfColors.orange) return PdfColors.orange50;
  if (mainColor == PdfColors.yellow) return PdfColors.yellow50;
  if (mainColor == PdfColors.teal) return PdfColors.cyan50;
  return PdfColors.grey100;
}