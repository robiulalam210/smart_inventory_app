part of 'source_bloc.dart';

sealed class SourceEvent {}

class FetchSourceList extends SourceEvent{
  BuildContext context;

  final String filterText;
  final int pageNumber;

  FetchSourceList(this.context,{this.filterText = '', this.pageNumber = 0});

}
class AddSource  extends SourceEvent {
  final Map<String,String>? body;

  AddSource({this.body});
}

class UpdateSource extends SourceEvent {
  final Map<String,String>? body;
  final String? id;


  UpdateSource({this.body,this.id});
}

class DeleteSource  extends SourceEvent {
  final String id;

  DeleteSource(this.id);
}
