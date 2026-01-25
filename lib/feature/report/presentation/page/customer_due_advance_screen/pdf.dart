// customer_due_advance_report_pdf.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../core/utilities/load_image_bytes.dart';
import '../../../../profile/data/model/profile_perrmission_model.dart';
import '../../../data/model/customer_due_advance_report_model.dart';


Future<Uint8List> generateCustomerDueAdvanceReportPdf(
    CustomerDueAdvanceResponse reportResponse, CompanyInfo? company,
    ) async {
  // Load company logo asynchronously
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

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(0),
        buildBackground: (context) => pw.Container(
          color: PdfColors.white,
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
      ),
      // header: (context) => _buildHeader(reportResponse),
      footer: (context) => _buildFooter(context),
      build: (context) => [
        _buildHeader(reportResponse),
        _buildReportTitle(),
        pw.SizedBox(height: 0),
        _buildExecutiveSummary(reportResponse.summary,reportResponse.report),
        _buildBalanceOverview(reportResponse.report, reportResponse.summary),
        _buildCustomerDueAdvanceTable(reportResponse.report),
        _buildRiskAnalysis(reportResponse.report, reportResponse.summary),
      ],
    ),
  );

  return pdf.save();
}

// Header with Report Info
pw.Widget _buildHeader(CustomerDueAdvanceResponse report) {
  final customersWithDue = report.report.where((c) => c.presentDue > 0).length;
  final customersWithAdvance = report.report.where((c) => c.presentAdvance > 0).length;

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
              'CUSTOMER BALANCE REPORT',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.brown800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Due & Advance Balance Analysis',
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
              '$customersWithDue with Due • $customersWithAdvance with Advance',
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
      color: PdfColors.brown800,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          'CUSTOMER DUE & ADVANCE REPORT',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Customer Balance & Credit Management',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
        ),
      ],
    ),
  );
}

