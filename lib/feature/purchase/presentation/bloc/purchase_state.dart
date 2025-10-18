part of 'purchase_bloc.dart';


sealed class PurchaseState {}

final class PurchaseInitial extends PurchaseState {}


final class PurchaseListLoading extends PurchaseState {}

final class PurchaseListSuccess extends PurchaseState {
  String selectedState = "";

  final List<PurchaseModel> list;


  PurchaseListSuccess({
    required this.list,

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



