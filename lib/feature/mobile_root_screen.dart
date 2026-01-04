import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meherinMart/feature/feature.dart';
import 'package:meherinMart/feature/splash/presentation/bloc/connectivity_bloc/connectivity_state.dart';

import '../core/configs/configs.dart';
import '../core/shared/widgets/sideMenu/mobile_tab_sidebar.dart';
import 'lab_dashboard/presentation/widgets/stats_card_monthly.dart';

final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

class MobileRootScreen extends StatefulWidget {
  const MobileRootScreen({super.key});

  @override
  State<MobileRootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<MobileRootScreen> {
  int selectedIndex = 1;
  String selectedPurchaseOverviewType = 'current_day';

  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    // Initialize scroll controller
    scrollController = ScrollController();

    // Use post frame callback for context-dependent bloc calls
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch print layout and initial dashboard data
      context.read<PrintLayoutBloc>().add(FetchPrintLayout());
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
        selectedColor: AppColors.primaryColor,
        borderColor: AppColors.primaryColor,
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
        dashboardCardItem(
          title: "Stock Alerts",
          value: ((data.stockAlerts?.lowStock ?? 0) + (data.stockAlerts?.outOfStock ?? 0)).toDouble(),
          icon: Icons.warning,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSalesPurchaseOverview(DashboardData data) {
    if (Responsive.isMobile(context)) {
      return Column(
        children: [
          _buildSalesOverview(data),
          const SizedBox(height: 16),
          _buildPurchaseOverview(data),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _buildSalesOverview(data)),
          const SizedBox(width: 16),
          Expanded(child: _buildPurchaseOverview(data)),
        ],
      );
    }
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
    return SafeArea(
      child: Scaffold(
        key: _drawerKey,

        // Mobile/tablet drawer
        drawer: const Drawer(child: MobileTabSidebar()),

        // AppBar only for smaller screens
        appBar: _buildAppBar(context),

        body: PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            // Prevent default back behavior / handle back if necessary.
            if (didPop) return;
          },
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              int currentIndex = 0;
              if (state is DashboardScreenChanged) {
                currentIndex = state.index;
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(
                    ChangeDashboardScreen(index: currentIndex),
                  );
                },
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
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
                          return Container(
                            color: AppColors.bg,
                            child: SafeArea(
                              child: SizedBox(
                                height: AppSizes.height(context) * 0.95,
                                child: ResponsiveRow(
                                  spacing: 0,
                                  runSpacing: 0,
                                  children: [
                                    ResponsiveCol(
                                      xs: 12,
                                      sm: 12,
                                      md: 12,
                                      lg: 12,
                                      xl: 12,
                                      child: SizedBox(
                                        height: AppSizes.height(context) * 0.90,
                                        child: Scrollbar(
                                          controller: scrollController,
                                          thickness: 8,
                                          thumbVisibility: true,
                                          child: SingleChildScrollView(
                                            controller: scrollController,
                                            padding: EdgeInsets.all(Responsive.isMobile(context) ? 8.0 : 12.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // ==== HEADER AND FILTER ====
                                               Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Dashboard",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    _buildFilterSegmentedControl(),
                                                  ],
                                                )
                                                   ,
                                                const SizedBox(height: 16),

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
                                                  const SizedBox(height: 100),

                                                  // ==== RECENT ACTIVITIES ====
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
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // FAB not needed on desktop since sidebar is permanent.
        floatingActionButton: null,
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgSecondaryLight,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => _drawerKey.currentState?.openDrawer(),
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
                  color: AppColors.primaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          gapW8,


        ],
      ),
    );
  }
}

Color getConnectivityColor(ConnectivityState state) {
  if (state is ConnectivityOnline) return Colors.green;
  if (state is ConnectivityOffline) return Colors.red;
  if (state is ConnectivityConnecting) return Colors.orange;
  return Colors.grey;
}

