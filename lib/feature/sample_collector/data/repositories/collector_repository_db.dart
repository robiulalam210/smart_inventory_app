import '../../../../core/database/database_info.dart';
import '../model/collector_model.dart';

class CollectorRepositoryDb {
  final DatabaseHelper dbHelper = DatabaseHelper();


  Future<List<CollectorLocalModel>> getCollector() async {
    final db = await dbHelper.database;

    final result = db.select('SELECT * FROM collectors  ');

    if (result.isEmpty) {}

    return result.map((map) => CollectorLocalModel.fromMap(map)).toList();
  }
}
