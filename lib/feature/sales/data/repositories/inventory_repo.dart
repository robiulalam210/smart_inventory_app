

import '../../../../core/database/database_info.dart';
import '../models/inventory_model/inventory_model.dart';

class InventoryRepository {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<List<InventoryLocalProduct>> getInventory() async {
    final db = await dbHelper.database;
    final result = db.select('SELECT * FROM inventory');

    return result.map((map) => InventoryLocalProduct.fromMap(map)).toList();
  }
}
