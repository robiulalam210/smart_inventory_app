import 'package:equatable/equatable.dart';

abstract class InventoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Load inventory
class LoadInventory extends InventoryEvent {}
