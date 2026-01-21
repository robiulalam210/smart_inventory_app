import 'package:meherinMart/feature/auth/presentation/pages/mobile_login_scr.dart';
import 'package:meherinMart/feature/expense/expense_head/presentation/pages/mobile_expense_head_screen.dart';
import 'package:meherinMart/feature/expense/expense_sub_head/presentation/pages/mobile_expense_sub_head_screen.dart';
import 'package:meherinMart/feature/expense/presentation/pages/mobile_expense_list_screen.dart';
import 'package:meherinMart/feature/products/brand/presentation/pages/mobile_brand_screen.dart';
import 'package:meherinMart/feature/products/categories/presentation/pages/mobile_categories_screen.dart';
import 'package:meherinMart/feature/products/groups/presentation/pages/mobile_groups_screen.dart';
import 'package:meherinMart/feature/products/soruce/presentation/pages/mobile_source_screen.dart';
import 'package:meherinMart/feature/products/unit/presentation/pages/mobile_unit_screen.dart';
import 'package:meherinMart/feature/profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import 'package:meherinMart/feature/sales/presentation/pages/mobile_pos_sale_screen.dart';

import '../../../../feature/account_transfer/presentation/screen/mobile_account_transfer_form.dart';
import '../../../../feature/account_transfer/presentation/screen/mobile_account_transfer_screen.dart';
import '../../../../feature/accounts/presentation/pages/mobile_account_screen.dart';
import '../../../../feature/customer/presentation/pages/mobile_customer_screen.dart';
import '../../../../feature/lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../../../feature/money_receipt/presentation/page/mobile_monery_receipt_create.dart';
import '../../../../feature/money_receipt/presentation/page/mobile_money_receipt_list.dart';
import '../../../../feature/products/product/presentation/pages/mobile_product_screen.dart';
import '../../../../feature/profile/data/model/profile_perrmission_model.dart';
import '../../../../feature/profile/presentation/pages/moble_profile_screen.dart';
import '../../../../feature/purchase/presentation/page/mobile_create_purchase_screen.dart';
import '../../../../feature/purchase/presentation/page/mobile_purchase_screen.dart';
import '../../../../feature/report/presentation/page/customer_due_advance_screen/mobile_customer_due_advance_screen.dart';
import '../../../../feature/report/presentation/page/customer_ledger_screen/mobile_customer_ledger_screen.dart';
import '../../../../feature/report/presentation/page/expense_report_screen/mobile_expense_report_screen.dart';
import '../../../../feature/report/presentation/page/low_stock_screen/mobile_low_stock_screen.dart';
import '../../../../feature/report/presentation/page/profit_loss_screen/mobile_profit_loss_screen.dart';
import '../../../../feature/report/presentation/page/purchase_report_screen/mobile_purchase_report_screen.dart';
import '../../../../feature/report/presentation/page/sales_report_page/mobile_sales_report_screen.dart';
import '../../../../feature/report/presentation/page/stock_report_screen/mobile_stock_report_screen.dart';
import '../../../../feature/report/presentation/page/supplier_due_advance_screen/mobile_supplier_due_advance_screen.dart';
import '../../../../feature/report/presentation/page/supplier_ledger_screen/mobile_supplier_ledger_screen.dart';
import '../../../../feature/report/presentation/page/top_products_screen/mobile_top_products_screen.dart';
import '../../../../feature/return/bad_stock/mobile_bad_stock_screen.dart';
import '../../../../feature/return/purchase_return/presentation/purchase_return/mobile_purchase_return_screen.dart';
import '../../../../feature/return/sales_return/presentation/page/mobile_sales_return_page.dart';
import '../../../../feature/sales/presentation/pages/create_pos_sale/mobile_create_pos_sale.dart';
import '../../../../feature/sales/presentation/pages/create_pos_sale/mobile_create_sales_pos.dart';
import '../../../../feature/supplier/presentation/pages/mobile_supplier_list_screen.dart';
import '../../../../feature/supplier/presentation/pages/mobile_supplier_payment_list_screen.dart';
import '../../../../feature/transactions/presentation/pages/mobile_transaction_screen.dart';
import '../../../../feature/users_list/presentation/pages/moblie_users_screen.dart';
import '../../../configs/configs.dart';
import 'menu_tile.dart';

