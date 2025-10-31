// lib/feature/report/presentation/bloc/low_stock_bloc/low_stock_state.dart
part of 'low_stock_bloc.dart';

@immutable
sealed class LowStockState {}

final class LowStockInitial extends LowStockState {}

final class LowStockLoading extends LowStockState {}

final class LowStockSuccess extends LowStockState {
  final LowStockResponse response;

  LowStockSuccess({required this.response});
}

final class LowStockFailed extends LowStockState {
  final String title, content;

  LowStockFailed({required this.title, required this.content});
}