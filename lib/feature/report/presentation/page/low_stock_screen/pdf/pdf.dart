// low_stock_report_pdf.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../data/model/low_stock_model.dart';

Future<Uint8List> generateLowStockReportPdf(
    LowStockResponse reportResponse,
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
        _buildCriticalAlertSection(reportResponse.summary),
        _buildSummarySection(reportResponse.summary, reportResponse.filtersApplied),
        _buildLowStockTable(reportResponse.report),
        _buildActionRecommendations(reportResponse.report, reportResponse.summary),
      ],
    ),
  );

  return pdf.save();
}

// Header with Report Info
pw.Widget _buildHeader(LowStockResponse report) {
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
              'LOW STOCK ALERT REPORT',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.orange800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Inventory Management & Replenishment',
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
              'Critical Items: ${report.summary.criticalItems}',
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
          'LOW STOCK INVENTORY REPORT',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Inventory Replenishment & Stock Management',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
        ),
      ],
    ),
  );
}

// Critical Alert Section
pw.Widget _buildCriticalAlertSection(LowStockSummary summary) {

  return pw.Container(
    margin: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      gradient: pw.LinearGradient(
        colors: [PdfColors.red50, PdfColors.orange50],
        begin: pw.Alignment.topLeft,
        end: pw.Alignment.bottomRight,
      ),
      border: pw.Border.all(color: PdfColors.red300, width: 2),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Padding(
      padding: const pw.EdgeInsets.all(16),
      child: pw.Row(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: const pw.BoxDecoration(
              color: PdfColors.red600,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Icon(
              pw.IconData(0xe3b6), // Warning icon
              color: PdfColors.white,
              size: 24,
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'STOCK ALERT - IMMEDIATE ATTENTION REQUIRED',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red800,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: '${summary.totalLowStockItems} ',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red800,
                        ),
                      ),
                      const pw.TextSpan(
                        text: 'items are below alert levels. ',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.TextSpan(
                        text: '${summary.criticalItems} ',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red800,
                        ),
                      ),
                      pw.TextSpan(
                        text: 'are critically low or out of stock.',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Summary Section
pw.Widget _buildSummarySection(
    LowStockSummary summary,
    Map<String, dynamic> filters,
    ) {
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
                'Low Stock Items',
                summary.totalLowStockItems.toString(),
                'Need Replenishment',
                PdfColors.orange,
              ),
              _buildSummaryCard(
                'Critical Items',
                summary.criticalItems.toString(),
                'Out of Stock/Urgent',
                PdfColors.red,
              ),
              _buildSummaryCard(
                'Alert Threshold',
                summary.threshold.toString(),
                'Minimum Stock Level',
                PdfColors.blue,
              ),
              _buildSummaryCard(
                'Stock Health',
                summary.criticalItems == 0 ? 'Good' : 'Attention Needed',
                'Inventory Status',
                summary.criticalItems == 0 ? PdfColors.green : PdfColors.orange,
              ),
              // Filters
              if (filters.isNotEmpty)
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

// Low Stock Data Table
pw.Widget _buildLowStockTable(List<LowStockProduct> reports) {
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
              'LOW STOCK PRODUCTS',
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
              1: const pw.FlexColumnWidth(2.5), // Product Name
              2: const pw.FlexColumnWidth(1.2), // Category
              3: const pw.FlexColumnWidth(1.2), // Brand
              4: const pw.FlexColumnWidth(1.0), // Price
              5: const pw.FlexColumnWidth(1.0), // Alert Qty
              6: const pw.FlexColumnWidth(1.0), // Current Stock
              7: const pw.FlexColumnWidth(1.0), // Sold Qty
              8: const pw.FlexColumnWidth(1.2), // Status
              9: const pw.FlexColumnWidth(1.2), // Shortfall
            },
            children: [
              // Table Header
              _buildTableHeader(),
              // Table Rows
              ...reports.map((report) => _buildTableRow(report)),
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
      _buildHeaderCell('Product Name'),
      _buildHeaderCell('Category'),
      _buildHeaderCell('Brand'),
      _buildHeaderCell('Price'),
      _buildHeaderCell('Alert Qty'),
      _buildHeaderCell('Current Stock'),
      _buildHeaderCell('Sold Qty'),
      _buildHeaderCell('Status'),
      _buildHeaderCell('Shortfall'),
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
        color: PdfColors.orange800,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

pw.TableRow _buildTableRow(LowStockProduct product) {
  final stockStatus = _getStockStatus(product);
  final shortfall = product.alertQuantity - product.totalStockQuantity;

  return pw.TableRow(
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
    ),
    children: [
      _buildDataCell(product.sl.toString(), alignment: pw.TextAlign.center),
      _buildDataCell(_truncateText(product.productName, 25)),
      _buildDataCell(_truncateText(product.category, 15)),
      _buildDataCell(_truncateText(product.brand, 12)),
      _buildDataCell(
        '\$${product.sellingPrice.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
      ),
      _buildDataCell(
        product.alertQuantity.toString(),
        alignment: pw.TextAlign.center,
      ),
      _buildDataCell(
        product.totalStockQuantity.toString(),
        alignment: pw.TextAlign.center,
        color: product.totalStockQuantity == 0
            ? PdfColors.red
            : product.totalStockQuantity <= product.alertQuantity
            ? PdfColors.orange
            : PdfColors.black,
      ),
      _buildDataCell(
        product.totalSoldQuantity.toString(),
        alignment: pw.TextAlign.center,
      ),
      _buildStatusCell(stockStatus),
      _buildDataCell(
        shortfall > 0 ? shortfall.toString() : '-',
        alignment: pw.TextAlign.center,
        color: shortfall > 0 ? PdfColors.red : PdfColors.grey,
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

// Action Recommendations
pw.Widget _buildActionRecommendations(List<LowStockProduct> products, LowStockSummary summary) {
  final criticalProducts = products.where((p) => p.totalStockQuantity == 0).toList();
  final lowStockProducts = products.where((p) => p.totalStockQuantity > 0 && p.totalStockQuantity <= p.alertQuantity).toList();

  final totalValueAtRisk = products.fold(0.0, (sum, product) {
    final shortfall = product.alertQuantity - product.totalStockQuantity;
    return sum + (shortfall > 0 ? shortfall * product.sellingPrice : 0);
  });

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
              'ACTION RECOMMENDATIONS',
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
              if (criticalProducts.isNotEmpty) ...[
                pw.Text(
                  '🚨 CRITICAL ITEMS - IMMEDIATE ACTION REQUIRED:',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '• ${criticalProducts.length} products are completely out of stock',
                  style: const pw.TextStyle(fontSize: 9),
                ),
                pw.Text(
                  '• Urgent replenishment needed to avoid lost sales',
                  style: const pw.TextStyle(fontSize: 9),
                ),
                pw.SizedBox(height: 12),
              ],

              pw.Text(
                '📋 RECOMMENDED ACTIONS:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.orange800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '• Replenish ${lowStockProducts.length} low stock items immediately',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '• Review and adjust alert quantities for frequently sold items',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '• Consider bulk ordering for high-demand products',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 8),

              pw.Text(
                '💰 FINANCIAL IMPACT:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.orange800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '• Potential sales at risk: \$${totalValueAtRisk.toStringAsFixed(2)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '• ${products.where((p) => p.totalSoldQuantity > 0).length} products have active sales history',
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
              'Inventory Management Document',
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

String _getStockStatus(LowStockProduct product) {
  if (product.totalStockQuantity == 0) return 'Out of Stock';
  if (product.totalStockQuantity <= product.alertQuantity) return 'Low Stock';
  return 'In Stock';
}

PdfColor _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'out of stock':
      return PdfColors.red;
    case 'low stock':
      return PdfColors.orange;
    case 'in stock':
      return PdfColors.green;
    default:
      return PdfColors.grey;
  }
}

PdfColor _getLightBackgroundColor(PdfColor mainColor) {
  if (mainColor == PdfColors.orange800) return PdfColors.orange50;
  if (mainColor == PdfColors.orange) return PdfColors.orange50;
  if (mainColor == PdfColors.red) return PdfColors.red50;
  if (mainColor == PdfColors.green) return PdfColors.green50;
  if (mainColor == PdfColors.blue) return PdfColors.blue50;
  return PdfColors.grey100;
}