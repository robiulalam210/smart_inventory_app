import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../../../core/configs/app_urls.dart';
import '../../../../core/repositories/get_response.dart';
import '../../../../core/repositories/post_response.dart';

/// একজন user এর permission এর বর্তমান অবস্থা (server থেকে আসা)
class UserPermissionDetail {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String role;
  final String roleDisplay;
  final String permissionSource; // ROLE / CUSTOM / MIXED
  final bool editable; // Super Admin বা অন্য Admin হলে false
  /// module → action → true/false   (যেমন {'sales': {'view': true, 'create': false}})
  final Map<String, Map<String, bool>> permissions;

  const UserPermissionDetail({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.role,
    required this.roleDisplay,
    required this.permissionSource,
    required this.editable,
    required this.permissions,
  });

  String get displayName => fullName.trim().isNotEmpty ? fullName : username;

  factory UserPermissionDetail.fromJson(Map<String, dynamic> data) {
    final user = (data['user'] as Map?)?.cast<String, dynamic>() ?? const {};
    final raw = (data['permissions'] as Map?)?.cast<String, dynamic>() ?? const {};
    final perms = <String, Map<String, bool>>{};
    raw.forEach((module, value) {
      if (value is Map) {
        perms[module] = value.map((k, v) => MapEntry(k.toString(), v == true));
      }
    });
    return UserPermissionDetail(
      id: int.tryParse('${user['id']}') ?? 0,
      username: '${user['username'] ?? ''}',
      fullName: '${user['full_name'] ?? ''}',
      email: '${user['email'] ?? ''}',
      role: '${user['role'] ?? ''}',
      roleDisplay: '${user['role_display'] ?? user['role'] ?? ''}',
      permissionSource: '${user['permission_source'] ?? raw['permission_source'] ?? 'ROLE'}',
      editable: user['editable'] != false,
      permissions: perms,
    );
  }
}

class PermissionResult<T> {
  final T? data;
  final String? error;
  const PermissionResult.ok(this.data) : error = null;
  const PermissionResult.fail(this.error) : data = null;
  bool get isOk => error == null;
}

/// Permission editor এর API কাজ এখানে আলাদা রাখা হয়েছে।
/// কেন bloc নয়: UserBloc পুরো app এ একটাই (global) — user list screen ও সেটা শোনে।
/// Permission screen থেকে সেখানে event পাঠালে পেছনের user list ও loading/বদলে যেত।
class UserPermissionRepo {
  const UserPermissionRepo();

  Future<PermissionResult<UserPermissionDetail>> fetch(BuildContext context, String userId) async {
    try {
      final res = await getResponse(context: context, url: AppUrls.userPermissionDetail(userId));
      final json = jsonDecode(res);
      if (json is Map && json['status'] == true && json['data'] is Map) {
        return PermissionResult.ok(
          UserPermissionDetail.fromJson((json['data'] as Map).cast<String, dynamic>()),
        );
      }
      return PermissionResult.fail(json is Map ? '${json['message'] ?? 'Failed to load permissions'}' : 'Failed to load permissions');
    } catch (e) {
      return PermissionResult.fail('Failed to load permissions: $e');
    }
  }

  /// সব module একসাথে পাঠানো হয় — backend এ যেটা পাঠানো হয় না সেটা false ধরে নেয়
  Future<PermissionResult<void>> save(String userId, Map<String, Map<String, bool>> permissions) async {
    final res = await postResponse(
      url: AppUrls.updatePermissions,
      payload: {
        'user_id': int.tryParse(userId) ?? userId,
        'permissions': permissions,
      },
    );
    return _result(res, 'Failed to save permissions');
  }

  Future<PermissionResult<void>> resetToRole(String userId) async {
    final res = await postResponse(
      url: AppUrls.resetPermissions,
      payload: {'user_id': int.tryParse(userId) ?? userId},
    );
    return _result(res, 'Failed to reset permissions');
  }

  PermissionResult<void> _result(Map<String, dynamic> res, String fallback) {
    final body = res['data'];
    final serverOk = body is Map ? body['status'] != false : true;
    if (res['status'] == true && serverOk) return const PermissionResult.ok(null);
    return PermissionResult.fail(_message(body) ?? '${res['message'] ?? fallback}');
  }

  /// DRF validation error গুলো ({"data": {"non_field_errors": [...]}}) থেকে পড়ার মতো message বের করা
  String? _message(dynamic body) {
    if (body is! Map) return null;
    final data = body['data'];
    if (data is Map) {
      for (final v in data.values) {
        if (v is List && v.isNotEmpty) return '${v.first}';
        if (v is String && v.isNotEmpty) return v;
      }
    }
    final m = body['message'];
    return m == null ? null : '$m';
  }
}
