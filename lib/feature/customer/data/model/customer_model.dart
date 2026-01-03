// To parse this JSON data, do
//
//     final customerModel = customerModelFromJson(jsonString);

import 'dart:convert';

List<CustomerModel> customerModelFromJson(String str) => List<CustomerModel>.from(json.decode(str).map((x) => CustomerModel.fromJson(x)));

String customerModelToJson(List<CustomerModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CustomerModel {
  final int? id;
  final String? name;
  final String? phone;
  final dynamic email;
  final String? address;
  final bool? isActive;
  final String? clientNo;
  final dynamic totalDue;
  final dynamic totalPaid;
  final String? amountType;
  final int? company;
  final int? totalSales;
  final DateTime? dateCreated;
  final int? createdBy;
  final dynamic advanceBalance;
  final PaymentBreakdown? paymentBreakdown;

  CustomerModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.isActive,
    this.clientNo,
    this.totalDue,
    this.totalPaid,
    this.amountType,
    this.company,
    this.totalSales,
    this.dateCreated,
    this.createdBy,
    this.advanceBalance,
    this.paymentBreakdown,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    email: json["email"],
    address: json["address"],
    isActive: json["is_active"],
    clientNo: json["client_no"],
    totalDue: json["total_due"],
    totalPaid: json["total_paid"],
    amountType: json["amount_type"],
    company: json["company"],
    totalSales: json["total_sales"],
    dateCreated: json["date_created"] == null ? null : DateTime.parse(json["date_created"]),
    createdBy: json["created_by"],
    advanceBalance: json["advance_balance"],
    paymentBreakdown: json["payment_breakdown"] == null ? null : PaymentBreakdown.fromJson(json["payment_breakdown"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "email": email,
    "address": address,
    "is_active": isActive,
    "client_no": clientNo,
    "total_due": totalDue,
    "total_paid": totalPaid,
    "amount_type": amountType,
    "company": company,
    "total_sales": totalSales,
    "date_created": dateCreated?.toIso8601String(),
    "created_by": createdBy,
    "advance_balance": advanceBalance,
    "payment_breakdown": paymentBreakdown?.toJson(),
  };
}

class PaymentBreakdown {
  final int? customerId;
  final String? customerName;
  final Summary? summary;
  final Details? details;
  final Calculation? calculation;
  final SyncInfo? syncInfo;

  PaymentBreakdown({
    this.customerId,
    this.customerName,
    this.summary,
    this.details,
    this.calculation,
    this.syncInfo,
  });

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) => PaymentBreakdown(
    customerId: json["customer_id"],
    customerName: json["customer_name"],
    summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
    details: json["details"] == null ? null : Details.fromJson(json["details"]),
    calculation: json["calculation"] == null ? null : Calculation.fromJson(json["calculation"]),
    syncInfo: json["sync_info"] == null ? null : SyncInfo.fromJson(json["sync_info"]),
  );

  Map<String, dynamic> toJson() => {
    "customer_id": customerId,
    "customer_name": customerName,
    "summary": summary?.toJson(),
    "details": details?.toJson(),
    "calculation": calculation?.toJson(),
    "sync_info": syncInfo?.toJson(),
  };
}

class Calculation {
  final SaleAnalysis? saleAnalysis;
  final AdvanceAnalysis? advanceAnalysis;
  final DueAnalysis? dueAnalysis;

  Calculation({
    this.saleAnalysis,
    this.advanceAnalysis,
    this.dueAnalysis,
  });

  factory Calculation.fromJson(Map<String, dynamic> json) => Calculation(
    saleAnalysis: json["sale_analysis"] == null ? null : SaleAnalysis.fromJson(json["sale_analysis"]),
    advanceAnalysis: json["advance_analysis"] == null ? null : AdvanceAnalysis.fromJson(json["advance_analysis"]),
    dueAnalysis: json["due_analysis"] == null ? null : DueAnalysis.fromJson(json["due_analysis"]),
  );

  Map<String, dynamic> toJson() => {
    "sale_analysis": saleAnalysis?.toJson(),
    "advance_analysis": advanceAnalysis?.toJson(),
    "due_analysis": dueAnalysis?.toJson(),
  };
}

class AdvanceAnalysis {
  final dynamic advanceFromReceipts;
  final dynamic advanceFromSalesOverpayment;
  final dynamic totalAdvanceAvailable;
  final dynamic storedAdvanceInDb;

  AdvanceAnalysis({
    this.advanceFromReceipts,
    this.advanceFromSalesOverpayment,
    this.totalAdvanceAvailable,
    this.storedAdvanceInDb,
  });

  factory AdvanceAnalysis.fromJson(Map<String, dynamic> json) => AdvanceAnalysis(
    advanceFromReceipts: json["advance_from_receipts"],
    advanceFromSalesOverpayment: json["advance_from_sales_overpayment"],
    totalAdvanceAvailable: json["total_advance_available"],
    storedAdvanceInDb: json["stored_advance_in_db"],
  );

  Map<String, dynamic> toJson() => {
    "advance_from_receipts": advanceFromReceipts,
    "advance_from_sales_overpayment": advanceFromSalesOverpayment,
    "total_advance_available": totalAdvanceAvailable,
    "stored_advance_in_db": storedAdvanceInDb,
  };
}

class DueAnalysis {
  final dynamic basicDueBeforeAdvance;
  final dynamic netDueAfterAdvance;
  final dynamic remainingAdvanceBalance;

  DueAnalysis({
    this.basicDueBeforeAdvance,
    this.netDueAfterAdvance,
    this.remainingAdvanceBalance,
  });

  factory DueAnalysis.fromJson(Map<String, dynamic> json) => DueAnalysis(
    basicDueBeforeAdvance: json["basic_due_before_advance"],
    netDueAfterAdvance: json["net_due_after_advance"],
    remainingAdvanceBalance: json["remaining_advance_balance"],
  );

  Map<String, dynamic> toJson() => {
    "basic_due_before_advance": basicDueBeforeAdvance,
    "net_due_after_advance": netDueAfterAdvance,
    "remaining_advance_balance": remainingAdvanceBalance,
  };
}

class SaleAnalysis {
  final dynamic totalSaleAmount;
  final dynamic totalPaidToSales;
  final dynamic salesOverpayment;
  final dynamic salesUnderpayment;

  SaleAnalysis({
    this.totalSaleAmount,
    this.totalPaidToSales,
    this.salesOverpayment,
    this.salesUnderpayment,
  });

  factory SaleAnalysis.fromJson(Map<String, dynamic> json) => SaleAnalysis(
    totalSaleAmount: json["total_sale_amount"],
    totalPaidToSales: json["total_paid_to_sales"],
    salesOverpayment: json["sales_overpayment"],
    salesUnderpayment: json["sales_underpayment"],
  );

  Map<String, dynamic> toJson() => {
    "total_sale_amount": totalSaleAmount,
    "total_paid_to_sales": totalPaidToSales,
    "sales_overpayment": salesOverpayment,
    "sales_underpayment": salesUnderpayment,
  };
}

class Details {
  final List<AdvanceReceipt>? advanceReceipts;
  final List<DueSale>? dueSales;
  final List<PaidSale>? paidSales;

  Details({
    this.advanceReceipts,
    this.dueSales,
    this.paidSales,
  });

  factory Details.fromJson(Map<String, dynamic> json) => Details(
    advanceReceipts: json["advance_receipts"] == null ? [] : List<AdvanceReceipt>.from(json["advance_receipts"]!.map((x) => AdvanceReceipt.fromJson(x))),
    dueSales: json["due_sales"] == null ? [] : List<DueSale>.from(json["due_sales"]!.map((x) => DueSale.fromJson(x))),
    paidSales: json["paid_sales"] == null ? [] : List<PaidSale>.from(json["paid_sales"]!.map((x) => PaidSale.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "advance_receipts": advanceReceipts == null ? [] : List<dynamic>.from(advanceReceipts!.map((x) => x.toJson())),
    "due_sales": dueSales == null ? [] : List<dynamic>.from(dueSales!.map((x) => x.toJson())),
    "paid_sales": paidSales == null ? [] : List<dynamic>.from(paidSales!.map((x) => x.toJson())),
  };
}

class AdvanceReceipt {
  final int? id;
  final String? receiptNo;
  final dynamic amount;
  final DateTime? date;
  final String? type;
  final String? paymentType;
  final bool? isAdvancePayment;
  final bool? saleLinked;
  final dynamic saleInvoiceNo;

  AdvanceReceipt({
    this.id,
    this.receiptNo,
    this.amount,
    this.date,
    this.type,
    this.paymentType,
    this.isAdvancePayment,
    this.saleLinked,
    this.saleInvoiceNo,
  });

  factory AdvanceReceipt.fromJson(Map<String, dynamic> json) => AdvanceReceipt(
    id: json["id"],
    receiptNo: json["receipt_no"],
    amount: json["amount"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    type: json["type"],
    paymentType: json["payment_type"],
    isAdvancePayment: json["is_advance_payment"],
    saleLinked: json["sale_linked"],
    saleInvoiceNo: json["sale_invoice_no"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "receipt_no": receiptNo,
    "amount": amount,
    "date": date?.toIso8601String(),
    "type": type,
    "payment_type": paymentType,
    "is_advance_payment": isAdvancePayment,
    "sale_linked": saleLinked,
    "sale_invoice_no": saleInvoiceNo,
  };
}

class DueSale {
  final int? id;
  final String? invoiceNo;
  final dynamic dueAmount;
  final DateTime? date;

  DueSale({
    this.id,
    this.invoiceNo,
    this.dueAmount,
    this.date,
  });

  factory DueSale.fromJson(Map<String, dynamic> json) => DueSale(
    id: json["id"],
    invoiceNo: json["invoice_no"],
    dueAmount: json["due_amount"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "invoice_no": invoiceNo,
    "due_amount": dueAmount,
    "date": date?.toIso8601String(),
  };
}

class PaidSale {
  final int? id;
  final String? invoiceNo;
  final dynamic grandTotal;
  final dynamic paidAmount;
  final dynamic overpayment;
  final DateTime? date;

  PaidSale({
    this.id,
    this.invoiceNo,
    this.grandTotal,
    this.paidAmount,
    this.overpayment,
    this.date,
  });

  factory PaidSale.fromJson(Map<String, dynamic> json) => PaidSale(
    id: json["id"],
    invoiceNo: json["invoice_no"],
    grandTotal: json["grand_total"],
    paidAmount: json["paid_amount"],
    overpayment: json["overpayment"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "invoice_no": invoiceNo,
    "grand_total": grandTotal,
    "paid_amount": paidAmount,
    "overpayment": overpayment,
    "date": date?.toIso8601String(),
  };
}

class Summary {
  final Advance? advance;
  final Due? due;
  final Due? paid;

  Summary({
    this.advance,
    this.due,
    this.paid,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    advance: json["advance"] == null ? null : Advance.fromJson(json["advance"]),
    due: json["due"] == null ? null : Due.fromJson(json["due"]),
    paid: json["paid"] == null ? null : Due.fromJson(json["paid"]),
  );

  Map<String, dynamic> toJson() => {
    "advance": advance?.toJson(),
    "due": due?.toJson(),
    "paid": paid?.toJson(),
  };
}

class Advance {
  final dynamic total;
  final Breakdown? breakdown;
  final int? count;

  Advance({
    this.total,
    this.breakdown,
    this.count,
  });

  factory Advance.fromJson(Map<String, dynamic> json) => Advance(
    total: json["total"],
    breakdown: json["breakdown"] == null ? null : Breakdown.fromJson(json["breakdown"]),
    count: json["count"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "breakdown": breakdown?.toJson(),
    "count": count,
  };
}

class Breakdown {
  final dynamic fromSalesOverpayment;
  final dynamic fromAdvanceReceipts;
  final dynamic storedInDb;
  final dynamic totalCalculated;

  Breakdown({
    this.fromSalesOverpayment,
    this.fromAdvanceReceipts,
    this.storedInDb,
    this.totalCalculated,
  });

  factory Breakdown.fromJson(Map<String, dynamic> json) => Breakdown(
    fromSalesOverpayment: json["from_sales_overpayment"],
    fromAdvanceReceipts: json["from_advance_receipts"],
    storedInDb: json["stored_in_db"],
    totalCalculated: json["total_calculated"],
  );

  Map<String, dynamic> toJson() => {
    "from_sales_overpayment": fromSalesOverpayment,
    "from_advance_receipts": fromAdvanceReceipts,
    "stored_in_db": storedInDb,
    "total_calculated": totalCalculated,
  };
}

class Due {
  final dynamic total;
  final int? count;

  Due({
    this.total,
    this.count,
  });

  factory Due.fromJson(Map<String, dynamic> json) => Due(
    total: json["total"],
    count: json["count"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "count": count,
  };
}

class SyncInfo {
  final bool? wasSynced;
  final dynamic previousValue;

  SyncInfo({
    this.wasSynced,
    this.previousValue,
  });

  factory SyncInfo.fromJson(Map<String, dynamic> json) => SyncInfo(
    wasSynced: json["was_synced"],
    previousValue: json["previous_value"],
  );

  Map<String, dynamic> toJson() => {
    "was_synced": wasSynced,
    "previous_value": previousValue,
  };
}
