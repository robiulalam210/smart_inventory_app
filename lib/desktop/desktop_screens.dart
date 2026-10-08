import 'package:flutter/material.dart';
import 'package:meherinMart/enery_screen.dart';
import 'package:meherinMart/feature/account_transfer/presentation/desktop/account_transfer_form.dart';
import 'package:meherinMart/feature/account_transfer/presentation/desktop/account_transfer_screen.dart';
import 'package:meherinMart/feature/accounts/presentation/desktop/account_screen.dart';
import 'package:meherinMart/feature/customer/presentation/desktop/customer_screen.dart';
import 'package:meherinMart/feature/expense/expense_head/presentation/desktop/expense_screen.dart';
import 'package:meherinMart/feature/expense/expense_sub_head/presentation/desktop/expense_sub_head_screen.dart';
import 'package:meherinMart/feature/expense/presentation/desktop/expense_list_screen.dart';
import 'package:meherinMart/feature/income/income_expense/presentation/shared/income_expense_head_page.dart';
import 'package:meherinMart/feature/income/presentation/shared/income_page_list.dart';
import 'package:meherinMart/feature/lab_dashboard/presentation/desktop/lab_dashboard_screen.dart';
import 'package:meherinMart/feature/money_receipt/presentation/desktop/monery_receipt_create.dart';
import 'package:meherinMart/feature/money_receipt/presentation/desktop/money_receipt_list.dart';
import 'package:meherinMart/feature/products/brand/presentation/desktop/brand_screen.dart';
import 'package:meherinMart/feature/products/categories/presentation/desktop/categories_screen.dart';
import 'package:meherinMart/feature/products/groups/presentation/desktop/groups_screen.dart';
import 'package:meherinMart/feature/products/product/presentation/desktop/product_screen.dart';
import 'package:meherinMart/feature/products/sale_mode/presentation/shared/sale_mode_list_screen.dart';
import 'package:meherinMart/feature/products/soruce/presentation/desktop/source_screen.dart';
import 'package:meherinMart/feature/products/unit/presentation/desktop/unit_screen.dart';
import 'package:meherinMart/feature/profile/presentation/desktop/profile_screen.dart';
import 'package:meherinMart/feature/purchase/presentation/desktop/create_purchase_screen.dart';
import 'package:meherinMart/feature/purchase/presentation/desktop/purchase_screen.dart';
import 'package:meherinMart/feature/report/presentation/desktop/customer_due_advance_screen/customer_due_advance_screen.dart';
import 'package:meherinMart/feature/report/presentation/desktop/customer_ledger_screen/customer_ledger_screen.dart';
import 'package:meherinMart/feature/report/presentation/desktop/expense_report_screen/expense_report_screen.dart';
import 'package:meherinMart/feature/report/presentation/desktop/low_stock_screen/low_stock_screen.dart';
import 'package:meherinMart/feature/report/presentation/shared/profit_loss_screen/profit_loss_screen.dart';
import 'package:meherinMart/feature/report/presentation/desktop/purchase_report_screen/purchase_report_screen.dart';
import 'package:meherinMart/feature/report/presentation/desktop/sales_report_page/sales_report_screen.dart';
import 'package:meherinMart/feature/report/presentation/desktop/stock_report_screen/stock_report_screen.dart';
import 'package:meherinMart/feature/report/presentation/desktop/supplier_due_advance_screen/supplier_due_advance_screen.dart';
import 'package:meherinMart/feature/report/presentation/desktop/supplier_ledger_screen/supplier_ledger_screen.dart';
import 'package:meherinMart/feature/report/presentation/desktop/top_products_screen/top_products_screen.dart';
import 'package:meherinMart/feature/return/bad_stock/desktop/bad_stock_screen.dart';
import 'package:meherinMart/feature/return/purchase_return/presentation/purchase_return/desktop/purchase_return_screen.dart';
import 'package:meherinMart/feature/return/sales_return/presentation/desktop/sales_return_page.dart';
import 'package:meherinMart/feature/sales/presentation/desktop/create_pos_sale/create_pos_sale.dart';
import 'package:meherinMart/feature/sales/presentation/desktop/create_pos_sale/create_sales_pos.dart';
import 'package:meherinMart/feature/sales/presentation/desktop/pos_sale_screen.dart';
import 'package:meherinMart/feature/supplier/presentation/desktop/supplier_list_screen.dart';
import 'package:meherinMart/feature/supplier/presentation/desktop/supplier_payment_list_screen.dart';
import 'package:meherinMart/feature/transactions/presentation/desktop/transaction_screen.dart';
import 'package:meherinMart/feature/users_list/presentation/desktop/users_screen.dart';
import 'package:meherinMart/desktop/widgets/embedded_full_page.dart';
import 'package:meherinMart/feature/audit_log/presentation/audit_log_screen.dart';

