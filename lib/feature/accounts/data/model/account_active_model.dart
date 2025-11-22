// To parse this JSON data, do
//
//     final accountActiveModel = accountActiveModelFromJson(jsonString);

import 'dart:convert';

List<AccountActiveModel> accountActiveModelFromJson(String str) => List<AccountActiveModel>.from(json.decode(str).map((x) => AccountActiveModel.fromJson(x)));

String accountActiveModelToJson(List<AccountActiveModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AccountActiveModel {
  final int? id;
  final String? name;
  final String? acType;
  final String? acNumber;
  final dynamic balance;
  final String? bankName;
  final String? branch;
  final dynamic openingBalance;
  final int? company;
  final String? status;
  final String? acNo;
  final dynamic number;

  AccountActiveModel({
    this.id,
    this.name,
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


  @override
  String toString() {
    return "${name ?? ""} (${(acNumber ?? "")})";
  }
  factory AccountActiveModel.fromJson(Map<String, dynamic> json) => AccountActiveModel(
    id: json["id"],
    name: json["name"],
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
    "id": id,
    "name": name,
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
