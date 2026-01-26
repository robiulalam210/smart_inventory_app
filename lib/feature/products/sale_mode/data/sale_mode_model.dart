// features/products/sale_mode/data/models/sale_mode_model.dart

import 'package:equatable/equatable.dart';

class SaleModeModel extends Equatable {
  final int? id;
  final String? name;
  final String? code;
  final int? baseUnit;
  final double? conversionFactor;
  final String? priceType;
  final bool? isActive;
  final int? company;
  final String? createdAt;
  final String? updatedAt;
  final String? baseUnitName;

  const SaleModeModel({
    this.id,
    this.name,
    this.code,
    this.baseUnit,
    this.conversionFactor,
    this.priceType,
    this.isActive,
    this.company,
    this.createdAt,
    this.updatedAt,
    this.baseUnitName,
  });

  factory SaleModeModel.fromJson(Map<String, dynamic> json) {
    return SaleModeModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      baseUnit: json['base_unit'],
      conversionFactor: json['conversion_factor'] != null
          ? double.tryParse(json['conversion_factor'].toString())
          : null,
      priceType: json['price_type'],
      isActive: json['is_active'],
      company: json['company'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      baseUnitName: json['base_unit_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'base_unit': baseUnit,
      'conversion_factor': conversionFactor,
      'price_type': priceType,
      'is_active': isActive,
      'company': company,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    baseUnit,
    conversionFactor,
    priceType,
    isActive,
    company,
    createdAt,
    updatedAt,
    baseUnitName,
  ];
}