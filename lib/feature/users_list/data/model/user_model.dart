// To parse this JSON data, do
//
//     final usersListModel = usersListModelFromJson(jsonString);

import 'dart:convert';

List<UsersListModel> usersListModelFromJson(String str) => List<UsersListModel>.from(json.decode(str).map((x) => UsersListModel.fromJson(x)));

String usersListModelToJson(List<UsersListModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UsersListModel {
  final int? id;
  final String? username;
  final String? email;
  final String? role;
  final Company? company;
  final bool? isActive;
  final bool? isStaff;

  UsersListModel({
    this.id,
    this.username,
    this.email,
    this.role,
    this.company,
    this.isActive,
    this.isStaff,
  });

  @override
  String toString() {
    // TODO: implement toString
    return username??"";
  }
  factory UsersListModel.fromJson(Map<String, dynamic> json) => UsersListModel(
    id: json["id"],
    username: json["username"],
    email: json["email"],
    role: json["role"],
    company: json["company"] == null ? null : Company.fromJson(json["company"]),
    isActive: json["is_active"],
    isStaff: json["is_staff"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "role": role,
    "company": company?.toJson(),
    "is_active": isActive,
    "is_staff": isStaff,
  };
}

class Company {
  final int? id;
  final String? name;
  final String? address;
  final String? phone;
  final String? logo;
  final bool? isActive;
  final DateTime? startDate;
  final DateTime? expiryDate;

  Company({
    this.id,
    this.name,
    this.address,
    this.phone,
    this.logo,
    this.isActive,
    this.startDate,
    this.expiryDate,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    id: json["id"],
    name: json["name"],
    address: json["address"],
    phone: json["phone"],
    logo: json["logo"],
    isActive: json["is_active"],
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    expiryDate: json["expiry_date"] == null ? null : DateTime.parse(json["expiry_date"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "address": address,
    "phone": phone,
    "logo": logo,
    "is_active": isActive,
    "start_date": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "expiry_date": "${expiryDate!.year.toString().padLeft(4, '0')}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')}",
  };
}
