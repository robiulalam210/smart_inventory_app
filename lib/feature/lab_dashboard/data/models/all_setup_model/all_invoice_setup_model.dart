import 'dart:convert';

AllInvoiceSetupModel allInvoiceSetupModelFromJson(String str) =>
    AllInvoiceSetupModel.fromJson(json.decode(str));

String allInvoiceSetupModelToJson(AllInvoiceSetupModel data) =>
    json.encode(data.toJson());

class AllInvoiceSetupModel {
  final List<AllInvoiceData>? data;
  final String? message;
  final int? statusCode;

  AllInvoiceSetupModel({
    this.data,
    this.message,
    this.statusCode,
  });

  factory AllInvoiceSetupModel.fromJson(Map<String, dynamic> json) =>
      AllInvoiceSetupModel(
        data: json["data"] == null
            ? []
            : List<AllInvoiceData>.from(
                json["data"]!.map((x) => AllInvoiceData.fromJson(x))),
        message: json["message"],
        statusCode: json["status_code"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
        "status_code": statusCode,
      };
}

class AllInvoiceData {
  final int? id;
  final int? saasBranchId;
  final String? saasBranchName;
  final String? visitType;
  final String? patientId;
  final String? patientFirstName;
  final String? patientMobilePhone;
  final String? referredBy;
  final String? referrer;
  final dynamic marketer;
  final dynamic pointPlan;
  final dynamic pointPlanMaster;
  final dynamic activePlan;
  final int? pointShare;
  final dynamic pointAmount;
  final String? paymentMethod;
  final dynamic paymentOption;
  final dynamic cardNumber;
  final dynamic expireDate;
  final dynamic digitalPaymentNumber;
  final String? totalBill;
  final DateTime? deliveryDate;
  final String? deliveryTime;
  final String? invoiceNo;
  final String? invoiceNoApp;
  final String? due;
  final int? paidAmount;
  final int? refundAmount;
  final String? specialDiscount;
  final String? discountPercentage;
  final int? discount;
  final dynamic deliveryStatus;
  final dynamic reportReadyStatus;
  final dynamic reportCollectionStatus;
  final dynamic sampleCollectionStatus;
  final dynamic sampleCollectionDate;
  final dynamic remarkForSampleCollection;
  final int? isApprovedInSampleCollection;
  final int? isApprovedInSendToLab;
  final int? isApprovedInReceiveFromLab;
  final dynamic reportReceiverFromLabRemark;
  final dynamic sampleReceiverToLabRemark;
  final int? createdById;
  final String? shiftId;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? billingComment;
  final String? discountType;
  final List<InvoiceSetupTestElement>? tests;
  final List<SetupInventory>? inventory;
  final List<SetupMoneyRecipt>? moneyRecipts;
  final List<Report>? reports; // Added reports field

  AllInvoiceData({
    this.id,
    this.saasBranchId,
    this.saasBranchName,
    this.visitType,
    this.patientId,
    this.patientFirstName,
    this.patientMobilePhone,
    this.referredBy,
    this.referrer,
    this.marketer,
    this.pointPlan,
    this.pointPlanMaster,
    this.activePlan,
    this.pointShare,
    this.pointAmount,
    this.paymentMethod,
    this.paymentOption,
    this.cardNumber,
    this.expireDate,
    this.digitalPaymentNumber,
    this.totalBill,
    this.deliveryDate,
    this.deliveryTime,
    this.invoiceNo,
    this.invoiceNoApp,
    this.due,
    this.paidAmount,
    this.refundAmount,
    this.specialDiscount,
    this.discountPercentage,
    this.discount,
    this.deliveryStatus,
    this.reportReadyStatus,
    this.reportCollectionStatus,
    this.sampleCollectionStatus,
    this.sampleCollectionDate,
    this.remarkForSampleCollection,
    this.isApprovedInSampleCollection,
    this.isApprovedInSendToLab,
    this.isApprovedInReceiveFromLab,
    this.reportReceiverFromLabRemark,
    this.sampleReceiverToLabRemark,
    this.createdById,
    this.shiftId,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.billingComment,
    this.discountType,
    this.tests,
    this.inventory,
    this.moneyRecipts,
    this.reports, // Added to constructor
  });

