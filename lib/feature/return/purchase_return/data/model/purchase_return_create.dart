import '/feature/return/purchase_return/data/model/purchase_return_model.dart';

class PurchaseReturnCreatedModel {
  final int? id;
  final dynamic supplier;
  final String? invoiceNo;
  final String? returnDate;
  final dynamic accountId;
  final String? paymentMethod;
  final String? returnCharge;
  final String? returnChargeType;
  final String? returnAmount;
  final String? reason;
  final dynamic status;
  final int? companyId;
  final List<PurchaseReturnItem>? items;

  PurchaseReturnCreatedModel({
    this.id,
    this.supplier,
    this.invoiceNo,
    this.returnDate,
    this.accountId,
    this.paymentMethod,
    this.returnCharge,
    this.returnChargeType,
    this.returnAmount,
    this.reason,
    this.status,
    this.companyId,
    this.items,
  });

  factory PurchaseReturnCreatedModel.fromJson(Map<String, dynamic> json) {
    return PurchaseReturnCreatedModel(
      id: json['id'],
      supplier: json['supplier'],
      invoiceNo: json['invoice_no'],
      returnDate: json['return_date'],
      accountId: json['account_id'],
      paymentMethod: json['payment_method'],
      returnCharge: json['return_charge'],
      returnChargeType: json['return_charge_type'],
      returnAmount: json['return_amount'],
      reason: json['reason'],
      status: json['status'],
      companyId: json['company_id'],
      items: json['items'] != null
          ? List<PurchaseReturnItem>.from(
          json['items'].map((x) => PurchaseReturnItem.fromJson(x)))
          : null,
    );
  }
}