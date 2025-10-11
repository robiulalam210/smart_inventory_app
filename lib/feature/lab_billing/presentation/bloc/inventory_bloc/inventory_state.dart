import 'package:equatable/equatable.dart';

import '../../../data/models/inventory_model/inventory_model.dart';

abstract class InventoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state
class InventoryInitial extends InventoryState {}

// Loading state
class InventoryLoading extends InventoryState {}

// Loaded state
class InventoryLoaded extends InventoryState {
  final List<InventoryLocalProduct> inventory;

  InventoryLoaded(this.inventory);

  @override
  List<Object?> get props => [inventory];
}

// Error state
class InventoryError extends InventoryState {
  final String message;

  InventoryError(this.message);

  @override
  List<Object?> get props => [message];
}
