import 'package:flutter/cupertino.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../../core/database/database_info.dart';
import '../../../../core/utilities/app_date_time.dart';
import '../models/invoice_sync_response_model.dart';
import '../models/invoice_local_model.dart';

class TransactionRepoDb {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<InvoiceSyncResponseModel> fetchInvoicesWithSummary(
    String? search,
    DateTime? from,
    DateTime? to,
    int pageNumber,
    int pageSize,
  ) async {
    final whereClauses = <String>[];

    // Search filter
    if (search != null && search.isNotEmpty) {
      final escapedSearch = search.replaceAll("'", "''");
      whereClauses.add(
        "(invoices.invoice_number LIKE '%$escapedSearch%' OR p_local.name LIKE '%$escapedSearch%')",
      );
    }

    // Date filters
    if (from != null) {
      whereClauses.add(
        "DATE(COALESCE(invoices.create_date_at_web, invoices.create_date)) >= DATE('${from.toIso8601String()}')",
      );
    }
    if (to != null) {
      whereClauses.add(
        "DATE(COALESCE(invoices.create_date_at_web, invoices.create_date)) <= DATE('${to.toIso8601String()}')",
      );
    }

    final whereClause =
        whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';
    final db = await dbHelper.database;

    try {
      final safePageNumber = pageNumber < 1 ? 1 : pageNumber;
      final offset = (safePageNumber - 1) * pageSize;

      // 3️⃣ Fetch paginated invoice details with joins
      final result = db.select('''
  WITH paginated_invoices AS (
    SELECT invoices.* FROM invoices
    LEFT JOIN patients p_local ON invoices.patient_id = p_local.id OR invoices.patient_web_id = p_local.org_patient_id
    $whereClause
    ORDER BY invoices.id DESC
    LIMIT $pageSize OFFSET $offset
  )
  SELECT
    invoices.id AS invoice_id,
    invoices.invoice_number,
    invoices.webId,
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
    invoice_details.is_refund,

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
ORDER BY invoices.id DESC, payments.payment_date DESC
''');

      final Map<int, Map<String, dynamic>> invoicesMap = {};
      int totalRefundCount = 0;
      double totalRefundAmountSum = 0.0;

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

        // --- Payments ---
        // --- Payments ---
        final receiptNumberRaw = row['money_receipt_number'];
        final receiptTypeRaw = row['money_receipt_type'];
        final paidAmountRaw = row['paid_amount'];
        final dueAmountRaw = row['due_amount'];
        final requestedAmountRaw = row['requested_amount'];
        final paymentId = row['payment_id'];

        final requestedAmount =
            double.tryParse(requestedAmountRaw?.toString() ?? '0') ?? 0.0;
        final dueAmount =
            double.tryParse(dueAmountRaw?.toString() ?? '0') ?? 0.0;
        final receiptNumber = receiptNumberRaw?.toString().trim() ?? '';
        final receiptType = receiptTypeRaw?.toString().toLowerCase() ?? '';
        final paidAmount =
            double.tryParse(paidAmountRaw?.toString() ?? '0') ?? 0.0;
        final isRefundPayment = receiptType == 'refund';
        final alreadyExists =
            paymentsList.any((p) => p['payment_id'] == paymentId);

// Process payment if it doesn't already exist
        if (paymentId != null && !alreadyExists) {
          final paymentData = {
            'payment_id': row['payment_id'],
            'web_id': row['payment_web_id'],
            'money_receipt_number': isRefundPayment
                ? (receiptNumber.isNotEmpty
                    ? receiptNumber
                    : 'REFUND-$paymentId')
                : receiptNumber,
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
            'is_refund': isRefundPayment,
          };

          paymentsList.add(paymentData);

          // Track payment in summary statistics
          if (paidAmount > 0) {
            final uniqueKey =
                isRefundPayment ? 'refund-$paymentId' : receiptNumber;

            if (!uniqueReceipts.contains(uniqueKey)) {
              if (isRefundPayment) {
                totalRefundCount++;
                // totalRefundAmountSum += paidAmount;
              } else if (receiptType == 'due') {
                dueReceiptCount++;
                dueReceiptAmountSum += paidAmount;
              } else {
                paidReceiptCount++;
                paidReceiptAmountSum += paidAmount;
              }
              uniqueReceipts.add(uniqueKey);
            }
          }
        }

        // --- Invoice details + refunds ---
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
            final discountApplied = row['discount_applied'] == 1;
            final isRefund = row['is_refund'] == 1;

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
              'discount_applied': discountApplied,
              'is_refund': isRefund,
            });

