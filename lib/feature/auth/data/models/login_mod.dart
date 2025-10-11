// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  bool? success;
   String? message;
   String? accessToken;
   User? user;

  LoginModel({
    this.success,
    this.message,
    this.accessToken,
    this.user,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    success: json["success"],
    message: json["message"],
    accessToken: json["access_token"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "access_token": accessToken,
    "user": user?.toJson(),
  };
}

class User {
  final int? id;
  final String? email;
  final String? mobile;
  final String? userId;
  final String? userType;
  final String? organizationName;
  final int? organizationId;
  final String? organizationMobile;
  final String? organizationEmail;
  final String? organizationAddress;
  final String? organizationLogo;
  final int? branchId;
  final String? branchName;
  final int? sUid;
  final String? bsType;
  final String? name;

  User({
    this.id,
    this.email,
    this.mobile,
    this.userId,
    this.userType,
    this.organizationName,
    this.organizationId,
    this.organizationMobile,
    this.organizationEmail,
    this.organizationAddress,
    this.organizationLogo,
    this.branchId,
    this.branchName,
    this.sUid,
    this.bsType,
    this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    email: json["email"],
    mobile: json["mobile"],
    userId: json["user_id"],
    userType: json["user_type"],
    organizationName: json["organization_name"],
    organizationId: json["organization_id"],
    organizationMobile: json["organization_mobile"],
    organizationEmail: json["organization_email"],
    organizationAddress: json["organization_address"],
    organizationLogo: json["organization_logo"],
    branchId: json["branch_id"],
    branchName: json["branch_name"],
    sUid: json["s_uid"],
    bsType: json["bs_type"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "mobile": mobile,
    "user_id": userId,
    "user_type": userType,
    "organization_name": organizationName,
    "organization_id": organizationId,
    "organization_mobile": organizationMobile,
    "organization_email": organizationEmail,
    "organization_address": organizationAddress,
    "organization_logo": organizationLogo,
    "branch_id": branchId,
    "branch_name": branchName,
    "s_uid": sUid,
    "bs_type": bsType,
    "name": name,
  };
}


// // To parse this JSON data, do
// //
// //     final loginModel = loginModelFromJson(jsonString);
//
// import 'dart:convert';
//
// LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));
//
// String loginModelToJson(LoginModel data) => json.encode(data.toJson());
//
// class LoginModel {
//   bool? success;
//   Data? data;
//   String? token;
//
//   LoginModel({
//     this.success,
//     this.data,
//     this.token,
//   });
//
//   factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
//     success: json["success"],
//     data: json["data"] == null ? null : Data.fromJson(json["data"]),
//     token: json["token"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "success": success,
//     "data": data?.toJson(),
//     "token": token,
//   };
// }
//
// class Data {
//   int? id;
//   String? userName;
//   String? userPhone;
//   String? userEmail;
//   String? image;
//   dynamic locationId;
//   int? allBranch;
//   dynamic locationName;
//   int? status;
//   String? roleName;
//   int? roleId;
//   int? companyId;
//   String? companyName;
//   String? companyEmail;
//   String? companyPhone;
//   String? companyAddress;
//   String? companyLogo;
//   dynamic companyCompressedLogo;
//   DateTime? companyCreatedAt;
//   String? companyStatus;
//   Role? role;
//   List<CanAccessModule>? canAccessModules;
//
//   Data({
//     this.id,
//     this.userName,
//     this.userPhone,
//     this.userEmail,
//     this.image,
//     this.locationId,
//     this.allBranch,
//     this.locationName,
//     this.status,
//     this.roleName,
//     this.roleId,
//     this.companyId,
//     this.companyName,
//     this.companyEmail,
//     this.companyPhone,
//     this.companyAddress,
//     this.companyLogo,
//     this.companyCompressedLogo,
//     this.companyCreatedAt,
//     this.companyStatus,
//     this.role,
//     this.canAccessModules,
//   });
//
//   factory Data.fromJson(Map<String, dynamic> json) => Data(
//     id: json["id"],
//     userName: json["user_name"],
//     userPhone: json["user_phone"],
//     userEmail: json["user_email"],
//     image: json["image"],
//     locationId: json["location_id"],
//     allBranch: json["all_branch"],
//     locationName: json["location_name"],
//     status: json["status"],
//     roleName: json["role_name"],
//     roleId: json["role_id"],
//     companyId: json["company_id"],
//     companyName: json["company_name"],
//     companyEmail: json["company_email"],
//     companyPhone: json["company_phone"],
//     companyAddress: json["company_address"],
//     companyLogo: json["company_logo"],
//     companyCompressedLogo: json["company_compressed_logo"],
//     companyCreatedAt: json["company_created_at"] == null ? null : DateTime.parse(json["company_created_at"]),
//     companyStatus: json["company_status"],
//     role: json["role"] == null ? null : Role.fromJson(json["role"]),
//     canAccessModules: json["can_access_modules"] == null ? [] : List<CanAccessModule>.from(json["can_access_modules"]!.map((x) => CanAccessModule.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "user_name": userName,
//     "user_phone": userPhone,
//     "user_email": userEmail,
//     "image": image,
//     "location_id": locationId,
//     "all_branch": allBranch,
//     "location_name": locationName,
//     "status": status,
//     "role_name": roleName,
//     "role_id": roleId,
//     "company_id": companyId,
//     "company_name": companyName,
//     "company_email": companyEmail,
//     "company_phone": companyPhone,
//     "company_address": companyAddress,
//     "company_logo": companyLogo,
//     "company_compressed_logo": companyCompressedLogo,
//     "company_created_at": companyCreatedAt?.toIso8601String(),
//     "company_status": companyStatus,
//     "role": role?.toJson(),
//     "can_access_modules": canAccessModules == null ? [] : List<dynamic>.from(canAccessModules!.map((x) => x.toJson())),
//   };
// }
//
// class CanAccessModule {
//   String? moduleName;
//   int? moduleId;
//   List<SubModule>? subModule;
//
//   CanAccessModule({
//     this.moduleName,
//     this.moduleId,
//     this.subModule,
//   });
//
//   factory CanAccessModule.fromJson(Map<String, dynamic> json) => CanAccessModule(
//     moduleName: json["module_name"],
//     moduleId: json["module_id"],
//     subModule: json["sub_module"] == null ? [] : List<SubModule>.from(json["sub_module"]!.map((x) => SubModule.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "module_name": moduleName,
//     "module_id": moduleId,
//     "sub_module": subModule == null ? [] : List<dynamic>.from(subModule!.map((x) => x.toJson())),
//   };
// }
//
// class SubModule {
//   int? subModuleId;
//   String? subModuleName;
//   Type? type;
//
//   SubModule({
//     this.subModuleId,
//     this.subModuleName,
//     this.type,
//   });
//
//   factory SubModule.fromJson(Map<String, dynamic> json) => SubModule(
//     subModuleId: json["sub_module_id"],
//     subModuleName: json["sub_module_name"],
//     type: json["type"] == null ? null : Type.fromJson(json["type"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "sub_module_id": subModuleId,
//     "sub_module_name": subModuleName,
//     "type": type?.toJson(),
//   };
// }
//
// class Type {
//   int? read;
//   int? write;
//   int? update;
//   int? delete;
//
//   Type({
//     this.read,
//     this.write,
//     this.update,
//     this.delete,
//   });
//
//   factory Type.fromJson(Map<String, dynamic> json) => Type(
//     read: json["read"],
//     write: json["write"],
//     update: json["update"],
//     delete: json["delete"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "read": read,
//     "write": write,
//     "update": update,
//     "delete": delete,
//   };
// }
//
// class Role {
//   int? id;
//   String? roleName;
//
//   Role({
//     this.id,
//     this.roleName,
//   });
//
//   factory Role.fromJson(Map<String, dynamic> json) => Role(
//     id: json["id"],
//     roleName: json["role_name"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "role_name": roleName,
//   };
// }
