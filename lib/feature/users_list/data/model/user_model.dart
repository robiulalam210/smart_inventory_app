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
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? role;
  final Company? company;
  final String? phone;
  final bool? isActive;
  final bool? isStaff;

  UsersListModel({
    this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    this.role,
    this.company,
    this.phone,
    this.isActive,
    this.isStaff,
  });

  @override
  String toString() {
    final name = (fullName != null && fullName!.trim().isNotEmpty)
        ? fullName!
        : (username ?? '');

    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UsersListModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
  factory UsersListModel.fromJson(Map<String, dynamic> json) => UsersListModel(
    id: json["id"],
    username: json["username"],
    email: json["email"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    fullName: ((json["first_name"] ?? "") + " " + (json["last_name"] ?? "")).trim(),
    role: json["role"],
    company: json["company"] == null ? null : Company.fromJson(json["company"]),
    phone: json["phone"],
    isActive: json["is_active"],
    isStaff: json["is_staff"],
  );


  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "first_name": firstName,
    "last_name": lastName,
    "full_name": fullName,
    "role": role,
    "company": company?.toJson(),
    "phone": phone,
    "is_active": isActive,
    "is_staff": isStaff,
  };
}


class Company {
  final int? id;
  final String? name;
  final String? companyCode;
  final String? address;
  final String? phone;
  final String? email;
  final dynamic logo;
  final bool? isActive;
  final String? planType;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final int? daysUntilExpiry;
  final int? activeUserCount;
  final int? productCount;

  Company({
    this.id,
    this.name,
    this.companyCode,
    this.address,
    this.phone,
    this.email,
    this.logo,
    this.isActive,
    this.planType,
    this.startDate,
    this.expiryDate,
    this.daysUntilExpiry,
    this.activeUserCount,
    this.productCount,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    id: json["id"],
    name: json["name"],
    companyCode: json["company_code"],
    address: json["address"],
    phone: json["phone"],
    email: json["email"],
    logo: json["logo"],
    isActive: json["is_active"],
    planType: json["plan_type"],
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    expiryDate: json["expiry_date"] == null ? null : DateTime.parse(json["expiry_date"]),
    daysUntilExpiry: json["days_until_expiry"],
    activeUserCount: json["active_user_count"],
    productCount: json["product_count"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "company_code": companyCode,
    "address": address,
    "phone": phone,
    "email": email,
    "logo": logo,
    "is_active": isActive,
    "plan_type": planType,
    "start_date": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "expiry_date": "${expiryDate!.year.toString().padLeft(4, '0')}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')}",
    "days_until_expiry": daysUntilExpiry,
    "active_user_count": activeUserCount,
    "product_count": productCount,
  };
}