class MobileTabSidebar extends StatelessWidget {
  const MobileTabSidebar({super.key});

  // Same menu structure as Sidebar for consistency
  List<MenuSection> getMenuSections(Permissions? permissions) {
    final sections = <MenuSection>[];

    // Dashboard Section
    if (permissions?.dashboard?.view == true) {
      sections.add(
        MenuSection(
          title: "My Dashboard",
          items: [MenuItem(title: "My Dashboard", index: 0)],
        ),
      );
    }

    // Sales Section
    if (permissions?.sales?.view == true) {
      sections.add(
        MenuSection(
          title: "Sales",
          items: [
            if (permissions?.sales?.create == true)
              MenuItem(title: "Sale", index: 1),
            if (permissions?.sales?.create == true)
              MenuItem(title: "Pos Sale", index: 2),
            if (permissions?.sales?.view == true)
              MenuItem(title: "Sale List", index: 3),
          ],
        ),
      );
    }

    // Money Receipt Section
    if (permissions?.moneyReceipt?.view == true) {
      sections.add(
        MenuSection(
          title: "Money Receipt",
          items: [
            if (permissions?.moneyReceipt?.create == true)
              MenuItem(title: "Create Money Receipt", index: 4),
            if (permissions?.moneyReceipt?.view == true)
              MenuItem(title: "Money Receipt", index: 5),
          ],
        ),
      );
    }

    // Purchase Section
    if (permissions?.purchases?.view == true) {
      sections.add(
        MenuSection(
          title: "Purchase",
          items: [
            if (permissions?.purchases?.create == true)
              MenuItem(title: "Create Purchase", index: 6),
            if (permissions?.purchases?.view == true)
              MenuItem(title: "Purchase List", index: 7),
          ],
        ),
      );
    }

    // Products Section
    if (permissions?.products?.view == true) {
      sections.add(
        MenuSection(
          title: "Products",
          items: [MenuItem(title: "Product", index: 8)],
        ),
      );
    }

    // Accounts Section
    if (permissions?.accounts?.view == true) {
      sections.add(
        MenuSection(
          title: "Accounts",
          items: [MenuItem(title: "Accounts", index: 9)],
        ),
      );
    }

    // Customers Section
    if (permissions?.customers?.view == true) {
      sections.add(
        MenuSection(
          title: "Customers",
          items: [MenuItem(title: "Customer", index: 10)],
        ),
      );
    }

    // Supplier Section
    if (permissions?.suppliers?.view == true) {
      sections.add(
        MenuSection(
          title: "Supplier",
          items: [
            if (permissions?.suppliers?.view == true)
              MenuItem(title: "Supplier List", index: 11),
            if (permissions?.suppliers?.view == true)
              MenuItem(title: "Supplier Payment", index: 12),
          ],
        ),
      );
    }

    // Expense Section
    if (permissions?.expense?.view == true) {
      sections.add(
        MenuSection(
          title: "Expense",
          items: [
            if (permissions?.expense?.view == true)
              MenuItem(title: "Expense List", index: 13),
            if (permissions?.expense?.view == true)
              MenuItem(title: "Expense Head", index: 14),
            if (permissions?.expense?.view == true)
              MenuItem(title: "Expense Sub Head", index: 15),
          ],
        ),
      );
    }

    // Return Section
    if (permissions?.permissionsReturn?.view == true) {
      sections.add(
        MenuSection(
          title: "Return",
          items: [
            if (permissions?.permissionsReturn?.view == true)
              MenuItem(title: "Sales Return", index: 16),
            if (permissions?.permissionsReturn?.view == true)
              MenuItem(title: "Bad Stock List", index: 17),
            if (permissions?.permissionsReturn?.view == true)
              MenuItem(title: "Purchase Return", index: 18),
          ],
        ),
      );
    }

    // Reports Section
    if (permissions?.reports?.view == true) {
      sections.add(
        MenuSection(
          title: "Reports",
          items: [
            if (permissions?.reports?.view == true)
              MenuItem(title: "Sales Report", index: 19),
            if (permissions?.reports?.view == true)
              MenuItem(title: "Purchase Report", index: 20),
            if (permissions?.reports?.view == true)
              MenuItem(title: "Profit/Loss Report", index: 21),
            if (permissions?.reports?.view == true)
              MenuItem(title: "Top Sale Product Report", index: 22),
            if (permissions?.reports?.view == true)
              MenuItem(title: "Low Stock Product Report", index: 23),
            if (permissions?.reports?.view == true)
              MenuItem(title: "Stock Product Report", index: 24),
            if (permissions?.reports?.view == true)
              MenuItem(title: "Customer Ledger", index: 25),
            if (permissions?.reports?.view == true)
              MenuItem(title: "Customer Due/Advance Report", index: 26),
            if (permissions?.reports?.view == true)
              MenuItem(title: "Supplier Ledger", index: 27),
            if (permissions?.reports?.view == true)
              MenuItem(title: "Supplier Due/Advance Report", index: 28),
            if (permissions?.reports?.view == true)
              MenuItem(title: "Expense Report", index: 29),
            if (permissions?.reports?.view == true)
              MenuItem(title: "Bad Stock Report", index: 30),
          ],
        ),
      );
    }

    // Administration Section
    if (permissions?.administration?.view == true) {
      sections.add(
        MenuSection(
          title: "Administration",
          items: [
            if (permissions?.users?.view == true)
              MenuItem(title: "Staff", index: 31),
            MenuItem(title: "Source", index: 32),
            MenuItem(title: "Unit", index: 33),
            MenuItem(title: "Brand", index: 34),
            MenuItem(title: "Category", index: 35),
            MenuItem(title: "Group", index: 36),
            MenuItem(title: "Profile", index: 37),
          ],
        ),
      );
    }

    // Transfer Balance Section (assuming it's under accounts)
    if (permissions?.accounts?.view == true) {
      sections.add(
        MenuSection(
          title: "Transfer Balance",
          items: [
            MenuItem(title: "Account Transfer From", index: 38),
            MenuItem(title: "Account Transfer List", index: 39),
            MenuItem(title: "Translation", index: 40),
          ],
        ),
      );
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.bottomNavBg(context),
      child: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            int currentIndex = 0;

            if (state is DashboardScreenChanged) {
              currentIndex = state.index;
            }

            final permission = context.read<ProfileBloc>().permissionModel?.data?.permissions;

            // Get dynamic menu sections based on permissions
            final menuSections = getMenuSections(permission);

            // Show empty state if no permissions
            if (menuSections.isEmpty) {
              return Center(
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
                      "No Menu Access",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Contact administrator for access",
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [

                /// Drawer Header
                DrawerHeader(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bottomNavBg(context),
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
                            color: AppColors.text(context),
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
                        if (section.items.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        if (section.items.length == 1) {
                          // Single item (no expansion)
                          final item = section.items.first;
                          return MenuTile(
                            isSubmenu: true,
                            title: section.title,
                            isSelected: currentIndex == item.index,
                            onPressed: () {
                              _handleMenuSelection(item.index, context, permission);
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
                                color: AppColors.text(context),
                              ),
                            ),
                            children: section.items.map((item) {
                              return MenuTile(
                                isSubmenu: true,
                                title: item.title,
                                isSelected: currentIndex == item.index,
                                onPressed: () {
                                  _handleMenuSelection(item.index, context, permission);
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

  void _handleMenuSelection(int index, BuildContext context, Permissions? permissions) {
    // Check permissions before navigation
    switch (index) {
      case 0: // Dashboard
        if (permissions?.dashboard?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.pop(context);
        break;

      case 1: // Sale (Create)
        if (permissions?.sales?.create != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileCreatePosSale());
        break;

      case 2: // Pos Sale
        if (permissions?.sales?.create != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileSalesScreen());
        break;

      case 3: // Sale List
        if (permissions?.sales?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobilePosSaleScreen());
        break;

      case 4: // Create Money Receipt
        if (permissions?.moneyReceipt?.create != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileMoneyReceiptForm());
        break;

      case 5: // Money Receipt List
        if (permissions?.moneyReceipt?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileMoneyReceiptList());
        break;

      case 6: // Create Purchase
        if (permissions?.purchases?.create != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileCreatePurchaseScreen());
        break;

      case 7: // Purchase List
        if (permissions?.purchases?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobilePurchaseScreen());
        break;

      case 8: // Product
        if (permissions?.products?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileProductScreen());
        break;

      case 9: // Accounts
        if (permissions?.accounts?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileAccountScreen());
        break;

      case 10: // Customer
        if (permissions?.customers?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileCustomerScreen());
        break;

      case 11: // Supplier List
        if (permissions?.suppliers?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileSupplierListScreen());
        break;

      case 12: // Supplier Payment
        if (permissions?.suppliers?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileSupplierPaymentListScreen());
        break;

      case 13: // Expense List
        if (permissions?.expense?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileExpenseListScreen());
        break;

      case 14: // Expense Head
        if (permissions?.expense?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileExpenseHeadScreen());
        break;

      case 15: // Expense Sub Head
        if (permissions?.expense?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileExpenseSubHeadScreen());
        break;

      case 16: // Sales Return
        if (permissions?.permissionsReturn?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileSalesReturnPage());
        break;

      case 17: // Bad Stock List
        if (permissions?.permissionsReturn?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileBadStockScreen());
        break;

      case 18: // Purchase Return
        if (permissions?.permissionsReturn?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobilePurchaseReturnScreen());
        break;

      case 19: // Sales Report
        if (permissions?.reports?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileSalesReportScreen());
        break;

      case 20: // Purchase Report
        if (permissions?.reports?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobilePurchaseReportScreen());
        break;

      case 21: // Profit/Loss Report
        if (permissions?.reports?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileProfitLossScreen());
        break;

      case 22: // Top Sale Product Report
        if (permissions?.reports?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileTopProductsScreen());
        break;

      case 23: // Low Stock Product Report
        if (permissions?.reports?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileLowStockScreen());
        break;

      case 24: // Stock Product Report
        if (permissions?.reports?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileStockReportScreen());
        break;

      case 25: // Customer Ledger
        if (permissions?.reports?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileCustomerLedgerScreen());
        break;

      case 26: // Customer Due/Advance Report
        if (permissions?.reports?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileCustomerDueAdvanceScreen());
        break;

      case 27: // Supplier Ledger
        if (permissions?.reports?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileSupplierLedgerScreen());
        break;

      case 28: // Supplier Due/Advance Report
        if (permissions?.reports?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileSupplierDueAdvanceScreen());
        break;

      case 29: // Expense Report
        if (permissions?.reports?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileExpenseReportScreen());
        break;

      case 30: // Bad Stock Report
        if (permissions?.reports?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileBadStockScreen());
        break;

      case 31: // Staff
        if (permissions?.users?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MoblieUsersScreen());
        break;

      case 32: // Source
        if (permissions?.administration?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileSourceScreen());
        break;

      case 33: // Unit
        if (permissions?.administration?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileUnitScreen());
        break;

      case 34: // Brand
        if (permissions?.administration?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileBrandScreen());
        break;

      case 35: // Category
        if (permissions?.administration?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileCategoriesScreen());
        break;

      case 36: // Group
        if (permissions?.administration?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileGroupsScreen());
        break;

      case 37: // Profile
        if (permissions?.administration?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileProfileScreen());
        break;

      case 38: // Account Transfer From
        if (permissions?.accounts?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileAccountTransferForm());
        break;

      case 39: // Account Transfer List
        if (permissions?.accounts?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileAccountTransferScreen());
        break;

      case 40: // Translation
        if (permissions?.accounts?.view != true) {
          _showPermissionDeniedDialog(context);
          return;
        }
        AppRoutes.push(context, MobileTransactionScreen());
        break;

      default:
      // Fallback: do nothing or show a snack bar
        break;
    }
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
                  MaterialPageRoute(builder: (context) => MobileLoginScr()),
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
}// Helper classes for menu structure
class MenuSection {
  final String title;
  final List<MenuItem> items;
  final bool Function(Permissions? permissions)? requiredPermission;

  MenuSection({
    required this.title,
    required this.items,
    this.requiredPermission,
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