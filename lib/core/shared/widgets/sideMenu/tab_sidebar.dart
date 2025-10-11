import '../../../../feature/auth/presentation/pages/login_scr.dart';
import '../../../../feature/lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../../configs/configs.dart';
import 'menu_tile.dart';

class TabSidebar extends StatelessWidget {
  const TabSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            final bloc = context.read<DashboardBloc>();
            int currentIndex = 0;

            if (state is DashboardScreenChanged) {
              currentIndex = state.index;
            }

            return SafeArea(
              child: Column(
                children: [
                  /// Drawer Header
                  DrawerHeader(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/logo_new.png")),
                      color: Theme.of(context)
                          .colorScheme
                          .inversePrimary
                          .withValues(alpha: 0.1),
                    ),
                    child: InkWell(
                      onTap: () {
                        AppRoutes.pop(context);
                      },
                    ),
                  ),

                  const Divider(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingInside),
                      children: [
                        /// Main Group
                        ExpansionTile(
                          initiallyExpanded:
                              [0, 1, 2, 3,
                                4, 5
                              ].contains(currentIndex),
                          title: Text(
                            "Great Lab",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          children: [
                            MenuTile(
                              isSubmenu: true,
                              title: "Dashboard",
                              isSelected: currentIndex == 0,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 0));
                                context.read<DashboardBloc>().add(
                                    LoadDashboardData(filter:DateRangeFilter.last7Days));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: "Billing",
                              isSelected: currentIndex == 1,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 1));
                              },
                            ),

                            MenuTile(
                              isSubmenu: true,
                              title: "Transactions",
                              isSelected: currentIndex == 2,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 2));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: "Sample Collection",
                              isSelected: currentIndex == 3,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 3));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: "Lab Technologist",
                              isSelected: currentIndex == 4,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 4));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: "Report Delivery",
                              isSelected: currentIndex == 5,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 5));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// Optional Logout Button (Bottom)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingInside,
                      vertical: AppSizes.paddingInside,
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        backgroundColor: Colors.redAccent,
                      ),
                      icon: const Icon(
                        Icons.logout,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text("Logout"),
                      onPressed: () {
                        LocalDB.delLoginInfo();
                        AppRoutes.push(context, LogInScreen());
                        // Add logout logic or callback
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
