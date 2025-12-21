import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
final bool isLive = true; // Set to true for production environment

// String getBaseUrl() {
//   // If you set a compile-time constant via --dart-define, prefer that:
//   // const envBaseUrl = String.fromEnvironment('BASE_URL', defaultValue: '');
//   // if (envBaseUrl.isNotEmpty) return envBaseUrl;
//
//   if (kIsWeb) {
//     return 'http://localhost:8000';
//   }
//   if (Platform.isAndroid) {
//     // Android emulator (AVD)
//     return 'http://10.0.2.2:8000';
//   }
//   if (Platform.isIOS) {
//     // iOS simulator uses localhost
//     return 'http://localhost:8000';
//   }
//   // Desktop or others
//   return 'http://localhost:8000';
// }
class AppUrls {



  static String versionUrl = dotenv.env['VERSION_URL']!;
  static String currentVersion = dotenv.env['CURRENT_VERSION']!;
  static String fileUrl = dotenv.env['FILE_URL']!;
  static String? baseUrlMain =
      isLive ? dotenv.env['BASE_URL'] : dotenv.env['TEST_BASE_URL'];

  static final String baseUrl = "$baseUrlMain/api"; //!Server url
  // static  final baseUrl = getBaseUrl();

  static final String login          = '$baseUrl/auth/login/';
  static final String patient          = '$baseUrl/user/bloc/change-password';
  static final String saveInvoice          = '$baseUrl/great-lab-save-invoice';
  static final String setUpData          = '$baseUrl/lab-offline/setup-data';
  static final String syncInvoice          = '$baseUrl/lab-offline/sync/invoice';
  static final String fullInvoiceRefund          = '$baseUrl/great-lab-invoice-full-refund/';
  static final String getInvoice          = '$baseUrl/lab-offline/invoice';


  static final String brand          = '$baseUrl/brands/';
  static final String unit          = '$baseUrl/units/';
  static final String category          = '$baseUrl/categories/';
  static final String group          = '$baseUrl/groups/';
  static final String product          = '$baseUrl/products/';
  static final String productActive          = '$baseUrl/products?no_pagination=true&is_active=true';
  // static final String productStock          = '$baseUrl/user/product/stock-info?status=1&total=true';
  static final String source          = '$baseUrl/sources/';
  static final String account          = '$baseUrl/accounts/?no_pagination=true';
  static final String accountNON          = '$baseUrl/accounts/';
  static final String transactions          = '$baseUrl/transactions/';
  static final String customer          = '$baseUrl/customers/';
  static final String customerActive          = '$baseUrl/customers-active';
  static final String accountActive          = '$baseUrl/accounts/?is_active=true';
  static final String administrationUser          = '$baseUrl/users/';



  static final String expenseHead          = '$baseUrl/expenses/expense-heads/';
  static final String expenseSubHead          = '$baseUrl/expenses/expense-subheads/';
  static final String expense          = '$baseUrl/expenses/expenses/';
  static final String posSale          = '$baseUrl/sales/';
  static final String purchase          = '$baseUrl/purchases/';
  static final String supplierList          = '$baseUrl/suppliers/';
  static final String moneyReceipt          = '$baseUrl/money-receipts/';
  static final String supplierPayment          = '$baseUrl/supplier-payments/';
  static final String supplierInvoiceList          = '$baseUrl/purchase-due/?supplier_id=';
  static final String supplierActiveList          = '$baseUrl/suppliers-active';


  static final String salesReport          = '$baseUrl/reports/sales/';
  static final String purchaseReport          = '$baseUrl/reports/purchases/';
  static final String profitLoss          = '$baseUrl/reports/profit-loss/';
  static final String topProducts          = '$baseUrl/reports/top-products/';
  static final String lowStock          = '$baseUrl/reports/low-stock/';
  static final String stockReport          = '$baseUrl/reports/stock/';
  static final String customerLedger          = '$baseUrl/reports/customer-ledger/';
  static final String customerDueAdvance          = '$baseUrl/reports/customer-due-advance/';
  static final String supplierLedger          = '$baseUrl/reports/supplier-ledger/';
  static final String supplierDueAdvance          = '$baseUrl/reports/supplier-due-advance/';
  static final String expenseReport          = '$baseUrl/reports/expenses/';


  static final String posSaleInvoice          = '$baseUrl/sale-invoice/';
  static final String saleReturn          = '$baseUrl/sales-returns/';
  static final String purchaseReturn          = '$baseUrl/purchase-returns/';
  static final String badStock          = '$baseUrl/bad-stocks/';
  static String saleReturnApprove(int id) => '/api/returns/sales-returns/$id/approve/';
  static String saleReturnReject(int id) => '/api/returns/sales-returns/$id/reject/';
  static String saleReturnComplete(int id) => '/api/returns/sales-returns/$id/complete/';


// NEW (Correct):
  static String purchaseReturnApprove(String id) => '$baseUrl/purchase-returns/$id/approve/';
  static String purchaseReturnReject(String id) => '$baseUrl/purchase-returns/$id/reject/';
  static String purchaseReturnComplete(String id) => '$baseUrl/purchase-returns/$id/complete/';
  static final String purchaseInvoice = '$baseUrl/purchases-invoice/supplier/';
  static final String dashboard = '$baseUrl/reports/dashboard/';

  static final String userProfile = "$baseUrl/profile/";
  // static final String profilePermission = "$baseUrl/profile/permissions/";
  static final String updateProfile = "$baseUrl/profile/update/";
  static final String changePassword = "$baseUrl/profile/change-password/";

  //!for App update link
  static const String playStoreLink= '';
  static const String appStoreLink = '';
}
