// supplier_ledger_report_pdf.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../data/model/supplier_ledger_model.dart';


Future<Uint8List> generateSupplierLedgerReportPdf(
    SupplierLedgerResponse reportResponse,
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
        _buildReportTitle(reportResponse.summary),
        pw.SizedBox(height: 0),
        _buildSupplierSummary(reportResponse.summary),
        _buildTransactionAnalysis(reportResponse.report, reportResponse.summary),
        _buildLedgerTable(reportResponse.report, reportResponse.summary),
        _buildPaymentTrends(reportResponse.report, reportResponse.summary),
      ],
    ),
  );

  return pdf.save();
}

// Header with Report Info
pw.Widget _buildHeader(SupplierLedgerResponse report) {
  final purchaseTransactions = report.report.where((t) => t.isPurchase).length;
  final paymentTransactions = report.report.where((t) => t.isPayment).length;

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
              'SUPPLIER LEDGER REPORT',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.deepPurple800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Detailed Transaction History',
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
              '$purchaseTransactions Purchases • $paymentTransactions Payments',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    ),
  );
}

// Report Title
pw.Widget _buildReportTitle(SupplierLedgerSummary summary) {
  return pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.all(8),
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: PdfColors.deepPurple800,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          'SUPPLIER LEDGER STATEMENT',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          summary.supplierName,
          style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Supplier ID: ${summary.supplierId}',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.white),
        ),
      ],
    ),
  );
}

