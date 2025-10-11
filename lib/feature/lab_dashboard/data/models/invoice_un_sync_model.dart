// To parse this JSON data, do
//
//     final invoiceUnSyncModel = invoiceUnSyncModelFromJson(jsonString);

import 'dart:convert';

InvoiceUnSyncModel invoiceUnSyncModelFromJson(String str) => InvoiceUnSyncModel.fromJson(json.decode(str));

String invoiceUnSyncModelToJson(InvoiceUnSyncModel data) => json.encode(data.toJson());

class InvoiceUnSyncModel {
  final dynamic webId;
  final String? invoiceNumber;
  final String? deliveryDate;
  final String? deliveryTime;
  final DateTime? createDate;
  final dynamic createdByUserId;
  final String? createdByName;
  final double? totalBillAmount;
  final double? due;
  final double? paidAmount;
  final String? discountType;
  final double? discount;
  final double? discountPercentage;
  final String? billingComment;
  final String? sampleCollectionRemark;
  final String? referType;
  final String? referreIdOrDesc;
  final int? branchId;
  final String? branch;
  final UnSyncPatient? patient;
  final List<UnSyncInvoiceDetail>? invoiceDetails;
  final List<InventoryItem>? inventory; // <-- new inventory field
  final List<UnSyncMoneyReceipt>? moneyReceipts;

  InvoiceUnSyncModel({
    this.webId,
    this.invoiceNumber,
    this.deliveryDate,
    this.deliveryTime,
    this.createDate,
    this.createdByUserId,
    this.createdByName,
    this.totalBillAmount,
    this.due,
    this.paidAmount,
    this.discountType,
    this.discount,
    this.discountPercentage,
    this.referType,
    this.billingComment,
    this.sampleCollectionRemark,
    this.referreIdOrDesc,
    this.branchId,
    this.branch,
    this.patient,
    this.invoiceDetails,
    this.inventory,
    this.moneyReceipts,
  });

