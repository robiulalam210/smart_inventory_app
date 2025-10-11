class InvoiceSyncResponseModel {
  final List<InvoiceModelSync>? invoices;
  final SummaryModel? summary;

  // Pagination fields
  final int? totalCount;
  final int? pageSize;
  final int? pageNumber;
  final int? totalPages;

  InvoiceSyncResponseModel({
     this.invoices,
     this.summary,
     this.totalCount,
     this.pageSize,
     this.pageNumber,
     this.totalPages,
  });

  factory InvoiceSyncResponseModel.fromMap(Map<String, dynamic> map) {
    return InvoiceSyncResponseModel(
      invoices: (map['invoices'] as List)
          .map((e) => InvoiceModelSync.fromMap(e))
          .toList(),
      summary: map['summary'] != null
          ? SummaryModel.fromMap(map['summary'])
          : null,
      totalCount: map['totalCount'] ?? 0,
      pageSize: map['pageSize'] ?? 20,
      pageNumber: map['pageNumber'] ?? 1,
      totalPages: map['totalPages'] ?? 1,
    );
  }
}


class InvoiceModelSync {
  final dynamic invoiceId;
  final String invoiceNumber;
  final dynamic createDateAtWeb;
  final String? deliveryDate;
  final String? deliveryTime;
  final DateTime createDate;
  final double? totalBillAmount;
  final double? due;
  final double? paidAmount;
  final String? discountType;
  final double? discount;
  final double? discountPercentage;
  final double? paymentAmount;
  final double? testDiscountApplyAmount;
  final double? netAmountAfterRefund;
  final String? referType;
  final String? referreIdOrDesc;
  final SyncCreatedByUser createdByUser;
  final SyncReferInfo referInfo;
  final PatientModel patient;
  final List<SyncPaymentModel> payments;
  final List<SyncInvoiceDetailModel> invoiceDetails;

  InvoiceModelSync({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.createDateAtWeb,
    required this.deliveryDate,
    this.deliveryTime,
    required this.createDate,
    required this.totalBillAmount,
    required this.due,
     this.paidAmount,
     this.discountType,
     this.discount,
     this.discountPercentage,
     this.paymentAmount,
     this.testDiscountApplyAmount,
     this.netAmountAfterRefund,
     this.referType,
     this.referreIdOrDesc,
    required this.createdByUser,
    required this.referInfo,
    required this.patient,
    required this.payments,
    required this.invoiceDetails,
  });
  Map<String, dynamic> toMap() {
    return {
      'invoice_id': invoiceId,
      'invoice_number': invoiceNumber,
      'create_date_at_web': createDateAtWeb,
      'delivery_date': deliveryDate,
      'delivery_time': deliveryTime,
      'create_date': createDate.toIso8601String(),
      'total_bill_amount': totalBillAmount,
      'due': due,
      'paid_amount': paidAmount,
      'discount_type': discountType,
      'discount': discount,
      'discount_percentage': discountPercentage,
      'payment_amount': paymentAmount,
      'testDiscountApplyAmount': testDiscountApplyAmount,
      'netAmountAfterRefund': netAmountAfterRefund,
      'refer_type': referType,
      'referre_id_or_desc': referreIdOrDesc,
      'created_by_user': createdByUser.toMap(),
      'refer_info': referInfo.toMap(),
      'patient': patient.toMap(),
      'payments': payments.map((p) => p.toMap()).toList(),
      'invoice_details': invoiceDetails.map((d) => d.toMap()).toList(),
    };
  }

