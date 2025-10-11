import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:sqlite3/sqlite3.dart';
import '../../../../core/database/database_info.dart';

import '../../../../core/database/login.dart';
import '../../../lab_dashboard/data/models/invoice_un_sync_model.dart';
import '../../../transactions/data/models/invoice_local_model.dart';

class LabBillingRepository {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<List<InvoiceUnSyncModel>> fetchAllOfflineInvoiceDetails() async {
    final Database db = await dbHelper.database;

    try {
      // Get branch info
      final userResult =
          db.select('SELECT branch_id, branch_name FROM users LIMIT 1');
      if (userResult.isEmpty) {
        throw Exception("No user found to retrieve branch info.");
      }

      final branchId = userResult.first['branch_id'];
      final branchName = userResult.first['branch_name'];

      // Main invoice query
      final result = db.select('''
      SELECT
        invoices.id AS invoice_id,
        invoices.webId AS invoice_web_id,
        invoices.invoice_number,
        invoices.delivery_date,
        invoices.delivery_time,
        invoices.create_date,
        invoices.total_bill_amount,
        invoices.discount_type,
        invoices.discount,
        invoices.due,
        invoices.discount_percentage,
        invoices.refer_type,
        invoices.referre_id_or_desc,
        invoices.created_by_user_id,
        invoices.created_by_name,
        invoices.billingComment,
        invoices.sample_collection_remark,

        patients.org_patient_id AS patient_web_id,
        patients.name AS patient_name,
        patients.phone AS patient_phone,
        patients.age AS patient_age,
        patients.month AS patient_month,
        patients.day AS patient_day,
        patients.gender AS patient_gender_id,
        patients.blood_group AS patient_blood_group_id,
        patients.address AS patient_address,
        patients.date_of_birth AS patient_dob,
        patients.visit_type AS patient_visit_type,
        patients.hn_number AS patient_hn_number,
        patients.create_date AS patient_create_date,

        invoice_details.test_id,
        invoice_details.inventory_id,
        invoice_details.qty,
        invoice_details.fee,
        invoice_details.is_refund,
        inventory.name AS inventory_name,
        inventory.price AS inventory_price,
        invoice_details.is_offline_sync,
        invoice_details.collection_date,
        invoice_details.collector_id,
        invoice_details.collector_name,
        invoice_details.booth_id,
        invoice_details.collection_status,
        invoice_details.remark,


        payments.id AS payment_id,
        payments.web_id AS payment_web_id,
        payments.money_receipt_number,
        payments.money_receipt_type,
        payments.payment_type,
        payments.amount AS payment_amount,
        payments.requested_amount AS requested_amount,
        payments.total_amount_paid AS total_amount_paid,
        payments.due_amount AS due_amount,
        payments.new_discount AS due_amount,
        payments.payment_date

    FROM invoices
    LEFT JOIN patients
      ON (invoices.patient_id = patients.id OR invoices.webId = patients.org_patient_id)
    LEFT JOIN invoice_details 
      ON invoices.invoice_number = invoice_details.invoice_id
    LEFT JOIN inventory 
      ON invoice_details.inventory_id = inventory.webId
    LEFT JOIN payments 
      ON invoices.invoice_number = payments.invoice_number
    LEFT JOIN test_names 
      ON invoice_details.test_id = test_names.org_test_name_id
    WHERE 
      invoices.webId IS NULL
      OR invoices.invoice_number IN (
        SELECT DISTINCT invoice_number
        FROM payments
        WHERE web_id IS NULL
      )
      OR invoices.invoice_number IN (
        SELECT DISTINCT invoice_id
        FROM invoice_details
        WHERE is_offline_sync = 1
      );


     
    ''');

      final Map<String, Map<String, dynamic>> invoiceMapByNumber = {};

      for (final row in result) {
        final invoiceNumber = row['invoice_number'] as String;
        final invoiceId = row['invoice_id'] as int;

        final current = invoiceMapByNumber.putIfAbsent(
            invoiceNumber,
            () => {
                  'invoice_id': invoiceId,
                  'web_id': row['invoice_web_id'],
                  'invoice_number': invoiceNumber,
                  'delivery_date': row['delivery_date'],
                  'delivery_time': row['delivery_time'],
                  'create_date': row['create_date'],
                  'created_by_user_id': row['created_by_user_id'],
                  'created_by_name': row['created_by_name'],
                  'billingComment': row['billingComment'],
                  'sample_collection_remark': row['sample_collection_remark'],
                  'due': double.tryParse(row['due']?.toString() ?? '0') ?? 0.0,
                  'total_bill_amount': double.tryParse(
                          row['total_bill_amount']?.toString() ?? '0') ??
                      0.0,
                  'discount_type': row['discount_type'],
                  'discount':
                      double.tryParse(row['discount']?.toString() ?? '0') ??
                          0.0,
                  'discount_percentage': double.tryParse(
                          row['discount_percentage']?.toString() ?? '0') ??
                      0.0,
                  'refer_type': row['refer_type'],
                  'referre_id_or_desc': row['referre_id_or_desc'],
                  'branch_id': branchId,
                  'branch': branchName,
                  'patient': {
                    'web_id': row['patient_web_id'],
                    'name': row['patient_name'],
                    'phone': row['patient_phone'],
                    'age': row['patient_age'],
                    'month': row['patient_month'],
                    'day': row['patient_day'],
                    'visit_type': row['patient_visit_type'],
                    'gender': row['patient_gender_id'],
                    'bloodGroup': row['patient_blood_group_id'],
                    'address': row['patient_address'],
                    'dateOfBirth': row['patient_dob'],
                    'hn_number': row['patient_hn_number'],
                    'create_date': row['patient_create_date'],
                  },
                  'invoice_details': <Map<String, dynamic>>[],
                  'inventory': <Map<String, dynamic>>[],
                  'money_receipts': <Map<String, dynamic>>[],
                });

        final detailList = current['invoice_details'] as List;
        final inventoryList = current['inventory'] as List;
        final paymentsList = current['money_receipts'] as List;

        // Test details
// Deduplicate test_id
        if (row['test_id'] != null) {
          final testId = row['test_id'];
          final isRefund = row['is_refund'];
          final collectionDate = row['collection_date'];
          final collectorId = row['collector_id'];
          final boothId = row['booth_id'];
          final collectionStatus = row['collection_status'];
          final collectorName = row['collector_name'];

          final exists = detailList.any((item) => item['test_id'] == testId);

          if (!exists) {
            detailList.add({
              'test_id': testId,
              'is_refund': isRefund,
              'collection_date': collectionDate,
              'collector_id': collectorId,
              'booth_id': boothId ,
              'collection_status': collectionStatus,
              'collector_name': collectorName,
            });
          }
        }

        if (row['inventory_id'] != null) {
          final inventoryId = row['inventory_id'];
          final exists = inventoryList.any((item) => item['id'] == inventoryId);

          if (!exists) {
            inventoryList.add({
              'id': inventoryId,
              'quantity': row['qty'],
              'price': row['inventory_price'],
              'name': row['inventory_name'] ?? '',
            });
          }
        }

        // Payment details
        if (row['payment_id'] != null) {
          final alreadyExists = paymentsList.any(
              (p) => p['payment_id'] == row['payment_id']);
          if (!alreadyExists && row['payment_id'] != null) {
            paymentsList.add({
              'payment_id': row['payment_id'],
              'm_web_id': row['payment_web_id'],
              'money_receipt_number': row['money_receipt_number'],
              'money_receipt_type': row['money_receipt_type'],
              'paid_amount':
                  double.tryParse(row['payment_amount']?.toString() ?? '0') ??
                      0.0,
              'new_discount':
                  double.tryParse(row['new_discount']?.toString() ?? '0') ??
                      0.0,
              'total_amount_paid': double.tryParse(
                      row['total_amount_paid']?.toString() ?? '0') ??
                  0.0,
              'requested_amount':
                  double.tryParse(row['requested_amount']?.toString() ?? '0') ??
                      0.0,
            });
          }
        }
      }

      // Calculate paid and due for each invoice
      for (final invoice in invoiceMapByNumber.values) {
        final payments = invoice['money_receipts'] as List;
        final paidAmount =
            payments.fold(0.0, (sum, p) => sum + (p['paid_amount'] ?? 0.0));
        final total = invoice['total_bill_amount'] ?? 0.0;
        (total - paidAmount).clamp(0, total);

        invoice['paid_amount'] = paidAmount;
        // invoice['due'] = due;
      }

      debugPrint("fetching invoice details: ${invoiceMapByNumber.values}");
      return invoiceMapByNumber.values
          .map((map) => InvoiceUnSyncModel.fromJson(map))
          .toList();
    } catch (e, s) {
      debugPrint("❌ Error fetching invoice details: $e\nStack: $s");
      throw Exception("Failed to fetch invoice details: $e");
    }
  }

