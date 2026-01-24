// features/products/sale_mode/data/models/product_sale_mode_model.dart

import 'dart:convert';
import 'package:equatable/equatable.dart';

import '../../price_tier/data/model/price_tier_model.dart';

import 'package:equatable/equatable.dart';

class ProductSaleModeModel extends Equatable {
  final int id;

  // Product info
  final String productName;
  final String productSku;

  // Sale mode info
  final String saleModeName;
  final String saleModeCode;
  final String baseUnitName;

  // Pricing
  final double? unitPrice;
  final double? flatPrice;
  final String priceType;
  final double conversionFactor;

  // Discount
  final String? discountType;
  final double? discountValue;

  // Status
  final bool isActive;

  // Meta
  final String createdAt;
  final String updatedAt;

  // Price tiers
  final List<PriceTierModel> tiers;

  const ProductSaleModeModel({
    required this.id,
    required this.productName,
    required this.productSku,
    required this.saleModeName,
    required this.saleModeCode,
    required this.baseUnitName,
    required this.unitPrice,
    required this.flatPrice,
    required this.priceType,
    required this.conversionFactor,
    required this.discountType,
    required this.discountValue,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.tiers,
  });

  factory ProductSaleModeModel.fromJson(Map<String, dynamic> json) {
    return ProductSaleModeModel(
      id: json['id'],

      productName: json['product_name'] ?? '',
      productSku: json['product_sku'] ?? '',

      saleModeName: json['sale_mode_name'] ?? '',
      saleModeCode: json['sale_mode_code'] ?? '',
      baseUnitName: json['base_unit_name'] ?? '',

      unitPrice: json['unit_price'] != null
          ? double.tryParse(json['unit_price'].toString())
          : null,

      flatPrice: json['flat_price'] != null
          ? double.tryParse(json['flat_price'].toString())
          : null,

      priceType: json['price_type'] ?? 'unit',

      conversionFactor: double.tryParse(
        json['conversion_factor']?.toString() ?? '1',
      ) ??
          1,

      discountType: json['discount_type'],

      discountValue: json['discount_value'] != null
          ? double.tryParse(json['discount_value'].toString())
          : null,

      isActive: json['is_active'] ?? false,

      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',

      tiers: (json['tiers'] as List<dynamic>? ?? [])
          .map((e) => PriceTierModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'product_sku': productSku,
      'sale_mode_name': saleModeName,
      'sale_mode_code': saleModeCode,
      'base_unit_name': baseUnitName,
      'unit_price': unitPrice,
      'flat_price': flatPrice,
      'price_type': priceType,
      'conversion_factor': conversionFactor,
      'discount_type': discountType,
      'discount_value': discountValue,
      'is_active': isActive,
      'tiers': tiers.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return '$saleModeName | price: ${unitPrice ?? flatPrice} | type: $priceType';
  }

  @override
  List<Object?> get props => [
    id,
    productName,
    productSku,
    saleModeName,
    saleModeCode,
    baseUnitName,
    unitPrice,
    flatPrice,
    priceType,
    conversionFactor,
    discountType,
    discountValue,
    isActive,
    createdAt,
    updatedAt,
    tiers,
  ];
}

