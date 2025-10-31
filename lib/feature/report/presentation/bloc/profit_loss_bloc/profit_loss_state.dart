// lib/feature/report/presentation/bloc/profit_loss_bloc/profit_loss_state.dart
part of 'profit_loss_bloc.dart';

@immutable
sealed class ProfitLossState {}

final class ProfitLossInitial extends ProfitLossState {}

final class ProfitLossLoading extends ProfitLossState {}

final class ProfitLossSuccess extends ProfitLossState {
  final ProfitLossResponse response;

  ProfitLossSuccess({required this.response});
}

final class ProfitLossFailed extends ProfitLossState {
  final String title, content;

  ProfitLossFailed({required this.title, required this.content});
}