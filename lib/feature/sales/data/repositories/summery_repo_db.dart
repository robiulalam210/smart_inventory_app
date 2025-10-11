import '../../../../core/database/database_info.dart';
import '../../../../core/database/login.dart';

class SummeryRepoDB {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<Map<String, dynamic>> fetchMoneyReceiptWithSummary({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final db = await dbHelper.database;
    final token = await LocalDB.getLoginInfo();
    String userId = "${token?['userId']}";

    final List<String> whereConditions = [];
    final List<dynamic> whereArgs = [];

    // Filter by current user
    if (userId.isNotEmpty) {
      whereConditions.add("invoices.created_by_user_id = ?");
      whereArgs.add(userId);
    }

    if (fromDate != null && toDate != null) {
      whereConditions.add(
        "DATE(payments.payment_date) BETWEEN DATE(?) AND DATE(?)",
      );
      whereArgs.addAll([fromDate.toIso8601String(), toDate.toIso8601String()]);
    }

    final whereClause =
    whereConditions.isNotEmpty ? "WHERE ${whereConditions.join(" AND ")}" : "";

    // ---------------- Fetch payments ----------------
    final sql = '''
    SELECT 
      payments.id AS payment_id,
      payments.web_id AS payment_web_id,
      payments.money_receipt_number,
      payments.money_receipt_type,
      payments.payment_type,
      payments.requested_amount,
      payments.due_amount,
      payments.amount AS payments_amount,
      payments.patient_id AS payment_patient_id,
      payments.patient_web AS payment_patient_web,
      payments.invoice_id AS payment_invoice_id,
      payments.invoice_number AS payment_invoice_number,
      payments.payment_date,

      invoices.invoice_number AS invoice_invoice_number,
      invoices.total_bill_amount AS invoice_total_bill_amount,
      invoices.discount AS invoice_discount,
      invoices.paid_amount AS invoice_paid_amount,
      invoices.due AS invoice_due,
      invoices.delivery_date AS invoice_delivery_date,
      invoices.refer_type AS invoice_refer_type,
      invoices.referre_id_or_desc AS invoice_referre_id_or_desc,
      invoices.delivery_time,
      invoices.create_date,
      invoices.discount_type,
      invoices.discount_percentage,
      invoices.created_by_user_id,
      invoices.created_by_name,
      invoices.patient_web_id,

      p_local.id AS patient_id,
      p_local.name AS patient_name,
      p_local.phone AS patient_phone,
      p_local.hn_number AS patient_hn_number,
      p_local.create_date AS patient_create_date,

      doctors.id AS doctor_id,
      doctors.name AS doctor_name,
      doctors.phone AS doctor_phone,

      creator_user.saas_user_id AS creator_user_id,
      creator_user.name AS creator_user_name

    FROM payments
    LEFT JOIN invoices
      ON payments.invoice_number = invoices.invoice_number
    LEFT JOIN patients p_local
      ON invoices.patient_id = p_local.id
      OR (invoices.patient_id IS NULL AND invoices.patient_web_id = p_local.org_patient_id)
    LEFT JOIN users AS creator_user
      ON invoices.created_by_user_id = creator_user.saas_user_id
    LEFT JOIN doctors
      ON invoices.refer_type = 'Doctor'
      AND invoices.referre_id_or_desc GLOB '[0-9]*'
      AND CAST(invoices.referre_id_or_desc AS INTEGER) = doctors.org_doctor_id
    $whereClause
    ORDER BY payments.payment_date DESC
    ''';

    final paymentsResult = db.select(sql, whereArgs);

    // ---------------- Fetch case_effects ----------------
    final paymentIds = paymentsResult
        .map((e) => e['payment_web_id'] ?? e['payment_id'])
        .where((id) => id != null)
        .toList();

    List<Map<String, Object?>> caseEffectsResult = [];
    if (paymentIds.isNotEmpty) {
      final placeholders = List.filled(paymentIds.length, '?').join(',');
      final caseSql = '''
      SELECT * FROM case_effects
      WHERE money_receipt_id IN ($placeholders)
      ''';
      caseEffectsResult = db.select(caseSql, paymentIds).map((row) {
        return {for (final key in row.keys) key: row[key]};
      }).toList();
    }

    // ---------------- Process payments ----------------
    final List<Map<String, dynamic>> paymentsAdd = [];
    final List<Map<String, dynamic>> paymentsDue = [];
    final List<Map<String, dynamic>> paymentsRefund = [];

    double newBillTotal = 0;
    double dueCollectionTotal = 0;
    double refundTotal = 0;

    final uniquePayments = <String, Map<String, dynamic>>{};

    for (final row in paymentsResult) {
      final key = row['payment_web_id']?.toString() ?? row['payment_id'].toString();
      if (uniquePayments.containsKey(key)) continue; // skip duplicates
      uniquePayments[key] = row;

      final type = (row['money_receipt_type'] ?? '').toString().toLowerCase();

      final caseEffect = caseEffectsResult.firstWhere(
            (ce) =>
        ce['money_receipt_id']?.toString() ==
            (row['payment_web_id']?.toString() ?? row['payment_id'].toString()),
        orElse: () => {
          'id': null,
          'web_id': null,
          'money_receipt_id': row['payment_web_id'] ?? row['payment_id'],
          'amount': 0.0,
        },
      );

      final amount = (type == 'refund')
          ? ((caseEffect['amount'] ?? row['payments_amount']) as num? ?? 0).toDouble()
          : ((row['payments_amount'] ?? 0) as num).toDouble();

      final paymentData = {
        'payment_id': row['payment_id'],
        'payment_web_id': row['payment_web_id'],
        'money_receipt_number': row['money_receipt_number'],
        'money_receipt_type': row['money_receipt_type'],
        'payment_type': row['payment_type'],
        'requested_amount': row['requested_amount'],
        'due_amount': row['due_amount'],
        'paid_amount': amount,
        'patient_id': row['payment_patient_id'],
        'patient_web': row['payment_patient_web'],
        'invoice_id': row['payment_invoice_id'],
        'invoice_number': row['payment_invoice_number'],
        'payment_date': row['payment_date'],
        'invoice': {
          'invoice_number': row['invoice_invoice_number'],
          'total_bill_amount': row['invoice_total_bill_amount'],
          'discount': row['invoice_discount'],
          'paid_amount': row['invoice_paid_amount'],
          'due': row['invoice_due'],
          'delivery_date': row['invoice_delivery_date'],
          'refer_type': row['invoice_refer_type'],
          'referre_id_or_desc': row['invoice_referre_id_or_desc'],
          'delivery_time': row['delivery_time'],
          'create_date': row['create_date'],
          'discount_type': row['discount_type'],
          'discount_percentage': row['discount_percentage'],
          'created_by_user_id': row['created_by_user_id'],
          'created_by_name': row['created_by_name'],
          'patient_web_id': row['patient_web_id'],
        },
        'case_effect': {
          'id': caseEffect['id'],
          'web_id': caseEffect['web_id'],
          'money_receipt_id': caseEffect['money_receipt_id'],
          'amount': (caseEffect['amount'] as num? ?? 0).toDouble(),
        },
        'patient': {
          'id': row['patient_id'],
          'name': row['patient_name'],
          'phone': row['patient_phone'],
          'hn_number': row['patient_hn_number'],
          'create_date': row['patient_create_date'],
        },
        'doctor': {
          'id': row['doctor_id'],
          'name': row['doctor_name'],
          'phone': row['doctor_phone'],
        },
        'creator_user': {
          'id': row['creator_user_id'],
          'name': row['creator_user_name'],
        },
      };

      if (type == 'add') {
        newBillTotal += amount;
        paymentsAdd.add(paymentData);
      } else if (type == 'due') {
        dueCollectionTotal += amount;
        paymentsDue.add(paymentData);
      } else if (type == 'refund') {
        refundTotal += amount;
        paymentsRefund.add(paymentData);
      }
    }

    final summary = {
      'new_bill': newBillTotal,
      'due_collection': dueCollectionTotal,
      'test_refund': refundTotal,
      'grand_total': newBillTotal + dueCollectionTotal - refundTotal,
    };

    return {
      'payments_add': paymentsAdd,
      'payments_due': paymentsDue,
      'payments_refund': paymentsRefund,
      'summary': summary,
    };
  }
}
