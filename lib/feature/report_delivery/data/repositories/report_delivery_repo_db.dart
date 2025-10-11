import '../../../../core/configs/configs.dart';
import '../../../sample_collector/data/model/sample_collector_model.dart';


class ReportDeliveryRepoDb {
  final DatabaseHelper dbHelper = DatabaseHelper();

  void insertReport({
    required String invoiceNo,
    required String patientId,
    required String deliveryDate,
    required String deliveryTime,
    required String collectedBy,
    required String remark,
    required List<InvoiceDetail> selectedTests, // pass full selected test objects
  }) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    // Prepare IDs and Names
    final selectedTestNames = selectedTests.map((t) => t.testName ?? "").join(",");

    // Insert delivery info
    db.execute('''
    INSERT INTO mhp_great_lab_report_delivery_infos 
    (invoiceNo, patient_id, deliveryDate, deliveryTime, collectedBy, remark, testList, created_at, updated_at) 
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
  ''', [
      invoiceNo,
      patientId,
      deliveryDate,
      deliveryTime,
      collectedBy,
      remark,
      selectedTestNames,
      DateTime.now().toIso8601String(),
      DateTime.now().toIso8601String(),
    ]);

    // Update delivery status for selected tests
    for (final test in selectedTests) {
      db.execute('''
      UPDATE invoice_details
      SET delivery_status = 1
      WHERE invoice_id = ? AND test_id = ?;
    ''', [invoiceNo, test.testId]);
    }

    // Check if all tests under this invoice are delivered
    final result = db.select('''
    SELECT COUNT(*) as total,
           SUM(CASE WHEN delivery_status = 1 THEN 1 ELSE 0 END) as delivered
    FROM invoice_details
    WHERE invoice_id = ?;
  ''', [invoiceNo]).first;

    final total = result['total'] as int;
    final delivered = result['delivered'] as int;

    if (total > 0 && total == delivered) {
      // Mark invoice as delivered
      db.execute('''
      UPDATE invoices
      SET delivery_status = 1,
          delivery_date = ?,
          delivery_time = ?
      WHERE invoice_number = ?;
    ''', [deliveryDate, deliveryTime, invoiceNo]);
    }
  }



}
