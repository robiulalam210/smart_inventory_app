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
  final Business? business;

  LoginModel({
    this.success,
    this.message,
    this.user,
    this.tokens,
    this.business,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return LoginModel(
      success: json["success"],
      message: json["message"],
      user: data?["user"] == null ? null : User.fromJson(data["user"]),
      tokens: data?["tokens"] == null ? null : Tokens.fromJson(data["tokens"]),
      // পুরনো cache করা login (key = company) ও পড়া যাবে
      business: (data?["business"] ?? data?["company"]) == null
          ? null
          : Business.fromJson(Map<String, dynamic>.from(data["business"] ?? data["company"])),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": {
      "user": user?.toJson(),
      "tokens": tokens?.toJson(),
      "business": business?.toJson(),
    }
  };
}

/// একমাত্র ব্যবসার তথ্য (server: BusinessProfile, login response এর `business`)
class Business {
  final int? id;
  final String? name;
  final String? tagline;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? address;
  final String? website;
  final String? tradeLicense;
  final dynamic logo;
  final String? currency;
  final DateTime? updatedAt;

  Business({
    this.id,
    this.name,
    this.tagline,
    this.phone,
    this.whatsapp,
    this.email,
    this.address,
    this.website,
    this.tradeLicense,
    this.logo,
    this.currency,
    this.updatedAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) => Business(
    id: json["id"],
    name: json["name"],
    tagline: json["tagline"],
    phone: json["phone"],
    whatsapp: json["whatsapp"],
    email: json["email"],
    address: json["address"],
    website: json["website"],
    tradeLicense: json["trade_license"],
    logo: json["logo"],
    currency: json["currency"],
    updatedAt: json["updated_at"] == null ? null : DateTime.tryParse(json["updated_at"].toString()),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "tagline": tagline,
    "phone": phone,
    "whatsapp": whatsapp,
    "email": email,
    "address": address,
    "website": website,
    "trade_license": tradeLicense,
    "logo": logo,
    "currency": currency,
    "updated_at": updatedAt?.toIso8601String(),
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
