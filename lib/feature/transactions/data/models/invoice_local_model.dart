class InvoiceLocalModel {
  final int? invoiceId;
  final String? invoiceNumber;
  final DateTime issuedDate;
  final String? deliveryDate;
  final String? deliveryTime;
  final DateTime? createDate;
  final double? totalBillAmount;
  final double? due;
  final double? paidAmount;
  final String? discountType;
  final double? discount;
  final double? discountPercentage;
  final double? paymentAmount;
  final String? referType;
  final String? billingComment;
  final String? referreIdOrDesc;
  final LocalCreatedByUser createdByUser;

  final ReferInfo referInfo;
  final PatientLocal patient;
  final List<Payment> payments;
  final List<InvoiceDetailLocal> invoiceDetails;
  final double? testDiscountApplyAmount;

  InvoiceLocalModel({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.issuedDate,
    this.deliveryDate,
    this.deliveryTime,
    this.createDate,
    this.billingComment,
    required this.totalBillAmount,
    required this.due,
    required this.paidAmount,
    required this.discountType,
    required this.discount,
    required this.discountPercentage,
    required this.paymentAmount,
    required this.referType,
    required this.referreIdOrDesc,
    required this.createdByUser,
    required this.referInfo,
    required this.patient,
    required this.payments,
    required this.invoiceDetails,
     this.testDiscountApplyAmount,
  });

  factory InvoiceLocalModel.fromMap(Map<String, dynamic> map) {
    return InvoiceLocalModel(
      invoiceId: map['invoice_id'] ?? 0,
      invoiceNumber: map['invoice_number']?.toString() ?? '',
      issuedDate: DateTime.tryParse(map['create_date_at_web']?.toString() ?? '') ?? DateTime.now(),
      deliveryDate: map['delivery_date']?.toString(),
      deliveryTime: map['delivery_time']?.toString(),
      createDate: DateTime.tryParse(map['create_date']?.toString() ?? ''),
      totalBillAmount: (map['total_bill_amount'] as num?)?.toDouble() ?? 0.0,   testDiscountApplyAmount: (map['testDiscountApplyAmount'] as num?)?.toDouble() ?? 0.0,
      due: (map['due'] as num?)?.toDouble() ?? 0.0,
      paidAmount: double.tryParse(map['paid_amount']?.toString() ?? '0') ?? 0.0,
      discountType: map['discount_type']?.toString() ?? '',
      discount: double.tryParse(map['discount']?.toString() ?? '0') ?? 0.0,
      discountPercentage: double.tryParse(map['discount_percentage']?.toString() ?? '0') ?? 0.0,
      paymentAmount: double.tryParse(map['payment_amount']?.toString() ?? '0') ?? 0.0,
      referType: map['refer_type']?.toString() ?? '',
      billingComment: map['billingComment']?.toString() ?? '',
      referreIdOrDesc: map['referre_id_or_desc']?.toString() ?? '',
      createdByUser: map['created_by_user'] != null
          ? LocalCreatedByUser.fromMap(Map<String, dynamic>.from(map['created_by_user']))
          : LocalCreatedByUser.empty(),
      referInfo: map['refer_info'] != null
          ? ReferInfo.fromMap(Map<String, dynamic>.from(map['refer_info']))
          : ReferInfo.empty(),

      patient: map['patient'] != null
          ? PatientLocal.fromMap(Map<String, dynamic>.from(map['patient']))
          : PatientLocal.empty(),

      payments: (map['payments'] as List<dynamic>?)
          ?.map((x) => Payment.fromMap(Map<String, dynamic>.from(x)))
          .toList() ??
          [],

      invoiceDetails: (map['invoice_details'] as List<dynamic>?)
          ?.map((x) => InvoiceDetailLocal.fromMap(Map<String, dynamic>.from(x)))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoice_id': invoiceId,
      'invoice_number': invoiceNumber,
      'create_date_at_web': issuedDate.toIso8601String(),
      'delivery_date': deliveryDate,
      'delivery_time': deliveryTime,
      'create_date': createDate?.toIso8601String(),
      'total_bill_amount': totalBillAmount,
      'testDiscountApplyAmount': testDiscountApplyAmount,
      'due': due,
      'paid_amount': paidAmount,
      'discount_type': discountType,
      'discount': discount,
      'discount_percentage': discountPercentage,
      'payment_amount': paymentAmount,
      'refer_type': referType,
      'billingComment': billingComment,
      'referre_id_or_desc': referreIdOrDesc,
      'created_by_user': createdByUser.toMap(),
      'refer_info': referInfo.toMap(),
      'patient': patient.toMap(),
      'payments': payments.map((p) => p.toMap()).toList(),
      'invoice_details': invoiceDetails.map((d) => d.toMap()).toList(),
    };
  }

}
class LocalCreatedByUser {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? type;

  LocalCreatedByUser({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.type,
  });

