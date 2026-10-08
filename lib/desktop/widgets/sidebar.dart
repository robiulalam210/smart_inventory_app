import '../../feature/lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../feature/profile/data/model/profile_perrmission_model.dart';
import '../../feature/profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '../../core/configs/configs.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  // Define full menu structure with permission checks
  static final List<MenuSection> _fullMenuSections = [
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
        MenuItem(title: "Sale Mode", index: 43, requiredPermission: (permissions) => permissions?.administration?.view == true),
      ],
      requiredPermission: (permissions) => permissions?.administration?.view == true,
    ),
    MenuSection(
      title: "Income",
      items: [
        MenuItem(title: "Income List", index: 41, requiredPermission: (permissions) => permissions?.accounts?.view == true),
        MenuItem(title: "Income Head", index: 42, requiredPermission: (permissions) => permissions?.accounts?.view == true),
      ],
      requiredPermission: (permissions) => permissions?.accounts?.view == true,
    ),
    MenuSection(
      title: "Transfer Balance",
      items: [
        MenuItem(title: "Account Transfer Form", index: 38, requiredPermission: (permissions) => permissions?.accounts?.view == true),
        MenuItem(title: "Account Transfer List", index: 39, requiredPermission: (permissions) => permissions?.accounts?.view == true),
        MenuItem(title: "Transactions", index: 40, requiredPermission: (permissions) => permissions?.accounts?.view == true),
      ],
      requiredPermission: (permissions) => permissions?.accounts?.view == true,
    ),
  ];

  // ------------------------------------------------------------
  // UI state
  // ------------------------------------------------------------
  // একবারে একটাই group খোলা থাকে (accordion) — আগে ExpansionTile
  // ছিল, একসাথে অনেকগুলো খুলে menu অনেক লম্বা হয়ে যেত, আর খোলা group
  // এর উপরে-নিচে অদ্ভুত divider লাইন আসত।
  String? _expanded;
  int? _lastIndex;

  static const Map<String, IconData> _sectionIcons = {
    'My Dashboard': Icons.space_dashboard_outlined,
    'Sales': Icons.point_of_sale_outlined,
    'Money Receipt': Icons.receipt_long_outlined,
    'Purchase': Icons.shopping_bag_outlined,
    'Products': Icons.inventory_2_outlined,
    'Accounts': Icons.account_balance_wallet_outlined,
    'Customers': Icons.people_alt_outlined,
    'Supplier': Icons.local_shipping_outlined,
    'Expense': Icons.payments_outlined,
    'Return': Icons.assignment_return_outlined,
    'Reports': Icons.bar_chart_rounded,
    'Administration': Icons.admin_panel_settings_outlined,
    'Income': Icons.trending_up_rounded,
    'Transfer Balance': Icons.swap_horiz_rounded,
    'Security': Icons.policy_outlined,
  };

  /// current screen যে group এর, সেটা খুলে রাখা
  void _syncExpanded(int currentIndex, List<MenuSection> sections) {
    if (_lastIndex == currentIndex) return;
    _lastIndex = currentIndex;
    for (final section in sections) {
      if (section.items.length > 1 &&
          section.items.any((it) => it.index == currentIndex)) {
        _expanded = section.title;
        return;
      }
    }
  }

  Color _sidebarBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.08)
          : AppColors.borderLight;

  /// sidebar এর বাইরের খোলস — পর্দার পুরো উচ্চতা জুড়ে, ডানে পাতলা border।
  /// আগে Drawer widget ব্যবহার হতো (নিজস্ব রং, গোল কোণা, shadow) আর
  /// উচ্চতা ছিল "পর্দা − 100" — তাই নিচে ফাঁকা থাকত বা শেষের item কেটে যেত।
  Widget _shell(BuildContext context, Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height - 64;
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.bottomNavBg(context),
            border: Border(right: BorderSide(color: _sidebarBorder(context))),
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, dashboardState) {
        final bloc = context.read<DashboardBloc>();
        int currentIndex = _lastIndex ?? 0;

        if (dashboardState is DashboardScreenChanged) {
          currentIndex = dashboardState.index;
        }

        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            final permissions = profileState is ProfilePermissionSuccess
                ? profileState.permissionData.data?.permissions
                : null;

            if (profileState is ProfilePermissionFailed) {
              return _buildErrorState(context);
            }
            if (profileState is ProfilePermissionLoading || permissions == null) {
              return _buildSkeletonLoading(context, currentIndex, bloc);
            }

            // permission অনুযায়ী section ও item ছাঁটাই
            final sections = <MenuSection>[];
            for (final section in _fullMenuSections) {
              if (section.requiredPermission(permissions) != true) continue;
              final items = section.items
                  .where((item) =>
                      item.requiredPermission == null ||
                      item.requiredPermission!(permissions) == true)
                  .toList();
              if (items.isEmpty) continue;
              sections.add(MenuSection(
                title: section.title,
                items: items,
                requiredPermission: section.requiredPermission,
              ));
            }

            // Audit Log — module permission নয়, role দেখে (শুধু Super Admin / Admin)
            final role = (profileState is ProfilePermissionSuccess
                    ? profileState.permissionData.data?.user?.role
                    : null)
                ?.toUpperCase();
            if (role == 'SUPER_ADMIN' || role == 'ADMIN') {
              sections.add(MenuSection(
                title: 'Security',
                items: [MenuItem(title: 'Audit Log', index: 44)],
                requiredPermission: (_) => true,
              ));
            }

            if (sections.isEmpty) {
              return _buildNoAccessState(context);
            }

            _syncExpanded(currentIndex, sections);

            return _shell(
              context,
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
                      children: [
                        for (final section in sections)
                          _buildSection(
                            context,
                            section,
                            currentIndex,
                            onSelect: (index) => _handleMenuSelection(
                                bloc, index, context, permissions),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    MenuSection section,
    int currentIndex, {
    required ValueChanged<int> onSelect,
  }) {
    final IconData icon = _sectionIcons[section.title] ?? Icons.circle_outlined;

    // এক item এর section — সরাসরি link
    if (section.items.length == 1) {
      final item = section.items.first;
      return _SidebarTile(
        icon: icon,
        title: section.title,
        selected: currentIndex == item.index,
        onTap: () => onSelect(item.index),
      );
    }

    final bool open = _expanded == section.title;
    final bool hasActive = section.items.any((it) => it.index == currentIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SidebarTile(
          icon: icon,
          title: section.title,
          // group এর ভিতরের কোনো screen চালু থাকলে group এর লেখা রঙিন,
          // কিন্তু পটভূমি নয় — পটভূমি শুধু আসল চালু item এর
          highlightText: hasActive,
          trailing: AnimatedRotation(
            turns: open ? 0.5 : 0,
            duration: const Duration(milliseconds: 180),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.text(context).withValues(alpha: 0.5),
            ),
          ),
          onTap: () => setState(() {
            _expanded = open ? null : section.title;
          }),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: open
              ? Container(
                  // বাঁয়ে পাতলা guide line — কোন item কোন group এর বোঝা যায়
                  margin: const EdgeInsets.only(left: 22, top: 2, bottom: 4),
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: _sidebarBorder(context), width: 1.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final item in section.items)
                        _SidebarTile(
                          title: item.title,
                          dense: true,
                          selected: currentIndex == item.index,
                          onTap: () => onSelect(item.index),
                        ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildSkeletonLoading(BuildContext context, int currentIndex, DashboardBloc bloc) {
    return _shell(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          for (int i = 0; i < 8; i++)
            Container(
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return _shell(
      context,
      Material(
        color: Colors.transparent,
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
    return _shell(
      context,
      Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              gapH16,
              SizedBox(
                height: MediaQuery.of(context).size.height - 140,
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

    // FIX: Income List / Income Head / Sale Mode আগে আলাদা page হিসেবে খুলত (sidebar ছাড়া)।
    // এখন অন্য সব screen এর মতো sidebar সহ main area তে খোলে (dashboard_bloc এর index 41-43)।
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
    showAppPopover(
      context: context,
      builder: (BuildContext context) {
        return AppPopoverCard(
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

/// sidebar এর একটা সারি — hover এ হালকা রং, চালু থাকলে primary রঙের
/// পটভূমি আর বাঁয়ে ছোট accent দাগ
class _SidebarTile extends StatefulWidget {
  const _SidebarTile({
    required this.title,
    required this.onTap,
    this.icon,
    this.selected = false,
    this.highlightText = false,
    this.dense = false,
    this.trailing,
  });

  final String title;
  final VoidCallback onTap;
  final IconData? icon;
  final bool selected;
  final bool highlightText;
  final bool dense;
  final Widget? trailing;

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final Color primary = AppColors.primaryColor(context);
    final Color text = AppColors.text(context);
    final bool active = widget.selected;
    final Color fg = active || widget.highlightText
        ? primary
        : text.withValues(alpha: widget.dense ? 0.72 : 0.85);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: widget.dense ? 36 : 42,
            padding: EdgeInsets.only(left: widget.dense ? 10 : 12, right: 8),
            decoration: BoxDecoration(
              color: active
                  ? primary.withValues(alpha: 0.10)
                  : _hover
                      ? text.withValues(alpha: 0.04)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 19, color: fg),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: widget.dense ? 13 : 14,
                      fontWeight: active || widget.highlightText
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ============================================================
// PAGE INFO — কোন index এ কোন page, কোন group এর
// ------------------------------------------------------------
// উপরের Header এই তথ্য দিয়ে "Sales › Sale List" breadcrumb আর page এর
// নাম দেখায়। menu এর তালিকা একটাই (_fullMenuSections) — sidebar আর
// header দুজনেই সেখান থেকে পড়ে, তাই নাম কখনো অমিল হবে না।
// ============================================================

class SidebarPageInfo {
  const SidebarPageInfo({
    required this.title,
    required this.section,
    required this.icon,
  });

  final String title;

  /// group এর নাম — একক page হলে null (যেমন Products)
  final String? section;
  final IconData icon;
}

SidebarPageInfo sidebarPageInfo(int index) {
  for (final section in _SidebarState._fullMenuSections) {
    for (final item in section.items) {
      if (item.index != index) continue;
      final icon =
          _SidebarState._sectionIcons[section.title] ?? Icons.circle_outlined;
      if (section.items.length == 1) {
        return SidebarPageInfo(title: section.title, section: null, icon: icon);
      }
      return SidebarPageInfo(
          title: item.title, section: section.title, icon: icon);
    }
  }
  return const SidebarPageInfo(
    title: 'My Dashboard',
    section: null,
    icon: Icons.space_dashboard_outlined,
  );
}
