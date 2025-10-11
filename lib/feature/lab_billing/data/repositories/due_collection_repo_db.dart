import 'package:sqlite3/sqlite3.dart';

import '../../../../core/configs/configs.dart';
import '../../../transactions/data/models/invoice_local_model.dart';

class DueCollectionRepoDb {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<InvoiceLocalModel> fetchInvoiceFilter(String invoiceId) async {
    final Database db = await dbHelper.database;

    try {
      final result = db.select('''
        SELECT
      invoices.id AS invoice_id,
      invoices.invoice_number,
      invoices.update_date,
      invoices.delivery_date,
      invoices.delivery_time,
      invoices.create_date,
      invoices.total_bill_amount,
      invoices.due,
      invoices.paid_amount,
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
   

      test_names.name AS test_name,
      test_names.code AS test_code,
      test_names.discount_applied AS discount_applied,
      test_names.discount AS detail_discount,

      inventory.name AS inventory_name,

      doctors.id AS doctor_id,
      doctors.name AS doctor_name,
      doctors.phone AS doctor_phone,

      payments.id AS payment_id,
      payments.payment_type,
      payments.amount AS payment_amount,
      payments.payment_date,
      
      creator_user.name AS creator_name,
      creator_user.email AS creator_email,
      creator_user.phone AS creator_phone,
      creator_user.user_type AS creator_type


    FROM invoices
   LEFT JOIN patients p_local
  ON invoices.patient_id = p_local.id
  OR invoices.patient_web_id = p_local.org_patient_id
    LEFT JOIN users AS creator_user ON invoices.created_by_user_id = creator_user.saas_user_id
    LEFT JOIN genders ON p_local.gender = genders.original_id
    LEFT JOIN blood_groups ON p_local.blood_group = blood_groups.original_id
    LEFT JOIN invoice_details ON invoices.invoice_number = invoice_details.invoice_id
    LEFT JOIN test_names ON invoice_details.test_id = test_names.org_test_name_id
    LEFT JOIN payments ON invoices.invoice_number = payments.invoice_number

    LEFT JOIN inventory ON invoice_details.inventory_id = inventory.webId
      LEFT JOIN doctors
        ON invoices.refer_type = 'Doctor'
        AND invoices.referre_id_or_desc GLOB '[0-9]*'
        AND CAST(invoices.referre_id_or_desc AS INTEGER) = doctors.org_doctor_id
      WHERE invoices.invoice_number = ?
    ''', [invoiceId]);

      if (result.isEmpty) {
        // throw Exception('Invoice not found');
      }

      double parseDouble(dynamic value) {
        if (value == null) return 0.0;
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      }

      final invoiceMap = <String, dynamic>{};
      final paymentIds = <int>{};
      final invoiceDetailSet = <String>{};

      for (final row in result) {
        if (invoiceMap.isEmpty) {
          invoiceMap.addAll({
            'invoice_id': row['invoice_id'],
            'invoice_number': row['invoice_number'],
            'webId': row['webId'],
            'update_date': row['update_date'],
            'delivery_date': row['delivery_date'],
            'delivery_time': row['delivery_time'],
            'create_date': row['create_date'],
            'created_by_user_id': row['created_by_user_id'],
            'created_by_name': row['created_by_name'],
            'total_bill_amount': parseDouble(row['total_bill_amount']),
            'due': parseDouble(row['due']),
            'paid_amount': parseDouble(row['paid_amount']),
            'discount_type': row['discount_type'],
            'discount': parseDouble(row['discount']),
            'discount_percentage': parseDouble(row['discount_percentage']),
            'refer_type': row['refer_type'],
            'referre_id_or_desc': row['referre_id_or_desc'],

            // Refer info
            'refer_info': (row['refer_type'] == 'Doctor' &&
                    row['referre_id_or_desc'] != null)
                ? {
                    'id': row['doctor_id'],
                    'name': row['doctor_name'] ?? '',
                    'phone': row['doctor_phone'] ?? '',
                  }
                : {
                    'type': row['refer_type'] ?? '',
                    'value': row['referre_id_or_desc'] ?? row['refer_type'],
                  },

            // Patient info
            'patient': {
              'id': row['id'],
              'patient_id': row['patient_id'],
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

            // Created by user
            'created_by_user': {
              'id': row['created_by_user_id'],
              'name': row['created_by_name'],
              'email': row['creator_email'],
              'phone': row['creator_phone'],
              'type': row['creator_type'],
            },

            'payments': [],
            'invoice_details': [],
            'testDiscountApplyAmount': 0.0,
          });
        }

        // Payments
        final paymentId = row['payment_id'] as int?;
        if (paymentId != null && !paymentIds.contains(paymentId)) {
          (invoiceMap['payments'] as List).add({
            // 'payment_id': paymentId,
            'invoice_number': row['invoice_number'] ?? '',
            'payment_type': row['payment_type'] ?? '',
            'payment_amount': parseDouble(row['payment_amount']),
            'payment_date': row['payment_date'] ?? '',
          });
          paymentIds.add(paymentId);
        }

        // Invoice details
        final testId = row['test_id'];
        final inventoryId = row['inventory_id'];
        final isTest = testId != null;
        final isInventory = inventoryId != null;

        final detailKey = isTest
            ? 'test_${testId.toString()}'
            : isInventory
                ? 'inv_${inventoryId.toString()}'
                : '';
        if (detailKey.isNotEmpty && !invoiceDetailSet.contains(detailKey)) {
          final fee =
              double.tryParse(row['detail_fee']?.toString() ?? '0') ?? 0.0;
          final discount =
              double.tryParse(row['detail_discount']?.toString() ?? '0') ?? 0.0;

          final discountApplied = (row['discount_applied'] == 1);
          final detail = {
            'type': isTest ? 'Test' : 'Inventory',
            'test_id': testId,
            'inventory_id': inventoryId,
            'test_name': row['test_name'],
            'test_code': row['test_code'],
            'inventory_name': row['inventory_name'],
            'fee': double.tryParse(row['detail_fee']?.toString() ?? '0') ?? 0.0,
            'qty': row['qty'] != null
                ? int.tryParse(row['qty'].toString()) ?? 1
                : 1, // fallback to 1 if null
            'discount_applied': row['discount_applied'],
            'detail_discount': parseDouble(row['detail_discount']),
          };

          (invoiceMap['invoice_details'] as List).add(detail);
          invoiceDetailSet.add(detailKey);

          // Initialize testDiscountApplyAmount if null
          if (invoiceMap['testDiscountApplyAmount'] == null) {
            invoiceMap['testDiscountApplyAmount'] = 0.0;
          }

          if (discountApplied) {
            final discountedFee = fee - (fee * discount / 100);
            invoiceMap['testDiscountApplyAmount'] =
                (invoiceMap['testDiscountApplyAmount'] as double? ?? 0) +
                    discountedFee;
          }
        }
      }

      debugPrint("invoice single : $invoiceMap");
      return InvoiceLocalModel.fromMap(invoiceMap);
    } catch (e, s) {
      debugPrint("Error fetching invoice details: $e\nStackTrace: $s");
      rethrow;
    }
  }
}
