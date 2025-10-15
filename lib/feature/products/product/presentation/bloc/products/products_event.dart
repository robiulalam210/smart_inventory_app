part of 'products_bloc.dart';

// @immutable
sealed class ProductsEvent {}




class FetchProductsList extends ProductsEvent {  BuildContext context;

final String filterApiURL;
  final String filterText;
  final String state;
  final String category;
  final int pageNumber;

  FetchProductsList(this.context,{this.filterText = '',this.state='',this.category='',this.filterApiURL='', this.pageNumber = 0});
}

class AddProducts extends ProductsEvent {
  final Map<String, String>? body;String? photoPath;


  AddProducts({this.body,this.photoPath});
}

class UpdateProducts extends ProductsEvent {  final String id;

final Map<String, String>? body;String? photoPath;


UpdateProducts({this.body,this.photoPath,this.id=''});
}


class DeleteProducts  extends ProductsEvent {
  final String id;

  DeleteProducts({this.id=""});
}



class FetchProductDetailsList extends ProductsEvent {
  final String id;
  BuildContext context;


  FetchProductDetailsList(this.context,{this.id = ''});
}