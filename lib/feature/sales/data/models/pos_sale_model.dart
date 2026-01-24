// To parse this JSON data, do
//
//     final posSaleModel = posSaleModelFromJson(jsonString);

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/core.dart';

List<PosSaleModel> posSaleModelFromJson(String str) => List<PosSaleModel>.from(json.decode(str)['data']['results'].map((x) => PosSaleModel.fromJson(x)));

String posSaleModelToJson(List<PosSaleModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PosSaleModel {
  final int? id;
  final String? invoiceNo;
  final int? customerId;
  final String? customerName;
  final String? saleType;
  final DateTime? saleDate;
  final String? saleByName;
  final String? createdByName;
  final dynamic grossTotal;
  final dynamic netTotal;
  final dynamic grandTotal;
  final dynamic payableAmount;
  final dynamic paidAmount;
  final dynamic dueAmount;
  final dynamic changeAmount;
  final dynamic overallDiscount;
  final String? overallDiscountType;
  final dynamic overallDeliveryCharge;
  final String? overallDeliveryType;
  final dynamic overallServiceCharge;
  final String? overallServiceType;
  final dynamic overallVatAmount;
  final String? overallVatType;
  final String? paymentMethod;
  final int? accountId;
  final String? accountName;
  final String? customerType;
  final String? withMoneyReceipt;
  final String? remark;
  final String? paymentStatus;
  final List<PosSaleItem>? items;

  PosSaleModel({
    this.id,
    this.invoiceNo,
    this.customerId,
    this.customerName,
    this.saleType,
    this.saleDate,
    this.saleByName,
    this.createdByName,
    this.grossTotal,
    this.netTotal,
    this.grandTotal,
    this.payableAmount,
    this.paidAmount,
    this.dueAmount,
    this.changeAmount,
    this.overallDiscount,
    this.overallDiscountType,
    this.overallDeliveryCharge,
    this.overallDeliveryType,
    this.overallServiceCharge,
    this.overallServiceType,
    this.overallVatAmount,
    this.overallVatType,
    this.paymentMethod,
    this.accountId,
    this.accountName,
    this.customerType,
    this.withMoneyReceipt,
    this.remark,
    this.paymentStatus,
    this.items,
  });

  @override
  String toString() {
    return invoiceNo ?? '';
  }

  String get formattedSaleDate {
    if (saleDate == null) return 'N/A';
    return '${saleDate!.day}/${saleDate!.month}/${saleDate!.year}';
  }

  String get formattedTime {
    if (saleDate == null) return 'N/A';
    return '${saleDate!.hour}:${saleDate!.minute.toString().padLeft(2, '0')}';
  }

  double get calculatedDueAmount {
    final payable = payableAmount is String
        ? double.tryParse(payableAmount!) ?? 0.0
        : (payableAmount ?? 0.0).toDouble();
    final paid = paidAmount is String
        ? double.tryParse(paidAmount!) ?? 0.0
        : (paidAmount ?? 0.0).toDouble();
    return payable - paid;
  }

  String get paymentStatusText {
    final payable = payableAmount is String
        ? double.tryParse(payableAmount!) ?? 0.0
        : (payableAmount ?? 0.0).toDouble();
    final paid = paidAmount is String
        ? double.tryParse(paidAmount!) ?? 0.0
        : (paidAmount ?? 0.0).toDouble();

    if (paid >= payable) return 'Paid';
    if (paid > 0) return 'Partial';
    return 'Pending';
  }

  Color get statusColor {
    final status = paymentStatus?.toLowerCase() ?? paymentStatusText.toLowerCase();
    switch (status) {
      case 'paid': return Colors.green;
      case 'partial': return Colors.orange;
      case 'pending': return Colors.red;
      default: return Colors.grey;
    }
  }

  // Total quantity of all items
  double get totalQuantity {
    if (items == null || items!.isEmpty) return 0.0;

    double total = 0.0;
    for (var item in items!) {
      total += item.quantity ?? 0.0;
    }
    return total;
  }

  // Total base quantity (for multi-mode sales)
  double get totalBaseQuantity {
    if (items == null || items!.isEmpty) return 0.0;

    double total = 0.0;
    for (var item in items!) {
      total += item.baseQuantity ?? 0.0;
    }
    return total;
  }

  // Get total items count
  int get itemsCount => items?.length ?? 0;

  factory PosSaleModel.fromJson(Map<String, dynamic> json) => PosSaleModel(
    id: json["id"],
    invoiceNo: json["invoice_no"],
    customerId: json["customer_id"],
    customerName: json["customer_name"],
    saleType: json["sale_type"],
    saleDate: json["sale_date"] == null ? null : DateTime.parse(json["sale_date"]),
    saleByName: json["sale_by_name"],
    createdByName: json["created_by_name"],
    grossTotal: json["gross_total"],
    netTotal: json["net_total"],
    grandTotal: json["grand_total"],
    payableAmount: json["payable_amount"],
    paidAmount: json["paid_amount"],
    dueAmount: json["due_amount"],
    changeAmount: json["change_amount"],
    overallDiscount: json["overall_discount"],
    overallDiscountType: json["overall_discount_type"],
    overallDeliveryCharge: json["overall_delivery_charge"],
    overallDeliveryType: json["overall_delivery_type"],
    overallServiceCharge: json["overall_service_charge"],
    overallServiceType: json["overall_service_type"],
    overallVatAmount: json["overall_vat_amount"],
    overallVatType: json["overall_vat_type"],
    paymentMethod: json["payment_method"],
    accountId: json["account_id"],
    accountName: json["account_name"],
    customerType: json["customer_type"],
    withMoneyReceipt: json["with_money_receipt"],
    remark: json["remark"],
    paymentStatus: json["payment_status"],
    items: json["items"] == null ? [] : List<PosSaleItem>.from(json["items"]!.map((x) => PosSaleItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "invoice_no": invoiceNo,
    "customer_id": customerId,
    "customer_name": customerName,
    "sale_type": saleType,
    "sale_date": saleDate?.toIso8601String(),
    "sale_by_name": saleByName,
    "created_by_name": createdByName,
    "gross_total": grossTotal,
    "net_total": netTotal,
    "grand_total": grandTotal,
    "payable_amount": payableAmount,
    "paid_amount": paidAmount,
    "due_amount": dueAmount,
    "change_amount": changeAmount,
    "overall_discount": overallDiscount,
    "overall_discount_type": overallDiscountType,
    "overall_delivery_charge": overallDeliveryCharge,
    "overall_delivery_type": overallDeliveryType,
    "overall_service_charge": overallServiceCharge,
    "overall_service_type": overallServiceType,
    "overall_vat_amount": overallVatAmount,
    "overall_vat_type": overallVatType,
    "payment_method": paymentMethod,
    "account_id": accountId,
    "account_name": accountName,
    "customer_type": customerType,
    "with_money_receipt": withMoneyReceipt,
    "remark": remark,
    "payment_status": paymentStatus,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class PosSaleItem {
  final int? id;
  final int? productId;
  final String? productName;
  final String? productSku;
  final int? saleModeId;
  final String? saleModeName;
  final double? quantity;      // sale_quantity from API
  final double? baseQuantity;  // base_quantity from API
  final dynamic unitPrice;
  final String? priceType;
  final dynamic flatPrice;
  final String? discount;
  final String? discountType;
  final dynamic subtotal;

  PosSaleItem({
    this.id,
    this.productId,
    this.productName,
    this.productSku,
    this.saleModeId,
    this.saleModeName,
    this.quantity,
    this.baseQuantity,
    this.unitPrice,
    this.priceType,
    this.flatPrice,
    this.discount,
    this.discountType,
    this.subtotal,
  });

  // Helper method to get actual quantity (use sale_quantity if available, otherwise base_quantity)
  double get actualQuantity {
    if (quantity != null && quantity! > 0) {
      return quantity!;
    }
    return baseQuantity ?? 0.0;
  }

  // Helper method to get quantity with unit
  String get quantityWithUnit {
    double qty = actualQuantity;
    if (saleModeName != null) {
      return '${qty.toStringAsFixed(2)} $saleModeName';
    }
    return '${qty.toStringAsFixed(2)} units';
  }

  factory PosSaleItem.fromJson(Map<String, dynamic> json) {
    // Handle quantity from API response
    double? parseQuantity;

    // Try to get quantity from sale_quantity field first
    if (json["sale_quantity"] != null) {
      if (json["sale_quantity"] is String) {
        parseQuantity = double.tryParse(json["sale_quantity"]);
      } else if (json["sale_quantity"] is num) {
        parseQuantity = json["sale_quantity"].toDouble();
      }
    }

    // If sale_quantity is 0 or null, check for quantity field
    if (parseQuantity == null || parseQuantity == 0) {
      if (json["quantity"] != null) {
        if (json["quantity"] is String) {
          parseQuantity = double.tryParse(json["quantity"]);
        } else if (json["quantity"] is num) {
          parseQuantity = json["quantity"].toDouble();
        }
      }
    }

    // Parse base quantity
    double? baseQty;
    if (json["base_quantity"] != null) {
      if (json["base_quantity"] is String) {
        baseQty = double.tryParse(json["base_quantity"]);
      } else if (json["base_quantity"] is num) {
        baseQty = json["base_quantity"].toDouble();
      }
    }

    return PosSaleItem(
      id: json["id"],
      productId: json["product_id"],
      productName: json["product_name"],
      productSku: json["product_sku"],
      saleModeId: json["sale_mode_id"],
      saleModeName: json["sale_mode_name"],
      quantity: parseQuantity ?? baseQty,  // Use sale_quantity if available, otherwise base_quantity
      baseQuantity: baseQty,
      unitPrice: json["unit_price"],
      priceType: json["price_type"],
      flatPrice: json["flat_price"],
      discount: json["discount"],
      discountType: json["discount_type"],
      subtotal: json["subtotal"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "product_id": productId,
    "product_name": productName,
    "product_sku": productSku,
    "sale_mode_id": saleModeId,
    "sale_mode_name": saleModeName,
    "quantity": quantity,
    "base_quantity": baseQuantity,
    "unit_price": unitPrice,
    "price_type": priceType,
    "flat_price": flatPrice,
    "discount": discount,
    "discount_type": discountType,
    "subtotal": subtotal,
  };
}