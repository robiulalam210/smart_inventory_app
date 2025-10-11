// To parse this JSON data, do
//
//     final reportInformationModel = reportInformationModelFromJson(jsonString);

import 'dart:convert';

ReportInformationModel reportInformationModelFromJson(String str) => ReportInformationModel.fromJson(json.decode(str));

String reportInformationModelToJson(ReportInformationModel data) => json.encode(data.toJson());

class ReportInformationModel {
  final int? status;
  final String? message;
  final Report? report;

  ReportInformationModel({
    this.status,
    this.message,
    this.report,
  });

  factory ReportInformationModel.fromJson(Map<String, dynamic> json) => ReportInformationModel(
    status: json["status"],
    message: json["message"],
    report: json["report"] == null ? null : Report.fromJson(json["report"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "report": report?.toJson(),
  };
}

class Report {
  final int? id;
  final int? saasBranchId;
  final String? saasBranchName;
  final String? invoiceId;
  final String? invoiceNo;
  final String? patientId;
  final String? testId;
  final String? testName;
  final String? testGroup;
  final String? testCategory;
  final String? gender;
  final String? technicianName;
  final String? technicianSign;
  final String? validator;
  final String? reportConfirm;
  final dynamic status;
  final String? remark;
  final dynamic radiogyReportImage;
  final String? radiologyReportDetails;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Specimen?  specimen;

  final List<Detail>? details;
  final List<ReportParameterGroup>? parameterGroup;

  Report({
    this.id,
    this.saasBranchId,
    this.saasBranchName,
    this.invoiceId,
    this.invoiceNo,
    this.patientId,
    this.testId,
    this.testName,
    this.testGroup,
    this.testCategory,
    this.gender,
    this.technicianName,
    this.technicianSign,
    this.validator,
    this.reportConfirm,
    this.status,
    this.remark,
    this.radiogyReportImage,
    this.radiologyReportDetails,
    this.createdAt,
    this.updatedAt,
    this.specimen,
    this.details,
    this.parameterGroup,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json["id"],
    saasBranchId: json["saas_branch_id"],
    saasBranchName: json["saas_branch_name"],
    invoiceId: json["invoice_id"],
    invoiceNo: json["invoice_no"],
    patientId: json["patient_id"],
    testId: json["test_id"],
    testName: json["test_name"],
    testGroup: json["test_group"],
    testCategory: json["test_category"],
    gender: json["gender"],
    technicianName: json["technician_name"],
    technicianSign: json["technician_sign"],
    validator: json["validator"],
    reportConfirm: json["report_confirm"],
    status: json["status"],
    remark: json["remark"],
    radiogyReportImage: json["radiogyReportImage"],
    radiologyReportDetails: json["radiologyReportDetails"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    specimen: json["specimen"] == null ? null : Specimen.fromJson(json["specimen"]),

    details: json["details"] == null ? [] : List<Detail>.from(json["details"]!.map((x) => Detail.fromJson(x))),
    parameterGroup: json["parameter_group"] == null ? [] : List<ReportParameterGroup>.from(json["parameter_group"]!.map((x) => ReportParameterGroup.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "saas_branch_id": saasBranchId,
    "saas_branch_name": saasBranchName,
    "invoice_id": invoiceId,
    "invoice_no": invoiceNo,
    "patient_id": patientId,
    "test_id": testId,
    "test_name": testName,
    "test_group": testGroup,
    "test_category": testCategory,
    "gender": gender,
    "technician_name": technicianName,
    "technician_sign": technicianSign,
    "validator": validator,
    "report_confirm": reportConfirm,
    "status": status,
    "remark": remark,
    "radiogyReportImage": radiogyReportImage,
    "radiologyReportDetails": radiologyReportDetails,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "specimen": specimen,

    "details": details == null ? [] : List<dynamic>.from(details!.map((x) => x.toJson())),
    "parameter_group": parameterGroup == null ? [] : List<dynamic>.from(parameterGroup!.map((x) => x.toJson())),
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

class Detail {
  final int? id;
  final int? reportId;
  final String? testId;
  final String? patientId;
  final String? invoiceId;
  final dynamic parameterId;
  final String? parameterName;
   String? result; // keep final
  final String? unit;
  final String? lowerValue;
  final String? upperValue;
  final String? flag;
  final String? labNo;
  final String? parameterGroupId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DetailParameter? parameter;

   Detail({
    this.id,
    this.reportId,
    this.testId,
    this.patientId,
    this.invoiceId,
    this.parameterId,
    this.parameterName,
    this.result,
    this.unit,
    this.lowerValue,
    this.upperValue,
    this.flag,
    this.labNo,
    this.parameterGroupId,
    this.createdAt,
    this.updatedAt,
    this.parameter,
  });

  Detail copyWith({
    int? id,
    int? reportId,
    String? testId,
    String? patientId,
    String? invoiceId,
    dynamic parameterId,
    String? parameterName,
    String? result,
    String? unit,
    String? lowerValue,
    String? upperValue,
    String? flag,
    String? labNo,
    String? parameterGroupId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DetailParameter? parameter,
  }) {
    return Detail(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      testId: testId ?? this.testId,
      patientId: patientId ?? this.patientId,
      invoiceId: invoiceId ?? this.invoiceId,
      parameterId: parameterId ?? this.parameterId,
      parameterName: parameterName ?? this.parameterName,
      result: result ?? this.result,
      unit: unit ?? this.unit,
      lowerValue: lowerValue ?? this.lowerValue,
      upperValue: upperValue ?? this.upperValue,
      flag: flag ?? this.flag,
      labNo: labNo ?? this.labNo,
      parameterGroupId: parameterGroupId ?? this.parameterGroupId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parameter: parameter ?? this.parameter,
    );
  }

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    id: json["id"],
    reportId: json["report_id"],
    testId: json["test_id"],
    patientId: json["patient_id"],
    invoiceId: json["invoice_id"],
    parameterId: json["parameter_id"],
    parameterName: json["parameter_name"],
    result: json["result"],
    unit: json["unit"],
    lowerValue: json["lower_value"],
    upperValue: json["upper_value"],
    flag: json["flag"],
    labNo: json["lab_no"],
    parameterGroupId: json["parameter_group_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    parameter: json["parameter"] == null ? null : DetailParameter.fromJson(json["parameter"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "report_id": reportId,
    "test_id": testId,
    "patient_id": patientId,
    "invoice_id": invoiceId,
    "parameter_id": parameterId,
    "parameter_name": parameterName,
    "result": result,
    "unit": unit,
    "lower_value": lowerValue,
    "upper_value": upperValue,
    "flag": flag,
    "lab_no": labNo,
    "parameter_group_id": parameterGroupId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "parameter": parameter?.toJson(),
  };
}

class DetailParameter {
  final dynamic id;
  final String? parameterName;
  final String? parameterUnit;
  final String? referenceValue;
  final List<dynamic>? options;
  final int? showOptions;
  final String? parameterGroupId;

  DetailParameter({
    this.id,
    this.parameterName,
    this.parameterUnit,
    this.referenceValue,
    this.options,
    this.showOptions,
    this.parameterGroupId,
  });

  factory DetailParameter.fromJson(Map<String, dynamic> json) => DetailParameter(
    id: json["id"],
    parameterName: json["parameter_name"],
    parameterUnit: json["parameter_unit"],
    referenceValue: json["reference_value"],
    options: json["options"] == null ? [] : List<dynamic>.from(json["options"]!.map((x) => x)),
    showOptions: json["show_options"],
    parameterGroupId: json["parameter_group_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "parameter_name": parameterName,
    "parameter_unit": parameterUnit,
    "reference_value": referenceValue,
    "options": options == null ? [] : List<dynamic>.from(options!.map((x) => x)),
    "show_options": showOptions,
    "parameter_group_id": parameterGroupId,
  };
}

class ReportParameterGroup {
  final int? id;
  final int? testNameId;
  final String? groupName;
  final int? hidden;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ParameterElement>? parameter;

  ReportParameterGroup({
    this.id,
    this.testNameId,
    this.groupName,
    this.hidden,
    this.createdAt,
    this.updatedAt,
    this.parameter,
  });

  factory ReportParameterGroup.fromJson(Map<String, dynamic> json) => ReportParameterGroup(
    id: json["id"],
    testNameId: json["test_name_id"],
    groupName: json["group_name"],
    hidden: json["hidden"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    parameter: json["parameter"] == null ? [] : List<ParameterElement>.from(json["parameter"]!.map((x) => ParameterElement.fromJson(x))),
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

class ParameterElement {
  final int? id;
  final int? testId;
  final String? parameterName;
  final String? parameterUnit;
  final String? referenceValue;
  final int? showOptions;
  final String? options;
  final int? parameterGroupId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ParameterElement({
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
  });

  factory ParameterElement.fromJson(Map<String, dynamic> json) => ParameterElement(
    id: json["id"],
    testId: json["test_id"],
    parameterName: json["parameter_name"],
    parameterUnit: json["parameter_unit"],
    referenceValue: json["reference_value"],
    showOptions: json["show_options"],
    options: json["options"],
    parameterGroupId: json["parameter_group_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
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
  };
}
