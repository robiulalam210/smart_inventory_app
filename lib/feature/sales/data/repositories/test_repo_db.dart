import '../../../../core/database/database_info.dart';
import '../models/tests_model/test_categories_model.dart';
import '../models/tests_model/tests_model.dart';


class TestRepository {
  DatabaseHelper dbHelper = DatabaseHelper();

  Future<List<TestLocalModel>> getTests() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    final result = db.select('SELECT * FROM test_names');

    if (result.isEmpty) {}

    return result.map((map) => TestLocalModel.fromMap(map)).toList();
  }

  Future<List<TestCategoriesLocalModel>> getTestsCategories() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    final result = db.select('SELECT * FROM test_categories');

    if (result.isEmpty) {}

    return result.map((map) => TestCategoriesLocalModel.fromMap(map)).toList();
  }
}
