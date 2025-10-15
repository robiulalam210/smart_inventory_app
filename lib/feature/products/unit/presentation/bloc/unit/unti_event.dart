part of 'unti_bloc.dart';

sealed class UnitEvent {}



class FetchUnitList extends UnitEvent{
  BuildContext context;

  final String filterText;
  final int pageNumber;

  FetchUnitList(this.context,{this.filterText = '', this.pageNumber = 0});

}
class AddUnit  extends UnitEvent {
  final Map<String,String>? body;

  AddUnit({this.body});
}

class UpdateUnit extends UnitEvent {
  final Map<String,String>? body;
  final String? id;


  UpdateUnit({this.body,this.id});
}

class DeleteUnit  extends UnitEvent {
  final String id;

  DeleteUnit(this.id);
}