// Executive Summary
pw.Widget _buildExecutiveSummary(CustomerDueAdvanceSummary summary,  List<CustomerDueAdvance> report,
    ) {
  final duePercentage = summary.totalCustomers > 0
      ? (report.where((c) => c.presentDue > 0).length / summary.totalCustomers) * 100
      : 0;

  final advancePercentage = summary.totalCustomers > 0
      ? (report.where((c) => c.presentAdvance > 0).length / summary.totalCustomers) * 100
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
            color: PdfColors.brown800,
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
                'Total Due Amount',
                '\$${summary.totalDueAmount.toStringAsFixed(2)}',
                'Outstanding Receivables',
                PdfColors.red,
              ),
              _buildSummaryCard(
                'Total Advance Amount',
                '\$${summary.totalAdvanceAmount.toStringAsFixed(2)}',
                'Customer Prepayments',
                PdfColors.green,
              ),
              _buildSummaryCard(
                'Net Balance',
                '\$${summary.netBalance.abs().toStringAsFixed(2)}',
                summary.overallStatus,
                _getNetBalanceColor(summary.netBalance),
              ),
              _buildSummaryCard(
                'Total Customers',
                summary.totalCustomers.toString(),
                'Active Accounts',
                PdfColors.blue,
              ),
              _buildSummaryCard(
                'Customers with Due',
                '${duePercentage.toStringAsFixed(1)}%',
                '${report.where((c) => c.presentDue > 0).length} customers',
                PdfColors.orange,
              ),
              _buildSummaryCard(
                'Customers with Advance',
                '${advancePercentage.toStringAsFixed(1)}%',
                '${report.where((c) => c.presentAdvance > 0).length} customers',
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
pw.Widget _buildBalanceOverview(List<CustomerDueAdvance> customers, CustomerDueAdvanceSummary summary) {
  final balanceAnalysis = _analyzeBalances(customers);

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
            color: PdfColors.brown800,
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
                        color: PdfColors.brown800,
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
                              '${entry.value} customers',
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
                      'RISK ASSESSMENT',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.brown800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'High Due (> \$500): ${balanceAnalysis['highDueCustomers']} customers',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Total High Due: \$${balanceAnalysis['highDueAmount'].toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Loyal Customers (Advance): ${balanceAnalysis['loyalCustomers']}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Risk Level: ${balanceAnalysis['riskLevel']}',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: _getRiskLevelColor(balanceAnalysis['riskLevel']!),
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

// Customer Due & Advance Data Table
pw.Widget _buildCustomerDueAdvanceTable(List<CustomerDueAdvance> customers) {
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
            color: PdfColors.brown800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'CUSTOMER BALANCE DETAILS',
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
              1: const pw.FlexColumnWidth(1.2), // Customer No
              2: const pw.FlexColumnWidth(2.5), // Customer Name
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
              ...customers.map((customer) => _buildTableRow(customer)),
              // Total Row
              _buildTotalRow(customers),
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
      _buildHeaderCell('Customer No'),
      _buildHeaderCell('Customer Name'),
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
        color: PdfColors.brown800,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

pw.TableRow _buildTableRow(CustomerDueAdvance customer) {
  final netBalance = customer.netBalance;
  final status = customer.balanceStatus;

  return pw.TableRow(
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
    ),
    children: [
      _buildDataCell(customer.sl.toString(), alignment: pw.TextAlign.center),
      _buildDataCell(customer.customerNo),
      _buildDataCell(_truncateText(customer.customerName, 20)),
      _buildDataCell(_formatPhone(customer.phone)),
      _buildDataCell(_truncateText(customer.email, 18)),
      _buildDataCell(
        customer.presentDue > 0 ? '\$${customer.presentDue.toStringAsFixed(2)}' : '-',
        alignment: pw.TextAlign.right,
        color: customer.presentDue > 0 ? PdfColors.red : PdfColors.grey,
      ),
      _buildDataCell(
        customer.presentAdvance > 0 ? '\$${customer.presentAdvance.toStringAsFixed(2)}' : '-',
        alignment: pw.TextAlign.right,
        color: customer.presentAdvance > 0 ? PdfColors.green : PdfColors.grey,
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

pw.TableRow _buildTotalRow(List<CustomerDueAdvance> customers) {
  final totalDue = customers.fold(0.0, (sum, customer) => sum + customer.presentDue);
  final totalAdvance = customers.fold(0.0, (sum, customer) => sum + customer.presentAdvance);
  final netBalance = totalAdvance - totalDue;

  return pw.TableRow(
    decoration: const pw.BoxDecoration(color: PdfColors.grey50),
    children: [
      _buildDataCell(
        'TOTAL',
        alignment: pw.TextAlign.center,
        color: PdfColors.brown800,
      ),
      _buildDataCell(
        '${customers.length} customers',
        color: PdfColors.brown800,
      ),
      _buildDataCell('', color: PdfColors.brown800),
      _buildDataCell('', color: PdfColors.brown800),
      _buildDataCell('', color: PdfColors.brown800),
      _buildDataCell(
        '\$${totalDue.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: PdfColors.brown800,
      ),
      _buildDataCell(
        '\$${totalAdvance.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: PdfColors.brown800,
      ),
      _buildDataCell(
        '\$${netBalance.abs().toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: _getNetBalanceColor(netBalance),
      ),
      _buildDataCell('', color: PdfColors.brown800),
    ],
  );
}

// Risk Analysis
pw.Widget _buildRiskAnalysis(List<CustomerDueAdvance> customers, CustomerDueAdvanceSummary summary) {
  final topDueCustomers = customers.where((c) => c.presentDue > 0).toList()
    ..sort((a, b) => b.presentDue.compareTo(a.presentDue));
  final topAdvanceCustomers = customers.where((c) => c.presentAdvance > 0).toList()
    ..sort((a, b) => b.presentAdvance.compareTo(a.presentAdvance));

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
            color: PdfColors.brown800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'RISK ANALYSIS & RECOMMENDATIONS',
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
              if (topDueCustomers.isNotEmpty) ...[
                pw.Text(
                  '⚠️ TOP DUE ACCOUNTS:',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                  ),
                ),
                pw.SizedBox(height: 8),
                ...topDueCustomers.take(3).map((customer) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      '• ${customer.customerName}: \$${customer.presentDue.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  );
                }),
                pw.SizedBox(height: 12),
              ],

              if (topAdvanceCustomers.isNotEmpty) ...[
                pw.Text(
                  '✅ LOYAL CUSTOMERS (ADVANCE):',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green,
                  ),
                ),
                pw.SizedBox(height: 8),
                ...topAdvanceCustomers.take(3).map((customer) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      '• ${customer.customerName}: \$${customer.presentAdvance.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  );
                }),
                pw.SizedBox(height: 12),
              ],

              pw.Text(
                '💡 RECOMMENDATIONS:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.brown800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '• Follow up with ${topDueCustomers.length} customers having due amounts',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '• Consider credit limits for customers with high due amounts',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '• Acknowledge and appreciate ${topAdvanceCustomers.length} loyal customers',
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

Map<String, dynamic> _analyzeBalances(List<CustomerDueAdvance> customers) {
  final categories = <String, int>{
    'Due Only': 0,
    'Advance Only': 0,
    'Settled': 0,
    'Both Due & Advance': 0,
  };

  int highDueCustomers = 0;
  double highDueAmount = 0;
  int loyalCustomers = 0;

  for (final customer in customers) {
    if (customer.presentDue > 0 && customer.presentAdvance > 0) {
      categories['Both Due & Advance'] = categories['Both Due & Advance']! + 1;
    } else if (customer.presentDue > 0) {
      categories['Due Only'] = categories['Due Only']! + 1;
    } else if (customer.presentAdvance > 0) {
      categories['Advance Only'] = categories['Advance Only']! + 1;
      loyalCustomers++;
    } else {
      categories['Settled'] = categories['Settled']! + 1;
    }

    if (customer.presentDue > 500) {
      highDueCustomers++;
      highDueAmount += customer.presentDue;
    }
  }

  final totalDue = customers.fold(0.0, (sum, c) => sum + c.presentDue);
  String riskLevel;
  if (totalDue > 10000) {
    riskLevel = 'High';
  } else if (totalDue > 5000) {
    riskLevel = 'Medium';
  }
  else if (totalDue > 1000) {
    riskLevel = 'Low';
  }
  else {
    riskLevel = 'Minimal';
  }
  return {
    'categories': categories,
    'highDueCustomers': highDueCustomers,
    'highDueAmount': highDueAmount,
    'loyalCustomers': loyalCustomers,
    'riskLevel': riskLevel,
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

PdfColor _getRiskLevelColor(String riskLevel) {
  switch (riskLevel.toLowerCase()) {
    case 'high':
      return PdfColors.red;
    case 'medium':
      return PdfColors.orange;
    case 'low':
      return PdfColors.yellow;
    case 'minimal':
      return PdfColors.green;
    default:
      return PdfColors.grey;
  }
}

PdfColor _getLightBackgroundColor(PdfColor mainColor) {
  if (mainColor == PdfColors.brown800) return PdfColors.orange50;
  if (mainColor == PdfColors.red) return PdfColors.red50;
  if (mainColor == PdfColors.green) return PdfColors.green50;
  if (mainColor == PdfColors.blue) return PdfColors.blue50;
  if (mainColor == PdfColors.orange) return PdfColors.orange50;
  if (mainColor == PdfColors.yellow) return PdfColors.yellow50;
  if (mainColor == PdfColors.teal) return PdfColors.cyan50;
  return PdfColors.grey100;
}