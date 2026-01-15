import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:printing/printing.dart';
import '/core/core.dart';
import '/core/widgets/date_range.dart';
import '/feature/report/presentation/bloc/stock_report_bloc/stock_report_bloc.dart';
import '/feature/report/presentation/page/stock_report_screen/pdf.dart';

import '../../../data/model/stock_report_model.dart';

class MobileStockReportScreen extends StatefulWidget {
  const MobileStockReportScreen({super.key});

  @override
  State<MobileStockReportScreen> createState() => _MobileStockReportScreenState();
}

class _MobileStockReportScreenState extends State<MobileStockReportScreen> {
  DateRange? selectedDateRange;
  String _sortBy = 'value';
  bool _sortAscending = false;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchStockReport();
  }

  void _fetchStockReport({DateTime? from, DateTime? to}) {
    context.read<StockReportBloc>().add(FetchStockReport(
      context: context,
      from: from,
      to: to,
    ));
  }

  void _handleSort(String column, bool ascending) {
    setState(() {
      _sortBy = column;
      _sortAscending = ascending;
    });
  }

  List<StockProduct> _getSortedProducts(List<StockProduct> products) {
    List<StockProduct> sorted = List.from(products);

    switch (_sortBy) {
      case 'name':
        sorted.sort((a, b) => a.productName.compareTo(b.productName));
        break;
      case 'category':
        sorted.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'stock':
        sorted.sort((a, b) => a.currentStock.compareTo(b.currentStock));
        break;
      case 'value':
        sorted.sort((a, b) => a.value.compareTo(b.value));
        break;
      case 'profit_margin':
        sorted.sort((a, b) => a.profitMargin.compareTo(b.profitMargin));
        break;
    }

    return _sortAscending ? sorted : sorted.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bottomNavBg(context),
      appBar: AppBar(
        title: const Text('Stock Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchStockReport(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchStockReport(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMobileFilterSection(),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 16),
              _buildSortOptions(),
              const SizedBox(height: 16),
              _buildStockList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _isFilterExpanded = !_isFilterExpanded);
        },
        child: Icon(_isFilterExpanded ? Icons.filter_alt_off : Icons.filter_alt),
        tooltip: 'Toggle Filters',
      ),
    );
  }

  Widget _buildMobileFilterSection() {
    return Card(
      child: ExpansionPanelList(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        expansionCallback: (int index, bool isExpanded) {
          setState(() => _isFilterExpanded = !isExpanded);
        },
        children: [
          ExpansionPanel(
            headerBuilder: (context, isExpanded) {
              return const ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Date Range Filter'),
              );
            },
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CustomDateRangeField(
                    isLabel: true,
                    selectedDateRange: selectedDateRange,
                    onDateRangeSelected: (value) {
                      setState(() => selectedDateRange = value);
                      if (value != null) {
                        _fetchStockReport(from: value.start, to: value.end);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedDateRange = null;
                              _isFilterExpanded = false;
                            });
                            context.read<StockReportBloc>().add(ClearStockReportFilters());
                            _fetchStockReport();
                          },
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Clear Filter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.grey[800],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _generatePdf,
                          icon: const Icon(Icons.picture_as_pdf, size: 18),
                          label: const Text('PDF Report'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            isExpanded: _isFilterExpanded,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<StockReportBloc, StockReportState>(
      builder: (context, state) {
        if (state is! StockReportSuccess) return const SizedBox();

        final summary = state.response.summary;
        final products = state.response.report;

        final outOfStockCount = products.where((p) => p.currentStock == 0).length;
        final lowStockCount = products.where((p) => p.currentStock > 0 && p.currentStock <= 10).length;

        return Column(
          children: [
            Row(
              children: [
                Flexible(
                  child: _buildMobileSummaryCard(
                    "Total Products",
                    summary.totalProducts.toString(),
                    Icons.inventory_2,
                    AppColors.primaryColor(context),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _buildMobileSummaryCard(
                    "Stock Value",
                    "\$${summary.totalStockValue.toStringAsFixed(2)}",
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  child: _buildMobileSummaryCard(
                    "Total Quantity",
                    summary.totalStockQuantity.toString(),
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _buildMobileSummaryCard(
                    "Avg Value",
                    "\$${summary.averageStockValue.toStringAsFixed(2)}",
                    Icons.analytics,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (outOfStockCount > 0 || lowStockCount > 0)
              Row(
                children: [
                  if (outOfStockCount > 0)
                    Flexible(
                      child: _buildMobileSummaryCard(
                        "Out of Stock",
                        outOfStockCount.toString(),
                        Icons.error_outline,
                        Colors.red,
                      ),
                    ),
                  if (outOfStockCount > 0 && lowStockCount > 0) const SizedBox(width: 8),
                  if (lowStockCount > 0)
                    Flexible(
                      child: _buildMobileSummaryCard(
                        "Low Stock",
                        lowStockCount.toString(),
                        Icons.warning,
                        Colors.orange,
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildMobileSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sort Options', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sortBy,
                    decoration: const InputDecoration(
                      labelText: 'Sort by',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'name', child: Text('Product Name')),
                      DropdownMenuItem(value: 'category', child: Text('Category')),
                      DropdownMenuItem(value: 'stock', child: Text('Stock Level')),
                      DropdownMenuItem(value: 'value', child: Text('Stock Value')),
                      DropdownMenuItem(value: 'profit_margin', child: Text('Profit Margin')),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _handleSort(newValue, _sortAscending);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    _handleSort(_sortBy, !_sortAscending);
                  },
                  tooltip: _sortAscending ? 'Ascending' : 'Descending',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockList() {
    return BlocBuilder<StockReportBloc, StockReportState>(
      builder: (context, state) {
        if (state is StockReportLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading stock report..."),
              ],
            ),
          );
        } else if (state is StockReportSuccess) {
          if (state.response.report.isEmpty) {
            return _buildEmptyState();
          }
          final sortedProducts = _getSortedProducts(state.response.report);
          return _buildMobileStockList(sortedProducts);
        } else if (state is StockReportFailed) {
          return _buildErrorState(state.content);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildMobileStockList(List<StockProduct> products) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isOutOfStock = product.currentStock == 0;
        final isLowStock = product.currentStock > 0 && product.currentStock <= 10;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.productName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(product.category, style: const TextStyle(fontSize: 10)),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(product.brand, style: const TextStyle(fontSize: 10)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: product.stockStatusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(product.currentStock.toString(),
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: product.stockStatusColor)),
                          Text(product.stockStatus,
                              style: TextStyle(fontSize: 10, color: product.stockStatusColor)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPriceItem('Cost', '\$${product.avgPurchasePrice.toStringAsFixed(2)}', Colors.orange),
                    _buildPriceItem('Selling', '\$${product.sellingPrice.toStringAsFixed(2)}', Colors.blue),
                    _buildPriceItem('Value', '\$${product.value.toStringAsFixed(2)}', Colors.green),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: product.profitabilityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text('Profit Margin', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text('${product.profitMargin.toStringAsFixed(1)}%',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: product.profitabilityColor)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: product.profitabilityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text('Profitability', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text(product.profitability,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: product.profitabilityColor)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 6,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1.0,
                    child: Container(
                      decoration: BoxDecoration(color: product.stockStatusColor, borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Stock Level', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    Text('${product.currentStock} units',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: product.stockStatusColor)),
                  ],
                ),
                if (isOutOfStock || isLowStock)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isOutOfStock ? Colors.red : Colors.orange).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isOutOfStock ? Colors.red : Colors.orange),
                    ),
                    child: Row(
                      children: [
                        Icon(isOutOfStock ? Icons.error_outline : Icons.warning,
                            color: isOutOfStock ? Colors.red : Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isOutOfStock
                                ? 'Out of stock - Immediate restock needed!'
                                : 'Low stock - Consider restocking soon',
                            style: TextStyle(
                                fontSize: 12,
                                color: isOutOfStock ? Colors.red : Colors.orange,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AppImages.noData, width: 150, height: 150),
          const SizedBox(height: 16),
          Text("No Stock Data Found",
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text("Stock data will appear here when available",
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchStockReport, child: const Text("Refresh Data")),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text("Error Loading Stock Report",
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(error, style: const TextStyle(fontSize: 14, color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchStockReport, child: const Text("Try Again")),
        ],
      ),
    );
  }

  void _generatePdf() {
    final state = context.read<StockReportBloc>().state;
    if (state is StockReportSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Stock Report PDF'),
              actions: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            body: PdfPreview(
              build: (format) => generateStockReportPdf(state.response),
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No stock data available'), backgroundColor: Colors.orange),
      );
    }
  }
}
