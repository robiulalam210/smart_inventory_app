// data/sales_return_create_model.dart
class SalesReturnCreateModel {
  final String? receiptNo;
  final String? customerName;
  final DateTime? returnDate;
  final int? accountId;
  final String? paymentMethod;
  final String? reason;
  final double? returnCharge;
  final String? returnChargeType;
  final bool? autoApprove;
  final List<SalesReturnItemCreate> items;

  SalesReturnCreateModel({
    this.receiptNo,
    this.customerName,
    this.returnDate,
    this.accountId,
    this.paymentMethod,
    this.reason,
    this.returnCharge,
    this.returnChargeType,
    this.autoApprove = false,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      if (receiptNo != null) 'receipt_no': receiptNo,
      if (customerName != null) 'customer_name': customerName,
      if (returnDate != null) 'return_date': returnDate!.toIso8601String().split('T').first,
      if (accountId != null) 'account_id': accountId,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (reason != null) 'reason': reason,
      if (returnCharge != null) 'return_charge': returnCharge,
      if (returnChargeType != null) 'return_charge_type': returnChargeType,
      if (autoApprove != null) 'auto_approve': autoApprove,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class SalesReturnItemCreate {
  final int productId;
  final int quantity;
  final int damageQuantity;
  final double unitPrice;
  final double? discount;
  final String? discountType;

  SalesReturnItemCreate({
    required this.productId,
    required this.quantity,
    this.damageQuantity = 0,
    required this.unitPrice,
    this.discount = 0,
    this.discountType,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'damage_quantity': damageQuantity,
      'unit_price': unitPrice,
      if (discount != null) 'discount': discount,
      if (discountType != null) 'discount_type': discountType,
    };
  }
}