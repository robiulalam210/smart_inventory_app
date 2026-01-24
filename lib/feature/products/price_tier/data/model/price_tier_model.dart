import 'package:equatable/equatable.dart';

class PriceTierModel extends Equatable {
  final int? id;
  final int? productSaleMode;
  final double? minQuantity;
  final double? maxQuantity;
  final double? price;
  final String? unit; // ADD THIS FIELD
  final DateTime? createdAt; // ADD THIS IF NEEDED
  final DateTime? updatedAt; // ADD THIS IF NEEDED

  const PriceTierModel({
    this.id,
    this.productSaleMode,
    this.minQuantity,
    this.maxQuantity,
    this.price,
    this.unit, // ADD THIS
    this.createdAt, // ADD THIS
    this.updatedAt, // ADD THIS
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
      unit: json['unit'], // ADD THIS
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null, // ADD THIS
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null, // ADD THIS
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_sale_mode': productSaleMode,
      'min_quantity': minQuantity,
      'max_quantity': maxQuantity,
      'price': price,
      'unit': unit, // ADD THIS
    };
  }

  @override
  List<Object?> get props => [
    id,
    productSaleMode,
    minQuantity,
    maxQuantity,
    price,
    unit, // ADD THIS
    createdAt, // ADD THIS
    updatedAt, // ADD THIS
  ];
}