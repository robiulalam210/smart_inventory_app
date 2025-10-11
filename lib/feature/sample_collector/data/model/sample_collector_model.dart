
class SampleCollectorInvoice {
  final int id;
  final String invoiceNumber;
  final String? webId;
  final String? updateDate;
  final String? deliveryDate;
  final String? deliveryTime;
  final String createDate;
  final double totalBillAmount;
  final double due;
  final double paidAmount;
  final double discount;
  final String? discountType;
  final double discountPercentage;
  final String? referType;
  final String? referreIdOrDesc;
  final dynamic createdByUserId;
  final String? createdByName;
  final String? patientWebId;
  final String? collectionStatus;
  final String? sentToLabStatus;
  final String? deliveryStatus;
  final String? reportCollectionStatus;
  final PatientLocalSampleCollector patient;
  final List<InvoiceDetail> details;
  final List<PaymentSample> payments;
  final ReferInfoSample referInfo;
  final int? collectorId;
  final String? collectionDate;
  final String? remark;


  SampleCollectorInvoice({
    required this.id,
    required this.invoiceNumber,
    this.webId,
    this.updateDate,
    this.deliveryDate,
    this.deliveryTime,
    required this.createDate,
    required this.totalBillAmount,
    required this.due,
    required this.paidAmount,
    required this.discount,
    this.discountType,
    required this.discountPercentage,
    this.referType,
    this.referreIdOrDesc,
    this.createdByUserId,
    this.createdByName,
    this.patientWebId,
    this.collectionStatus,
    this.sentToLabStatus,
    this.deliveryStatus,
    this.reportCollectionStatus,
    required this.patient,
    required this.details,
    required this.payments,
    required this.referInfo,
    this.collectorId,
    this.collectionDate,
    this.remark,

  });