            if (isRefund) {
              final discountPercentage =
                  (row['discount_percentage'] ?? 0.0) as double;
              final testDiscount = discount; // per-test discount

              double netFee;
              double netFeeAfterInvoiceDiscount;

              if (discountApplied) {
                netFee = fee - (fee * testDiscount / 100);
                netFeeAfterInvoiceDiscount =
                    netFee - (netFee * discountPercentage / 100);
              } else {
                netFee = fee;
                netFeeAfterInvoiceDiscount = netFee; // no discount applied
              }

              // Add to invoice totalRefund
              invoice['netAmountAfterRefund'] =
                  (invoice['netAmountAfterRefund'] as double? ?? 0) +
                      netFeeAfterInvoiceDiscount;

              // Update summary totals
              totalRefundAmountSum += netFeeAfterInvoiceDiscount;
              totalRefundCount += 1;
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

      // debugPrint(invoicesMap.values.toString());
      final invoiceList = invoicesMap.values
          .map((invoiceMap) => InvoiceModelSync.fromMap(invoiceMap))
          .toList();
      final summaryResult = db.select('''
  SELECT 
  COUNT(DISTINCT id) AS invoiceCount,
  COUNT(CASE WHEN paid_amount > 0 THEN 1 END) AS paidAmountCount,
  IFNULL(SUM(total_bill_amount), 0) AS total_amount,
  IFNULL(SUM(discount), 0) AS total_discount,
  IFNULL(SUM(paid_amount), 0) AS total_received,
  IFNULL(SUM(due), 0) AS total_due,
  IFNULL(SUM(
    CASE WHEN (total_bill_amount - discount - paid_amount) > 0 
         THEN (total_bill_amount - discount - paid_amount) 
         ELSE 0 END
  ), 0) AS due_collection
FROM invoices;
''');

      // debugPrint('Summary Result: $summaryResult');
      if (summaryResult.isEmpty) {
        throw Exception('No summary data found');
      }

      final summaryRow = summaryResult.isNotEmpty ? summaryResult.first : null;

      final totalAmountSum = (summaryRow?['total_amount'] ?? 0) as num;
      final totalDiscountSum = (summaryRow?['total_discount'] ?? 0) as num;
      final totalPaidSum = (summaryRow?['total_received'] ?? 0) as num;
      final totalDueSum = (summaryRow?['total_due'] ?? 0) as num;
      final paidAmountCount = (summaryRow?['paidAmountCount'] ?? 0) as int;
      final invoiceCount = (summaryRow?['invoiceCount'] ?? 0) as int;

      // 2️⃣ Count total for pagination
      final countResult = db.select('''
      SELECT COUNT(DISTINCT invoices.id) as totalCount
      FROM invoices
      LEFT JOIN patients p_local ON invoices.patient_id = p_local.id OR invoices.patient_web_id = p_local.org_patient_id
      $whereClause
    ''');

      final totalCount =
          countResult.isNotEmpty ? countResult.first['totalCount'] as int : 0;

      // --- Summary including refund totals ---
      final summary = {
        'invoiceCount': invoiceCount,
        'totalAmount': totalAmountSum.toDouble(),
        'totalDiscount': totalDiscountSum.toDouble(),
        'netAmount': totalAmountSum.toDouble() - totalDiscountSum.toDouble(),
        'totalPaid': totalPaidSum.toDouble(),
        'totalDue': totalDueSum.toDouble(),
        'receiptCount': paidAmountCount,
        'refundCount': totalRefundCount,
        'refundAmount': totalRefundAmountSum.toDouble(),
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
        'totalCount': totalCount,
        'pageSize': pageSize,
        'pageNumber': safePageNumber,
        'totalPages': (totalCount / pageSize).ceil(),
      });
    } catch (e, s) {
      debugPrint("Error fetching invoices with summary: $e\n$s");
      throw Exception("Failed to fetch invoices with summary: $e");
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

  Future<InvoiceLocalModel> fetchMoneyReceiptDetails(
    String moneyReceiptNumber, {
    bool isRefund = false,
  }) async {
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
        payments.due_amount,

        payments.total_amount_paid,
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
        invoice_details.is_refund AS detail_is_refund,

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

      LEFT JOIN genders ON p_local.gender = genders.original_id
      LEFT JOIN blood_groups ON p_local.blood_group = blood_groups.original_id
      LEFT JOIN invoice_details ON invoices.invoice_number = invoice_details.invoice_id
        ${isRefund ? "AND invoice_details.is_refund = 1" : ""}
      LEFT JOIN test_names ON invoice_details.test_id = test_names.org_test_name_id
      LEFT JOIN payments ON payments.invoice_number = invoices.invoice_number
      LEFT JOIN users AS creator_user ON invoices.created_by_user_id = creator_user.saas_user_id
      LEFT JOIN inventory ON invoice_details.inventory_id = inventory.webId
      LEFT JOIN doctors
        ON invoices.refer_type = 'Doctor'
        AND invoices.referre_id_or_desc GLOB '[0-9]*'
        AND CAST(invoices.referre_id_or_desc AS INTEGER) = doctors.org_doctor_id
  WHERE (payments.money_receipt_number = ? OR (payments.id = ? AND payments.money_receipt_type = 'refund'))
    ${isRefund ? "AND payments.money_receipt_type = 'refund'" : ""}
''', [moneyReceiptNumber, moneyReceiptNumber]);

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
            'due': parseDouble(row['due_amount']),
            'paid_amount': parseDouble(row['total_amount_paid']),
            'discount_type': row['discount_type'],
            'discount': parseDouble(row['discount']),
            'discount_percentage': parseDouble(row['discount_percentage']),
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
                    'value': row['referre_id_or_desc'] ?? row['refer_type'],
                  },
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
            'qty': row['qty'] != null
                ? int.tryParse(row['qty'].toString()) ?? 1
                : 1,
            'discount_applied': row['discount_applied'],
            'detail_discount': parseDouble(row['detail_discount']),
            'is_refund': row['detail_is_refund'] == 1,
          };

          (invoiceMap['invoice_details'] as List).add(detail);
          invoiceDetailSet.add(detailKey);
        }

        // Payments
        (invoiceMap['payments'] as List).add({
          'amount': parseDouble(row['payment_amount']),
          'payment_type': row['payment_type'],
          'payment_date': row['payment_date'],
          'is_refund': isRefund,
        });
      }

      debugPrint("invoice single : $invoiceMap");
      return InvoiceLocalModel.fromMap(invoiceMap);
    } catch (e, s) {
      debugPrint("Error fetching invoice details: $e\nStackTrace: $s");
      rethrow;
    }
  }

  Future<void> updateInvoiceAfterRefund(
    String invoiceNumber, {
    bool isFullRefund = false,
    List<int> refundTestIds = const [],
  }) async {
    final db = await dbHelper.database;

    try {
      db.execute('BEGIN TRANSACTION');

      // 1️⃣ Fetch invoice
      final invoiceRows = db.select('''
      SELECT total_bill_amount, paid_amount, due, discount, discount_type,
             patient_id, patient_web_id, id
      FROM invoices
      WHERE invoice_number = ?
    ''', [invoiceNumber]);

      if (invoiceRows.isEmpty) throw Exception('Invoice not found');

      final invoice = invoiceRows.first;
      double paidAmount = (invoice['paid_amount'] as num?)?.toDouble() ?? 0.0;
      double dueAmount = (invoice['due'] as num?)?.toDouble() ?? 0.0;
      double totalBillAmount =
          (invoice['total_bill_amount'] as num?)?.toDouble() ?? 0.0;
      double discount = (invoice['discount'] as num?)?.toDouble() ?? 0.0;
      String discountType = invoice['discount_type'] ?? "fixed";
      String patientId = invoice['patient_id'] ?? "";
      String patientWebId = invoice['patient_web_id'] ?? "";
      int invoiceId = invoice['id'];

      double totalRefund = 0.0;

      if (isFullRefund) {
        // 2️⃣ Calculate net total after invoice-level discount
        double netTotal;
        if (discountType == "percent") {
          netTotal = totalBillAmount - (totalBillAmount * discount / 100);
        } else {
          netTotal = totalBillAmount - discount;
        }
        totalRefund = netTotal;
        final checkRows = db.select(
          'SELECT id, invoice_id, is_refund FROM invoice_details WHERE invoice_id = ?',
          [invoiceNumber],
        );
        debugPrint("Invoice details before refund: $checkRows");

        // 3️⃣ Mark all tests refunded
        db.execute('''
        UPDATE invoice_details
        SET is_refund = 1
        WHERE invoice_id = ?
      ''', [invoiceNumber]);
      } else {
        // 2️⃣ Partial refund - fetch selected tests
        String testFilter = 'AND test_id IN (${refundTestIds.join(',')})';

        final refundRows = db.select('''
        SELECT fee, discount_applied, discount
        FROM invoice_details
        WHERE invoice_id = ? $testFilter
      ''', [invoiceNumber]);

        for (final row in refundRows) {
          double fee = (row['fee'] as num?)?.toDouble() ?? 0.0;
          int discountApplied = (row['discount_applied'] as int?) ?? 0;
          double testDiscount = (row['discount'] as num?)?.toDouble() ?? 0.0;

          double netFee =
              discountApplied == 1 ? fee - (fee * testDiscount / 100) : fee;

          totalRefund += netFee;
        }

        // Apply invoice-level discount proportionally to refunded tests
        if (discount > 0) {
          if (discountType == "percent") {
            totalRefund = totalRefund - (totalRefund * discount / 100);
          } else {
            // distribute fixed discount proportionally
            double discountRatio = totalRefund / totalBillAmount;
            totalRefund = totalRefund - (discount * discountRatio);
          }
        }

        // 3️⃣ Mark only selected tests refunded
        db.execute('''
        UPDATE invoice_details
        SET is_refund = 1
        WHERE invoice_id = ? $testFilter
      ''', [invoiceNumber]);
      }

      // 4️⃣ Adjust due & paid
      double remainingRefund = totalRefund;

      double appliedToDue = remainingRefund.clamp(0.0, dueAmount);
      double newDue = dueAmount - appliedToDue;
      remainingRefund -= appliedToDue;

      double appliedToPaid = remainingRefund.clamp(0.0, paidAmount);
      double newPaid = paidAmount - appliedToPaid;

      // 5️⃣ Update invoice
      db.execute('''
      UPDATE invoices
      SET due = ?, paid_amount = ?
      WHERE invoice_number = ?
    ''', [newDue, newPaid, invoiceNumber]);

      final nowStr = DateTime.now().toIso8601String();

      db.execute('''
      INSERT INTO payments (
        money_receipt_type,
        patient_id,
        patient_web,
        invoice_number,
        invoice_id,
        payment_type,
        requested_amount,
        due_amount,
        amount,
        payment_date,
        is_sync
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?,  ?)
    ''', [
        'refund',
        patientId,
        patientWebId,
        invoiceNumber,
        invoiceId,
        'Cash',
        totalBillAmount - discount,
        newDue, // due left
        totalRefund, // actual refunded amount
        nowStr,
        0,
      ]);

      db.execute('COMMIT');
    } catch (e, stack) {
      debugPrint('Error updating invoice after refund: $e\n$stack');
      try {
        db.execute('ROLLBACK');
      } catch (_) {}
      rethrow;
    }
  }
}
