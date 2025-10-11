import '../../../../../core/configs/configs.dart';

class UnSyncRepo {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<Map<String, dynamic>> syncInvoiceAndPatient({
    required Map<String, dynamic> invoice,
    required Map<String, dynamic> patient,
    List<Map<String, dynamic>> moneyRecipts = const [],
    List<Map<String, dynamic>> testList = const [],
    List<Map<String, dynamic>> inventoryList = const [],
  }) async {
    final db = await dbHelper.database;

    final invoiceNoApp = invoice['invoiceNo_app']?.toString() ?? '';
    final invoiceNoWeb = invoice['invoiceNo']?.toString() ?? invoiceNoApp;
    final webPatientId = patient['web_id'] ?? patient['id'];

    if (webPatientId == null) {
      return {
        'status': 'error',
        'message': 'Patient web_id is null. Skipping sync.',
      };
    }

    try {
      db.execute('BEGIN TRANSACTION');

      // ---------------- Step 1: Upsert Patient ----------------
      int localPatientId;
      // Step 1: Find patient by org_patient_id
      final existingPatientByWebId = db.select(
        'SELECT id FROM patients WHERE org_patient_id = ? LIMIT 1',
        [webPatientId],
      );

      if (existingPatientByWebId.isNotEmpty) {
        localPatientId = existingPatientByWebId.first['id'];
        // Safe update without changing org_patient_id to a duplicate
        db.execute('''
    UPDATE patients SET
      name = ?, phone = ?, age = ?, month = ?, day = ?,
      gender = ?, blood_group = ?, address = ?, date_of_birth = ?,
      visit_type = ?, hn_number = ?, create_date = ?
    WHERE id = ?
  ''', [
          patient['fullName'],
          patient['patient_mobile_phone'],
          patient['age'],
          patient['month'],
          patient['day'],
          patient['patient_birth_sex_id'],
          patient['ptn_blood_group_id'],
          patient['patient_address1'],
          patient['patient_dob'],
          patient['visit_type'],
          patient['patient_hn_number'],
          invoice['created_at'],
          localPatientId,
        ]);
      } else {
        // Insert new patient safely
        db.execute('''
    INSERT INTO patients (
      name, phone, age, month, day, gender, blood_group, address,
      date_of_birth, visit_type, hn_number, create_date, org_patient_id
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ''', [
          patient['fullName'],
          patient['patient_mobile_phone'],
          patient['age'],
          patient['month'],
          patient['day'],
          patient['patient_birth_sex_id'],
          patient['ptn_blood_group_id'],
          patient['patient_address1'],
          patient['patient_dob'],
          patient['visit_type'],
          patient['patient_hn_number'],
          invoice['created_at'],
          webPatientId,
        ]);
        localPatientId = db.lastInsertRowId;
      }

      // ---------------- Step 2: Upsert Invoice ----------------
      int invoiceId;
      final existingInvoice = db.select(
        'SELECT id FROM invoices WHERE invoice_number = ? OR invoice_number_local = ? LIMIT 1',
        [invoiceNoWeb, invoiceNoApp],
      );

      if (existingInvoice.isEmpty) {
        // Insert new invoice
        db.execute('''
        INSERT INTO invoices (
          invoice_number, invoice_number_local, webId, patient_id, patient_web_id, delivery_date, delivery_time,
          update_date, total_bill_amount, due, paid_amount,
          discount_type, discount, refer_type, referre_id_or_desc,
          discount_percentage, created_by_user_id, created_by_name, create_date,
          create_date_at_web, update_date_at_web, billingComment
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
          invoiceNoWeb,
          invoiceNoApp,
          invoice['web_id'],
          localPatientId,
          webPatientId,
          invoice['deliveryDate'],
          invoice['deliveryTime'],
          invoice['updated_at'],
          invoice['totalBill'],
          invoice['due'],
          invoice['paidAmount'],
          invoice['discount_type'],
          invoice['specialDiscount'],
          invoice['referredBy'],
          invoice['referrer'],
          invoice['discount_percentage'],
          invoice['created_by_id'],
          invoice['created_by'],
          DateTime.now().toIso8601String(),
          invoice['created_at'],
          invoice['updated_at'],
          invoice['billingComment'],
        ]);
        invoiceId = db.lastInsertRowId;
      } else {
        // Update existing invoice
        invoiceId = existingInvoice.first['id'];

        // Avoid unique conflict on invoice_number_local
        final conflictCheck = db.select(
          'SELECT id FROM invoices WHERE invoice_number_local = ? AND id != ? LIMIT 1',
          [invoiceNoApp, invoiceId],
        );
        if (conflictCheck.isNotEmpty) {
          final tempInvoiceNumberLocal =
              "${invoiceNoApp}_${DateTime.now().millisecondsSinceEpoch}";
          db.execute(
              'UPDATE invoices SET invoice_number_local = ? WHERE id = ?', [
            tempInvoiceNumberLocal,
            invoiceId,
          ]);
        }

        db.execute('''
        UPDATE invoices SET
          invoice_number = ?, invoice_number_local = ?, webId = ?, patient_id = ?, patient_web_id = ?,
          delivery_date = ?, delivery_time = ?, update_date = ?, total_bill_amount = ?, due = ?, paid_amount = ?,
          discount_type = ?, discount = ?, refer_type = ?, referre_id_or_desc = ?, discount_percentage = ?,
          created_by_user_id = ?, created_by_name = ?, create_date_at_web = ?, update_date_at_web = ?, billingComment = ?
        WHERE id = ?
      ''', [
          invoiceNoWeb,
          invoiceNoApp,
          invoice['web_id'],
          localPatientId,
          webPatientId,
          invoice['deliveryDate'],
          invoice['deliveryTime'],
          invoice['updated_at'],
          invoice['totalBill'],
          invoice['due'],
          invoice['paidAmount'],
          invoice['discount_type'],
          invoice['specialDiscount'],
          invoice['referredBy'],
          invoice['referrer'],
          invoice['discount_percentage'],
          invoice['created_by_id'],
          invoice['created_by'],
          invoice['created_at'],
          invoice['updated_at'],
          invoice['billingComment'],
          invoiceId,
        ]);
      }

      // ---------------- Step 3: Upsert Invoice Details (Tests) ----------------
      for (final test
          in testList.isNotEmpty ? testList : (invoice['tests'] ?? [])) {
        final fee = double.tryParse(test['fee']?.toString() ?? '0') ?? 0.0;
        final discount = test['test']?['discount'] ?? 0;

        db.execute('''
        INSERT INTO invoice_details (
          invoice_id, invoice_number_local, test_id, fee, is_refund, discount_applied, discount,
          collection_date, collector_id, booth_id, collection_status, remark,
          report_confirmed_status, report_approve_status, report_add_status,
          delivery_status, sent_to_lab_status, reportCollectionStatus, point, point_percent,
          is_offline_sync
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)
        ON CONFLICT(invoice_id, test_id) DO UPDATE SET
          invoice_number_local = excluded.invoice_number_local,
          fee = excluded.fee,
          is_refund = excluded.is_refund,
          discount_applied = excluded.discount_applied,
          discount = excluded.discount,
          collection_date = excluded.collection_date,
          collector_id = excluded.collector_id,
          booth_id = excluded.booth_id,
          collection_status = excluded.collection_status,
          remark = excluded.remark,
          report_confirmed_status = excluded.report_confirmed_status,
          report_approve_status = excluded.report_approve_status,
          report_add_status = excluded.report_add_status,
          delivery_status = excluded.delivery_status,
          sent_to_lab_status = excluded.sent_to_lab_status,
          reportCollectionStatus = excluded.reportCollectionStatus,
          point = excluded.point,
          point_percent = excluded.point_percent,
          is_offline_sync = 0
      ''', [
          invoiceNoWeb,
          invoiceNoApp,
          test['test']?['id'],
          fee,
          test['isRefund'] ?? 0,
          test['test']?['discountApplied'] ?? 0,
          discount,
          test['collectionDate'],
          test['collectorId'],
          test['boothId'],
          test['collectionStatus'] ?? 0,
          test['remark'],
          test['reportConfiremdStatus'],
          test['reportApproveStatus'],
          test['reportAddStatus'],
          test['deliveryStatus'],
          test['sentToLabStatus'],
          test['reportCollectionStatus'],
          test['point'],
          test['pointPercent'],
        ]);
      }

      // ---------------- Step 4: Upsert Invoice Details (Inventory) ----------------
      for (final item in inventoryList.isNotEmpty
          ? inventoryList
          : (invoice['inventory'] ?? [])) {
        final price = (item['price'] ?? 0);
        final quantity = (item['quantity'] ?? 1);

        db.execute('''
        INSERT INTO invoice_details (
          invoice_id, invoice_number_local, inventory_id, qty, fee, is_refund, discount_applied, discount
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      ''', [
          invoiceId,
          invoiceNoApp,
          item['product_id'],
          quantity,
          price,
          0,
          1,
          0,
        ]);
      }

      // ---------------- Step 5: Upsert Payments ----------------

      for (final receipt in moneyRecipts.isNotEmpty
          ? moneyRecipts
          : (invoice['payments'] ?? [])) {
        db.execute('''
    INSERT OR REPLACE INTO payments (
      web_id, money_receipt_number, money_receipt_type,
      patient_id, patient_web, invoice_number, invoice_number_local, invoice_id,
      payment_type, requested_amount, total_amount_paid, due_amount,
      amount, payment_date, is_sync
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ''', [
          receipt['id'], // web_id (unique key)
          receipt['money_receipt_number'],
          receipt['money_receipt_type'],
          localPatientId,
          webPatientId,
          receipt['invoice_number'],
          invoiceNoApp,
          invoiceId,
          receipt['payment_method'] ?? "Cash",
          receipt['requested_amount'],
          receipt['total_amount_paid'],
          receipt['due_amount'],
          receipt['paid_amount'],
          receipt['created_at'],
          1, // is_sync
        ]);
      }
// Update lab_reports for this invoice
      db.execute('''
  UPDATE lab_reports
  SET
    invoice_no = ?,
    invoice_number_local = ?,
    patient_id = ?
  WHERE invoice_no = ?
''', [
        invoiceNoWeb, // invoice_number
        invoiceNoApp, // local invoice number
        localPatientId, // local patient id
        invoiceNoApp.toString(), // invoice_id stored in lab_reports
      ]);
// Update report_details for this invoice
      db.execute('''
  UPDATE lab_report_details
  SET
    invoice_no = ?,
    invoice_number_local = ?,
    patient_id = ?
  WHERE invoice_no = ?
''', [
        invoiceNoWeb.toString(),
        invoiceNoApp,
        localPatientId,
        invoiceNoApp.toString(), // old value might be same or empty
      ]);
      db.execute('''
  UPDATE mhp_great_lab_report_delivery_infos
  SET
    invoiceNo = ?,
    invoice_number_local = ?,
    patient_id = ?
  WHERE invoiceNo = ?
''', [
        invoiceNoWeb.toString(),
        invoiceNoApp,
        localPatientId,
        invoiceNoApp.toString(), // old value might be same or empty
      ]);

      db.execute('COMMIT');

      return {
        'status': 'success',
        'message': 'Invoice and patient synced successfully.',
        'invoice_number': invoiceNoWeb,
      };
    } catch (e, stack) {
      db.execute('ROLLBACK');
      debugPrint('❌ Sync failed: $e\n$stack');
      return {
        'status': 'error',
        'message': 'Error syncing invoice and patient: $e',
      };
    }
  }

  Future<Map<String, dynamic>> refundInvoiceThenPatientFromServer({
    required Map<String, dynamic> fullInvoice,
    required bool isFullRefund,
  }) async {
    final db = await dbHelper.database;

    final invoice = fullInvoice['invoice'];
    try {
      final invoiceNo = invoice['invoiceNo'];
      final patient = invoice['patient'];
      final test = invoice['tests'];

      final webId = patient['id'];

      // Get existing invoice
      final existingInvoice = db.select(
        'SELECT id, patient_id FROM invoices WHERE invoice_number = ? LIMIT 1',
        [invoiceNo],
      );

      if (existingInvoice.isEmpty) {
        return {
          'status': 'error',
          'message': 'Invoice $invoiceNo not found in local DB.',
        };
      }

      final invoiceId = existingInvoice.first['id'];
      var localPatientId = existingInvoice.first['patient_id'];

      db.execute('BEGIN TRANSACTION');

      try {
        // ✅ Step 1: Update or insert patient

        final existingPatient = db.select(
          'SELECT id, org_patient_id FROM patients WHERE id = ? OR org_patient_id = ? LIMIT 1',
          [localPatientId, webId],
        );

        if (existingPatient.isNotEmpty) {
          localPatientId = existingPatient.first['id'];
          db.execute('''
  UPDATE patients SET
    name = ?, phone = ?, age = ?, month = ?, day = ?,
    gender = ?, blood_group = ?, address = ?, date_of_birth = ?,
    visit_type = ?, hn_number = ?, create_date = ?
  WHERE id = ?
''', [
            patient['fullName'],
            patient['patient_mobile_phone'],
            patient['age'],
            patient['month'],
            patient['day'],
            patient['patient_birth_sex_id'],
            patient['ptn_blood_group_id'],
            patient['patient_address1'],
            patient['patient_dob'],
            patient['visit_type'],
            patient['patient_hn_number'],
            invoice['created_at'],
            localPatientId,
          ]);
        } else {
          db.execute('''
          INSERT INTO patients (
            name, phone, age, month, day, gender, blood_group, address,
            date_of_birth, visit_type, hn_number, create_date, org_patient_id
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
            patient['fullName'],
            patient['patient_mobile_phone'],
            patient['age'],
            patient['month'],
            patient['day'],
            patient['patient_birth_sex_id'],
            patient['ptn_blood_group_id'],
            patient['patient_address1'],
            patient['patient_dob'],
            patient['visit_type'],
            patient['patient_hn_number'],
            invoice['created_at'],
            webId,
          ]);
          localPatientId = db.lastInsertRowId;
        }

        // ✅ Step 2: Update invoice
        db.execute('''
        UPDATE invoices SET
          webId = ?, patient_web_id = ?, delivery_date = ?, delivery_time = ?, update_date = ?, 
          total_bill_amount = ?, due = ?, paid_amount = ?, discount_type = ?, 
          discount = ?, refer_type = ?, referre_id_or_desc = ?, 
          discount_percentage = ?, created_by_user_id = ?, created_by_name = ?,
          create_date_at_web = ?, update_date_at_web = ?, billingComment = ?,
          patient_id = ?
        WHERE id = ?
      ''', [
          invoice['web_id'],
          patient['web_id'],
          invoice['deliveryDate'],
          invoice['deliveryTime'],
          invoice['updated_at'],
          invoice['totalBill'],
          invoice['due'],
          invoice['paidAmount'],
          invoice['discount_type'],
          invoice['specialDiscount'],
          invoice['referredBy'].toString().capitalize(),
          invoice['referrer'],
          invoice['discount_percentage'],
          invoice['created_by_id'],
          invoice['created_by'],
          invoice['created_at'],
          invoice['updated_at'],
          invoice['billingComment'],
          localPatientId, // Make sure to update patient_id in invoice
          invoiceId,
        ]);

        // ✅ Step 3: Insert Invoice Details - Tests
        if (test != []) {
          for (final t in test) {
            final fee = double.tryParse(t['fee']?.toString() ?? '0') ?? 0.0;
            final discount =
                double.tryParse(t['discount']?.toString() ?? '0') ?? 0.0;

            db.execute('''
  INSERT INTO invoice_details (
    invoice_id, test_id, fee, is_refund, discount_applied, discount
  ) VALUES (?, ?, ?, ?, ?, ?)
  ON CONFLICT(invoice_id, test_id) DO UPDATE SET
    fee = excluded.fee,
    is_refund = excluded.is_refund,
    discount_applied = excluded.discount_applied,
    discount = excluded.discount
''', [
              t['invoiceNo'],
              t['testCode'],
              fee,
              t['is_refund'] ?? 0,
              t['discount_applied'] ?? 0,
              discount,
            ]);
          }
        }

        final nowStr = DateTime.now().toIso8601String();

        if (isFullRefund) {
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
      ) VALUES (?,  ?,?, ?, ?, ?, ?, ?, ?, ?,  ?)
    ''', [
            'refund',
            patient[''],
            patient['id'],
            invoiceNo,
            invoiceId,
            'Cash',
            invoice['refundAmount'],
            invoice['due'], // due left
            invoice['refundAmount'],
            nowStr,
            0,
          ]);
        } else {
          for (final receipt in invoice['money_recipts']) {
            final existingPayment = db.select(
              '''
    SELECT id FROM payments 
    WHERE web_id = ? AND invoice_number = ? 
    LIMIT 1
    ''',
              [receipt['id'], invoiceNo],
            );

            if (existingPayment.isEmpty) {
              // 🔹 Insert new payment
              db.execute('''
      INSERT INTO payments (
        web_id,
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
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
                receipt['id'],
                receipt['money_receipt_type'],
                localPatientId, // local DB id
                patient['id'], // server id
                invoiceNo,
                invoiceId,
                'Cash',
                receipt['requested_amount'],
                receipt['due_amount'],
                receipt['paid_amount'],
                nowStr,
                0,
              ]);
            } else {
              // 🔹 Update existing payment
              db.execute('''
      UPDATE payments SET
        requested_amount = ?,
        due_amount = ?,
        amount = ?,
        payment_date = ?
      WHERE web_id = ? AND invoice_number = ?
    ''', [
                receipt['requested_amount'],
                receipt['due_amount'],
                receipt['paid_amount'],
                nowStr,
                receipt['id'],
                invoiceNo,
              ]);
            }
          }
        }

        db.execute('COMMIT');

        debugPrint(
            '✅ Invoice $invoiceNo and patient ID $localPatientId updated successfully');
        return {
          'status': 'success',
          'message': 'Invoice and patient updated successfully.',
          'invoice_number': invoiceNo,
        };
      } catch (e) {
        db.execute('ROLLBACK');
        rethrow;
      }
    } catch (e, stack) {
      debugPrint('❌ Error updating invoice/patient: $e\n$stack');
      return {
        'status': 'error',
        'message': 'Error syncing: $e',
      };
    }
  }
}
