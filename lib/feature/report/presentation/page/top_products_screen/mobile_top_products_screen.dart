import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:printing/printing.dart';
import '../../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '/core/core.dart';
import '/core/widgets/date_range.dart';
import '/feature/report/presentation/bloc/top_products_bloc/top_products_bloc.dart';
import '/feature/report/presentation/page/top_products_screen/pdf.dart';

import '../../../data/model/top_products_model.dart';

class MobileTopProductsScreen extends StatefulWidget {
  const MobileTopProductsScreen({super.key});

  @override
  State<MobileTopProductsScreen> createState() =>
      _MobileTopProductsScreenState();
}

class _MobileTopProductsScreenState extends State<MobileTopProductsScreen> {
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
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Top Products Report',
          style: AppTextStyle.titleMedium(context),
        ),
        actions: [
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedPdf02, color: AppColors.text(context)),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedReload, color: AppColors.text(context)),
            onPressed: () {
              _fetchTopProductsReport();
              setState(() {

                selectedDateRange=null;
              });
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchTopProductsReport(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter Section
              CustomDateRangeField(
                isLabel: true,
                selectedDateRange: selectedDateRange,
                onDateRangeSelected: (value) {
                  setState(() => selectedDateRange = value);
                  if (value != null) {
                    _fetchTopProductsReport(from: value.start, to: value.end);
                  }
                },
              ),
              const SizedBox(height: 8),

              // Summary Cards
              _buildSummaryCards(),

              const SizedBox(height: 0),

              // Top Products List
              BlocBuilder<TopProductsBloc, TopProductsState>(
                builder: (context, state) {
                  if (state is TopProductsLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text("Loading top products..."),
                        ],
                      ),
                    );
                  } else if (state is TopProductsSuccess) {
                    if (state.response.report.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildMobileProductsList(state.response.report);
                  } else if (state is TopProductsFailed) {
                    return _buildErrorState(state.content);
                  }
                  return _buildEmptyState();
                },
              ),
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

        return Column(
          children: [
            // First row: Products and Quantity
            Row(
              children: [
                _buildMobileSummaryCard(
                  "Products",
                  summary.totalProducts.toString(),
                  Icons.inventory_2,
                  AppColors.primaryColor(context),
                  isMobile: true,
                ),
                const SizedBox(width: 8),
                _buildMobileSummaryCard(
                  "Quantity Sold",
                  summary.totalQuantitySold.toString(),
                  Icons.shopping_cart_checkout,
                  Colors.green,
                  isMobile: true,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Second row: Sales and Average
            Row(
              children: [
                _buildMobileSummaryCard(
                  "Total Sales",
                  summary.totalSales.toStringAsFixed(2),
                  Icons.attach_money,
                  Colors.blue,
                  isMobile: true,
                ),
                const SizedBox(width: 8),
                _buildMobileSummaryCard(
                  "Avg/Product",
                  (summary.totalSales / summary.totalProducts).toStringAsFixed(2),
                  Icons.analytics,
                  Colors.orange,
                  isMobile: true,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isMobile = false,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bottomNavBg(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.greyColor(context).withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: isMobile ? 24 : 28),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      color: AppColors.text(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text(context),
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

  Widget _buildMobileProductsList(List<TopProductModel> products) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final rank = index + 1;
        final totalRevenue = products.fold(
          0.0,
          (sum, p) => sum + p.totalSoldPrice,
        );
        final percentage = (product.totalSoldPrice / totalRevenue * 100);

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bottomNavBg(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.greyColor(context).withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Rank Badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getRankColor(rank).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: _getRankColor(rank), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        rank.toString(),
                        style: TextStyle(
                          color: _getRankColor(rank),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  // Performance Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getPerformanceColor(
                        percentage,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getPerformanceColor(percentage),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _showMobileProductDetails(context, product),
                    child: const Icon(Icons.remove_red_eye, size: 16),

                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Product Name
              Text(
                product.productName,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.text(context),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Product Details Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMobileDetailItem(
                    'Price',
                    product.sellingPrice.toStringAsFixed(2),
                    Colors.blue,
                  ),
                  _buildMobileDetailItem(
                    'Sold',
                    product.totalSoldQuantity.toString(),
                    Colors.green,
                  ),
                  _buildMobileDetailItem(
                    'Revenue',
                    product.totalSoldPrice.toStringAsFixed(2),
                    Colors.purple,
                  ),
                ],
              ),

              // Performance Bar
              const SizedBox(height: 4),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getPerformanceColor(percentage),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),


            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileDetailItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showMobileProductDetails(
    BuildContext context,
    TopProductModel product,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final totalRevenue = product.totalSoldPrice;
        final avgSale = totalRevenue / product.totalSoldQuantity;

        return SafeArea(
          child: Container(
            decoration:  BoxDecoration(
              color: AppColors.bottomNavBg(context),

              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.productName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 4),

                // Product Details
                _buildMobileDetailRow(
                  'Selling Price:',
                  product.sellingPrice.toStringAsFixed(2),context
                ),
                _buildMobileDetailRow(
                  'Quantity Sold:',
                  product.totalSoldQuantity.toString(),context
                ),
                _buildMobileDetailRow(
                  'Total Revenue:',
                  totalRevenue.toStringAsFixed(2),context
                ),
                _buildMobileDetailRow(
                  'Average per Sale:',
                  avgSale.toStringAsFixed(2),context
                ),

                // Performance Metrics
                const SizedBox(height: 12),
                 Text(
                  'Performance Metrics',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: AppColors.text(context),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.trending_up, color: Colors.blue),
                            const SizedBox(height: 8),
                             Text(
                              'Top Seller',
                              style: TextStyle(fontSize: 12,                             color: AppColors.text(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Text(
                            //   '#${product.indexOf(product) + 1}',
                            //   style: const TextStyle(
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.bold,
                            //     color: Colors.blue,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.attach_money, color: Colors.green),
                            const SizedBox(height: 8),
                            Text(
                              'Revenue Rank',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.text(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Text(
                            //   '#${_getRevenueRank(product, products)}',
                            //   style: const TextStyle(
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.bold,
                            //     color: Colors.green,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
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

  Widget _buildMobileDetailRow(String label, String value,BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style:  TextStyle(
                fontSize: 14,
                color: AppColors.text(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style:  TextStyle(fontSize: 14,
                  color: AppColors.text(context),

                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
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
          Text(
            "No Top Products Data Found",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Top performing products will appear here",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchTopProductsReport,
            child: const Text("Refresh Data"),
          ),
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
          Text(
            "Error Loading Top Products",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(fontSize: 14, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchTopProductsReport,
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  void _generatePdf() {
    final state = context.read<TopProductsBloc>().state;
    if (state is TopProductsSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Top Products PDF'),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            body: PdfPreview(
              build: (format) => generateTopProductsReportPdf(state.response, context.read<ProfileBloc>().permissionModel?.data?.companyInfo),
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No top products data available'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _getPerformanceColor(double percentage) {
    if (percentage > 50) return Colors.green;
    if (percentage > 25) return Colors.orange;
    return Colors.red;
  }
}
