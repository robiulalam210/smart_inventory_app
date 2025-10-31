// lib/feature/report/presentation/screens/stock_report_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_inventory/core/configs/app_colors.dart';
import 'package:smart_inventory/core/configs/app_images.dart';
import 'package:smart_inventory/core/configs/app_text.dart';
import 'package:smart_inventory/core/shared/widgets/sideMenu/sidebar.dart';
import 'package:smart_inventory/core/widgets/date_range.dart';
import 'package:smart_inventory/feature/report/presentation/bloc/stock_report_bloc/stock_report_bloc.dart';

import '../../../../../responsive.dart';
import '../../../data/model/stock_report_model.dart';

class StockReportScreen extends StatefulWidget {
  const StockReportScreen({super.key});

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  DateRange? selectedDateRange;
  String _sortBy = 'value'; // Default sort by value
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _fetchStockReport();
  }

  void _fetchStockReport({
    DateTime? from,
    DateTime? to,
  }) {
    context.read<StockReportBloc>().add(FetchStockReport(
      context: context,
      from: from,
      to: to,
    ));
  }

  void _sortStock(List<StockProduct> products, String column, bool ascending) {
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
    final isBigScreen = Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return Container(
      color: AppColors.bg,
      child: SafeArea(
        child: ResponsiveRow(
          children: [
            if (isBigScreen) _buildSidebar(),
            _buildContentArea(isBigScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() => ResponsiveCol(
    xs: 0,
    sm: 1,
    md: 1,
    lg: 2,
    xl: 2,
    child: Container(color: Colors.white, child: const Sidebar()),
  );

  Widget _buildContentArea(bool isBigScreen) {
    return ResponsiveCol(
      xs: 12,
      lg: 10,
      child: RefreshIndicator(
        onRefresh: () async => _fetchStockReport(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            children: [
              _buildFilterRow(),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 16),
              _buildStockTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 📅 Date Range Picker
        SizedBox(
          width: 260,
          child: CustomDateRangeField(
            selectedDateRange: selectedDateRange,
            onDateRangeSelected: (value) {
              setState(() => selectedDateRange = value);
              if (value != null) {
                _fetchStockReport(from: value.start, to: value.end);
              }
            },
          ),
        ),

        // Sort Options
        BlocBuilder<StockReportBloc, StockReportState>(
          builder: (context, state) {
            if (state is! StockReportSuccess) return const SizedBox();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sort, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text('Sort by:', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _sortBy,
                    icon: const Icon(Icons.arrow_drop_down, size: 16),
                    elevation: 16,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    underline: const SizedBox(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _sortStock(state.response.report, newValue, _sortAscending);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 'name', child: Text('Name')),
                      DropdownMenuItem(value: 'category', child: Text('Category')),
                      DropdownMenuItem(value: 'stock', child: Text('Stock')),
                      DropdownMenuItem(value: 'value', child: Text('Value')),
                      DropdownMenuItem(value: 'profit_margin', child: Text('Margin')),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 16,
                    ),
                    onPressed: () {
                      setState(() => _sortAscending = !_sortAscending);
                      if (state is StockReportSuccess) {
                        _sortStock(state.response.report, _sortBy, _sortAscending);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),

        // Action Buttons
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() => selectedDateRange = null);
                context.read<StockReportBloc>().add(ClearStockReportFilters());
                _fetchStockReport();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text("Clear"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.grey,
                foregroundColor: AppColors.blackColor,
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              onPressed: () => _fetchStockReport(),
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return BlocBuilder<StockReportBloc, StockReportState>(
      builder: (context, state) {
        if (state is! StockReportSuccess) return const SizedBox();

        final summary = state.response.summary;
        final products = state.response.report;

        // Calculate additional metrics
        final outOfStockCount = products.where((p) => p.currentStock == 0).length;
        final lowStockCount = products.where((p) => p.currentStock > 0 && p.currentStock <= 10).length;
        final highValueProducts = products.where((p) => p.value > 1000).length;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildSummaryCard(
              "Total Products",
              summary.totalProducts.toString(),
              Icons.inventory_2,
              AppColors.primaryColor,
            ),
            _buildSummaryCard(
              "Total Stock Value",
              "\$${summary.totalStockValue.toStringAsFixed(2)}",
              Icons.attach_money,
              Colors.green,
            ),
            _buildSummaryCard(
              "Total Quantity",
              summary.totalStockQuantity.toString(),
              Icons.shopping_cart,
              Colors.blue,
            ),
            _buildSummaryCard(
              "Avg Stock Value",
              "\$${summary.averageStockValue.toStringAsFixed(2)}",
              Icons.analytics,
              Colors.orange,
            ),
            _buildSummaryCard(
              "Out of Stock",
              outOfStockCount.toString(),
              Icons.error_outline,
              Colors.red,
            ),
            _buildSummaryCard(
              "Low Stock",
              lowStockCount.toString(),
              Icons.warning,
              Colors.orange,
            ),
            _buildSummaryCard(
              "High Value Items",
              highValueProducts.toString(),
              Icons.star,
              Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
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
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockTable() {
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
            return _noDataWidget("No stock data found");
          }
          final sortedProducts = _getSortedProducts(state.response.report);
          return StockDataTableWidget(
            products: sortedProducts,
            sortBy: _sortBy,
            sortAscending: _sortAscending,
            onSort: (column, ascending) => _sortStock(state.response.report, column, ascending),
          );
        } else if (state is StockReportFailed) {
          return _errorWidget(state.content);
        }
        return _noDataWidget("No data available");
      },
    );
  }

  Widget StockDataTableWidget({
    required List<StockProduct> products,
    required String sortBy,
    required bool sortAscending,
    required Function(String, bool) onSort,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
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
        child: DataTable(
          sortColumnIndex: _getSortColumnIndex(sortBy),
          sortAscending: sortAscending,
          headingRowColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) => AppColors.primaryColor.withOpacity(0.1),
          ),
          columns: [
            _buildDataColumn('#', 'sl'),
            _buildDataColumn('Product Name', 'name'),
            _buildDataColumn('Category', 'category'),
            _buildDataColumn('Brand', 'brand'),
            _buildDataColumn('Avg Cost', 'cost'),
            _buildDataColumn('Selling Price', 'price'),
            _buildDataColumn('Current Stock', 'stock'),
            _buildDataColumn('Stock Value', 'value'),
            _buildDataColumn('Potential Value', 'potential'),
            _buildDataColumn('Profit Margin', 'profit_margin'),
            _buildDataColumn('Stock Status', 'status'),
            _buildDataColumn('Profitability', 'profitability'),
          ],
          rows: products.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;

            return DataRow(
              color: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return index % 2 == 0 ? Colors.grey.withOpacity(0.05) : Colors.transparent;
                },
              ),
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(
                  Text(
                    product.productName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                DataCell(Text(product.category)),
                DataCell(Text(product.brand)),
                DataCell(Text('\$${product.avgPurchasePrice.toStringAsFixed(2)}')),
                DataCell(Text('\$${product.sellingPrice.toStringAsFixed(2)}')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.stockStatusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: product.stockStatusColor),
                    ),
                    child: Text(
                      product.currentStock.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: product.stockStatusColor,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '\$${product.value.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
                DataCell(
                  Text(
                    '\$${product.potentialValue.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: product.potentialValue > product.value ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.profitabilityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${product.profitMargin.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: product.profitabilityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.stockStatusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.stockStatus,
                      style: TextStyle(
                        color: product.stockStatusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.profitabilityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.profitability,
                      style: TextStyle(
                        color: product.profitabilityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  DataColumn _buildDataColumn(String label, String columnId) {
    return DataColumn(
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      onSort: (columnIndex, ascending) {
        _sortStock([], columnId, ascending);
      },
    );
  }
  int _getSortColumnIndex(String sortBy) {
    switch (sortBy) {
      case 'name': return 1;
      case 'category': return 2;
      case 'stock': return 6;
      case 'value': return 7;
      case 'profit_margin': return 9;
      default: return 7; // Default to value
    }
  }

  Widget _noDataWidget(String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(AppImages.noData, width: 200, height: 200),
        const SizedBox(height: 12),
        Text(message),
        const SizedBox(height: 8),
        ElevatedButton(
            onPressed: _fetchStockReport,
            child: const Text("Refresh")
        ),
      ],
    ),
  );

  Widget _errorWidget(String error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 60, color: Colors.red),
        const SizedBox(height: 16),
        Text("Error: $error"),
        const SizedBox(height: 8),
        ElevatedButton(
            onPressed: _fetchStockReport,
            child: const Text("Retry")
        ),
      ],
    ),
  );
}