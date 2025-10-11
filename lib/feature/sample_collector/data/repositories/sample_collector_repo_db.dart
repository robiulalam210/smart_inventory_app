import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/database_info.dart';
import '../../../../core/utilities/app_date_time.dart';
import '../model/sample_collector_model.dart';

class SampleCollectorRepoDb {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<Map<String, dynamic>?> fetchTestInfo(int testId) async {
    final db = await dbHelper.database;

    // 1. Main test info
    final testResult = db.select(
      'SELECT * FROM test_names WHERE org_test_name_id = ?',
      [testId],
    );

    if (testResult.isEmpty) return null;
    final testData = testResult.first;

    // 2. Test category (with group id)
    final categoryResult = db.select(
      '''
    SELECT id, name AS test_category_name, test_group_id
    FROM test_categories 
    WHERE org_test_category_id = ?
    ''',
      [testData['test_category_id']],
    );

    Map<String, Object?>? category;
    Map<String, Object?>? group;

    if (categoryResult.isNotEmpty) {
      category = categoryResult.first;

      // 3. Test group
      if (category['test_group_id'] != null) {
        final groupResult = db.select(
          'SELECT id, test_group_name FROM test_groups WHERE id = ?',
          [category['test_group_id']],
        );
        if (groupResult.isNotEmpty) {
          group = groupResult.first;
        }
      }
    }

    // 4. Return structured map
    return {
      'id': testData['id'],
      'org_test_name_id': testData['org_test_name_id'],
      'name': testData['name'],
      'code': testData['code'],
      'fee': (testData['fee'] as num?)?.toDouble() ?? 0.0,
      'discountApplied': testData['discount_applied'],
      'discount': (testData['discount'] as num?)?.toDouble() ?? 0.0,
      'testCategoryId': testData['test_category_id'],
      'testCategory': category != null
          ? {
              'id': category['id'],
              'name': category['test_category_name'],
            }
          : null,
      'testGroup': group != null
          ? {
              'id': group['id'],
              'name': group['test_group_name'],
            }
          : null,
    };
  }

