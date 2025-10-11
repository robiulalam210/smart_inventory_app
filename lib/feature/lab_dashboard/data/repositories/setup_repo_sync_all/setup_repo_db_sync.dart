import 'package:flutter/foundation.dart';

import '../../../../../core/database/database_info.dart';
import '../../../../../core/utilities/app_date_time.dart';
import '../../models/all_setup_model/all_invoice_setup_model.dart';
import '../../models/all_setup_model/all_setup_model.dart';

class SetupAllSyncRepo {
  final DatabaseHelper dbHelper;

  SetupAllSyncRepo(this.dbHelper);

  Future<void> syncTestCategories(List<SetupTestCategory> categories) async {
    final db = await dbHelper.database;
    db.execute('BEGIN TRANSACTION');
    try {
      for (final cat in categories) {
        db.execute('''
        INSERT INTO test_categories (org_test_category_id, name, test_group_id, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(org_test_category_id) DO UPDATE SET
          name = excluded.name,
          test_group_id = excluded.test_group_id,
          created_at = excluded.created_at,
          updated_at = excluded.updated_at;
      ''', [
          cat.id,
          cat.testCategoryName,
          cat.testGroupId, // ✅ now saved
          cat.createdAt,
          cat.updatedAt,
        ]);
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> syncTestNames(List<SetupTestName> testNames) async {
    final db = await dbHelper.database;

    // Start transaction
    db.execute('BEGIN TRANSACTION');

    try {
      // Prepare SQL with all columns you want to insert/update
      final stmt = db.prepare('''
      INSERT INTO test_names (
        test_category_id,
        org_test_name_id,
        name,
        code,
        fee,
        discount_applied,
        discount,
        test_group_id,
        test_sub_category_id,
        specimen_id,
        created_at,
        test_category_name,
        test_group_name,
        test_sub_category_name
      )
      VALUES (?, ?, ?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(org_test_name_id) DO UPDATE SET
        test_category_id=excluded.test_category_id,
        name=excluded.name,
        code=excluded.code,
        fee=excluded.fee,
        discount_applied=excluded.discount_applied,
        discount=excluded.discount,
        test_group_id=excluded.test_group_id,
        test_sub_category_id=excluded.test_sub_category_id,
        specimen_id=excluded.specimen_id,
        created_at=excluded.created_at,
        test_category_name=excluded.test_category_name,
        test_group_name=excluded.test_group_name,
        test_sub_category_name=excluded.test_sub_category_name
    ''');

      for (final test in testNames) {
        if (test.id == null) {
          debugPrint('Skipping test with null org_test_name_id: ${test.testName}');
          continue;
        }

        if (test.testCategoryId == null) {
          debugPrint('Skipping test with null test_category_id: ${test.testName}');
          continue;
        }

        stmt.execute([
          test.testCategoryId,
          test.id, // org_test_name_id
          test.testName ?? "",
          test.itemCode,
          test.fee,
          test.discountApplied ?? 0,
          test.discount ?? 0,
          test.testGroupId,
          test.testSubCategoryId,
          test.specimenId,
          test.createdAt,
          test.category?.testCategoryName,
          test.group?.testGroupName,
          test.subCategory?.testSubCategoryName,
        ]);
      }

      stmt.dispose();

      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> syncParameterGroups(List<SetupParameterGroup> setupPGroupList) async {
    final db = await dbHelper.database;

    db.execute('BEGIN TRANSACTION'); // start manual transaction

    try {
      for (final par in setupPGroupList) {
        db.execute('''
        INSERT INTO parameter_groups (
          id, test_name_id, group_name, hidden, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          test_name_id = excluded.test_name_id,
          group_name = excluded.group_name,
          hidden = excluded.hidden,
          created_at = excluded.created_at,
          updated_at = excluded.updated_at
      ''', [
          par.id,
          par.testNameId,
          par.groupName,
          par.hidden,
          par.createdAt,
          par.updatedAt,
        ]);
      }

      db.execute('COMMIT'); // commit only if no error
    } catch (e) {
      db.execute('ROLLBACK'); // rollback on failure
      rethrow;
    }
  }

  Future<void> syncParameters(List<SetupParameter> setupParameterList) async {
    final db = await dbHelper.database;

    db.execute('BEGIN TRANSACTION');
    try {
      for (final param in setupParameterList) {
        db.execute('''
        INSERT INTO parameters (
          id, test_id, parameter_name, parameter_unit, reference_value,
          show_options, options, parameter_group_id, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          test_id = excluded.test_id,
          parameter_name = excluded.parameter_name,
          parameter_unit = excluded.parameter_unit,
          reference_value = excluded.reference_value,
          show_options = excluded.show_options,
          options = excluded.options,
          parameter_group_id = excluded.parameter_group_id,
          created_at = excluded.created_at,
          updated_at = excluded.updated_at
      ''', [
          param.id,
          param.testId,
          param.parameterName,
          param.parameterUnit,
          param.referenceValue,
          param.showOptions,
          param.options,
          param.parameterGroupId,
          param.createdAt,
          param.updatedAt,
        ]);
      }

      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> syncTestParameters(List<SetupTestParameter> testParameterList) async {
    final db = await dbHelper.database;

    db.execute('BEGIN TRANSACTION');
    try {
      for (final tp in testParameterList) {
        db.execute('''
        INSERT INTO test_parameters (
          id, parameter_id, gender, minimum_age, maximum_age,
          lower_value, upper_value, normal_value, in_words, test_name_id,
          created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          parameter_id = excluded.parameter_id,
          gender = excluded.gender,
          minimum_age = excluded.minimum_age,
          maximum_age = excluded.maximum_age,
          lower_value = excluded.lower_value,
          upper_value = excluded.upper_value,
          normal_value = excluded.normal_value,
          in_words = excluded.in_words,
          test_name_id = excluded.test_name_id,
          created_at = excluded.created_at,
          updated_at = excluded.updated_at
      ''', [
          tp.id,
          tp.parameterId,
          tp.gender,
          tp.minimumAge,
          tp.maximumAge,
          tp.lowerValue,
          tp.upperValue,
          tp.normalValue,
          tp.inWords,
          tp.testNameId,
          tp.createdAt,
          tp.updatedAt,
        ]);
      }

      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> syncTestNameConfigs(List<SetupTestNameConfig> testNameConfigList) async {
    final db = await dbHelper.database;

    db.execute('BEGIN TRANSACTION');
    try {
      for (final config in testNameConfigList) {
        db.execute('''
        INSERT INTO test_name_configs (
          id, test_name_id, parameter_id,
          child_lower_value, child_upper_value, child_normal_value,
          male_lower_value, male_upper_value, male_normal_value,
          female_lower_value, female_upper_value, female_normal_value,
          created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          test_name_id = excluded.test_name_id,
          parameter_id = excluded.parameter_id,
          child_lower_value = excluded.child_lower_value,
          child_upper_value = excluded.child_upper_value,
          child_normal_value = excluded.child_normal_value,
          male_lower_value = excluded.male_lower_value,
          male_upper_value = excluded.male_upper_value,
          male_normal_value = excluded.male_normal_value,
          female_lower_value = excluded.female_lower_value,
          female_upper_value = excluded.female_upper_value,
          female_normal_value = excluded.female_normal_value,
          created_at = excluded.created_at,
          updated_at = excluded.updated_at
      ''', [
          config.id,
          config.testNameId,
          config.parameterId,
          config.childLowerValue,
          config.childUpperValue,
          config.childNormalValue,
          config.maleLowerValue,
          config.maleUpperValue,
          config.maleNormalValue,
          config.femaleLowerValue,
          config.femaleUpperValue,
          config.femaleNormalValue,
          config.createdAt,
          config.updatedAt,
        ]);
      }

      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> syncBooths(List<SetupBooth> boothList) async {
    final db = await dbHelper.database;

    db.execute('BEGIN TRANSACTION');
    try {
      for (final booth in boothList) {
        db.execute('''
        INSERT INTO booths (
          id, saas_branch_id, saas_branch_name, branch_id,
          name, booth_no, status, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          saas_branch_id = excluded.saas_branch_id,
          saas_branch_name = excluded.saas_branch_name,
          branch_id = excluded.branch_id,
          name = excluded.name,
          booth_no = excluded.booth_no,
          status = excluded.status,
          created_at = excluded.created_at,
          updated_at = excluded.updated_at
      ''', [
          booth.id,
          booth.saasBranchId,
          booth.saasBranchName,
          booth.branchId,
          booth.name,
          booth.boothNo,
          booth.status,
          booth.createdAt,
          booth.updatedAt,
        ]);
      }

      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> syncCollectors(List<SetupCollector> collectors) async {
    final db = await dbHelper.database;

    db.execute('BEGIN TRANSACTION');
    try {
      for (final c in collectors) {
        if (c.phone == null || c.phone!.isEmpty) {
          debugPrint('Skipping collector with null phone: ${c.name}');
          continue;
        }
        db.execute('''
        INSERT INTO collectors (
          id, name, phone, email, saas_branch_id, saas_branch_name, address, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          name = excluded.name,
          phone = excluded.phone,
          email = excluded.email,
          saas_branch_id = excluded.saas_branch_id,
          saas_branch_name = excluded.saas_branch_name,
          address = excluded.address,
          created_at = excluded.created_at,
          updated_at = excluded.updated_at
      ''', [
          c.id,
          c.name,
          c.phone,
          c.email,
          c.saasBranchId,
          c.saasBranchName,
          c.address,
          c.createdAt,
          c.updatedAt,
        ]);
      }

      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> syncPrintLayouts(PrintLayout layout) async {
    final db = await dbHelper.database;

    db.execute('BEGIN TRANSACTION');
    try {
      db.execute('''
        INSERT INTO print_layouts (
          id, layout_name, page_size, orientation, billing, letter,sticker, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?,?)
        ON CONFLICT(id) DO UPDATE SET
          layout_name = excluded.layout_name,
          page_size = excluded.page_size,
          orientation = excluded.orientation,
          billing = excluded.billing,
          letter = excluded.letter,
          sticker = excluded.sticker,
          created_at = excluded.created_at,
          updated_at = excluded.updated_at
      ''', [
        layout.id,
        layout.layoutName,
        layout.pageSize,
        layout.orientation,
        layout.billing,
        layout.letter,
        layout.sticker,
        layout.createdAt,
        layout.updatedAt,
      ]);

      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> syncInventory(List<SetupInventoryAllSetup> inventoryItems) async {
    final db = await dbHelper.database;
    db.execute('BEGIN TRANSACTION');
    try {
      for (final item in inventoryItems) {
        db.execute('''
        INSERT INTO inventory (webId, name, price,item_code)
        VALUES (?, ?, ?,?)
        ON CONFLICT(webId) DO UPDATE SET
          name=excluded.name,
          price=excluded.price,
          item_code=excluded.item_code
      ''', [
          item.id,
          item.name,
          item.mrp,
          item.itemCode,
        ]);
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> syncPatients(List<SetupPatient> patients) async {
    final db = await dbHelper.database;
    db.execute('BEGIN TRANSACTION');
    try {
      for (final patient in patients) {
        // ✅ Skip if both name and phone are empty/null
        final name = (patient.fullName ?? '').trim();
        final phone = (patient.patientMobilePhone ?? '').trim();
        if (name.isEmpty && phone.isEmpty) {
          continue; // Skip this patient
        }
        final orgId = patient.id;

        if (orgId != null) {
          db.execute('''
          INSERT INTO patients (
            org_patient_id, name, phone, age, month, day,
            date_of_birth, gender, blood_group, visit_type,
            address, hn_number, create_date
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(org_patient_id) DO UPDATE SET
            name = excluded.name,
            phone = excluded.phone,
            age = excluded.age,
            month = excluded.month,
            day = excluded.day,
            date_of_birth = excluded.date_of_birth,
            gender = excluded.gender,
            blood_group = excluded.blood_group,
            visit_type = excluded.visit_type,
            address = excluded.address,
            hn_number = excluded.hn_number,
            create_date = excluded.create_date
        ''', [
            orgId,
            patient.fullName ?? '',
            patient.patientMobilePhone ?? '',
            patient.age ?? '',
            patient.month ?? '',
            patient.day ?? '',
            patient.patientDob,
            patient.patientBirthSexId ?? '',
            patient.ptnBloodGroupId ?? '',
            patient.visitType ?? '',
            patient.patientAddress1 ?? '',
            patient.patientHnNumber ?? '',
            patient.createdAt?.toIso8601String() ?? '',
          ]);
        } else {
          db.execute('''
          INSERT INTO patients (
            name, phone, age, month, day,
            date_of_birth, gender, blood_group, address,
            hn_number, create_date
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
            patient.fullName ?? '',
            patient.patientMobilePhone ?? '',
            patient.age ?? '',
            patient.month ?? '',
            patient.day ?? '',
            patient.patientDob,
            patient.patientBirthSexId ?? '',
            patient.ptnBloodGroupId ?? '',
            patient.patientAddress1 ?? '',
            patient.patientHnNumber ?? '',
            patient.createdAt ?? '',
          ]);
        }
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> syncDoctors(List<SetupDoctor> onlineDoctors) async {
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();

    db.execute('BEGIN TRANSACTION');
    try {
      for (final doctor in onlineDoctors) {
        db.execute('''
        INSERT INTO doctors (org_doctor_id, name, phone, age, degree, last_updated)
        VALUES (?, ?, ?, ?, ?, ?)
        ON CONFLICT(org_doctor_id) DO UPDATE SET
          name=excluded.name,
          phone=excluded.phone,
          age=excluded.age,
          degree=excluded.degree,
          last_updated=excluded.last_updated;
      ''', [
          doctor.id,
          "${doctor.title?.titleName ?? ""} ${doctor.fullName ?? ""}",
          doctor.drMobilePhone ?? doctor.drWorkPhone ?? '',
          calculateAgeDB(doctor.drDob.toString()),
          getHighestDegreeDB(doctor.academic),
          now,
        ]);
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> syncGenders(List<SetupGender> genders) async {
    final db = await dbHelper.database;
    db.execute('BEGIN TRANSACTION');
    try {
      for (final gender in genders) {
        db.execute('''
        INSERT INTO genders (original_id, name) VALUES (?, ?)
        ON CONFLICT(original_id) DO UPDATE SET
          name=excluded.name;
      ''', [
          gender.id,
          gender.birthSexName,
        ]);
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }
  Future<void> syncInvoices(List<AllInvoiceData> invoices) async {
    final db = await dbHelper.database;
    db.execute('BEGIN TRANSACTION');
    try {
      for (final invoice in invoices) {
        // 🔹 Insert or update invoice
        db.execute('''
      INSERT INTO invoices (
        webId, patient_id, patient_web_id, invoice_number, invoice_number_local,
        update_date, delivery_date, delivery_time, create_date_at_web, update_date_at_web,
        total_bill_amount, due, paid_amount, discount, discount_percentage, discount_type,
        refer_type, referre_id_or_desc, created_by_user_id, created_by_name, billingComment,
        collection_status, sent_to_lab_status, delivery_status, report_collection_status
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(invoice_number) DO UPDATE SET
        webId=excluded.webId,
        patient_id=excluded.patient_id,
        patient_web_id=excluded.patient_web_id,
        invoice_number_local=excluded.invoice_number_local,
        update_date=excluded.update_date,
        delivery_date=excluded.delivery_date,
        delivery_time=excluded.delivery_time,
        create_date_at_web=excluded.create_date_at_web,
        update_date_at_web=excluded.update_date_at_web,
        total_bill_amount=excluded.total_bill_amount,
        due=excluded.due,
        paid_amount=excluded.paid_amount,
        discount=excluded.discount,
        discount_percentage=excluded.discount_percentage,
        discount_type=excluded.discount_type,
        refer_type=excluded.refer_type,
        referre_id_or_desc=excluded.referre_id_or_desc,
        created_by_user_id=excluded.created_by_user_id,
        created_by_name=excluded.created_by_name,
        billingComment=excluded.billingComment,
        collection_status=excluded.collection_status,
        sent_to_lab_status=excluded.sent_to_lab_status,
        delivery_status=excluded.delivery_status,
        report_collection_status=excluded.report_collection_status;
      ''', [
          invoice.id.toString(),
          int.tryParse(invoice.patientId ?? '') ?? 0,
          invoice.patientId,
          invoice.invoiceNo,
          invoice.invoiceNoApp ?? invoice.invoiceNo,
          invoice.updatedAt?.toIso8601String(),
          invoice.deliveryDate?.toIso8601String() ?? '',
          invoice.deliveryTime,
          invoice.createdAt?.toIso8601String(),
          invoice.updatedAt?.toIso8601String(),
          double.tryParse(invoice.totalBill ?? '0') ?? 0,
          double.tryParse(invoice.due ?? '0') ?? 0,
          invoice.paidAmount ?? 0,
          double.tryParse(invoice.specialDiscount ?? '0') ?? 0,
          double.tryParse(invoice.discountPercentage ?? '0') ?? 0,
          (['fixed', 'percentage']
              .contains(invoice.discountType?.toLowerCase()))
              ? invoice.discountType?.toLowerCase()
              : 'fixed',
          invoice.referredBy?.toString(),
          invoice.referrer,
          invoice.createdById,
          invoice.createdBy,
          invoice.billingComment,
          invoice.sampleCollectionStatus ?? 0,
          invoice.isApprovedInSendToLab ?? 0,
          invoice.deliveryStatus ?? 0,
          invoice.reportCollectionStatus ?? 0,
        ]);

        // 🔹 Get the local DB id for this invoice
        final invRow = db.select(
          'SELECT id FROM invoices WHERE invoice_number = ?',
          [invoice.invoiceNo],
        );
        if (invRow.isEmpty) continue;
        final invoiceId = invRow.first['id'] as int;

        // ---------------- INVOICE DETAILS (tests) ----------------
        for (final test in invoice.tests ?? []) {
          final fee = double.tryParse(test.fee ?? '0') ?? 0.0;
          final discount = test.test?.discount ?? 0;

          db.execute('''
        INSERT INTO invoice_details (
          invoice_id,invoice_number_local, test_id, fee, is_refund, discount_applied, discount,
          collection_date, collector_id, booth_id, collection_status, remark,
          report_confirmed_status, report_approve_status, report_add_status,
          delivery_status, sent_to_lab_status, reportCollectionStatus, point, point_percent,
          is_offline_sync
        ) VALUES (?, ?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)
        ON CONFLICT(invoice_id, test_id) DO UPDATE SET
          invoice_number_local=excluded.invoice_number_local,
          fee=excluded.fee,
          is_refund=excluded.is_refund,
          discount_applied=excluded.discount_applied,
          discount=excluded.discount,
          collection_date=excluded.collection_date,
          collector_id=excluded.collector_id,
          booth_id=excluded.booth_id,
          collection_status=excluded.collection_status,
          remark=excluded.remark,
          report_confirmed_status=excluded.report_confirmed_status,
          report_approve_status=excluded.report_approve_status,
          report_add_status=excluded.report_add_status,
          delivery_status=excluded.delivery_status,
          sent_to_lab_status=excluded.sent_to_lab_status,
          reportCollectionStatus=excluded.reportCollectionStatus,
          point=excluded.point,
          point_percent=excluded.point_percent,
          is_offline_sync=0
        ''', [
            invoice.invoiceNo,
            invoice.invoiceNoApp,
            test.test?.id,
            fee,
            test.isRefund ?? 0,
            test.test?.discountApplied ?? 0,
            discount,
            test.collectionDate,
            test.collectorId,
            test.boothId,
            test.collectionStatus ?? 0,
            test.remark,
            test.reportConfiremdStatus,
            test.reportApproveStatus,
            test.reportAddStatus,
            test.deliveryStatus,
            test.sentToLabStatus,
            test.reportCollectionStatus,
            test.point,
            test.pointPercent,
          ]);
        }

        // ---------------- INVOICE DETAILS (inventory) ----------------
        for (final item in invoice.inventory ?? []) {
          final total = (item.price ?? 0) * (item.quantity ?? 1);

          db.execute('''
        INSERT OR REPLACE INTO invoice_details (
          invoice_id,invoice_number_local, inventory_id, fee, qty, is_refund, discount_applied, discount,
          collection_date, collector_id, collection_status, remark
        ) VALUES (?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?, ?)
        ''', [
            invoice.invoiceNo,
            invoice.invoiceNoApp,
            item.id,
            total,
            item.quantity ?? 1,
            0, // is_refund
            1, // discount_applied
            0, // discount
            null,
            null,
            0,
            null,
          ]);
        }

        // ---------------- PAYMENTS ----------------
        double cumulativePaidAmount = 0.0;
        for (final receipt in invoice.moneyRecipts ?? []) {
          final paidAmount =
              double.tryParse(receipt.paidAmount?.toString() ?? '0') ?? 0.0;
          final requestedAmount =
              double.tryParse(receipt.requestedAmount?.toString() ?? '0') ?? 0.0;
          final dueAmount =
              double.tryParse(receipt.dueAmount?.toString() ?? '0') ?? 0.0;

          cumulativePaidAmount += paidAmount;

          db.execute('''
        INSERT OR REPLACE INTO payments (
          web_id, money_receipt_number, money_receipt_type,
          patient_web, invoice_number, invoice_id,invoice_number_local,
          payment_type, requested_amount, total_amount_paid,
          due_amount, amount, payment_date, is_sync
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?, ?, ?)
        ''', [
            receipt.id,
            receipt.moneyReceiptNumber,
            receipt.moneyReceiptType,
            invoice.patientId,
            invoice.invoiceNo,
            invoiceId,
            invoice.invoiceNoApp,
            invoice.paymentMethod ?? 'Cash',
            requestedAmount,
            cumulativePaidAmount,
            dueAmount,
            paidAmount,
            receipt.createdAt.toIso8601String(),
            1,
          ]);
        }

        // ---------------- LAB REPORTS ----------------
        for (final report in invoice.reports ?? []) {
          db.execute('''
        INSERT OR REPLACE INTO lab_reports (
          web_id, saas_branch_id, saas_branch_name, invoice_id, invoice_no,invoice_number_local, patient_id,
          test_id, test_name, test_group, test_category, gender,
          technician_name, technician_sign, validator, report_confirm,
          status, remark, radiogyReportImage, radiologyReportDetails,
          created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
            report.id,
            report.saasBranchId,
            report.saasBranchName,
            invoiceId,
            invoice.invoiceNo,
            invoice.invoiceNoApp,
            invoice.patientId,
            report.testId,
            report.testName,
            report.testGroup,
            report.testCategory,
            report.gender,
            report.technicianName,
            report.technicianSign,
            report.validator,
            report.reportConfirm,
            report.status,
            report.remark,
            report.radiogyReportImage,
            report.radiologyReportDetails,
            report.createdAt?.toIso8601String(),
            report.updatedAt?.toIso8601String(),
          ]);

          // report details
          for (final detail in report.details ?? []) {
            db.execute('''
          INSERT OR REPLACE INTO lab_report_details (
            saas_branch_id, saas_branch_name,web_report_id, test_id, patient_id,
            invoice_no,invoice_number_local, parameter_id, parameter_name, result, unit,
            lower_value, upper_value, flag, lab_no, parameter_group_id,
            created_at, updated_at
          ) VALUES (?, ?, ?, ?, ?, ?,?,?, ?, ?,?, ?, ?, ?, ?, ?, ?,  ?)
          ''', [
              detail.saasBranchId,
              detail.saasBranchName,
              report.id,
              report.testId,
              invoice.patientId,
              invoice.invoiceNo,
              invoice.invoiceNoApp,
              detail.parameterId,
              detail.parameterName,
              detail.result,
              detail.unit,
              detail.lowerValue,
              detail.upperValue,
              detail.flag,
              detail.labNo,
              detail.parameterGroupId,
              detail.createdAt?.toIso8601String(),
              detail.updatedAt?.toIso8601String(),
            ]);
          }
        }
      }

      db.execute('COMMIT');
    } catch (e, s) {
      debugPrint('Sync Invoices Error: $e\n$s');
      try {
        db.execute('ROLLBACK');
      } catch (_) {}
    }
  }


  Future<void> syncSpecimens(List<SetupSpecimen> specimens) async {
    final db = await dbHelper.database; // ✅ must await
    db.execute('BEGIN TRANSACTION');
    try {
      for (final specimen in specimens) {
        db.execute('''
        INSERT INTO specimens (
          id, saas_branch_id, saas_branch_name, name, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          saas_branch_id = excluded.saas_branch_id,
          saas_branch_name = excluded.saas_branch_name,
          name = excluded.name,
          created_at = excluded.created_at,
          updated_at = excluded.updated_at;
      ''', [
          specimen.id,
          specimen.saasBranchId,
          specimen.saasBranchName,
          specimen.name,
          specimen.createdAt.toString(),
          specimen.updatedAt.toString(),
        ]);
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> syncTestGroups(List<SetupTestGroup> testGroups) async {
    final db = await dbHelper.database; // ✅ must await
    db.execute('BEGIN TRANSACTION');
    try {
      for (final testGroup in testGroups) {
        db.execute('''
        INSERT INTO test_groups (
          id, saas_branch_id, saas_branch_name, test_group_name, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
          saas_branch_id = excluded.saas_branch_id,
          saas_branch_name = excluded.saas_branch_name,
          test_group_name = excluded.test_group_name,
          created_at = excluded.created_at,
          updated_at = excluded.updated_at;
      ''', [
          testGroup.id,
          testGroup.saasBranchId,
          testGroup.saasBranchName,
          testGroup.testGroupName,
          testGroup.createdAt.toString(),
          testGroup.updatedAt.toString(),
        ]);
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<void> syncBloodGroups(List<SetupBloodGroup> bloodGroups) async {
    final db = await dbHelper.database;
    db.execute('BEGIN TRANSACTION');
    try {
      for (final group in bloodGroups) {
        db.execute('''
        INSERT INTO blood_groups (original_id, name) VALUES (?, ?)
        ON CONFLICT(original_id) DO UPDATE SET
          name=excluded.name;
      ''', [
          group.id,
          group.bloodGroupName,
        ]);
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }
  Future<void> syncCaseEffects(List<SetupCaseEffect> caseEffects) async {
    final db = await dbHelper.database;
    db.execute('BEGIN TRANSACTION');
    try {
      for (final effect in caseEffects) {
        db.execute('''
        INSERT INTO case_effects (web_id, money_receipt_id, amount)
        VALUES (?, ?, ?)
        ON CONFLICT(web_id) DO UPDATE SET
          money_receipt_id = excluded.money_receipt_id,
          amount = excluded.amount;
      ''', [
          effect.id, // web_id
          effect.moneyReceiptId,
          effect.amount,
        ]);
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }
  Future<void> syncMarketers(List<SetupMarketer> marketers) async {
    final db = await dbHelper.database;
    db.execute('BEGIN TRANSACTION');
    try {
      for (final marketer in marketers) {
        db.execute('''
        INSERT INTO marketers (
          id, name, marketer_id, marketer_group_id, marketer_group_name, phone, email, address
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(marketer_id) DO UPDATE SET
          name = excluded.name,
          marketer_group_id = excluded.marketer_group_id,
          marketer_group_name = excluded.marketer_group_name,
          phone = excluded.phone,
          email = excluded.email,
          address = excluded.address;
      ''', [
          marketer.id,
          marketer.name,
          marketer.marketerId,
          marketer.marketerGroupId,
          marketer.group?.name,
          marketer.phone,
          marketer.email,
          marketer.address,
        ]);
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }


}
