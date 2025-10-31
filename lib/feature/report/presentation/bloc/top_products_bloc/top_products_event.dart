// lib/feature/report/presentation/bloc/top_products_bloc/top_products_event.dart
part of 'top_products_bloc.dart';

@immutable
sealed class TopProductsEvent {}

class FetchTopProductsReport extends TopProductsEvent {
  final BuildContext context;
  final DateTime? from;
  final DateTime? to;

  FetchTopProductsReport({
    required this.context,
    this.from,
    this.to,
  });
}

class ClearTopProductsFilters extends TopProductsEvent {}