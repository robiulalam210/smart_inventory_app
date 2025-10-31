// lib/feature/report/presentation/bloc/top_products_bloc/top_products_state.dart
part of 'top_products_bloc.dart';

@immutable
sealed class TopProductsState {}

final class TopProductsInitial extends TopProductsState {}

final class TopProductsLoading extends TopProductsState {}

final class TopProductsSuccess extends TopProductsState {
  final TopProductsResponse response;

  TopProductsSuccess({required this.response});
}

final class TopProductsFailed extends TopProductsState {
  final String title, content;

  TopProductsFailed({required this.title, required this.content});
}