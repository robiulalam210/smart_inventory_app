// features/products/sale_mode/presentation/bloc/price_tier_event.dart
part of 'price_tier_bloc.dart';

@immutable
abstract class PriceTierEvent extends Equatable {
  const PriceTierEvent();

  @override
  List<Object> get props => [];
}

class LoadPriceTiers extends PriceTierEvent {
  final BuildContext context;
  final int? productSaleModeId;
  final String? productId;

  const LoadPriceTiers({
    required this.context,
    this.productSaleModeId,
    this.productId,
  });

  @override
  List<Object> get props => [context, productSaleModeId ?? 0, productId ?? 0];
}

class AddPriceTier extends PriceTierEvent {
  final BuildContext context;
  final Map<String ,dynamic> priceTier;

  const AddPriceTier({
    required this.context,
    required this.priceTier,
  });

  @override
  List<Object> get props => [context, priceTier];
}


class FetchAvailableSaleModes extends PriceTierEvent {
  final BuildContext context;
  final String productId;

  const FetchAvailableSaleModes(this.context, {required this.productId});

  @override
  List<Object> get props => [context, productId];
}

class UpdatePriceTier extends PriceTierEvent {
  final BuildContext context;
  final Map<String ,dynamic> priceTier;

  const UpdatePriceTier({
    required this.context,
    required this.priceTier,
  });

  @override
  List<Object> get props => [context, priceTier];
}

class DeletePriceTier extends PriceTierEvent {
  final BuildContext context;
  final int id;

  const DeletePriceTier({
    required this.context,
    required this.id,
  });

  @override
  List<Object> get props => [context, id];
}

class ClearPriceTiers extends PriceTierEvent {}

class CalculatePrice extends PriceTierEvent {
  final BuildContext context;
  final int productSaleModeId;
  final double quantity;

  const CalculatePrice({
    required this.context,
    required this.productSaleModeId,
    required this.quantity,
  });

  @override
  List<Object> get props => [context, productSaleModeId, quantity];
}