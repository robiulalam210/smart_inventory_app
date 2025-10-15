part of 'products_bloc.dart';

sealed class ProductsState {}

final class ProductsInitial extends ProductsState {}




final class ProductsListLoading extends ProductsState {}

final class ProductsListSuccess extends ProductsState {
  String selectedState = "";

  final List<ProductModel> list;
  final int totalPages;
  final int currentPage;

  ProductsListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
  });
}
final class ProductsListFailed extends ProductsState {
  final String title, content;

  ProductsListFailed({required this.title, required this.content});
}



final class ProductsAddInitial extends ProductsState {}

final class ProductsAddLoading extends ProductsState {}

final class ProductsAddSuccess extends ProductsState {
  ProductsAddSuccess();
}



final class ProductsDeleteFailed extends ProductsState {
  final String title, content;

  ProductsDeleteFailed({required this.title, required this.content});
}

final class ProductsDeleteInitial extends ProductsState {}

final class ProductsDeleteLoading extends ProductsState {}

final class ProductsDeleteSuccess extends ProductsState {
  ProductsDeleteSuccess();
}



final class ProductsAddFailed extends ProductsState {
  final String title, content;

  ProductsAddFailed({required this.title, required this.content});
}




sealed class ProductDetailsState {}

final class ProductDetailsInitial
    extends ProductDetailsState {}

final class ProductDetailsLoading
    extends ProductDetailsState {}

// final class ProductDetailsSuccess
//     extends ProductDetailsState {
//
//
//   final ProductDetailsModel productDetailsModel;
//
//   ProductDetailsSuccess({
//     required this.productDetailsModel,
//   });
// }

final class ProductDetailsFailed extends ProductDetailsState {
  final String title, content;

  ProductDetailsFailed({required this.title, required this.content});
}