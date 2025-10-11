part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardEvent {}



class ChangeDashboardScreen extends DashboardEvent {
  final int index;
  ChangeDashboardScreen({this.index=0});
}

// Add optional filter parameter here
class LoadDashboardData extends DashboardEvent {
  final DateRangeFilter filter;

   LoadDashboardData({this.filter = DateRangeFilter.all});

  List<Object?> get props => [filter];
}