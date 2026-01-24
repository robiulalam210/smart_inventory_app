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
class ProductSaleModeLoaded extends ProductSaleModeState {
  final List<ProductSaleModeModel> configuredModes;
  final List<AvlibleSaleModeModel> availableModes;
  final bool isLoadingConfigured;
  final bool isLoadingAvailable;
  final String configuredError;
  final String availableError;

  ProductSaleModeLoaded({
    this.configuredModes = const [],
    this.availableModes = const [],
    this.isLoadingConfigured = false,
    this.isLoadingAvailable = false,
    this.configuredError = '',
    this.availableError = '',
  });

  ProductSaleModeLoaded copyWith({
    List<ProductSaleModeModel>? configuredModes,
    List<AvlibleSaleModeModel>? availableModes,
    bool? isLoadingConfigured,
    bool? isLoadingAvailable,
    String? configuredError,
    String? availableError,
  }) {
    return ProductSaleModeLoaded(
      configuredModes: configuredModes ?? this.configuredModes,
      availableModes: availableModes ?? this.availableModes,
      isLoadingConfigured: isLoadingConfigured ?? this.isLoadingConfigured,
      isLoadingAvailable: isLoadingAvailable ?? this.isLoadingAvailable,
      configuredError: configuredError ?? this.configuredError,
      availableError: availableError ?? this.availableError,
    );
  }
}
class ProductSaleModeListFailed extends ProductSaleModeState {
  final String title;
  final String content;

  const ProductSaleModeListFailed({required this.title, required this.content});

  @override
  List<Object> get props => [title, content];
}

class AvailableSaleModesLoading extends ProductSaleModeState {}

class AvailableSaleModesSuccess extends ProductSaleModeState {
  final List<AvlibleSaleModeModel> availableModes;

  const AvailableSaleModesSuccess({required this.availableModes});

  @override
  List<Object> get props => [availableModes];
}


class AvailableSaleModesFailed extends ProductSaleModeState {
  final String title;
  final String content;

  const AvailableSaleModesFailed({required this.title, required this.content});

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