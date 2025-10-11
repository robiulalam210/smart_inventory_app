import '/feature/lab_billing/data/models/common_model.dart';

import '../../../../core/database/database_info.dart';

class GenderRepositories {
  DatabaseHelper dbHelper = DatabaseHelper();

  /// Fetch all patient records.
  Future<List<GenderLocalModel>> fetchAllGender() async {
    final db = await dbHelper.database;

    try {
      final result = db.select('SELECT * FROM genders');
      return result.map((row) => GenderLocalModel.fromMap(row)).toList();
    } catch (e) {
      throw Exception("Error fetching genders: $e");
    }
  }
}
