import 'package:flutter/cupertino.dart';
import '../../../../core/database/database_info.dart';
import '../../../../core/database/login.dart';
import '../../../../core/utilities/app_date_time.dart';
import '../../../transactions/data/models/invoice_sync_response_model.dart';

class FinderRepoDb {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<InvoiceSyncResponseModel> fetchInvoicesWithSummary(String? search,) async {
    final whereClauses = <String>[];
    final params = <String>[];

    if (search != null && search.isNotEmpty) {
      final param = '%$search%';
      whereClauses.add(
          "(invoices.invoice_number LIKE ? OR p_local.name LIKE ? OR p_local.phone LIKE ?)");
      params.addAll([param, param, param]);
    }

    final whereClause =
        whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';
    final db = await dbHelper.database;

    try {
      final result = db.select('''
WITH paginated_invoices AS (
  SELECT * FROM invoices
  ORDER BY id ASC
)

SELECT
  invoices.id AS invoice_id,
  invoices.invoice_number,
  invoices.update_date,
  invoices.delivery_date,
  invoices.delivery_time,
  invoices.create_date,
  invoices.create_date_at_web,
  invoices.total_bill_amount,
  invoices.due,
  invoices.paid_amount as recive_amount,
  invoices.discount,
  invoices.discount_type,
  invoices.discount_percentage,
  invoices.refer_type,
  invoices.referre_id_or_desc,
  invoices.created_by_user_id,
  invoices.created_by_name,
  invoices.patient_web_id,

  p_local.id AS patient_id,
  p_local.name AS patient_name,
  p_local.phone AS patient_phone,
  p_local.age AS patient_age,
  p_local.month AS patient_month,
  p_local.day AS patient_day,
  p_local.gender AS patient_gender_id,
  genders.name AS patient_gender,
  p_local.blood_group AS patient_blood_group_id,
  blood_groups.name AS patient_blood_group,
  p_local.address AS patient_address,
  p_local.date_of_birth AS patient_dob,
  p_local.visit_type AS patient_visit_type,
  p_local.hn_number AS patient_hn_number,
  p_local.create_date AS patient_create_date,

  invoice_details.id AS detail_id,
  invoice_details.test_id,
  invoice_details.inventory_id,
  invoice_details.fee AS detail_fee,
  invoice_details.qty AS detail_qty,
  invoice_details.discount AS detail_discount,
  invoice_details.discount_applied,

  test_names.name AS test_name,
  test_names.code AS test_code,

  inventory.name AS inventory_name,

  doctors.id AS doctor_id,
  doctors.name AS doctor_name,
  doctors.phone AS doctor_phone,

  payments.id AS payment_id,
  payments.web_id AS payment_web_id,
  payments.money_receipt_number,
  payments.money_receipt_type,
  payments.payment_type,
  payments.requested_amount,
  payments.due_amount,
  payments.amount AS paid_amount,
  payments.patient_id AS payment_patient_id,
  payments.patient_web AS payment_patient_web,
  payments.invoice_id AS payment_invoice_id,
  payments.payment_date

FROM paginated_invoices invoices
LEFT JOIN patients p_local ON invoices.patient_id = p_local.id OR invoices.patient_web_id = p_local.org_patient_id
LEFT JOIN genders ON p_local.gender = genders.original_id
LEFT JOIN blood_groups ON p_local.blood_group = blood_groups.original_id
LEFT JOIN invoice_details ON invoices.invoice_number = invoice_details.invoice_id
LEFT JOIN test_names ON invoice_details.test_id = test_names.org_test_name_id
LEFT JOIN inventory ON invoice_details.inventory_id = inventory.webId
LEFT JOIN doctors
  ON invoices.refer_type = 'Doctor'
  AND invoices.referre_id_or_desc GLOB '[0-9]*'
  AND CAST(invoices.referre_id_or_desc AS INTEGER) = doctors.org_doctor_id
LEFT JOIN payments ON invoices.invoice_number = payments.invoice_number

$whereClause
''', params);

      final Map<int, Map<String, dynamic>> invoicesMap = {};

      final uniqueReceipts = <String>{};

      for (final row in result) {
        final invoiceId = row['invoice_id'] as int;

        invoicesMap.putIfAbsent(invoiceId, () {
          final totalAmount =
              double.tryParse(row['total_bill_amount']?.toString() ?? '0') ??
                  0.0;
          final due = double.tryParse(row['due']?.toString() ?? '0') ?? 0.0;
          final paid =
              double.tryParse(row['recive_amount']?.toString() ?? '0') ?? 0.0;
          final discount =
              double.tryParse(row['discount']?.toString() ?? '0') ?? 0.0;

          return {
            'invoice_id': invoiceId,
            'invoice_number': row['invoice_number'],
            'update_date': row['update_date'],
            'delivery_date': row['delivery_date'],
            'delivery_time': row['delivery_time'],
            'create_date':
                parseDate(row['create_date_at_web'])?.toIso8601String() ??
                    parseDate(row['create_date'])?.toIso8601String() ??
                    DateTime.now().toIso8601String(),
            'created_by_user_id': row['created_by_user_id'],
            'created_by_name': row['created_by_name'],
            'total_bill_amount': totalAmount,
            'due': due,
            'paid_amount': paid,
            'discount_type': row['discount_type'],
            'discount': discount,
            'discount_percentage': double.tryParse(
                    row['discount_percentage']?.toString() ?? '0') ??
                0.0,
            'refer_type': row['refer_type'],
            'referre_id_or_desc': row['referre_id_or_desc'],
            'refer_info': (row['refer_type'] == 'Doctor' &&
                    row['referre_id_or_desc'] != null)
                ? {
                    'id': row['doctor_id'],
                    'name': row['doctor_name'] ?? '',
                    'phone': row['doctor_phone'] ?? '',
                  }
                : {
                    'type': row['refer_type'] ?? '',
                    'value': row['referre_id_or_desc'] ?? '',
                  },
            'patient': {
              'id': row['patient_id'],
              'web_id': row['patient_web_id'],
              'name': row['patient_name'],
              'phone': row['patient_phone'],
              'age': row['patient_age'],
              'month': row['patient_month'],
              'day': row['patient_day'],
              'visit_type': row['patient_visit_type'],
              'gender': row['patient_gender'],
              'bloodGroup': row['patient_blood_group'],
              'address': row['patient_address'],
              'dateOfBirth': row['patient_dob'],
              'hn_number': row['patient_hn_number'],
              'create_date': row['patient_create_date'],
            },
            'payments': [],
            'invoice_details': [],
            'testDiscountApplyAmount': 0.0,
          };
        });

        final invoice = invoicesMap[invoiceId]!;
        final paymentsList = invoice['payments'] as List;

        final receiptNumberRaw = row['money_receipt_number'];
        final receiptTypeRaw = row['money_receipt_type'];
        final paidAmountRaw = row['paid_amount'];
        final dueAmountRaw = row['due_amount'];
        final requestedAmountRaw = row['requested_amount'];
        final requestedAmount =
            double.tryParse(requestedAmountRaw?.toString() ?? '0') ?? 0.0;
        final dueAmount =
            double.tryParse(dueAmountRaw?.toString() ?? '0') ?? 0.0;
        final receiptNumber = receiptNumberRaw?.toString().trim() ?? '';
        final paidAmount =
            double.tryParse(paidAmountRaw?.toString() ?? '0') ?? 0.0;
        final alreadyExists =
            paymentsList.any((p) => p['money_receipt_number'] == receiptNumber);

        if (receiptNumber.isNotEmpty && !alreadyExists) {
          paymentsList.add({
            'web_id': row['payment_web_id'],
            'money_receipt_number': receiptNumber,
            'money_receipt_type': receiptTypeRaw,
            'patient_id': row['payment_patient_id'],
            'patient_web': row['payment_patient_web'],
            'invoice_number': row['invoice_number'],
            'invoice_id': row['payment_invoice_id'],
            'payment_type': row['payment_type'],
            'amount': paidAmount,
            'requested_amount': requestedAmount,
            'due_amount': dueAmount,
            'payment_date': row['payment_date'],
            'is_sync': 1,
          });

          if (paidAmount > 0 && !uniqueReceipts.contains(receiptNumber)) {
            uniqueReceipts.add(receiptNumber);
          }
        }

        // Add invoice details
        final testId = row['test_id'];
        final inventoryId = row['inventory_id'];

        if (testId != null || inventoryId != null) {
          final detailList = invoice['invoice_details'] as List;

          final isDuplicateDetail = detailList.any((d) =>
              d['test_id'] == testId && d['inventory_id'] == inventoryId);

          if (!isDuplicateDetail) {
            final fee =
                double.tryParse(row['detail_fee']?.toString() ?? '0') ?? 0.0;
            final discount =
                double.tryParse(row['detail_discount']?.toString() ?? '0') ??
                    0.0;

            final discountApplied = (row['discount_applied'] == 1);

            detailList.add({
              'type': testId != null ? 'Test' : 'Inventory',
              'test_id': testId,
              'test_name': row['test_name'],
              'test_code': row['test_code'],
              'inventory_id': inventoryId,
              'inventory_name': row['inventory_name'],
              'fee': fee,
              'qty': row['detail_qty'],
              'discount': discount,
            });

            // Initialize testDiscountApplyAmount if null
            if (invoice['testDiscountApplyAmount'] == null) {
              invoice['testDiscountApplyAmount'] = 0.0;
            }

            if (discountApplied) {
              final discountedFee = fee - (fee * discount / 100);
              invoice['testDiscountApplyAmount'] =
                  (invoice['testDiscountApplyAmount'] as double? ?? 0) +
                      discountedFee;
            }
          }
        }
      }

      final invoiceList = invoicesMap.values
          .map((invoiceMap) => InvoiceModelSync.fromMap(invoiceMap))
          .toList();
      return InvoiceSyncResponseModel.fromMap({
        'invoices': invoiceList.map((i) => i.toMap()).toList(),
        'summary': null,
      });
    } catch (e, s) {
      debugPrint("Error fetching invoices with summary: $e\n$s");
      throw Exception("Failed to fetch invoices with summary: $e");
    }
  }

