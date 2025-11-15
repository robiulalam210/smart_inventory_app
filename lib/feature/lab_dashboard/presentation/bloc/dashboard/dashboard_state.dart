part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardState {}

final class DashboardInitial extends DashboardState {}

class DashboardScreenChanged extends DashboardState {
  final int index;
  DashboardScreenChanged(this.index);
}


class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardData dashboardData;

   DashboardLoaded(this.dashboardData);

  List<Object> get props => [dashboardData];
}

class DashboardError extends DashboardState {
  final String message;

   DashboardError(this.message);

  List<Object> get props => [message];
}