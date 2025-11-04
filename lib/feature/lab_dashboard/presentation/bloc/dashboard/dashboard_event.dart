part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardEvent {}



class ChangeDashboardScreen extends DashboardEvent {
  final int index;
  ChangeDashboardScreen({this.index=0});
}


class FetchDashboardData extends DashboardEvent {
  final String? dateFilter;
  final BuildContext context;

   FetchDashboardData({this.dateFilter,required this.context});

  @override
  List<Object> get props => [dateFilter ?? ''];
}