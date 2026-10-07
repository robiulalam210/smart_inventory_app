import 'package:meherinMart/desktop/widgets/sidebar.dart';
// lib/feature/report/presentation/screens/stock_report_screen.dart
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import '../../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '/core/core.dart';
import '/core/widgets/date_range.dart';
import '/feature/report/presentation/bloc/stock_report_bloc/stock_report_bloc.dart';
import '/feature/report/presentation/shared/stock_report_screen/pdf.dart';

import '../../../data/model/stock_report_model.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

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
              summary.totalStockValue.toStringAsFixed(2),
              Icons.attach_money,
              AppColors.success,
            ),
            _buildSummaryCard(
              "Total Quantity",
              summary.totalStockQuantity.toString(),
              Icons.shopping_cart,
              AppColors.info,
            ),
            _buildSummaryCard(
              "Avg Stock ",
              summary.averageStockValue.toStringAsFixed(2),
              Icons.analytics,
              AppColors.warning,
            ),
            _buildSummaryCard(
              "Out of Stock",
              outOfStockCount.toString(),
              Icons.error_outline,
              AppColors.danger,
            ),
            _buildSummaryCard(
              "Low Stock",
              lowStockCount.toString(),
              Icons.warning,
              AppColors.warning,
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
                    backgroundColor: AppColors.danger,
                    body: PdfPreview.builder(
                      useActions: true,
                      allowSharing: false,
                      canDebug: false,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      dynamicLayout: true,
                      build: (format) => generateStockReportPdf(
                        state.response,context.read<ProfileBloc>().permissionModel?.data?.companyInfo

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
                          icon: const Icon(Icons.cancel, color: AppColors.danger),
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
                    color:AppColors.text(context),
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
          const Icon(Icons.error_outline, size: 60, color: AppColors.danger),
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
            style: const TextStyle(fontSize: 14, color: AppColors.danger),
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
  // Desktop টেবিল — AppDataTable (header ক্লিক করে sort করা যায়)
  Widget build(BuildContext context) {
    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 52),
      AppTableColumn('Product', flex: 4, minWidth: 170, sortKey: 'name'),
      AppTableColumn('Category', flex: 2, minWidth: 110, sortKey: 'category'),
      AppTableColumn.numeric('Avg Cost', flex: 2, minWidth: 100),
      AppTableColumn.numeric('Sell Price', flex: 2, minWidth: 100),
      AppTableColumn.numeric('Stock', flex: 1, minWidth: 84, sortKey: 'stock'),
      AppTableColumn.numeric('Stock Value', flex: 2, minWidth: 120, sortKey: 'value'),
      AppTableColumn.numeric('Potential', flex: 2, minWidth: 110),
      AppTableColumn.numeric('Margin', flex: 1, minWidth: 90, sortKey: 'profit_margin'),
      AppTableColumn.center('Status', flex: 2, minWidth: 110),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: products.length,
      sortKey: sortBy,
      sortAscending: sortAscending,
      onSort: onSort,
      cellBuilder: (context, row, col) {
        final p = products[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(p.productName, bold: true, subtitle: p.brand);
          case 2:
            return AppTableText(p.category, muted: true);
          case 3:
            return AppTableMoney(p.avgPurchasePrice);
          case 4:
            return AppTableMoney(p.sellingPrice);
          case 5:
            return AppTableText('${p.currentStock}',
                align: AppCellAlign.end,
                bold: true,
                color: p.stockStatusColor);
          case 6:
            return AppTableMoney(p.value, bold: true);
          case 7:
            return AppTableMoney(p.potentialValue,
                color: p.potentialValue > p.value ? AppColors.info : null);
          case 8:
            return AppTableText('${p.profitMargin.toStringAsFixed(1)}%',
                align: AppCellAlign.end,
                bold: true,
                color: p.profitabilityColor);
          default:
            return AppStatusPill(p.stockStatus, color: p.stockStatusColor);
        }
      },
    );
  }
}
