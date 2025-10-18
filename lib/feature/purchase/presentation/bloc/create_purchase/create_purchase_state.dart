part of 'create_purchase_bloc.dart';

@immutable
sealed class CreatePurchaseState {}

final class CreatePurchaseInitial extends CreatePurchaseState {}




final class CreatePurchaseLoading extends CreatePurchaseState {}

final class CreatePurchaseSuccess extends CreatePurchaseState {

  CreatePurchaseSuccess();
}



final class CreatePurchaseFailed extends CreatePurchaseState {
  final String title, content;

  CreatePurchaseFailed({required this.title, required this.content});
}

