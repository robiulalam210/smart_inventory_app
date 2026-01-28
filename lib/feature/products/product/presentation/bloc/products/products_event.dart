part of 'products_bloc.dart';

// @immutable
sealed class ProductsEvent {}

class FetchProductsList extends ProductsEvent {
  final BuildContext context;
  final String filterText;
  final String category;
  final String state;
  final String brand;
  final String unit;
  final String group;
  final String source;
  final String minPrice;
  final String maxPrice;
  final String minStock;
  final String maxStock;
  final String productName;
  final String sku;
  final int pageNumber;
  final int pageSize;

  FetchProductsList(
    this.context, {
    this.filterText = '',
    this.category = '',
    this.state = '',
    this.brand = '',
    this.unit = '',
    this.group = '',
    this.source = '',
    this.minPrice = '',
    this.maxPrice = '',
    this.minStock = '',
    this.maxStock = '',
    this.productName = '',
    this.sku = '',
    this.pageNumber = 1,
    this.pageSize = 10,
  });
}

class FetchProductsStockList extends ProductsEvent {
  BuildContext context;

  FetchProductsStockList(this.context);
}
class FetchProductDetails extends ProductsEvent {
  final BuildContext context;
  final String productId;

   FetchProductDetails(this.context, {required this.productId});
}


class ProductDetailsLoading extends ProductsState {}

class ProductDetailsSuccess extends ProductsState {
  final ProductModel product;

   ProductDetailsSuccess({required this.product});
}

class ProductDetailsFailed extends ProductsState {
  final String title;
  final String content;

   ProductDetailsFailed({required this.title, required this.content});
}

class AddProducts extends ProductsEvent {
  final Map<String, dynamic>? body;

  AddProducts({this.body});
}

class UpdateProducts extends ProductsEvent {
  final String id;

  final Map<String, dynamic>? body;
  String? photoPath;

  UpdateProducts({this.body, this.photoPath, this.id = ''});
}

class DeleteProducts extends ProductsEvent {
  final String id;

  DeleteProducts({this.id = ""});
}

class FetchProductDetailsList extends ProductsEvent {
  final String id;
  BuildContext context;

  FetchProductDetailsList(this.context, {this.id = ''});
}
