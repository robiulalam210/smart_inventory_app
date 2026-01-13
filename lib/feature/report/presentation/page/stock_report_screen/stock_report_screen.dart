// lib/feature/report/presentation/screens/stock_report_screen.dart
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import '/core/core.dart';
import '/core/widgets/date_range.dart';
import '/feature/report/presentation/bloc/stock_report_bloc/stock_report_bloc.dart';
import '/feature/report/presentation/page/stock_report_screen/pdf.dart';

import '../../../data/model/stock_report_model.dart';

class StockReportScreen extends StatefulWidget {
  const StockReportScreen({super.key});

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  DateRange? selectedDateRange;
  String _sortBy = 'value';
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
      color: AppColors.bottomNavBg(context),
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
              _buildSummaryCards(),
              const SizedBox(height: 8),
              SizedBox(child: _buildStockTable()),
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
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSummaryCard(
              "Total Products",
              summary.totalProducts.toString(),
              Icons.inventory_2,
              AppColors.primaryColor(context),
            ),
            _buildSummaryCard(
              "Total Stock ",
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
              "Avg Stock ",
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

            // Date Range Picker
            SizedBox(
              width: 270,
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
                            _handleSort(newValue, _sortAscending);
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
                          _handleSort(_sortBy, !_sortAscending);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            // Clear Filters Button
            AppButton(
              size: 100,
              name: "Clear",
              onPressed: () {
                setState(() => selectedDateRange = null);
                context.read<StockReportBloc>().add(ClearStockReportFilters());
                _fetchStockReport();
              },
            ),
            gapW16,
            AppButton(
                size: 100,
                color: AppColors.primaryColor(context),
                name: "Pdf", onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    backgroundColor: Colors.red,
                    body: PdfPreview.builder(
                      useActions: true,
                      allowSharing: false,
                      canDebug: false,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      dynamicLayout: true,
                      build: (format) => generateStockReportPdf(
                        state.response,

                      ),
                      pdfPreviewPageDecoration:
                      BoxDecoration(color: AppColors.white),
                      actionBarTheme: PdfActionBarTheme(
                        backgroundColor: AppColors.primaryColor(context),
                        iconColor: Colors.white,
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () => AppRoutes.pop(context),
                          icon: const Icon(Icons.cancel, color: Colors.red),
                        ),
                      ],
                      pagesBuilder: (context, pages) {
                        debugPrint('Rendering ${pages.length} pages');
                        return PageView.builder(
                          itemCount: pages.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            final page = pages[index];
                            return Container(
                              color: Colors.grey,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8.0),
                              child: Image(image: page.image, fit: BoxFit.contain),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              );

            }),

          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style:  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:AppColors.blackColor(context),
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
            return _buildEmptyState();
          }
          final sortedProducts = _getSortedProducts(state.response.report);
          return StockReportTableCard(
            products: sortedProducts,
            sortBy: _sortBy,
            sortAscending: _sortAscending,
            onSort: _handleSort,
          );
        } else if (state is StockReportFailed) {
          return _buildErrorState(state.content);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AppImages.noData, width: 200, height: 200),
          const SizedBox(height: 16),
          Text(
            "No Stock Data Found",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Stock data will appear here when available",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchStockReport,
            child: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            "Error Loading Stock Report",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(fontSize: 14, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchStockReport,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

class StockReportTableCard extends StatelessWidget {
  final List<StockProduct> products;
  final String sortBy;
  final bool sortAscending;
  final Function(String, bool) onSort;

  const StockReportTableCard({
    super.key,
    required this.products,
    required this.sortBy,
    required this.sortAscending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 12; // SL, Product Name, Category, Brand, Avg Cost, Selling Price, Current Stock, Stock Value, Potential Value, Profit Margin, Stock Status, Profitability
        const minColumnWidth = 100.0;

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Scrollbar(
            controller: verticalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: verticalScrollController,
              scrollDirection: Axis.vertical,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Scrollbar(
                  controller: horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: totalWidth),
                        child: DataTable(
                          dataRowMinHeight: 40,
                          dataRowMaxHeight: 40,
                          columnSpacing: 8,
                          horizontalMargin: 12,
                          dividerThickness: 0.5,
                          headingRowHeight: 40,
                          headingTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          headingRowColor: WidgetStateProperty.all(
                            AppColors.primaryColor(context),
                          ),
                          dataTextStyle: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          sortColumnIndex: _getSortColumnIndex(sortBy),
                          sortAscending: sortAscending,
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: products.asMap().entries.map((entry) {
                            final product = entry.value;
                            return DataRow(
                              cells: [
                                _buildIndexCell(entry.key + 1, dynamicColumnWidth * 0.6),
                                _buildProductNameCell(product, dynamicColumnWidth * 1.5),
                                _buildCategoryCell(product.category, dynamicColumnWidth),
                                _buildBrandCell(product.brand, dynamicColumnWidth * 1.2),
                                _buildPriceCell(product.avgPurchasePrice, dynamicColumnWidth, isCost: true),
                                _buildPriceCell(product.sellingPrice, dynamicColumnWidth, isSelling: true),
                                _buildStockCell(product, dynamicColumnWidth),
                                _buildValueCell(product.value, dynamicColumnWidth),
                                _buildPotentialValueCell(product, dynamicColumnWidth),
                                _buildProfitMarginCell(product, dynamicColumnWidth),
                                _buildStockStatusCell(product, dynamicColumnWidth),
                                _buildProfitabilityCell(product, dynamicColumnWidth),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildColumns(double columnWidth) {
    return [
      DataColumn(
        label: SizedBox(
          width: columnWidth * 0.6,
          child: const Text('SL', textAlign: TextAlign.center),
        ),
      ),
      _buildSortableColumn('Product Name', 'name', columnWidth * 1.5),
      _buildSortableColumn('Category', 'category', columnWidth),
      DataColumn(
        label: SizedBox(
          width: columnWidth * 1.2,
          child: const Text('Brand', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Avg Cost', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Selling Price', textAlign: TextAlign.center),
        ),
      ),
      _buildSortableColumn('Current Stock', 'stock', columnWidth),
      _buildSortableColumn('Stock Value', 'value', columnWidth),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Potential Value', textAlign: TextAlign.center),
        ),
      ),
      _buildSortableColumn('Profit Margin', 'profit_margin', columnWidth),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Stock Status', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Profitability', textAlign: TextAlign.center),
        ),
      ),
    ];
  }

  DataColumn _buildSortableColumn(String label, String columnId, double width) {
    return DataColumn(
      label: SizedBox(
        width: width,
        child: Text(
          label,
          textAlign: TextAlign.center,
        ),
      ),
      onSort: (columnIndex, ascending) {
        onSort(columnId, ascending);
      },
    );
  }

  DataCell _buildIndexCell(int index, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Text(
            index.toString(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
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
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ),
    );
  }

  DataCell _buildCategoryCell(String category, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          category,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  DataCell _buildBrandCell(String brand, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          brand,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  DataCell _buildPriceCell(double price, double width, {bool isCost = false, bool isSelling = false}) {
    Color getPriceColor() {
      if (isCost) return Colors.orange;
      if (isSelling) return Colors.blue;
      return Colors.grey;
    }

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: getPriceColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              price.toStringAsFixed(2),
              style: TextStyle(
                color: getPriceColor(),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
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
                color: product.stockStatusColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
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
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '\$${value.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildPotentialValueCell(StockProduct product, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Text(
            '\$${product.potentialValue.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: product.potentialValue > product.value ? Colors.blue : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: product.profitabilityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${product.profitMargin.toStringAsFixed(1)}%',
              style: TextStyle(
                color: product.profitabilityColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: product.stockStatusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              product.stockStatus,
              style: TextStyle(
                color: product.stockStatusColor,
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: product.profitabilityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              product.profitability,
              style: TextStyle(
                color: product.profitabilityColor,
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
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
      default: return 7;
    }
  }
}