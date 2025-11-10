import 'package:flutter_dotenv/flutter_dotenv.dart';
final bool isLive = false; // Set to true for production environment

class AppUrls {



  static String versionUrl = dotenv.env['VERSION_URL']!;
  static String currentVersion = dotenv.env['CURRENT_VERSION']!;
  static String fileUrl = dotenv.env['FILE_URL']!;
  static String? baseUrlMain =
      isLive ? dotenv.env['BASE_URL'] : dotenv.env['TEST_BASE_URL'];

  static final String baseUrl = "$baseUrlMain/api"; //!Server url

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
  static final String customer          = '$baseUrl/customers/';
  static final String customerActive          = '$baseUrl/customers-active';
  static final String accountActive          = '$baseUrl/accounts/?is_active=true&no_pagination=true';
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

  static final String purchaseInvoice = '$baseUrl/purchases-invoice/supplier/';
  static final String dashboard = '$baseUrl/reports/dashboard/';



  //!for App update link
  static const String playStoreLink= '';
  static const String appStoreLink = '';
}
