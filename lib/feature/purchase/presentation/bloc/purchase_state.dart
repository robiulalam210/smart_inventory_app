part of 'purchase_bloc.dart';


sealed class PurchaseState {}

final class PurchaseInitial extends PurchaseState {}


final class PurchaseListLoading extends PurchaseState {}
final class PurchaseListSuccess extends PurchaseState {
  final List<PurchaseModel> list;
  final int count;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final int from;
  final int to;

  PurchaseListSuccess({
    required this.list,
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.from,
    required this.to,
  });
}


final class PurchaseListFailed extends PurchaseState {
  final String title, content;

  PurchaseListFailed({required this.title, required this.content});
}


final class PurchaseAddInitial extends PurchaseState {}

final class PurchaseAddLoading extends PurchaseState {}

final class PurchaseAddSuccess extends PurchaseState {

  PurchaseAddSuccess();
}



final class PurchaseAddFailed extends PurchaseState {
  final String title, content;

  PurchaseAddFailed({required this.title, required this.content});
}



