import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:meherinMart/feature/feature.dart';

import '../core/configs/configs.dart';
import '../core/shared/widgets/sideMenu/mobile_tab_sidebar.dart';
import 'lab_dashboard/presentation/widgets/stats_card_monthly.dart';
import 'profile/presentation/bloc/profile_bloc/profile_bloc.dart';


class MobileRootScreen extends StatefulWidget {
  const MobileRootScreen({super.key});

  @override
  State<MobileRootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<MobileRootScreen> {
  int selectedIndex = 1;
  String selectedPurchaseOverviewType = 'current_day';

  late ScrollController scrollController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // Initialize scroll controller
    scrollController = ScrollController();

    // Use post frame callback for context-dependent bloc calls
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch print layout and initial dashboard data
      context.read<PrintLayoutBloc>().add(FetchPrintLayout());
      context.read<ProfileBloc>().add(FetchProfilePermission(context: context));

      context.read<DashboardBloc>().add(FetchDashboardData(context: context));
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget _buildFilterSegmentedControl() {

    return SizedBox(
      width:  double.infinity ,
      child: CupertinoSegmentedControl<String>(
        padding: EdgeInsets.zero,
        children: {
          'current_day': Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 4.0,
            ),
            child: Text(
              'Today',
              style: TextStyle(
                fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                fontSize: 12,
                color: selectedPurchaseOverviewType == 'current_day'
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          'this_month': Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 4.0,
            ),
            child: Text(
              DateFormat('MMMM').format(DateTime.now()),
              style: TextStyle(
                fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                fontSize: 12,
                color: selectedPurchaseOverviewType == 'this_month'
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          'lifeTime': Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 4.0,
            ),
            child: Text(
              'Life Time',
              style: TextStyle(
                fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                fontSize: 12,
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
        borderColor: AppColors.primaryColor(context),
      ),
    );
  }

  Widget dashboardCardItem({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
    bool isCurrency = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.cardLevelHead(context)),
                const SizedBox(height: 4),
                Text(
                  isCurrency ? value.toStringAsFixed(2) : value.toString(),
                  style: AppTextStyle.cardLevelText(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCards(DashboardData data) {
    final isMobile = Responsive.isMobile(context);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 5,
      childAspectRatio: isMobile ? 2.2 : 1.5,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      children: [
        dashboardCardItem(
          title: "Total Sales",
          value: data.todayMetrics?.sales?.total?.toDouble() ?? 0.0,
          icon: Icons.shopping_cart,
          color: Colors.green,
          isCurrency: true,
        ),
        dashboardCardItem(
          title: "Total Purchases",
          value: data.todayMetrics?.purchases?.total?.toDouble() ?? 0.0,
          icon: Icons.inventory_2,
          color: Colors.blue,
          isCurrency: true,
        ),
        dashboardCardItem(
          title: "Total Expenses",
          value: data.todayMetrics?.expenses?.total?.toDouble() ?? 0.0,
          icon: Icons.money_off,
          color: Colors.red,
          isCurrency: true,
        ),
        dashboardCardItem(
          title: "Net Profit",
          value: data.profitLoss?.netProfit?.toDouble() ?? 0.0,
          icon: Icons.trending_up,
          color: (data.profitLoss?.netProfit ?? 0) >= 0 ? Colors.green : Colors.red,
          isCurrency: true,
        ),
        // dashboardCardItem(
        //   title: "Stock Alerts",
        //   value: ((data.stockAlerts?.lowStock ?? 0) + (data.stockAlerts?.outOfStock ?? 0)).toDouble(),
        //   icon: Icons.warning,
        //   color: Colors.orange,
        // ),
      ],
    );
  }

  Widget _buildSalesPurchaseOverview(DashboardData data) {
      return Column(
        children: [
          _buildSalesOverview(data),
          const SizedBox(height: 16),
          _buildPurchaseOverview(data),
        ],
      );

  }

  Widget _buildSalesOverview(DashboardData data) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
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
                  fontSize: isMobile ? 14 : 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatsCardMonthly(
                      title: "Total Sold Quantity",
                      count: data.todayMetrics?.sales?.totalQuantity?.toString() ?? "0",
                      color: Colors.pink,
                      icon: "assets/images/sold.png",
                    ),
                  ),
                  SizedBox(width: isMobile ? 5 : 10),
                  Expanded(
                    child: StatsCardMonthly(
                      title: "Total Amount",
                      count: (data.todayMetrics?.sales?.total ?? 0).toStringAsFixed(2),
                      color: Colors.purple,
                      icon: "assets/images/gross.png",
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Row(
                children: [
                  Expanded(
                    child: StatsCardMonthly(
                      title: "Total Due",
                      count: (data.todayMetrics?.sales?.totalDue ?? 0).toStringAsFixed(2),
                      color: Colors.redAccent,
                      icon: "assets/images/cancel.png",
                    ),
                  ),
                  SizedBox(width: isMobile ? 5 : 10),
                  Expanded(
                    child: StatsCardMonthly(
                      title: "Profit / Loss",
                      count: (data.profitLoss?.netProfit ?? 0).toStringAsFixed(2),
                      color: (data.profitLoss?.netProfit ?? 0) >= 0 ? Colors.green : Colors.red,
                      icon: "assets/images/expenses.png",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseOverview(DashboardData data) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
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
                  fontSize: isMobile ? 14 : 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatsCardMonthly(
                      title: "Total Purchase\nQuantity",
                      count: data.todayMetrics?.purchases?.totalQuantity?.toString() ?? "0",
                      color: Colors.blue,
                      icon: "assets/images/buy.png",
                    ),
                  ),
                  SizedBox(width: isMobile ? 5 : 10),
                  Expanded(
                    child: StatsCardMonthly(
                      title: "Total Amount",
                      count: (data.todayMetrics?.purchases?.total ?? 0).toStringAsFixed(2),
                      color: Colors.green,
                      icon: "assets/images/gross.png",
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Row(
                children: [
                  Expanded(
                    child: StatsCardMonthly(
                      title: "Total Due",
                      count: (data.todayMetrics?.purchases?.totalDue ?? 0).toStringAsFixed(2),
                      color: Colors.redAccent,
                      icon: "assets/images/cancel.png",
                    ),
                  ),
                  SizedBox(width: isMobile ? 5 : 10),
                  Expanded(
                    child: StatsCardMonthly(
                      title: "Total Returns",
                      count: (data.todayMetrics?.purchaseReturns?.totalAmount ?? 0).toStringAsFixed(2),
                      color: Colors.black,
                      icon: "assets/images/product_return.png",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scaffoldKey: _scaffoldKey,

      // Mobile/tablet drawer
      drawer: const Drawer(child: MobileTabSidebar()),

      // AppBar only for smaller screens
      appBar: AppBar(
        backgroundColor: AppColors.bottomNavBg(context),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Try opening drawer using the scaffold key
            if (_scaffoldKey.currentState != null) {
              _scaffoldKey.currentState!.openDrawer();
            } else {
              // Fallback: try using context
              Scaffold.of(context).openDrawer();
            }
          },
        ),
        title: Row(
          children: [
            // App title
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.isMobile(context) ? 8.0 : 16.0,
                ),
                child: Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            gapW8,


          ],
        ),
      ),

      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          // Prevent default back behavior / handle back if necessary.
          if (didPop) return;
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {


            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(FetchDashboardData(context: context));

              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.bodyPadding * (Responsive.isMobile(context) ? 0.5 : 1.5),
                ),
                child: BlocConsumer<DashboardBloc, DashboardState>(
                  listener: (context, state) {
                    if (state is DashboardError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    return SafeArea(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: EdgeInsets.all(Responsive.isMobile(context) ? 8.0 : 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ==== HEADER AND FILTER ====
                            const Text(
                              "Dashboard",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildFilterSegmentedControl(),

                            // ==== LOADING STATE ====
                            if (state is DashboardLoading)
                              const Center(
                                child: CircularProgressIndicator(),
                              ),

                            // ==== DASHBOARD CARDS ====
                            if (state is DashboardLoaded) ...[
                              _buildDashboardCards(state.dashboardData),
                              const SizedBox(height: 12),

                              // ==== SALES & PURCHASE OVERVIEW ====
                              _buildSalesPurchaseOverview(state.dashboardData),

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
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),

    );
  }

}


