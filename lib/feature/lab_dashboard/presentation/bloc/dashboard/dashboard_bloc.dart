import 'package:smart_inventory/feature/accounts/presentation/pages/account_screen.dart';
import 'package:smart_inventory/feature/expense/expense_head/presentation/pages/expense_screen.dart';
import 'package:smart_inventory/feature/expense/presentation/pages/expense_list_screen.dart';
import 'package:smart_inventory/feature/products/groups/presentation/pages/groups_screen.dart';
import 'package:smart_inventory/feature/products/soruce/presentation/pages/source_screen.dart';
import 'package:smart_inventory/feature/products/unit/presentation/pages/unit_screen.dart';
import 'package:smart_inventory/feature/sales/presentation/pages/pos_sale_screen.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../enery_screen.dart';
import '../../../../customer/presentation/pages/customer_screen.dart';
import '../../../../expense/expense_sub_head/presentation/pages/expense_sub_head_screen.dart';
import '../../../../money_receipt/presentation/page/monery_receipt_create.dart';
import '../../../../money_receipt/presentation/page/money_receipt_list_screen.dart';
import '../../../../product/presentation/page/create_product_screen.dart';
import '../../../../product/presentation/page/product_setup.dart';
import '../../../../products/brand/presentation/pages/brand_screen.dart';
import '../../../../products/categories/presentation/pages/categories_screen.dart';
import '../../../../products/product/presentation/pages/product_screen.dart';
import '../../../../purchase/presentation/page/purchase_entry_from.dart';
import '../../../../purchase/presentation/page/purchase_list_screen.dart';
import '../../../../sales/presentation/pages/create_pos_sale/create_pos_sale.dart';
import '../../../../sales/presentation/pages/sales_create.dart';
import '../../../../sales/presentation/pages/sales_list_screen.dart';
import '../../../../users_list/presentation/pages/users_screen.dart';
import '../../../data/models/dashboard/dashboard_model.dart';
import '../../../data/repositories/dashboard_repo_db/dashboard_repo_db.dart';
import '../../pages/lab_dashboard_screen.dart';

part 'dashboard_event.dart';

part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DatabaseHelper dbHelper;
  final List<Widget> myScreens = [
    AppWrapper(child: DashboardScreen()),

    AppWrapper(child: CreatePosSalePage()),
    AppWrapper(child: PosSaleScreen()),

    // AppWrapper(child: SalesListScreen()),

    AppWrapper(child: MoneyReceiptForm()),
    AppWrapper(child: MoneyReceiptListScreen()),

    // AppWrapper(child: ProductCreateScreen()),
    AppWrapper(child: ProductsScreen()),
    AppWrapper(child: SourceScreen()),
    AppWrapper(child: UnitScreen()),
    AppWrapper(child: BrandScreen()),
    AppWrapper(child: CategoriesScreen()),
    AppWrapper(child: GroupsScreen()),
    AppWrapper(child: AccountScreen()),
    AppWrapper(child: CustomerScreen()),

    AppWrapper(child: ExpenseListScreen()),
    AppWrapper(child: ExpenseHeadScreen()),
    AppWrapper(child: ExpenseSubHeadScreen()),

    AppWrapper(child: UsersScreen()),


    // AppWrapper(child: PurchaseCreateScreen()),
    // AppWrapper(child: PurchaseListScreen()),

  ];

  DashboardBloc(this.dbHelper) : super(DashboardScreenChanged(0)) {
    on<ChangeDashboardScreen>((event, emit) {
      emit(DashboardScreenChanged(event.index));
    });

    on<LoadDashboardData>((event, emit) async {
      emit(DashboardLoading());
      try {
        final dashboardData = await fetchDashboardData(filter: event.filter);
        emit(DashboardLoaded(dashboardData));
      } catch (e,k) {
        debugPrint("error $e stack $k");
        emit(DashboardError("Failed to load dashboard data"));
      }
    });
  }
}

enum DateRangeFilter {
  today,
  last7Days,
  last30Days,
  last365Days,
  all,
}
