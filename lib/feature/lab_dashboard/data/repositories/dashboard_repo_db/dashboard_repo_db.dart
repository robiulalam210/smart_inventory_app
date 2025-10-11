

import '../../../../../core/database/database_info.dart';
import '../../../presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../models/dashboard/dashboard_model.dart';

Future<DashboardData> fetchDashboardData({DateRangeFilter filter = DateRangeFilter.all}) async {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final db = await dbHelper.database;

  final now = DateTime.now();
  late DateTime fromDate;

  switch (filter) {
    case DateRangeFilter.today:
      fromDate = DateTime(now.year, now.month, now.day);
      break;
    case DateRangeFilter.last7Days:
      fromDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
      break;
    case DateRangeFilter.last30Days:
      fromDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
      break;
    case DateRangeFilter.last365Days:
      fromDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 364));
      break;
    case DateRangeFilter.all:
    fromDate = DateTime(2000); // Far past date for no filter
  }

  final fromDateStr = fromDate.toIso8601String();
  final testFromInvoiceDetailsResult = db.select('''
  SELECT COUNT(*) AS total_invoice_tests
  FROM invoice_details
  JOIN invoices ON invoice_details.invoice_id = invoices.invoice_number
  WHERE COALESCE(invoices.create_date_at_web, invoices.create_date) >= '$fromDateStr';
''');

  // Query totals from invoices table filtered by create_date >= fromDate
  final invoiceTotalsResult = db.select('''
  SELECT 
    IFNULL(SUM(total_bill_amount), 0) AS total_amount,
    IFNULL(SUM(discount), 0) AS total_discount,
    IFNULL(SUM(paid_amount), 0) AS total_received,
    IFNULL(SUM(paid_amount), 0) AS total_received,
    IFNULL(SUM(due), 0) AS total_due,
    (
      SELECT IFNULL(SUM(p.amount), 0)
      FROM payments p
      WHERE p.money_receipt_type = 'due'
        AND p.payment_date >= '$fromDateStr'
    ) AS due_collection

  FROM invoices
  WHERE COALESCE(create_date_at_web, create_date) >= '$fromDateStr';
''');

  final patientInvoiceCountResult = db.select('''
  SELECT COUNT(DISTINCT COALESCE(patients.org_patient_id, patients.id)) AS total_patients
  FROM invoices
  JOIN patients
    ON (
      invoices.patient_web_id IS NOT NULL AND invoices.patient_web_id = patients.org_patient_id
    ) OR (
      invoices.patient_web_id IS NULL AND invoices.patient_id = patients.id
    )
  WHERE COALESCE(invoices.create_date_at_web, invoices.create_date) >= '$fromDateStr';
''');

  // Test and doctor counts (no date filter)
  final testCountResult = db.select('SELECT COUNT(*) AS total_tests FROM test_names;');
  final doctorCountResult = db.select('SELECT COUNT(*) AS total_doctors FROM doctors;');


  // Patient chart data filtered by date range
  final patientChartResult = db.select('''
    SELECT create_date, COUNT(*) as count
    FROM patients
    WHERE create_date >= '$fromDateStr'
    GROUP BY create_date
    ORDER BY create_date ASC;
  ''');
  final invoiceChartResult = db.select('''
  SELECT 
    date(COALESCE(create_date_at_web, create_date)) AS create_date,
    COUNT(*) AS count,
    IFNULL(SUM(total_bill_amount), 0) AS total_amount
  FROM invoices
  WHERE date(COALESCE(create_date_at_web, create_date)) >= ?
  GROUP BY create_date
  ORDER BY create_date ASC;
''', [fromDateStr]);


  final invoiceChart = invoiceChartResult.map((row) {
    final dateStr = row['create_date'] as String?;
    final count = row['count'] is int ? row['count'] as int : int.tryParse(row['count'].toString()) ?? 0;
    final totalAmount = row['total_amount'] is num ? (row['total_amount'] as num).toDouble() : 0.0;

    return ChartEntry(
      date: dateStr != null ? DateTime.tryParse(dateStr) ?? DateTime.now() : DateTime.now(),
      count: count,
      totalBillAmount: totalAmount,
    );
  }).toList();





  final patientChart = patientChartResult.map((row) {
    return ChartEntry(
      date: DateTime.tryParse(row['create_date'] as String) ?? DateTime.now(),
      count: row['count'] as int,
    );
  }).toList();

  final invoiceTotals = invoiceTotalsResult.first;
  final patientCount = patientInvoiceCountResult.first;
  final testCount = testCountResult.first;
  final doctorCount = doctorCountResult.first;
  final testFromInvoiceDetails = testFromInvoiceDetailsResult.first;

  return DashboardData(
    totalAmount: (invoiceTotals['total_amount'] as num).toDouble(),
    totalDiscount: (invoiceTotals['total_discount'] as num).toDouble(),
    totalReceived: (invoiceTotals['total_received'] as num).toDouble(),
    totalDue: (invoiceTotals['total_due'] as num).toDouble(),
    dueCollection: (invoiceTotals['due_collection'] as num).toDouble(),
    totalPatients: patientCount['total_patients'] as int,
    totalInvoiceTests: testFromInvoiceDetails['total_invoice_tests'] as int,

    totalTests: testCount['total_tests'] as int,
    totalDoctors: doctorCount['total_doctors'] as int,
    invoiceChart: invoiceChart,
    patientChart: patientChart,
  );

}
