class BoothLocalModel {
  final int id;
  final int? saasBranchId;
  final String? saasBranchName;
  final int branchId;
  final String name;
  final String? boothNo;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  BoothLocalModel({
    required this.id,
    this.saasBranchId,
    this.saasBranchName,
    required this.branchId,
    required this.name,
    this.boothNo,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  @override
  String toString() {
    return name;
  }
  factory BoothLocalModel.fromMap(Map<String, Object?> map) {
    return BoothLocalModel(
      id: map['id'] as int,
      saasBranchId: map['saas_branch_id'] as int?,
      saasBranchName: map['saas_branch_name'] as String?,
      branchId: map['branch_id'] as int,
      name: map['name'] as String,
      boothNo: map['booth_no'] as String?,
      status: map['status'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }
}