/// Desktop root এর main area তে যে স্ক্রিনগুলো index অনুযায়ী দেখায়।
/// (আগে DashboardBloc.myScreens ছিল — সেটা mobile build এও সব desktop স্ক্রিন টেনে আনত।)
final List<Widget> desktopScreens = [
    AppWrapper(child: DashboardScreen()),

    AppWrapper(child: CreatePosSalePage()),
    AppWrapper(child: SalesScreen()),
    AppWrapper(child: PosSaleScreen()),

    AppWrapper(child: MoneyReceiptForm()),
    AppWrapper(child: MoneyReceiptScreen()),

    AppWrapper(child: CreatePurchaseScreen()),
    AppWrapper(child: PurchaseScreen()),

    AppWrapper(child: ProductsScreen()),

    AppWrapper(child: AccountScreen()),

    AppWrapper(child: CustomerScreen()),

    AppWrapper(child: SupplierScreen()),

    AppWrapper(child: SupplierPaymentScreen()),


    AppWrapper(child: ExpenseListScreen()),
    AppWrapper(child: ExpenseHeadScreen()),
    AppWrapper(child: ExpenseSubHeadScreen()),


    AppWrapper(child: SalesReturnScreen()),
    AppWrapper(child: BadStockScreen()),
    AppWrapper(child: PurchaseReturnScreen()),


    AppWrapper(child: SaleReportScreen()),
    AppWrapper(child: PurchaseReportScreen()),
    AppWrapper(child: ProfitLossScreen()),
    AppWrapper(child: TopProductsScreen()),
    AppWrapper(child: LowStockScreen()),
    AppWrapper(child: StockReportScreen()),
    AppWrapper(child: CustomerLedgerScreen()),
    AppWrapper(child: CustomerDueAdvanceScreen()),
    AppWrapper(child: SupplierLedgerScreen()),
    AppWrapper(child: SupplierDueAdvanceScreen()),
    AppWrapper(child: ExpenseReportScreen()),
    AppWrapper(child: BadStockScreen()),

    AppWrapper(child: UsersScreen()),
    AppWrapper(child: SourceScreen()),
    AppWrapper(child: UnitScreen()),
    AppWrapper(child: BrandScreen()),
    AppWrapper(child: CategoriesScreen()),
    AppWrapper(child: GroupsScreen()),
    AppWrapper(child: ProfileScreen()),


    AppWrapper(child: AccountTransferForm()),
    AppWrapper(child: AccountTransferScreen()),
    AppWrapper(child: TransactionScreen()),

    // index 41-43: আগে sidebar ছাড়া আলাদা page এ খুলত
    AppWrapper(child: EmbeddedFullPage(child: MobileIncomeListScreen())),   // 41 Income List
    AppWrapper(child: EmbeddedFullPage(child: MobileIncomeHeadScreen())),   // 42 Income Head
    AppWrapper(child: EmbeddedFullPage(child: SaleModeListScreen())),       // 43 Sale Mode
    AppWrapper(child: EmbeddedFullPage(child: AuditLogScreen(showAppBar: false))), // 44 Audit Log (Super Admin / Admin)



  ];
