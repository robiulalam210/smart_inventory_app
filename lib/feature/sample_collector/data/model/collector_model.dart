class CollectorLocalModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final int? saasBranchId;
  final String? saasBranchName;
  final String? address;
  final String? createdAt;
  final String? updatedAt;

  CollectorLocalModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.saasBranchId,
    this.saasBranchName,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  @override
  String toString() {
    return name;
  }
  factory CollectorLocalModel.fromMap(Map<String, Object?> map) {
    return CollectorLocalModel(
      id: map['id'] as int,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      saasBranchId: map['saas_branch_id'] as int?,
      saasBranchName: map['saas_branch_name'] as String?,
      address: map['address'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }
}