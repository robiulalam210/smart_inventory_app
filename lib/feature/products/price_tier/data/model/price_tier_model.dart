// features/products/sale_mode/data/model/price_tier_model.dart

import 'package:equatable/equatable.dart';

class PriceTierModel extends Equatable {
  final int? id;
  final int? productSaleMode;
  final double? minQuantity;
  final double? maxQuantity;
  final double? price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PriceTierModel({
    this.id,
    this.productSaleMode,
    this.minQuantity,
    this.maxQuantity,
    this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory PriceTierModel.fromJson(Map<String, dynamic> json) {
    return PriceTierModel(
      id: json['id'],
      productSaleMode: json['product_sale_mode'] is int
          ? json['product_sale_mode']
          : int.tryParse(json['product_sale_mode'].toString()),
      minQuantity: json['min_quantity']?.toDouble(),
      maxQuantity: json['max_quantity']?.toDouble(),
      price: json['price']?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (productSaleMode != null) 'product_sale_mode': productSaleMode,
      if (minQuantity != null) 'min_quantity': minQuantity,
      if (maxQuantity != null) 'max_quantity': maxQuantity,
      if (price != null) 'price': price,
      // Do NOT include createdAt or updatedAt in POST requests
    };
  }

  @override
  List<Object?> get props => [
    id,
    productSaleMode,
    minQuantity,
    maxQuantity,
    price,
    createdAt,
    updatedAt,
  ];
}