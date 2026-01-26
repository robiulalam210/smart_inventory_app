import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int? id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? role;
  final String? permissionSource;
  final String? phone;
  final bool? isActive;
  final bool? isStaff;
  final bool? isSuperuser;
  final bool? isVerified;
  final CompanyModel? company;
  final Map<String, dynamic>? permissions;
  final List<dynamic>? customPermissions;
  final DateTime? dateJoined;
  final DateTime? lastLogin;

  const UserModel({
    this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    this.role,
    this.permissionSource,
    this.phone,
    this.isActive,
    this.isStaff,
    this.isSuperuser,
    this.isVerified,
    this.company,
    this.permissions,
    this.customPermissions,
    this.dateJoined,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"] as int?,
    username: json["username"] as String?,
    email: json["email"] as String?,
    firstName: json["first_name"] as String?,
    lastName: json["last_name"] as String?,
    fullName: json["full_name"] as String?,
    role: json["role"] as String?,
    permissionSource: json["permission_source"] as String?,
    phone: json["phone"] as String?,
    isActive: json["is_active"] as bool?,
    isStaff: json["is_staff"] as bool?,
    isSuperuser: json["is_superuser"] as bool?,
    isVerified: json["is_verified"] as bool?,
    company: json["company"] == null
        ? null
        : CompanyModel.fromJson(json["company"] as Map<String, dynamic>),
    permissions: json["permissions"] as Map<String, dynamic>?,
    customPermissions: json["custom_permissions"] as List<dynamic>?,
    dateJoined: json["date_joined"] == null
        ? null
        : DateTime.parse(json["date_joined"] as String),
    lastLogin: json["last_login"] == null
        ? null
        : DateTime.parse(json["last_login"] as String),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "first_name": firstName,
    "last_name": lastName,
    "full_name": fullName,
    "role": role,
    "permission_source": permissionSource,
    "phone": phone,
    "is_active": isActive,
    "is_staff": isStaff,
    "is_superuser": isSuperuser,
    "is_verified": isVerified,
    "company": company?.toJson(),
    "permissions": permissions,
    "custom_permissions": customPermissions,
    "date_joined": dateJoined?.toIso8601String(),
    "last_login": lastLogin?.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    firstName,
    lastName,
    fullName,
    role,
    permissionSource,
    phone,
    isActive,
    isStaff,
    isSuperuser,
    isVerified,
    company,
    permissions,
    customPermissions,
    dateJoined,
    lastLogin,
  ];
}

class CompanyModel extends Equatable {
  final int? id;
  final String? name;
  final String? tradeLicense;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? logo;
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
  final int? activeUserCount;
  final int? productCount;
  final bool? isExpired;
  final int? daysUntilExpiry;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompanyModel({
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
    this.activeUserCount,
    this.productCount,
    this.isExpired,
    this.daysUntilExpiry,
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
    id: json["id"] as int?,
    name: json["name"] as String?,
    tradeLicense: json["trade_license"] as String?,
    address: json["address"] as String?,
    phone: json["phone"] as String?,
    email: json["email"] as String?,
    website: json["website"] as String?,
    logo: json["logo"] as String?,
    currency: json["currency"] as String?,
    timezone: json["timezone"] as String?,
    fiscalYearStart: json["fiscal_year_start"] == null
        ? null
        : DateTime.parse(json["fiscal_year_start"] as String),
    planType: json["plan_type"] as String?,
    startDate: json["start_date"] == null
        ? null
        : DateTime.parse(json["start_date"] as String),
    expiryDate: json["expiry_date"] == null
        ? null
        : DateTime.parse(json["expiry_date"] as String),
    isActive: json["is_active"] as bool?,
    maxUsers: json["max_users"] as int?,
    maxProducts: json["max_products"] as int?,
    maxBranches: json["max_branches"] as int?,
    companyCode: json["company_code"] as String?,
    activeUserCount: json["active_user_count"] as int?,
    productCount: json["product_count"] as int?,
    isExpired: json["is_expired"] as bool?,
    daysUntilExpiry: json["days_until_expiry"] as int?,
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"] as String),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"] as String),
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
    "fiscal_year_start": fiscalYearStart?.toIso8601String(),
    "plan_type": planType,
    "start_date": startDate?.toIso8601String(),
    "expiry_date": expiryDate?.toIso8601String(),
    "is_active": isActive,
    "max_users": maxUsers,
    "max_products": maxProducts,
    "max_branches": maxBranches,
    "company_code": companyCode,
    "active_user_count": activeUserCount,
    "product_count": productCount,
    "is_expired": isExpired,
    "days_until_expiry": daysUntilExpiry,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    name,
    tradeLicense,
    address,
    phone,
    email,
    website,
    logo,
    currency,
    timezone,
    fiscalYearStart,
    planType,
    startDate,
    expiryDate,
    isActive,
    maxUsers,
    maxProducts,
    maxBranches,
    companyCode,
    activeUserCount,
    productCount,
    isExpired,
    daysUntilExpiry,
    createdAt,
    updatedAt,
  ];
}

