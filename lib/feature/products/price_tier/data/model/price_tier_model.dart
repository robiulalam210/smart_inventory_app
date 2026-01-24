class PriceTierModel {
  final int? id;
  final int? productSaleMode;
  final double? minQuantity;
  final double? maxQuantity;
  final double? price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PriceTierModel({
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
      id: json['id'] as int?,
      productSaleMode: json['product_sale_mode'] as int?,
      minQuantity: json['min_quantity'] != null
          ? double.tryParse(json['min_quantity'].toString())
          : null,
      maxQuantity: json['max_quantity'] != null
          ? double.tryParse(json['max_quantity'].toString())
          : null,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
