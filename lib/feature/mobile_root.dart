import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../core/widgets/app_scaffold.dart';
import 'lab_dashboard/presentation/pages/mobile_dashboard_screen.dart';
import 'profile/presentation/pages/moble_profile_screen.dart';
import 'purchase/presentation/page/mobile_purchase_screen.dart';
import 'report/presentation/page/mobile_all_report_tab_screen.dart';
import 'sales/presentation/pages/mobile_pos_sale_screen.dart';

class MobileRootScreen extends StatefulWidget {
  final int initialPageIndex;

  const MobileRootScreen({super.key, this.initialPageIndex = 2});

  @override
  State<MobileRootScreen> createState() => _MobileRootScreenState();
}

class _MobileRootScreenState extends State<MobileRootScreen> {
  final ValueNotifier<int> pageIndex = ValueNotifier<int>(0);
  late final List<Widget> screens;
  late final List<_NavItem> navItems;
  int? dashboardIndex;

  @override
  void initState() {
    super.initState();

    pageIndex.value = widget.initialPageIndex;

    // Build screens and nav items without any permissions
    screens = [
      MobilePosSaleScreen(),
      MobilePurchaseScreen(),
      DashBoardScreen(),
      MobileReportsTabScreen(),
      MobileProfileScreen(),
    ];

    navItems = [
      _NavItem(icon: HugeIcons.strokeRoundedSaleTag02, index: 0, label: 'Sales'),
      _NavItem(icon: HugeIcons.strokeRoundedInvoice04, index: 1, label: 'Purchase'),
      // Dashboard is center FAB
      _NavItem(icon: HugeIcons.strokeRoundedChartBarLine, index: 3, label: 'Reports'),
      _NavItem(icon: HugeIcons.strokeRoundedUser, index: 4, label: 'Profile'),
    ];

    dashboardIndex = 2; // Dashboard is always center FAB
  }

  @override
  void dispose() {
    pageIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppScaffold(
          body: ValueListenableBuilder<int>(
            valueListenable: pageIndex,
            builder: (context, currentIndex, child) {
              return screens[currentIndex];
            },
          ),
          isCenterFAB: true,
          bottomNavigationBar: SafeArea(
            child: ValueListenableBuilder<int>(
              valueListenable: pageIndex,
              builder: (context, currentIndex, child) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Left buttons
                          _buildNavButton(navItems[0].icon, navItems[0].index, currentIndex),
                          _buildNavButton(navItems[1].icon, navItems[1].index, currentIndex),

                          const SizedBox(width: 56), // space for center FAB

                          // Right buttons
                          _buildNavButton(navItems[2].icon, navItems[2].index, currentIndex),
                          _buildNavButton(navItems[3].icon, navItems[3].index, currentIndex),
                        ],
                      ),
                    ),

                    // Center FAB
                    Positioned(
                      bottom: 30,
                      child: FloatingActionButton(
                        onPressed: () => pageIndex.value = dashboardIndex!,
                        child: Icon(HugeIcons.strokeRoundedHome04),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, int index, int currentIndex) {
    final selected = index == currentIndex;
    return InkWell(
      onTap: () => pageIndex.value = index,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            height: 3,
            width: selected ? 20 : 0,
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Icon(icon, color: selected ? Colors.blue : Colors.black38),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final int index;
  final String label;

  _NavItem({required this.icon, required this.index, required this.label});
}

