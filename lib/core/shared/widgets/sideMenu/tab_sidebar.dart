import '../../../../feature/auth/presentation/pages/login_scr.dart';
import '../../../../feature/lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../../configs/configs.dart';
import 'menu_tile.dart';

class TabSidebar extends StatelessWidget {
  const TabSidebar({super.key});

  // Same menu structure as Sidebar for consistency
  final List<MenuSection> menuSections = const [
    MenuSection(
      title: "My Dashboard",
      items: [
        MenuItem(title: "My Dashboard", index: 0),
      ],
    ),
    MenuSection(
      title: "Sales",
      items: [
        MenuItem(title: "Sale", index: 1),
        MenuItem(title: "Sale List", index: 2),
      ],
    ),
    MenuSection(
      title: "Money Receipt",
      items: [
        MenuItem(title: "Create Money Receipt", index: 3),
        MenuItem(title: "Money Receipt", index: 4),
      ],
    ),
    MenuSection(
      title: "Purchase",
      items: [
        MenuItem(title: "Create Purchase", index: 5),
        MenuItem(title: "Purchase List", index: 6),
      ],
    ),
    MenuSection(
      title: "Products",
      items: [
        MenuItem(title: "Product", index: 7),
      ],
    ),
    MenuSection(
      title: "Accounts",
      items: [
        MenuItem(title: "Accounts", index: 8),
      ],
    ),
    MenuSection(
      title: "Customers",
      items: [
        MenuItem(title: "Customer", index: 9),
      ],
    ),
    MenuSection(
      title: "Supplier",
      items: [
        MenuItem(title: "Supplier List", index: 10),
        MenuItem(title: "Supplier Payment", index: 11),
      ],
    ),
    MenuSection(
      title: "Expense",
      items: [
        MenuItem(title: "Expense List", index: 12),
        MenuItem(title: "Expense Head", index: 13),
        MenuItem(title: "Expense Sub Head", index: 14),
      ],
    ),
    MenuSection(
      title: "Return",
      items: [
        MenuItem(title: "Sales Return", index: 15),
        MenuItem(title: "Bad Stock List", index: 16),
        MenuItem(title: "Purchase Return", index: 17),
      ],
    ),
    MenuSection(
      title: "Reports",
      items: [
        MenuItem(title: "Sales Report", index: 18),
        MenuItem(title: "Purchase Report", index: 19),
        MenuItem(title: "Profit/Loss Report", index: 20),
        MenuItem(title: "Top Sale Product Report", index: 21),
        MenuItem(title: "Low Stock Product Report", index: 22),
        MenuItem(title: "Stock Product Report", index: 23),
        MenuItem(title: "Customer Ledger", index: 24),
        MenuItem(title: "Customer Due/Advance Report", index: 25),
        MenuItem(title: "Supplier Ledger", index: 26),
        MenuItem(title: "Supplier Due/Advance Report", index: 27),
        MenuItem(title: "Expense Report", index: 28),
        // MenuItem(title: "Bad Stock Report", index: 29),
      ],
    ),
    MenuSection(
      title: "Administration",
      items: [
        MenuItem(title: "Staff", index: 30),
        MenuItem(title: "Source", index: 31),
        MenuItem(title: "Unit", index: 32),
        MenuItem(title: "Brand", index: 33),
        MenuItem(title: "Category", index: 34),
        MenuItem(title: "Group", index: 35),
        MenuItem(title: "Profile", index: 36),
      ],
    ),
    MenuSection(
      title: "Transfer Balance",
      items: [
        MenuItem(title: "Account Transfer From", index: 37),
        MenuItem(title: "Account Transfer List", index: 38),
        MenuItem(title: "Translation", index: 39),

      ],
    ),
  ];

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

            return Column(
              children: [
                /// Drawer Header
                DrawerHeader(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // color: Theme.of(context)
                    //     .colorScheme
                    //     .inversePrimary
                    //     .withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.fill,
                      height: 250,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          "Great Lab",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const Divider(height: 1),

                /// Menu Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingInside,
                      vertical: 8,
                    ),
                    children: [
                      // Build all menu sections dynamically
                      ...menuSections.map((section) {
                        if (section.items.length == 1) {
                          // Single item (no expansion)
                          final item = section.items.first;
                          return MenuTile(
                            isSubmenu: true,
                            title: section.title,
                            isSelected: currentIndex == item.index,
                            onPressed: () {
                              _handleMenuSelection(bloc, item.index, context);
                            },
                          );
                        } else {
                          // Multiple items (with expansion)
                          return ExpansionTile(
                            initiallyExpanded: section.items
                                .any((item) => currentIndex == item.index),
                            title: Text(
                              section.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                            ),
                            children: section.items.map((item) {
                              return MenuTile(
                                isSubmenu: true,
                                title: item.title,
                                isSelected: currentIndex == item.index,
                                onPressed: () {
                                  _handleMenuSelection(bloc, item.index, context);
                                },
                              );
                            }).toList(),
                          );
                        }
                      }),
                    ],
                  ),
                ),

                /// Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingInside,
                    vertical: AppSizes.paddingInside,
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text(
                      "Logout",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onPressed: () {
                      _handleLogout(context);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleMenuSelection(DashboardBloc bloc, int index, BuildContext context) {
    bloc.add(ChangeDashboardScreen(index: index));

    // Handle special cases
    if (index == 0) {
      bloc.add(FetchDashboardData( context: context));
    }

    // Close drawer on tablet/mobile
    if (Responsive.isTablet(context) || Responsive.isMobile(context)) {
      Navigator.pop(context);
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                LocalDB.delLoginInfo();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LogInScreen()),
                      (route) => false,
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Make sure these classes are available (same as in Sidebar)
class MenuSection {
  final String title;
  final List<MenuItem> items;

  const MenuSection({required this.title, required this.items});
}

class MenuItem {
  final String title;
  final int index;

  const MenuItem({required this.title, required this.index});
}