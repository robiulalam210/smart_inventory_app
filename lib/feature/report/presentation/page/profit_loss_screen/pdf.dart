// profit_loss_report_pdf.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../core/utilities/load_image_bytes.dart';
import '../../../../profile/data/model/profile_perrmission_model.dart';
import '../../../data/model/profit_loss_report_model.dart';


Future<Uint8List> generateProfitLossReportPdf(
    ProfitLossResponse reportResponse,CompanyInfo? company,
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
      footer: (context) => _buildFooter(context),
      build: (context) => [
        _buildHeader(reportResponse),
        _buildReportTitle(),
        pw.SizedBox(height: 0),
        _buildExecutiveSummary(reportResponse.summary),
        _buildIncomeStatement(reportResponse.summary),
        _buildExpenseBreakdown(reportResponse.summary),
        _buildProfitabilityAnalysis(reportResponse.summary),
      ],
    ),
  );

  return pdf.save();
}

// Header with Report Info
pw.Widget _buildHeader(ProfitLossResponse report) {
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
              'PROFIT & LOSS STATEMENT',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Financial Performance Overview',
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
              'Period: ${_formatDateRange(report.summary.dateRange)}',
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
      color: PdfColors.green800,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          'PROFIT & LOSS STATEMENT',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Comprehensive Financial Performance Analysis',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
        ),
      ],
    ),
  );
}

// Executive Summary
pw.Widget _buildExecutiveSummary(ProfitLossSummary summary) {
  final grossProfitMargin = summary.totalSales > 0
      ? (summary.grossProfit / summary.totalSales) * 100
      : 0;
  final netProfitMargin = summary.totalSales > 0
      ? (summary.netProfit / summary.totalSales) * 100
      : 0;
  final expenseRatio = summary.totalSales > 0
      ? (summary.totalExpenses / summary.totalSales) * 100
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
            color: PdfColors.green800,
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
                'Total Revenue',
                '\$${summary.totalSales.toStringAsFixed(2)}',
                'Gross Sales',
                PdfColors.green800,
              ),
              _buildSummaryCard(
                'Gross Profit',
                '\$${summary.grossProfit.toStringAsFixed(2)}',
                '${grossProfitMargin.toStringAsFixed(1)}% Margin',
                summary.grossProfit >= 0 ? PdfColors.green : PdfColors.red,
              ),
              _buildSummaryCard(
                'Net Profit',
                '\$${summary.netProfit.toStringAsFixed(2)}',
                '${netProfitMargin.toStringAsFixed(1)}% Margin',
                summary.netProfit >= 0 ? PdfColors.green : PdfColors.red,
              ),
              _buildSummaryCard(
                'Total Expenses',
                '\$${summary.totalExpenses.toStringAsFixed(2)}',
                '${expenseRatio.toStringAsFixed(1)}% of Revenue',
                PdfColors.orange,
              ),
              _buildSummaryCard(
                'COGS',
                '\$${summary.totalPurchase.toStringAsFixed(2)}',
                'Cost of Goods Sold',
                PdfColors.blue,
              ),
              _buildSummaryCard(
                'Profitability',
                summary.netProfit >= 0 ? 'Profitable' : 'Loss',
                summary.netProfit >= 0 ? 'Positive' : 'Negative',
                summary.netProfit >= 0 ? PdfColors.green : PdfColors.red,
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

// Income Statement
pw.Widget _buildIncomeStatement(ProfitLossSummary summary) {
  final grossProfitMargin = summary.totalSales > 0
      ? (summary.grossProfit / summary.totalSales) * 100
      : 0;
  final netProfitMargin = summary.totalSales > 0
      ? (summary.netProfit / summary.totalSales) * 100
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
            color: PdfColors.green800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'INCOME STATEMENT',
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
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3.0),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Revenue Section
              _buildStatementRow(
                'REVENUE',
                '',
                '',
                isHeader: true,
                backgroundColor: PdfColors.green50,
              ),
              _buildStatementRow(
                'Total Sales',
                '\$${summary.totalSales.toStringAsFixed(2)}',
                '100.0%',
              ),

              // Cost Section
              _buildStatementRow(
                'COST OF GOODS SOLD',
                '',
                '',
                isHeader: true,
                backgroundColor: PdfColors.red50,
              ),

              // _buildStatementRow(
              //   'Total Purchases',
              //   '(\$${summary.totalPurchase.toStringAsFixed(2)})',
              //   "${(summary.totalSales > 0 ? (summary.totalPurchase / summary.totalSales * 100).toStringAsFixed(1).toString())} %",
              //   isHeader: true,
              //   backgroundColor: PdfColors.red50,
              // ),
              _buildStatementRow(
                'Total Purchases',
                '(\$${summary.totalPurchase.toStringAsFixed(2)})',
                summary.totalSales > 0
                    ? '${(summary.totalPurchase / summary.totalSales * 100).toStringAsFixed(1)}%'
                    : '0.0%',
              ),

              // Gross Profit
              _buildStatementRow(
                'GROSS PROFIT',
                '\$${summary.grossProfit.toStringAsFixed(2)}',
                '${grossProfitMargin.toStringAsFixed(1)}%',
                isHeader: true,
                backgroundColor: PdfColors.blue50,
                isProfit: true,
              ),

              // Expenses Section
              _buildStatementRow(
                'OPERATING EXPENSES',
                '',
                '',
                isHeader: true,
                backgroundColor: PdfColors.orange50,
              ),
              _buildStatementRow(
                'Total Expenses',
                '(\$${summary.totalExpenses.toStringAsFixed(2)})',
                summary.totalSales > 0
                    ? '${(summary.totalExpenses / summary.totalSales * 100).toStringAsFixed(1)}%'
                    : '0.0%',
              ),

              // Net Profit
              _buildStatementRow(
                'NET PROFIT',
                '\$${summary.netProfit.toStringAsFixed(2)}',
                '${netProfitMargin.toStringAsFixed(1)}%',
                isHeader: true,
                backgroundColor: summary.netProfit >= 0 ? PdfColors.green50 : PdfColors.red50,
                isProfit: true,
                isNetProfit: true,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.TableRow _buildStatementRow(
    String description,
    String amount,
    String percentage, {
      bool isHeader = false,
      PdfColor? backgroundColor,
      bool isProfit = false,
      bool isNetProfit = false,
    }) {
  return pw.TableRow(
    decoration: backgroundColor != null
        ? pw.BoxDecoration(color: backgroundColor)
        : null,
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          description,
          style: pw.TextStyle(
            fontSize: isHeader ? 10 : 9,
            fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isHeader ? PdfColors.green800 : PdfColors.black,
          ),
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          amount,
          style: pw.TextStyle(
            fontSize: isHeader ? 10 : 9,
            fontWeight: isNetProfit ? pw.FontWeight.bold : (isHeader ? pw.FontWeight.bold : pw.FontWeight.normal),
            color: _getAmountColor(amount, isProfit, isNetProfit),
          ),
          textAlign: pw.TextAlign.right,
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          percentage,
          style: pw.TextStyle(
            fontSize: isHeader ? 10 : 9,
            fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isHeader ? PdfColors.green800 : PdfColors.grey700,
          ),
          textAlign: pw.TextAlign.right,
        ),
      ),
    ],
  );
}

