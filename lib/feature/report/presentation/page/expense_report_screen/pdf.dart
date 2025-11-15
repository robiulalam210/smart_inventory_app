// expense_report_pdf.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../data/model/expense_report_model.dart';


Future<Uint8List> generateExpenseReportPdf(
    ExpenseReportResponse reportResponse,
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
        _buildExecutiveSummary(reportResponse.summary),
        _buildExpenseBreakdown(reportResponse.report),
        _buildExpenseTable(reportResponse.report),
        _buildSpendingAnalysis(reportResponse.report, reportResponse.summary),
      ],
    ),
  );

  return pdf.save();
}

// Header with Report Info
pw.Widget _buildHeader(ExpenseReportResponse report) {
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
              'EXPENSE ANALYSIS REPORT',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.red800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Expense Tracking & Management',
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
              'Total Expenses: ${report.report.length}',
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
      color: PdfColors.red800,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          'EXPENSE REPORT',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Detailed Expense Tracking & Analysis',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
        ),
      ],
    ),
  );
}

// Executive Summary
pw.Widget _buildExecutiveSummary(ExpenseReportSummary summary) {
  final averageExpense = summary.totalCount > 0
      ? summary.totalAmount / summary.totalCount
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
            color: PdfColors.red800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'EXPENSE SUMMARY',
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
                'Total Expenses',
                '\$${summary.totalAmount.toStringAsFixed(2)}',
                'Total Amount',
                PdfColors.red800,
              ),
              _buildSummaryCard(
                'Transaction Count',
                summary.totalCount.toString(),
                'Number of Expenses',
                PdfColors.blue,
              ),
              _buildSummaryCard(
                'Average Expense',
                '\$${averageExpense.toStringAsFixed(2)}',
                'Per Transaction',
                PdfColors.purple,
              ),
              _buildSummaryCard(
                'Period',
                _formatDateRange(summary.dateRange),
                'Reporting Period',
                PdfColors.teal,
              ),
              _buildSummaryCard(
                'Daily Average',
                '\$${(summary.totalAmount / _getDaysInRange(summary.dateRange)).toStringAsFixed(2)}',
                'Per Day',
                PdfColors.orange,
              ),
              _buildSummaryCard(
                'Expense Trend',
                summary.totalCount > 10 ? 'High' : 'Moderate',
                'Activity Level',
                summary.totalCount > 10 ? PdfColors.red : PdfColors.orange,
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

// Expense Breakdown by Category
pw.Widget _buildExpenseBreakdown(List<ExpenseReport> expenses) {
  final categoryBreakdown = _calculateCategoryBreakdown(expenses);
  final paymentMethodBreakdown = _calculatePaymentMethodBreakdown(expenses);

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
            color: PdfColors.red800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'EXPENSE BREAKDOWN',
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
              // Category Breakdown
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BY CATEGORY',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    ...categoryBreakdown.entries.map((entry) {
                      final percentage = (entry.value / _getTotalAmount(expenses)) * 100;
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                entry.key,
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                '\$${entry.value.toStringAsFixed(2)}',
                                style: const pw.TextStyle(fontSize: 8),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: const pw.TextStyle(fontSize: 8),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              // Payment Method Breakdown
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BY PAYMENT METHOD',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    ...paymentMethodBreakdown.entries.map((entry) {
                      final percentage = (entry.value / _getTotalAmount(expenses)) * 100;
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                entry.key,
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                '\$${entry.value.toStringAsFixed(2)}',
                                style: const pw.TextStyle(fontSize: 8),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: const pw.TextStyle(fontSize: 8),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
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

// Expense Data Table
pw.Widget _buildExpenseTable(List<ExpenseReport> expenses) {
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
            color: PdfColors.red800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'DETAILED EXPENSE TRANSACTIONS',
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
              2: const pw.FlexColumnWidth(2.0), // Head
              3: const pw.FlexColumnWidth(1.8), // Subhead
              4: const pw.FlexColumnWidth(1.5), // Amount
              5: const pw.FlexColumnWidth(1.5), // Payment Method
              6: const pw.FlexColumnWidth(2.0), // Note
            },
            children: [
              // Table Header
              _buildTableHeader(),
              // Table Rows
              ...expenses.map((expense) => _buildTableRow(expense)).toList(),
              // Total Row
              _buildTotalRow(expenses),
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
      _buildHeaderCell('Category'),
      _buildHeaderCell('Subcategory'),
      _buildHeaderCell('Amount'),
      _buildHeaderCell('Payment Method'),
      _buildHeaderCell('Notes'),
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
        color: PdfColors.red800,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

pw.TableRow _buildTableRow(ExpenseReport expense) {
  return pw.TableRow(
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
    ),
    children: [
      _buildDataCell(expense.sl.toString(), alignment: pw.TextAlign.center),
      _buildDataCell(_formatDate(expense.expenseDate)),
      _buildDataCell(_truncateText(expense.head, 20)),
      _buildDataCell(_truncateText(expense.subhead ?? '-', 18)),
      _buildDataCell(
        '\$${expense.amount.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: PdfColors.red,
      ),
      _buildPaymentMethodCell(expense.paymentMethod),
      _buildDataCell(_truncateText(expense.note ?? '-', 25)),
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

pw.Widget _buildPaymentMethodCell(String paymentMethod) {
  final color = _getPaymentMethodColor(paymentMethod);
  final backgroundColor = _getLightBackgroundColor(color);

  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: backgroundColor,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: color),
      ),
      child: pw.Text(
        paymentMethod.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 7,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
  );
}

pw.TableRow _buildTotalRow(List<ExpenseReport> expenses) {
  final totalAmount = expenses.fold(0.0, (sum, expense) => sum + expense.amount);

  return pw.TableRow(
    decoration: const pw.BoxDecoration(color: PdfColors.grey50),
    children: [
      _buildDataCell(
        'TOTAL',
        alignment: pw.TextAlign.center,
        color: PdfColors.red800,
      ),
      _buildDataCell(
        '${expenses.length} expenses',
        color: PdfColors.red800,
      ),
      _buildDataCell('', color: PdfColors.red800),
      _buildDataCell('', color: PdfColors.red800),
      _buildDataCell(
        '\$${totalAmount.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: PdfColors.red800,
      ),
      _buildDataCell('', color: PdfColors.red800),
      _buildDataCell('', color: PdfColors.red800),
    ],
  );
}

// Spending Analysis
pw.Widget _buildSpendingAnalysis(List<ExpenseReport> expenses, ExpenseReportSummary summary) {
  final averageExpense = summary.totalCount > 0
      ? summary.totalAmount / summary.totalCount
      : 0;
  final largestExpense = expenses.isNotEmpty
      ? expenses.reduce((a, b) => a.amount > b.amount ? a : b)
      : null;
  final smallestExpense = expenses.isNotEmpty
      ? expenses.reduce((a, b) => a.amount < b.amount ? a : b)
      : null;

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
            color: PdfColors.red800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'SPENDING ANALYSIS',
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
              _buildAnalysisRow(
                'Average Transaction Size',
                '\$${averageExpense.toStringAsFixed(2)}',
                averageExpense > 100 ? 'High' : 'Moderate',
                averageExpense > 100 ? PdfColors.red : PdfColors.orange,
              ),
              pw.SizedBox(height: 8),
              if (largestExpense != null)
                _buildAnalysisRow(
                  'Largest Expense',
                  '\$${largestExpense.amount.toStringAsFixed(2)}',
                  largestExpense.head,
                  PdfColors.red,
                ),
              pw.SizedBox(height: 8),
              if (smallestExpense != null)
                _buildAnalysisRow(
                  'Smallest Expense',
                  '\$${smallestExpense.amount.toStringAsFixed(2)}',
                  smallestExpense.head,
                  PdfColors.green,
                ),
              pw.SizedBox(height: 8),
              _buildAnalysisRow(
                'Expense Frequency',
                '${_getDaysInRange(summary.dateRange)} days',
                '${(summary.totalCount / _getDaysInRange(summary.dateRange)).toStringAsFixed(1)} expenses/day',
                PdfColors.purple,
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'TOP EXPENSE CATEGORIES:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red800,
                ),
              ),
              pw.SizedBox(height: 8),
              ..._getTopCategories(expenses).take(3).map((category) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '• ${category['head']}: \$${category['amount'].toStringAsFixed(2)} (${category['percentage'].toStringAsFixed(1)}%)',
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

pw.Widget _buildAnalysisRow(
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
              'Financial Management Document',
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

String _formatDateRange(Map<String, dynamic> dateRange) {
  final start = dateRange['start'] != null ? DateTime.parse(dateRange['start']) : null;
  final end = dateRange['end'] != null ? DateTime.parse(dateRange['end']) : null;

  if (start != null && end != null) {
    return '${_formatDate(start)} - ${_formatDate(end)}';
  } else if (start != null) {
    return 'From ${_formatDate(start)}';
  } else if (end != null) {
    return 'Until ${_formatDate(end)}';
  }
  return 'All Time';
}

int _getDaysInRange(Map<String, dynamic> dateRange) {
  final start = dateRange['start'] != null ? DateTime.parse(dateRange['start']) : null;
  final end = dateRange['end'] != null ? DateTime.parse(dateRange['end']) : DateTime.now();

  if (start != null) {
    return end.difference(start).inDays + 1;
  }
  return 30; // Default to 30 days if no range specified
}

String _truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength - 3)}...';
}

double _getTotalAmount(List<ExpenseReport> expenses) {
  return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
}

Map<String, double> _calculateCategoryBreakdown(List<ExpenseReport> expenses) {
  final breakdown = <String, double>{};

  for (final expense in expenses) {
    breakdown[expense.head] = (breakdown[expense.head] ?? 0) + expense.amount;
  }

  return breakdown;
}

Map<String, double> _calculatePaymentMethodBreakdown(List<ExpenseReport> expenses) {
  final breakdown = <String, double>{};

  for (final expense in expenses) {
    breakdown[expense.paymentMethod] = (breakdown[expense.paymentMethod] ?? 0) + expense.amount;
  }

  return breakdown;
}

List<Map<String, dynamic>> _getTopCategories(List<ExpenseReport> expenses) {
  final breakdown = _calculateCategoryBreakdown(expenses);
  final totalAmount = _getTotalAmount(expenses);

  return breakdown.entries.map((entry) {
    return {
      'head': entry.key,
      'amount': entry.value,
      'percentage': (entry.value / totalAmount) * 100,
    };
  }).toList()
    ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
}

PdfColor _getPaymentMethodColor(String paymentMethod) {
  switch (paymentMethod.toLowerCase()) {
    case 'cash':
      return PdfColors.green;
    case 'card':
    case 'credit card':
    case 'debit card':
      return PdfColors.blue;
    case 'bank transfer':
    case 'transfer':
      return PdfColors.purple;
    case 'digital wallet':
    case 'mobile payment':
      return PdfColors.orange;
    default:
      return PdfColors.grey;
  }
}

PdfColor _getLightBackgroundColor(PdfColor mainColor) {
  if (mainColor == PdfColors.red800) return PdfColors.red50;
  if (mainColor == PdfColors.red) return PdfColors.red50;
  if (mainColor == PdfColors.green) return PdfColors.green50;
  if (mainColor == PdfColors.blue) return PdfColors.blue50;
  if (mainColor == PdfColors.orange) return PdfColors.orange50;
  if (mainColor == PdfColors.purple) return PdfColors.purple50;
  if (mainColor == PdfColors.teal) return PdfColors.cyan50;
  return PdfColors.grey100;
}