  Future<InvoiceLocalModel> fetchInvoiceDetails(String invoiceId) async {

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
      invoices.billingComment,

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
      
      creator_user.name AS creator_name,
      creator_user.email AS creator_email,
      creator_user.phone AS creator_phone,


      payments.id AS payment_id,
      payments.payment_type,
      payments.amount AS payment_amount,
      payments.payment_date

    FROM invoices
   LEFT JOIN patients p_local
    ON invoices.patient_id = p_local.id
    OR invoices.patient_web_id = p_local.org_patient_id
  
      LEFT JOIN genders ON p_local.gender = genders.original_id
      LEFT JOIN blood_groups ON p_local.blood_group = blood_groups.original_id
      LEFT JOIN invoice_details ON invoices.invoice_number = invoice_details.invoice_id
      LEFT JOIN test_names ON invoice_details.test_id = test_names.org_test_name_id
      LEFT JOIN payments ON invoices.invoice_number = payments.invoice_number
      LEFT JOIN users AS creator_user ON invoices.created_by_user_id = creator_user.saas_user_id
  
      LEFT JOIN inventory ON invoice_details.inventory_id = inventory.webId
        LEFT JOIN doctors
          ON invoices.refer_type = 'Doctor'
          AND invoices.referre_id_or_desc GLOB '[0-9]*'
          AND CAST(invoices.referre_id_or_desc AS INTEGER) = doctors.org_doctor_id
        WHERE invoices.invoice_number = ?
    ''', [invoiceId]);

      if (result.isEmpty) {
        throw Exception('Invoice not found');
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
            'billingComment': row['billingComment'],
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
          final detail = {
            'type': isTest ? 'Test' : 'Inventory',
            'test_id': testId,
            'inventory_id': inventoryId,
            'test_name': row['test_name'],
            'test_code': row['test_code'],
            'inventory_name': row['inventory_name'],
            'fee': double.tryParse(row['detail_fee']?.toString() ?? '0') ?? 0.0,
            'qty': row['detail_qty'] != null
                ? int.tryParse(row['detail_qty'].toString()) ?? 1
                : 1, // fallback to 1 if null
            'discount_applied': row['discount_applied'],
            'detail_discount': parseDouble(row['detail_discount']),
          };

          (invoiceMap['invoice_details'] as List).add(detail);
          invoiceDetailSet.add(detailKey);
        }
      }

      debugPrint("invoiceMap : $invoiceMap");
      return InvoiceLocalModel.fromMap(invoiceMap);
    } catch (e, s) {
      debugPrint("Error fetching invoice details: $e\nStackTrace: $s");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> managePatientAndInvoice({
    required bool isUpdate,
    String? patientID,
    String? patientWebId,
    required String name,
    required String phone,
    required String age,
    required String day,
    required String month,
    required String dob,
    required String gender,
    required String visitType,
    String bloodGroup = '',
    String address = '',

    // Invoice parameters
    required String referredBy,
    required String referredById,
    required String deliveryDate,
    required String deliveryTime,
    required String totalAmount,
    required String discount,
    required String discountPercentage,
    required String paymentMethod,
    required String discountType,
    required String paidAmount,
    required String billingComment,
    required List<Map<String, dynamic>> testItems,
  }) async {
    final db = await dbHelper.database;
    final token = await LocalDB.getLoginInfo();
    final now = DateTime.now().toLocal();
    final isoNow = now.toIso8601String();

    try {
      db.execute('BEGIN TRANSACTION');

      int effectivePatientId;

      // Patient handling
      if (isUpdate) {
        if (patientID == null) {
          throw Exception('Patient ID required for update');
        }
        final existing = db.select(
          'SELECT id FROM patients WHERE id = ? LIMIT 1',
          [patientID],
        );
        if (existing.isEmpty) {
          db.execute('ROLLBACK');
          return {
            'status': 'error',
            'message': 'Patient not found',
            'timestamp': isoNow,
          };
        }

        db.execute('''
        UPDATE patients SET
          name = ?, phone = ?, age = ?, month = ?, day = ?,
          gender = ?, blood_group = ?, address = ?, date_of_birth = ?, visit_type = ?
        WHERE id = ?
      ''', [
          name,
          phone,
          age,
          month,
          day,
          gender,
          bloodGroup,
          address,
          dob,
          visitType,
          patientID,
        ]);

        effectivePatientId = int.parse(patientID);
      } else {
        db.execute('''
        INSERT INTO patients (
          name, phone, age, month, day, gender, blood_group, address, date_of_birth, visit_type
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
          name,
          phone,
          age,
          month,
          day,
          gender,
          bloodGroup,
          address,
          dob,
          visitType,
        ]);

