import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/configs/app_colors.dart';
import '../../../../core/configs/app_sizes.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../responsive.dart';
import '../../data/models/dashboard/dashboard_model.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../widgets/dashboard_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 1;
  // String selectedSalesOverviewType = 'current_day';
  String selectedPurchaseOverviewType = 'current_day';
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Fetch initial dashboard data
    context.read<DashboardBloc>().add(FetchDashboardData(context: context));
  }

  @override
  Widget build(BuildContext context) {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
    final ScrollController scrollController = ScrollController();

    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Container(
          color: AppColors.bg,
          key: drawerKey,
          child: SafeArea(
            child: SizedBox(
              height: AppSizes.height(context) * 0.95,
              child: ResponsiveRow(
                spacing: 0,
                runSpacing: 0,
                children: [
                  if (isBigScreen)
                    ResponsiveCol(
                      xs: 0,
                      sm: 1,
                      md: 1,
                      lg: 2,
                      xl: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: AppColors.border.withAlpha(128), // Fixed: changed withValues to withAlpha
                            width: 0.5,
                          ),
                        ),
                        child: isBigScreen ? const Sidebar() : null,
                      ),
                    ),
                  ResponsiveCol(
                    xs: 12,
                    sm: 12,
                    md: 12,
                    lg: 10,
                    xl: 10,
                    child: SizedBox(
                      height: AppSizes.height(context) * 0.90,
                      child: Scrollbar(
                        controller: scrollController,
                        thickness: 8,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              // ==== HEADER AND FILTER ====
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Dashboard",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: AppSizes.width(context) * 0.25,
                                    child: CupertinoSegmentedControl<String>(
                                      padding: EdgeInsets.zero,
                                      children: {
                                        'current_day': Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                            horizontal: 1.0,
                                          ),
                                          child: Text(
                                            'Today',
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                                              color: selectedPurchaseOverviewType == 'current_day'
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        'this_month': Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 0.0,
                                            horizontal: 1.0,
                                          ),
                                          child: Text(
                                            DateFormat('MMMM').format(DateTime.now()),
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                                              color: selectedPurchaseOverviewType == 'this_month'
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        'lifeTime': Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 0.0,
                                            horizontal: 2.0,
                                          ),
                                          child: Text(
                                            'Life Time',
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                                              color: selectedPurchaseOverviewType == 'lifeTime'
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      },
                                      onValueChanged: (value) {
                                        setState(() {
                                          selectedPurchaseOverviewType = value;
                                          context.read<DashboardBloc>().add(
                                            FetchDashboardData(
                                              dateFilter: value,
                                              context: context,
                                            ),
                                          );
                                        });
                                      },
                                      groupValue: selectedPurchaseOverviewType,
                                      unselectedColor: Colors.white54,
                                      selectedColor: AppColors.primaryColor,
                                      borderColor: AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // ==== LOADING STATE ====
                              if (state is DashboardLoading)
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),

                              // ==== DASHBOARD CARDS ====
                              if (state is DashboardLoaded) ...[
                                _buildDashboardCards(state.dashboardData),
                                const SizedBox(height: 24),

                                // ==== SALES & PURCHASE OVERVIEW ====
                                _buildSalesPurchaseOverview(state.dashboardData),
                                const SizedBox(height: 16),

                                // ==== RECENT ACTIVITIES ====
                                // _buildRecentActivities(state.dashboardData),
                              ],

                              // ==== ERROR STATE ====
                              if (state is DashboardError)
                                Center(
                                  child: Column(
                                    children: [
                                      Text('Error: ${state.message}'),
                                      ElevatedButton(
                                        onPressed: () {
                                          context.read<DashboardBloc>().add(
                                            FetchDashboardData(context: context),
                                          );
                                        },
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardCards(DashboardData data) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        dashboardCardItem(
          title: "Total Sales",
          value: data.todayMetrics?.sales?.total?.toDouble() ?? 0.0, // Fixed: null check and type conversion
          icon: Icons.shopping_cart,
          color: Colors.green,
          isCurrency: true,
        ),
        dashboardCardItem(
          title: "Total Purchases",
          value: data.todayMetrics?.purchases?.total?.toDouble() ?? 0.0, // Fixed: null check and type conversion
          icon: Icons.inventory_2,
          color: Colors.blue,
          isCurrency: true,
        ),
        dashboardCardItem(
          title: "Total Expenses",
          value: data.todayMetrics?.expenses?.total?.toDouble() ?? 0.0, // Fixed: null check and type conversion
          icon: Icons.money_off,
          color: Colors.red,
          isCurrency: true,
        ),
        dashboardCardItem(
          title: "Net Profit",
          value: data.profitLoss?.netProfit?.toDouble() ?? 0.0, // Fixed: null check and type conversion
          icon: Icons.trending_up,
          color: (data.profitLoss?.netProfit ?? 0) >= 0 ? Colors.green : Colors.red, // Fixed: null check
          isCurrency: true,
        ),
        dashboardCardItem(
          title: "Stock Alerts",
          value: ((data.stockAlerts?.lowStock ?? 0) + (data.stockAlerts?.outOfStock ?? 0)).toDouble(), // Fixed: null check
          icon: Icons.warning,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSalesPurchaseOverview(DashboardData data) {
    return Row(
      children: [
        Expanded(child: _buildSalesOverview(data)),
        const SizedBox(width: 16),
        Expanded(child: _buildPurchaseOverview(data)),
      ],
    );
  }

  Widget _buildSalesOverview(DashboardData data) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sales Overview",
                style: TextStyle(
                  fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                  fontWeight: FontWeight.w500,
                  fontSize: Responsive.isMobile(context) ? 14 : 18,
                ),
              ),
              _buildSegmentedControl('sales'),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatsCardMonthly(
                title: "Total Sold Quantity\n",
                count: data.todayMetrics?.sales?.totalQuantity?.toString() ?? "0", // Fixed: null check
                color: Colors.pink,
                icon: "assets/images/sold.png",
              ),
              SizedBox(width: Responsive.isMobile(context) ? 5 : 10),
              StatsCardMonthly(
                title: "Total Amount",
                count: (data.todayMetrics?.sales?.total ?? 0).toStringAsFixed(2), // Fixed: null check
                color: Colors.purple,
                icon: "assets/images/gross.png",
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatsCardMonthly(
                title: "Total Due",
                count: (data.todayMetrics?.sales?.totalDue ?? 0).toStringAsFixed(2), // Fixed: null check
                color: Colors.redAccent,
                icon: "assets/images/cancel.png",
              ),
              SizedBox(width: Responsive.isMobile(context) ? 5 : 20),
              StatsCardMonthly(
                title: "Profit / Loss",
                count: (data.profitLoss?.netProfit ?? 0).toStringAsFixed(2), // Fixed: null check
                color: (data.profitLoss?.netProfit ?? 0) >= 0 ? Colors.green : Colors.red, // Fixed: null check
                icon: "assets/images/expenses.png",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseOverview(DashboardData data) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 3.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Purchase Overview",
                style: TextStyle(
                  fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: Responsive.isMobile(context) ? 12 : 18,
                ),
              ),
              _buildSegmentedControl('purchase'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatsCardMonthly(
                title: "Total Purchase \nQuantity",
                count: data.todayMetrics?.purchases?.totalQuantity?.toString() ?? "0", // Fixed: null check
                color: Colors.blue,
                icon: "assets/images/buy.png",
              ),
              SizedBox(width: Responsive.isMobile(context) ? 5 : 20),
              StatsCardMonthly(
                title: "Total Amount \n",
                count: (data.todayMetrics?.purchases?.total ?? 0).toStringAsFixed(2), // Fixed: null check
                color: Colors.green,
                icon: "assets/images/gross.png",
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatsCardMonthly(
                title: "Total Due",
                count: (data.todayMetrics?.purchases?.totalDue ?? 0).toStringAsFixed(2), // Fixed: null check
                color: Colors.redAccent,
                icon: "assets/images/cancel.png",
              ),
              SizedBox(width: Responsive.isMobile(context) ? 5 : 20),
              StatsCardMonthly(
                title: "Total Returns",
                count: (data.todayMetrics?.purchaseReturns?.totalAmount ?? 0).toStringAsFixed(2), // Fixed: null check
                color: Colors.black,
                icon: "assets/images/product_return.png",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl(String type) {
    return SizedBox(
      width: AppSizes.width(context) * 0.20,
      child: CupertinoSegmentedControl<String>(
        padding: EdgeInsets.zero,
        children: {
          'current_day': Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 1.0),
            child: Text(
              'Today',
              style: TextStyle(
                fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                color: (type == 'sales' ? selectedPurchaseOverviewType : selectedPurchaseOverviewType) == 'current_day'
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          'this_month': Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 1.0),
            child: Text(
              DateFormat('MMMM').format(DateTime.now()),
              style: TextStyle(
                fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                color: (type == 'sales' ? selectedPurchaseOverviewType : selectedPurchaseOverviewType) == 'this_month'
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          'lifeTime': Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 2.0),
            child: Text(
              'Life Time',
              style: TextStyle(
                fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                color: (type == 'sales' ? selectedPurchaseOverviewType : selectedPurchaseOverviewType) == 'lifeTime'
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        },
        onValueChanged: (value) {
          setState(() {
            if (type == 'sales') {
              selectedPurchaseOverviewType = value;
            } else {
              selectedPurchaseOverviewType = value;
            }
            context.read<DashboardBloc>().add(
              FetchDashboardData(dateFilter: value, context: context),
            );
          });
        },
        groupValue: type == 'sales' ? selectedPurchaseOverviewType : selectedPurchaseOverviewType,
        unselectedColor: Colors.white54,
        selectedColor: AppColors.primaryColor,
        borderColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildRecentActivities(DashboardData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Activities",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.playfairDisplay().fontFamily,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRecentSales(data.recentActivities?.sales ?? [])), // Fixed: null check
              const SizedBox(width: 16),
              Expanded(child: _buildRecentPurchases(data.recentActivities?.purchases ?? [])), // Fixed: null check
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSales(List<Purchase> sales) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Sales",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        ...sales.map((sale) => _buildActivityItem(
          icon: Icons.shopping_cart,
          title: sale.invoiceNo ?? 'N/A', // Fixed: null check
          subtitle: sale.customer ?? 'N/A', // Fixed: null check
          amount: sale.amount?.toDouble() ?? 0.0, // Fixed: null check and type conversion
          date: sale.date != null ? DateFormat('MMM dd, yyyy').format(sale.date!) : 'N/A', // Fixed: null check
          color: Colors.green,
        )),
      ],
    );
  }

  Widget _buildRecentPurchases(List<Purchase> purchases) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Purchases",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        ...purchases.map((purchase) => _buildActivityItem(
          icon: Icons.inventory_2,
          title: purchase.invoiceNo ?? 'N/A', // Fixed: null check
          subtitle: purchase.supplier ?? 'N/A', // Fixed: null check
          amount: purchase.amount?.toDouble() ?? 0.0, // Fixed: null check and type conversion
          date: purchase.date != null ? DateFormat('MMM dd, yyyy').format(purchase.date!) : 'N/A', // Fixed: null check
          color: Colors.blue,
        )),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required double amount,
    required String date,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  date,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Text(
            '৳ ${amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class StatsCardMonthly extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final String icon;

  const StatsCardMonthly({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            // BoxShadow(
            //   color: Color.fromARGB(17, 0, 0, 0),
            //   spreadRadius: 5,
            //   blurRadius: 5,
            // ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: Responsive.isMobile(context) ? 14 : 18,
                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color.withAlpha(128), // Fixed: changed withValues to withAlpha
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            icon,
                            color: Colors.white,
                            width: 30,
                          ),
                        ),
                        const SizedBox(width: 3),
                        SizedBox(
                          child: Text(
                            count.toString(),
                            maxLines: 2,
                            style: TextStyle(
                              color: color,
                              fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: -40,
                right: -40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: color.withAlpha(25), // Fixed: changed withValues to withAlpha
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}