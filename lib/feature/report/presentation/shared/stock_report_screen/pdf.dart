// stock_report_pdf.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../core/utilities/load_image_bytes.dart';
import '../../../../profile/data/model/profile_perrmission_model.dart';
import '../../../data/model/stock_report_model.dart';


Future<Uint8List> generateStockReportPdf(
    StockReportResponse reportResponse, CompanyInfo? company,
    ) async {Uint8List? logoBytes;
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
      build: (context) => [
        _buildReportTitle(),
        _buildExecutiveSummary(reportResponse.summary,reportResponse.report),
        _buildInventoryHealth(reportResponse.report),
        buildStockTable(reportResponse.report),
        _buildValuationAnalysis(reportResponse.report, reportResponse.summary),
      ],
    ),
  );

  return pdf.save();
}

// Header with Report Info
pw.Widget _buildHeader(StockReportResponse report) {
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
              'STOCK INVENTORY REPORT',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.purple800,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Complete Inventory Analysis & Valuation',
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
              'Total Products: ${report.report.length}',
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
      color: PdfColors.purple800,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          'STOCK INVENTORY REPORT',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Complete Stock Analysis & Valuation',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
        ),
      ],
    ),
  );
}

pw.Widget _buildExecutiveSummary(StockSummary summary, List<StockProduct> products) {
  final potentialValue = _calculatePotentialValue(products);
  final profitMargin = potentialValue > 0
      ? ((potentialValue - summary.totalStockValue) / potentialValue) * 100
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
            color: PdfColors.purple800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'INVENTORY SUMMARY',
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
                'Total Stock Value',
                '\$${summary.totalStockValue.toStringAsFixed(2)}',
                'At Cost',
                PdfColors.purple800,
              ),
              _buildSummaryCard(
                'Potential Sales Value',
                '\$${potentialValue.toStringAsFixed(2)}',
                'At Selling Price',
                PdfColors.green,
              ),
              _buildSummaryCard(
                'Total Products',
                summary.totalProducts.toString(),
                'SKUs in Inventory',
                PdfColors.blue,
              ),
              _buildSummaryCard(
                'Total Quantity',
                summary.totalStockQuantity.toString(),
                'Units in Stock',
                PdfColors.orange,
              ),
              _buildSummaryCard(
                'Avg. Product Value',
                '\$${summary.averageStockValue.toStringAsFixed(2)}',
                'Per SKU',
                PdfColors.teal,
              ),
              _buildSummaryCard(
                'Potential Profit',
                '${profitMargin.toStringAsFixed(1)}%',
                'Gross Margin',
                profitMargin > 20 ? PdfColors.green : PdfColors.orange,
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

// Inventory Health Analysis
pw.Widget _buildInventoryHealth(List<StockProduct> products) {
  final stockAnalysis = _analyzeStockHealth(products);
  final categoryBreakdown = _calculateCategoryBreakdown(products);

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
            color: PdfColors.purple800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'INVENTORY HEALTH ANALYSIS',
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
              // Stock Status
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'STOCK STATUS DISTRIBUTION',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.purple800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    ...stockAnalysis['statusDistribution']!.entries.map((entry) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Row(
                          children: [
                            pw.Container(
                              width: 12,
                              height: 12,
                              decoration: pw.BoxDecoration(
                                color: _getStatusColor(entry.key),
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
                              '${entry.value} products',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              pw.SizedBox(width: 5),
              // Category Breakdown
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'TOP CATEGORIES BY VALUE',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.purple800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    ...categoryBreakdown.entries.take(5).map((entry) {
                      final percentage = (entry.value / stockAnalysis['totalValue']!) * 100;
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
                    }),
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

// Stock Data Table
pw.Widget buildStockTable(List<StockProduct> products) {
  return pw.Container(
    margin: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      borderRadius: pw.BorderRadius.circular(8),
      border: pw.Border.all(color: PdfColors.grey400, width: 1),
    ),
    child: pw.Column(
      children: [
        // Header
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.purple800,
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'DETAILED STOCK INVENTORY',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ),

        // Table Body
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            borderRadius: const pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(8),
              bottomRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.grey300,
              width: 0.5,
            ),
            children: [
              _buildTableHeader(),
              ...products.map(_buildTableRow),
              _buildTotalRow(products),
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
      _buildHeaderCell('Product No'),
      _buildHeaderCell('Product Name'),
      _buildHeaderCell('Category'),
      _buildHeaderCell('Brand'),
      _buildHeaderCell('Cost'),
      _buildHeaderCell('Price'),
      _buildHeaderCell('Qty'),
      _buildHeaderCell('Value'),
      _buildHeaderCell('Margin'),
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
        color: PdfColors.purple800,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

pw.TableRow _buildTableRow(StockProduct product) {
  final stockStatus = _getStockStatus(product.currentStock);
  final profitMargin = product.profitMargin;

  return pw.TableRow(
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
    ),
    children: [
      _buildDataCell(product.sl.toString(), alignment: pw.TextAlign.center),
      _buildDataCell(product.productNo.toString(), alignment: pw.TextAlign.center),
      _buildDataCell(_truncateText(product.productName, 20)),
      _buildDataCell(_truncateText(product.category, 12)),
      _buildDataCell(_truncateText(product.brand, 10)),
      _buildDataCell(
        '\$${product.avgPurchasePrice.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
      ),
      _buildDataCell(
        '\$${product.sellingPrice.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
      ),
      _buildDataCell(
        product.currentStock.toString(),
        alignment: pw.TextAlign.center,
        color: _getQuantityColor(product.currentStock),
      ),
      _buildDataCell(
        '\$${product.value.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
      ),
      _buildMarginCell(profitMargin),
      _buildStatusCell(stockStatus),
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

pw.Widget _buildMarginCell(double margin) {
  final color = _getMarginColor(margin);
  final backgroundColor = _getLightBackgroundColor(color);

  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: pw.BoxDecoration(
        color: backgroundColor,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: color),
      ),
      child: pw.Text(
        '${margin.toStringAsFixed(1)}%',
        style: pw.TextStyle(
          fontSize: 6,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
        textAlign: pw.TextAlign.center,
      ),
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

pw.TableRow _buildTotalRow(List<StockProduct> products) {
  final totalValue = products.fold(0.0, (sum, product) => sum + product.value);
  final totalQuantity = products.fold(0, (sum, product) => sum + product.currentStock);

  return pw.TableRow(
    decoration: const pw.BoxDecoration(color: PdfColors.grey50),
    children: [
      _buildDataCell(
        'TOTAL',
        alignment: pw.TextAlign.center,
        color: PdfColors.purple800,
      ),
      _buildDataCell(
        '${products.length} products',
        color: PdfColors.purple800,
      ),
      _buildDataCell('', color: PdfColors.purple800),
      _buildDataCell('', color: PdfColors.purple800),
      _buildDataCell('', color: PdfColors.purple800),
      _buildDataCell('', color: PdfColors.purple800),
      _buildDataCell('', color: PdfColors.purple800),
      _buildDataCell(
        totalQuantity.toString(),
        alignment: pw.TextAlign.center,
        color: PdfColors.purple800,
      ),
      _buildDataCell(
        '\$${totalValue.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: PdfColors.purple800,
      ),
      _buildDataCell('', color: PdfColors.purple800),
      _buildDataCell('', color: PdfColors.purple800),
    ],
  );
}

// Valuation Analysis
pw.Widget _buildValuationAnalysis(List<StockProduct> products, StockSummary summary) {
  final analysis = _analyzeStockHealth(products);
  final topProducts = products..sort((a, b) => b.value.compareTo(a.value));
  final highMarginProducts = products.where((p) => p.profitMargin > 30).toList();

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
            color: PdfColors.purple800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'VALUATION & PERFORMANCE ANALYSIS',
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
                'Inventory Turnover Potential',
                analysis['turnoverRating'] ?? 'Good',
                'Based on stock levels',
                _getTurnoverColor(analysis['turnoverRating'] ?? ''),
              ),
              pw.SizedBox(height: 8),
              _buildAnalysisRow(
                'High-Value Products',
                '${topProducts.take(5).length} items',
                'Top 80% of inventory value',
                PdfColors.purple,
              ),
              pw.SizedBox(height: 8),
              _buildAnalysisRow(
                'High-Margin Products',
                '${highMarginProducts.length} items',
                '>30% profit margin',
                PdfColors.green,
              ),
              pw.SizedBox(height: 8),
              _buildAnalysisRow(
                'Stock-Out Risk',
                '${analysis['outOfStock']} products',
                'Requires immediate attention',
                analysis['outOfStock']! > 0 ? PdfColors.red : PdfColors.green,
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'TOP 5 HIGH-VALUE PRODUCTS:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.purple800,
                ),
              ),
              pw.SizedBox(height: 8),
              ...topProducts.take(5).map((product) {
                final percentage = (product.value / summary.totalStockValue) * 100;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    '• ${product.productName}: \$${product.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%) - ${product.profitMargin.toStringAsFixed(1)}% margin',
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

double _calculatePotentialValue(List<StockProduct> products) {
  return products.fold(0.0, (sum, product) => sum + product.potentialValue);
}

Map<String, dynamic> _analyzeStockHealth(List<StockProduct> products) {
  final statusDistribution = <String, int>{};
  int outOfStock = 0;
  int lowStock = 0;
  double totalValue = 0;

  for (final product in products) {
    final status = _getStockStatus(product.currentStock);
    statusDistribution[status] = (statusDistribution[status] ?? 0) + 1;

    if (product.currentStock == 0) outOfStock++;
    if (product.currentStock <= 10) lowStock++;

    totalValue += product.value;
  }

  final healthScore = _calculateHealthScore(products);
  String turnoverRating;
  if (healthScore >= 80) {
    turnoverRating = 'Excellent';
  } else if (healthScore >= 60) {
    turnoverRating = 'Good';
  }
  else if (healthScore >= 40) {
    turnoverRating = 'Fair';
  }
  else {
    turnoverRating = "Poor";
  }

  return {
    'statusDistribution': statusDistribution,
    'outOfStock': outOfStock,
    'lowStock': lowStock,
    'totalValue': totalValue,
    'healthScore': healthScore,
    'turnoverRating': turnoverRating,
  };
}

double _calculateHealthScore(List<StockProduct> products) {
  if (products.isEmpty) return 0;

  double score = 0;
  for (final product in products) {
    if (product.currentStock == 0) {
      score += 0;
    } else if (product.currentStock <= 10) {
      score += 40;
    } else if (product.currentStock <= 25) {
      score += 70;
    } else {
      score += 90;
    }
  }

  return score / products.length;
}

Map<String, double> _calculateCategoryBreakdown(List<StockProduct> products) {
  final breakdown = <String, double>{};

  for (final product in products) {
    breakdown[product.category] = (breakdown[product.category] ?? 0) + product.value;
  }

  // Sort by value in descending order
  final sortedEntries = breakdown.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return Map.fromEntries(sortedEntries);
}

String _getStockStatus(int quantity) {
  if (quantity == 0) return 'Out of Stock';
  if (quantity <= 10) return 'Low Stock';
  if (quantity <= 25) return 'Medium Stock';
  return 'High Stock';
}

PdfColor _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'out of stock':
      return PdfColors.red;
    case 'low stock':
      return PdfColors.orange;
    case 'medium stock':
      return PdfColors.blue;
    case 'high stock':
      return PdfColors.green;
    default:
      return PdfColors.grey;
  }
}

PdfColor _getQuantityColor(int quantity) {
  if (quantity == 0) return PdfColors.red;
  if (quantity <= 10) return PdfColors.orange;
  if (quantity <= 25) return PdfColors.blue;
  return PdfColors.green;
}

PdfColor _getMarginColor(double margin) {
  if (margin > 50) return PdfColors.green;
  if (margin > 20) return PdfColors.blue;
  if (margin > 0) return PdfColors.orange;
  return PdfColors.red;
}

PdfColor _getTurnoverColor(String rating) {
  switch (rating.toLowerCase()) {
    case 'excellent':
      return PdfColors.green;
    case 'good':
      return PdfColors.blue;
    case 'fair':
      return PdfColors.orange;
    case 'poor':
      return PdfColors.red;
    default:
      return PdfColors.grey;
  }
}

PdfColor _getLightBackgroundColor(PdfColor mainColor) {
  if (mainColor == PdfColors.purple800) return PdfColors.purple50;
  if (mainColor == PdfColors.purple) return PdfColors.purple50;
  if (mainColor == PdfColors.green) return PdfColors.green50;
  if (mainColor == PdfColors.red) return PdfColors.red50;
  if (mainColor == PdfColors.orange) return PdfColors.orange50;
  if (mainColor == PdfColors.blue) return PdfColors.blue50;
  if (mainColor == PdfColors.teal) return PdfColors.cyan50;
  return PdfColors.grey100;
}