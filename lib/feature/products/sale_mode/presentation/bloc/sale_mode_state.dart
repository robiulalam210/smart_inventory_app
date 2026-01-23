// features/products/sale_mode/presentation/bloc/sale_mode/sale_mode_state.dart

part of 'sale_mode_bloc.dart';

abstract class SaleModeState extends Equatable {
  const SaleModeState();

  @override
  List<Object> get props => [];
}

class SaleModeInitial extends SaleModeState {}

class SaleModeListLoading extends SaleModeState {}

class SaleModeListSuccess extends SaleModeState {
  final List<SaleModeModel> list;
  final int totalPages;
  final int currentPage;

  const SaleModeListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  List<Object> get props => [list, totalPages, currentPage];
}

class SaleModeListFailed extends SaleModeState {
  final String title;
  final String content;

  const SaleModeListFailed({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}

class SaleModeAddLoading extends SaleModeState {}

class SaleModeAddSuccess extends SaleModeState {}

class SaleModeAddFailed extends SaleModeState {
  final String title;
  final String content;

  const SaleModeAddFailed({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}

class SaleModeDeleteLoading extends SaleModeState {}

class SaleModeDeleteSuccess extends SaleModeState {
  final String message;

  const SaleModeDeleteSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class SaleModeDeleteFailed extends SaleModeState {
  final String title;
  final String content;

  const SaleModeDeleteFailed({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}