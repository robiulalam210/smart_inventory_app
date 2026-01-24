import '/feature/accounts/presentation/pages/account_screen.dart';
import '/feature/expense/expense_head/presentation/pages/expense_screen.dart';
import '/feature/expense/presentation/pages/expense_list_screen.dart';
import '/feature/products/groups/presentation/pages/groups_screen.dart';
import '/feature/products/soruce/presentation/pages/source_screen.dart';
import '/feature/products/unit/presentation/pages/unit_screen.dart';
import '/feature/purchase/presentation/page/purchase_screen.dart';
import '/feature/report/presentation/page/customer_ledger_screen/customer_ledger_screen.dart';
import '/feature/report/presentation/page/low_stock_screen/low_stock_screen.dart';
import '/feature/report/presentation/page/profit_loss_screen/profit_loss_screen.dart';
import '/feature/report/presentation/page/purchase_report_screen/purchase_report_screen.dart';
import '/feature/report/presentation/page/sales_report_page/sales_report_screen.dart';
import '/feature/report/presentation/page/stock_report_screen/stock_report_screen.dart';
import '/feature/report/presentation/page/top_products_screen/top_products_screen.dart';
import '/feature/sales/presentation/pages/pos_sale_screen.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/get_response.dart';
import '../../../../../enery_screen.dart';
import '../../../../account_transfer/presentation/screen/account_transfer_form.dart';
import '../../../../account_transfer/presentation/screen/account_transfer_screen.dart';
import '../../../../customer/presentation/pages/customer_screen.dart';
import '../../../../expense/expense_sub_head/presentation/pages/expense_sub_head_screen.dart';
import '../../../../money_receipt/presentation/page/monery_receipt_create.dart';
import '../../../../money_receipt/presentation/page/money_receipt_list.dart';

import '../../../../products/brand/presentation/pages/brand_screen.dart';
import '../../../../products/categories/presentation/pages/categories_screen.dart';
import '../../../../products/product/presentation/pages/product_screen.dart';
import '../../../../profile/presentation/pages/profile_screen.dart';
import '../../../../purchase/presentation/page/create_purchase_screen.dart';

import '../../../../report/presentation/page/customer_due_advance_screen/customer_due_advance_screen.dart';
import '../../../../report/presentation/page/expense_report_screen/expense_report_screen.dart';
import '../../../../report/presentation/page/supplier_due_advance_screen/supplier_due_advance_screen.dart';
import '../../../../report/presentation/page/supplier_ledger_screen/supplier_ledger_screen.dart';
import '../../../../return/bad_stock/bad_stock_screen.dart';
import '../../../../return/purchase_return/presentation/purchase_return/purchase_return_screen.dart';
import '../../../../return/sales_return/presentation/page/sales_return_page.dart';
import '../../../../sales/presentation/pages/create_pos_sale/create_pos_sale.dart';

import '../../../../sales/presentation/pages/create_pos_sale/create_sales_pos.dart';
import '../../../../supplier/presentation/pages/supplier_list_screen.dart';
import '../../../../supplier/presentation/pages/supplier_payment_list_screen.dart';
import '../../../../transactions/presentation/pages/transaction_screen.dart';
import '../../../../users_list/presentation/pages/users_screen.dart';
import '../../../data/models/dashboard/dashboard_model.dart';
import '../../pages/lab_dashboard_screen.dart';

part 'dashboard_event.dart';

part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final List<Widget> myScreens = [
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



  ];

  DashboardBloc() : super(DashboardScreenChanged(0)) {
    // Register event handlers
    on<ChangeDashboardScreen>((event, emit) {
      emit(DashboardScreenChanged(event.index));
    });

    on<FetchDashboardData>(_onFetchDashboardData);
  }

  Future<void> _onFetchDashboardData(
      FetchDashboardData event,
      Emitter<DashboardState> emit,
      ) async {
    emit(DashboardLoading());
    try {
      // Build URL with date filter parameter BEFORE making the request
      String url = AppUrls.dashboard;
      if (event.dateFilter != null) {
        url += '?dateFilter=${event.dateFilter}';
      }

      // Debug print

      final res = await getResponse(
        url: url, // Use the constructed URL
        context: event.context,
      );

      // Parse manually to handle the nested structure
      final Map<String, dynamic> responseData = json.decode(res);

      if (responseData['status'] == true) {
        final dashboardData = DashboardData.fromJson(responseData['data']);
        emit(DashboardLoaded(dashboardData));
      } else {
        emit(DashboardError(
          responseData['message'] ?? "Failed to fetch dashboard data",
        ));
      }
    } catch (error,st) {
      print(error);
      print(st);
      emit(DashboardError(error.toString()));
    }
  }
}

enum DateRangeFilter {
  today,
  last7Days,
  last30Days,
  last365Days,
  all,
}
