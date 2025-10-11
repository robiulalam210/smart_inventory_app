class TestCategoriesLocalModel {
  final int? id;
  final int? orgTestCategoryId;
  final String? name;

  TestCategoriesLocalModel({
     this.id,
    this.orgTestCategoryId,
     this.name,
  });

  factory TestCategoriesLocalModel.fromMap(Map<String, dynamic> map) {
    return TestCategoriesLocalModel(
      id: map['id'],
      orgTestCategoryId: map['org_test_category_id'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'org_test_category_id': orgTestCategoryId,
      'name': name,
    };
  }
  List<Object?> get props => [name, orgTestCategoryId];

}
