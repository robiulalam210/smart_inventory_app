import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  final LoginModelUser? user;
  final Tokens? tokens;
  bool? success;
  String? message;

  LoginModel({
    this.user,
    this.tokens,
    this.success,
    this.message,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    user: json["user"] == null
        ? null
        : LoginModelUser.fromJson(json["user"]),
    tokens:
    json["tokens"] == null ? null : Tokens.fromJson(json["tokens"]),
    success: json["success"], // optional from API
    message: json["message"], // optional from API
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "tokens": tokens?.toJson(),
    "success": success,
    "message": message,
  };
}

class Tokens {
  final String? refresh;
  final String? access;

  Tokens({this.refresh, this.access});

  factory Tokens.fromJson(Map<String, dynamic> json) => Tokens(
    refresh: json["refresh"],
    access: json["access"],
  );

  Map<String, dynamic> toJson() => {
    "refresh": refresh,
    "access": access,
  };
}

class LoginModelUser {
  final int? id;
  final String? username;
  final String? email;
  final String? role;
  final Company? company;
  final Staff? staff;

  LoginModelUser({
    this.id,
    this.username,
    this.email,
    this.role,
    this.company,
    this.staff,
  });

  factory LoginModelUser.fromJson(Map<String, dynamic> json) =>
      LoginModelUser(
        id: json["id"],
        username: json["username"],
        email: json["email"],
        role: json["role"],
        company:
        json["company"] == null ? null : Company.fromJson(json["company"]),
        staff: json["staff"] == null ? null : Staff.fromJson(json["staff"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "role": role,
    "company": company?.toJson(),
    "staff": staff?.toJson(),
  };
}

class Company {
  final int? id;
  final String? name;
  final String? address;
  final dynamic phone;
  final dynamic logo;
  final bool? isActive;
  final String? startDate;  // Added this field
  final String? expiryDate; // Added this field

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
    startDate: json["start_date"],  // Added this line
    expiryDate: json["expiry_date"], // Added this line
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "address": address,
    "phone": phone,
    "logo": logo,
    "is_active": isActive,
    "start_date": startDate,  // Added this line
    "expiry_date": expiryDate, // Added this line
  };
}

class Staff {
  final int? id;
  final StaffUser? user;
  final String? roleName;
  final String? phone;
  final dynamic designation;
  final String? salary;
  final String? commission;
  final bool? isMainUser;
  final int? status;
  final DateTime? joiningDate;
  final String? address;
  final DateTime? createdAt;

  Staff({
    this.id,
    this.user,
    this.roleName,
    this.phone,
    this.designation,
    this.salary,
    this.commission,
    this.isMainUser,
    this.status,
    this.joiningDate,
    this.address,
    this.createdAt,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
    id: json["id"],
    user: json["user"] == null ? null : StaffUser.fromJson(json["user"]),
    roleName: json["role_name"],
    phone: json["phone"],
    designation: json["designation"],
    salary: json["salary"],
    commission: json["commission"],
    isMainUser: json["is_main_user"],
    status: json["status"],
    joiningDate: json["joining_date"] == null
        ? null
        : DateTime.parse(json["joining_date"]),
    address: json["address"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user": user?.toJson(),
    "role_name": roleName,
    "phone": phone,
    "designation": designation,
    "salary": salary,
    "commission": commission,
    "is_main_user": isMainUser,
    "status": status,
    "joining_date": joiningDate?.toIso8601String(),
    "address": address,
    "created_at": createdAt?.toIso8601String(),
  };
}

class StaffUser {
  final int? id;
  final String? username;
  final String? email;
  final String? role;

  StaffUser({this.id, this.username, this.email, this.role});

  factory StaffUser.fromJson(Map<String, dynamic> json) => StaffUser(
    id: json["id"],
    username: json["username"],
    email: json["email"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "role": role,
  };
}