  factory LocalCreatedByUser.fromMap(Map<String, dynamic> map) {
    return LocalCreatedByUser(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? ''),
      name: map['name']?.toString(),
      email: map['email']?.toString(),
      phone: map['phone']?.toString(),
      type: map['type']?.toString(),
    );
  }

  factory LocalCreatedByUser.empty() {
    return LocalCreatedByUser(id: null, name: null, email: null, phone: null, type: null);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'type': type,
    };
  }
}

class ReferInfo {
  final String type;
  final String value;
  final int? id;
  final String? name;
  final String? phone;

  ReferInfo({
    this.type = '',
    this.value = '',
    this.id,
    this.name,
    this.phone,
  });

  factory ReferInfo.fromMap(Map<String, dynamic> map) {
    return ReferInfo(
      type: map['type']?.toString() ?? '',
      value: map['value']?.toString() ?? '',
      id: map['id'] is int ? map['id'] : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
      name: map['name']?.toString(),
      phone: map['phone']?.toString(),
    );
  }

  factory ReferInfo.empty() => ReferInfo();

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'value': value,
      'id': id,
      'name': name,
      'phone': phone,
    };
  }
}

class PatientLocal {
  final int id;
  final String name;
  final String phone;
  final String age;
  final String month;
  final String day;
  final String gender;
  final String bloodGroup;
  final String address;
  final String dateOfBirth;
  final String visitType;
  final String hnNumber;
  final String createDate;

  PatientLocal({
    required this.id,
    required this.name,
    required this.phone,
    required this.age,
    required this.month,
    required this.day,
    required this.gender,
    required this.bloodGroup,
    required this.address,
    required this.dateOfBirth,
    required this.visitType,
    required this.hnNumber,
    required this.createDate,
  });

  factory PatientLocal.fromMap(Map<String, dynamic> map) {
    return PatientLocal(
      id: map['id'] ?? 0,
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      age: map['age']?.toString() ?? '',
      month: map['month']?.toString() ?? '',
      day: map['day']?.toString() ?? '',
      gender: map['gender']?.toString() ?? '',
      bloodGroup: map['bloodGroup']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      dateOfBirth: map['dateOfBirth']?.toString() ?? '',
      visitType: map['visit_type']?.toString() ?? '',
      hnNumber: map['hn_number']?.toString() ?? '',
      createDate: map['create_date']?.toString() ?? '',
    );
  }

  factory PatientLocal.empty() {
    return PatientLocal(
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

  Map<String, dynamic> toMap() {
    return {
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
}

class Payment {
  final int paymentId;
  final String paymentMethod;
  final DateTime paymentDate;
  final double paymentAmount;

  Payment({
    required this.paymentId,
    required this.paymentMethod,
    required this.paymentDate,
    required this.paymentAmount,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      paymentId: map['payment_id'] ?? 0,
      paymentMethod: map['payment_type']?.toString() ?? '',
      paymentDate: DateTime.tryParse(map['payment_date']?.toString() ?? '') ?? DateTime.now(),
      paymentAmount: double.tryParse(map['payment_amount']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'payment_id': paymentId,
      'payment_type': paymentMethod,
      'payment_date': paymentDate.toIso8601String(),
      'payment_amount': paymentAmount,
    };
  }
}

class InvoiceDetailLocal {
  final int? testId;
  final int? inventoryId;
  final String? name;
  final String? code;
  final double? fee;
  final double? discount;
  final int? discountApplied;
  final int? qty;
  final String? type;

  InvoiceDetailLocal({
    this.testId,
    this.inventoryId,
    required this.name,
    this.code,
     this.fee,
     this.discount,
     this.discountApplied,
     this.qty,
     this.type,
  });

  factory InvoiceDetailLocal.fromMap(Map<String, dynamic> map) {
    return InvoiceDetailLocal(
      testId: map['test_id'] is int ? map['test_id'] : (map['test_id'] != null ? int.tryParse(map['test_id'].toString()) : null),
      inventoryId: map['inventory_id'] is int ? map['inventory_id'] : (map['inventory_id'] != null ? int.tryParse(map['inventory_id'].toString()) : null),
      name: map['test_name']?.toString() ?? map['inventory_name']?.toString() ?? '',
      code: map['test_code']?.toString(),
      fee: (map['fee'] ?? 0).toDouble(),
      discount: (map['detail_discount'] ?? 0).toDouble(),
      discountApplied: map['discount_applied'] ,
      qty: (map['qty'] is int) ? map['qty'] : int.tryParse(map['qty']?.toString() ?? '1') ?? 1,
      type: map['type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'test_id': testId,
      'inventory_id': inventoryId,
      'test_name': name,
      'test_code': code,
      'fee': fee,
      'detail_discount': discount,
      'discount_applied': discountApplied,
      'qty': qty,
      'type': type,
    };
  }
}
