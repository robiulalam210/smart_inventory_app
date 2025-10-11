
import '../../../../core/database/database_info.dart';
import '../models/print_layout_model.dart';

class PrintLayoutRepoDb {
  DatabaseHelper dbHelper = DatabaseHelper();

  /// Fetch all fetchPrintLayout records.
  Future<PrintLayoutModel?> fetchPrintLayout() async {
    final db = await dbHelper.database;

    try {
      final result = db.select('SELECT * FROM print_layouts LIMIT 1');

      if (result.isNotEmpty) {
        return PrintLayoutModel.fromJson(result.first);
      } else {
        return null; // no rows found
      }
    } catch (e) {

      throw Exception("Error fetching print_layouts: $e");
    }
  }
}