// Supplier Summary
pw.Widget _buildSupplierSummary(SupplierLedgerSummary summary) {
  final netMovement = summary.netMovement;
  final balanceStatus = summary.balanceStatus;

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
            color: PdfColors.deepPurple800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'ACCOUNT SUMMARY',
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
                'Opening Balance',
                '\$${summary.openingBalance.toStringAsFixed(2)}',
                'Period Start',
                PdfColors.blue,
              ),
              _buildSummaryCard(
                'Closing Balance',
                '\$${summary.closingBalance.abs().toStringAsFixed(2)}',
                balanceStatus,
                _getBalanceColor(summary.closingBalance),
              ),
              _buildSummaryCard(
                'Total Purchases',
                '\$${summary.totalDebit.toStringAsFixed(2)}',
                'Debit Amount',
                PdfColors.red,
              ),
              _buildSummaryCard(
                'Total Payments',
                '\$${summary.totalCredit.toStringAsFixed(2)}',
                'Credit Amount',
                PdfColors.green,
              ),
              _buildSummaryCard(
                'Net Movement',
                '\$${netMovement.abs().toStringAsFixed(2)}',
                netMovement >= 0 ? 'Increase' : 'Decrease',
                netMovement >= 0 ? PdfColors.red : PdfColors.green,
              ),
              _buildSummaryCard(
                'Transactions',
                summary.totalTransactions.toString(),
                'Total Entries',
                PdfColors.orange,
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

// Transaction Analysis
pw.Widget _buildTransactionAnalysis(List<SupplierLedger> transactions, SupplierLedgerSummary summary) {
  final analysis = _analyzeTransactions(transactions);
  final periodAnalysis = _analyzePeriod(transactions, summary.dateRange);

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
            color: PdfColors.deepPurple800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'TRANSACTION ANALYSIS',
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
              // Transaction Types
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'TRANSACTION TYPES',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.deepPurple800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    ...analysis['typeBreakdown']!.entries.map((entry) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Row(
                          children: [
                            pw.Container(
                              width: 12,
                              height: 12,
                              decoration: pw.BoxDecoration(
                                color: _getTransactionTypeColor(entry.key),
                                shape: pw.BoxShape.circle,
                              ),
                            ),
                            pw.SizedBox(width: 8),
                            pw.Expanded(
                              child: pw.Text(
                                '${entry.key}:',
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                            ),
                            pw.Text(
                              '${entry.value}',
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
              // Payment Methods & Activity
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PAYMENT METHODS',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.deepPurple800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    ...analysis['methodBreakdown']!.entries.take(3).map((entry) {
                      return pw.Text(
                        '• ${entry.key}: ${entry.value}',
                        style: const pw.TextStyle(fontSize: 8),
                      );
                    }).toList(),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'ACTIVITY LEVEL: ${periodAnalysis['activityLevel']}',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: _getActivityLevelColor(periodAnalysis['activityLevel']!),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Avg. ${periodAnalysis['transactionsPerDay'].toStringAsFixed(1)} transactions/day',
                      style: const pw.TextStyle(fontSize: 8),
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

// Ledger Table
pw.Widget _buildLedgerTable(List<SupplierLedger> transactions, SupplierLedgerSummary summary) {
  final runningBalances = _calculateRunningBalances(transactions, summary.openingBalance);

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
            color: PdfColors.deepPurple800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'DETAILED LEDGER ENTRIES',
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
              1: const pw.FlexColumnWidth(1.2), // Date
              2: const pw.FlexColumnWidth(1.5), // Voucher
              3: const pw.FlexColumnWidth(2.0), // Particular
              4: const pw.FlexColumnWidth(1.5), // Type
              5: const pw.FlexColumnWidth(1.2), // Method
              6: const pw.FlexColumnWidth(1.2), // Debit
              7: const pw.FlexColumnWidth(1.2), // Credit
              8: const pw.FlexColumnWidth(1.2), // Balance
            },
            children: [
              // Table Header
              _buildTableHeader(),
              // Opening Balance Row
              _buildOpeningBalanceRow(summary.openingBalance),
              // Table Rows
              ...transactions.asMap().entries.map((entry) =>
                  _buildTableRow(entry.value, runningBalances[entry.key])
              ).toList(),
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
      _buildHeaderCell('Date'),
      _buildHeaderCell('Voucher No'),
      _buildHeaderCell('Particular'),
      _buildHeaderCell('Type'),
      _buildHeaderCell('Method'),
      _buildHeaderCell('Debit'),
      _buildHeaderCell('Credit'),
      _buildHeaderCell('Balance'),
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
        color: PdfColors.deepPurple800,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

pw.TableRow _buildOpeningBalanceRow(double openingBalance) {
  return pw.TableRow(
    decoration: const pw.BoxDecoration(color: PdfColors.grey50),
    children: [
      _buildDataCell('', alignment: pw.TextAlign.center),
      _buildDataCell('Opening', alignment: pw.TextAlign.center),
      _buildDataCell('Balance', alignment: pw.TextAlign.center),
      _buildDataCell(''),
      _buildDataCell(''),
      _buildDataCell(''),
      _buildDataCell(''),
      _buildDataCell(''),
      _buildDataCell(
        '\$${openingBalance.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: _getBalanceColor(openingBalance),
      ),
    ],
  );
}

pw.TableRow _buildTableRow(SupplierLedger transaction, double runningBalance) {
  return pw.TableRow(
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
    ),
    children: [
      _buildDataCell(transaction.sl.toString(), alignment: pw.TextAlign.center),
      _buildDataCell(_formatDate(transaction.date)),
      _buildDataCell(transaction.voucherNo),
      _buildDataCell(_truncateText(transaction.particular, 20)),
      _buildTransactionTypeCell(transaction.type),
      _buildDataCell(_truncateText(transaction.method, 10)),
      _buildDataCell(
        transaction.debit > 0 ? '\$${transaction.debit.toStringAsFixed(2)}' : '-',
        alignment: pw.TextAlign.right,
        color: transaction.debit > 0 ? PdfColors.red : PdfColors.grey,
      ),
      _buildDataCell(
        transaction.credit > 0 ? '\$${transaction.credit.toStringAsFixed(2)}' : '-',
        alignment: pw.TextAlign.right,
        color: transaction.credit > 0 ? PdfColors.green : PdfColors.grey,
      ),
      _buildDataCell(
        '\$${runningBalance.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: _getBalanceColor(runningBalance),
      ),
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

pw.Widget _buildTransactionTypeCell(String type) {
  final typeColor = _getTransactionTypeColor(type);
  final backgroundColor = _getLightBackgroundColor(typeColor);

  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: pw.BoxDecoration(
        color: backgroundColor,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: typeColor),
      ),
      child: pw.Text(
        type.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 6,
          fontWeight: pw.FontWeight.bold,
          color: typeColor,
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
  );
}

// Payment Trends
pw.Widget _buildPaymentTrends(List<SupplierLedger> transactions, SupplierLedgerSummary summary) {
  final trendAnalysis = _analyzePaymentTrends(transactions);
  final paymentRecommendations = _generatePaymentRecommendations(summary);

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
            color: PdfColors.deepPurple800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'PAYMENT TRENDS & RECOMMENDATIONS',
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
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Account Status:',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: _getLightBackgroundColor(_getBalanceColor(summary.closingBalance)),
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(color: _getBalanceColor(summary.closingBalance)),
                    ),
                    child: pw.Text(
                      summary.balanceStatus.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: _getBalanceColor(summary.closingBalance),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                '📊 TRANSACTION INSIGHTS:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.deepPurple800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '• Average Purchase: \$${trendAnalysis['averagePurchase'].toStringAsFixed(2)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '• Average Payment: \$${trendAnalysis['averagePayment'].toStringAsFixed(2)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '• Payment Frequency: ${trendAnalysis['paymentFrequency']}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '💰 PAYMENT RECOMMENDATIONS:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.deepPurple800,
                ),
              ),
              pw.SizedBox(height: 8),
              ...paymentRecommendations.take(3).map((recommendation) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '• $recommendation',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                );
              }),
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

String _truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength - 3)}...';
}

List<double> _calculateRunningBalances(List<SupplierLedger> transactions, double openingBalance) {
  final runningBalances = <double>[];
  double currentBalance = openingBalance;

  for (final transaction in transactions) {
    currentBalance += transaction.debit - transaction.credit;
    runningBalances.add(currentBalance);
  }

  return runningBalances;
}

Map<String, dynamic> _analyzeTransactions(List<SupplierLedger> transactions) {
  final typeBreakdown = <String, int>{};
  final methodBreakdown = <String, int>{};

  for (final transaction in transactions) {
    typeBreakdown[transaction.type] = (typeBreakdown[transaction.type] ?? 0) + 1;
    methodBreakdown[transaction.method] = (methodBreakdown[transaction.method] ?? 0) + 1;
  }

  return {
    'typeBreakdown': typeBreakdown,
    'methodBreakdown': methodBreakdown,
  };
}

Map<String, dynamic> _analyzePeriod(List<SupplierLedger> transactions, Map<String, dynamic> dateRange) {
  final start = dateRange['start'] != null ? DateTime.parse(dateRange['start']) : null;
  final end = dateRange['end'] != null ? DateTime.parse(dateRange['end']) : DateTime.now();

  int daysInPeriod = 1;
  if (start != null) {
    daysInPeriod = end.difference(start).inDays + 1;
  }

  final transactionsPerDay = transactions.length / daysInPeriod;

  String activityLevel;
  if (transactionsPerDay > 2) {
    activityLevel = 'High';
  } else if (transactionsPerDay > 0.5) activityLevel = 'Medium';
  else activityLevel = 'Low';

  return {
    'transactionsPerDay': transactionsPerDay,
    'activityLevel': activityLevel,
  };
}

Map<String, dynamic> _analyzePaymentTrends(List<SupplierLedger> transactions) {
  final purchases = transactions.where((t) => t.isPurchase).toList();
  final payments = transactions.where((t) => t.isPayment).toList();

  final averagePurchase = purchases.isNotEmpty
      ? purchases.fold(0.0, (sum, t) => sum + t.debit) / purchases.length
      : 0;

  final averagePayment = payments.isNotEmpty
      ? payments.fold(0.0, (sum, t) => sum + t.credit) / payments.length
      : 0;

  String paymentFrequency;
  if (payments.length >= 10) paymentFrequency = 'Frequent';
  else if (payments.length >= 5) paymentFrequency = 'Regular';
  else paymentFrequency = 'Occasional';

  return {
    'averagePurchase': averagePurchase,
    'averagePayment': averagePayment,
    'paymentFrequency': paymentFrequency,
  };
}

List<String> _generatePaymentRecommendations(SupplierLedgerSummary summary) {
  final recommendations = <String>[];

  if (summary.closingBalance > 0) {
    recommendations.add('Consider scheduling payment for outstanding balance of \$${summary.closingBalance.toStringAsFixed(2)}');
    recommendations.add('Review payment terms with supplier to optimize cash flow');
  } else if (summary.closingBalance < 0) {
    recommendations.add('Supplier has advance balance - consider utilizing for future purchases');
    recommendations.add('Maintain good relationship with timely communication');
  }

  if (summary.totalDebit > 10000) {
    recommendations.add('High purchase volume - consider negotiating better payment terms');
  }

  recommendations.add('Monitor account regularly to maintain healthy supplier relationship');

  return recommendations;
}

PdfColor _getBalanceColor(double balance) {
  if (balance > 0) return PdfColors.red;
  if (balance < 0) return PdfColors.green;
  return PdfColors.blue;
}

PdfColor _getTransactionTypeColor(String type) {
  switch (type.toLowerCase()) {
    case 'opening':
      return PdfColors.orange;
    case 'purchase':
      return PdfColors.blue;
    case 'payment':
      return PdfColors.green;
    case 'adjustment':
      return PdfColors.purple;
    default:
      return PdfColors.grey;
  }
}

PdfColor _getActivityLevelColor(String level) {
  switch (level.toLowerCase()) {
    case 'high':
      return PdfColors.green;
    case 'medium':
      return PdfColors.orange;
    case 'low':
      return PdfColors.red;
    default:
      return PdfColors.grey;
  }
}

PdfColor _getLightBackgroundColor(PdfColor mainColor) {
  if (mainColor == PdfColors.deepPurple800) return PdfColors.purple50;
  if (mainColor == PdfColors.red) return PdfColors.red50;
  if (mainColor == PdfColors.green) return PdfColors.green50;
  if (mainColor == PdfColors.blue) return PdfColors.blue50;
  if (mainColor == PdfColors.orange) return PdfColors.orange50;
  if (mainColor == PdfColors.purple) return PdfColors.purple50;
  return PdfColors.grey100;
}