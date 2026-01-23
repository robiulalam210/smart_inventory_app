// features/products/sale_mode/data/models/product_sale_mode_model.dart

import 'dart:convert';
import 'package:equatable/equatable.dart';

class PriceTierModel extends Equatable {
  final int? id;
  final int? productSaleMode;
  final double? minQuantity;
  final double? maxQuantity;
  final double? price;

  const PriceTierModel({
    this.id,
    this.productSaleMode,
    this.minQuantity,
    this.maxQuantity,
    this.price,
  });

  factory PriceTierModel.fromJson(Map<String, dynamic> json) {
    return PriceTierModel(
      id: json['id'],
      productSaleMode: json['product_sale_mode'],
      minQuantity: json['min_quantity'] != null
          ? double.tryParse(json['min_quantity'].toString())
          : null,
      maxQuantity: json['max_quantity'] != null
          ? double.tryParse(json['max_quantity'].toString())
          : null,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_sale_mode': productSaleMode,
      'min_quantity': minQuantity,
      'max_quantity': maxQuantity,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [
    id,
    productSaleMode,
    minQuantity,
    maxQuantity,
    price,
  ];
}

class ProductSaleModeModel extends Equatable {
  final int? id;
  final int? product;
  final int? saleMode;
  final double? unitPrice;
  final double? flatPrice;
  final String? priceType;
  final double? conversionFactor;
  final String? discountType;
  final double? discountValue;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? saleModeName;
  final String? saleModeCode;
  final List<PriceTierModel>? tiers;

  const ProductSaleModeModel({
    this.id,
    this.product,
    this.saleMode,
    this.unitPrice,
    this.flatPrice,
    this.priceType,
    this.conversionFactor,
    this.discountType,
    this.discountValue,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.saleModeName,
    this.saleModeCode,
    this.tiers,
  });

  factory ProductSaleModeModel.fromJson(Map<String, dynamic> json) {
    return ProductSaleModeModel(
      id: json['id'],
      product: json['product'],
      saleMode: json['sale_mode'],
      unitPrice: json['unit_price'] != null
          ? double.tryParse(json['unit_price'].toString())
          : null,
      flatPrice: json['flat_price'] != null
          ? double.tryParse(json['flat_price'].toString())
          : null,
      priceType: json['price_type'],
      conversionFactor: json['conversion_factor'] != null
          ? double.tryParse(json['conversion_factor'].toString())
          : null,
      discountType: json['discount_type'],
      discountValue: json['discount_value'] != null
          ? double.tryParse(json['discount_value'].toString())
          : null,
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      saleModeName: json['sale_mode_name'],
      saleModeCode: json['sale_mode_code'],
      tiers: json['tiers'] != null
          ? List<PriceTierModel>.from(
          json['tiers'].map((x) => PriceTierModel.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product,
      'sale_mode': saleMode,
      'unit_price': unitPrice,
      'flat_price': flatPrice,
      'price_type': priceType,
      'discount_type': discountType,
      'discount_value': discountValue,
      'is_active': isActive,
      'tiers': tiers != null
          ? List<dynamic>.from(tiers!.map((x) => x.toJson()))
          : null,
    };
  }

  @override
  List<Object?> get props => [
    id,
    product,
    saleMode,
    unitPrice,
    flatPrice,
    priceType,
    conversionFactor,
    discountType,
    discountValue,
    isActive,
    createdAt,
    updatedAt,
    saleModeName,
    saleModeCode,
    tiers,
  ];
}

