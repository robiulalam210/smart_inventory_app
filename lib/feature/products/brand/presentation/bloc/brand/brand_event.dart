part of 'brand_bloc.dart';

sealed class BrandEvent {}

class FetchBrandList extends BrandEvent{
  BuildContext context;

  final String filterText;
  final int pageNumber;

  FetchBrandList(this.context,{this.filterText = '', this.pageNumber = 0});

}
class AddBrand  extends BrandEvent {
  final Map<String,dynamic>? body;

  AddBrand({this.body});
}

class UpdateBrand extends BrandEvent {
  final Map<String,dynamic>? body;
  final String? id;


  UpdateBrand({this.body,this.id});
}

class DeleteBrand  extends BrandEvent {
  final String id;

  DeleteBrand({this.id=''});
}
