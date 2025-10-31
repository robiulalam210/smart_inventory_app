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
                        horizontal: AppSizes.paddingInside,
                      ),
                      children: [
                        MenuTile(
                          isSubmenu: true,
                          title: "My Dashboard",
                          isSelected: currentIndex == 0,
                          onPressed: () {
                            bloc.add(ChangeDashboardScreen(index: 0));
                            context.read<DashboardBloc>().add(
                              LoadDashboardData(
                                filter: DateRangeFilter.last7Days,
                              ),
                            );
                          },
                        ),

                        ExpansionTile(
                          initiallyExpanded:
                              currentIndex == 1 || currentIndex == 2,

                          title: Text(
                            "Sales",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color,
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
                              title: "Sale List",
                              isSelected: currentIndex == 2,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 2));
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          initiallyExpanded:
                              currentIndex == 3 || currentIndex == 4,

                          title: Text(
                            "Money Receipt",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color,
                            ),
                          ),
                          children: [
                            MenuTile(
                              isSubmenu: true,
                              title: "Create Money Receipt",
                              isSelected: currentIndex == 3,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 3));
                              },
                            ),

                            MenuTile(
                              isSubmenu: true,
                              title: "Money Receipt",
                              isSelected: currentIndex == 4,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 4));
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          initiallyExpanded:
                              currentIndex == 5 || currentIndex == 6,

                          title: Text(
                            "Purchase ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color,
                            ),
                          ),
                          children: [
                            MenuTile(
                              isSubmenu: true,
                              title: "Create Purchase ",
                              isSelected: currentIndex == 5,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 5));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: "Purchase List ",
                              isSelected: currentIndex == 6,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 6));
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          initiallyExpanded: currentIndex == 7,

                          title: Text(
                            "Products ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color,
                            ),
                          ),
                          children: [
                            MenuTile(
                              isSubmenu: true,
                              title: "Product ",
                              isSelected: currentIndex == 7,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 7));
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          initiallyExpanded: currentIndex == 8,

                          title: Text(
                            "Accounts ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color,
                            ),
                          ),
                          children: [
                            MenuTile(
                              isSubmenu: true,
                              title: "Accounts ",
                              isSelected: currentIndex == 8,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 8));
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          initiallyExpanded: currentIndex == 9,

                          title: Text(
                            "Customers ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color,
                            ),
                          ),
                          children: [
                            MenuTile(
                              isSubmenu: true,
                              title: "Customer ",
                              isSelected: currentIndex == 9,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 9));
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          initiallyExpanded:
                              currentIndex == 10 || currentIndex == 11,

                          title: Text(
                            "Supplier ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color,
                            ),
                          ),
                          children: [
                            MenuTile(
                              isSubmenu: true,
                              title: " Supplier  List",
                              isSelected: currentIndex == 10,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 10));
                              },
                            ),

                            MenuTile(
                              isSubmenu: true,
                              title: 'Supplier Payment',
                              isSelected: currentIndex == 11,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 11));
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          initiallyExpanded:
                              currentIndex == 12 ||
                              currentIndex == 13 ||
                              currentIndex == 14,

                          title: Text(
                            "Expense ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color,
                            ),
                          ),
                          children: [
                            MenuTile(
                              isSubmenu: true,
                              title: "Expense  List",
                              isSelected: currentIndex == 12,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 12));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: 'Expense Head',
                              isSelected: currentIndex == 13,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 13));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: 'Expense Sub Head',
                              isSelected: currentIndex == 14,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 14));
                              },
                            ),
                          ],
                        ),

                        ExpansionTile(
                          initiallyExpanded:
                              currentIndex == 15 ||
                              currentIndex == 16 ||
                              currentIndex == 17,

                          title: Text(
                            "Return ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color,
                            ),
                          ),
                          children: [
                            MenuTile(
                              isSubmenu: true,
                              title: "Sales Return",
                              isSelected: currentIndex == 15,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 15));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: "Bad Stock List ",
                              isSelected: currentIndex == 16,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 16));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: "Purchase Return",
                              isSelected: currentIndex == 17,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 17));
                              },
                            ),
                          ],
                        ),

                        ExpansionTile(
                          initiallyExpanded:
                              currentIndex == 18 ||
                              currentIndex == 19 ||
                              currentIndex == 20 ||
                              currentIndex == 21 ||
                              currentIndex == 22 ||
                              currentIndex == 23 ||
                              currentIndex == 24 ||
                              currentIndex == 25 ||
                              currentIndex == 26 ||
                              currentIndex == 27,

                          title: Text(
                            "Reports ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color,
                            ),
                          ),
                          children: [
                            MenuTile(
                              isSubmenu: true,
                              title: 'Sales Report',
                              isSelected: currentIndex == 18,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 18));
                              },
                            ),

                            MenuTile(
                              isSubmenu: true,
                              title: 'Purchase Report',
                              isSelected: currentIndex == 19,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 19));
                              },
                            ),

                            MenuTile(
                              isSubmenu: true,
                              title: 'Profit/Loss Report',
                              isSelected: currentIndex == 20,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 20));
                              },
                            ),

                            MenuTile(
                              isSubmenu: true,
                              title: 'Top Sale Product Report',
                              isSelected: currentIndex == 21,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 21));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: 'Low Stock Product Report',
                              isSelected: currentIndex == 22,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 22));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: 'Stock Product Report',
                              isSelected: currentIndex == 23,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 23));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: 'Customer Ledger',
                              isSelected: currentIndex == 24,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 24));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: 'Customer Due/Advance Report',
                              isSelected: currentIndex == 25,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 25));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: 'Supplier Ledger',
                              isSelected: currentIndex == 26,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 26));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: 'Supplier Due/Advance Report',
                              isSelected: currentIndex == 27,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 27));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: 'Expense Report',
                              isSelected: currentIndex == 28,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 28));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: "Bad Stock Report",
                              isSelected: currentIndex == 4,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 4));
                              },
                            ),

                            MenuTile(
                              isSubmenu: true,
                              title: 'Supplier Ledger',
                              isSelected: currentIndex == 4,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 4));
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          initiallyExpanded:
                              currentIndex == 0 ||
                              currentIndex == 1 ||
                              currentIndex == 2 ||
                              currentIndex == 3 ||
                              currentIndex == 4 ||
                              currentIndex == 5,

                          title: Text(
                            "Administration ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color,
                            ),
                          ),
                          children: [
                            ExpansionTile(
                              initiallyExpanded:
                                  currentIndex == 16 || currentIndex == 17,

                              title: Text(
                                "Staff ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium!.color,
                                ),
                              ),
                              children: [
                                MenuTile(
                                  isSubmenu: true,
                                  title: "User ",
                                  isSelected: currentIndex == 16,
                                  onPressed: () {
                                    bloc.add(ChangeDashboardScreen(index: 16));
                                  },
                                ),
                                // MenuTile(
                                //   isSubmenu: true,
                                //   title: "Purchase List ",
                                //   isSelected: currentIndex == 12,
                                //   onPressed: () {
                                //     bloc.add(ChangeDashboardScreen(index: 12));
                                //   },
                                // ),
                              ],
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: "Source ",
                              isSelected: currentIndex == 6,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 6));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: "Unit ",
                              isSelected: currentIndex == 7,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 7));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: "Brand ",
                              isSelected: currentIndex == 8,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 8));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: "Category ",
                              isSelected: currentIndex == 9,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 9));
                              },
                            ),
                            MenuTile(
                              isSubmenu: true,
                              title: "Group ",
                              isSelected: currentIndex == 10,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 10));
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
