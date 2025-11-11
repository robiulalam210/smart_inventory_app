// To parse this JSON data, do
//
//     final accountModel = accountModelFromJson(jsonString);

import 'dart:convert';

List<AccountModel> accountModelFromJson(String str) => List<AccountModel>.from(json.decode(str).map((x) => AccountModel.fromJson(x)));

String accountModelToJson(List<AccountModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AccountModel {
  final int? acId;
  final String? acName;
  final String? acType;
  final String? acNumber;
  final dynamic? balance;
  final String? bankName;
  final String? branch;
  final dynamic? openingBalance;
  final int? company;
  final dynamic? status;
  final String? acNo;
  final dynamic number;

  AccountModel({
    this.acId,
    this.acName,
    this.acType,
    this.acNumber,
    this.balance,
    this.bankName,
    this.branch,
    this.openingBalance,
    this.company,
    this.status,
    this.acNo,
    this.number,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
    acId: json["ac_id"],
    acName: json["ac_name"],
    acType: json["ac_type"],
    acNumber: json["ac_number"],
    balance: json["balance"],
    bankName: json["bank_name"],
    branch: json["branch"],
    openingBalance: json["opening_balance"],
    company: json["company"],
    status: json["status"],
    acNo: json["ac_no"],
    number: json["number"],
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
    "status": status,
    "ac_no": acNo,
    "number": number,
  };
}
