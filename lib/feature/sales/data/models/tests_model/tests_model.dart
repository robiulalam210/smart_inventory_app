class TestLocalModel {
  final int? id;
  final dynamic testCategoryId;
  final dynamic orgTestNameId;
  final String? name;
  final String? code;
  final double? fee;
  final int? discountApplied;
  final double? discount;
  final dynamic testGroupId;
  final dynamic testSubCategoryId;
  final String? status;
  final String? createdAt;
  final String? testCategoryName;
  final String? testGroupName;
  final String? testSubCategoryName;

  TestLocalModel({
    this.id,
    this.testCategoryId,
    this.orgTestNameId,
    this.name,
    this.code,
    this.fee,
    this.discountApplied,
    this.discount,
    this.testGroupId,
    this.testSubCategoryId,
    this.status,
    this.createdAt,
    this.testCategoryName,
    this.testGroupName,
    this.testSubCategoryName,
  });

  factory TestLocalModel.fromMap(Map<String, dynamic> map) {
    return TestLocalModel(
      id: map['id'] as int?,
      testCategoryId: map['test_category_id'],
      orgTestNameId: map['org_test_name_id'],
      name: map['name'] as String?,
      code: map['code'] as String?,
      fee: map['fee'] != null ? (map['fee'] as num).toDouble() : null,
      discountApplied: map['discount_applied'] as int?,
      discount: map['discount'] != null ? (map['discount'] as num).toDouble() : null,
      testGroupId: map['test_group_id'] as int?,
      testSubCategoryId: map['test_sub_category_id'],
      status: map['status'] as String?,
      createdAt: map['created_at'] as String?,
      testCategoryName: map['test_category_name'] as String?,
      testGroupName: map['test_group_name'] as String?,
      testSubCategoryName: map['test_sub_category_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'test_category_id': testCategoryId,
      'org_test_name_id': orgTestNameId,
      'name': name,
      'code': code,
      'fee': fee,
      'discount_applied': discountApplied,
      'discount': discount,
      'test_group_id': testGroupId,
      'test_sub_category_id': testSubCategoryId,
      'status': status,
      'created_at': createdAt,
      'test_category_name': testCategoryName,
      'test_group_name': testGroupName,
      'test_sub_category_name': testSubCategoryName,
    };
  }

  @override
  String toString() {
    return '$name ${code ?? ""} Amount: $fee';
  }
}
