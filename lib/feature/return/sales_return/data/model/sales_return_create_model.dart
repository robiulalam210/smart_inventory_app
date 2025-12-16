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
  final double? returnAmount; // ADDED: Calculated total return amount
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
    this.returnAmount, // ADDED parameter
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
      if (returnAmount != null) 'return_amount': returnAmount, // ADDED to JSON
      if (autoApprove != null) 'auto_approve': autoApprove,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Optional: Add copyWith method for easy updates
  SalesReturnCreateModel copyWith({
    String? receiptNo,
    String? customerName,
    DateTime? returnDate,
    int? accountId,
    String? paymentMethod,
    String? reason,
    double? returnCharge,
    String? returnChargeType,
    double? returnAmount,
    bool? autoApprove,
    List<SalesReturnItemCreate>? items,
  }) {
    return SalesReturnCreateModel(
      receiptNo: receiptNo ?? this.receiptNo,
      customerName: customerName ?? this.customerName,
      returnDate: returnDate ?? this.returnDate,
      accountId: accountId ?? this.accountId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      reason: reason ?? this.reason,
      returnCharge: returnCharge ?? this.returnCharge,
      returnChargeType: returnChargeType ?? this.returnChargeType,
      returnAmount: returnAmount ?? this.returnAmount,
      autoApprove: autoApprove ?? this.autoApprove,
      items: items ?? this.items,
    );
  }
}

class SalesReturnItemCreate {
  final int productId;
  final int quantity;
  final int damageQuantity;
  final double unitPrice;
  final double? discount;
  final String? discountType;
  final String? productName; // Optional: For display purposes
  final double? total; // Optional: For display purposes

  SalesReturnItemCreate({
    required this.productId,
    required this.quantity,
    this.damageQuantity = 0,
    required this.unitPrice,
    this.discount = 0,
    this.discountType = 'fixed',
    this.productName, // Optional
    this.total, // Optional
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      if (productName != null) 'product_name': productName, // Optional
      'quantity': quantity,
      'damage_quantity': damageQuantity,
      'unit_price': unitPrice,
      'discount': discount ?? 0,
      'discount_type': discountType ?? 'fixed',
      if (total != null) 'total': total, // Optional
    };
  }

  // Calculate item total with discount
  double calculateTotal() {
    double itemTotal = unitPrice * quantity;

    if (discountType == 'percentage' && discount != null && discount! > 0) {
      itemTotal = itemTotal - (itemTotal * discount! / 100);
    } else if (discount != null && discount! > 0) {
      itemTotal = itemTotal - discount!;
    }

    return itemTotal;
  }
}

// Optional: Helper class for calculating totals
class SalesReturnCalculator {
  static double calculateSubtotal(List<SalesReturnItemCreate> items) {
    return items.fold(0.0, (sum, item) => sum + item.calculateTotal());
  }

  static double calculateReturnCharge({
    required double subtotal,
    required double returnCharge,
    required String returnChargeType,
  }) {
    if (returnChargeType == 'percentage') {
      return subtotal * (returnCharge / 100);
    }
    return returnCharge;
  }

  static double calculateTotalAmount({
    required double subtotal,
    required double returnChargeAmount,
  }) {
    return subtotal + returnChargeAmount;
  }

  static SalesReturnCreateModel withCalculatedAmounts(SalesReturnCreateModel model) {
    double subtotal = calculateSubtotal(model.items);
    double returnChargeAmount = calculateReturnCharge(
      subtotal: subtotal,
      returnCharge: model.returnCharge ?? 0,
      returnChargeType: model.returnChargeType ?? 'fixed',
    );
    double totalAmount = calculateTotalAmount(
      subtotal: subtotal,
      returnChargeAmount: returnChargeAmount,
    );

    return model.copyWith(returnAmount: totalAmount);
  }
}