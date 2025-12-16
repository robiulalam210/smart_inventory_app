// data/model/sales_return_model.dart
import 'dart:convert';

class SalesReturnModel {
  final int id;
  final String? receiptNo;
  final String? customerName;
  final DateTime? returnDate;
  final String? accountName;
  final String? paymentMethod;
  final String? reason;
  final double? returnCharge;
  final String? returnChargeType;
  final double? returnAmount;
  final String? status;
  final DateTime? createdAt;
  final List<SalesReturnItem> items;
  final int? accountId;

  SalesReturnModel({
    required this.id,
    this.receiptNo,
    this.customerName,
    this.returnDate,
    this.accountName,
    this.paymentMethod,
    this.reason,
    this.returnCharge,
    this.returnChargeType,
    this.returnAmount,
    this.status,
    this.createdAt,
    required this.items,
    this.accountId,
  });

  factory SalesReturnModel.fromJson(Map<String, dynamic> json) {
    return SalesReturnModel(
      id: json['id'] ?? 0,
      receiptNo: json['receipt_no'],
      customerName: json['customer_name'],
      returnDate: json['return_date'] != null
          ? DateTime.tryParse(json['return_date'].toString())
          : null,
      accountName: json['account']?['name'],
      accountId: json['account_id'],
      paymentMethod: json['payment_method'],
      reason: json['reason'],
      returnCharge: json['return_charge'] != null
          ? double.tryParse(json['return_charge'].toString())
          : 0.0,
      returnChargeType: json['return_charge_type'],
      returnAmount: json['return_amount'] != null
          ? double.tryParse(json['return_amount'].toString())
          : 0.0,
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      items: json['items'] != null
          ? List<SalesReturnItem>.from(
          json['items'].map((x) => SalesReturnItem.fromJson(x))
      )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receipt_no': receiptNo,
      'customer_name': customerName,
      'return_date': returnDate?.toIso8601String(),
      'account_id': accountId,
      'payment_method': paymentMethod,
      'reason': reason,
      'return_charge': returnCharge,
      'return_charge_type': returnChargeType,
      'return_amount': returnAmount,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'items': items.map((x) => x.toJson()).toList(),
    };
  }

  SalesReturnModel copyWith({
    int? id,
    String? receiptNo,
    String? customerName,
    DateTime? returnDate,
    String? accountName,
    int? accountId,
    String? paymentMethod,
    String? reason,
    double? returnCharge,
    String? returnChargeType,
    double? returnAmount,
    String? status,
    DateTime? createdAt,
    List<SalesReturnItem>? items,
  }) {
    return SalesReturnModel(
      id: id ?? this.id,
      receiptNo: receiptNo ?? this.receiptNo,
      customerName: customerName ?? this.customerName,
      returnDate: returnDate ?? this.returnDate,
      accountName: accountName ?? this.accountName,
      accountId: accountId ?? this.accountId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      reason: reason ?? this.reason,
      returnCharge: returnCharge ?? this.returnCharge,
      returnChargeType: returnChargeType ?? this.returnChargeType,
      returnAmount: returnAmount ?? this.returnAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}

class SalesReturnItem {
  final int? id;
  final int? productId;
  final String? productName;
  final int quantity;
  final int damageQuantity;
  final double unitPrice;
  final double? discount;
  final String? discountType;
  final double? total;

  SalesReturnItem({
    this.id,
    this.productId,
    this.productName,
    required this.quantity,
    this.damageQuantity = 0,
    required this.unitPrice,
    this.discount = 0,
    this.discountType,
    this.total,
  });

  factory SalesReturnItem.fromJson(Map<String, dynamic> json) {
    return SalesReturnItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'] ?? 0,
      damageQuantity: json['damage_quantity'] ?? 0,
      unitPrice: json['unit_price'] != null
          ? double.tryParse(json['unit_price'].toString()) ?? 0.0
          : 0.0,
      discount: json['discount'] != null
          ? double.tryParse(json['discount'].toString()) ?? 0.0
          : 0.0,
      discountType: json['discount_type'],
      total: json['total'] != null
          ? double.tryParse(json['total'].toString()) ?? 0.0
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'damage_quantity': damageQuantity,
      'unit_price': unitPrice,
      'discount': discount,
      'discount_type': discountType,
      'total': total,
    };
  }

  SalesReturnItem copyWith({
    int? id,
    int? productId,
    String? productName,
    int? quantity,
    int? damageQuantity,
    double? unitPrice,
    double? discount,
    String? discountType,
    double? total,
  }) {
    return SalesReturnItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      damageQuantity: damageQuantity ?? this.damageQuantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discount: discount ?? this.discount,
      discountType: discountType ?? this.discountType,
      total: total ?? this.total,
    );
  }
}