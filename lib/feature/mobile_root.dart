import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:meherinMart/feature/profile/data/model/profile_perrmission_model.dart';
import 'package:meherinMart/feature/profile/presentation/pages/moble_profile_screen.dart';
import 'package:meherinMart/feature/purchase/presentation/page/mobile_purchase_screen.dart';
import 'package:meherinMart/feature/report/presentation/page/mobile_all_report_tab_screen.dart';
import 'package:meherinMart/feature/sales/presentation/pages/mobile_pos_sale_screen.dart';

import '../core/widgets/app_scaffold.dart';
import 'common/presentation/cubit/theme_cubit.dart';
import 'lab_dashboard/presentation/pages/mobile_dashboard_screen.dart';
import '/core/core.dart';
import 'profile/presentation/bloc/profile_bloc/profile_bloc.dart';

class MobileRootScreen extends StatefulWidget {
  final int initialPageIndex;

  const MobileRootScreen({super.key, this.initialPageIndex = 2});

  @override
  State<MobileRootScreen> createState() => _MobileRootScreenState();
}

class _MobileRootScreenState extends State<MobileRootScreen> {
  final ValueNotifier<int> pageIndex = ValueNotifier<int>(0);
  List<Widget> screens = [];
  List<_NavItem> navItems = [];
  int? dashboardIndex;

  @override
  void initState() {
    super.initState();

    // Use provided initial index as a starting value. We'll rebuild navigation
    // immediately with null (safe default) so there is always at least the
    // Profile screen available and the index will be clamped accordingly.
    pageIndex.value = widget.initialPageIndex;

    // Build a safe default navigation (no permissions yet)
    _buildNavigation(null);
  }

  @override
  void dispose() {
    pageIndex.dispose();
    super.dispose();
  }

  // Always build at least the Profile screen. Accept null permissions.
  void _buildNavigation(Permissions? permissions) {
    // Build fresh lists
    final newScreens = <Widget>[];
    final newNavItems = <_NavItem>[];
    int currentIndex = 0;
    int? newDashboardIndex;

    // Sales
    if ((permissions?.sales?.view ?? false) ||
        (permissions?.sales?.create ?? false)) {
      newScreens.add(MobilePosSaleScreen());
      newNavItems.add(
        _NavItem(
          icon: HugeIcons.strokeRoundedSaleTag02,
          index: currentIndex,
          label: 'Sales',
        ),
      );
      currentIndex++;
    } else {
      newScreens.add(
        Scaffold(body: Center(child: Text("No Permission Sale"))),
      );
      newNavItems.add(
        _NavItem(
          icon: HugeIcons.strokeRoundedSaleTag02,
          index: currentIndex,
          label: 'Sales',
        ),
      );
      currentIndex++;
    }

    // Purchase
    if ((permissions?.purchases?.view ?? false) ||
        (permissions?.purchases?.create ?? false)) {
      newScreens.add(MobilePurchaseScreen());
      newNavItems.add(
        _NavItem(
          icon: HugeIcons.strokeRoundedInvoice04,
          index: currentIndex,
          label: 'Purchase',
        ),
      );
      currentIndex++;
    } else {
      newScreens.add(
        Scaffold(body: Center(child: Text("No Permission Purchase"))),
      );
      // Use invoice icon for purchase even when permission missing
      newNavItems.add(
        _NavItem(
          icon: HugeIcons.strokeRoundedInvoice04,
          index: currentIndex,
          label: 'Purchase',
        ),
      );
      currentIndex++;
    }

    // Dashboard (center FAB) - add screen; when permitted we set dashboardIndex
    if (permissions?.dashboard?.view == true) {
      newScreens.add(DashBoardScreen());
      newDashboardIndex = currentIndex;
      // Note: intentionally NOT adding a nav item here because dashboard is
      // exposed via the center FAB when available.
      currentIndex++;
    } else {
      newScreens.add(
        Scaffold(body: Center(child: Text("No Permission Dashboard"))),
      );
      // When dashboard isn't available as center FAB, offer a normal nav item
      // so the user can see the placeholder/notice.
      newNavItems.add(
        _NavItem(
          icon: HugeIcons.strokeRoundedHome04,
          index: currentIndex,
          label: 'Dashboard',
        ),
      );
      currentIndex++;
    }

    // Reports
    if (permissions?.reports?.view == true) {
      newScreens.add(MobileReportsTabScreen());
      newNavItems.add(
        _NavItem(
          icon: HugeIcons.strokeRoundedChartBarLine,
          index: currentIndex,
          label: 'Reports',
        ),
      );
      currentIndex++;
    } else {
      newScreens.add(
        Scaffold(body: Center(child: Text("No Permission Reports"))),
      );
      // Use reports icon even when permission missing
      newNavItems.add(
        _NavItem(
          icon: HugeIcons.strokeRoundedChartBarLine,
          index: currentIndex,
          label: 'Reports',
        ),
      );
      currentIndex++;
    }

    // Profile (always add as last)
    newScreens.add(MobileProfileScreen());
    newNavItems.add(
      _NavItem(
        icon: HugeIcons.strokeRoundedUser,
        index: currentIndex,
        label: 'Profile',
      ),
    );

    // Assign to state
    screens = newScreens;
    navItems = newNavItems;
    dashboardIndex = newDashboardIndex;

    // Ensure pageIndex is valid for the new screens set
    if (pageIndex.value >= screens.length) {
      // set to last screen (profile) which we just added
      pageIndex.value = screens.isNotEmpty ? screens.length - 1 : 0;
    }
    // If pageIndex is negative (shouldn't happen), clamp to 0
    if (pageIndex.value < 0) {
      pageIndex.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final brightness = themeState.themeMode == ThemeMode.system
            ? MediaQuery.of(context).platformBrightness
            : themeState.themeMode == ThemeMode.dark
            ? Brightness.dark
            : Brightness.light;

        final isDark = brightness == Brightness.dark;
        final primary = themeState.primaryColor;

        // Listen for profile permission changes and update navigation from the listener.
        return BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfilePermissionSuccess) {
              _buildNavigation(state.permissionData.data?.permissions);
              if (mounted) setState(() {});
            } else if (state is ProfilePermissionFailed) {
              // If permission fetch failed, still make sure Profile screen is available
              _buildNavigation(null);
              if (mounted) setState(() {});
            }
          },
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              // If for some reason screens are empty (shouldn't be because we
              // build a default in initState), show NoScreens / error UI.
              if (screens.isEmpty) {
                return _buildNoScreensState();
              }