  factory InvoiceUnSyncModel.fromJson(Map<String, dynamic> json) => InvoiceUnSyncModel(
    webId: json["web_id"],
    invoiceNumber: json["invoice_number"],
    deliveryDate: json["delivery_date"],
    deliveryTime: json["delivery_time"],
    createDate: json["create_date"] == null ? null : DateTime.parse(json["create_date"]),
    createdByUserId: json["created_by_user_id"],
    createdByName: json["created_by_name"],
    totalBillAmount: (json["total_bill_amount"] is int) ? (json["total_bill_amount"] as int).toDouble() : json["total_bill_amount"],
    due: (json["due"] is int) ? (json["due"] as int).toDouble() : json["due"],
    paidAmount: (json["paid_amount"] is int) ? (json["paid_amount"] as int).toDouble() : json["paid_amount"],
    discountType: json["discount_type"],
    discount: (json["discount"] is int) ? (json["discount"] as int).toDouble() : json["discount"],
    discountPercentage: (json["discount_percentage"] is int) ? (json["discount_percentage"] as int).toDouble() : json["discount_percentage"],
    billingComment: json["billingComment"],
    sampleCollectionRemark: json["sample_collection_remark"],
    referType: json["refer_type"],
    referreIdOrDesc: json["referre_id_or_desc"],
    branchId: json["branch_id"],
    branch: json["branch"],
    patient: json["patient"] == null ? null : UnSyncPatient.fromJson(json["patient"]),
    invoiceDetails: json["invoice_details"] == null
        ? []
        : List<UnSyncInvoiceDetail>.from(json["invoice_details"].map((x) => UnSyncInvoiceDetail.fromJson(x))),
    inventory: json["inventory"] == null
        ? []
        : List<InventoryItem>.from(json["inventory"].map((x) => InventoryItem.fromJson(x))),
    moneyReceipts: json["money_receipts"] == null
        ? []
        : List<UnSyncMoneyReceipt>.from(
        json["money_receipts"].map((x) => UnSyncMoneyReceipt.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "web_id": webId,
    "invoice_number": invoiceNumber,
    "delivery_date": deliveryDate,
    "delivery_time": deliveryTime,
    "create_date": createDate?.toIso8601String(),
    "created_by_user_id": createdByUserId,
    "created_by_name": createdByName,
    "total_bill_amount": totalBillAmount,
    "due": due,
    "paid_amount": paidAmount,
    "discount_type": discountType,
    "discount": discount,
    "discount_percentage": discountPercentage,
    "billingComment": billingComment,
    "sample_collection_remark": sampleCollectionRemark,
    "refer_type": referType,
    "referre_id_or_desc": referreIdOrDesc,
    "branch_id": branchId,
    "branch": branch,
    "patient": patient?.toJson(),
    "invoice_details": invoiceDetails == null
        ? []
        : List<dynamic>.from(invoiceDetails!.map((x) => x.toJson())),
    "inventory": inventory == null
        ? []
        : List<dynamic>.from(inventory!.map((x) => x.toJson())),
    "money_receipts": moneyReceipts == null
        ? []
        : List<dynamic>.from(moneyReceipts!.map((x) => x.toJson())),
  };

  @override
  String toString() => toJson().toString(); // helpful for debugPrint
}

class UnSyncInvoiceDetail {
  final int? testId;
  final int? isRefund;
  final DateTime? collectionDate;
  final int? collectorId;
  final int? boothId;
  final int? collectionStatus;
  final String? collectorName;

  UnSyncInvoiceDetail({
    this.testId,
    this.isRefund,
    this.collectionDate,
    this.collectorId,
    this.boothId,
    this.collectionStatus,
    this.collectorName,
  });

  factory UnSyncInvoiceDetail.fromJson(Map<String, dynamic> json) => UnSyncInvoiceDetail(
    testId: json["test_id"],
    isRefund: json["is_refund"],
    collectionDate: json["collection_date"] != null
        ? DateTime.parse(json["collection_date"])
        : null,
    collectorId: json["collector_id"],
    boothId: json["booth_id"],
    collectionStatus: json["collection_status"],
    collectorName: json["collector_name"],
  );

  Map<String, dynamic> toJson() => {
    "test_id": testId,
    "is_refund": isRefund,
    "collection_date": collectionDate?.toIso8601String(),
    "collector_id": collectorId,
    "booth_id": boothId,
    "collection_status": collectionStatus,
    "collector_name": collectorName,
  };
}
class UnSyncMoneyReceipt {
  final String? moneyReceiptNumber;
  final String? moneyReceiptType;
  final double? paidAmount;
  final double? dueAmount;
  final double? totalAmountPaid;
  final double? requestedAmount;

  UnSyncMoneyReceipt({
    this.moneyReceiptNumber,
    this.moneyReceiptType,
    this.paidAmount,
    this.dueAmount,
    this.totalAmountPaid,
    this.requestedAmount,
  });

  factory UnSyncMoneyReceipt.fromJson(Map<String, dynamic> json) => UnSyncMoneyReceipt(
    moneyReceiptNumber: json["money_receipt_number"],
    moneyReceiptType: json["money_receipt_type"],
    paidAmount: (json["paid_amount"] is int)
        ? (json["paid_amount"] as int).toDouble()
        : json["paid_amount"],
    dueAmount: (json["due_amount"] is int)
        ? (json["due_amount"] as int).toDouble()
        : json["due_amount"],
    totalAmountPaid: (json["total_amount_paid"] is int)
        ? (json["total_amount_paid"] as int).toDouble()
        : json["total_amount_paid"],
    requestedAmount: (json["requested_amount"] is int)
        ? (json["requested_amount"] as int).toDouble()
        : json["requested_amount"],
  );

  Map<String, dynamic> toJson() => {
    "money_receipt_number": moneyReceiptNumber,
    "money_receipt_type": moneyReceiptType,
    "paid_amount": paidAmount,
    "due_amount": dueAmount,
    "total_amount_paid": totalAmountPaid,
    "requested_amount": requestedAmount,
  };
}

class UnSyncPatient {
  final int? webId;
  final String? name;
  final String? phone;
  final dynamic age;
  final dynamic month;
  final dynamic day;
  final String? visitType;
  final dynamic gender;
  final String? bloodGroup;
  final String? address;
  final String? dateOfBirth;
  final String? hnNumber;
  final DateTime? createDate;

  UnSyncPatient({
    this.webId,
    this.name,
    this.phone,
    this.age,
    this.month,
    this.day,
    this.visitType,
    this.gender,
    this.bloodGroup,
    this.address,
    this.dateOfBirth,
    this.hnNumber,
    this.createDate,
  });

  factory UnSyncPatient.fromJson(Map<String, dynamic> json) => UnSyncPatient(
    webId: json["web_id"],
    name: json["name"],
    phone: json["phone"],
    age: json["age"],
    month: json["month"],
    day: json["day"],
    visitType: json["visit_type"],
    gender: json["gender"],
    bloodGroup: json["bloodGroup"],
    address: json["address"],
    dateOfBirth: json["dateOfBirth"],
    hnNumber: json["hn_number"],
    createDate: json["create_date"] == null ? null : DateTime.parse(json["create_date"]),
  );

  Map<String, dynamic> toJson() => {
    "web_id": webId,
    "name": name,
    "phone": phone,
    "age": age,
    "month": month,
    "day": day,
    "visit_type": visitType,
    "gender": gender,
    "bloodGroup": bloodGroup,
    "address": address,
    "dateOfBirth": dateOfBirth,
    "hn_number": hnNumber,
    "create_date": createDate?.toIso8601String(),
  };
}

// New InventoryItem model class

class InventoryItem {
  final int? id;
  final int? quantity;
  final double? price;
  final String? name;

  InventoryItem({
    this.id,
    this.quantity,
    this.price,
    this.name,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json["id"],
    quantity: json["quantity"],
    price: (json["price"] is int) ? (json["price"] as int).toDouble() : json["price"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
    "price": price,
    "name": name,
  };
}
