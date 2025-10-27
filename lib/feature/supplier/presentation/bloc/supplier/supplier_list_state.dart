part of 'supplier_list_bloc.dart';

// @immutable
sealed class SupplierListState {}

final class SupplierListInitial extends SupplierListState {}




final class SupplierListLoading extends SupplierListState {}

final class SupplierListSuccess extends SupplierListState {
  String selectedState = "";

  final List<SupplierListModel> list;
  final int totalPages;
  final int currentPage;
  final int count;
  final int pageSize;
  final int from;
  final int to;

  SupplierListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
    required this.count,
    required this.pageSize,
    required this.from,
    required this.to,
  });

  @override
  List<Object> get props => [list, totalPages, currentPage, count, pageSize, from, to];
}
final class SupplierListFailed extends SupplierListState {
  final String title, content;

  SupplierListFailed({required this.title, required this.content});
}



final class SupplierAddInitial extends SupplierListState {}

final class SupplierAddLoading extends SupplierListState {}

final class SupplierAddSuccess extends SupplierListState {
  SupplierAddSuccess();
}



final class SupplierAddFailed extends SupplierListState {
  final String title, content;

  SupplierAddFailed({required this.title, required this.content});
}



final class SupplierSwitchInitial extends SupplierListState {}

final class SupplierSwitchLoading extends SupplierListState {}

final class SupplierSwitchSuccess extends SupplierListState {
  SupplierSwitchSuccess();
}



final class SupplierSwitchFailed extends SupplierListState {
  final String title, content;

  SupplierSwitchFailed({required this.title, required this.content});
}


