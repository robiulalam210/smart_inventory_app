

import '../../../../core/database/database_info.dart';
import '../models/patient_model/patient_model.dart';

class PatientRepository {
  // final DatabaseHelper dbHelper;
  final DatabaseHelper dbHelper = DatabaseHelper();

  /// Fetch all patient records.
  Future<List<PatientLocalModel>> fetchAllPatients() async {
    final db = await dbHelper.database;

    try {
      final result = db.select('''
  SELECT 
    p.*, 
    g.name AS gender_name, 
    b.name AS blood_group_name
  FROM patients p
  LEFT JOIN genders g ON p.gender = g.id
  LEFT JOIN blood_groups b ON p.blood_group = b.id
''');

      return result.map((row) => PatientLocalModel.fromMap(row)).toList();
    } catch (e) {
      throw Exception("Error fetching patients: $e");
    }
  }
}
