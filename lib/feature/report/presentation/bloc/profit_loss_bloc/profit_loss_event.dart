// lib/feature/report/presentation/bloc/profit_loss_bloc/profit_loss_event.dart
part of 'profit_loss_bloc.dart';

@immutable
sealed class ProfitLossEvent {}

class FetchProfitLossReport extends ProfitLossEvent {
  final BuildContext context;
  final DateTime? from;
  final DateTime? to;

  FetchProfitLossReport({
    required this.context,
    this.from,
    this.to,
  });
}

class ClearProfitLossFilters extends ProfitLossEvent {}