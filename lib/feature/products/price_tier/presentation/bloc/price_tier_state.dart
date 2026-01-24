// features/products/sale_mode/presentation/bloc/price_tier_state.dart
part of 'price_tier_bloc.dart';

@immutable
abstract class PriceTierState extends Equatable {
  const PriceTierState();

  @override
  List<Object> get props => [];
}

class PriceTierInitial extends PriceTierState {}

class PriceTierLoading extends PriceTierState {}

class PriceTierListLoaded extends PriceTierState {
  final List<PriceTierModel> priceTiers;

  const PriceTierListLoaded({required this.priceTiers});

  @override
  List<Object> get props => [priceTiers];
}

class PriceTierOperationLoading extends PriceTierState {}

class PriceTierOperationSuccess extends PriceTierState {
  final String message;
  final PriceTierModel? priceTier;

  const PriceTierOperationSuccess({
    required this.message,
    this.priceTier,
  });

  @override
  List<Object> get props => [message, priceTier ?? PriceTierModel()];
}

class PriceTierOperationFailed extends PriceTierState {
  final String error;

  const PriceTierOperationFailed({required this.error});

  @override
  List<Object> get props => [error];
}

class PriceCalculated extends PriceTierState {
  final double price;
  final Map<String, dynamic> calculationData;

  const PriceCalculated({
    required this.price,
    required this.calculationData,
  });

  @override
  List<Object> get props => [price, calculationData];
}