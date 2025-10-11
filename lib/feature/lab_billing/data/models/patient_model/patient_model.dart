class PatientLocalModel {
  final int id;
  final int orgPatientId;
  final String name;
  final String phone;
  final dynamic age;
  final String dob;
  final int gender;
  final int bloodGroup;
  final String address;

  // ✅ NEW fields
  final String hnNumber;
  final String visitType;
  final String createDate;

  // Optional display fields (from JOIN)
  final String? genderName;
  final String? bloodGroupName;

  PatientLocalModel({
    required this.id,
    required this.orgPatientId,
    required this.name,
    required this.phone,
    required this.age,
    required this.dob,
    required this.gender,
    required this.bloodGroup,
    required this.address,
    required this.visitType,
    required this.hnNumber,
    required this.createDate,
    this.genderName,
    this.bloodGroupName,
  });

  factory PatientLocalModel.fromMap(Map<String, dynamic> map) {
    return PatientLocalModel(
      id: map['id'] ?? 0,
      orgPatientId: map['org_patient_id'] ?? 0,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      age: map['age'] ?? '',
      dob: map['date_of_birth'] ?? '',
      gender: map['gender'] is int
          ? map['gender']
          : int.tryParse(map['gender'].toString()) ?? 0,
      bloodGroup: map['blood_group'] is int
          ? map['blood_group']
          : int.tryParse(map['blood_group'].toString()) ?? 0,
      address: map['address'] ?? '',

      // ✅ Map new fields
      hnNumber: map['hn_number'] ?? '',
      visitType: map['visit_type'] ?? '',
      createDate: map['create_date'] ?? '',

      genderName: map['gender_name'],
      bloodGroupName: map['blood_group_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'org_patient_id': orgPatientId,
      'name': name,
      'phone': phone,
      'age': age,
      'date_of_birth': dob,
      'gender': gender,
      'blood_group': bloodGroup,
      'address': address,
      'hn_number': hnNumber,
      'visit_type': visitType,
      'create_date': createDate,
    };
  }
}
