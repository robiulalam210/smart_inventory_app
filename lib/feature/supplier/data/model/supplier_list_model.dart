// To parse this JSON data, do
//
//     final supplierListModel = supplierListModelFromJson(jsonString);

import 'dart:convert';

List<SupplierListModel> supplierListModelFromJson(String str) => List<SupplierListModel>.from(json.decode(str).map((x) => SupplierListModel.fromJson(x)));

String supplierListModelToJson(List<SupplierListModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SupplierListModel {
  int? id;
  String? name;
  String? phone;
  String? address;
  int? status;
  String? supplierNo;
  String? email;
  dynamic additionalPhone;
  dynamic additionalEmail;
  dynamic sourceName;
  dynamic sourceId;
  String? due;


  @override
  String toString(){
    return "[${supplierNo??""}]$name(Due: ${due??"0"})";
  }
  SupplierListModel({
    this.id,
    this.name,
    this.phone,
    this.address,
    this.status,
    this.supplierNo,
    this.email,
    this.additionalPhone,
    this.additionalEmail,
    this.sourceName,
    this.sourceId,
    this.due,
  });

  factory SupplierListModel.fromJson(Map<String, dynamic> json) => SupplierListModel(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    address: json["address"],
    status: json["status"],
    supplierNo: json["supplier_no"],
    email: json["email"],
    additionalPhone: json["additional_phone"],
    additionalEmail: json["additional_email"],
    sourceName: json["source_name"],
    sourceId: json["source_id"],
    due: json["due"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "address": address,
    "status": status,
    "supplier_no": supplierNo,
    "email": email,
    "additional_phone": additionalPhone,
    "additional_email": additionalEmail,
    "source_name": sourceName,
    "source_id": sourceId,
    "due": due,
  };
}
