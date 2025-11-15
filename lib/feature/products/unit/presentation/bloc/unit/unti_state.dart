part of 'unti_bloc.dart';

sealed class UnitState {}

final class UnitInitial extends UnitState {}

final class UnitListLoading extends UnitState {}

final class UnitListSuccess extends UnitState {
  String selectedState = "";

  final List<UnitsModel> list;
  final int totalPages;
  final int currentPage;

  UnitListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
  });
}

final class UnitListFailed extends UnitState {
  final String title, content;

  UnitListFailed({required this.title, required this.content});
}

final class UnitAddInitial extends UnitState {}

final class UnitAddLoading extends UnitState {}

final class UnitAddSuccess extends UnitState {
  UnitAddSuccess();
}

final class UnitAddFailed extends UnitState {
  final String title, content;

  UnitAddFailed({required this.title, required this.content});
}

final class UnitUpdateInitial extends UnitState {}

final class UnitUpdateLoading extends UnitState {}

final class UnitUpdateSuccess extends UnitState {
  UnitUpdateSuccess();
}

final class UnitUpdateFailed extends UnitState {
  final String title, content;

  UnitUpdateFailed({required this.title, required this.content});
}

final class UnitDeleteInitial extends UnitState {}

final class UnitDeleteLoading extends UnitState {}

final class UnitDeleteSuccess extends UnitState {
  String message;
  UnitDeleteSuccess(this.message);
}

final class UnitDeleteFailed extends UnitState {
  final String title, content;

  UnitDeleteFailed({required this.title, required this.content});
}
