import '../../../../../core/configs/configs.dart';
import '../../../../../enery_screen.dart';
import '../../../../product/presentation/page/product_setup.dart';
import '../../../../sales/presentation/bloc/lab_billing/lab_billing_bloc.dart';
import '../../../../sales/presentation/pages/sales_create.dart';
import '../../../../sales/presentation/pages/sales_list_screen.dart';
import '../../../../transactions/presentation/pages/transactions_screen.dart';
import '../../../data/models/dashboard/dashboard_model.dart';
import '../../../data/repositories/dashboard_repo_db/dashboard_repo_db.dart';
import '../../pages/lab_dashboard_screen.dart';

part 'dashboard_event.dart';

part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DatabaseHelper dbHelper;
  final List<Widget> myScreens = [
    AppWrapper(child: DashboardScreen()),
    AppWrapper(child: SalesListScreen()),

    BlocProvider(create: (_) => LabBillingBloc(), child: AppWrapper(child: SalesScreen())),
    AppWrapper(child: SalesListScreen()),
    AppWrapper(child: ProductSetupScreen()),

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
