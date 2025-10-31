// To parse this JSON data, do
//
//     final customerDueAdvanceReportModel = customerDueAdvanceReportModelFromJson(jsonString);

import 'dart:convert';

CustomerDueAdvanceReportModel customerDueAdvanceReportModelFromJson(String str) => CustomerDueAdvanceReportModel.fromJson(json.decode(str));

String customerDueAdvanceReportModelToJson(CustomerDueAdvanceReportModel data) => json.encode(data.toJson());

class CustomerDueAdvanceReportModel {
  bool? success;
  List<CustomerDueAdvanceModel>? data;
  Summary? summary;

  CustomerDueAdvanceReportModel({
    this.success,
    this.data,
    this.summary,
  });

  factory CustomerDueAdvanceReportModel.fromJson(Map<String, dynamic> json) => CustomerDueAdvanceReportModel(
    success: json["success"],
    data: json["data"] == null ? [] : List<CustomerDueAdvanceModel>.from(json["data"]!.map((x) => CustomerDueAdvanceModel.fromJson(x))),
    summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "summary": summary?.toJson(),
  };
}

class CustomerDueAdvanceModel {
  int? id;
  String? name;
  String? clientNo;
  String? phone;
  String? email;
  int? status;
  String? balance;

  CustomerDueAdvanceModel({
    this.id,
    this.name,
    this.clientNo,
    this.phone,
    this.email,
    this.status,
    this.balance,
  });

  factory CustomerDueAdvanceModel.fromJson(Map<String, dynamic> json) => CustomerDueAdvanceModel(
    id: json["id"],
    name: json["name"],
    clientNo: json["client_no"],
    phone: json["phone"],
    email: json["email"],
    status: json["status"],
    balance: json["balance"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "client_no": clientNo,
    "phone": phone,
    "email": email,
    "status": status,
    "balance": balance,
  };
}

class Summary {
  String? totalDue;
  String? totalAdvance;

  Summary({
    this.totalDue,
    this.totalAdvance,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    totalDue: json["totalDue"],
    totalAdvance: json["totalAdvance"],
  );

  Map<String, dynamic> toJson() => {
    "totalDue": totalDue,
    "totalAdvance": totalAdvance,
  };
}
