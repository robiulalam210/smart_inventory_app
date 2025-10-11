// To parse this JSON data, do
//
//     final fullRefundInvoiceModel = fullRefundInvoiceModelFromJson(jsonString);

import 'dart:convert';

FullRefundInvoiceModel fullRefundInvoiceModelFromJson(String str) => FullRefundInvoiceModel.fromJson(json.decode(str));

String fullRefundInvoiceModelToJson(FullRefundInvoiceModel data) => json.encode(data.toJson());

class FullRefundInvoiceModel {
  final int? status;
  final String? message;
  final Invoice? invoice;

  FullRefundInvoiceModel({
    this.status,
    this.message,
    this.invoice,
  });

  factory FullRefundInvoiceModel.fromJson(Map<String, dynamic> json) => FullRefundInvoiceModel(
    status: json["status"],
    message: json["message"],
    invoice: json["invoice"] == null ? null : Invoice.fromJson(json["invoice"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "invoice": invoice?.toJson(),
  };
}

class Invoice {
  final int? id;
  final int? saasBranchId;
  final String? saasBranchName;
  final String? visitType;
  final String? patientId;
  final String? patientFirstName;
  final String? patientMobilePhone;
  final String? referredBy;
  final dynamic referrer;
  final String? marketer;
  final dynamic pointPlan;
  final dynamic pointPlanMaster;
  final dynamic activePlan;
  final int? pointShare;
  final int? pointAmount;
  final String? paymentMethod;
  final String? paymentOption;
  final String? cardNumber;
  final String? expireDate;
  final String? digitalPaymentNumber;
  final String? totalBill;
  final DateTime? deliveryDate;
  final String? deliveryTime;
  final String? invoiceNo;
  final int? due;
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
  final Patient? patient;
  final List<TestElement>? tests;
  final List<MoneyRecipt>? moneyRecipts;
  final List<dynamic>? inventory;
  final dynamic doctor;

  Invoice({
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
    this.patient,
    this.tests,
    this.moneyRecipts,
    this.inventory,
    this.doctor,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
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
    deliveryDate: json["deliveryDate"] == null ? null : DateTime.parse(json["deliveryDate"]),
    deliveryTime: json["deliveryTime"],
    invoiceNo: json["invoiceNo"],
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
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    billingComment: json["billingComment"],
    discountType: json["discount_type"],
    patient: json["patient"] == null ? null : Patient.fromJson(json["patient"]),
    tests: json["tests"] == null ? [] : List<TestElement>.from(json["tests"]!.map((x) => TestElement.fromJson(x))),
    moneyRecipts: json["money_recipts"] == null ? [] : List<MoneyRecipt>.from(json["money_recipts"]!.map((x) => MoneyRecipt.fromJson(x))),
    inventory: json["inventory"] == null ? [] : List<dynamic>.from(json["inventory"]!.map((x) => x)),
    doctor: json["doctor"],
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
    "patient": patient?.toJson(),
    "tests": tests == null ? [] : List<dynamic>.from(tests!.map((x) => x.toJson())),
    "money_recipts": moneyRecipts == null ? [] : List<dynamic>.from(moneyRecipts!.map((x) => x.toJson())),
    "inventory": inventory == null ? [] : List<dynamic>.from(inventory!.map((x) => x)),
    "doctor": doctor,
  };
}

class MoneyRecipt {
  final int? id;
  final String? invoiceNumber;
  final String? moneyReceiptNumber;
  final String? moneyReceiptType;
  final String? requestedAmount;
  final String? paidAmount;
  final String? dueAmount;
  final DateTime? createdAt;

  MoneyRecipt({
    this.id,
    this.invoiceNumber,
    this.moneyReceiptNumber,
    this.moneyReceiptType,
    this.requestedAmount,
    this.paidAmount,
    this.dueAmount,
    this.createdAt,
  });

  factory MoneyRecipt.fromJson(Map<String, dynamic> json) => MoneyRecipt(
    id: json["id"],
    invoiceNumber: json["invoice_number"],
    moneyReceiptNumber: json["money_receipt_number"],
    moneyReceiptType: json["money_receipt_type"],
    requestedAmount: json["requested_amount"],
    paidAmount: json["paid_amount"],
    dueAmount: json["due_amount"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "invoice_number": invoiceNumber,
    "money_receipt_number": moneyReceiptNumber,
    "money_receipt_type": moneyReceiptType,
    "requested_amount": requestedAmount,
    "paid_amount": paidAmount,
    "due_amount": dueAmount,
    "created_at": createdAt?.toIso8601String(),
  };
}

class Patient {
  final int? id;
  final String? patientFirstName;
  final String? patientLastName;
  final dynamic patientMiddleName;
  final String? patientMobilePhone;
  final DateTime? patientDob;
  final String? patientHnNumber;
  final dynamic patientImages;
  final String? patientBirthSexId;
  final dynamic ptnBloodGroupId;
  final String? age;
  final String? month;
  final String? day;
  final dynamic patientAddress1;
  final String? fullName;
  final PatientBirthSex? patientBirthSex;
  final dynamic bloodGroup;

  Patient({
    this.id,
    this.patientFirstName,
    this.patientLastName,
    this.patientMiddleName,
    this.patientMobilePhone,
    this.patientDob,
    this.patientHnNumber,
    this.patientImages,
    this.patientBirthSexId,
    this.ptnBloodGroupId,
    this.age,
    this.month,
    this.day,
    this.patientAddress1,
    this.fullName,
    this.patientBirthSex,
    this.bloodGroup,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    id: json["id"],
    patientFirstName: json["patient_first_name"],
    patientLastName: json["patient_last_name"],
    patientMiddleName: json["patient_middle_name"],
    patientMobilePhone: json["patient_mobile_phone"],
    patientDob: json["patient_dob"] == null ? null : DateTime.parse(json["patient_dob"]),
    patientHnNumber: json["patient_hn_number"],
    patientImages: json["patient_images"],
    patientBirthSexId: json["patient_birth_sex_id"],
    ptnBloodGroupId: json["ptn_blood_group_id"],
    age: json["age"],
    month: json["month"],
    day: json["day"],
    patientAddress1: json["patient_address1"],
    fullName: json["fullName"],
    patientBirthSex: json["patient_birth_sex"] == null ? null : PatientBirthSex.fromJson(json["patient_birth_sex"]),
    bloodGroup: json["blood_group"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "patient_first_name": patientFirstName,
    "patient_last_name": patientLastName,
    "patient_middle_name": patientMiddleName,
    "patient_mobile_phone": patientMobilePhone,
    "patient_dob": patientDob?.toIso8601String(),
    "patient_hn_number": patientHnNumber,
    "patient_images": patientImages,
    "patient_birth_sex_id": patientBirthSexId,
    "ptn_blood_group_id": ptnBloodGroupId,
    "age": age,
    "month": month,
    "day": day,
    "patient_address1": patientAddress1,
    "fullName": fullName,
    "patient_birth_sex": patientBirthSex?.toJson(),
    "blood_group": bloodGroup,
  };
}

class PatientBirthSex {
  final int? id;
  final String? birthSexName;

  PatientBirthSex({
    this.id,
    this.birthSexName,
  });

  factory PatientBirthSex.fromJson(Map<String, dynamic> json) => PatientBirthSex(
    id: json["id"],
    birthSexName: json["birth_sex_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "birth_sex_name": birthSexName,
  };
}

class TestElement {
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
  final int? point;
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
  final TestTest? test;
  final dynamic booth;

  TestElement({
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

  factory TestElement.fromJson(Map<String, dynamic> json) => TestElement(
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
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    test: json["test"] == null ? null : TestTest.fromJson(json["test"]),
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

class TestTest {
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
  final dynamic itemCode;
  final dynamic specimen;

  TestTest({
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

  factory TestTest.fromJson(Map<String, dynamic> json) => TestTest(
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
    specimen: json["specimen"],
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
    "specimen": specimen,
  };
}
