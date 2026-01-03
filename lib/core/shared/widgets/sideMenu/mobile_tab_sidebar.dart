import 'package:meherinMart/feature/mobile_root_screen.dart';
import 'package:meherinMart/feature/sales/presentation/pages/mobile_pos_sale_screen.dart';

import '../../../../feature/accounts/presentation/pages/account_screen.dart';
import '../../../../feature/accounts/presentation/pages/mobile_account_screen.dart';
import '../../../../feature/auth/presentation/pages/login_scr.dart';
import '../../../../feature/customer/presentation/pages/mobile_customer_screen.dart';
import '../../../../feature/lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../../../feature/money_receipt/presentation/page/mobile_monery_receipt_create.dart';
import '../../../../feature/money_receipt/presentation/page/mobile_money_receipt_list.dart';
import '../../../../feature/products/product/presentation/pages/mobile_product_screen.dart';
import '../../../../feature/purchase/presentation/page/mobile_create_purchase_screen.dart';
import '../../../../feature/purchase/presentation/page/mobile_purchase_screen.dart';
import '../../../../feature/sales/presentation/pages/create_pos_sale/mobile_create_pos_sale.dart';
import '../../../../feature/sales/presentation/pages/create_pos_sale/mobile_create_sales_pos.dart';
import '../../../../feature/supplier/presentation/pages/mobile_supplier_list_screen.dart';
import '../../../../feature/supplier/presentation/pages/mobile_supplier_payment_list_screen.dart';
import '../../../configs/configs.dart';
import 'menu_tile.dart';

class MobileTabSidebar extends StatelessWidget {
  const MobileTabSidebar({super.key});

  // Same menu structure as Sidebar for consistency
  final List<MenuSection> menuSections = const [
    MenuSection(
      title: "My Dashboard",
      items: [MenuItem(title: "My Dashboard", index: 0)],
    ),
    MenuSection(
      title: "Sales",
      items: [
        MenuItem(title: "Sale", index: 1),
        MenuItem(title: "Pos Sale", index: 2),
        MenuItem(title: "Sale List", index: 3),
      ],
    ),
    MenuSection(
      title: "Money Receipt",
      items: [
        MenuItem(title: "Create Money Receipt", index: 4),
        MenuItem(title: "Money Receipt", index: 5),
      ],
    ),
    MenuSection(
      title: "Purchase",
      items: [
        MenuItem(title: "Create Purchase", index: 6),
        MenuItem(title: "Purchase List", index: 7),
      ],
    ),
    MenuSection(
      title: "Products",
      items: [MenuItem(title: "Product", index: 8)],
    ),
    MenuSection(
      title: "Accounts",
      items: [MenuItem(title: "Accounts", index: 9)],
    ),
    MenuSection(
      title: "Customers",
      items: [MenuItem(title: "Customer", index: 10)],
    ),
    MenuSection(
      title: "Supplier",
      items: [
        MenuItem(title: "Supplier List", index: 11),
        MenuItem(title: "Supplier Payment", index: 12),
      ],
    ),
    MenuSection(
      title: "Expense",
      items: [
        MenuItem(title: "Expense List", index: 13),
        MenuItem(title: "Expense Head", index: 14),
        MenuItem(title: "Expense Sub Head", index: 15),
      ],
    ),
    MenuSection(
      title: "Return",
      items: [
        MenuItem(title: "Sales Return", index: 16),
        MenuItem(title: "Bad Stock List", index: 17),
        MenuItem(title: "Purchase Return", index: 18),
      ],
    ),
    MenuSection(
      title: "Reports",
      items: [
        MenuItem(title: "Sales Report", index: 19),
        MenuItem(title: "Purchase Report", index: 20),
        MenuItem(title: "Profit/Loss Report", index: 21),
        MenuItem(title: "Top Sale Product Report", index: 22),
        MenuItem(title: "Low Stock Product Report", index: 23),
        MenuItem(title: "Stock Product Report", index: 24),
        MenuItem(title: "Customer Ledger", index: 25),
        MenuItem(title: "Customer Due/Advance Report", index: 26),
        MenuItem(title: "Supplier Ledger", index: 27),
        MenuItem(title: "Supplier Due/Advance Report", index: 28),
        MenuItem(title: "Expense Report", index: 29),
        MenuItem(title: "Bad Stock Report", index: 30),
      ],
    ),
    MenuSection(
      title: "Administration",
      items: [
        MenuItem(title: "Staff", index: 31),
        MenuItem(title: "Source", index: 32),
        MenuItem(title: "Unit", index: 33),
        MenuItem(title: "Brand", index: 34),
        MenuItem(title: "Category", index: 35),
        MenuItem(title: "Group", index: 36),
        MenuItem(title: "Profile", index: 37),
      ],
    ),
    MenuSection(
      title: "Transfer Balance",
      items: [
        MenuItem(title: "Account Transfer From", index: 38),
        MenuItem(title: "Account Transfer List", index: 39),
        MenuItem(title: "Translation", index: 40),
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
                              _handleMenuSelection(item.index, context);
                            },
                          );
                        } else {
                          // Multiple items (with expansion)
                          return ExpansionTile(
                            initiallyExpanded: section.items.any(
                              (item) => currentIndex == item.index,
                            ),
                            title: Text(
                              section.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.color,
                              ),
                            ),
                            children: section.items.map((item) {
                              return MenuTile(
                                isSubmenu: true,
                                title: item.title,
                                isSelected: currentIndex == item.index,
                                onPressed: () {
                                  _handleMenuSelection(item.index, context);
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

  void _handleMenuSelection(int index, BuildContext context) {
    switch (index) {
      case 0: // POS Sale
        AppRoutes.pop(context);
        break;
      case 1: // Sale
        AppRoutes.push(context, MobileCreatePosSale());
        break;
      case 2: // Sale
        AppRoutes.push(context, MobileSalesScreen());
        break;
      case 3: // Sale List
        AppRoutes.push(context, MobilePosSaleScreen());
        break;

      case 4: // Sale List
        AppRoutes.push(context, MobileMoneyReceiptForm());
        break;
      case 5: // Sale List
        AppRoutes.push(context, MobileMoneyReceiptList());
        break;
      case 6: // Sale List
        AppRoutes.push(context, MobileCreatePurchaseScreen());
        break;
      case 7: // Sale List
        AppRoutes.push(context, MobilePurchaseScreen());
        break;
      case 8: // Sale List
        AppRoutes.push(context, MobileProductScreen());
        break;
      case 9: // Sale List
        AppRoutes.push(context, MobileAccountScreen());
        break;
      case 10: // Sale List
        AppRoutes.push(context, MobileCustomerScreen());
        break;
      case 11: // Sale List
        AppRoutes.push(context, MobileSupplierListScreen());
        break;
      case 12: // Sale List
        AppRoutes.push(context, MobileSupplierPaymentListScreen());
        break;
      case 13: // Sale List
        AppRoutes.push(context, MobileSupplierListScreen());
        break;
      case 14: // Sale List
        AppRoutes.push(context, MobileSupplierPaymentListScreen());
        break;

      // Add more cases for other menu items
      default:
        // Fallback: do nothing or show a snack bar
        break;
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
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
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
