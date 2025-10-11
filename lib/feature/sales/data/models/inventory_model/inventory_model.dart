class InventoryLocalProduct {
  final int? id;
  final int? webId;
  final String? name;
  final String? itemCode;
  final int? quantity;
  final double? price;

  InventoryLocalProduct({
    this.id,
     this.webId,
     this.name,
     this.itemCode,
     this.quantity,
     this.price,
  });

  @override
  String toString() => name??"";

  // Convert model to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'webId': webId,
      'name': name,
      'item_code': itemCode,
      'quantity': quantity,
      'price': price,
    };
  }

  factory InventoryLocalProduct.fromMap(Map<String, dynamic> map) {
    return InventoryLocalProduct(
      id: map['id'] as int?,
      webId: map['webId'] is int ? map['webId'] : int.tryParse(map['webId']?.toString() ?? ''),
      name: map['name'] as String? ?? '',
      itemCode: map['item_code'] as String? ?? '',
      quantity: (map['quantity'] is int) ? map['quantity'] : int.tryParse(map['quantity']?.toString() ?? '') ?? 0,
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : double.tryParse(map['price']?.toString() ?? '') ?? 0.0,
    );
  }

}