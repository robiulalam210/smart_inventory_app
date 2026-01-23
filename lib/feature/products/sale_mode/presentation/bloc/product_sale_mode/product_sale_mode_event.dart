// features/products/sale_mode/presentation/bloc/product_sale_mode/product_sale_mode_event.dart

part of 'product_sale_mode_bloc.dart';

abstract class ProductSaleModeEvent extends Equatable {
  const ProductSaleModeEvent();

  @override
  List<Object> get props => [];
}

class FetchProductSaleModeList extends ProductSaleModeEvent {
  final BuildContext context;
  final String productId;
  final String filterText;
  final int pageNumber;

  const FetchProductSaleModeList(
      this.context, {
        required this.productId,
        this.filterText = '',
        this.pageNumber = 0,
      });

  @override
  List<Object> get props => [context, productId, filterText, pageNumber];
}

class FetchAvailableSaleModes extends ProductSaleModeEvent {
  final BuildContext context;
  final String productId;

  const FetchAvailableSaleModes(this.context, {required this.productId});

  @override
  List<Object> get props => [context, productId];
}

class AddProductSaleMode extends ProductSaleModeEvent {
  final Map<String, dynamic> body;

  const AddProductSaleMode({required this.body});

  @override
  List<Object> get props => [body];
}

class UpdateProductSaleMode extends ProductSaleModeEvent {
  final String id;
  final Map<String, dynamic>? body;

  const UpdateProductSaleMode({required this.id, this.body});

  @override
  List<Object> get props => [id];
}

class DeleteProductSaleMode extends ProductSaleModeEvent {
  final String id;

  const DeleteProductSaleMode({required this.id});

  @override
  List<Object> get props => [id];
}

class BulkUpdateProductSaleModes extends ProductSaleModeEvent {
  final String productId;
  final List<Map<String, dynamic>> saleModes;

  const BulkUpdateProductSaleModes({
    required this.productId,
    required this.saleModes,
  });

  @override
  List<Object> get props => [productId, saleModes];
}

class ClearProductSaleModeData extends ProductSaleModeEvent {}