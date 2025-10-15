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
                              currentIndex == 5 ||
                              currentIndex == 6 ||
                              currentIndex == 7 ||
                              currentIndex == 8 ||
                              currentIndex == 9 ||
                              currentIndex == 10 ||
                              currentIndex == 10,

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
                            // MenuTile(
                            //   isSubmenu: true,
                            //   title: "Create Product ",
                            //   isSelected: currentIndex == 5,
                            //   onPressed: () {
                            //     bloc.add(ChangeDashboardScreen(index: 5));
                            //   },
                            // ),
                            MenuTile(
                              isSubmenu: true,
                              title: "Product ",
                              isSelected: currentIndex == 5,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 5));
                              },
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
                            MenuTile(
                              isSubmenu: true,
                              title: "Accounts ",
                              isSelected: currentIndex == 11,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 11));
                              },
                            ),MenuTile(
                              isSubmenu: true,
                              title: "Customers ",
                              isSelected: currentIndex == 12,
                              onPressed: () {
                                bloc.add(ChangeDashboardScreen(index: 12));
                              },
                            ),
                          ],
                        ),
                        // ExpansionTile(
                        //   initiallyExpanded:
                        //       currentIndex == 12 ||
                        //       currentIndex == 12 ,
                        //
                        //
                        //   title: Text(
                        //     "Purchase ",
                        //     style: TextStyle(
                        //       fontWeight: FontWeight.w600,
                        //       color: Theme.of(
                        //         context,
                        //       ).textTheme.bodyMedium!.color,
                        //     ),
                        //   ),
                        //   children: [
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: "Create Purchase ",
                        //       isSelected: currentIndex == 12,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 12));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: "Purchase List ",
                        //       isSelected: currentIndex == 12,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 12));
                        //       },
                        //     ),
                        //   ],
                        // ),
                        //
                        //
                        // ExpansionTile(
                        //   initiallyExpanded:
                        //
                        //       currentIndex == 13 ||
                        //       currentIndex == 4 ,
                        //
                        //
                        //   title: Text(
                        //     "Return ",
                        //     style: TextStyle(
                        //       fontWeight: FontWeight.w600,
                        //       color: Theme.of(
                        //         context,
                        //       ).textTheme.bodyMedium!.color,
                        //     ),
                        //   ),
                        //   children: [
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: "Sales Return",
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: "Bad Stock List ",
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: "Purchase Return",
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //   ],
                        // ),
                        // ExpansionTile(
                        //   initiallyExpanded:
                        //       currentIndex == 0 ||
                        //       currentIndex == 1 ||
                        //       currentIndex == 2 ||
                        //       currentIndex == 3 ||
                        //       currentIndex == 4 ||
                        //       currentIndex == 5,
                        //
                        //   title: Text(
                        //     "Accounts ",
                        //     style: TextStyle(
                        //       fontWeight: FontWeight.w600,
                        //       color: Theme.of(
                        //         context,
                        //       ).textTheme.bodyMedium!.color,
                        //     ),
                        //   ),
                        //   children: [
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: "Accounts  ",
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: "Customer Balance Adjustment ",
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: "Customer Balance Adjustment ",
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: "Balance Adjustment ",
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: "Balance Transfer",
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //   ],
                        // ),
                        // ExpansionTile(
                        //   initiallyExpanded:
                        //       currentIndex == 0 ||
                        //       currentIndex == 1 ||
                        //       currentIndex == 2 ||
                        //       currentIndex == 3 ||
                        //       currentIndex == 4 ||
                        //       currentIndex == 5,
                        //
                        //   title: Text(
                        //     "Customer ",
                        //     style: TextStyle(
                        //       fontWeight: FontWeight.w600,
                        //       color: Theme.of(
                        //         context,
                        //       ).textTheme.bodyMedium!.color,
                        //     ),
                        //   ),
                        //   children: [
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: "Create Customer ",
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: "Customer List ",
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //   ],
                        // ),
                        //
                        // ExpansionTile(
                        //   initiallyExpanded:
                        //       currentIndex == 0 ||
                        //       currentIndex == 1 ||
                        //       currentIndex == 2 ||
                        //       currentIndex == 3 ||
                        //       currentIndex == 4 ||
                        //       currentIndex == 5,
                        //
                        //   title: Text(
                        //     "Supplier ",
                        //     style: TextStyle(
                        //       fontWeight: FontWeight.w600,
                        //       color: Theme.of(
                        //         context,
                        //       ).textTheme.bodyMedium!.color,
                        //     ),
                        //   ),
                        //   children: [
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: " Supplier  List",
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: 'Payment List',
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: 'Supplier Payment',
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //   ],
                        // ),
                        //
                        // ExpansionTile(
                        //   initiallyExpanded:
                        //       currentIndex == 0 ||
                        //       currentIndex == 1 ||
                        //       currentIndex == 2 ||
                        //       currentIndex == 3 ||
                        //       currentIndex == 4 ||
                        //       currentIndex == 5,
                        //
                        //   title: Text(
                        //     "Expense ",
                        //     style: TextStyle(
                        //       fontWeight: FontWeight.w600,
                        //       color: Theme.of(
                        //         context,
                        //       ).textTheme.bodyMedium!.color,
                        //     ),
                        //   ),
                        //   children: [
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: " Expense  List",
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: 'Expense Head',
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //   ],
                        // ),
                        // ExpansionTile(
                        //   initiallyExpanded:
                        //       currentIndex == 0 ||
                        //       currentIndex == 1 ||
                        //       currentIndex == 2 ||
                        //       currentIndex == 3 ||
                        //       currentIndex == 4 ||
                        //       currentIndex == 5,
                        //
                        //   title: Text(
                        //     "Reports ",
                        //     style: TextStyle(
                        //       fontWeight: FontWeight.w600,
                        //       color: Theme.of(
                        //         context,
                        //       ).textTheme.bodyMedium!.color,
                        //     ),
                        //   ),
                        //   children: [
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: "Bad Stock Report",
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: 'Supplier Due/Advance Report',
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: 'Supplier Ledger',
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: 'Customer Ledger',
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: 'Customer Due/Advance Report',
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: 'Expense Report',
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: 'Purchase Report',
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: 'Sales Report',
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //     MenuTile(
                        //       isSubmenu: true,
                        //       title: 'Profit/Loss Report',
                        //       isSelected: currentIndex == 4,
                        //       onPressed: () {
                        //         bloc.add(ChangeDashboardScreen(index: 4));
                        //       },
                        //     ),
                        //   ],
                        // ),
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
