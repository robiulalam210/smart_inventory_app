// To parse this JSON data, do
//
//     final profilePermissionModel = profilePermissionModelFromJson(jsonString);

import 'dart:convert';

ProfilePermissionModel profilePermissionModelFromJson(String str) => ProfilePermissionModel.fromJson(json.decode(str));

String profilePermissionModelToJson(ProfilePermissionModel data) => json.encode(data.toJson());

class ProfilePermissionModel {
  final bool? status;
  final String? message;
  final Data? data;

  ProfilePermissionModel({
    this.status,
    this.message,
    this.data,
  });

  factory ProfilePermissionModel.fromJson(Map<String, dynamic> json) => ProfilePermissionModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  final User? user;
  final dynamic staffProfile;
  final Permissions? permissions;
  final CompanyInfo? companyInfo;

  Data({
    this.user,
    this.staffProfile,
    this.permissions,
    this.companyInfo,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    staffProfile: json["staff_profile"],
    permissions: json["permissions"] == null ? null : Permissions.fromJson(json["permissions"]),
    companyInfo: json["company_info"] == null ? null : CompanyInfo.fromJson(json["company_info"]),
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "staff_profile": staffProfile,
    "permissions": permissions?.toJson(),
    "company_info": companyInfo?.toJson(),
  };
}

class CompanyInfo {
  final int? id;
  final String? name;
  final String? tradeLicense;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
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

  CompanyInfo({
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
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) => CompanyInfo(
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
  };
}

class Permissions {
  final Dashboard? dashboard;
  final Accounts? sales;
  final Accounts? moneyReceipt;
  final Accounts? purchases;
  final Accounts? products;
  final Accounts? accounts;
  final Accounts? customers;
  final Accounts? suppliers;
  final Accounts? expense;
  final Accounts? permissionsReturn;
  final Reports? reports;
  final Accounts? users;
  final Accounts? administration;
  final Settings? settings;

  Permissions({
    this.dashboard,
    this.sales,
    this.moneyReceipt,
    this.purchases,
    this.products,
    this.accounts,
    this.customers,
    this.suppliers,
    this.expense,
    this.permissionsReturn,
    this.reports,
    this.users,
    this.administration,
    this.settings,
  });

  factory Permissions.fromJson(Map<String, dynamic> json) => Permissions(
    dashboard: json["dashboard"] == null ? null : Dashboard.fromJson(json["dashboard"]),
    sales: json["sales"] == null ? null : Accounts.fromJson(json["sales"]),
    moneyReceipt: json["money_receipt"] == null ? null : Accounts.fromJson(json["money_receipt"]),
    purchases: json["purchases"] == null ? null : Accounts.fromJson(json["purchases"]),
    products: json["products"] == null ? null : Accounts.fromJson(json["products"]),
    accounts: json["accounts"] == null ? null : Accounts.fromJson(json["accounts"]),
    customers: json["customers"] == null ? null : Accounts.fromJson(json["customers"]),
    suppliers: json["suppliers"] == null ? null : Accounts.fromJson(json["suppliers"]),
    expense: json["expense"] == null ? null : Accounts.fromJson(json["expense"]),
    permissionsReturn: json["return"] == null ? null : Accounts.fromJson(json["return"]),
    reports: json["reports"] == null ? null : Reports.fromJson(json["reports"]),
    users: json["users"] == null ? null : Accounts.fromJson(json["users"]),
    administration: json["administration"] == null ? null : Accounts.fromJson(json["administration"]),
    settings: json["settings"] == null ? null : Settings.fromJson(json["settings"]),
  );

  Map<String, dynamic> toJson() => {
    "dashboard": dashboard?.toJson(),
    "sales": sales?.toJson(),
    "money_receipt": moneyReceipt?.toJson(),
    "purchases": purchases?.toJson(),
    "products": products?.toJson(),
    "accounts": accounts?.toJson(),
    "customers": customers?.toJson(),
    "suppliers": suppliers?.toJson(),
    "expense": expense?.toJson(),
    "return": permissionsReturn?.toJson(),
    "reports": reports?.toJson(),
    "users": users?.toJson(),
    "administration": administration?.toJson(),
    "settings": settings?.toJson(),
  };
}

class Accounts {
  final bool? view;
  final bool? create;
  final bool? edit;
  final bool? delete;

  Accounts({
    this.view,
    this.create,
    this.edit,
    this.delete,
  });

  factory Accounts.fromJson(Map<String, dynamic> json) => Accounts(
    view: json["view"],
    create: json["create"],
    edit: json["edit"],
    delete: json["delete"],
  );

  Map<String, dynamic> toJson() => {
    "view": view,
    "create": create,
    "edit": edit,
    "delete": delete,
  };
}

class Dashboard {
  final bool? view;

  Dashboard({
    this.view,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) => Dashboard(
    view: json["view"],
  );

  Map<String, dynamic> toJson() => {
    "view": view,
  };
}

class Reports {
  final bool? view;
  final bool? create;
  final bool? reportsExport;

  Reports({
    this.view,
    this.create,
    this.reportsExport,
  });

  factory Reports.fromJson(Map<String, dynamic> json) => Reports(
    view: json["view"],
    create: json["create"],
    reportsExport: json["export"],
  );

  Map<String, dynamic> toJson() => {
    "view": view,
    "create": create,
    "export": reportsExport,
  };
}

class Settings {
  final bool? view;
  final bool? edit;

  Settings({
    this.view,
    this.edit,
  });

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    view: json["view"],
    edit: json["edit"],
  );

  Map<String, dynamic> toJson() => {
    "view": view,
    "edit": edit,
  };
}

class User {
  final int? id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? role;
  final int? company;
  final CompanyInfo? companyInfo;
  final dynamic phone;
  final dynamic profilePicture;
  final dynamic dateOfBirth;
  final bool? isVerified;
  final DateTime? lastLogin;
  final DateTime? dateJoined;
  final Permissions? permissions;
  final bool? isActive;

  User({
    this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    this.role,
    this.company,
    this.companyInfo,
    this.phone,
    this.profilePicture,
    this.dateOfBirth,
    this.isVerified,
    this.lastLogin,
    this.dateJoined,
    this.permissions,
    this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    username: json["username"],
    email: json["email"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    fullName: json["full_name"],
    role: json["role"],
    company: json["company"],
    companyInfo: json["company_info"] == null ? null : CompanyInfo.fromJson(json["company_info"]),
    phone: json["phone"],
    profilePicture: json["profile_picture"],
    dateOfBirth: json["date_of_birth"],
    isVerified: json["is_verified"],
    lastLogin: json["last_login"] == null ? null : DateTime.parse(json["last_login"]),
    dateJoined: json["date_joined"] == null ? null : DateTime.parse(json["date_joined"]),
    permissions: json["permissions"] == null ? null : Permissions.fromJson(json["permissions"]),
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "first_name": firstName,
    "last_name": lastName,
    "full_name": fullName,
    "role": role,
    "company": company,
    "company_info": companyInfo?.toJson(),
    "phone": phone,
    "profile_picture": profilePicture,
    "date_of_birth": dateOfBirth,
    "is_verified": isVerified,
    "last_login": lastLogin?.toIso8601String(),
    "date_joined": dateJoined?.toIso8601String(),
    "permissions": permissions?.toJson(),
    "is_active": isActive,
  };
}