// Expense Breakdown
pw.Widget _buildExpenseBreakdown(ProfitLossSummary summary) {
  if (summary.expenseBreakdown.isEmpty) {
    return pw.SizedBox();
  }

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
            color: PdfColors.green800,
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
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.0),
              1: const pw.FlexColumnWidth(2.0),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header Row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _buildHeaderCell('Expense Head'),
                  _buildHeaderCell('Subcategory'),
                  _buildHeaderCell('Amount'),
                  _buildHeaderCell('% of Total'),
                ],
              ),
              // Data Rows
              ...summary.expenseBreakdown.map((expense) {
                final percentage = summary.totalExpenses > 0
                    ? (expense.total / summary.totalExpenses) * 100
                    : 0;

                return pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
                  ),
                  children: [
                    _buildDataCell(expense.head),
                    _buildDataCell(expense.subhead),
                    _buildDataCell(
                      '\$${expense.total.toStringAsFixed(2)}',
                      alignment: pw.TextAlign.right,
                    ),
                    _buildDataCell(
                      '${percentage.toStringAsFixed(1)}%',
                      alignment: pw.TextAlign.right,
                    ),
                  ],
                );
              }),
              // Total Row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey50),
                children: [
                  _buildDataCell(
                    'TOTAL EXPENSES',
                    isBold: true,
                    color: PdfColors.green800,
                  ),
                  _buildDataCell('', isBold: true),
                  _buildDataCell(
                    '\$${summary.totalExpenses.toStringAsFixed(2)}',
                    alignment: pw.TextAlign.right,
                    isBold: true,
                    color: PdfColors.green800,
                  ),
                  _buildDataCell(
                    '100.0%',
                    alignment: pw.TextAlign.right,
                    isBold: true,
                    color: PdfColors.green800,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
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
        color: PdfColors.green800,
      ),
      textAlign: pw.TextAlign.left,
    ),
  );
}

