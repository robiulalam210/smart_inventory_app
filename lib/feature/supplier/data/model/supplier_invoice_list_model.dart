// To parse this JSON data, do
//
//     final supplierInvoiceListModel = supplierInvoiceListModelFromJson(jsonString);

import 'dart:convert';

List<SupplierInvoiceListModel> supplierInvoiceListModelFromJson(String str) => List<SupplierInvoiceListModel>.from(json.decode(str).map((x) => SupplierInvoiceListModel.fromJson(x)));

String supplierInvoiceListModelToJson(List<SupplierInvoiceListModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SupplierInvoiceListModel {
  final int? id;
  final String? invoiceNo;
  final DateTime? purchaseDate;
  final dynamic grandTotal;
  final dynamic paidAmount;
  final dynamic dueAmount;
  final String? paymentStatus;
  final String? supplierName;

  SupplierInvoiceListModel({
    this.id,
    this.invoiceNo,
    this.purchaseDate,
    this.grandTotal,
    this.paidAmount,
    this.dueAmount,
    this.paymentStatus,
    this.supplierName,
  });

  @override
  String toString() {
    // TODO: implement toString
    return "${invoiceNo??""}($dueAmount)";
  }
  factory SupplierInvoiceListModel.fromJson(Map<String, dynamic> json) => SupplierInvoiceListModel(
    id: json["id"],
    invoiceNo: json["invoice_no"],
    purchaseDate: json["purchase_date"] == null ? null : DateTime.parse(json["purchase_date"]),
    grandTotal: json["grand_total"],
    paidAmount: json["paid_amount"],
    dueAmount: json["due_amount"],
    paymentStatus: json["payment_status"],
    supplierName: json["supplier_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "invoice_no": invoiceNo,
    "purchase_date": "${purchaseDate!.year.toString().padLeft(4, '0')}-${purchaseDate!.month.toString().padLeft(2, '0')}-${purchaseDate!.day.toString().padLeft(2, '0')}",
    "grand_total": grandTotal,
    "paid_amount": paidAmount,
    "due_amount": dueAmount,
    "payment_status": paymentStatus,
    "supplier_name": supplierName,
  };
}
