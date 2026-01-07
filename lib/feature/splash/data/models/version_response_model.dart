// To parse this JSON data, do
//
//     final versionResponseModel = versionResponseModelFromJson(jsonString);

import 'dart:convert';

VersionResponseModel versionResponseModelFromJson(String str) => VersionResponseModel.fromJson(json.decode(str));

String versionResponseModelToJson(VersionResponseModel data) => json.encode(data.toJson());

class VersionResponseModel {
    final bool? success;
    final String? message;
    final VersionData? data;

    VersionResponseModel({
        this.success,
        this.message,
        this.data,
    });

    factory VersionResponseModel.fromJson(Map<String, dynamic> json) => VersionResponseModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : VersionData.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
    };
}

class VersionData {
    final String? appName;
    final String? packageName;
    final String? playStoreVersion;
    final String? appStoreVersion;
    final dynamic microsoftStoreVersion;
    final bool? forceUpdatePlayStore;
    final bool? forceUpdateAppStore;
    final bool? isPausePlayStore;
    final bool? isPauseAppStore;
    final String? appIcon;
    final String? playStoreLink;
    final dynamic appStoreLink;
    final dynamic microsoftStoreLink;
    final int? id;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final String? createdBy;
    final String? updatedBy;
    final String? updateMessage;

    VersionData({
        this.appName,
        this.packageName,
        this.playStoreVersion,
        this.appStoreVersion,
        this.microsoftStoreVersion,
        this.forceUpdatePlayStore,
        this.forceUpdateAppStore,
        this.isPausePlayStore,
        this.isPauseAppStore,
        this.appIcon,
        this.playStoreLink,
        this.appStoreLink,
        this.microsoftStoreLink,
        this.id,
        this.createdAt,
        this.updatedAt,
        this.createdBy,
        this.updatedBy,
        this.updateMessage,
    });

    factory VersionData.fromJson(Map<String, dynamic> json) => VersionData(
        appName: json["app_name"],
        packageName: json["package_name"],
        playStoreVersion: json["play_store_version"],
        appStoreVersion: json["app_store_version"],
        microsoftStoreVersion: json["microsoft_store_version"],
        forceUpdatePlayStore: json["force_update_play_store"],
        forceUpdateAppStore: json["force_update_app_store"],
        isPausePlayStore: json["is_pause_play_store"],
        isPauseAppStore: json["is_pause_app_store"],
        appIcon: json["app_icon"],
        playStoreLink: json["play_store_link"],
        appStoreLink: json["app_store_link"],
        microsoftStoreLink: json["microsoft_store_link"],
        id: json["id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        createdBy: json["created_by"],
        updatedBy: json["updated_by"],
        updateMessage: json["update_message"],
    );

    Map<String, dynamic> toJson() => {
        "app_name": appName,
        "package_name": packageName,
        "play_store_version": playStoreVersion,
        "app_store_version": appStoreVersion,
        "microsoft_store_version": microsoftStoreVersion,
        "force_update_play_store": forceUpdatePlayStore,
        "force_update_app_store": forceUpdateAppStore,
        "is_pause_play_store": isPausePlayStore,
        "is_pause_app_store": isPauseAppStore,
        "app_icon": appIcon,
        "play_store_link": playStoreLink,
        "app_store_link": appStoreLink,
        "microsoft_store_link": microsoftStoreLink,
        "id": id,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "created_by": createdBy,
        "updated_by": updatedBy,
        "update_message": updateMessage,
    };
}
