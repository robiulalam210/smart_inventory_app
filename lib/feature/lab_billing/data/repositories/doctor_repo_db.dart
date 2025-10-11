import '../../../../core/database/database_info.dart';
import '../models/doctors_model/doctor_model.dart';

class DoctorRepository {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<List<DoctorLocalModel>> getDoctors() async {
    final db = await dbHelper.database;

    final result = db.select('SELECT * FROM doctors');

    if (result.isEmpty) {}

    return result.map((map) => DoctorLocalModel.fromMap(map)).toList();
  }
}
