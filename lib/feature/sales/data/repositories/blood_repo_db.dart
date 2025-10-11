
import '../../../../core/database/database_info.dart';
import '../models/common_model.dart';
class BloodGroupRepositories {
  DatabaseHelper dbHelper = DatabaseHelper();
/// Fetch all patient records.
Future<List<BloodGroupLocalModel>> fetchAllBloodGroup() async {
  final db = await dbHelper.database;

  try {
    final result = db.select('SELECT * FROM blood_groups');
    return result.map((row) => BloodGroupLocalModel.fromMap(row)).toList();
  } catch (e) {
    throw Exception("Error fetching blood_groups: $e");
  }
}}