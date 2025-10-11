import '../../../../core/database/database_info.dart';
import '../model/booth_model.dart';

class BoothRepository {
  final DatabaseHelper dbHelper = DatabaseHelper();


  Future<List<BoothLocalModel>> getBooth() async {
    final db = await dbHelper.database;

    final result = db.select('SELECT * FROM booths ');

    if (result.isEmpty) {}

    return result.map((map) => BoothLocalModel.fromMap(map)).toList();
  }
}