  Future<InvoiceSyncResponseModel> fetchInvoicesWithCurrentUser({
    String? search,
  }) async {
    try {
      final db = await dbHelper.database;
      final token = await LocalDB.getLoginInfo();

      String userId = "${token?['userId']}";
      final whereClauses = <String>[];
      final params = <String>[];

      if (search != null && search.isNotEmpty) {
        final param = '%$search%';
        whereClauses.add(
            "(invoices.invoice_number LIKE ? OR p_local.name LIKE ? OR p_local.phone LIKE ?)");
        params.addAll([param, param, param]);
      }

      if (userId.isNotEmpty) {
        whereClauses.add("invoices.created_by_user_id = ?");
        params.add(userId);
      }

      final whereClause =
          whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';

      final result = db.select('''
   WITH paginated_invoices AS (
  SELECT * FROM invoices
  ORDER BY id ASC
)
    SELECT
      invoices.id AS invoice_id,
      invoices.invoice_number,
      invoices.update_date,
      invoices.delivery_date,
      invoices.delivery_time,
      invoices.create_date,
      invoices.create_date_at_web,
      invoices.total_bill_amount,
      invoices.due,
      invoices.paid_amount as recive_amount,
      invoices.discount,
      invoices.discount_type,
      invoices.discount_percentage,
      invoices.refer_type,
      invoices.referre_id_or_desc,
      invoices.created_by_user_id,
      invoices.created_by_name,
      invoices.patient_web_id,

      p_local.id AS patient_id,
      p_local.name AS patient_name,
      p_local.phone AS patient_phone,
      p_local.age AS patient_age,
      p_local.month AS patient_month,
      p_local.day AS patient_day,
      p_local.gender AS patient_gender_id,
      genders.name AS patient_gender,
      p_local.blood_group AS patient_blood_group_id,
      blood_groups.name AS patient_blood_group,
      p_local.address AS patient_address,
      p_local.date_of_birth AS patient_dob,
      p_local.visit_type AS patient_visit_type,
      p_local.hn_number AS patient_hn_number,
      p_local.create_date AS patient_create_date,

      invoice_details.id AS detail_id,
      invoice_details.test_id,
      invoice_details.inventory_id,
      invoice_details.fee AS detail_fee,
      invoice_details.qty AS detail_qty,
      invoice_details.discount AS detail_discount,
      invoice_details.discount_applied,

      test_names.name AS test_name,
      test_names.code AS test_code,

      inventory.name AS inventory_name,

      doctors.id AS doctor_id,
      doctors.name AS doctor_name,
      doctors.phone AS doctor_phone,

      payments.id AS payment_id,
      payments.web_id AS payment_web_id,
      payments.money_receipt_number,
      payments.money_receipt_type,
      payments.payment_type,
      payments.requested_amount,
      payments.due_amount,
      payments.amount AS paid_amount,
      payments.patient_id AS payment_patient_id,
      payments.patient_web AS payment_patient_web,
      payments.invoice_id AS payment_invoice_id,
      payments.payment_date

    FROM paginated_invoices invoices
    LEFT JOIN patients p_local ON invoices.patient_id = p_local.id OR invoices.patient_web_id = p_local.org_patient_id
    LEFT JOIN genders ON p_local.gender = genders.id
    LEFT JOIN blood_groups ON p_local.blood_group = blood_groups.id
    LEFT JOIN invoice_details ON invoices.invoice_number = invoice_details.invoice_id
    LEFT JOIN test_names ON invoice_details.test_id = test_names.org_test_name_id
    LEFT JOIN inventory ON invoice_details.inventory_id = inventory.webId
    LEFT JOIN doctors
      ON invoices.refer_type = 'Doctor'
      AND invoices.referre_id_or_desc GLOB '[0-9]*'
      AND CAST(invoices.referre_id_or_desc AS INTEGER) = doctors.org_doctor_id
    LEFT JOIN payments ON invoices.invoice_number = payments.invoice_number

$whereClause
''', params);
      final Map<int, Map<String, dynamic>> invoicesMap = {};

      int receiptCount = 0;
      int dueReceiptCount = 0;
      int paidReceiptCount = 0;
      int dueInvoiceCount = 0;
      int paidInvoiceCount = 0;
      int discountInvoiceCount = 0;
      double dueReceiptAmountSum = 0;
      double paidReceiptAmountSum = 0;

      final uniqueReceipts = <String>{};

      for (final row in result) {
        final invoiceId = row['invoice_id'] as int;

        invoicesMap.putIfAbsent(invoiceId, () {
          final totalAmount =
              double.tryParse(row['total_bill_amount']?.toString() ?? '0') ??
                  0.0;
          final due = double.tryParse(row['due']?.toString() ?? '0') ?? 0.0;
          final paid =
              double.tryParse(row['recive_amount']?.toString() ?? '0') ?? 0.0;
          final discount =
              double.tryParse(row['discount']?.toString() ?? '0') ?? 0.0;

          if (discount > 0) discountInvoiceCount++;
          if (due > 0) {
            dueInvoiceCount++;
          } else {
            paidInvoiceCount++;
          }

          return {
            'invoice_id': invoiceId,
            'invoice_number': row['invoice_number'],
            'update_date': row['update_date'],
            'delivery_date': row['delivery_date'],
            'delivery_time': row['delivery_time'],
            'create_date':
                parseDate(row['create_date_at_web'])?.toIso8601String() ??
                    parseDate(row['create_date'])?.toIso8601String() ??
                    DateTime.now().toIso8601String(),
            'created_by_user_id': row['created_by_user_id'],
            'created_by_name': row['created_by_name'],
            'total_bill_amount': totalAmount,
            'due': due,
            'paid_amount': paid,
            'discount_type': row['discount_type'],
            'discount': discount,
            'discount_percentage': double.tryParse(
                    row['discount_percentage']?.toString() ?? '0') ??
                0.0,
            'refer_type': row['refer_type'],
            'referre_id_or_desc': row['referre_id_or_desc'],
            'refer_info': (row['refer_type'] == 'Doctor' &&
                    row['referre_id_or_desc'] != null)
                ? {
                    'id': row['doctor_id'],
                    'name': row['doctor_name'] ?? '',
                    'phone': row['doctor_phone'] ?? '',
                  }
                : {
                    'type': row['refer_type'] ?? '',
                    'value': row['referre_id_or_desc'] ?? '',
                  },
            'patient': {
              'id': row['patient_id'],
              'web_id': row['patient_web_id'],
              'name': row['patient_name'],
              'phone': row['patient_phone'],
              'age': row['patient_age'],
              'month': row['patient_month'],
              'day': row['patient_day'],
              'visit_type': row['patient_visit_type'],
              'gender': row['patient_gender'],
              'bloodGroup': row['patient_blood_group'],
              'address': row['patient_address'],
              'dateOfBirth': row['patient_dob'],
              'hn_number': row['patient_hn_number'],
              'create_date': row['patient_create_date'],
            },
            'payments': [],
            'invoice_details': [],
            'testDiscountApplyAmount': 0.0,
          };
        });

        final invoice = invoicesMap[invoiceId]!;
        final paymentsList = invoice['payments'] as List;

        final receiptNumberRaw = row['money_receipt_number'];
        final receiptTypeRaw = row['money_receipt_type'];
        final paidAmountRaw = row['paid_amount'];
        final dueAmountRaw = row['due_amount'];
        final requestedAmountRaw = row['requested_amount'];
        final requestedAmount =
            double.tryParse(requestedAmountRaw?.toString() ?? '0') ?? 0.0;
        final dueAmount =
            double.tryParse(dueAmountRaw?.toString() ?? '0') ?? 0.0;
        final receiptNumber = receiptNumberRaw?.toString().trim() ?? '';
        final receiptType = receiptTypeRaw?.toString().toLowerCase() ?? '';
        final paidAmount =
            double.tryParse(paidAmountRaw?.toString() ?? '0') ?? 0.0;
        final alreadyExists =
            paymentsList.any((p) => p['money_receipt_number'] == receiptNumber);

        if (receiptNumber.isNotEmpty && !alreadyExists) {
          paymentsList.add({
            'web_id': row['payment_web_id'],
            'money_receipt_number': receiptNumber,
            'money_receipt_type': receiptTypeRaw,
            'patient_id': row['payment_patient_id'],
            'patient_web': row['payment_patient_web'],
            'invoice_number': row['invoice_number'],
            'invoice_id': row['payment_invoice_id'],
            'payment_type': row['payment_type'],
            'amount': paidAmount,
            'requested_amount': requestedAmount,
            'due_amount': dueAmount,
            'payment_date': row['payment_date'],
            'is_sync': 1,
          });

          if (paidAmount > 0 && !uniqueReceipts.contains(receiptNumber)) {
            receiptCount++;

            if (receiptType == 'due') {
              dueReceiptCount++;
              dueReceiptAmountSum += paidAmount;
            } else {
              paidReceiptCount++;
              paidReceiptAmountSum += paidAmount;
            }

            uniqueReceipts.add(receiptNumber);
          }
        }

        // Add invoice details
        final testId = row['test_id'];
        final inventoryId = row['inventory_id'];

        if (testId != null || inventoryId != null) {
          final detailList = invoice['invoice_details'] as List;

          final isDuplicateDetail = detailList.any((d) =>
              d['test_id'] == testId && d['inventory_id'] == inventoryId);

          if (!isDuplicateDetail) {
            final fee =
                double.tryParse(row['detail_fee']?.toString() ?? '0') ?? 0.0;
            final discount =
                double.tryParse(row['detail_discount']?.toString() ?? '0') ??
                    0.0;

            final discountApplied = (row['discount_applied'] == 1);

            detailList.add({
              'type': testId != null ? 'Test' : 'Inventory',
              'test_id': testId,
              'test_name': row['test_name'],
              'test_code': row['test_code'],
              'inventory_id': inventoryId,
              'inventory_name': row['inventory_name'],
              'fee': fee,
              'qty': row['detail_qty'],
              'discount': discount,
            });

            // Initialize testDiscountApplyAmount if null
            if (invoice['testDiscountApplyAmount'] == null) {
              invoice['testDiscountApplyAmount'] = 0.0;
            }

            if (discountApplied) {
              final discountedFee = fee - (fee * discount / 100);
              invoice['testDiscountApplyAmount'] =
                  (invoice['testDiscountApplyAmount'] as double? ?? 0) +
                      discountedFee;
            }
          }
        }
      }

      final invoiceList = invoicesMap.values
          .map((invoiceMap) => InvoiceModelSync.fromMap(invoiceMap))
          .toList();

      final summary = {
        'receiptCount': receiptCount,
        'dueReceiptCount': dueReceiptCount,
        'dueReceiptAmount': dueReceiptAmountSum,
        'paidReceiptCount': paidReceiptCount,
        'paidReceiptAmount': paidReceiptAmountSum,
        'dueInvoiceCount': dueInvoiceCount,
        'paidInvoiceCount': paidInvoiceCount,
        'totalDiscountCount': discountInvoiceCount,
      };

      return InvoiceSyncResponseModel.fromMap({
        'invoices': invoiceList.map((i) => i.toMap()).toList(),
        'summary': summary,
      });
    } catch (e, s) {
      debugPrint("Error fetching invoices with summary: $e\n$s");
      throw Exception("Failed to fetch invoices with summary: $e");
    }
  }
}
