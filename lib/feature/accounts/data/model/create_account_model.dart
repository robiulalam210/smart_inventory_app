// To parse this JSON data, do
//
//     final createAccountModel = createAccountModelFromJson(jsonString);

import 'dart:convert';

CreateAccountModel createAccountModelFromJson(String str) => CreateAccountModel.fromJson(json.decode(str));

String createAccountModelToJson(CreateAccountModel data) => json.encode(data.toJson());

class CreateAccountModel {
  final bool? status;
  final String? message;
  final Data? data;

  CreateAccountModel({
    this.status,
    this.message,
    this.data,
  });

  factory CreateAccountModel.fromJson(Map<String, dynamic> json) => CreateAccountModel(
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
  final int? acId;
  final String? acName;
  final String? acType;
  final String? acNumber;
  final dynamic? balance;
  final String? bankName;
  final String? branch;
  final dynamic openingBalance;
  final int? company;

  Data({
    this.acId,
    this.acName,
    this.acType,
    this.acNumber,
    this.balance,
    this.bankName,
    this.branch,
    this.openingBalance,
    this.company,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    acId: json["ac_id"],
    acName: json["ac_name"],
    acType: json["ac_type"],
    acNumber: json["ac_number"],
    balance: json["balance"],
    bankName: json["bank_name"],
    branch: json["branch"],
    openingBalance: json["opening_balance"],
    company: json["company"],
  );

  Map<String, dynamic> toJson() => {
    "ac_id": acId,
    "ac_name": acName,
    "ac_type": acType,
    "ac_number": acNumber,
    "balance": balance,
    "bank_name": bankName,
    "branch": branch,
    "opening_balance": openingBalance,
    "company": company,
  };
}