// Permission models
class UserPermissionModel {
  final int? id;
  final String? module;
  final String? moduleDisplay;
  final bool? canView;
  final bool? canCreate;
  final bool? canEdit;
  final bool? canDelete;
  final bool? canCreatePos;
  final bool? canCreateShort;
  final bool? canExport;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserPermissionModel({
    this.id,
    this.module,
    this.moduleDisplay,
    this.canView,
    this.canCreate,
    this.canEdit,
    this.canDelete,
    this.canCreatePos,
    this.canCreateShort,
    this.canExport,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory UserPermissionModel.fromJson(Map<String, dynamic> json) =>
      UserPermissionModel(
        id: json["id"] as int?,
        module: json["module"] as String?,
        moduleDisplay: json["module_display"] as String?,
        canView: json["can_view"] as bool?,
        canCreate: json["can_create"] as bool?,
        canEdit: json["can_edit"] as bool?,
        canDelete: json["can_delete"] as bool?,
        canCreatePos: json["can_create_pos"] as bool?,
        canCreateShort: json["can_create_short"] as bool?,
        canExport: json["can_export"] as bool?,
        isActive: json["is_active"] as bool?,
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"] as String),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"] as String),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "module": module,
    "module_display": moduleDisplay,
    "can_view": canView,
    "can_create": canCreate,
    "can_edit": canEdit,
    "can_delete": canDelete,
    "can_create_pos": canCreatePos,
    "can_create_short": canCreateShort,
    "can_export": canExport,
    "is_active": isActive,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

// user_model.dart
class PermissionActionUser {
  final bool view;
  final bool create;
  final bool edit;
  final bool delete;
  final bool createPos;
  final bool createShort;
  final bool export;

  const PermissionActionUser({
    this.view = false,
    this.create = false,
    this.edit = false,
    this.delete = false,
    this.createPos = false,
    this.createShort = false,
    this.export = false,
  });

  factory PermissionActionUser.fromJson(Map<String, dynamic> json) {
    return PermissionActionUser(
      view: json["view"] as bool? ?? false,
      create: json["create"] as bool? ?? false,
      edit: json["edit"] as bool? ?? false,
      delete: json["delete"] as bool? ?? false,
      createPos: json["create_pos"] as bool? ?? false,
      createShort: json["create_short"] as bool? ?? false,
      export: json["export"] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "view": view,
      "create": create,
      "edit": edit,
      "delete": delete,
      "create_pos": createPos,
      "create_short": createShort,
      "export": export,
    };
  }

  PermissionActionUser copyWith({
    bool? view,
    bool? create,
    bool? edit,
    bool? delete,
    bool? createPos,
    bool? createShort,
    bool? export,
  }) {
    return PermissionActionUser(
      view: view ?? this.view,
      create: create ?? this.create,
      edit: edit ?? this.edit,
      delete: delete ?? this.delete,
      createPos: createPos ?? this.createPos,
      createShort: createShort ?? this.createShort,
      export: export ?? this.export,
    );
  }
}
// UsersListModel - আপনার existing model
class UsersListModel {
  final int? id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? role;
  final String? permissionSource;
  final String? phone;
  final bool? isActive;
  final bool? isStaff;
  final bool? isSuperuser;
  final bool? isVerified;
  final CompanyModel? company;
  final Map<String, dynamic>? permissions;

  const UsersListModel({
    this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    this.role,
    this.permissionSource,
    this.phone,
    this.isActive,
    this.isStaff,
    this.isSuperuser,
    this.isVerified,
    this.company,
    this.permissions,
  });

  factory UsersListModel.fromJson(Map<String, dynamic> json) => UsersListModel(
    id: json["id"] as int?,
    username: json["username"] as String?,
    email: json["email"] as String?,
    firstName: json["first_name"] as String?,
    lastName: json["last_name"] as String?,
    fullName: json["full_name"] as String?,
    role: json["role"] as String?,
    permissionSource: json["permission_source"] as String?,
    phone: json["phone"] as String?,
    isActive: json["is_active"] as bool?,
    isStaff: json["is_staff"] as bool?,
    isSuperuser: json["is_superuser"] as bool?,
    isVerified: json["is_verified"] as bool?,
    company: json["company"] == null
        ? null
        : CompanyModel.fromJson(json["company"] as Map<String, dynamic>),
    permissions: json["permissions"] as Map<String, dynamic>?,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "email": email,
    "first_name": firstName,
    "last_name": lastName,
    "full_name": fullName,
    "role": role,
    "permission_source": permissionSource,
    "phone": phone,
    "is_active": isActive,
    "is_staff": isStaff,
    "is_superuser": isSuperuser,
    "is_verified": isVerified,
    "company": company?.toJson(),
    "permissions": permissions,
  };
}