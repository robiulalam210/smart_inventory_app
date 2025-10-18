part of 'create_purchase_bloc.dart';

@immutable
sealed class CreatePurchaseEvent {}


class AddPurchase extends CreatePurchaseEvent {
  final Map<String,dynamic>? body;

  AddPurchase({this.body});
}
