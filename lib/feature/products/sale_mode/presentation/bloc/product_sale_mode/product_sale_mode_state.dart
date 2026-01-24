part of 'product_sale_mode_bloc.dart';



abstract class ProductSaleModeState extends Equatable {
  const ProductSaleModeState();

  @override
  List<Object> get props => [];
}

class ProductSaleModeInitial extends ProductSaleModeState {}

class ProductSaleModeListLoading extends ProductSaleModeState {}

class ProductSaleModeListSuccess extends ProductSaleModeState {
  final List<ProductSaleModeModel> list;
  final int totalPages;
  final int currentPage;

  const ProductSaleModeListSuccess({
    required this.list,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  List<Object> get props => [list, totalPages, currentPage];
}
// Combined state
class ProductSaleModeListFailed extends ProductSaleModeState {
  final String title;
  final String content;

  const ProductSaleModeListFailed({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}


class ProductSaleModeAddLoading extends ProductSaleModeState {}

class ProductSaleModeAddSuccess extends ProductSaleModeState {}

class ProductSaleModeAddFailed extends ProductSaleModeState {
  final String title;
  final String content;

  const ProductSaleModeAddFailed({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}

class ProductSaleModeDeleteLoading extends ProductSaleModeState {}

class ProductSaleModeDeleteSuccess extends ProductSaleModeState {
  final String message;

  const ProductSaleModeDeleteSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class ProductSaleModeDeleteFailed extends ProductSaleModeState {
  final String title;
  final String content;

  const ProductSaleModeDeleteFailed({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}

class ProductSaleModeBulkUpdateLoading extends ProductSaleModeState {}

class ProductSaleModeBulkUpdateSuccess extends ProductSaleModeState {}

class ProductSaleModeBulkUpdateFailed extends ProductSaleModeState {
  final String title;
  final String content;

  const ProductSaleModeBulkUpdateFailed({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}