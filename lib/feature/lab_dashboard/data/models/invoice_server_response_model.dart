// To parse this JSON data, do
//
//     final invoiceSyncResponseModel = invoiceSyncResponseModelFromJson(jsonString);

import 'dart:convert';

InvoiceServerSyncResponseModel invoiceSyncResponseModelFromJson(String str) => InvoiceServerSyncResponseModel.fromJson(json.decode(str));

String invoiceSyncResponseModelToJson(InvoiceServerSyncResponseModel data) => json.encode(data.toJson());

class InvoiceServerSyncResponseModel {
  final List<Datum>? data;
  final String? message;
  final int? statusCode;

  InvoiceServerSyncResponseModel({
    this.data,
    this.message,
    this.statusCode,
  });

  factory InvoiceServerSyncResponseModel.fromJson(Map<String, dynamic> json) => InvoiceServerSyncResponseModel(
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    message: json["message"],
    statusCode: json["status_code"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "message": message,
    "status_code": statusCode,
  };
}

class Datum {
  final Patient? patient;
  final Invoice? invoice;
  final List<Inventory>? inventory;
  final List<MoneyReceipt>? moneyReceipt; // changed from MoneyReceipt? to List<MoneyReceipt>
  final List<TestElement>? test;

  Datum({
    this.patient,
    this.invoice,
    this.inventory,
    this.moneyReceipt,
    this.test,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    patient: json["patient"] == null ? null : Patient.fromJson(json["patient"]),
    invoice: json["invoice"] == null ? null : Invoice.fromJson(json["invoice"]),
    inventory: json["inventory"] == null ? [] : List<Inventory>.from(json["inventory"]!.map((x) => Inventory.fromJson(x))),
    moneyReceipt: json["money_receipt"] == null
        ? []
        : List<MoneyReceipt>.from(json["money_receipt"].map((x) => MoneyReceipt.fromJson(x))),
    test: json["test"] == null ? [] : List<TestElement>.from(json["test"]!.map((x) => TestElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "patient": patient?.toJson(),
    "invoice": invoice?.toJson(),
    "inventory": inventory == null ? [] : List<dynamic>.from(inventory!.map((x) => x.toJson())),
    "money_receipt": moneyReceipt == null
        ? []
        : List<dynamic>.from(moneyReceipt!.map((x) => x.toJson())),

    "test": test == null ? [] : List<dynamic>.from(test!.map((x) => x.toJson())),
  };
}

class Inventory {
  final int? invoiceId;
  final dynamic productId;
  final int? quantity;
  final int? price;
  final String? name;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int? id;

  Inventory({
    this.invoiceId,
    this.productId,
    this.quantity,
    this.price,
    this.name,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) => Inventory(
    invoiceId: json["invoice_id"],
    productId: json["product_id"],
    quantity: json["quantity"],
    price: json["price"],
    name: json["name"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "invoice_id": invoiceId,
    "product_id": productId,
    "quantity": quantity,
    "price": price,
    "name": name,
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "id": id,
  };
}

class Invoice {
  final String? visitType;
  final dynamic invoiceNo;
  final dynamic invoiceNoApp;
  final String? billingComment;
  final int? saasBranchId;
  final String? saasBranchName;
  final dynamic patientId;
  final String? patientFirstName;
  final String? patientMobilePhone;
  final String? referredBy;
  final String? discountType;
  final dynamic referrer;
  final String? paymentMethod;
  final String? paymentOption;
  final String? cardNumber;
  final String? expireDate;
  final String? digitalPaymentNumber;
  final dynamic totalBill;
  final dynamic due;
  final dynamic discount;
  final dynamic paidAmount;
  final dynamic specialDiscount;
  final dynamic discountPercentage;
  final String? deliveryStatus;
  final String? reportReadyStatus;
  final String? reportCollectionStatus;
  final String? sampleCollectionStatus;
  final String? sampleCollectionDate;
  final String? deliveryDate;
  final String? deliveryTime;
  final String? createdBy;
  final dynamic createdById;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? marketer;
  final dynamic shiftId;
  final int? id;
  final int? webId;

  String? get invoiceNumber => invoiceNo;

  Invoice({
    this.visitType,
    this.invoiceNo,
    this.invoiceNoApp,
    this.billingComment,
    this.saasBranchId,
    this.saasBranchName,
    this.patientId,
    this.patientFirstName,
    this.patientMobilePhone,
    this.referredBy,
    this.discountType,
    this.referrer,
    this.paymentMethod,
    this.paymentOption,
    this.cardNumber,
    this.expireDate,
    this.digitalPaymentNumber,
    this.totalBill,
    this.due,
    this.discount,
    this.paidAmount,
    this.specialDiscount,
    this.discountPercentage,
    this.deliveryStatus,
    this.reportReadyStatus,
    this.reportCollectionStatus,
    this.sampleCollectionStatus,
    this.sampleCollectionDate,
    this.deliveryDate,
    this.deliveryTime,
    this.createdBy,
    this.createdById,
    this.createdAt,
    this.updatedAt,
    this.marketer,
    this.shiftId,
    this.id,
    this.webId,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    visitType: json["visit_type"],
    invoiceNo: json["invoiceNo"].toString(),
    invoiceNoApp: json["invoiceNo_app"].toString(),
    billingComment: json["billingComment"],
    saasBranchId: json["saas_branch_id"],
    saasBranchName: json["saas_branch_name"],
    patientId: json["patient_id"],
    patientFirstName: json["patient_first_name"],
    patientMobilePhone: json["patient_mobile_phone"],
    referredBy: json["referredBy"],
    discountType: json["discount_type"],
    referrer: json["referrer"],
    paymentMethod: json["paymentMethod"],
    paymentOption: json["paymentOption"],
    cardNumber: json["cardNumber"],
    expireDate: json["expireDate"],
    digitalPaymentNumber: json["digitalPaymentNumber"],
    totalBill: json["totalBill"],
    due: json["due"],
    discount: json["discount"],
    paidAmount: json["paidAmount"],
    specialDiscount: json["specialDiscount"],
    discountPercentage: json["discount_percentage"],
    deliveryStatus: json["deliveryStatus"],
    reportReadyStatus: json["reportReadyStatus"],
    reportCollectionStatus: json["reportCollectionStatus"],
    sampleCollectionStatus: json["sampleCollectionStatus"],
    sampleCollectionDate: json["sampleCollectionDate"],
    deliveryDate: json["deliveryDate"],
    deliveryTime: json["deliveryTime"],
    createdBy: json["created_by"],
    createdById: json["created_by_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    marketer: json["marketer"],
    shiftId: json["shift_id"],
    id: json["id"],
    webId: json["web_id"],
  );

  Map<String, dynamic> toJson() => {
    "visit_type": visitType,
    "invoiceNo": invoiceNo,
    "invoiceNo_app": invoiceNoApp,
    "billingComment": billingComment,
    "saas_branch_id": saasBranchId,
    "saas_branch_name": saasBranchName,
    "patient_id": patientId,
    "patient_first_name": patientFirstName,
    "patient_mobile_phone": patientMobilePhone,
    "referredBy": referredBy,
    "discount_type": discountType,
    "referrer": referrer,
    "paymentMethod": paymentMethod,
    "paymentOption": paymentOption,
    "cardNumber": cardNumber,
    "expireDate": expireDate,
    "digitalPaymentNumber": digitalPaymentNumber,
    "totalBill": totalBill,
    "due": due,
    "discount": discount,
    "paidAmount": paidAmount,
    "specialDiscount": specialDiscount,
    "discount_percentage": discountPercentage,
    "deliveryStatus": deliveryStatus,
    "reportReadyStatus": reportReadyStatus,
    "reportCollectionStatus": reportCollectionStatus,
    "sampleCollectionStatus": sampleCollectionStatus,
    "sampleCollectionDate": sampleCollectionDate,
    "deliveryDate": deliveryDate,
    "deliveryTime": deliveryTime,
    "created_by": createdBy,
    "created_by_id": createdById,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "marketer": marketer,
    "shift_id": shiftId,
    "id": id,
    "web_id": webId,
  };
}
class MoneyReceipt {
  final int? saasBranchId;
  final String? saasBranchName;
  final String? moneyReceiptNumber;
  final String? hnNumber;
  final dynamic dueAmount;
  final dynamic age;
  final int? invoiceId;
  final String? name;
  final dynamic invoiceNumber;
  final dynamic requestedAmount;
  final dynamic paidAmount;
  final DateTime? paymentDate;
  final String? paymentTime;
  final String? moneyReceiptType;
  final String? paymentMethod;
  final dynamic totalAmountPaid;
  final String? createdBy;
  final dynamic createdById;
  final int? shiftId;
  final String? referredBy;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int? id;

  MoneyReceipt({
    this.saasBranchId,
    this.saasBranchName,
    this.moneyReceiptNumber,
    this.hnNumber,
    this.dueAmount,
    this.age,
    this.invoiceId,
    this.name,
    this.invoiceNumber,
    this.requestedAmount,
    this.paidAmount,
    this.paymentDate,
    this.paymentTime,
    this.moneyReceiptType,
    this.paymentMethod,
    this.totalAmountPaid,
    this.createdBy,
    this.createdById,
    this.shiftId,
    this.referredBy,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory MoneyReceipt.fromJson(Map<String, dynamic> json) => MoneyReceipt(
    saasBranchId: json["saas_branch_id"],
    saasBranchName: json["saas_branch_name"],
    moneyReceiptNumber: json["money_receipt_number"],
    hnNumber: json["hn_number"],
    dueAmount: json["due_amount"],
    age: json["age"],
    invoiceId: json["invoice_id"],
    name: json["name"],
    invoiceNumber: json["invoice_number"],
    requestedAmount: json["requested_amount"],
    paidAmount: json["paid_amount"],
    paymentDate: json["payment_date"] == null ? null : DateTime.parse(json["payment_date"]),
    paymentTime: json["payment_time"],
    moneyReceiptType: json["money_receipt_type"],
    paymentMethod: json["payment_method"],
    totalAmountPaid: json["total_amount_paid"],
    createdBy: json["created_by"],
    createdById: json["created_by_id"],
    shiftId: json["shift_id"],
    referredBy: json["referredBy"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "saas_branch_id": saasBranchId,
    "saas_branch_name": saasBranchName,
    "money_receipt_number": moneyReceiptNumber,
    "hn_number": hnNumber,
    "due_amount": dueAmount,
    "age": age,
    "invoice_id": invoiceId,
    "name": name,
    "invoice_number": invoiceNumber,
    "requested_amount": requestedAmount,
    "paid_amount": paidAmount,
    "payment_date": "${paymentDate?.year.toString().padLeft(4, '0')}-${paymentDate?.month.toString().padLeft(2, '0')}-${paymentDate?.day.toString().padLeft(2, '0')}",
    "payment_time": paymentTime,
    "money_receipt_type": moneyReceiptType,
    "payment_method": paymentMethod,
    "total_amount_paid": totalAmountPaid,
    "created_by": createdBy,
    "created_by_id": createdById,
    "shift_id": shiftId,
    "referredBy": referredBy,
    "updated_at": updatedAt?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "id": id,
  };
}

class Patient {
  final int? id;
  final String? patientHnNumber;
  final String? patientFirstName;
  final dynamic patientMiddleName;
  final String? patientLastName;
  final String? patientBirthSexId;
  final String? patientDob;
  final String? patientMobilePhone;
  final dynamic patientAddress1;
  final dynamic age;
  final dynamic month;
  final dynamic day;
  final String? visitType;
  final String? ptnBloodGroupId;
  final int? webId;
  final String? fullName;

  Patient({
    this.id,
    this.patientHnNumber,
    this.patientFirstName,
    this.patientMiddleName,
    this.patientLastName,
    this.patientBirthSexId,
    this.patientDob,
    this.patientMobilePhone,
    this.patientAddress1,
    this.age,
    this.month,
    this.day,
    this.visitType,
    this.ptnBloodGroupId,
    this.webId,
    this.fullName,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    id: json["id"],
    patientHnNumber: json["patient_hn_number"],
    patientFirstName: json["patient_first_name"],
    patientMiddleName: json["patient_middle_name"],
    patientLastName: json["patient_last_name"],
    patientBirthSexId: json["patient_birth_sex_id"],
    patientDob: json["patient_dob"],
    patientMobilePhone: json["patient_mobile_phone"],
    patientAddress1: json["patient_address1"],
    age: json["age"],
    month: json["month"],
    day: json["day"],
    visitType: json["visit_type"],
    ptnBloodGroupId: json["ptn_blood_group_id"],
    webId: json["web_id"],
    fullName: json["fullName"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "patient_hn_number": patientHnNumber,
    "patient_first_name": patientFirstName,
    "patient_middle_name": patientMiddleName,
    "patient_last_name": patientLastName,
    "patient_birth_sex_id": patientBirthSexId,
    "patient_dob": patientDob,
    "patient_mobile_phone": patientMobilePhone,
    "patient_address1": patientAddress1,
    "age": age,
    "month": month,
    "day": day,
    "visit_type": visitType,
    "ptn_blood_group_id": ptnBloodGroupId,
    "web_id": webId,
    "fullName": fullName,
  };
}
class MoneyRecipt {
  final String? invoiceNumber;
  final String? moneyReceiptNumber;
  final String? moneyReceiptType;
  final String? requestedAmount;
  final String? paidAmount;
  final String? dueAmount;
  final DateTime? createdAt;

  MoneyRecipt({
    this.invoiceNumber,
    this.moneyReceiptNumber,
    this.moneyReceiptType,
    this.requestedAmount,
    this.paidAmount,
    this.dueAmount,
    this.createdAt,
  });

  factory MoneyRecipt.fromJson(Map<String, dynamic> json) => MoneyRecipt(
    invoiceNumber: json["invoice_number"],
    moneyReceiptNumber: json["money_receipt_number"],
    moneyReceiptType: json["money_receipt_type"],
    requestedAmount: json["requested_amount"],
    paidAmount: json["paid_amount"],
    dueAmount: json["due_amount"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "invoice_number": invoiceNumber,
    "money_receipt_number": moneyReceiptNumber,
    "money_receipt_type": moneyReceiptType,
    "requested_amount": requestedAmount,
    "paid_amount": paidAmount,
    "due_amount": dueAmount,
    "created_at": createdAt?.toIso8601String(),
  };
}

// class Test {
//   final String? invoiceNo;
//   final String? testName;
//   final dynamic testCode;
//   final String? fee;
//   final int? discountApplied;
//   final String? testCategory;
//   final dynamic testCategoryId;
//   final DateTime? updatedAt;
//   final DateTime? createdAt;
//   final int? id;
//
//   Test({
//     this.invoiceNo,
//     this.testName,
//     this.testCode,
//     this.fee,
//     this.discountApplied,
//     this.testCategory,
//     this.testCategoryId,
//     this.updatedAt,
//     this.createdAt,
//     this.id,
//   });
//
//   factory Test.fromJson(Map<String, dynamic> json) => Test(
//     invoiceNo: json["invoiceNo"],
//     testName: json["testName"],
//     testCode: json["testCode"],
//     fee: json["fee"],
//     discountApplied: json["discount_applied"],
//     testCategory: json["testCategory"],
//     testCategoryId: json["test_category_id"],
//     updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
//     createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
//     id: json["id"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "invoiceNo": invoiceNo,
//     "testName": testName,
//     "testCode": testCode,
//     "fee": fee,
//     "discount_applied": discountApplied,
//     "testCategory": testCategory,
//     "test_category_id": testCategoryId,
//     "updated_at": updatedAt?.toIso8601String(),
//     "created_at": createdAt?.toIso8601String(),
//     "id": id,
//   };
// }
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
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
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
  final String? itemCode;
  final Specimen? specimen;

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
    specimen: json["specimen"] == null
        ? null
        : Specimen.fromJson(json["specimen"]),
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
}class Specimen {
  final int? id;
  final String? name;

  Specimen({
    this.id,
    this.name,
  });

  factory Specimen.fromJson(Map<String, dynamic> json) => Specimen(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
