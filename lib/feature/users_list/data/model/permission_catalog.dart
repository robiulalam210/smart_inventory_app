import 'package:flutter/material.dart';

/// Permission editor এর "মানচিত্র" — কোন module এ কোন action আছে, কোন group এ বসবে,
/// আর screen এ কী নাম/icon/রং দেখাবে।
///
/// Key গুলো backend এর `User.get_permissions()` / `_get_permission_mapping()` এর সাথে
/// হুবহু মিলতে হবে — নতুন module যোগ হলে দুই জায়গাতেই যোগ করতে হবে।

class PermissionActionDef {
  final String key; // backend key: view / create / edit / delete / create_pos / create_short / export
  final String label;
  final IconData icon;
  final Color color;

  const PermissionActionDef(this.key, this.label, this.icon, this.color);
}

class PermissionModuleDef {
  final String key;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final List<PermissionActionDef> actions;

  const PermissionModuleDef({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.actions,
  });
}

class PermissionGroupDef {
  final String title;
  final String subtitle;
  final List<PermissionModuleDef> modules;

  const PermissionGroupDef(this.title, this.subtitle, this.modules);
}

class PermissionCatalog {
  PermissionCatalog._();

  // ── Action গুলো (রং দেখে এক নজরে বোঝা যায়: দেখা=নীল, তৈরি=সবুজ, এডিট=কমলা, ডিলিট=লাল)
  static const view = PermissionActionDef('view', 'View', Icons.visibility_outlined, Color(0xFF2563EB));
  static const create = PermissionActionDef('create', 'Add', Icons.add_circle_outline_rounded, Color(0xFF16A34A));
  static const edit = PermissionActionDef('edit', 'Edit', Icons.edit_outlined, Color(0xFFF59E0B));
  static const delete = PermissionActionDef('delete', 'Delete', Icons.delete_outline_rounded, Color(0xFFDC2626));
  static const createPos = PermissionActionDef('create_pos', 'POS Sale', Icons.point_of_sale_rounded, Color(0xFF7C3AED));
  static const createShort = PermissionActionDef('create_short', 'Quick Sale', Icons.bolt_rounded, Color(0xFF0891B2));
  static const export = PermissionActionDef('export', 'Export', Icons.file_download_outlined, Color(0xFF0D9488));

  static const _crud = [view, create, edit, delete];

  static const List<PermissionGroupDef> groups = [
    PermissionGroupDef('Overview', 'Home screen and business summary', [
      PermissionModuleDef(
        key: 'dashboard',
        label: 'Dashboard',
        description: 'Sales, profit and money summary',
        icon: Icons.space_dashboard_outlined,
        color: Color(0xFF2563EB),
        actions: [PermissionActionDef('view', 'Access', Icons.visibility_outlined, Color(0xFF2563EB))],
      ),
    ]),
    PermissionGroupDef('Sales & Collection', 'Selling, receiving money and returns', [
      PermissionModuleDef(
        key: 'sales',
        label: 'Sales',
        description: 'Invoices and sale list',
        icon: Icons.shopping_cart_outlined,
        color: Color(0xFF16A34A),
        actions: [view, create, createPos, createShort, edit, delete],
      ),
      PermissionModuleDef(
        key: 'money_receipt',
        label: 'Money receipts',
        description: 'Collecting customer dues',
        icon: Icons.receipt_long_outlined,
        color: Color(0xFF0891B2),
        actions: _crud,
      ),
      PermissionModuleDef(
        key: 'return',
        label: 'Returns',
        description: 'Sales return, purchase return and bad stock',
        icon: Icons.assignment_return_outlined,
        color: Color(0xFFEA580C),
        actions: _crud,
      ),
    ]),
    PermissionGroupDef('Purchase & Inventory', 'Buying stock and managing products', [
      PermissionModuleDef(
        key: 'purchases',
        label: 'Purchases',
        description: 'Purchase invoices and supplier payments',
        icon: Icons.local_shipping_outlined,
        color: Color(0xFF7C3AED),
        actions: _crud,
      ),
      PermissionModuleDef(
        key: 'products',
        label: 'Products & stock',
        description: 'Products, category, brand, unit and price',
        icon: Icons.inventory_2_outlined,
        color: Color(0xFFDB2777),
        actions: _crud,
      ),
      PermissionModuleDef(
        key: 'suppliers',
        label: 'Suppliers',
        description: 'Including supplier payments',
        icon: Icons.storefront_outlined,
        color: Color(0xFF9333EA),
        actions: _crud,
      ),
    ]),
    PermissionGroupDef('Customers & Finance', 'People you sell to and where money moves', [
      PermissionModuleDef(
        key: 'customers',
        label: 'Customers',
        description: 'Customer list and their details',
        icon: Icons.people_alt_outlined,
        color: Color(0xFF0EA5E9),
        actions: _crud,
      ),
      PermissionModuleDef(
        key: 'accounts',
        label: 'Accounts',
        description: 'Cash, bank, transfers, income',
        icon: Icons.account_balance_wallet_outlined,
        color: Color(0xFF059669),
        actions: _crud,
      ),
      PermissionModuleDef(
        key: 'expense',
        label: 'Expenses',
        description: 'Daily expenses and their heads',
        icon: Icons.payments_outlined,
        color: Color(0xFFDC2626),
        actions: _crud,
      ),
    ]),
    PermissionGroupDef('Reports', 'Business reports and exporting', [
      PermissionModuleDef(
        key: 'reports',
        label: 'Reports',
        description: 'Sales, purchase, stock, ledger and profit reports',
        icon: Icons.bar_chart_rounded,
        color: Color(0xFF0D9488),
        actions: [view, export],
      ),
    ]),
    PermissionGroupDef('System & Administration', 'Staff, business setup and settings', [
      PermissionModuleDef(
        key: 'users',
        label: 'Staff',
        description: 'Adding and changing people',
        icon: Icons.manage_accounts_outlined,
        color: Color(0xFF4F46E5),
        actions: _crud,
      ),
      PermissionModuleDef(
        key: 'administration',
        label: 'Setup',
        description: 'Units, categories, brands, business profile',
        icon: Icons.admin_panel_settings_outlined,
        color: Color(0xFF475569),
        actions: _crud,
      ),
      PermissionModuleDef(
        key: 'settings',
        label: 'Settings',
        description: 'App and print settings',
        icon: Icons.settings_outlined,
        color: Color(0xFF64748B),
        actions: [view, edit],
      ),
    ]),
  ];

  static Iterable<PermissionModuleDef> get allModules => groups.expand((g) => g.modules);

  static int get totalActions => allModules.fold(0, (sum, m) => sum + m.actions.length);
}
