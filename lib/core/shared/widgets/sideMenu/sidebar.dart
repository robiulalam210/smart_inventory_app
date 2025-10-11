import 'package:flutter_svg/flutter_svg.dart';

import '../../../../feature/lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../../configs/configs.dart';
import 'menu_tile.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String selectedMenu = 'dashboard'; // Store the selected menu
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final bloc = context.read<DashboardBloc>();
        int currentIndex = 0; // Default

        if (state is DashboardScreenChanged) {
          currentIndex = state.index;
        }

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: Drawer(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  gapH16,
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 100,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingInside),
                      children: [
                        MenuTile(
                          isSubmenu: true,
                          title: "My Dashboard",
                          isSelected: currentIndex == 0,
                          onPressed: () {
                            bloc.add(ChangeDashboardScreen(index: 0));
                            context.read<DashboardBloc>().add(
                                LoadDashboardData(
                                    filter: DateRangeFilter.last7Days));
                          },
                        ),

                        ExpansionTile(
                          initiallyExpanded: currentIndex == 0 ||
                              currentIndex == 1 ||
                              currentIndex == 2 ||
                              currentIndex == 3 ||
                              currentIndex == 4 ||
                              currentIndex == 5,

                          title: Text(
                            "Sales",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                              Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                          ),
                          children: [

                            MenuTile(
                              isSubmenu: true,
                              title: "Sale",
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



                          ],
                        ),
                        ExpansionTile(
                          initiallyExpanded: currentIndex == 0 ||
                              currentIndex == 1 ||
                              currentIndex == 2 ||
                              currentIndex == 3 ||
                              currentIndex == 4 ||
                              currentIndex == 5,

                          title: Text(
                            "Product Setup",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                              Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                          ),
                          children: [


                            MenuTile(
                              isSubmenu: true,
                              title: "Product ",
                              isSelected: currentIndex == 4,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 4));
                              },
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
