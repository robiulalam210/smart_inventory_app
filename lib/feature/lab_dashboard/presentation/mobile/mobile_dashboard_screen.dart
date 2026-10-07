import 'dart:ui' show FontFeature;

import 'package:intl/intl.dart';

import '../../../../core/configs/configs.dart';
import '../../../../core/utilities/amount_counter.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../mobile/mobile_root.dart';
import '../../../../mobile/widgets/mobile_tab_sidebar.dart';
import '../../../feature.dart';
import '../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '../widgets/mobile_stat_card.dart';

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

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _cardBorder =>
      _isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.borderLight;

  // ================= HERO (স্বাগতম + নিট লাভ) =================
  Widget _buildHero(DashboardData? data) {
    final companyInfo =
        context.read<ProfileBloc>().permissionModel?.data?.companyInfo;
    final primary = AppColors.primaryColor(context);
    final onPrimary = AppColors.onColor(primary);
    final netProfit = (data?.profitLoss?.netProfit ?? 0).toDouble();
    final isProfit = netProfit >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.primaryGradient(context),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyInfo?.name?.isNotEmpty == true
                          ? 'Welcome, ${companyInfo!.name}'
                          : 'Welcome',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
                      style: TextStyle(
                        color: onPrimary.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: onPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.insights_rounded, color: onPrimary),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Net Profit',
            style: TextStyle(
              color: onPrimary.withValues(alpha: 0.75),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AnimatedAmountCounter(
                    amount: netProfit,
                    prefix: '৳ ',
                    style: TextStyle(
                      color: onPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: onPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isProfit
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: onPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isProfit ? 'Profit' : 'Loss',
                      style: TextStyle(
                        color: onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= সময় ফিল্টার =================
  Widget _buildFilter() {
    final primary = AppColors.primaryColor(context);
    final onPrimary = AppColors.onColor(primary);

    final options = <String, String>{
      'current_day': 'Today',
      'this_month': DateFormat('MMMM').format(DateTime.now()),
      'lifeTime': 'Lifetime',
    };

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: options.entries.map((e) {
          final selected = selectedPurchaseOverviewType == e.key;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (selected) return;
                setState(() => selectedPurchaseOverviewType = e.key);
                context.read<DashboardBloc>().add(
                      FetchDashboardData(dateFilter: e.key, context: context),
                    );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  e.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? onPrimary
                        : AppColors.text(context).withValues(alpha: 0.65),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= স্টক সতর্কতা =================
  Widget _buildStockAlert(DashboardData data) {
    final low = data.stockAlerts?.lowStock ?? 0;
    final out = data.stockAlerts?.outOfStock ?? 0;
    if (low + out == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock Alert',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$low low stock · $out out of stock',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.text(context).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= KPI কার্ড =================
  Widget _kpiTile({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
    bool isCurrency = true,
  }) {
    final valueStyle = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w800,
      color: AppColors.text(context),
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text(context).withValues(alpha: 0.65),
                  ),
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: isCurrency
                ? AnimatedAmountCounter(
                    amount: value,
                    prefix: '৳ ',
                    style: valueStyle,
                  )
                : AnimatedCounter(amount: value.toInt(), style: valueStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(DashboardData data) {
    final profit = (data.profitLoss?.netProfit ?? 0).toDouble();
    final profitWithIncome =
        (data.profitLoss?.netProfitWithIncomes ?? 0).toDouble();
    final alerts = ((data.stockAlerts?.lowStock ?? 0) +
            (data.stockAlerts?.outOfStock ?? 0))
        .toDouble();

    final tiles = <Widget>[
      _kpiTile(
        title: 'Total Sales',
        value: data.todayMetrics?.sales?.total?.toDouble() ?? 0,
        icon: Icons.shopping_cart_rounded,
        color: AppColors.success,
      ),
      _kpiTile(
        title: 'Purchases',
        value: data.todayMetrics?.purchases?.total?.toDouble() ?? 0,
        icon: Icons.inventory_2_rounded,
        color: AppColors.info,
      ),
      _kpiTile(
        title: 'Expenses',
        value: data.todayMetrics?.expenses?.total?.toDouble() ?? 0,
        icon: Icons.payments_rounded,
        color: AppColors.danger,
      ),
      _kpiTile(
        title: 'Net Profit',
        value: profit,
        icon: Icons.trending_up_rounded,
        color: profit >= 0 ? AppColors.success : AppColors.danger,
      ),
      _kpiTile(
        title: 'Profit + Incomes',
        value: profitWithIncome,
        icon: Icons.account_balance_wallet_rounded,
        color: profitWithIncome >= 0 ? AppColors.success : AppColors.danger,
      ),
      _kpiTile(
        title: 'Stock Alerts',
        value: alerts,
        icon: Icons.warning_amber_rounded,
        color: AppColors.warning,
        isCurrency: false,
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: tiles,
    );
  }

  // ================= সেকশন =================
  Widget _section(String title, IconData icon, Widget child) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryColor(context)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _statsRow(Widget a, Widget b) {
    return Row(
      children: [
        Expanded(child: a),
        const SizedBox(width: 8),
        Expanded(child: b),
      ],
    );
  }

  Widget _buildSalesOverview(DashboardData data) {
    final profit = (data.profitLoss?.netProfit ?? 0);
    return Column(
      children: [
        _statsRow(
          MobileStatCard(
            title: 'Sold Quantity',
            count: data.todayMetrics?.sales?.totalQuantity?.toString() ?? '0',
            color: Colors.pink,
            icon: 'assets/images/sales.png',
          ),
          MobileStatCard(
            title: 'Total Amount',
            count: (data.todayMetrics?.sales?.total ?? 0).toStringAsFixed(2),
            color: Colors.purple,
            icon: 'assets/images/amount.png',
          ),
        ),
        const SizedBox(height: 8),
        _statsRow(
          MobileStatCard(
            title: 'Total Due',
            count: (data.todayMetrics?.sales?.totalDue ?? 0).toStringAsFixed(2),
            color: Colors.redAccent,
            icon: 'assets/images/due.png',
          ),
          MobileStatCard(
            title: 'Profit / Loss',
            count: profit.toStringAsFixed(2),
            color: profit >= 0 ? AppColors.success : AppColors.danger,
            icon: 'assets/images/profits.png',
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseOverview(DashboardData data) {
    return Column(
      children: [
        _statsRow(
          MobileStatCard(
            title: 'Purchase Quantity',
            count:
                data.todayMetrics?.purchases?.totalQuantity?.toString() ?? '0',
            color: AppColors.info,
            icon: 'assets/images/buy.png',
          ),
          MobileStatCard(
            title: 'Total Amount',
            count:
                (data.todayMetrics?.purchases?.total ?? 0).toStringAsFixed(2),
            color: AppColors.success,
            icon: 'assets/images/amount.png',
          ),
        ),
        const SizedBox(height: 8),
        _statsRow(
          MobileStatCard(
            title: 'Total Due',
            count: (data.todayMetrics?.purchases?.totalDue ?? 0)
                .toStringAsFixed(2),
            color: Colors.redAccent,
            icon: 'assets/images/cancel.png',
          ),
          MobileStatCard(
            title: 'Returns',
            count: (data.todayMetrics?.purchaseReturns?.totalAmount ?? 0)
                .toStringAsFixed(2),
            color: AppColors.warning,
            icon: 'assets/images/product_return.png',
          ),
        ),
      ],
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
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        centerTitle: false,
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryColor(context),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => AppRoutes.push(
              context,
              const MobileRootScreen(initialPageIndex: 4),
            ),
            icon: const Icon(Icons.account_circle_outlined, size: 28),
          ),
          gapW8,
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final loaded = state is DashboardLoaded ? state.dashboardData : null;

          return RefreshIndicator(
            color: AppColors.primaryColor(context),
            onRefresh: () async {
              context.read<DashboardBloc>().add(
                    FetchDashboardData(
                      dateFilter: selectedPurchaseOverviewType,
                      context: context,
                    ),
                  );
            },
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(loaded),
                  _buildFilter(),
                  if (state is DashboardLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (loaded != null) ...[
                    _buildStockAlert(loaded),
                    const SizedBox(height: 14),
                    _buildKpiGrid(loaded),
                    _section(
                      'Sales Overview',
                      Icons.point_of_sale_rounded,
                      _buildSalesOverview(loaded),
                    ),
                    _section(
                      'Purchase Overview',
                      Icons.local_shipping_rounded,
                      _buildPurchaseOverview(loaded),
                    ),
                  ],
                  if (state is DashboardError)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text(state.message)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
