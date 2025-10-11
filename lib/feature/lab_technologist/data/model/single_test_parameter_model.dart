

import 'dart:convert';

SingleTestInformationModel singleTestInformationModelFromJson(String str) => SingleTestInformationModel.fromJson(json.decode(str));

String singleTestInformationModelToJson(SingleTestInformationModel data) => json.encode(data.toJson());

class SingleTestInformationModel {
  final int? status;
  final TestName? testName;

  SingleTestInformationModel({
    this.status,
    this.testName,
  });

  factory SingleTestInformationModel.fromJson(Map<String, dynamic> json) => SingleTestInformationModel(
    status: json["status"],
    testName: json["test_name"] == null ? null : TestName.fromJson(json["test_name"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "test_name": testName?.toJson(),
  };
}

class TestName {
  final int? id;
  final int? testCategoryId;
  final int? orgTestNameId;
  final String? name;
  final dynamic code;
  final int? fee;
  final int? discountApplied;
  final int? discount;
  final int? testGroupId;
  final dynamic testSubCategoryId;
  final dynamic parameterGroupId;
  final dynamic status;
  final int? hideTestName;
  final String? createdAt;
  final String? testCategoryName;
  final String? testGroupName;
  final dynamic testSubCategoryName;
  final TestCategory? category;
  final dynamic subCategory;
  final List<ParameterGroup>? parameterGroup;
  final List<TestParameter>? labParameter;
  final Specimen?  specimen;

  TestName({
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
    this.parameterGroupId,
    this.status,
    this.hideTestName,
    this.createdAt,
    this.testCategoryName,
    this.testGroupName,
    this.testSubCategoryName,
    this.category,
    this.subCategory,
    this.parameterGroup,
    this.labParameter,
    this.specimen,
  });

  factory TestName.fromJson(Map<String, dynamic> json) => TestName(
    id: json["id"],
    testCategoryId: json["test_category_id"],
    orgTestNameId: json["org_test_name_id"],
    name: json["name"],
    code: json["code"],
    fee: json["fee"],
    discountApplied: json["discount_applied"],
    discount: json["discount"],
    testGroupId: json["test_group_id"],
    testSubCategoryId: json["test_sub_category_id"],
    parameterGroupId: json["parameter_group_id"],
    status: json["status"],
    hideTestName: json["hide_test_name"],
    createdAt: json["created_at"],
    testCategoryName: json["test_category_name"],
    testGroupName: json["test_group_name"],
    testSubCategoryName: json["test_sub_category_name"],
    category: json["category"] == null ? null : TestCategory.fromJson(json["category"]),
    specimen: json["specimen"] == null ? null : Specimen.fromJson(json["specimen"]),
    subCategory: json["sub_category"],
    parameterGroup: json["parameter_group"] == null ? [] : List<ParameterGroup>.from(json["parameter_group"]!.map((x) => ParameterGroup.fromJson(x))),
    labParameter: json["lab_parameter"] == null ? [] : List<TestParameter>.from(json["lab_parameter"]!.map((x) => TestParameter.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "test_category_id": testCategoryId,
    "org_test_name_id": orgTestNameId,
    "name": name,
    "code": code,
    "fee": fee,
    "discount_applied": discountApplied,
    "discount": discount,
    "test_group_id": testGroupId,
    "test_sub_category_id": testSubCategoryId,
    "parameter_group_id": parameterGroupId,
    "status": status,
    "hide_test_name": hideTestName,
    "created_at": createdAt,
    "test_category_name": testCategoryName,
    "test_group_name": testGroupName,
    "test_sub_category_name": testSubCategoryName,
    "category": category?.toJson(),
    "sub_category": subCategory,
    "specimen": specimen?.toJson(),
    "parameter_group": parameterGroup == null ? [] : List<dynamic>.from(parameterGroup!.map((x) => x.toJson())),
    "lab_parameter": labParameter == null ? [] : List<dynamic>.from(labParameter!.map((x) => x.toJson())),
  };
}
class Specimen {
  final int id;
  final String name;
  final String? createdAt;
  final String? updatedAt;

  Specimen({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory Specimen.fromJson(Map<String, Object?> json) {
    return Specimen(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class TestCategory {
  final int? id;
  final String? testCategoryName;

  TestCategory({
    this.id,
    this.testCategoryName,
  });

  factory TestCategory.fromJson(Map<String, dynamic> json) => TestCategory(
    id: json["id"],
    testCategoryName: json["test_category_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "test_category_name": testCategoryName,
  };
}

class TestParameter {
  final int? id;
  final int? testId;
  final String? parameterName;
  final String? parameterUnit;
  final String? referenceValue;
  final int? showOptions;
  final dynamic options;
  final int? parameterGroupId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // NEW: store user-entered result
  String? result;

  TestParameter({
    this.id,
    this.testId,
    this.parameterName,
    this.parameterUnit,
    this.referenceValue,
    this.showOptions,
    this.options,
    this.parameterGroupId,
    this.createdAt,
    this.updatedAt,
    this.result,
  });

  factory TestParameter.fromJson(Map<String, dynamic> json) => TestParameter(
    id: json["id"],
    testId: json["test_id"],
    parameterName: json["parameter_name"],
    parameterUnit: json["parameter_unit"],
    referenceValue: json["reference_value"],
    showOptions: json["show_options"],
    options: json["options"],
    parameterGroupId: json["parameter_group_id"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    result: json["result"], // NEW
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "test_id": testId,
    "parameter_name": parameterName,
    "parameter_unit": parameterUnit,
    "reference_value": referenceValue,
    "show_options": showOptions,
    "options": options,
    "parameter_group_id": parameterGroupId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "result": result, // NEW
  };
}

class ParameterGroup {
  final int? id;
  final int? testNameId;
  final String? groupName;
  final int? hidden;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<TestParameter>? parameter;

  ParameterGroup({
    this.id,
    this.testNameId,
    this.groupName,
    this.hidden,
    this.createdAt,
    this.updatedAt,
    this.parameter,
  });

  factory ParameterGroup.fromJson(Map<String, dynamic> json) => ParameterGroup(
    id: json["id"],
    testNameId: json["test_name_id"],
    groupName: json["group_name"],
    hidden: json["hidden"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    parameter: json["parameter"] == null ? [] : List<TestParameter>.from(json["parameter"]!.map((x) => TestParameter.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "test_name_id": testNameId,
    "group_name": groupName,
    "hidden": hidden,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "parameter": parameter == null ? [] : List<dynamic>.from(parameter!.map((x) => x.toJson())),
  };
}
