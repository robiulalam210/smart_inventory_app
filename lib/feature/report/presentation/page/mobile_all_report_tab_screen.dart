import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meherinMart/core/configs/app_colors.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:meherinMart/feature/report/presentation/page/profit_loss_screen/mobile_profit_loss_screen.dart';
import 'package:meherinMart/feature/report/presentation/page/stock_report_screen/mobile_stock_report_screen.dart';
import 'package:meherinMart/feature/report/presentation/page/supplier_due_advance_screen/mobile_supplier_due_advance_screen.dart';
import 'package:meherinMart/feature/report/presentation/page/supplier_ledger_screen/mobile_supplier_ledger_screen.dart';
import 'package:meherinMart/feature/report/presentation/page/top_products_screen/mobile_top_products_screen.dart';

import 'customer_due_advance_screen/mobile_customer_due_advance_screen.dart';
import 'customer_ledger_screen/mobile_customer_ledger_screen.dart';
import 'expense_report_screen/mobile_expense_report_screen.dart';
import 'low_stock_screen/mobile_low_stock_screen.dart';
import 'purchase_report_screen/mobile_purchase_report_screen.dart';
import 'sales_report_page/mobile_sales_report_screen.dart';

class MobileReportsTabScreen extends StatefulWidget {
  const MobileReportsTabScreen({super.key});

  @override
  State<MobileReportsTabScreen> createState() => _MobileReportsTabScreenState();
}

class _MobileReportsTabScreenState extends State<MobileReportsTabScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  late TabController _tabController;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Define all 11 tabs with icons and colors
  final List<ReportTab> _tabs = [
    ReportTab(
      title: 'Sales',
      icon: Icons.shopping_cart,
      color: Colors.blue,
    ),
    ReportTab(
      title: 'Purchase',
      icon: Icons.shopping_bag,
      color: Colors.purple,
    ),
    ReportTab(
      title: 'Profit/Loss',
      icon: Icons.trending_up,
      color: Colors.green,
    ),
    ReportTab(
      title: 'Top Products',
      icon: Icons.star,
      color: Colors.amber,
    ),
    ReportTab(
      title: 'Low Stock',
      icon: Icons.warning,
      color: Colors.red,
    ),
    ReportTab(
      title: 'Stock Report',
      icon: Icons.inventory,
      color: Colors.teal,
    ),
    ReportTab(
      title: 'Customer Ledger',
      icon: Icons.book,
      color: Colors.indigo,
    ),
    ReportTab(
      title: 'Customer Due',
      icon: Icons.account_balance_wallet,
      color: Colors.deepOrange,
    ),
    ReportTab(
      title: 'Supplier Ledger',
      icon: Icons.business,
      color: Colors.brown,
    ),
    ReportTab(
      title: 'Supplier Due',
      icon: Icons.account_balance,
      color: Colors.cyan,
    ),
    ReportTab(
      title: 'Expense',
      icon: Icons.pie_chart,
      color: Colors.orange,
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
      _pageController.jumpToPage(_tabController.index);
    }
  }

  void _onPageChanged(int index) {
    _tabController.animateTo(index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }





  @override
  Widget build(BuildContext context) {
    super.build(context);

    return AppScaffold(

      body: SafeArea(
        child: Column(
          children: [

            // 🔹 TabBar (Without AppBar)
            Container(
              height: 48,
              decoration: BoxDecoration(
           
                color: AppColors.bottomNavBg(context),
                
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 3,
                indicatorColor: _tabs[_currentIndex].color,
                labelColor: _tabs[_currentIndex].color,
                unselectedLabelColor: AppColors.text(context),
                tabs: _tabs.map((tab) {
                  return Tab(
                    icon: Icon(tab.icon, size: 18),
                    text: tab.title,
                  );
                }).toList(),
              ),
            ),

            // 🔹 Tab View
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: const [
                  MobileSalesReportScreen(),
                  MobilePurchaseReportScreen(),
                  MobileProfitLossScreen(),
                  MobileTopProductsScreen(),
                  MobileLowStockScreen(),
                  MobileStockReportScreen(),
                  MobileCustomerLedgerScreen(),
                  MobileCustomerDueAdvanceScreen(),
                  MobileSupplierLedgerScreen(),
                  MobileSupplierDueAdvanceScreen(),
                  MobileExpenseReportScreen(),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }

}

class ReportTab {
  final String title;
  final IconData icon;
  final Color color;

  ReportTab({
    required this.title,
    required this.icon,
    required this.color,
  });
}