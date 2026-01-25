// top_products_report_pdf.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../core/utilities/load_image_bytes.dart';
import '../../../../profile/data/model/profile_perrmission_model.dart';
import '../../../data/model/top_products_model.dart';

Future<Uint8List> generateTopProductsReportPdf(
    TopProductsResponse reportResponse, CompanyInfo? company,
    ) async {
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
      build: (context) => [
        _buildHeader(reportResponse),
        _buildReportTitle(),
        pw.SizedBox(height: 0),
        _buildExecutiveSummary(reportResponse.summary),
        _buildPerformanceMetrics(reportResponse.report, reportResponse.summary),
        _buildTopProductsTable(reportResponse.report),
        _buildSalesAnalysis(reportResponse.report, reportResponse.summary),
      ],
    ),
  );

  return pdf.save();
}

// Header with Report Info
pw.Widget _buildHeader(TopProductsResponse report) {
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
              'TOP PRODUCTS PERFORMANCE REPORT',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.deepPurple800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Best Selling Products Analysis',
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
              'Top ${report.report.length} Products',
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
      color: PdfColors.deepPurple800,
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          'TOP SELLING PRODUCTS REPORT',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Sales Performance & Revenue Analysis',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
        ),
      ],
    ),
  );
}

// Executive Summary
pw.Widget _buildExecutiveSummary(TopProductsSummary summary) {
  final averageSalePerProduct = summary.totalProducts > 0
      ? summary.totalSales / summary.totalProducts
      : 0;
  final averageQuantityPerProduct = summary.totalProducts > 0
      ? summary.totalQuantitySold / summary.totalProducts
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
            color: PdfColors.deepPurple800,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Center(
            child: pw.Text(
              'SALES PERFORMANCE SUMMARY',
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
                'Total Sales Revenue',
                '\$${summary.totalSales.toStringAsFixed(2)}',
                'Gross Revenue',
                PdfColors.deepPurple800,
              ),
              _buildSummaryCard(
                'Total Quantity Sold',
                summary.totalQuantitySold.toString(),
                'Units Sold',
                PdfColors.green,
              ),
              _buildSummaryCard(
                'Products Analyzed',
                summary.totalProducts.toString(),
                'Top Performers',
                PdfColors.blue,
              ),
              _buildSummaryCard(
                'Avg. Revenue per Product',
                '\$${averageSalePerProduct.toStringAsFixed(2)}',
                'Per Product',
                PdfColors.orange,
              ),
              _buildSummaryCard(
                'Avg. Quantity per Product',
                averageQuantityPerProduct.toStringAsFixed(1),
                'Units per Product',
                PdfColors.teal,
              ),
              _buildSummaryCard(
                'Sales Period',
                _formatDateRange(summary.dateRange),
                'Analysis Period',
                PdfColors.purple,
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

// Performance Metrics
pw.Widget _buildPerformanceMetrics(List<TopProductModel> products, TopProductsSummary summary) {
  final topProduct = products.isNotEmpty ? products.first : null;
  final performanceAnalysis = _analyzePerformance(products, summary);

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
              'PERFORMANCE METRICS',
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
              // Top Performer
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '🏆 TOP PERFORMER',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.deepPurple800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    if (topProduct != null) ...[
                      pw.Text(
                        _truncateText(topProduct.productName, 30),
                        style:  pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Revenue: \$${topProduct.totalSoldPrice.toStringAsFixed(2)}',
                                  style: const pw.TextStyle(fontSize: 8),
                                ),
                                pw.Text(
                                  'Quantity: ${topProduct.totalSoldQuantity}',
                                  style: const pw.TextStyle(fontSize: 8),
                                ),
                              ],
                            ),
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.green50,
                              borderRadius: pw.BorderRadius.circular(4),
                              border: pw.Border.all(color: PdfColors.green),
                            ),
                            child: pw.Text(
                              '#1 RANK',
                              style: pw.TextStyle(
                                fontSize: 7,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      pw.Text(
                        'No data available',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              // Performance Stats
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '📊 PERFORMANCE STATS',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.deepPurple800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Top 20% Generate: ${performanceAnalysis['top20RevenuePercentage'].toStringAsFixed(1)}% of Revenue',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Avg. Price: \$${performanceAnalysis['averagePrice'].toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Sales Concentration: ${performanceAnalysis['concentrationRating']}',
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

// Top Products Data Table
pw.Widget _buildTopProductsTable(List<TopProductModel> products) {
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
              'TOP SELLING PRODUCTS RANKING',
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
              0: const pw.FlexColumnWidth(0.8), // Rank
              1: const pw.FlexColumnWidth(0.8), // SL
              2: const pw.FlexColumnWidth(3.0), // Product Name
              3: const pw.FlexColumnWidth(1.2), // Price
              4: const pw.FlexColumnWidth(1.2), // Quantity Sold
              5: const pw.FlexColumnWidth(1.5), // Revenue
              6: const pw.FlexColumnWidth(1.5), // Performance
            },
            children: [
              // Table Header
              _buildTableHeader(),
              // Table Rows
              ...products.asMap().entries.map((entry) => _buildTableRow(entry.value, entry.key + 1)),
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
      _buildHeaderCell('Rank'),
      _buildHeaderCell('SL'),
      _buildHeaderCell('Product Name'),
      _buildHeaderCell('Price'),
      _buildHeaderCell('Qty Sold'),
      _buildHeaderCell('Revenue'),
      _buildHeaderCell('Performance'),
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

pw.TableRow _buildTableRow(TopProductModel product, int rank) {
  final performance = _calculatePerformanceRating(product, rank);

  return pw.TableRow(
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
    ),
    children: [
      _buildRankCell(rank),
      _buildDataCell(product.sl.toString(), alignment: pw.TextAlign.center),
      _buildDataCell(_truncateText(product.productName, 25)),
      _buildDataCell(
        '\$${product.sellingPrice.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
      ),
      _buildDataCell(
        product.totalSoldQuantity.toString(),
        alignment: pw.TextAlign.center,
      ),
      _buildDataCell(
        '\$${product.totalSoldPrice.toStringAsFixed(2)}',
        alignment: pw.TextAlign.right,
        color: PdfColors.green,
      ),
      _buildPerformanceCell(performance),
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

pw.Widget _buildRankCell(int rank) {
  final color = _getRankColor(rank);
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
        '#$rank',
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

pw.Widget _buildPerformanceCell(String performance) {
  final color = _getPerformanceColor(performance);
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
        performance.toUpperCase(),
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

// Sales Analysis
pw.Widget _buildSalesAnalysis(List<TopProductModel> products, TopProductsSummary summary) {
  final analysis = _analyzeSalesPatterns(products);
  final recommendations = _generateRecommendations(analysis);

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
              'SALES ANALYSIS & RECOMMENDATIONS',
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
              pw.Text(
                '📈 SALES INSIGHTS:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.deepPurple800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '• Top 3 products generate ${analysis['top3RevenueShare'].toStringAsFixed(1)}% of total revenue',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '• ${analysis['highVolumeProducts']} high-volume products identified',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '• ${analysis['premiumProducts']} premium products (>${analysis['premiumThreshold'].toStringAsFixed(2)})',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                '💡 RECOMMENDATIONS:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.deepPurple800,
                ),
              ),
              pw.SizedBox(height: 8),
              ...recommendations.take(3).map((recommendation) {
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
              'Sales Performance Document',
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

String _truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength - 3)}...';
}

Map<String, dynamic> _analyzePerformance(List<TopProductModel> products, TopProductsSummary summary) {
  if (products.isEmpty) {
    return {
      'top20RevenuePercentage': 0,
      'averagePrice': 0,
      'concentrationRating': 'Low',
    };
  }

  // Calculate top 20% revenue share
  final top20Count = (products.length * 0.2).ceil();
  final top20Revenue = products.take(top20Count).fold(0.0, (sum, product) => sum + product.totalSoldPrice);
  final top20RevenuePercentage = (top20Revenue / summary.totalSales) * 100;

  // Calculate average price
  final averagePrice = products.fold(0.0, (sum, product) => sum + product.sellingPrice) / products.length;

  // Determine concentration rating
  String concentrationRating;
  if (top20RevenuePercentage > 80) {
    concentrationRating = 'Very High';
  } else if (top20RevenuePercentage > 60) {
    concentrationRating = 'High';
  } else if (top20RevenuePercentage > 40) {
    concentrationRating = 'Moderate';
  } else {
    concentrationRating = 'Low';
  }

  return {
    'top20RevenuePercentage': top20RevenuePercentage,
    'averagePrice': averagePrice,
    'concentrationRating': concentrationRating,
  };
}

String _calculatePerformanceRating(TopProductModel product, int rank) {
  if (rank <= 3) return 'Excellent';
  if (rank <= 10) return 'Good';
  if (rank <= 20) return 'Average';
  return 'Low';
}

PdfColor _getPerformanceColor(String performance) {
  switch (performance.toLowerCase()) {
    case 'excellent':
      return PdfColors.green;
    case 'good':
      return PdfColors.blue;
    case 'average':
      return PdfColors.orange;
    case 'low':
      return PdfColors.red;
    default:
      return PdfColors.grey;
  }
}

PdfColor _getRankColor(int rank) {
  if (rank == 1) return PdfColors.indigo50;
  if (rank <= 3) return PdfColors.green;
  if (rank <= 10) return PdfColors.blue;
  return PdfColors.grey;
}

Map<String, dynamic> _analyzeSalesPatterns(List<TopProductModel> products) {
  if (products.isEmpty) {
    return {
      'top3RevenueShare': 0,
      'highVolumeProducts': 0,
      'premiumProducts': 0,
      'premiumThreshold': 0,
    };
  }

  // Top 3 revenue share
  final top3Revenue = products.take(3).fold(0.0, (sum, product) => sum + product.totalSoldPrice);
  final totalRevenue = products.fold(0.0, (sum, product) => sum + product.totalSoldPrice);
  final top3RevenueShare = (top3Revenue / totalRevenue) * 100;

  // High volume products (above average quantity)
  final averageQuantity = products.fold(0, (sum, product) => sum + product.totalSoldQuantity) / products.length;
  final highVolumeProducts = products.where((p) => p.totalSoldQuantity > averageQuantity).length;

  // Premium products (above average price)
  final averagePrice = products.fold(0.0, (sum, product) => sum + product.sellingPrice) / products.length;
  final premiumProducts = products.where((p) => p.sellingPrice > averagePrice).length;

  return {
    'top3RevenueShare': top3RevenueShare,
    'highVolumeProducts': highVolumeProducts,
    'premiumProducts': premiumProducts,
    'premiumThreshold': averagePrice,
  };
}

List<String> _generateRecommendations(Map<String, dynamic> analysis) {
  final recommendations = <String>[];

  if (analysis['top3RevenueShare'] > 60) {
    recommendations.add('Focus on maintaining top 3 products as they drive majority of revenue');
  }

  if (analysis['highVolumeProducts'] > 0) {
    recommendations.add('Ensure adequate stock for high-volume products to avoid stockouts');
  }

  if (analysis['premiumProducts'] > 0) {
    recommendations.add('Leverage premium products for margin improvement and upselling');
  }

  recommendations.add('Consider bundling popular products to increase average order value');
  recommendations.add('Monitor inventory levels for top performers to optimize stock turnover');

  return recommendations;
}

PdfColor _getLightBackgroundColor(PdfColor mainColor) {
  if (mainColor == PdfColors.deepPurple800) return PdfColors.purple50;
  if (mainColor == PdfColors.green) return PdfColors.green50;
  if (mainColor == PdfColors.blue) return PdfColors.blue50;
  if (mainColor == PdfColors.orange) return PdfColors.orange50;
  if (mainColor == PdfColors.red) return PdfColors.red50;
  if (mainColor == PdfColors.yellowAccent) return PdfColors.yellow50;
  if (mainColor == PdfColors.purple) return PdfColors.purple50;
  return PdfColors.grey100;
}