  factory AllInvoiceData.fromJson(Map<String, dynamic> json) => AllInvoiceData(
    id: json["id"],
    saasBranchId: json["saas_branch_id"],
    saasBranchName: json["saas_branch_name"],
    visitType: json["visit_type"],
    patientId: json["patient_id"],
    patientFirstName: json["patient_first_name"],
    patientMobilePhone: json["patient_mobile_phone"],
    referredBy: json["referredBy"],
    referrer: json["referrer"],
    marketer: json["marketer"],
    pointPlan: json["point_plan"],
    pointPlanMaster: json["point_plan_master"],
    activePlan: json["active_plan"],
    pointShare: json["point_share"],
    pointAmount: json["point_amount"],
    paymentMethod: json["paymentMethod"],
    paymentOption: json["paymentOption"],
    cardNumber: json["cardNumber"],
    expireDate: json["expireDate"],
    digitalPaymentNumber: json["digitalPaymentNumber"],
    totalBill: json["totalBill"],
    deliveryDate: json["deliveryDate"] == null
        ? null
        : parseCustomDate(json["deliveryDate"]),
    deliveryTime: json["deliveryTime"],
    invoiceNo: json["invoiceNo"],
    invoiceNoApp: json["invoiceNo_app"],
    due: json["due"],
    paidAmount: json["paidAmount"],
    refundAmount: json["refundAmount"],
    specialDiscount: json["specialDiscount"],
    discountPercentage: json["discount_percentage"],
    discount: json["discount"],
    deliveryStatus: json["deliveryStatus"],
    reportReadyStatus: json["reportReadyStatus"],
    reportCollectionStatus: json["reportCollectionStatus"],
    sampleCollectionStatus: json["sampleCollectionStatus"],
    sampleCollectionDate: json["sampleCollectionDate"],
    remarkForSampleCollection: json["remarkForSampleCollection"],
    isApprovedInSampleCollection: json["isApprovedInSampleCollection"],
    isApprovedInSendToLab: json["isApprovedInSendToLab"],
    isApprovedInReceiveFromLab: json["isApprovedInReceiveFromLab"],
    reportReceiverFromLabRemark: json["reportReceiverFromLabRemark"],
    sampleReceiverToLabRemark: json["sampleReceiverToLabRemark"],
    createdById: json["created_by_id"],
    shiftId: json["shift_id"],
    createdBy: json["created_by"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    billingComment: json["billingComment"],
    discountType: json["discount_type"],
    tests: json["tests"] == null
        ? []
        : List<InvoiceSetupTestElement>.from(
        json["tests"]!.map((x) => InvoiceSetupTestElement.fromJson(x))),
    inventory: json["inventory"] == null
        ? []
        : List<SetupInventory>.from(
        json["inventory"]!.map((x) => SetupInventory.fromJson(x))),
    moneyRecipts: json["money_recipts_for_app"] == null
        ? []
        : List<SetupMoneyRecipt>.from(json["money_recipts_for_app"]!
        .map((x) => SetupMoneyRecipt.fromJson(x))),
    reports: json["reports"] == null
        ? []
        : List<Report>.from(
        json["reports"]!.map((x) => Report.fromJson(x))), // Added reports parsing
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "saas_branch_id": saasBranchId,
    "saas_branch_name": saasBranchName,
    "visit_type": visitType,
    "patient_id": patientId,
    "patient_first_name": patientFirstName,
    "patient_mobile_phone": patientMobilePhone,
    "referredBy": referredBy,
    "referrer": referrer,
    "marketer": marketer,
    "point_plan": pointPlan,
    "point_plan_master": pointPlanMaster,
    "active_plan": activePlan,
    "point_share": pointShare,
    "point_amount": pointAmount,
    "paymentMethod": paymentMethod,
    "paymentOption": paymentOption,
    "cardNumber": cardNumber,
    "expireDate": expireDate,
    "digitalPaymentNumber": digitalPaymentNumber,
    "totalBill": totalBill,
    "deliveryDate": deliveryDate?.toIso8601String(),
    "deliveryTime": deliveryTime,
    "invoiceNo": invoiceNo,
    "invoiceNo_app": invoiceNoApp,
    "due": due,
    "paidAmount": paidAmount,
    "refundAmount": refundAmount,
    "specialDiscount": specialDiscount,
    "discount_percentage": discountPercentage,
    "discount": discount,
    "deliveryStatus": deliveryStatus,
    "reportReadyStatus": reportReadyStatus,
    "reportCollectionStatus": reportCollectionStatus,
    "sampleCollectionStatus": sampleCollectionStatus,
    "sampleCollectionDate": sampleCollectionDate,
    "remarkForSampleCollection": remarkForSampleCollection,
    "isApprovedInSampleCollection": isApprovedInSampleCollection,
    "isApprovedInSendToLab": isApprovedInSendToLab,
    "isApprovedInReceiveFromLab": isApprovedInReceiveFromLab,
    "reportReceiverFromLabRemark": reportReceiverFromLabRemark,
    "sampleReceiverToLabRemark": sampleReceiverToLabRemark,
    "created_by_id": createdById,
    "shift_id": shiftId,
    "created_by": createdBy,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "billingComment": billingComment,
    "discount_type": discountType,
    "tests": tests == null
        ? []
        : List<dynamic>.from(tests!.map((x) => x.toJson())),
    "inventory": inventory == null
        ? []
        : List<dynamic>.from(inventory!.map((x) => x.toJson())),
    "money_recipts_for_app": moneyRecipts == null
        ? []
        : List<dynamic>.from(moneyRecipts!.map((x) => x.toJson())),
    "reports": reports == null
        ? []
        : List<dynamic>.from(reports!.map((x) => x.toJson())), // Added reports to JSON
  };
}

// You'll also need to create the Report class and related classes based on your JSON structure
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
  final dynamic technicianSign;
  final dynamic validator;
  final dynamic reportConfirm;
  final String? status;
  final dynamic remark;
  final dynamic radiogyReportImage;
  final dynamic radiologyReportDetails;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ReportTest? test;
  final List<ReportDetail>? details;

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
    this.test,
    this.details,
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
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    test: json["test"] == null ? null : ReportTest.fromJson(json["test"]),
    details: json["details"] == null
        ? []
        : List<ReportDetail>.from(
        json["details"]!.map((x) => ReportDetail.fromJson(x))),
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
    "test": test?.toJson(),
    "details": details == null
        ? []
        : List<dynamic>.from(details!.map((x) => x.toJson())),
  };
}

