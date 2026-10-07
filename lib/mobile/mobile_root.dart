import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../core/configs/app_colors.dart';
import '../core/widgets/app_scaffold.dart';
import '../feature/lab_dashboard/presentation/mobile/mobile_dashboard_screen.dart';
import '../feature/profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '../feature/profile/presentation/mobile/moble_profile_screen.dart';
import '../feature/purchase/presentation/mobile/mobile_purchase_screen.dart';
import '../feature/report/presentation/mobile/mobile_all_report_tab_screen.dart';
import '../feature/sales/presentation/mobile/mobile_pos_sale_screen.dart';

/// মোবাইলের মূল শেল — নিচে ৫টি ট্যাবসহ নেভিগেশন বার।
/// ট্যাবের ক্রম: Sales · Purchase · Home · Reports · Profile
class MobileRootScreen extends StatefulWidget {
  final int initialPageIndex;

  const MobileRootScreen({super.key, this.initialPageIndex = 2});

  @override
  State<MobileRootScreen> createState() => _MobileRootScreenState();
}

class _MobileRootScreenState extends State<MobileRootScreen> {
  final ValueNotifier<int> pageIndex = ValueNotifier<int>(0);
  late final List<Widget> screens;

  static const List<_NavItem> _items = [
    _NavItem(HugeIcons.strokeRoundedSaleTag02, 'Sales'),
    _NavItem(HugeIcons.strokeRoundedInvoice04, 'Purchase'),
    _NavItem(HugeIcons.strokeRoundedHome04, 'Home'),
    _NavItem(HugeIcons.strokeRoundedChartBarLine, 'Reports'),
    _NavItem(HugeIcons.strokeRoundedUser, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    pageIndex.value = widget.initialPageIndex;
    screens = [
      MobilePosSaleScreen(),
      MobilePurchaseScreen(),
      DashBoardScreen(),
      MobileReportsTabScreen(),
      MobileProfileScreen(),
    ];
  }

  @override
  void dispose() {
    pageIndex.dispose();
    super.dispose();
  }

  /// Permission এখনো লোড না হলে (null) কিছুই lock হয় না;
  /// backend নিজেই access যাচাই করে।
  bool _allowed(BuildContext context, int index) {
    final p = context.read<ProfileBloc>().permissionModel?.data?.permissions;
    if (p == null) return true;
    switch (index) {
      case 0:
        return p.sales?.view == true;
      case 1:
        return p.purchases?.view == true;
      case 2:
        return p.dashboard?.view == true;
      case 3:
        return p.reports?.view == true;
      default:
        return true; // Profile
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: pageIndex,
        builder: (context, currentIndex, _) => screens[currentIndex],
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: pageIndex,
        builder: (context, currentIndex, _) =>
            _buildBottomBar(context, currentIndex),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, int currentIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.primaryColor(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.borderLight,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
          child: Row(
            children: List.generate(_items.length, (i) {
              return Expanded(
                child: _NavButton(
                  item: _items[i],
                  selected: i == currentIndex,
                  enabled: _allowed(context, i),
                  primary: primary,
                  onTap: () => pageIndex.value = i,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final bool enabled;
  final Color primary;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.enabled,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final base = AppColors.text(context);
    final Color color = !enabled
        ? base.withValues(alpha: 0.2)
        : selected
            ? primary
            : base.withValues(alpha: 0.55);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: selected ? 52 : 36,
              height: 30,
              decoration: BoxDecoration(
                color: selected
                    ? primary.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(item.icon, size: 22, color: color),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1.1,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}