pw.Widget _buildDataCell(
    String text, {
      pw.TextAlign alignment = pw.TextAlign.left,
      bool isBold = false,
      PdfColor? color,
    }) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 8,
        fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color ?? PdfColors.black,
      ),
      textAlign: alignment,
    ),
  );
}

// Profitability Analysis
pw.Widget _buildProfitabilityAnalysis(ProfitLossSummary summary) {
  final double grossProfitMargin = summary.totalSales > 0
      ? (summary.grossProfit / summary.totalSales) * 100
      : 0;
  final double netProfitMargin = summary.totalSales > 0
      ? (summary.netProfit / summary.totalSales) * 100
      : 0;
  final double expenseRatio = summary.totalSales > 0
      ? (summary.totalExpenses / summary.totalSales) * 100
      : 0;
  final double cogsRatio = summary.totalSales > 0
      ? (summary.totalPurchase / summary.totalSales) * 100
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
            color: PdfColors.green800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'PROFITABILITY ANALYSIS',
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
                'Gross Profit Margin',
                '${grossProfitMargin.toStringAsFixed(2)}%',
                _getMarginAssessment(grossProfitMargin, true),
                _getMarginColor(grossProfitMargin, true),
              ),
              pw.SizedBox(height: 8),
              _buildAnalysisRow(
                'Net Profit Margin',
                '${netProfitMargin.toStringAsFixed(2)}%',
                _getMarginAssessment(netProfitMargin, false),
                _getMarginColor(netProfitMargin, false),
              ),
              pw.SizedBox(height: 8),
              _buildAnalysisRow(
                'Expense to Revenue Ratio',
                '${expenseRatio.toStringAsFixed(2)}%',
                _getExpenseRatioAssessment(expenseRatio),
                _getExpenseRatioColor(expenseRatio),
              ),
              pw.SizedBox(height: 8),
              _buildAnalysisRow(
                'COGS Ratio',
                '${cogsRatio.toStringAsFixed(2)}%',
                _getCogsAssessment(cogsRatio),
                _getCogsColor(cogsRatio),
              ),
              pw.SizedBox(height: 8),
              _buildAnalysisRow(
                'Operating Efficiency',
                summary.netProfit >= 0 ? 'Efficient' : 'Inefficient',
                summary.netProfit >= 0 ? 'Positive Returns' : 'Negative Returns',
                summary.netProfit >= 0 ? PdfColors.green : PdfColors.red,
              ),
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

PdfColor _getAmountColor(String amount, bool isProfit, bool isNetProfit) {
  if (isNetProfit) {
    return amount.contains('(') ? PdfColors.red : PdfColors.green;
  }
  if (isProfit) {
    return PdfColors.green;
  }
  return amount.contains('(') ? PdfColors.red : PdfColors.black;
}

PdfColor _getMarginColor(double margin, bool isGross) {
  if (isGross) {
    return margin >= 40 ? PdfColors.green : margin >= 20 ? PdfColors.orange : PdfColors.red;
  } else {
    return margin >= 15 ? PdfColors.green : margin >= 5 ? PdfColors.orange : PdfColors.red;
  }
}

String _getMarginAssessment(double margin, bool isGross) {
  if (isGross) {
    return margin >= 40 ? 'Excellent' : margin >= 20 ? 'Good' : 'Needs Improvement';
  } else {
    return margin >= 15 ? 'Excellent' : margin >= 5 ? 'Good' : 'Needs Improvement';
  }
}

PdfColor _getExpenseRatioColor(double ratio) {
  return ratio <= 20 ? PdfColors.green : ratio <= 40 ? PdfColors.orange : PdfColors.red;
}

String _getExpenseRatioAssessment(double ratio) {
  return ratio <= 20 ? 'Efficient' : ratio <= 40 ? 'Moderate' : 'High';
}

PdfColor _getCogsColor(double ratio) {
  return ratio <= 50 ? PdfColors.green : ratio <= 70 ? PdfColors.orange : PdfColors.red;
}

String _getCogsAssessment(double ratio) {
  return ratio <= 50 ? 'Low' : ratio <= 70 ? 'Moderate' : 'High';
}

PdfColor _getLightBackgroundColor(PdfColor mainColor) {
  if (mainColor == PdfColors.green800) return PdfColors.green50;
  if (mainColor == PdfColors.green) return PdfColors.green50;
  if (mainColor == PdfColors.red) return PdfColors.red50;
  if (mainColor == PdfColors.orange) return PdfColors.orange50;
  if (mainColor == PdfColors.blue) return PdfColors.blue50;
  if (mainColor == PdfColors.purple) return PdfColors.purple50;
  return PdfColors.grey100;
}