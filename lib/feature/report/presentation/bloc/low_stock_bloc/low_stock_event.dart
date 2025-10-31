// lib/feature/report/presentation/bloc/low_stock_bloc/low_stock_event.dart
part of 'low_stock_bloc.dart';

@immutable
sealed class LowStockEvent {}

class FetchLowStockReport extends LowStockEvent {
  final BuildContext context;

  FetchLowStockReport({required this.context});
}

class ClearLowStockFilters extends LowStockEvent {}