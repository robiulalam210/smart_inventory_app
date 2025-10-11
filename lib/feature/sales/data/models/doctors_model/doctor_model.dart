class DoctorLocalModel {
  final int? id;
  final int? orgDoctorId;
  final String? name;
  final String? phone;
  final String? age;
  final String? degree;

  DoctorLocalModel({
    this.id,
    this.orgDoctorId,
    required this.name,
    required this.phone,
    required this.age,
    required this.degree,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'org_doctor_id': orgDoctorId,
      'name': name,
      'phone': phone,
      'age': age,
      'degree': degree,
    };
  }

  factory DoctorLocalModel.fromMap(Map<String, dynamic> map) {
    return DoctorLocalModel(
      id: map['id'],
      orgDoctorId: map['org_doctor_id'],
      name: map['name'],
      phone: map['phone'],
      age: map['age'],
      degree: map['degree'],
    );
  }

  @override
  String toString() {
    return "$name ($degree)";
  }
}
