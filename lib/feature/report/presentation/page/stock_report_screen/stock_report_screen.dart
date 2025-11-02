// lib/feature/report/presentation/screens/stock_report_screen.dart
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:smart_inventory/core/core.dart';
import 'package:smart_inventory/core/widgets/date_range.dart';
import 'package:smart_inventory/feature/report/presentation/bloc/stock_report_bloc/stock_report_bloc.dart';

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

  void _handleSort(String column, bool ascending) {
    setState(() {
      _sortBy = column;
      _sortAscending = ascending;
    });
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
  final ScrollController _horizontalScrollController = ScrollController();
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
      lg: 12,
      child: RefreshIndicator(
        onRefresh: () async => _fetchStockReport(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            children: [
              // _buildFilterRow(),
              // const SizedBox(height: 8),
              _buildSummaryCards(),
              const SizedBox(height: 8),
              _buildStockTable(),
            ],
          ),
        ),
      ),
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
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildSummaryCard(
              "Total Products",
              summary.totalProducts.toString(),
              Icons.inventory_2,
              AppColors.primaryColor,
            ),
            _buildSummaryCard(
              "Total Stock Value",
              summary.totalStockValue.toStringAsFixed(2),
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

            SizedBox(
              width: 260,
              child: CustomDateRangeField(
                isLabel: false,

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
                  height: 40,
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sort, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text('Sort by:', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
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
                          _sortStock(state.response.report, _sortBy, _sortAscending);
                                                },
                      ),
                    ],
                  ),
                );
              },
            ),

            AppButton(
              size: 100,
                color: AppColors.grey,
                textColor: AppColors.blackColor,
                name: "Clear", onPressed: (){
              setState(() => selectedDateRange = null);
              context.read<StockReportBloc>().add(ClearStockReportFilters());
              _fetchStockReport();
            }),

            IconButton(
              onPressed: () => _fetchStockReport(),
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh",
            ),

          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
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
                SizedBox(height: 8),
                Text("Loading stock report..."),
              ],
            ),
          );
        } else if (state is StockReportSuccess) {
          if (state.response.report.isEmpty) {
            return _noDataWidget("No stock data found");
          }
          final sortedProducts = _getSortedProducts(state.response.report);
          return stockDataTableWidget(
            products: sortedProducts,
            sortBy: _sortBy,
            sortAscending: _sortAscending,
          );
        } else if (state is StockReportFailed) {
          return _errorWidget(state.content);
        }
        return _noDataWidget("No data available");
      },
    );
  }

  Widget stockDataTableWidget({
    required List<StockProduct> products,
    required String sortBy,
    required bool sortAscending,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        const int numColumns = 12;
        const double minColumnWidth = 80.0;

        final double dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

        return Scrollbar(
          trackVisibility: true,
          controller: _horizontalScrollController,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: BoxConstraints(minWidth: totalWidth),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DataTable(
                sortColumnIndex: _getSortColumnIndex(sortBy),
                sortAscending: sortAscending,
                headingRowColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) => AppColors.primaryColor,
                ),
                dataRowMinHeight: 50,
                dataRowMaxHeight: 60,
                columnSpacing: 8,
                horizontalMargin: 12,
                columns: _buildDataColumns(dynamicColumnWidth),
                rows: products.asMap().entries.map((entry) {
                  final index = entry.key;
                  final product = entry.value;
                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                        return index % 2 == 0 ? Colors.grey.withValues(alpha: 0.05) : null;
                      },
                    ),
                    cells: _buildDataCells(product, index, dynamicColumnWidth),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildDataColumns(double columnWidth) {
    return [
      _buildDataColumn('SL', 'sl', columnWidth * 0.3),
      _buildDataColumn('Product Name', 'name', columnWidth * 1.5),
      _buildDataColumn('Category', 'category', columnWidth ),
      _buildDataColumn('Brand', 'brand', columnWidth * 1.2),
      _buildDataColumn('Avg Cost', 'cost', columnWidth),
      _buildDataColumn('Selling Price', 'price', columnWidth),
      _buildDataColumn('Current Stock', 'stock', columnWidth),
      _buildDataColumn('Stock Value', 'value', columnWidth),
      _buildDataColumn('Potential Value', 'potential', columnWidth),
      _buildDataColumn('Profit Margin', 'profit_margin', columnWidth),
      _buildDataColumn('Stock Status', 'status', columnWidth),
      _buildDataColumn('Profitability', 'profitability', columnWidth),
    ];
  }

  DataColumn _buildDataColumn(String label, String columnId, double width) {
    final isSortable = columnId != 'sl' &&
        columnId != 'brand' &&
        columnId != 'cost' &&
        columnId != 'price';

    return DataColumn(
      label: SizedBox(
        width: width,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12,color: AppColors.white),
          textAlign: TextAlign.center,
        ),
      ),
      onSort: isSortable ? (columnIndex, ascending) {
        _handleSort(columnId, ascending); // Fixed: Use _handleSort instead of onSort
      } : null,
    );
  }

  List<DataCell> _buildDataCells(StockProduct product, int index, double columnWidth) {
    return [
      _buildIndexCell(index, columnWidth * 0.3),
      _buildProductNameCell(product, columnWidth * 1.5),
      _buildTextCell(product.category, columnWidth ),
      _buildTextCell(product.brand, columnWidth * 1.2),
      _buildPriceCell(product.avgPurchasePrice, columnWidth),
      _buildPriceCell(product.sellingPrice, columnWidth),
      _buildStockCell(product, columnWidth),
      _buildValueCell(product.value, columnWidth),
      _buildPotentialValueCell(product, columnWidth),
      _buildProfitMarginCell(product, columnWidth),
      _buildStockStatusCell(product, columnWidth),
      _buildProfitabilityCell(product, columnWidth),
    ];
  }

  DataCell _buildIndexCell(int index, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Text(
            '${index + 1}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  DataCell _buildProductNameCell(StockProduct product, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Tooltip(
          message: product.productName,
          child: Text(
            product.productName,
            style: const TextStyle(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ),
    );
  }

  DataCell _buildTextCell(String text, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  DataCell _buildPriceCell(double price, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          price.toStringAsFixed(2),
          style: const TextStyle(fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  DataCell _buildStockCell(StockProduct product, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: product.stockStatusColor.withValues(alpha: 0.1),
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
      ),
    );
  }

  DataCell _buildValueCell(double value, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          value.toStringAsFixed(2),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  DataCell _buildPotentialValueCell(StockProduct product, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          product.potentialValue.toStringAsFixed(2),
          style: TextStyle(
            color: product.potentialValue > product.value ? Colors.blue : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  DataCell _buildProfitMarginCell(StockProduct product, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: product.profitabilityColor.withValues(alpha: 0.1),
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
      ),
    );
  }

  DataCell _buildStockStatusCell(StockProduct product, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: product.stockStatusColor.withValues(alpha: 0.1),
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
      ),
    );
  }

  DataCell _buildProfitabilityCell(StockProduct product, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: product.profitabilityColor.withValues(alpha: 0.1),
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
      ),
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