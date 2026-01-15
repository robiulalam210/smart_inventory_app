import 'package:meherinMart/feature/profile/presentation/pages/moble_profile_screen.dart';
import 'package:meherinMart/feature/purchase/presentation/page/mobile_purchase_screen.dart';
import 'package:meherinMart/feature/report/presentation/page/mobile_all_report_tab_screen.dart';
import 'package:meherinMart/feature/sales/presentation/pages/create_pos_sale/mobile_create_sales_pos.dart';

import '../core/widgets/app_scaffold.dart';
import 'common/presentation/cubit/theme_cubit.dart';
import 'lab_dashboard/presentation/pages/mobile_dashboard_screen.dart';
import '/core/core.dart';
import 'sales/presentation/pages/mobile_pos_sale_screen.dart';

class MobileRootScreen extends StatefulWidget {
  final int initialPageIndex;
  const MobileRootScreen({super.key, this.initialPageIndex = 2});

  @override
  State<MobileRootScreen> createState() => _MobileRootScreenState();
}

class _MobileRootScreenState extends State<MobileRootScreen> {
  final ValueNotifier<int> pageIndex = ValueNotifier<int>(0);

  final List<Widget> screens = [

    MobilePosSaleScreen(),
    MobilePurchaseScreen(),
    DashBoardScreen(),
    MobileReportsTabScreen(),
    MobileProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    pageIndex.value = widget.initialPageIndex;
  }

  @override
  void dispose() {
    pageIndex.dispose();
    super.dispose();
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

        return AppScaffold(
          body: ValueListenableBuilder(
            valueListenable: pageIndex,
            builder: (_, value, _) => screens[value],
          ),
          isCenterFAB: true,
          bottomNavigationBar: SafeArea(
            child: ValueListenableBuilder(
              valueListenable: pageIndex,
              builder: (_, value, _) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    // Bottom Navigation Bar Container
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
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
                          _buildNavButton(HugeIcons.strokeRoundedSaleTag02, 0, value, primary, isDark),
                          _buildNavButton(HugeIcons.strokeRoundedInvoice04, 1, value, primary, isDark),
                          const SizedBox(width: 56), // FAB space
                          _buildNavButton(HugeIcons.strokeRoundedChartBarLine, 3, value, primary, isDark),
                          _buildNavButton(HugeIcons.strokeRoundedUser, 4, value, primary, isDark),
                        ],
                      ),
                    ),
                    // Center FAB
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
                          onPressed: () => pageIndex.value = 2,
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
        );
      },
    );
  }

  // Navigation button builder
  Widget _buildNavButton(
      IconData icon,
      int index,
      int currentIndex,
      Color primary,
      bool isDark,
      ) {
    final selected = index == currentIndex;
    return InkWell(
      onTap: () => pageIndex.value = index,
      splashColor: Colors.transparent,
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
    );
  }
}
