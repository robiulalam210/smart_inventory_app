class PurchaseReturnModel {
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
  final String? status;
  final int? companyId;
  final List<PurchaseReturnItem>? items;

  PurchaseReturnModel({
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

  factory PurchaseReturnModel.fromJson(Map<String, dynamic> json) {
    return PurchaseReturnModel(
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

class PurchaseReturnItem {
  final int? id;
  final String? productName;
  final int? quantity;
  final String? unitPrice;
  final String? discount;
  final String? discountType;
  final String? total;

  PurchaseReturnItem({
    this.id,
    this.productName,
    this.quantity,
    this.unitPrice,
    this.discount,
    this.discountType,
    this.total,
  });

  factory PurchaseReturnItem.fromJson(Map<String, dynamic> json) {
    return PurchaseReturnItem(
      id: json['id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      unitPrice: json['unit_price'],
      discount: json['discount'],
      discountType: json['discount_type'],
      total: json['total'],
    );
  }
}