  Future<SampleCollectorInvoiceList> fetchInvoicesWithSample({
    String? search,
    DateTime? from,
    DateTime? to,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      // Validate and sanitize inputs
      final safePageSize = pageSize.clamp(1, 100);
      final safePageNumber = max(1, pageNumber);
      final offset = (safePageNumber - 1) * safePageSize;

      final whereClauses = <String>[];
      final args = <dynamic>[];

      // Search filter with parameterized query
      if (search != null && search.trim().isNotEmpty) {
        final sanitizedSearch = search.trim();
        whereClauses.add(
          "(invoices.invoice_number LIKE ? OR p_local.name LIKE ?)",
        );
        args.addAll(['%$sanitizedSearch%', '%$sanitizedSearch%']);
      }

      // Date filters with proper formatting
      final dateFormat = DateFormat('yyyy-MM-dd');
      if (from != null) {
        whereClauses.add(
          "DATE(COALESCE(invoices.create_date_at_web, invoices.create_date)) >= DATE(?)",
        );
        args.add(dateFormat.format(from));
      }
      if (to != null) {
        whereClauses.add(
          "DATE(COALESCE(invoices.create_date_at_web, invoices.create_date)) <= DATE(?)",
        );
        args.add(dateFormat.format(to));
      }

      final whereClause =
          whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';
      final db = await dbHelper.database;

      // Count total for pagination
      final countResult = db.select('''
      SELECT COUNT(DISTINCT invoices.id) as totalCount
      FROM invoices
      LEFT JOIN patients p_local ON invoices.patient_id = p_local.id OR invoices.patient_web_id = p_local.org_patient_id
      $whereClause
    ''', args);

      final totalCount = countResult.isNotEmpty
          ? (countResult.first['totalCount'] as int?) ?? 0
          : 0;

      // Main query with inventory parts removed
      final result = db.select('''
      WITH paginated_invoices AS (
        SELECT invoices.* FROM invoices
        LEFT JOIN patients p_local ON invoices.patient_id = p_local.id OR invoices.patient_web_id = p_local.org_patient_id
        $whereClause
        ORDER BY invoices.id DESC
        LIMIT ? OFFSET ?
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
        
        invoices.collection_status,
        invoices.sent_to_lab_status,
        invoices.delivery_status,
        invoices.report_collection_status,

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
        invoice_details.fee AS detail_fee,
        invoice_details.qty AS detail_qty,
        invoice_details.discount AS detail_discount,
        invoice_details.discount_applied,
        
        invoice_details.collection_date,
        invoice_details.collector_id,
        invoice_details.collection_status as details_collection_status,
        invoice_details.remark,
        invoice_details.report_confirmed_status,
        invoice_details.report_approve_status,
        invoice_details.report_add_status,
        invoice_details.delivery_status,
        invoice_details.sent_to_lab_status,
        invoice_details.reportCollectionStatus,
        invoice_details.point,
        invoice_details.point_percent,
        invoice_details.is_refund,
       
        
        /* Collector fields */
        collectors.id AS collector_id,
        collectors.name AS collector_name,
        collectors.phone AS collector_phone,
        collectors.email AS collector_email,
        collectors.address AS collector_address,
        
        /* Booth fields */
        booths.id AS booth_id,
        booths.name AS booth_name,
        booths.booth_no AS booth_number,
        booths.status AS booth_status,

        test_names.name AS test_name,
        test_names.code AS test_code,

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
      LEFT JOIN collectors ON invoice_details.collector_id = collectors.id
      LEFT JOIN booths ON invoice_details.booth_id = booths.id
      LEFT JOIN doctors
        ON invoices.refer_type = 'Doctor'
        AND CASE WHEN CAST(invoices.referre_id_or_desc AS INTEGER) IS NOT NULL 
             THEN CAST(invoices.referre_id_or_desc AS INTEGER) = doctors.org_doctor_id
             ELSE 0 END
      LEFT JOIN payments ON invoices.invoice_number = payments.invoice_number
      ORDER BY invoices.id DESC, payments.payment_date DESC
    ''', [...args, safePageSize, offset]);

      final invoicesMap = <int, Map<String, dynamic>>{};
      final uniqueReceipts = <String>{};

      for (final row in result) {
        final invoiceId = row['invoice_id'] as int?;
        if (invoiceId == null) continue;

        final invoiceNumber = row['invoice_number']?.toString() ?? '';
        if (invoiceNumber.isEmpty) continue;

        invoicesMap.putIfAbsent(invoiceId, () {
          final totalAmount = row['total_bill_amount'] is num
              ? (row['total_bill_amount'] as num).toDouble()
              : 0.0;
          final due = row['due'] is num ? (row['due'] as num).toDouble() : 0.0;
          final paid = row['recive_amount'] is num
              ? (row['recive_amount'] as num).toDouble()
              : 0.0;
          final discount = row['discount'] is num
              ? (row['discount'] as num).toDouble()
              : 0.0;

          return {
            'invoice_id': invoiceId,
            'invoice_number': invoiceNumber,
            'update_date': row['update_date']?.toString(),
            'delivery_date': row['delivery_date']?.toString(),
            'delivery_time': row['delivery_time']?.toString(),
            'create_date': parseDate(row['create_date_at_web']?.toString())
                    ?.toIso8601String() ??
                parseDate(row['create_date']?.toString())?.toIso8601String() ??
                DateTime.now().toIso8601String(),
            'created_by_user_id': row['created_by_user_id'],
            'created_by_name': row['created_by_name']?.toString(),
            'total_bill_amount': totalAmount,
            'due': due,
            'paid_amount': paid,
            'discount_type': row['discount_type']?.toString(),
            'discount': discount,
            'discount_percentage': row['discount_percentage'] is num
                ? (row['discount_percentage'] as num).toDouble()
                : 0.0,
            'refer_type': row['refer_type']?.toString(),
            'referre_id_or_desc': row['referre_id_or_desc']?.toString(),
            'patient_web_id': row['patient_web_id']?.toString(),
            'collection_status': row['collection_status']?.toString(),
            'sent_to_lab_status': row['sent_to_lab_status']?.toString(),
            'delivery_status': row['delivery_status']?.toString(),
            'report_collection_status':
                row['report_collection_status']?.toString(),
            'collector_id': row['collector_id'] as int?,
            'collection_date': row['collection_date']?.toString(),
            'remark': row['remark']?.toString(),
            'patient': {
              'id': row['patient_id'] as int?,
              'web_id': row['patient_web_id']?.toString(),
              'name': row['patient_name']?.toString() ?? '',
              'phone': row['patient_phone']?.toString(),
              'age': row['patient_age'],
              'month': row['patient_month'],
              'day': row['patient_day'],
              'visit_type': row['patient_visit_type']?.toString(),
              'gender': row['patient_gender']?.toString(),
              'bloodGroup': row['patient_blood_group']?.toString(),
              'address': row['patient_address']?.toString(),
              'dateOfBirth': row['patient_dob']?.toString(),
              'hn_number': row['patient_hn_number']?.toString(),
              'create_date': row['patient_create_date']?.toString(),
            },
            'refer_info': (row['refer_type'] == 'Doctor' &&
                    row['referre_id_or_desc'] != null)
                ? {
                    'type': 'Doctor',
                    'value': row['referre_id_or_desc']?.toString() ?? '',
                    'id': row['doctor_id'] as int?,
                    'name': row['doctor_name']?.toString() ?? '',
                    'phone': row['doctor_phone']?.toString() ?? '',
                  }
                : {
                    'type': row['refer_type']?.toString() ?? '',
                    'value': row['referre_id_or_desc']?.toString() ?? '',
                    'id': null,
                    'name': null,
                    'phone': null,
                  },
            'payments': [],
            'invoice_details': [],
          };
        });

        final invoice = invoicesMap[invoiceId]!;
        final paymentsList = invoice['payments'] as List;

        // Process payments
        final receiptNumber =
            row['money_receipt_number']?.toString().trim() ?? '';
        if (receiptNumber.isNotEmpty) {
          final paymentDate = row['payment_date']?.toString();
          final paidAmount = row['paid_amount'] is num
              ? (row['paid_amount'] as num).toDouble()
              : 0.0;
          final requestedAmount = row['requested_amount'] is num
              ? (row['requested_amount'] as num).toDouble()
              : 0.0;
          final dueAmount = row['due_amount'] is num
              ? (row['due_amount'] as num).toDouble()
              : 0.0;

          final alreadyExists = paymentsList.any((p) =>
              p['money_receipt_number'] == receiptNumber &&
              p['payment_date'] == paymentDate &&
              p['amount'] == paidAmount);

          if (!alreadyExists) {
            paymentsList.add({
              'web_id': row['payment_web_id']?.toString(),
              'money_receipt_number': receiptNumber,
              'money_receipt_type': row['money_receipt_type']?.toString(),
              'patient_id': row['payment_patient_id'] as int?,
              'patient_web': row['payment_patient_web']?.toString(),
              'invoice_number': invoiceNumber,
              'invoice_id': row['payment_invoice_id'] as int?,
              'payment_type': row['payment_type']?.toString(),
              'amount': paidAmount,
              'requested_amount': requestedAmount,
              'due_amount': dueAmount,
              'payment_date': paymentDate,
              'is_sync': 1,
            });

            if (paidAmount > 0) {
              uniqueReceipts.add(receiptNumber);
            }
          }
        }

        // Process invoice details (only tests now)
        final testId = row['test_id'] as int?;
        final detailCollectorId = row['collector_id'] as int?;
        final detailId = row['detail_id'] as int?;

        if (testId != null) {
          final isRefund = row['is_refund'] == 1 || row['is_refund'] == true;
          if (isRefund) continue; // 🔹 skip refunded tests
          final detailList = invoice['invoice_details'] as List;
          final isDuplicateDetail =
              detailList.any((d) => d['test_id'] == testId);

          if (!isDuplicateDetail) {
            final fee = row['detail_fee'] is num
                ? (row['detail_fee'] as num).toDouble()
                : 0.0;
            final discount = row['detail_discount'] is num
                ? (row['detail_discount'] as num).toDouble()
                : 0.0;
            final report =
                await fetchLabReport(invoiceNumber, testId.toString());

            detailList.add({
              'detail_id': detailId, // <-- store PK for updates later

              'type': 'Test',
              'test_id': testId,
              'test_name': row['test_name']?.toString(),
              'test_info': await fetchTestInfo(testId) ?? {},
              'test_code': row['test_code']?.toString(),
              'fee': fee,
              'qty': row['detail_qty'] is int ? row['detail_qty'] as int : 1,
              'discount': discount,
              'collection_date': row['collection_date']?.toString(),
              'collector_id': detailCollectorId,

              'collection_status': row['details_collection_status']?.toString(),
              'collector': (detailCollectorId != null &&
                      row['collector_id'] == detailCollectorId)
                  ? {
                      'id': detailCollectorId,
                      'name': row['collector_name']?.toString(),
                      'phone': row['collector_phone']?.toString(),
                      'email': row['collector_email']?.toString(),
                      'address': row['collector_address']?.toString(),
                    }
                  : null,
              'booth': row['booth_id'] != null
                  ? {
                      'id': row['booth_id'] as int?,
                      'name': row['booth_name']?.toString(),
                      'booth_no': row['booth_number']?.toString(),
                      'status': row['booth_status']?.toString(),
                    }
                  : null,
              'remark': row['remark']?.toString(),
              'report_confirmed_status':
                  row['report_confirmed_status']?.toString(),
              'report_approve_status': row['report_approve_status']?.toString(),
              'report_add_status': row['report_add_status']?.toString(),
              'delivery_status': row['delivery_status']?.toString(),
              'sent_to_lab_status': row['sent_to_lab_status']?.toString(),
              'reportCollectionStatus':
                  row['reportCollectionStatus']?.toString(),
              'point': row['point']?.toString(),
              'point_percent': row['point_percent']?.toString(),
              'is_refund': row['is_refund'] == 1 || row['is_refund'] == true,
              'lab_report': report, // now it's LabReport? type
            });
          }
        }
      }
// After building invoicesMap completely

      debugPrint(invoicesMap.values.toString());
      final invoiceList = invoicesMap.values
          .where((invoiceMap) {
            final details = invoiceMap['invoice_details'] as List;
            if (details.isEmpty) return false; // skip invoices with no details
            final allRefunded = details.every((d) => d['is_refund'] == true);
            return !allRefunded; // keep only invoices with at least 1 non-refund detail
          })
          .map((invoiceMap) => SampleCollectorInvoice.fromMap(invoiceMap))
          .toList();

      return SampleCollectorInvoiceList(
        invoices: invoiceList,
        totalCount: totalCount,
        pageSize: safePageSize,
        pageNumber: safePageNumber,
        totalPages: (totalCount / safePageSize).ceil(),
      );
    } catch (e, stackTrace) {
      debugPrint("Error in : $e\n$stackTrace");
      throw Exception(
          "Failed to fetch invoices (page: $pageNumber, size: $pageSize). Error: ${e.toString()}");
    }
  }