  factory InvoiceModelSync.fromMap(Map<String, dynamic> map) {
    return InvoiceModelSync(
      invoiceId: map['invoice_id'],
      invoiceNumber: map['invoice_number'],
      createDateAtWeb: map['create_date_at_web'],
      deliveryDate: map['delivery_date'],
      deliveryTime: map['delivery_time'],
      createDate: DateTime.parse(map['create_date']),
      totalBillAmount: (map['total_bill_amount'] ?? 0).toDouble(),
      due: (map['due'] ?? 0).toDouble(),
      paidAmount: (map['paid_amount'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      discountPercentage: (map['discount_percentage'] ?? 0).toDouble(),
      paymentAmount: (map['payment_amount'] ?? 0).toDouble(),
      testDiscountApplyAmount: (map['testDiscountApplyAmount'] ?? 0).toDouble(),
      netAmountAfterRefund: (map['netAmountAfterRefund'] ?? 0).toDouble(),
      discountType: map['discount_type'],
      referType: map['refer_type'],
      referreIdOrDesc: map['referre_id_or_desc'] ?? '',
      createdByUser: map['created_by_user'] != null
          ? SyncCreatedByUser.fromMap(
              Map<String, dynamic>.from(map['created_by_user']))
          : SyncCreatedByUser.empty(),
      referInfo: map['refer_info'] != null
          ? SyncReferInfo.fromMap(Map<String, dynamic>.from(map['refer_info']))
          : SyncReferInfo.empty(),
      patient: map['patient'] != null
          ? PatientModel.fromMap(Map<String, dynamic>.from(map['patient']))
          : PatientModel.empty(),
      payments: (map['payments'] as List<dynamic>?)
              ?.map(
                  (x) => SyncPaymentModel.fromMap(Map<String, dynamic>.from(x)))
              .toList() ??
          [],
      invoiceDetails: (map['invoice_details'] as List<dynamic>?)
              ?.map((x) =>
                  SyncInvoiceDetailModel.fromMap(Map<String, dynamic>.from(x)))
              .toList() ??
          [],
    );
  }
}

class SyncCreatedByUser {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? type;

  SyncCreatedByUser({this.id, this.name, this.email, this.phone, this.type});

  factory SyncCreatedByUser.fromMap(Map<String, dynamic> map) {
    return SyncCreatedByUser(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      type: map['type'],
    );
  }
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'type': type,
      };

  factory SyncCreatedByUser.empty() {
    return SyncCreatedByUser(
        id: null, name: null, email: null, phone: null, type: null);
  }
}

class SyncReferInfo {
  final String? type;
  final String? value;
  final int? id;
  final String? name;
  final String? phone;

  SyncReferInfo({
    this.type,
    this.value,
    this.id,
    this.name,
    this.phone,
  });
  factory SyncReferInfo.empty() => SyncReferInfo(type: '', value: '');

  factory SyncReferInfo.fromMap(Map<String, dynamic> map) {
    return SyncReferInfo(
      type: map['type'],
      value: map['value'],
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
    );
  }
  Map<String, dynamic> toMap() => {
        'type': type,
        'value': value,
        'id': id,
        'name': name,
        'phone': phone,
      };
}

class PatientModel {
  final int? id;
  final String? name;
  final String? phone;
  final dynamic age;
  final dynamic month;
  final dynamic day;
  final String? gender;
  final String? bloodGroup;
  final String? address;
  final String? dateOfBirth;
  final String? visitType;
  final String? hnNumber;
  final String? createDate;

  PatientModel({
    this.id,
    this.name,
    this.phone,
    this.age,
    this.month,
    this.day,
    this.gender,
    this.bloodGroup,
    this.address,
    this.dateOfBirth,
    this.visitType,
    this.hnNumber,
    this.createDate,
  });

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      age: map['age'],
      month: map['month'],
      day: map['day'],
      gender: map['gender'],
      bloodGroup: map['bloodGroup'],
      address: map['address'],
      dateOfBirth: map['dateOfBirth'],
      visitType: map['visit_type'],
      hnNumber: map['hn_number'],
      createDate: map['create_date'],
    );
  }
  factory PatientModel.empty() {
    return PatientModel(
      id: 0,
      name: '',
      phone: '',
      age: '',
      month: '',
      day: '',
      gender: '',
      bloodGroup: '',
      address: '',
      dateOfBirth: '',
      visitType: '',
      hnNumber: '',
      createDate: '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'age': age,
        'month': month,
        'day': day,
        'gender': gender,
        'bloodGroup': bloodGroup,
        'address': address,
        'dateOfBirth': dateOfBirth,
        'visit_type': visitType,
        'hn_number': hnNumber,
        'create_date': createDate,
      };
}

