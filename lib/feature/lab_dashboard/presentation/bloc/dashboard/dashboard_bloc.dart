import '../../../../../core/configs/configs.dart';
import '../../../../../enery_screen.dart';
import '../../../../lab_billing/presentation/bloc/lab_billing/lab_billing_bloc.dart';
import '../../../../lab_billing/presentation/pages/billing_screen.dart';
import '../../../../lab_technologist/presentation/pages/lab_technologist_screen.dart';
import '../../../../report_delivery/presentation/page/report_delivery_screen.dart';
import '../../../../sample_collector/presentation/pages/sample_collection_screen.dart';
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
    BlocProvider(create: (_) => LabBillingBloc(), child: AppWrapper(child: BillingScreen())),
    AppWrapper(child: TransactionScreen()),
    AppWrapper(child: SampleCollectionScreen()),
    AppWrapper(child: LabTechnologistScreen()),
    AppWrapper(child: ReportDeliveryScreen()),
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
