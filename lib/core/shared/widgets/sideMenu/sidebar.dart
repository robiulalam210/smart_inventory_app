import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../feature/lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../../../feature/profile/data/model/profile_perrmission_model.dart';
import '../../../../feature/profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '../../../configs/configs.dart';
import 'menu_tile.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  // Define full menu structure with permission checks
  final List<MenuSection> _fullMenuSections = [
    MenuSection(
      title: "My Dashboard",
      items: [
        MenuItem(title: "My Dashboard", index: 0, requiredPermission: (permissions) => permissions?.dashboard?.view == true),
      ],
      requiredPermission: (permissions) => permissions?.dashboard?.view == true,
    ),
    MenuSection(
      title: "Sales",
      items: [
        MenuItem(title: "Sale", index: 1, requiredPermission: (permissions) => permissions?.sales?.create == true),
        MenuItem(title: "Pos Sale", index: 2, requiredPermission: (permissions) => permissions?.sales?.create == true),
        MenuItem(title: "Sale List", index: 3, requiredPermission: (permissions) => permissions?.sales?.view == true),
      ],
      requiredPermission: (permissions) =>
      permissions?.sales?.view == true || permissions?.sales?.create == true,
    ),
    MenuSection(
      title: "Money Receipt",
      items: [
        MenuItem(title: "Create Money Receipt", index: 4, requiredPermission: (permissions) => permissions?.moneyReceipt?.create == true),
        MenuItem(title: "Money Receipt", index: 5, requiredPermission: (permissions) => permissions?.moneyReceipt?.view == true),
      ],
      requiredPermission: (permissions) =>
      permissions?.moneyReceipt?.view == true || permissions?.moneyReceipt?.create == true,
    ),
    MenuSection(
      title: "Purchase",
      items: [
        MenuItem(title: "Create Purchase", index: 6, requiredPermission: (permissions) => permissions?.purchases?.create == true),
        MenuItem(title: "Purchase List", index: 7, requiredPermission: (permissions) => permissions?.purchases?.view == true),
      ],
      requiredPermission: (permissions) =>
      permissions?.purchases?.view == true || permissions?.purchases?.create == true,
    ),
    MenuSection(
      title: "Products",
      items: [
        MenuItem(title: "Product", index: 8, requiredPermission: (permissions) => permissions?.products?.view == true),
      ],
      requiredPermission: (permissions) => permissions?.products?.view == true,
    ),
    MenuSection(
      title: "Accounts",
      items: [
        MenuItem(title: "Accounts", index: 9, requiredPermission: (permissions) => permissions?.accounts?.view == true),
      ],
      requiredPermission: (permissions) => permissions?.accounts?.view == true,
    ),
    MenuSection(
      title: "Customers",
      items: [
        MenuItem(title: "Customer", index: 10, requiredPermission: (permissions) => permissions?.customers?.view == true),
      ],
      requiredPermission: (permissions) => permissions?.customers?.view == true,
    ),
    MenuSection(
      title: "Supplier",
      items: [
        MenuItem(title: "Supplier List", index: 11, requiredPermission: (permissions) => permissions?.suppliers?.view == true),
        MenuItem(title: "Supplier Payment", index: 12, requiredPermission: (permissions) => permissions?.suppliers?.view == true),
      ],
      requiredPermission: (permissions) => permissions?.suppliers?.view == true,
    ),
    MenuSection(
      title: "Expense",
      items: [
        MenuItem(title: "Expense List", index: 13, requiredPermission: (permissions) => permissions?.expense?.view == true),
        MenuItem(title: "Expense Head", index: 14, requiredPermission: (permissions) => permissions?.expense?.view == true),
        MenuItem(title: "Expense Sub Head", index: 15, requiredPermission: (permissions) => permissions?.expense?.view == true),
      ],
      requiredPermission: (permissions) => permissions?.expense?.view == true,
    ),
    MenuSection(
      title: "Return",
      items: [
        MenuItem(title: "Sales Return", index: 16, requiredPermission: (permissions) => permissions?.permissionsReturn?.view == true),
        MenuItem(title: "Bad Stock List", index: 17, requiredPermission: (permissions) => permissions?.permissionsReturn?.view == true),
        MenuItem(title: "Purchase Return", index: 18, requiredPermission: (permissions) => permissions?.permissionsReturn?.view == true),
      ],
      requiredPermission: (permissions) => permissions?.permissionsReturn?.view == true,
    ),
    MenuSection(
      title: "Reports",
      items: [
        MenuItem(title: "Sales Report", index: 19, requiredPermission: (permissions) => permissions?.reports?.view == true),
        MenuItem(title: "Purchase Report", index: 20, requiredPermission: (permissions) => permissions?.reports?.view == true),
        MenuItem(title: "Profit/Loss Report", index: 21, requiredPermission: (permissions) => permissions?.reports?.view == true),
        MenuItem(title: "Top Sale Product Report", index: 22, requiredPermission: (permissions) => permissions?.reports?.view == true),
        MenuItem(title: "Low Stock Product Report", index: 23, requiredPermission: (permissions) => permissions?.reports?.view == true),
        MenuItem(title: "Stock Product Report", index: 24, requiredPermission: (permissions) => permissions?.reports?.view == true),
        MenuItem(title: "Customer Ledger", index: 25, requiredPermission: (permissions) => permissions?.reports?.view == true),
        MenuItem(title: "Customer Due/Advance Report", index: 26, requiredPermission: (permissions) => permissions?.reports?.view == true),
        MenuItem(title: "Supplier Ledger", index: 27, requiredPermission: (permissions) => permissions?.reports?.view == true),
        MenuItem(title: "Supplier Due/Advance Report", index: 28, requiredPermission: (permissions) => permissions?.reports?.view == true),
        MenuItem(title: "Expense Report", index: 29, requiredPermission: (permissions) => permissions?.reports?.view == true),
        MenuItem(title: "Bad Stock Report", index: 30, requiredPermission: (permissions) => permissions?.reports?.view == true),
      ],
      requiredPermission: (permissions) => permissions?.reports?.view == true,
    ),
    MenuSection(
      title: "Administration",
      items: [
        MenuItem(title: "Staff", index: 31, requiredPermission: (permissions) => permissions?.users?.view == true),
        MenuItem(title: "Source", index: 32, requiredPermission: (permissions) => permissions?.administration?.view == true),
        MenuItem(title: "Unit", index: 33, requiredPermission: (permissions) => permissions?.administration?.view == true),
        MenuItem(title: "Brand", index: 34, requiredPermission: (permissions) => permissions?.administration?.view == true),
        MenuItem(title: "Category", index: 35, requiredPermission: (permissions) => permissions?.administration?.view == true),
        MenuItem(title: "Group", index: 36, requiredPermission: (permissions) => permissions?.administration?.view == true),
        MenuItem(title: "Profile", index: 37, requiredPermission: (permissions) => permissions?.administration?.view == true),
      ],
      requiredPermission: (permissions) => permissions?.administration?.view == true,
    ),
    MenuSection(
      title: "Transfer Balance",
      items: [
        MenuItem(title: "Account Transfer From", index: 38, requiredPermission: (permissions) => permissions?.accounts?.view == true),
        MenuItem(title: "Account Transfer List", index: 39, requiredPermission: (permissions) => permissions?.accounts?.view == true),
        MenuItem(title: "Translation", index: 40, requiredPermission: (permissions) => permissions?.accounts?.view == true),
      ],
      requiredPermission: (permissions) => permissions?.accounts?.view == true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, dashboardState) {
        final bloc = context.read<DashboardBloc>();
        int currentIndex = 0;

        if (dashboardState is DashboardScreenChanged) {
          currentIndex = dashboardState.index;
        }

        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            // Get permissions from ProfileBloc
            final permissions = profileState is ProfilePermissionSuccess
                ? profileState.permissionData.data?.permissions
                : null;

            // Show loading state
            if (profileState is ProfilePermissionLoading || permissions == null) {
              return _buildSkeletonLoading(context, currentIndex, bloc);
            }

            // Show error state
            if (profileState is ProfilePermissionFailed) {
              return _buildErrorState(context);
            }

            // Filter menu sections based on permissions
            final filteredMenuSections = _fullMenuSections.where((section) {
              return section.requiredPermission(permissions) == true;
            }).toList();

            // If no sections available after filtering
            if (filteredMenuSections.isEmpty) {
              return _buildNoAccessState(context);
            }

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height,
                maxWidth: MediaQuery.of(context).size.width * 0.30,
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

                            // Build filtered menu sections dynamically
                            ...filteredMenuSections.map((section) {
                              // Filter items within section based on individual permissions
                              final filteredItems = section.items.where((item) {
                                return item.requiredPermission == null ||
                                    item.requiredPermission!(permissions) == true;
                              }).toList();

                              // Skip section if no items after filtering
                              if (filteredItems.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              if (filteredItems.length == 1) {
                                // Single item (no expansion)
                                final item = filteredItems.first;
                                return MenuTile(
                                  isSubmenu: true,
                                  title: section.title,
                                  isSelected: currentIndex == item.index,
                                  onPressed: () {
                                    _handleMenuSelection(bloc, item.index, context, permissions);
                                  },
                                );
                              } else {
                                // Multiple items (with expansion)
                                return ExpansionTile(
                                  initiallyExpanded: filteredItems.any((item) => currentIndex == item.index),
                                  title: Text(
                                    section.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).textTheme.bodyMedium!.color,
                                    ),
                                  ),
                                  children: filteredItems.map((item) {
                                    return MenuTile(
                                      isSubmenu: true,
                                      title: item.title,
                                      isSelected: currentIndex == item.index,
                                      onPressed: () {
                                        _handleMenuSelection(bloc, item.index, context, permissions);
                                      },
                                    );
                                  }).toList(),
                                );
                              }
                            }).toList(),
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
      },
    );
  }

  Widget _buildSkeletonLoading(BuildContext context, int currentIndex, DashboardBloc bloc) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
        maxWidth: MediaQuery.of(context).size.width * 0.30,
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
                    // Skeleton header
                    DrawerHeader(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.all(0),
                      child: Center(
                        child: Container(
                          width: 120,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),

                    // Skeleton menu items
                    for (int i = 0; i < 5; i++)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 20,
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
        maxWidth: MediaQuery.of(context).size.width * 0.30,
      ),
      child: Drawer(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Failed to load permissions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please try again later",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoAccessState(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
        maxWidth: MediaQuery.of(context).size.width * 0.30,
      ),
      child: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              gapH16,
              SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Access",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "You don't have permission to access any features.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Please contact your administrator.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuSelection(
      DashboardBloc bloc,
      int index,
      BuildContext context,
      Permissions permissions,
      ) {
    // Check if user has permission for this specific action
    final menuItem = _getMenuItemByIndex(index);
    if (menuItem != null &&
        menuItem.requiredPermission != null &&
        !menuItem.requiredPermission!(permissions)) {
      // Show permission denied message
      _showPermissionDeniedDialog(context);
      return;
    }

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

  MenuItem? _getMenuItemByIndex(int index) {
    for (final section in _fullMenuSections) {
      for (final item in section.items) {
        if (item.index == index) {
          return item;
        }
      }
    }
    return null;
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Access Denied"),
          content: const Text("You don't have permission to access this feature."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

// Helper classes for menu structure
class MenuSection {
  final String title;
  final List<MenuItem> items;
  final bool Function(Permissions? permissions) requiredPermission;

  MenuSection({
    required this.title,
    required this.items,
    required this.requiredPermission,
  });
}

class MenuItem {
  final String title;
  final int index;
  final bool Function(Permissions? permissions)? requiredPermission;

  MenuItem({
    required this.title,
    required this.index,
    this.requiredPermission,
  });
}