class SyncPaymentModel {
  final int? id;
  final dynamic webId;
  final String? moneyReceiptNumber;
  final String? moneyReceiptType;
  final dynamic patientId;
  final dynamic patientWeb;
  final String? invoiceNumber;
  final int? invoiceId;
  final String? paymentType;
  final double? amount;
  final double? requestedAmount;
  final double? dueAmount;
  final String? paymentDate;
  final bool? isSynced;

  SyncPaymentModel({
    this.id,
    this.webId,
    this.moneyReceiptNumber,
    this.moneyReceiptType,
    this.patientId,
    this.patientWeb,
    this.invoiceNumber,
    this.invoiceId,
    this.paymentType,
    this.amount,
    this.requestedAmount,
    this.dueAmount,
    this.paymentDate,
    this.isSynced,
  });

  factory SyncPaymentModel.fromMap(Map<String, dynamic> map) {
    return SyncPaymentModel(
      id: map['payment_id'],
      webId: map['web_id'],
      moneyReceiptNumber: map['money_receipt_number'],
      moneyReceiptType: map['money_receipt_type'],
      patientId: map['patient_id'],
      patientWeb: map['patient_web'],
      invoiceNumber: map['invoice_number'],
      invoiceId: map['invoice_id'],
      paymentType: map['payment_type'],
      amount: map['amount'] is int
          ? (map['amount'] as int).toDouble()
          : map['amount'],
      requestedAmount: map['requested_amount'] is int
          ? (map['requested_amount'] as int).toDouble()
          : map['requested_amount'],
      dueAmount: map['due_amount'] is int
          ? (map['due_amount'] as int).toDouble()
          : map['due_amount'],
      paymentDate: map['payment_date'],
      isSynced: map['is_synced'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'payment_id': id,
      'web_id': webId,
      'money_receipt_number': moneyReceiptNumber,
      'money_receipt_type': moneyReceiptType,
      'patient_id': patientId,
      'patient_web': patientWeb,
      'invoice_number': invoiceNumber,
      'invoice_id': invoiceId,
      'payment_type': paymentType,
      'amount': amount,
      'requested_amount': requestedAmount,
      'due_amount': dueAmount,
      'payment_date': paymentDate,
      'is_synced': isSynced == true ? 1 : 0,
    };
  }

  SyncPaymentModel copyWith({
    int? id,
    int? webId,
    String? moneyReceiptNumber,
    String? moneyReceiptType,
    int? patientId,
    int? patientWeb,
    String? invoiceNumber,
    int? invoiceId,
    String? paymentType,
    double? amount,
    String? paymentDate,
    bool? isSynced,
  }) {
    return SyncPaymentModel(
      id: id ?? this.id,
      webId: webId ?? this.webId,
      moneyReceiptNumber: moneyReceiptNumber ?? this.moneyReceiptNumber,
      moneyReceiptType: moneyReceiptType ?? this.moneyReceiptType,
      patientId: patientId ?? this.patientId,
      patientWeb: patientWeb ?? this.patientWeb,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceId: invoiceId ?? this.invoiceId,
      paymentType: paymentType ?? this.paymentType,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

class SyncInvoiceDetailModel {
  final int? testId;
  final int? inventoryId;
  final String? testName;
  final String? testCode;
  final double fee;
  final double discount;
  final dynamic discountApplied;
  final int qty;
  final String type;
  final bool? isRefund;

  SyncInvoiceDetailModel({
    this.testId,
    this.inventoryId,
    this.testName,
    this.testCode,
    required this.fee,
    required this.discount,
    required this.discountApplied,
    required this.qty,
    required this.type,
    this.isRefund
  });

  factory SyncInvoiceDetailModel.fromMap(Map<String, dynamic> map) {
    return SyncInvoiceDetailModel(
      testId: map['test_id'],
      inventoryId: map['inventory_id'],
      testName: map['test_name'] ?? map['inventory_name'],
      testCode: map['test_code'],
      fee: (map['fee'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      discountApplied: map['discount_applied'],
      qty: map['qty'],
      type: map['type'],
      isRefund: map['is_refund'],
    );
  }

  Map<String, dynamic> toMap() => {
        'test_id': testId,
        'inventory_id': inventoryId,
        'test_name': testName,
        'test_code': testCode,
        'fee': fee,
        'discount': discount,
        'discount_applied': discountApplied,
        'qty': qty,
        'type': type,
        'is_refund': isRefund,
      };
}

class SummaryModel {
  final double totalAmount;
  final double totalDue;
  final double totalPaid;
  final double totalDiscount;
  final double netAmount;
  final int invoiceCount;
  final int receiptCount;
  final int dueReceiptCount;
  final int paidReceiptCount;
  final int dueInvoiceCount;
  final int paidInvoiceCount;
  final int discountInvoiceCount;
  final int refundCount;

  final double dueReceiptAmount;
  final double paidReceiptAmount;
  final double refundAmount;

  SummaryModel({
    required this.totalAmount,
    required this.totalDue,
    required this.totalPaid,
    required this.totalDiscount,
    required this.netAmount,
    required this.invoiceCount,
    required this.receiptCount,
    required this.dueReceiptCount,
    required this.paidReceiptCount,
    required this.dueInvoiceCount,
    required this.paidInvoiceCount,
    required this.discountInvoiceCount,
    required this.dueReceiptAmount,
    required this.paidReceiptAmount,
    required this.refundCount,
    required this.refundAmount,
  });

  factory SummaryModel.fromMap(Map<String, dynamic> map) {
    return SummaryModel(
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      totalDue: (map['totalDue'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (map['totalPaid'] as num?)?.toDouble() ?? 0.0,
      totalDiscount: (map['totalDiscount'] as num?)?.toDouble() ?? 0.0,
      netAmount: (map['netAmount'] as num?)?.toDouble() ?? 0.0,
      invoiceCount: (map['invoiceCount'] as num?)?.toInt() ?? 0,
      receiptCount: (map['receiptCount'] as num?)?.toInt() ?? 0,
      dueReceiptCount: (map['dueReceiptCount'] as num?)?.toInt() ?? 0,
      paidReceiptCount: (map['paidReceiptCount'] as num?)?.toInt() ?? 0,
      dueInvoiceCount: (map['dueInvoiceCount'] as num?)?.toInt() ?? 0,
      paidInvoiceCount: (map['paidInvoiceCount'] as num?)?.toInt() ?? 0,
      discountInvoiceCount: (map['totalDiscountCount'] as num?)?.toInt() ?? 0,
      refundCount: (map['refundCount'] as num?)?.toInt() ?? 0,
      dueReceiptAmount: (map['dueReceiptAmount'] as num?)?.toDouble() ?? 0.0,
      paidReceiptAmount: (map['paidReceiptAmount'] as num?)?.toDouble() ?? 0.0,
      refundAmount: (map['refundAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }


  Map<String, dynamic> toMap() => {
        'totalAmount': totalAmount,
        'totalDue': totalDue,
        'totalPaid': totalPaid,
        'totalDiscount': totalDiscount,
        'netAmount': netAmount,
        'invoiceCount': invoiceCount,
        'receiptCount': receiptCount,
        'dueReceiptCount': dueReceiptCount,
        'paidReceiptCount': paidReceiptCount,
        'dueInvoiceCount': dueInvoiceCount,
        'paidInvoiceCount': paidInvoiceCount,
        'totalDiscountCount': discountInvoiceCount,
        'dueReceiptAmount': dueReceiptAmount,
        'paidReceiptAmount': paidReceiptAmount,
      };
}