              final showCenterFAB = dashboardIndex != null;

              // Show the normal scaffold and overlay a loading indicator when loading,
              // instead of replacing the whole UI.
              return Stack(
                children: [
                  AppScaffold(
                    body: ValueListenableBuilder<int>(
                      valueListenable: pageIndex,
                      builder: (context, currentIndex, child) {
                        if (currentIndex < screens.length && currentIndex >= 0) {
                          return screens[currentIndex];
                        }
                        return screens.isNotEmpty ? screens[0] : Container();
                      },
                    ),
                    isCenterFAB: showCenterFAB,
                    bottomNavigationBar: SafeArea(
                      child: ValueListenableBuilder<int>(
                        valueListenable: pageIndex,
                        builder: (context, currentIndex, child) {
                          if (screens.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Stack(
                            alignment: Alignment.bottomCenter,
                            clipBehavior: Clip.none,
                            children: [
                              // Navigation bar container
                              Container(
                                padding: const EdgeInsets.all(14),
                                margin: const EdgeInsets.only(
                                  bottom: 10,
                                  left: 10,
                                  right: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[900] : Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    // Left side buttons
                                    for (int i = 0; i < (navItems.length ~/ 2); i++)
                                      _buildNavButton(
                                        navItems[i].icon,
                                        navItems[i].index,
                                        currentIndex,
                                        primary,
                                        isDark,
                                        navItems[i].label,
                                      ),

                                    // Center FAB space if dashboard is available
                                    if (showCenterFAB) const SizedBox(width: 56),

                                    // Right side buttons
                                    for (int i = navItems.length ~/ 2; i < navItems.length; i++)
                                      _buildNavButton(
                                        navItems[i].icon,
                                        navItems[i].index,
                                        currentIndex,
                                        primary,
                                        isDark,
                                        navItems[i].label,
                                      ),
                                  ],
                                ),
                              ),

                              // Center FAB (Dashboard) if available
                              if (showCenterFAB && dashboardIndex != null)
                                Positioned(
                                  bottom: 30,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: primary.withValues(alpha: 0.5),
                                          blurRadius: 10,
                                        ),
                                      ],
                                      color: primary,
                                    ),
                                    child: FloatingActionButton(
                                      shape: const CircleBorder(),
                                      onPressed: () {
                                        if (dashboardIndex! < screens.length) {
                                          pageIndex.value = dashboardIndex!;
                                        }
                                      },
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      child: Icon(
                                        HugeIcons.strokeRoundedHome04,
                                        color: AppColors.text(context),
                                        size: AppSizes.preferredBottom,
                                      ),
                                    ),
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
            },
          ),
        );
      },
    );
  }

  Widget _buildNoScreensState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'No Access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You don\'t have permission to access any features. Please contact your administrator.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(
      IconData icon,
      int index,
      int currentIndex,
      Color primary,
      bool isDark,
      String? label,
      ) {
    final selected = index == currentIndex;
    return Tooltip(
      message: label ?? '',
      child: InkWell(
        onTap: () => pageIndex.value = index,
        splashColor: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              height: 3,
              width: selected ? 20 : 0,
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
            ),
            SizedBox(height: AppSizes.paddingInside / 2),
            Icon(
              icon,
              size: AppSizes.preferredBottom,
              color: selected
                  ? primary
                  : isDark
                  ? Colors.grey[500]
                  : Colors.black38,
            ),
          ],
        ),
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