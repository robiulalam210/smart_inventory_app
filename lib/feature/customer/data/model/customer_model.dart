// To parse this JSON data, do
//
//     final customerModel = customerModelFromJson(jsonString);

import 'dart:convert';

List<CustomerModel> customerModelFromJson(String str) => List<CustomerModel>.from(json.decode(str).map((x) => CustomerModel.fromJson(x)));

String customerModelToJson(List<CustomerModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CustomerModel {
  final int? id;
  final int? company;
  final String? name;
  final dynamic phone;
  final String? address;

  CustomerModel({
    this.id,
    this.company,
    this.name,
    this.phone,
    this.address,
  });
  @override
  String toString() {
    // TODO: implement toString
    return name??"";
  }
  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: json["id"],
    company: json["company"],
    name: json["name"],
    phone: json["phone"],
    address: json["address"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company": company,
    "name": name,
    "phone": phone,
    "address": address,
  };
}
