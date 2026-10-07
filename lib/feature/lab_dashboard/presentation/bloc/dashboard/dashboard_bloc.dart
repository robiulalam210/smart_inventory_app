
import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/get_response.dart';



import '../../../data/models/dashboard/dashboard_model.dart';

part 'dashboard_event.dart';

part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  

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
