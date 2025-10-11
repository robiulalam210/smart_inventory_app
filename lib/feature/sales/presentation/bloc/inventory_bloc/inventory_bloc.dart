import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/inventory_repo.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository inventoryRepository=InventoryRepository();

  InventoryBloc() : super(InventoryInitial()) {
    on<LoadInventory>(_onLoadInventory);
  }

  // Load inventory items
  Future<void> _onLoadInventory(
      LoadInventory event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    try {
      final inventory = await inventoryRepository.getInventory();


      emit(InventoryLoaded(inventory));
    } catch (e,s) {

      debugPrint("error $e stack $s");
      emit(InventoryError(e.toString()));
    }
  }

}