  factory SampleCollectorInvoice.fromMap(Map<String, dynamic> map) {
    return SampleCollectorInvoice(
      id: map['invoice_id'] as int,
      invoiceNumber: map['invoice_number'] as String,
      webId: map['webId']?.toString(),
      updateDate: map['update_date']?.toString(),
      deliveryDate: map['delivery_date']?.toString(),
      deliveryTime: map['delivery_time']?.toString(),
      createDate: map['create_date'],
      totalBillAmount: (map['total_bill_amount'] as num).toDouble(),
      due: (map['due'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      discountType: map['discount_type']?.toString(),
      discountPercentage: (map['discount_percentage'] as num).toDouble(),
      referType: map['refer_type']?.toString(),
      referreIdOrDesc: map['referre_id_or_desc']?.toString(),
      createdByUserId: map['created_by_user_id'],
      createdByName: map['created_by_name']?.toString(),
      patientWebId: map['patient_web_id']?.toString(),
      collectionStatus: map['collection_status']?.toString(),
      sentToLabStatus: map['sent_to_lab_status']?.toString(),
      deliveryStatus: map['delivery_status']?.toString(),
      reportCollectionStatus: map['report_collection_status']?.toString(),
      patient: PatientLocalSampleCollector.fromMap(map['patient'] as Map<String, dynamic>),
      details: (map['invoice_details'] as List<dynamic>)
          .map((e) => InvoiceDetail.fromMap(e as Map<String, dynamic>))
          .toList(),
      payments: (map['payments'] as List<dynamic>)
          .map((e) => PaymentSample.fromMap(e as Map<String, dynamic>))
          .toList(),
      referInfo: ReferInfoSample.fromMap(map['refer_info'] as Map<String, dynamic>),
      collectorId: map['collector_id'] as int?,
      collectionDate: map['collection_date']?.toString(),
      remark: map['remark']?.toString(),


    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoice_id': id,
      'invoice_number': invoiceNumber,
      'webId': webId,
      'update_date': updateDate,
      'delivery_date': deliveryDate,
      'delivery_time': deliveryTime,
      'create_date': createDate,
      'total_bill_amount': totalBillAmount,
      'due': due,
      'paid_amount': paidAmount,
      'discount': discount,
      'discount_type': discountType,
      'discount_percentage': discountPercentage,
      'refer_type': referType,
      'referre_id_or_desc': referreIdOrDesc,
      'created_by_user_id': createdByUserId,
      'created_by_name': createdByName,
      'patient_web_id': patientWebId,
      'collection_status': collectionStatus,
      'sent_to_lab_status': sentToLabStatus,
      'delivery_status': deliveryStatus,
      'report_collection_status': reportCollectionStatus,
      'patient': patient.toMap(),
      'invoice_details': details.map((e) => e.toMap()).toList(),
      'payments': payments.map((e) => e.toMap()).toList(),
      'refer_info': referInfo.toMap(),
      'collector_id': collectorId,
      'collection_date': collectionDate,
      'remark': remark,

    };
  }

  @override
  String toString() {
    return 'SampleCollectorInvoice(id: $id, invoiceNumber: $invoiceNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SampleCollectorInvoice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}


class PatientLocalSampleCollector {
  final int id;
  final String name;
  final String phone;
  final String age;
  final String month;
  final String day;
  final String gender;
  final String bloodGroup;
  final String address;
  final String dateOfBirth;
  final String visitType;
  final String hnNumber;
  final String createDate;

  PatientLocalSampleCollector({
    required this.id,
    required this.name,
    required this.phone,
    required this.age,
    required this.month,
    required this.day,
    required this.gender,
    required this.bloodGroup,
    required this.address,
    required this.dateOfBirth,
    required this.visitType,
    required this.hnNumber,
    required this.createDate,
  });

  factory PatientLocalSampleCollector.fromMap(Map<String, dynamic> map) {
    return PatientLocalSampleCollector(
      id: map['id'] ?? 0,
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      age: map['age']?.toString() ?? '',
      month: map['month']?.toString() ?? '',
      day: map['day']?.toString() ?? '',
      gender: map['gender']?.toString() ?? '',
      bloodGroup: map['bloodGroup']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      dateOfBirth: map['dateOfBirth']?.toString() ?? '',
      visitType: map['visit_type']?.toString() ?? '',
      hnNumber: map['hn_number']?.toString() ?? '',
      createDate: map['create_date']?.toString() ?? '',
    );
  }

  factory PatientLocalSampleCollector.empty() {
    return PatientLocalSampleCollector(
      id: 0,
      name: '',
      phone: '',
      age: '',
      month: '',
      day: '',
      gender: '',
      bloodGroup: '',
      address: '',
      dateOfBirth: '',
      visitType: '',
      hnNumber: '',
      createDate: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'age': age,
      'month': month,
      'day': day,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'address': address,
      'dateOfBirth': dateOfBirth,
      'visit_type': visitType,
      'hn_number': hnNumber,
      'create_date': createDate,
    };
  }
}
class Collector {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? address;

  Collector({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
  });

  factory Collector.fromMap(Map<String, dynamic> map) {
    return Collector(
      id: map['id'] as int?,
      name: map['name']?.toString(),
      phone: map['phone']?.toString(),
      email: map['email']?.toString(),
      address: map['address']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }
}

class Booth {
  final int? id;
  final String? name;
  final String? boothNo;
  final String? status;

  Booth({
    this.id,
    this.name,
    this.boothNo,
    this.status,
  });

  factory Booth.fromMap(Map<String, dynamic> map) {
    return Booth(
      id: map['id'] as int?,
      name: map['name']?.toString(),
      boothNo: map['booth_no']?.toString(),
      status: map['status']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'booth_no': boothNo,
      'status': status,
    };
  }
}

class InvoiceDetail {
  final int? detailId; // PK from invoice_details
  final String type; // 'Test' or 'Inventory'
  final int? testId;
  final String? testName;
  final String? testCode;
  final int? inventoryId;
  final String? inventoryName;
  final double fee;
  final int qty;
  final bool? isRefund;
  final double discount;
  final String? collectionDate;
  final int? collectorId;
  final String? collectionStatus;
   bool? isReady;
  final String? remark;
  final Collector? collector;
  final Booth? booth;
  // ✅ Link TestInfo
  final TestInfo? testInfo;
  final LabReport? labReport;

  // Report / status fields
   String? reportConfirmedStatus;
  final String? reportApproveStatus;
  final String? reportAddStatus;
  final String? deliveryStatus;
  final String? sentToLabStatus;
  final String? reportCollectionStatus;
  final String? point;
  final String? pointPercent;

  InvoiceDetail({
    this.detailId,
    required this.type,
    this.testId,
    this.testName,
    this.testCode,
    this.inventoryId,
    this.inventoryName,
    required this.fee,
    required this.qty,
    required this.discount,
    this.collectionDate,
    this.collectorId,
    this.collectionStatus,
    this.isReady,
    this.remark,
    this.isRefund,
    this.collector,
    this.booth,
    this.testInfo,
    this.labReport,
    this.reportConfirmedStatus,
    this.reportApproveStatus,
    this.reportAddStatus,
    this.deliveryStatus,
    this.sentToLabStatus,
    this.reportCollectionStatus,
    this.point,
    this.pointPercent,
  });

  factory InvoiceDetail.fromMap(Map<String, dynamic> map) {
    String? numToStr(dynamic value) => value?.toString();

    return InvoiceDetail(
      detailId: map['detail_id'] as int?,
      type: map['type']?.toString() ?? 'Test',
      testId: map['test_id'] as int?,
      testName: map['test_name']?.toString(),
      testCode: map['test_code']?.toString(),
      inventoryId: map['inventory_id'] as int?,
      inventoryName: map['inventory_name']?.toString(),
      fee: (map['fee'] as num).toDouble(),
      qty: map['qty'] as int,
      isRefund: map['is_refund'] as bool?,
      discount: (map['discount'] as num).toDouble(),
      collectionDate: map['collection_date']?.toString(),
      collectorId: map['collector_id'] as int?,
      collectionStatus: map['collection_status']?.toString(),
      remark: map['remark']?.toString(),
      collector: map['collector'] != null
          ? Collector.fromMap(map['collector'] as Map<String, dynamic>)
          : null,
      booth: map['booth'] != null
          ? Booth.fromMap(map['booth'] as Map<String, dynamic>)
          : null,
      testInfo: map['test_info'] != null
          ? TestInfo.fromMap(map['test_info'] as Map<String, dynamic>)
          : null,
      labReport: map['lab_report'] as LabReport?,


      reportConfirmedStatus: numToStr(map['report_confirmed_status']),
      reportApproveStatus: numToStr(map['report_approve_status']),
      reportAddStatus: numToStr(map['report_add_status']),
      deliveryStatus: numToStr(map['delivery_status']),
      sentToLabStatus: numToStr(map['sent_to_lab_status']),
      reportCollectionStatus: numToStr(map['reportCollectionStatus']),
      point: numToStr(map['point']),
      pointPercent: numToStr(map['point_percent']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'detail_id': detailId,
      'type': type,
      'test_id': testId,
      'test_name': testName,
      'test_code': testCode,
      'inventory_id': inventoryId,
      'inventory_name': inventoryName,
      'fee': fee,
      'qty': qty,
      'is_refund': isRefund,
      'discount': discount,
      'collection_date': collectionDate,
      'collector_id': collectorId,
      'collection_status': collectionStatus,
      'remark': remark,
      'collector': collector?.toMap(),
      'booth': booth?.toMap(),
      'test_info': testInfo?.toMap(),
      'lab_report': labReport?.toJson(),

      'report_confirmed_status': reportConfirmedStatus,
      'report_approve_status': reportApproveStatus,
      'report_add_status': reportAddStatus,
      'delivery_status': deliveryStatus,
      'sent_to_lab_status': sentToLabStatus,
      'reportCollectionStatus': reportCollectionStatus,
      'point': point,
      'point_percent': pointPercent,
    };
  }
}

class LabReport {
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
  final String? status;
  final String? remark;
  final dynamic radiogyReportImage;
  final String? radiologyReportDetails;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SampleSpecimen?  specimen;

  final List<SampleDetail>? details;
  final List<ReportParameterGroupSample>? parameterGroup;

  LabReport({
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

  factory LabReport.fromJson(Map<String, dynamic> json) => LabReport(
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
    specimen: json["specimen"] == null ? null : SampleSpecimen.fromJson(json["specimen"]),

    details: json["details"] == null ? [] : List<SampleDetail>.from(json["details"]!.map((x) => SampleDetail.fromJson(x))),
    parameterGroup: json["parameter_group"] == null ? [] : List<ReportParameterGroupSample>.from(json["parameter_group"]!.map((x) => ReportParameterGroupSample.fromJson(x))),
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
class SampleSpecimen {
  final int id;
  final String name;
  final String? createdAt;
  final String? updatedAt;

  SampleSpecimen({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory SampleSpecimen.fromJson(Map<String, Object?> json) {
    return SampleSpecimen(
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

class SampleDetail {
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
  final DetailParameterSample? parameter;

  SampleDetail({
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

  SampleDetail copyWith({
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
    DetailParameterSample? parameter,
  }) {
    return SampleDetail(
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

  factory SampleDetail.fromJson(Map<String, dynamic> json) => SampleDetail(
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
    parameter: json["parameter"] == null ? null : DetailParameterSample.fromJson(json["parameter"]),
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

class DetailParameterSample {
  final dynamic id;
  final String? parameterName;
  final String? parameterUnit;
  final String? referenceValue;
  final List<dynamic>? options;
  final int? showOptions;
  final String? parameterGroupId;

  DetailParameterSample({
    this.id,
    this.parameterName,
    this.parameterUnit,
    this.referenceValue,
    this.options,
    this.showOptions,
    this.parameterGroupId,
  });

  factory DetailParameterSample.fromJson(Map<String, dynamic> json) => DetailParameterSample(
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

class ReportParameterGroupSample {
  final int? id;
  final int? testNameId;
  final String? groupName;
  final int? hidden;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ParameterElementSample>? parameter;

  ReportParameterGroupSample({
    this.id,
    this.testNameId,
    this.groupName,
    this.hidden,
    this.createdAt,
    this.updatedAt,
    this.parameter,
  });

  factory ReportParameterGroupSample.fromJson(Map<String, dynamic> json) => ReportParameterGroupSample(
    id: json["id"],
    testNameId: json["test_name_id"],
    groupName: json["group_name"],
    hidden: json["hidden"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    parameter: json["parameter"] == null ? [] : List<ParameterElementSample>.from(json["parameter"]!.map((x) => ParameterElementSample.fromJson(x))),
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

class ParameterElementSample {
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

  ParameterElementSample({
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

  factory ParameterElementSample.fromJson(Map<String, dynamic> json) => ParameterElementSample(
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
class TestInfo {
  final int id;
  final int orgTestNameId;
  final String name;
  final String? code;
  final double fee;
  final int discountApplied;
  final double discount;

  final int testCategoryId;
  final TestCategory? category;
  final TestGroup? group;

  TestInfo({
    required this.id,
    required this.orgTestNameId,
    required this.name,
    this.code,
    required this.fee,
    required this.discountApplied,
    required this.discount,
    required this.testCategoryId,
    this.category,
    this.group,
  });

  factory TestInfo.fromMap(Map<String, dynamic> map) {
    return TestInfo(
      id: (map['id'] as num).toInt(),
      orgTestNameId: (map['org_test_name_id'] as num).toInt(),
      name: map['name']?.toString() ?? '',
      code: map['code']?.toString(),
      fee: (map['fee'] as num?)?.toDouble() ?? 0.0,
      discountApplied: (map['discountApplied'] as num?)?.toInt() ?? 0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      testCategoryId: (map['testCategoryId'] as num?)?.toInt() ?? 0,
      category: map['testCategory'] != null
          ? TestCategory.fromMap(Map<String, dynamic>.from(map['testCategory']))
          : null,
      group: map['testGroup'] != null
          ? TestGroup.fromMap(Map<String, dynamic>.from(map['testGroup']))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'org_test_name_id': orgTestNameId,
      'name': name,
      'code': code,
      'fee': fee,
      'discountApplied': discountApplied,
      'discount': discount,
      'testCategoryId': testCategoryId,
      'testCategory': category?.toMap(),
      'testGroup': group?.toMap(),
    };
  }
}

class TestCategory {
  final int id;
  final String? name;

  TestCategory({required this.id, this.name});

  factory TestCategory.fromMap(Map<String, dynamic> map) {
    return TestCategory(
      id: (map['id'] as num).toInt(),
      name: map['name']?.toString() ?? map['test_category_name']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class TestGroup {
  final int id;
  final String? name;

  TestGroup({required this.id, this.name});

  factory TestGroup.fromMap(Map<String, dynamic> map) {
    return TestGroup(
      id: (map['id'] as num).toInt(),
      name: map['name']?.toString() ?? map['test_group_name']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class PaymentSample {
  final String? webId;
  final String moneyReceiptNumber;
  final String? moneyReceiptType;
  final String paymentType;
  final double amount;
  final double requestedAmount;
  final double dueAmount;
  final int? patientId;
  final String? patientWeb;
  final String invoiceNumber;
  final int? invoiceId;
  final String? paymentDate;
  final int isSync;

  PaymentSample({
    this.webId,
    required this.moneyReceiptNumber,
    this.moneyReceiptType,
    required this.paymentType,
    required this.amount,
    required this.requestedAmount,
    required this.dueAmount,
    this.patientId,
    this.patientWeb,
    required this.invoiceNumber,
    this.invoiceId,
    this.paymentDate,
    this.isSync = 1,
  });

  factory PaymentSample.fromMap(Map<String, dynamic> map) {
    return PaymentSample(
      webId: map['web_id']?.toString(),
      moneyReceiptNumber: map['money_receipt_number'] as String,
      moneyReceiptType: map['money_receipt_type']?.toString(),
      paymentType: map['payment_type'] as String,
      amount: (map['amount'] as num).toDouble(),
      requestedAmount: (map['requested_amount'] as num).toDouble(),
      dueAmount: (map['due_amount'] as num).toDouble(),
      patientId: map['patient_id'] as int?,
      patientWeb: map['patient_web']?.toString(),
      invoiceNumber: map['invoice_number'] as String,
      invoiceId: map['invoice_id'] as int?,
      paymentDate: map['payment_date']?.toString(),
      isSync: map['is_sync'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'web_id': webId,
      'money_receipt_number': moneyReceiptNumber,
      'money_receipt_type': moneyReceiptType,
      'payment_type': paymentType,
      'amount': amount,
      'requested_amount': requestedAmount,
      'due_amount': dueAmount,
      'patient_id': patientId,
      'patient_web': patientWeb,
      'invoice_number': invoiceNumber,
      'invoice_id': invoiceId,
      'payment_date': paymentDate,
      'is_sync': isSync,
    };
  }
}

class ReferInfoSample {
  final String type;
  final String value;
  final int? id;
  final String? name;
  final String? phone;

  ReferInfoSample({
    required this.type,
    required this.value,
    this.id,
    this.name,
    this.phone,
  });

  factory ReferInfoSample.fromMap(Map<String, dynamic> map) {
    return ReferInfoSample(
      type: map['type'] as String,
      value: map['value'] as String,
      id: map['id'] as int?,
      name: map['name']?.toString(),
      phone: map['phone']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'value': value,
      'id': id,
      'name': name,
      'phone': phone,
    };
  }
}

class SampleCollectorInvoiceList {
  final List<SampleCollectorInvoice> invoices;
  final int totalCount;
  final int pageSize;
  final int pageNumber;
  final int totalPages;

  SampleCollectorInvoiceList({
    required this.invoices,
    required this.totalCount,
    required this.pageSize,
    required this.pageNumber,
    required this.totalPages,
  });

  factory SampleCollectorInvoiceList.fromMap(Map<String, dynamic> map) {
    return SampleCollectorInvoiceList(
      invoices: (map['invoices'] as List<dynamic>)
          .map((e) => SampleCollectorInvoice.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalCount: map['totalCount'] as int,
      pageSize: map['pageSize'] as int,
      pageNumber: map['pageNumber'] as int,
      totalPages: map['totalPages'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoices': invoices.map((e) => e.toMap()).toList(),
      'totalCount': totalCount,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
      'totalPages': totalPages,
    };
  }
}