import 'package:meherinMart/desktop/widgets/sidebar.dart';
// lib/feature/report/presentation/screens/top_products_screen.dart
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import '../../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '/core/core.dart';
import '/core/widgets/date_range.dart';
import '/feature/report/presentation/bloc/top_products_bloc/top_products_bloc.dart';
import '/feature/report/presentation/shared/top_products_screen/pdf.dart';

import '../../../data/model/top_products_model.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

class TopProductsScreen extends StatefulWidget {
  const TopProductsScreen({super.key});

  @override
  State<TopProductsScreen> createState() => _TopProductsScreenState();
}

class _TopProductsScreenState extends State<TopProductsScreen> {
  DateRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    _fetchTopProductsReport();
  }

  void _fetchTopProductsReport({DateTime? from, DateTime? to}) {
    context.read<TopProductsBloc>().add(
      FetchTopProductsReport(context: context, from: from, to: to),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

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
        onRefresh: () async => _fetchTopProductsReport(),
        child: Container(
          padding: AppTextStyle.getResponsivePaddingBody(context),
          child: Column(
            children: [

              _buildSummaryCards(),
              const SizedBox(height: 6),
              SizedBox(child: _buildTopProductsTable()),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildSummaryCards() {
    return BlocBuilder<TopProductsBloc, TopProductsState>(
      builder: (context, state) {
        if (state is! TopProductsSuccess) return const SizedBox();

        final summary = state.response.summary;

        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildSummaryCard(
              "Total Products",
              summary.totalProducts.toString(),
              Icons.inventory_2,
              AppColors.primaryColor(context),
            ),
            _buildSummaryCard(
              "Total Quantity Sold",
              summary.totalQuantitySold.toString(),
              Icons.shopping_cart_checkout,
              AppColors.success,
            ),
            _buildSummaryCard(
              "Total Sales",
              "\$${summary.totalSales.toStringAsFixed(2)}",
              Icons.attach_money,
              AppColors.info,
            ),
            _buildSummaryCard(
              "Average per Product",
              "\$${(summary.totalSales / summary.totalProducts).toStringAsFixed(2)}",
              Icons.analytics,
              AppColors.warning,
            ),

            SizedBox(
              width: 245,
              child: CustomDateRangeField(
                isLabel: false,
                selectedDateRange: selectedDateRange,
                onDateRangeSelected: (value) {
                  setState(() => selectedDateRange = value);
                  if (value != null) {
                    _fetchTopProductsReport(from: value.start, to: value.end);
                  }
                },
              ),
            ),
            AppButton(
                size: 80,
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
                      build: (format) => generateTopProductsReportPdf(
                        state.response, context.read<ProfileBloc>().permissionModel?.data?.companyInfo

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
            AppButton(
              name: "Clear",size: 80,
              onPressed: () {
                setState(() => selectedDateRange = null);
                context.read<TopProductsBloc>().add(ClearTopProductsFilters());
                _fetchTopProductsReport();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
            color: AppColors.greyColor(context).withValues(alpha: 0.5),width: 0.5
        ),
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(8),

      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(width: 6),
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

  Widget _buildTopProductsTable() {
    return BlocBuilder<TopProductsBloc, TopProductsState>(
      builder: (context, state) {
        if (state is TopProductsLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading top products report..."),
              ],
            ),
          );
        } else if (state is TopProductsSuccess) {
          if (state.response.report.isEmpty) {
            return _buildEmptyState();
          }
          return TopProductsTableCard(products: state.response.report);
        } else if (state is TopProductsFailed) {
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
            "No Top Products Data Found",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Top products data will appear here when available",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchTopProductsReport,
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
            "Error Loading Top Products Report",
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
            onPressed: _fetchTopProductsReport,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

class TopProductsTableCard extends StatelessWidget {
  final List<TopProductModel> products;
  final VoidCallback? onProductTap;

  const TopProductsTableCard({
    super.key,
    required this.products,
    this.onProductTap,
  });

  @override
  // Desktop টেবিল — AppDataTable
  // Share column এ ছোট progress bar — কোন product মোট বিক্রির কত অংশ,
  // এক নজরে বোঝা যায়
  Widget build(BuildContext context) {
    final double totalRevenue =
        products.fold(0.0, (sum, p) => sum + p.totalSoldPrice);

    const columns = [
      AppTableColumn.center('Rank', flex: 1, minWidth: 64),
      AppTableColumn('Product', flex: 4, minWidth: 180),
      AppTableColumn.numeric('Price', flex: 2, minWidth: 100),
      AppTableColumn.numeric('Sold Qty', flex: 1, minWidth: 90),
      AppTableColumn.numeric('Revenue', flex: 2, minWidth: 120),
      AppTableColumn('Share', flex: 3, minWidth: 150),
      AppTableColumn.center('Actions', flex: 2, minWidth: 96),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: products.length,
      onRowTap: onProductTap == null ? null : (_) => onProductTap!(),
      cellBuilder: (context, row, col) {
        final p = products[row];
        switch (col) {
          case 0:
            final rank = row + 1;
            final medal = switch (rank) {
              1 => const Color(0xFFF59E0B),
              2 => const Color(0xFF94A3B8),
              3 => const Color(0xFFB45309),
              _ => null,
            };
            return medal == null
                ? AppTableText('#$rank',
                    align: AppCellAlign.center, muted: true)
                : CircleAvatar(
                    radius: 12,
                    backgroundColor: medal.withValues(alpha: 0.15),
                    child: Text('$rank',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: medal)),
                  );
          case 1:
            return AppTableText(p.productName, bold: true);
          case 2:
            return AppTableMoney(p.sellingPrice);
          case 3:
            return AppTableText('${p.totalSoldQuantity}',
                align: AppCellAlign.end, bold: true);
          case 4:
            return AppTableMoney(p.totalSoldPrice,
                bold: true, color: AppColors.success);
          case 5:
            final share = totalRevenue <= 0
                ? 0.0
                : (p.totalSoldPrice / totalRevenue).clamp(0.0, 1.0);
            return Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: share,
                      minHeight: 6,
                      backgroundColor: AppColors.primaryColor(context)
                          .withValues(alpha: 0.10),
                      color: AppColors.primaryColor(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${(share * 100).toStringAsFixed(1)}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.text(context)),
                  ),
                ),
              ],
            );
          default:
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTableAction(
                  icon: Icons.visibility_outlined,
                  tooltip: 'Details',
                  color: AppColors.info,
                  onPressed: () => _showProductDetails(context, p),
                ),
                AppTableAction(
                  icon: Icons.insights_outlined,
                  tooltip: 'Sales analytics',
                  color: AppColors.success,
                  onPressed: () => _showSalesAnalytics(context, p),
                ),
              ],
            );
        }
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
    );
  }

  void _showProductDetails(BuildContext context, TopProductModel product) {
    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverShell(
          child: Container(
            width: AppSizes.width(context) * 0.40,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Performance - ${product.productName}',
                  style: AppTextStyle.cardLevelHead(context),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Product Name:', product.productName),
                _buildDetailRow(
                  'Selling Price:',
                  product.sellingPrice.toStringAsFixed(2),
                ),
                _buildDetailRow(
                  'Quantity Sold:',
                  product.totalSoldQuantity.toString(),
                ),
                _buildDetailRow(
                  'Total Revenue:',
                  product.totalSoldPrice.toStringAsFixed(2),
                ),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSalesAnalytics(BuildContext context, TopProductModel product) {
    // Implement sales analytics view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening sales analytics for ${product.productName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
