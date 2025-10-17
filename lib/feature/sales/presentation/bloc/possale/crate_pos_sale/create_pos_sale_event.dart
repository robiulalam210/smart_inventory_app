part of 'create_pos_sale_bloc.dart';

@immutable
sealed class CreatePosSaleEvent {}



class AddPosSale extends CreatePosSaleEvent {
  final Map<String,dynamic>? body;

  AddPosSale({this.body});
}
