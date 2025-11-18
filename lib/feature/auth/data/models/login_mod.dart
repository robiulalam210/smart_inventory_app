// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
   bool? success;
   String? message;
  final User? user;
  final Tokens? tokens;
  final Company? company;

  LoginModel({
    this.success,
    this.message,
    this.user,
    this.tokens,
    this.company,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    success: json["success"],
    message: json["message"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    tokens: json["tokens"] == null ? null : Tokens.fromJson(json["tokens"]),
    company: json["company"] == null ? null : Company.fromJson(json["company"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "user": user?.toJson(),
    "tokens": tokens?.toJson(),
    "company": company?.toJson(),
  };
}

class Company {
  final int? id;
  final String? name;
  final dynamic tradeLicense;
  final dynamic address;
  final dynamic phone;
  final dynamic email;
  final dynamic website;
  final dynamic logo;
  final String? currency;
  final String? timezone;
  final DateTime? fiscalYearStart;
  final String? planType;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final bool? isActive;
  final int? maxUsers;
  final int? maxProducts;
  final int? maxBranches;
  final String? companyCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isExpired;
  final int? daysUntilExpiry;
  final int? activeUserCount;
  final int? productCount;

  Company({
    this.id,
    this.name,
    this.tradeLicense,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.logo,
    this.currency,
    this.timezone,
    this.fiscalYearStart,
    this.planType,
    this.startDate,
    this.expiryDate,
    this.isActive,
    this.maxUsers,
    this.maxProducts,
    this.maxBranches,
    this.companyCode,
    this.createdAt,
    this.updatedAt,
    this.isExpired,
    this.daysUntilExpiry,
    this.activeUserCount,
    this.productCount,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    id: json["id"],
    name: json["name"],
    tradeLicense: json["trade_license"],
    address: json["address"],
    phone: json["phone"],
    email: json["email"],
    website: json["website"],
    logo: json["logo"],
    currency: json["currency"],
    timezone: json["timezone"],
    fiscalYearStart: json["fiscal_year_start"] == null ? null : DateTime.parse(json["fiscal_year_start"]),
    planType: json["plan_type"],
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    expiryDate: json["expiry_date"] == null ? null : DateTime.parse(json["expiry_date"]),
    isActive: json["is_active"],
    maxUsers: json["max_users"],
    maxProducts: json["max_products"],
    maxBranches: json["max_branches"],
    companyCode: json["company_code"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    isExpired: json["is_expired"],
    daysUntilExpiry: json["days_until_expiry"],
    activeUserCount: json["active_user_count"],
    productCount: json["product_count"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "trade_license": tradeLicense,
    "address": address,
    "phone": phone,
    "email": email,
    "website": website,
    "logo": logo,
    "currency": currency,
    "timezone": timezone,
    "fiscal_year_start": "${fiscalYearStart!.year.toString().padLeft(4, '0')}-${fiscalYearStart!.month.toString().padLeft(2, '0')}-${fiscalYearStart!.day.toString().padLeft(2, '0')}",
    "plan_type": planType,
    "start_date": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "expiry_date": "${expiryDate!.year.toString().padLeft(4, '0')}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')}",
    "is_active": isActive,
    "max_users": maxUsers,
    "max_products": maxProducts,
    "max_branches": maxBranches,
    "company_code": companyCode,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "is_expired": isExpired,
    "days_until_expiry": daysUntilExpiry,
    "active_user_count": activeUserCount,
    "product_count": productCount,
  };
}

class Tokens {
  final String? refresh;
  final String? access;

  Tokens({
    this.refresh,
    this.access,
  });

  factory Tokens.fromJson(Map<String, dynamic> json) => Tokens(
    refresh: json["refresh"],
    access: json["access"],
  );

  Map<String, dynamic> toJson() => {
    "refresh": refresh,
    "access": access,
  };
}

class User {
  final int? id;
  final String? username;
  final String? email;
  final bool? isStaff;
  final bool? isSuperuser;
  final bool? isActive;
  final String? role;

  User({
    this.id,
    this.username,
    this.email,
    this.isStaff,
    this.isSuperuser,
    this.isActive,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    username: json["username"],
    email: json["email"],
    isStaff: json["is_staff"],
    isSuperuser: json["is_superuser"],
    isActive: json["is_active"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "is_staff": isStaff,
    "is_superuser": isSuperuser,
    "is_active": isActive,
    "role": role,
  };
}
