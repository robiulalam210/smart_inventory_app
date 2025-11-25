import '../../../../feature/lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../../configs/configs.dart';
import 'menu_tile.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  // Define menu structure for better maintainability
  final List<MenuSection> menuSections = [
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
        MenuItem(title: "Transaction", index: 36),
        MenuItem(title: "Profile", index: 37),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final bloc = context.read<DashboardBloc>();
        int currentIndex = 0;

        if (state is DashboardScreenChanged) {
          currentIndex = state.index;
        }

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width*030,
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
                        /// Drawer Header
                        DrawerHeader(

                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.all(0),
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
                        // Build menu sections dynamically
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
                                    _handleMenuSelection(
                                        bloc, item.index, context);
                                  },
                                );
                              }).toList(),
                            );
                          }
                        }),
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

  void _handleMenuSelection(DashboardBloc bloc, int index, BuildContext context) {
    bloc.add(ChangeDashboardScreen(index: index));

    // Handle special cases
    if (index == 0) {
      // Dashboard - load data
      bloc.add(FetchDashboardData(context: context));
    }

    // Close drawer on mobile
    if (Responsive.isMobile(context)) {
      Navigator.pop(context);
    }
  }
}

// Helper classes for menu structure
class MenuSection {
  final String title;
  final List<MenuItem> items;

  MenuSection({required this.title, required this.items});
}

class MenuItem {
  final String title;
  final int index;

  MenuItem({required this.title, required this.index});
}