        effectivePatientId = db.lastInsertRowId;
      }

      // Generate invoice number
      String generateInvoiceNumber() {
        final now = DateTime.now();
        final millis = now.millisecondsSinceEpoch.toString();
        final timePart = millis.substring(millis.length - 4);
        final randPart = (Random().nextInt(900) + 100).toString();
        return 'APP$timePart$randPart';
      }

      // Generate money receipt number
      String generateReceiptNumber() {
        final date = DateFormat('MMddHHmm')
            .format(DateTime.now()); // MMddHHmm = 8 digits
        final random = Random().nextInt(900) + 100; // 3-digit random
        return 'MR$date$random';
      }

      final invoiceNumber = generateInvoiceNumber();
      final moneyReceiptNumber = generateReceiptNumber();

      final total = double.tryParse(totalAmount) ?? 0.0;
      final paid = double.tryParse(paidAmount) ?? 0.0;
      final disc = double.tryParse(discount) ?? 0.0;
      final due = total - paid - disc;
      final discountPerc = double.tryParse(discountPercentage) ?? 0.0;

      // Create invoice
      db.execute('''
      INSERT INTO invoices (
        patient_id, patient_web_id, invoice_number,invoice_number_local, update_date, delivery_date, delivery_time, create_date,
        total_bill_amount, due, paid_amount,
        discount_type, discount,
        refer_type, referre_id_or_desc, discount_percentage,
        created_by_user_id, created_by_name,billingComment
      ) VALUES (?, ?, ?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)
    ''', [
        effectivePatientId,
        patientWebId,
        invoiceNumber,
        invoiceNumber,
        isoNow,
        deliveryDate,
        deliveryTime,
        isoNow,
        total,
        due,
        paid,
        discountType,
        disc,
        referredBy,
        referredById,
        discountPerc,
        token?['userId'],
        token?['userName'],
        billingComment
      ]);

      final invoiceId = db.lastInsertRowId;

      // Add test/inventory items
      for (final item in testItems) {
        final type = item['type'] ?? 'Test';
        final testId = (type == 'Test') ? (item['id'] ?? 0) : null;
        final inventoryId = (type == 'Inventory') ? (item['id'] ?? 0) : null;
        final fee = double.tryParse(item['rate'].toString()) ?? 0.0;
        final qty = int.tryParse(item['qty'].toString()) ?? 1;
        final itemDiscount =
            double.tryParse(item['discountPercentage'].toString()) ?? 0.0;
        final discountApplied =
            double.tryParse(item['discountApplied'].toString()) ?? 0.0;

        db.execute('''
    INSERT INTO invoice_details (
      invoice_id, invoice_number_local,test_id, fee, qty, is_refund, discount_applied, discount, inventory_id
    ) VALUES (?, ?, ?,?, ?, ?, ?, ?, ?)
  ''', [
          invoiceNumber,
          invoiceNumber,
          testId != 0 ? testId : null,
          fee,
          qty,
          0,
          discountApplied,
          itemDiscount,
          inventoryId,
        ]);
      }


      db.execute('''
  INSERT INTO payments (
    patient_id, patient_web, invoice_number, invoice_number_local, invoice_id,
    payment_type, amount, payment_date,
    money_receipt_number, requested_amount, total_amount_paid, due_amount, money_receipt_type
  ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ON CONFLICT(money_receipt_number) DO UPDATE SET
    patient_id=excluded.patient_id,
    patient_web=excluded.patient_web,
    invoice_number=excluded.invoice_number,
    invoice_number_local=excluded.invoice_number_local,
    invoice_id=excluded.invoice_id,
    payment_type=excluded.payment_type,
    amount=excluded.amount,
    payment_date=excluded.payment_date,
    requested_amount=excluded.requested_amount,
    total_amount_paid=excluded.total_amount_paid,
    due_amount=excluded.due_amount,
    money_receipt_type=excluded.money_receipt_type
''', [
        effectivePatientId,
        patientID,
        invoiceNumber,
        invoiceNumber,
        invoiceId,
        paymentMethod,
        paid,
        isoNow,
        moneyReceiptNumber,
        total - disc,
        paid,
        due,
        "add"
      ]);

      db.execute('COMMIT');

      return {
        'status': 'success',
        'patientId': effectivePatientId,
        'invoiceId': invoiceId,
        'invoiceNumber': invoiceNumber,
        'moneyReceiptNumber': moneyReceiptNumber,
        'timestamp': isoNow,
      };
    } catch (e, s) {
      debugPrint("error $e stack $s");
      try {
        db.execute('ROLLBACK');
      } catch (_) {}
      return {
        'status': 'error',
        'message':
            'Failed to ${isUpdate ? 'update' : 'create'} patient and invoice: $e',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<Map<String, dynamic>> collectPartialPayment({
    required String invoiceId,
    required double collectedAmount,
    required double discount,
    required double totalTestPrice,
    required String paymentMethod,
  }) async {
    Database? db;
    bool transactionActive = false;

    try {
      db = await dbHelper.database;
      db.execute('BEGIN;');
      transactionActive = true;

      // Fetch current invoice details
      final invoiceResult = db.select(
        '''
      SELECT 
        due, 
        paid_amount, 
        invoice_number, 
        discount, 
        patient_id, 
        patient_web_id 
      FROM invoices 
      WHERE id = ?
      ''',
        [invoiceId],
      );

      if (invoiceResult.isEmpty) {
        throw Exception("Invoice with ID $invoiceId not found.");
      }

      final row = invoiceResult.first;
      final currentDue = (row['due'] as num?)?.toDouble() ?? 0.0;
      final currentPaid = (row['paid_amount'] as num?)?.toDouble() ?? 0.0;
      final currentDiscount = (row['discount'] as num?)?.toDouble() ?? 0.0;

      final invoiceNumber = row['invoice_number'] as String? ?? '';
      final patientId = row['patient_id'];
      final patientWebId = row['patient_web_id'];

      // Limit discount
      final actualDiscount = discount.clamp(0, currentDue);
      final remainingDue = currentDue - actualDiscount;

      if (collectedAmount > remainingDue) {
        throw Exception("Collected amount exceeds due after discount.");
      }

      final updatedPaid = currentPaid + collectedAmount;
      final updatedDue = remainingDue - collectedAmount;
      final totalDiscount = currentDiscount + actualDiscount;

      final now = DateTime.now();
      final nowStr = now.toIso8601String();

      // Generate money receipt number
      String generateReceiptNumber() {
        final date = DateFormat('MMddHHmm')
            .format(DateTime.now()); // MMddHHmm = 8 digits
        final random = Random().nextInt(900) + 100; // 3-digit random
        return 'MR$date$random';
      }

      final moneyReceiptNumber = generateReceiptNumber();

// Calculate discount percentage
      double discountPercentage = 0.0;
      if (totalTestPrice > 0) {
        discountPercentage = (totalDiscount / totalTestPrice) * 100;
      }

// Optional: Print for debugging
      debugPrint("🧾 Invoice ID: $invoiceId");
      debugPrint("🧪 Total Test Price: $totalTestPrice");
      debugPrint("💸 Total Discount: $totalDiscount");
      debugPrint(
          "📊 Discount Percentage: ${discountPercentage.toStringAsFixed(2)}%");

// Update invoice
      db.execute(
        '''
  UPDATE invoices
  SET due = ?, 
      paid_amount = ?, 
      discount = ?, 
      discount_percentage = ?,
      update_date = ?
  WHERE id = ?
  ''',
        [
          updatedDue,
          updatedPaid,
          totalDiscount,
          discountPercentage.toStringAsFixed(2),
          nowStr,
          invoiceId
        ],
      );

      // Insert into payments

      db.execute(
        '''
  INSERT INTO payments (   
    money_receipt_number,
    money_receipt_type,
    patient_id,
    patient_web,
    invoice_number,
    invoice_id,
    payment_type,
    requested_amount,
    total_amount_paid,
    due_amount,
    new_discount,
    amount,
    payment_date,
    is_sync
  ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ''',
        [
          moneyReceiptNumber, // 1
          'due', // 2
          patientId, // 3
          patientWebId, // 4
          invoiceNumber, // 5
          invoiceId, // 6
          paymentMethod, // 7
          currentDue, // 8
          updatedPaid, // 9
          updatedDue, // ✅ 10 due_amount (you need to define this!)
          actualDiscount, // 11
          collectedAmount, // 12
          nowStr, // 13
          0 // 14
        ],
      );


      db.execute('COMMIT;');

      return {
        'status': 'success',
        'invoiceId': invoiceId,
        'collectedAmount': collectedAmount,
        'discountApplied': actualDiscount,
        'paymentMethod': paymentMethod,
        'receiptNumber': moneyReceiptNumber,
        'timestamp': nowStr,
      };
    } catch (e, stack) {
      debugPrint("❌ Error collecting payment: $e\n$stack");

      if (transactionActive && db != null) {
        db.execute('ROLLBACK;');
      }

      return {
        'status': 'error',
        'message': 'Failed to collect partial payment: $e',
        'invoiceId': invoiceId,
        'collectedAmount': collectedAmount,
        'discountApplied': discount,
        'paymentMethod': paymentMethod,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