class ReportDetail {
  final int? id;
  final dynamic saasBranchId;
  final dynamic saasBranchName;
  final String? reportId;
  final String? testId;
  final String? patientId;
  final String? invoiceId;
  final String? parameterId;
  final String? parameterName;
  final String? result;
  final String? unit;
  final dynamic lowerValue;
  final dynamic upperValue;
  final dynamic flag;
  final String? labNo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? parameterGroupId;
  final InvoiceSetupParameter? parameter;

  ReportDetail({
    this.id,
    this.saasBranchId,
    this.saasBranchName,
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
    this.createdAt,
    this.updatedAt,
    this.parameterGroupId,
    this.parameter,
  });

  factory ReportDetail.fromJson(Map<String, dynamic> json) => ReportDetail(
    id: json["id"],
    saasBranchId: json["saas_branch_id"],
    saasBranchName: json["saas_branch_name"],
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
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    parameterGroupId: json["parameter_group_id"],
    parameter: json["parameter"] == null
        ? null
        : InvoiceSetupParameter.fromJson(json["parameter"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "saas_branch_id": saasBranchId,
    "saas_branch_name": saasBranchName,
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
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "parameter_group_id": parameterGroupId,
    "parameter": parameter?.toJson(),
  };
}

class InvoiceSetupParameter {
  final int? id;
  final dynamic saasBranchId;
  final dynamic saasBranchName;
  final String? testId;
  final String? parameterName;
  final String? parameterUnit;
  final dynamic referenceValue;
  final int? showOptions;
  final String? options;
  final String? parameterGroupId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InvoiceSetupParameter({
    this.id,
    this.saasBranchId,
    this.saasBranchName,
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

  factory InvoiceSetupParameter.fromJson(Map<String, dynamic> json) => InvoiceSetupParameter(
    id: json["id"],
    saasBranchId: json["saas_branch_id"],
    saasBranchName: json["saas_branch_name"],
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
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "saas_branch_id": saasBranchId,
    "saas_branch_name": saasBranchName,
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

class ReportTest {
  final int? id;
  final dynamic saasBranchId;
  final dynamic saasBranchName;
  final String? testGroupId;
  final String? testCategoryId;
  final dynamic testSubCategoryId;
  final String? specimenId;
  final String? testName;
  final String? fee;
  final dynamic testParameter;
  final String? accountsId;
  final String? accountsTypeId;
  final String? accountsGroupId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic parameterGroupId;
  final int? discountApplied;
  final int? discount;
  final int? hideTestName;
  final dynamic itemCode;
  final List<InvoiceSetupParameterGroup>? parameterGroup;

  ReportTest({
    this.id,
    this.saasBranchId,
    this.saasBranchName,
    this.testGroupId,
    this.testCategoryId,
    this.testSubCategoryId,
    this.specimenId,
    this.testName,
    this.fee,
    this.testParameter,
    this.accountsId,
    this.accountsTypeId,
    this.accountsGroupId,
    this.createdAt,
    this.updatedAt,
    this.parameterGroupId,
    this.discountApplied,
    this.discount,
    this.hideTestName,
    this.itemCode,
    this.parameterGroup,
  });

  factory ReportTest.fromJson(Map<String, dynamic> json) => ReportTest(
    id: json["id"],
    saasBranchId: json["saas_branch_id"],
    saasBranchName: json["saas_branch_name"],
    testGroupId: json["test_group_id"],
    testCategoryId: json["test_category_id"],
    testSubCategoryId: json["test_sub_category_id"],
    specimenId: json["specimen_id"],
    testName: json["test_name"],
    fee: json["fee"],
    testParameter: json["test_parameter"],
    accountsId: json["accounts_id"],
    accountsTypeId: json["accounts_type_id"],
    accountsGroupId: json["accounts_group_id"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    parameterGroupId: json["parameter_group_id"],
    discountApplied: json["discount_applied"],
    discount: json["discount"],
    hideTestName: json["hide_test_name"],
    itemCode: json["item_code"],
    parameterGroup: json["parameter_group"] == null
        ? []
        : List<InvoiceSetupParameterGroup>.from(
        json["parameter_group"]!.map((x) => InvoiceSetupParameterGroup.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "saas_branch_id": saasBranchId,
    "saas_branch_name": saasBranchName,
    "test_group_id": testGroupId,
    "test_category_id": testCategoryId,
    "test_sub_category_id": testSubCategoryId,
    "specimen_id": specimenId,
    "test_name": testName,
    "fee": fee,
    "test_parameter": testParameter,
    "accounts_id": accountsId,
    "accounts_type_id": accountsTypeId,
    "accounts_group_id": accountsGroupId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "parameter_group_id": parameterGroupId,
    "discount_applied": discountApplied,
    "discount": discount,
    "hide_test_name": hideTestName,
    "item_code": itemCode,
    "parameter_group": parameterGroup == null
        ? []
        : List<dynamic>.from(parameterGroup!.map((x) => x.toJson())),
  };
}

class InvoiceSetupParameterGroup {
  final int? id;
  final dynamic saasBranchId;
  final dynamic saasBranchName;
  final String? groupName;
  final String? testNameId;
  final String? hidden;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InvoiceSetupParameterGroup({
    this.id,
    this.saasBranchId,
    this.saasBranchName,
    this.groupName,
    this.testNameId,
    this.hidden,
    this.createdAt,
    this.updatedAt,
  });

  factory InvoiceSetupParameterGroup.fromJson(Map<String, dynamic> json) => InvoiceSetupParameterGroup(
    id: json["id"],
    saasBranchId: json["saas_branch_id"],
    saasBranchName: json["saas_branch_name"],
    groupName: json["group_name"],
    testNameId: json["test_name_id"],
    hidden: json["hidden"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "saas_branch_id": saasBranchId,
    "saas_branch_name": saasBranchName,
    "group_name": groupName,
    "test_name_id": testNameId,
    "hidden": hidden,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

// Helper function for date parsing (assuming you already have this)
DateTime? parseCustomDate(dynamic date) {
  if (date == null) return null;
  if (date is DateTime) return date;
  if (date is String) {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }
  return null;
}
class SetupInventory {
  final int? id; // ✅ Added
  final int? invoiceId;
  final String? name;
  final dynamic price;
  final int? quantity;

  SetupInventory({
    this.id,
    this.invoiceId,
    this.name,
    this.price,
    this.quantity,
  });

  factory SetupInventory.fromJson(Map<String, dynamic> json) => SetupInventory(
        id: json["id"],
        invoiceId: json["invoice_id"],
        name: json["name"],
        price: json["price"],
        quantity: json["quantity"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "invoice_id": invoiceId,
        "name": name,
        "price": price,
        "quantity": quantity,
      };
}

class SetupMoneyRecipt {
  final String? invoiceNumber;
  final String? moneyReceiptNumber;
  final String? moneyReceiptType;
  final String? requestedAmount;
  final String? paidAmount;
  final String? dueAmount;
  final DateTime? createdAt;
  final int? id;

  SetupMoneyRecipt({
    this.invoiceNumber,
    this.moneyReceiptNumber,
    this.moneyReceiptType,
    this.requestedAmount,
    this.paidAmount,
    this.dueAmount,
    this.createdAt,
    this.id,
  });

  factory SetupMoneyRecipt.fromJson(Map<String, dynamic> json) =>
      SetupMoneyRecipt(
        invoiceNumber: json["invoice_number"],
        moneyReceiptNumber: json["money_receipt_number"],
        moneyReceiptType: json["money_receipt_type"],
        requestedAmount: json["requested_amount"],
        paidAmount: json["paid_amount"],
        dueAmount: json["due_amount"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "invoice_number": invoiceNumber,
        "money_receipt_number": moneyReceiptNumber,
        "money_receipt_type": moneyReceiptType,
        "requested_amount": requestedAmount,
        "paid_amount": paidAmount,
        "due_amount": dueAmount,
        "created_at": createdAt?.toIso8601String(),
        "id": id,
      };
}

class InvoiceSetupTestElement {
  final int? id;
  final dynamic saasBranchId;
  final dynamic saasBranchName;
  final String? invoiceNo;
  final String? testName;
  final dynamic boothId;
  final String? testCode;
  final String? fee;
  final int? isRefund;
  final int? discountApplied;
  final String? discount;
  final String? pointPercent;
  final dynamic point;
  final dynamic collector;
  final int? collectionStatus;
  final dynamic remark;
  final int? sentToLabStatus;
  final int? deliveryStatus;
  final int? reportCollectionStatus;
  final dynamic collectionDate;
  final String? testCategory;
  final String? testCategoryId;
  final dynamic sampleReceiverToLab;
  final dynamic sampleReceiverToLabPhoneNo;
  final dynamic sampleReceiverToLabDate;
  final dynamic sampleReceiverToLabTime;
  final dynamic sampleReceiverToLabRemark;
  final dynamic sampleCarrierToLab;
  final dynamic reportReceiverFromLab;
  final dynamic reportReceiverFromLabPhoneNo;
  final dynamic reportReceiverFromLabDate;
  final dynamic reportReceiverFromLabTime;
  final dynamic reportReceiverFromLabRemark;
  final int? reportApproveStatus;
  final int? reportAddStatus;
  final int? reportConfiremdStatus;
  final dynamic reportId;
  final dynamic specimenName;
  final dynamic specimenId;
  final int? collectorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final InvoiceSetupTestTest? test;
  final dynamic booth;

  InvoiceSetupTestElement({
    this.id,
    this.saasBranchId,
    this.saasBranchName,
    this.invoiceNo,
    this.testName,
    this.boothId,
    this.testCode,
    this.fee,
    this.isRefund,
    this.discountApplied,
    this.discount,
    this.pointPercent,
    this.point,
    this.collector,
    this.collectionStatus,
    this.remark,
    this.sentToLabStatus,
    this.deliveryStatus,
    this.reportCollectionStatus,
    this.collectionDate,
    this.testCategory,
    this.testCategoryId,
    this.sampleReceiverToLab,
    this.sampleReceiverToLabPhoneNo,
    this.sampleReceiverToLabDate,
    this.sampleReceiverToLabTime,
    this.sampleReceiverToLabRemark,
    this.sampleCarrierToLab,
    this.reportReceiverFromLab,
    this.reportReceiverFromLabPhoneNo,
    this.reportReceiverFromLabDate,
    this.reportReceiverFromLabTime,
    this.reportReceiverFromLabRemark,
    this.reportApproveStatus,
    this.reportAddStatus,
    this.reportConfiremdStatus,
    this.reportId,
    this.specimenName,
    this.specimenId,
    this.collectorId,
    this.createdAt,
    this.updatedAt,
    this.test,
    this.booth,
  });

  factory InvoiceSetupTestElement.fromJson(Map<String, dynamic> json) => InvoiceSetupTestElement(
        id: json["id"],
        saasBranchId: json["saas_branch_id"],
        saasBranchName: json["saas_branch_name"],
        invoiceNo: json["invoiceNo"],
        testName: json["testName"],
        boothId: json["booth_id"],
        testCode: json["testCode"],
        fee: json["fee"],
        isRefund: json["is_refund"],
        discountApplied: json["discount_applied"],
        discount: json["discount"],
        pointPercent: json["point_percent"],
        point: json["point"],
        collector: json["collector"],
        collectionStatus: json["collectionStatus"],
        remark: json["remark"],
        sentToLabStatus: json["sentToLabStatus"],
        deliveryStatus: json["deliveryStatus"],
        reportCollectionStatus: json["reportCollectionStatus"],
        collectionDate: json["collectionDate"],
        testCategory: json["testCategory"],
        testCategoryId: json["test_category_id"],
        sampleReceiverToLab: json["sampleReceiverToLab"],
        sampleReceiverToLabPhoneNo: json["sampleReceiverToLabPhoneNo"],
        sampleReceiverToLabDate: json["sampleReceiverToLabDate"],
        sampleReceiverToLabTime: json["sampleReceiverToLabTime"],
        sampleReceiverToLabRemark: json["sampleReceiverToLabRemark"],
        sampleCarrierToLab: json["sampleCarrierToLab"],
        reportReceiverFromLab: json["reportReceiverFromLab"],
        reportReceiverFromLabPhoneNo: json["reportReceiverFromLabPhoneNo"],
        reportReceiverFromLabDate: json["reportReceiverFromLabDate"],
        reportReceiverFromLabTime: json["reportReceiverFromLabTime"],
        reportReceiverFromLabRemark: json["reportReceiverFromLabRemark"],
        reportApproveStatus: json["report_approve_status"],
        reportAddStatus: json["report_add_status"],
        reportConfiremdStatus: json["report_confiremd_status"],
        reportId: json["report_id"],
        specimenName: json["specimen_name"],
        specimenId: json["specimen_id"],
        collectorId: json["collector_id"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        test: json["test"] == null ? null : InvoiceSetupTestTest.fromJson(json["test"]),
        booth: json["booth"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "saas_branch_id": saasBranchId,
        "saas_branch_name": saasBranchName,
        "invoiceNo": invoiceNo,
        "testName": testName,
        "booth_id": boothId,
        "testCode": testCode,
        "fee": fee,
        "is_refund": isRefund,
        "discount_applied": discountApplied,
        "discount": discount,
        "point_percent": pointPercent,
        "point": point,
        "collector": collector,
        "collectionStatus": collectionStatus,
        "remark": remark,
        "sentToLabStatus": sentToLabStatus,
        "deliveryStatus": deliveryStatus,
        "reportCollectionStatus": reportCollectionStatus,
        "collectionDate": collectionDate,
        "testCategory": testCategory,
        "test_category_id": testCategoryId,
        "sampleReceiverToLab": sampleReceiverToLab,
        "sampleReceiverToLabPhoneNo": sampleReceiverToLabPhoneNo,
        "sampleReceiverToLabDate": sampleReceiverToLabDate,
        "sampleReceiverToLabTime": sampleReceiverToLabTime,
        "sampleReceiverToLabRemark": sampleReceiverToLabRemark,
        "sampleCarrierToLab": sampleCarrierToLab,
        "reportReceiverFromLab": reportReceiverFromLab,
        "reportReceiverFromLabPhoneNo": reportReceiverFromLabPhoneNo,
        "reportReceiverFromLabDate": reportReceiverFromLabDate,
        "reportReceiverFromLabTime": reportReceiverFromLabTime,
        "reportReceiverFromLabRemark": reportReceiverFromLabRemark,
        "report_approve_status": reportApproveStatus,
        "report_add_status": reportAddStatus,
        "report_confiremd_status": reportConfiremdStatus,
        "report_id": reportId,
        "specimen_name": specimenName,
        "specimen_id": specimenId,
        "collector_id": collectorId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "test": test?.toJson(),
        "booth": booth,
      };
}

class InvoiceSetupTestTest {
  final int? id;
  final dynamic saasBranchId;
  final dynamic saasBranchName;
  final String? testGroupId;
  final String? testCategoryId;
  final dynamic testSubCategoryId;
  final String? specimenId;
  final String? testName;
  final String? fee;
  final dynamic testParameter;
  final String? accountsId;
  final String? accountsTypeId;
  final String? accountsGroupId;
  final String? createdAt;
  final String? updatedAt;
  final dynamic parameterGroupId;
  final int? discountApplied;
  final int? discount;
  final int? hideTestName;
  final String? itemCode;
  final InvoiceSetupSpecimen? specimen;

  InvoiceSetupTestTest({
    this.id,
    this.saasBranchId,
    this.saasBranchName,
    this.testGroupId,
    this.testCategoryId,
    this.testSubCategoryId,
    this.specimenId,
    this.testName,
    this.fee,
    this.testParameter,
    this.accountsId,
    this.accountsTypeId,
    this.accountsGroupId,
    this.createdAt,
    this.updatedAt,
    this.parameterGroupId,
    this.discountApplied,
    this.discount,
    this.hideTestName,
    this.itemCode,
    this.specimen,
  });

  factory InvoiceSetupTestTest.fromJson(Map<String, dynamic> json) => InvoiceSetupTestTest(
        id: json["id"],
        saasBranchId: json["saas_branch_id"],
        saasBranchName: json["saas_branch_name"],
        testGroupId: json["test_group_id"],
        testCategoryId: json["test_category_id"],
        testSubCategoryId: json["test_sub_category_id"],
        specimenId: json["specimen_id"],
        testName: json["test_name"],
        fee: json["fee"],
        testParameter: json["test_parameter"],
        accountsId: json["accounts_id"],
        accountsTypeId: json["accounts_type_id"],
        accountsGroupId: json["accounts_group_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        parameterGroupId: json["parameter_group_id"],
        discountApplied: json["discount_applied"],
        discount: json["discount"],
        hideTestName: json["hide_test_name"],
        itemCode: json["item_code"],
        specimen: json["specimen"] == null
            ? null
            : InvoiceSetupSpecimen.fromJson(json["specimen"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "saas_branch_id": saasBranchId,
        "saas_branch_name": saasBranchName,
        "test_group_id": testGroupId,
        "test_category_id": testCategoryId,
        "test_sub_category_id": testSubCategoryId,
        "specimen_id": specimenId,
        "test_name": testName,
        "fee": fee,
        "test_parameter": testParameter,
        "accounts_id": accountsId,
        "accounts_type_id": accountsTypeId,
        "accounts_group_id": accountsGroupId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "parameter_group_id": parameterGroupId,
        "discount_applied": discountApplied,
        "discount": discount,
        "hide_test_name": hideTestName,
        "item_code": itemCode,
        "specimen": specimen?.toJson(),
      };
}

class InvoiceSetupSpecimen {
  final int? id;
  final String? name;

  InvoiceSetupSpecimen({
    this.id,
    this.name,
  });

  factory InvoiceSetupSpecimen.fromJson(Map<String, dynamic> json) => InvoiceSetupSpecimen(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

