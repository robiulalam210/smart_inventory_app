import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meherinMart/root.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/utilities/amount_counter.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/shared/widgets/sideMenu/mobile_tab_sidebar.dart';

import '../../../mobile_root.dart';
import '../../../profile/presentation/pages/moble_profile_screen.dart';
import '../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '../../../feature.dart';

import '../widgets/stats_card_monthly.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  String selectedPurchaseOverviewType = 'current_day';

  late ScrollController scrollController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  // ================= HEADER =================
  Widget _buildHeader() {
    final companyInfo = context.read<ProfileBloc>().permissionModel?.data?.companyInfo;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor(context),
            AppColors.primaryColor(context).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Dashboard",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text("Welcome ${companyInfo?.name??""}",style: AppTextStyle.body(context).copyWith(
                color: AppColors.whiteColor(context)
              ),),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Icon(Icons.insights, color: AppColors.primaryColor(context)),
          ),
        ],
      ),
    );
  }

  // ================= FILTER =================
  Widget _buildFilterSegmentedControl() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      // decoration: BoxDecoration(
      //   color: AppColors.bottomNavBg(context),
      //   borderRadius: BorderRadius.circular(30),
      // ),
      child: CupertinoSegmentedControl<String>(
        children: {
          'current_day': _segText("Today", 'current_day'),
          'this_month': _segText(
            DateFormat('MMMM').format(DateTime.now()),
            'this_month',
          ),
          'lifeTime': _segText("Lifetime", 'lifeTime'),
        },
        groupValue: selectedPurchaseOverviewType,
        selectedColor: AppColors.primaryColor(context),
        unselectedColor: Colors.transparent,
        borderColor: Colors.transparent,
        onValueChanged: (value) {
          setState(() => selectedPurchaseOverviewType = value);
          context.read<DashboardBloc>().add(
            FetchDashboardData(dateFilter: value, context: context),
          );
        },
      ),
    );
  }

  Widget _segText(String text, String value) {
    final bool isSelected = selectedPurchaseOverviewType == value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected
              ? AppColors.text(context) // ✅ selected text color
              : AppColors.primaryColor(context), // ❌ unselected
        ),
      ),
    );
  }

  // ================= SUMMARY CARD =================
  Widget dashboardCardItem({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
    bool isCurrency = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.07),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTextStyle.bodyLarge(context)),
                const SizedBox(height: 4),
                if (isCurrency)
                  AnimatedAmountCounter(
                    amount: double.tryParse(value.toString()) ?? 0.0,
                    prefix: '৳ ',
                    style: AppTextStyle.body(context),
                  )
                else
                  AnimatedCounter(
                    amount: int.tryParse(value.toString()) ?? 0,
                    style: AppTextStyle.body(context),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCards(DashboardData data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 5,
      childAspectRatio: 1.1,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      children: [
        dashboardCardItem(
          title: "Total Sales",
          value: data.todayMetrics?.sales?.total?.toDouble() ?? 0,
          icon: Icons.shopping_cart,
          color: Colors.green,
          isCurrency: true,
        ),
        dashboardCardItem(
          title: "Purchases",
          value: data.todayMetrics?.purchases?.total?.toDouble() ?? 0,
          icon: Icons.inventory,
          color: Colors.blue,
          isCurrency: true,
        ),
        dashboardCardItem(
          title: "Expenses",
          value: data.todayMetrics?.expenses?.total?.toDouble() ?? 0,
          icon: Icons.money_off,
          color: Colors.red,
          isCurrency: true,
        ),
        dashboardCardItem(
          title: "Net Profit",
          value: data.profitLoss?.netProfit?.toDouble() ?? 0,
          icon: Icons.trending_up,
          color: (data.profitLoss?.netProfit ?? 0) >= 0
              ? Colors.green
              : Colors.red,
          isCurrency: true,
        ),
        dashboardCardItem(
          title: "Stock Alerts",
          value:
              ((data.stockAlerts?.lowStock ?? 0) +
                      (data.stockAlerts?.outOfStock ?? 0))
                  .toDouble(),
          icon: Icons.warning,
          color: Colors.orange,
        ),
      ],
    );
  }

  // ================= SECTION WRAPPER =================
  Widget _sectionWrapper(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text(context),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scaffoldKey: _scaffoldKey,
      drawer: const Drawer(child: MobileTabSidebar()),
      appBar: AppBar(
        backgroundColor: AppColors.bottomNavBg(context),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor(context),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                AppRoutes.push(context,  MobileRootScreen(initialPageIndex: 4,)),
            icon: const Icon(Icons.person, size: 30),
          ),
          gapW8,
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(
                FetchDashboardData(context: context),
              );
            },
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildFilterSegmentedControl(),

                  if (state is DashboardLoading)
                    const Center(child: CircularProgressIndicator()),

                  if (state is DashboardLoaded) ...[
                    _buildDashboardCards(state.dashboardData),
                    _sectionWrapper(
                      "Sales Overview",
                      _buildSalesOverview(state.dashboardData),
                    ),
                    _sectionWrapper(
                      "Purchase Overview",
                      _buildPurchaseOverview(state.dashboardData),
                    ),
                  ],

                  if (state is DashboardError)
                    Center(child: Text(state.message)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPurchaseOverview(DashboardData data) {
    final isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatsCardMonthly(
                title: "Purchase Quantity",
                count:
                    data.todayMetrics?.purchases?.totalQuantity?.toString() ??
                    "0",
                color: Colors.blue,
                icon: "assets/images/buy.png",
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: StatsCardMonthly(
                title: "Total Amount",
                count: (data.todayMetrics?.purchases?.total ?? 0)
                    .toStringAsFixed(2),
                color: Colors.green,
                icon: "assets/images/amount.png",
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
                count: (data.todayMetrics?.purchases?.totalDue ?? 0)
                    .toStringAsFixed(2),
                color: Colors.redAccent,
                icon: "assets/images/cancel.png",
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: StatsCardMonthly(
                title: "Returns",
                count: (data.todayMetrics?.purchaseReturns?.totalAmount ?? 0)
                    .toStringAsFixed(2),
                color: Colors.orange,
                icon: "assets/images/product_return.png",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalesOverview(DashboardData data) {
    final isMobile = Responsive.isMobile(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatsCardMonthly(
                title: "Sold Quantity",
                count:
                    data.todayMetrics?.sales?.totalQuantity?.toString() ?? "0",
                color: Colors.pink,
                icon: "assets/images/sales.png",
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: StatsCardMonthly(
                title: "Total Amount",
                count: (data.todayMetrics?.sales?.total ?? 0).toStringAsFixed(
                  2,
                ),
                color: Colors.purple,
                icon: "assets/images/amount.png",
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
                count: (data.todayMetrics?.sales?.totalDue ?? 0)
                    .toStringAsFixed(2),
                color: Colors.redAccent,
                icon: "assets/images/due.png",
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: StatsCardMonthly(
                title: "Profit / Loss",
                count: (data.profitLoss?.netProfit ?? 0).toStringAsFixed(2),
                color: (data.profitLoss?.netProfit ?? 0) >= 0
                    ? Colors.green
                    : Colors.red,
                icon: "assets/images/profits.png",
              ),
            ),
          ],
        ),
      ],
    );
  }
}
