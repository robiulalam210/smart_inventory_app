import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// কোন platform এ offline mode চলবে, আর কোন data / API offline এ কাজ করবে।
///
/// - Mobile (Android/iOS): সবসময় full online — কোনো local database নেই।
/// - Desktop (Windows/macOS/Linux): online + offline দুটোই।
///
/// Server এর `offline_sync/registry.py` এর সাথে এই list মিলিয়ে রাখতে হবে।
class OfflineConfig {
  OfflineConfig._();

  static bool get enabled =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  /// Header এ পাঠানো হয় → server এর audit log এ দেখা যায় কোন app থেকে কাজটা হয়েছে
  static String get clientSource => enabled ? 'desktop' : 'mobile';

  /// প্রথম setup এ এই ক্রমে data নামবে
  static const List<String> syncOrder = [
    'category', 'unit', 'brand', 'group', 'source', 'sale_mode', 'product',
    'product_sale_mode', 'price_tier', 'customer', 'supplier', 'account', 'user',
    'expense_head', 'expense_subhead', 'income_head',
  ];

  /// Entity এর বাংলা নাম (setup screen ও Sync Center এ দেখানোর জন্য)
  static const Map<String, String> entityLabels = {
    'category': 'Category', 'unit': 'Unit', 'brand': 'Brand', 'group': 'Group',
    'source': 'Source', 'sale_mode': 'Sale Mode', 'product': 'Product',
    'product_sale_mode': 'Product Sale Mode', 'price_tier': 'Price Tier',
    'customer': 'Customer', 'supplier': 'Supplier', 'account': 'Account',
    'user': 'User', 'expense_head': 'Expense Head',
    'expense_subhead': 'Expense Sub Head', 'income_head': 'Income Head',
    'sale': 'Sale', 'purchase': 'Purchase', 'money_receipt': 'Money Receipt',
    'supplier_payment': 'Supplier Payment', 'expense': 'Expense', 'income': 'Income',
  };

  /// Offline এ GET request এলে কোন path কোন entity থেকে উত্তর পাবে।
  /// (একই data বিভিন্ন path দিয়ে আসে — active list, no_pagination ইত্যাদি)
  static const Map<String, String> readPaths = {
    '/api/categories/': 'category',
    '/api/categories/active/': 'category',
    '/api/units/': 'unit',
    '/api/units/active/': 'unit',
    '/api/brands/': 'brand',
    '/api/brands/active/': 'brand',
    '/api/groups/': 'group',
    '/api/groups/active/': 'group',
    '/api/sources/': 'source',
    '/api/sources/active/': 'source',
    '/api/sale-modes/': 'sale_mode',
    '/api/sale-modes/active/': 'sale_mode',
    '/api/price-tiers/': 'price_tier',
    '/api/product-sale-modes/': 'product_sale_mode',
    '/api/product-sale-modes/by_product/': 'product_sale_mode',
    '/api/products': 'product',
    '/api/products/': 'product',
    '/api/products/active/': 'product',
    '/api/customers/': 'customer',
    '/api/customers-active': 'customer',
    '/api/customers-active/': 'customer',
    '/api/suppliers/': 'supplier',
    '/api/suppliers-active': 'supplier',
    '/api/suppliers-active/': 'supplier',
    '/api/accounts/': 'account',
    '/api/accounts/active/': 'account',
    '/api/users/': 'user',
    '/api/expenses/expense-heads/': 'expense_head',
    '/api/expenses/expense-subheads/': 'expense_subhead',
    '/api/income/income-heads/': 'income_head',
  };

  /// Offline এ যেসব নতুন entry করা যাবে (edit/delete শুধু online এ — conflict এড়াতে)
  static const Map<String, String> writePaths = {
    '/api/customers/': 'customer',
    '/api/sales/': 'sale',
    '/api/money-receipts/': 'money_receipt',
    '/api/purchases/': 'purchase',
    '/api/supplier-payments/': 'supplier_payment',
    '/api/expenses/expenses/': 'expense',
    '/api/income/incomes/': 'income',
  };

  /// Auto sync এর সময়সূচি
  static const Duration autoSyncInterval = Duration(minutes: 2);
  static const Duration onlineProbeInterval = Duration(seconds: 20);
  static const Duration offlineProbeInterval = Duration(seconds: 8);
  static const Duration fullRefreshEvery = Duration(hours: 12);
  static const int pushBatchSize = 25;
}