  Future<LabReport?>? fetchLabReport(String invoiceNo, String testId) async {
    final db = await dbHelper.database;

    // 1️⃣ Fetch main report
    final reportResult = db.select('''
    SELECT * FROM lab_reports
    WHERE invoice_no = ? AND test_id = ?
    LIMIT 1
  ''', [invoiceNo, testId]);

    if (reportResult.isEmpty) return null;

    final reportRow = reportResult.first;

    // 2️⃣ Fetch test info
    final testResult = db.select(
      'SELECT * FROM test_names WHERE org_test_name_id = ?',
      [testId],
    );
    final testData = testResult.isNotEmpty ? testResult.first : null;

    // 3️⃣ Fetch specimen
    SampleSpecimen? specimen;
    if (testData != null && testData['specimen_id'] != null) {
      final specimenResult = db.select(
        'SELECT * FROM specimens WHERE id = ?',
        [testData['specimen_id']],
      );
      if (specimenResult.isNotEmpty) {
        specimen = SampleSpecimen.fromJson(specimenResult.first);
      }
    }

    // 4️⃣ Fetch report details
    final detailsResult = db.select('''
    SELECT rd.*, 
           p.parameter_name AS original_name, 
           p.parameter_unit AS original_unit, 
           p.reference_value,
           p.options,
           p.show_options
    FROM lab_report_details rd
    LEFT JOIN parameters p ON p.id = rd.parameter_id
    WHERE rd.report_id = ?
  ''', [reportRow['id']]);

    final details =
        detailsResult.map((row) => SampleDetail.fromJson(row)).toList();

    // 5️⃣ Fetch parameter groups
    final parameterGroupsResult = db.select(
      'SELECT * FROM parameter_groups WHERE test_name_id = ?',
      [testId],
    );

    final parameterGroups = parameterGroupsResult.map((group) {
      final parameters = db.select(
        'SELECT * FROM parameters WHERE parameter_group_id = ?',
        [group['id']],
      );
      return ReportParameterGroupSample.fromJson({
        ...group,
        'parameter': parameters,
      });
    }).toList();

    // 6️⃣ Construct LabReport
    final labReport = LabReport(
      id: reportRow['id'],
      saasBranchId: reportRow['saas_branch_id'],
      saasBranchName: reportRow['saas_branch_name'],
      invoiceId: reportRow['invoice_id'],
      invoiceNo: reportRow['invoice_no'],
      patientId: reportRow['patient_id'],
      testId: reportRow['test_id'],
      testName: reportRow['test_name'],
      testGroup: reportRow['test_group'],
      testCategory: reportRow['test_category'],
      gender: reportRow['gender'],
      technicianName: reportRow['technician_name'],
      technicianSign: reportRow['technician_sign'],
      validator: reportRow['validator'],
      reportConfirm: reportRow['report_confirm'],
      status: reportRow['status']?.toString() ?? '0',
      remark: reportRow['remark'],
      radiogyReportImage: reportRow['radiogyReportImage'],
      radiologyReportDetails: reportRow['radiologyReportDetails'],
      createdAt: reportRow['created_at'] != null
          ? DateTime.parse(reportRow['created_at'].toString())
          : null,
      updatedAt: reportRow['updated_at'] != null
          ? DateTime.parse(reportRow['updated_at'].toString())
          : null,
      specimen: specimen,
      details: details,
      parameterGroup: parameterGroups,
    );

    return labReport;
  }
  Future<int> updateSampleCollectionStatus({
    required List<int> invoiceDetailIds, // <-- use PKs, not testIds
    required int collectorId,
    required int boothId,
    required String collectionDate,
    required String collectorName, // new
    String? remark,
    required String status,
  }) async {
    try {
      final db = await dbHelper.database;

      if (invoiceDetailIds.isEmpty) {
        throw Exception("No invoiceDetailIds provided to update.");
      }

      final placeholders = List.filled(invoiceDetailIds.length, '?').join(',');

      // Update only those specific rows + set is_offline_sync = 1 + collector_name
      final stmt1 = db.prepare('''
      UPDATE invoice_details 
      SET collector_id = ?, 
          booth_id = ?, 
          collection_date = ?, 
          collection_status = ?, 
          remark = ?, 
          collector_name = ?, 
          is_offline_sync = 1
      WHERE id IN ($placeholders)
    ''');

      stmt1.execute([
        collectorId,
        boothId,
        collectionDate,
        status,
        remark,
        collectorName,
        ...invoiceDetailIds
      ]);
      stmt1.dispose();

      // Recalculate full invoice status
      final invoiceId = db
          .select('''
          SELECT invoice_id 
          FROM invoice_details 
          WHERE id = ? 
          LIMIT 1
        ''', [invoiceDetailIds.first])
          .first['invoice_id'];


      db.execute('''
      UPDATE invoices
      SET sample_collection_remark = ?
      WHERE invoice_number = ?
    ''', [remark ?? '', invoiceId]);
      final checkStmt = db.prepare('''
      SELECT COUNT(*) AS total, 
             SUM(CASE 
                   WHEN collector_id IS NOT NULL 
                        AND collection_date IS NOT NULL 
                        AND collection_status = '1' 
                   THEN 1 ELSE 0 
                 END) AS valid_count
      FROM invoice_details
      WHERE invoice_id = ?
    ''');

      final checkResult = checkStmt.select([invoiceId]).first;
      checkStmt.dispose();


      final total = checkResult['total'] as int;
      final validCount = checkResult['valid_count'] as int;

      // If all collected → return 1, otherwise 0
      return (total > 0 && total == validCount) ? 1 : 0;
    } catch (e, stackTrace) {
      debugPrint("Error updating sample collection status: $e\n$stackTrace");
      throw Exception("Failed to update collection status: ${e.toString()}");
    }
  }


}
