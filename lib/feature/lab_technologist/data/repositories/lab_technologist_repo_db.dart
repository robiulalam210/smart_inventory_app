import 'dart:io';
import '../../../../core/configs/configs.dart';
import '../model/single_report_model.dart' hide Specimen;
import '../model/single_test_parameter_model.dart';

class LabTechnologistRepoDb {
  final DatabaseHelper dbHelper = DatabaseHelper();

  // Future<List<Map<String, dynamic>>> fetchUnsyncedLabDataNested() async {
  //   final db = await dbHelper.database;
  //
  //   // Fetch all unsynced lab reports
  //   final labReports = db.select(
  //       "SELECT * FROM lab_reports WHERE web_id IS NULL OR web_id = ''");
  //
  //   // Fetch all unsynced report details
  //   final reportDetails = db.select(
  //       "SELECT * FROM lab_report_details WHERE web_report_id IS NULL OR web_report_id = ''");
  //
  //   // Group report details and delivery infos by invoice_id / invoice_no
  //   List<Map<String, dynamic>> nestedReports = labReports.map((report) {
  //     // final invoiceNo = report['invoice_no'];
  //     final reportId = report['id'];
  //
  //     final detailsForReport =
  //         reportDetails.where((d) => d['report_id'] == reportId).toList();
  //
  //     return {
  //       ...report,
  //       'report_details': detailsForReport,
  //     };
  //   }).toList();
  //   debugPrint(nestedReports.toString());
  //
  //   return nestedReports;
  // }
  Future<List<Map<String, dynamic>>> fetchUnsyncedLabDataNested() async {
    final db = await dbHelper.database;

    // --- Fetch unsynced lab reports
    final labReports = db.select('''
    SELECT * FROM lab_reports 
    WHERE web_id IS NULL OR web_id = ''
  ''');

    // --- Fetch unsynced report details
    final reportDetails = db.select('''
    SELECT * FROM lab_report_details 
    WHERE web_report_id IS NULL OR web_report_id = ''
  ''');

    // --- Fetch parameters (master parameter info)
    final parameters = db.select("SELECT * FROM parameters");

    // --- Fetch test_parameters (age/gender ranges)
    final testParameters = db.select("SELECT * FROM test_parameters");

    // --- Build nested structure
    final nestedReports = labReports.map((report) {
      final reportId = report['id'];

      final detailsForReport = reportDetails
          .where((d) => d['report_id'] == reportId)
          .map((detail) {
        final paramId = detail['parameter_id'];

        // Match parameter row
        final param = parameters.firstWhere(
              (p) => p['id'].toString() == paramId.toString(),
        );

        // Match all test_parameter ranges for this parameter
        final ranges = testParameters
            .where((tp) => tp['parameter_id'].toString() == paramId.toString())
            .toList();

        return {
          ...detail,
          'parameter': param.isNotEmpty ? {
            ...param,
            'ranges': ranges, // 👈 embed test_parameters here
          } : null,
        };
      })
          .toList();

      return {
        ...report,
        'report_details': detailsForReport,
      };
    }).toList();

    debugPrint(nestedReports.toString());

    return nestedReports;
  }

  // Fetch complete test data by test_name.id
  Future<SingleTestInformationModel> getTestData(String testId) async {
    final db = await dbHelper.database;

    // 1. Get the main test info
    final testResult = db.select('''
      SELECT * FROM test_names 
      WHERE org_test_name_id = ?
    ''', [testId]);

    if (testResult.isEmpty) {
      throw Exception('Test not found with ID: $testId');
    }

    final testData = testResult.first;
    final testCategoryId = testData['test_category_id'];
    // 2. Get the test category
    final categoryResult = db.select('''
      SELECT id, name as test_category_name FROM test_categories 
      WHERE org_test_category_id = ?
    ''', [testCategoryId]);

    // 3. Get parameter groups for this test with their parameters
    final parameterGroupsResult = db.select('''
      SELECT * FROM parameter_groups 
      WHERE test_name_id = ?
    ''', [testId]);

    final parameterGroups = parameterGroupsResult.map((group) {
      final groupId = group['id'];

      // Get parameters for this group
      final parameters = db.select('''
        SELECT * FROM parameters 
        WHERE parameter_group_id = ?
      ''', [groupId]);

      return {
        ...group,
        'parameter': parameters,
      };
    }).toList();

    // 4. Get all lab parameters (from parameters table where test_id matches)
    final labParameters = db.select('''
      SELECT * FROM parameters 
      WHERE test_id = ?
    ''', [testId]);
    final specimenId = testData['specimen_id'];
    Map<String, Object?>? specimen;

    if (specimenId != null) {
      final specimenResult = db.select(
        'SELECT * FROM specimens WHERE id = ?',
        [specimenId],
      );
      if (specimenResult.isNotEmpty) {
        specimen = specimenResult.first;
      }
    }

    // 5. Structure the final response
    return SingleTestInformationModel(
      status: 200,
      testName: TestName(
        id: testData['id'],
        testCategoryId: testData['test_category_id'],
        orgTestNameId: testData['org_test_name_id'],
        name: testData['name'],
        code: testData['code'],
        fee: testData['fee']?.toInt(),
        discountApplied: testData['discount_applied'],
        discount: testData['discount']?.toInt(),
        testGroupId: testData['test_group_id'],
        testSubCategoryId: testData['test_sub_category_id'],
        parameterGroupId: testData['parameter_group_id'],
        status: testData['status'],
        hideTestName: testData['hide_test_name'],
        createdAt: testData['created_at'],
        testCategoryName: testData['test_category_name'],
        testGroupName: testData['test_group_name'],
        testSubCategoryName: testData['test_sub_category_name'],
        category: categoryResult.isNotEmpty
            ? TestCategory.fromJson(categoryResult.first)
            : null,
        subCategory: null,
        parameterGroup:
            parameterGroups.map((g) => ParameterGroup.fromJson(g)).toList(),
        labParameter:
            labParameters.map((p) => TestParameter.fromJson(p)).toList(),
        specimen: specimen != null ? Specimen.fromJson(specimen) : null,
      ),
    );
  }

  Future<ReportInformationModel> fetchLabReport(
      String invoiceNo, String testId) async {
    final db = await dbHelper.database;

    // 1️⃣ Fetch main report
    final reportResult = db.select('''
    SELECT * FROM lab_reports
    WHERE invoice_no = ? AND test_id = ?
    LIMIT 1
  ''', [invoiceNo, testId]);

    if (reportResult.isEmpty) {
      debugPrint("No lab report found for Invoice #$invoiceNo, Test #$testId");
      return ReportInformationModel(
        status: 404,
        message: "No lab report found",
        report: null,
      );
    }

    final reportRow = reportResult.first;

    // 2️⃣ Fetch test info (to get specimen_id)
    final testResult = db.select(
      'SELECT * FROM test_names WHERE org_test_name_id = ?',
      [testId],
    );
    final testData = testResult.isNotEmpty ? testResult.first : null;

    // 3️⃣ Fetch specimen info
    Map<String, Object?>? specimen;
    if (testData != null && testData['specimen_id'] != null) {
      final specimenResult = db.select(
        'SELECT * FROM specimens WHERE id = ?',
        [testData['specimen_id']],
      );
      if (specimenResult.isNotEmpty) {
        specimen = specimenResult.first;
      }
    }

    // 4️⃣ Fetch report details and join with parameters
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

    // Map details
    final details = detailsResult.map((row) {
      final paramId = row['parameter_id'] ?? 0;
      final paramName =
          row['parameter_name'] ?? row['original_name'] ?? 'Unknown';
      final paramUnit = row['unit'] ?? row['original_unit'] ?? '';
      final paramRef = row['reference_value'] ?? '';
      final paramOptions = row['options']?.toString().split('\n') ?? [];

      // Use result if exists, otherwise first option or empty string
      final resultValue = row['result']?.toString().trim() ??
          (paramOptions.isNotEmpty ? paramOptions.first : '');

      return {
        "id": row['id'] ?? 0,
        "report_id": row['report_id'] ?? 0,
        "test_id": row['test_id'] ?? 0,
        "patient_id": row['patient_id'] ?? '',
        "invoice_id": row['invoice_id'] ?? '',
        "parameter_id": paramId,
        "parameter_name": paramName,
        "result": resultValue,
        "unit": paramUnit,
        "lower_value": row['lower_value'] ?? '',
        "upper_value": row['upper_value'] ?? '',
        "flag": row['flag'] ?? '',
        "lab_no": row['lab_no'] ?? '',
        "parameter_group_id": row['parameter_group_id']?.toString() ?? '0',
        "created_at": row['created_at'] ?? '',
        "updated_at": row['updated_at'] ?? '',
        "parameter": {
          "id": paramId,
          "parameter_name": paramName,
          "parameter_unit": paramUnit,
          "reference_value": paramRef,
          "options": paramOptions,
          "show_options": row['show_options'] ?? 0,
          "parameter_group_id": row['parameter_group_id']?.toString() ?? '0',
        }
      };
    }).toList();

    // 5️⃣ Fetch parameter groups for this test
    final parameterGroupsResult = db.select(
      'SELECT * FROM parameter_groups WHERE test_name_id = ?',
      [testId],
    );

    final parameterGroups = parameterGroupsResult.map((group) {
      final groupId = group['id'];

      // Get parameters for this group
      final parameters = db.select(
        'SELECT * FROM parameters WHERE parameter_group_id = ?',
        [groupId],
      );

      return {
        ...group,
        'parameter': parameters,
      };
    }).toList();

    // 6️⃣ Construct final report map
    final reportMap = {
      "id": reportRow['id'] ?? 0,
      "saas_branch_id": reportRow['saas_branch_id'] ?? 0,
      "saas_branch_name": reportRow['saas_branch_name'] ?? '',
      "invoice_id": reportRow['invoice_id'] ?? '',
      "invoice_no": reportRow['invoice_no'] ?? '',
      "patient_id": reportRow['patient_id'] ?? '',
      "test_id": reportRow['test_id'] ?? '',
      "test_name": reportRow['test_name'] ?? '',
      "test_group": reportRow['test_group'] ?? '',
      "test_category": reportRow['test_category'] ?? '',
      "gender": reportRow['gender'] ?? '',
      "technician_name": reportRow['technician_name'] ?? '',
      "technician_sign": reportRow['technician_sign'] ?? '',
      "validator": reportRow['validator'] ?? '',
      "report_confirm": reportRow['report_confirm'] ?? '',
      "status": reportRow['status'] ?? '0',
      "remark": reportRow['remark'] ?? '',
      "radiogyReportImage": reportRow['radiogyReportImage'],
      "radiologyReportDetails": reportRow['radiologyReportDetails'] ?? '',
      "created_at": reportRow['created_at'] ?? '',
      "updated_at": reportRow['updated_at'] ?? '',
      "specimen": specimen, // ✅ convert to JSON
      "details": details,
      "parameter_group": parameterGroups,
    };

    debugPrint(jsonEncode(
        {"status": 200, "message": "Lab reports", "report": reportMap}));

    return ReportInformationModel(
      status: 200,
      message: "Lab reports",
      report: Report.fromJson(reportMap),
    );
  }

  Future<void> saveTestReport({
    required String invoiceId,
    required String invoiceNo,
    required String invoiceApp,
    required String patientId,
    required String testId,
    required String testName,
    required String testGroup,
    required String testCategory,
    required String gender,
    String? technicianName,
    String? validator,
    String? status,
    String? remark,
    File? radiologyReportImage,
    String? radiologyReportDetails, // HTML string for Radiology
    List<Map<String, dynamic>>? parameterResults, // Pathology parameter results
  }) async {
    final DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final token = await LocalDB.getLoginInfo();

//   1️⃣ Save or update invoice_detail for this test
// Update only collection_status for this invoice and test
    db.execute('''
  UPDATE invoice_details
  SET report_add_status = ?
  WHERE invoice_id = ? AND test_id = ?
''', [
      1, // new collection_status
      invoiceNo,
      testId,
    ]);

    if (testGroup.toLowerCase() == "radiology") {
      // 2️⃣ Save Radiology report
      Uint8List? imageBytes;
      if (radiologyReportImage != null) {
        imageBytes = await radiologyReportImage.readAsBytes();
      }

      db.execute('''
      INSERT INTO lab_reports (
        invoice_id, invoice_no, patient_id, test_id, test_name,
        test_group, test_category, gender, technician_name, validator,
        remark,technician_name, radiogyReportImage, radiologyReportDetails, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    ''', [
        invoiceId,
        invoiceNo,
        patientId,
        testId,
        testName,
        testGroup,
        testCategory,
        gender,
        technicianName ?? "",
        validator ?? "",
        remark ?? "",
        token?['userName'],
        imageBytes,
        radiologyReportDetails ?? "",
      ]);
    } else if (parameterResults != null && parameterResults.isNotEmpty) {
      // 3️⃣ Save Pathology parameter results
      // First, insert lab report entry for reference
      db.execute('''
      INSERT INTO lab_reports (
        invoice_id, invoice_no, patient_id, test_id, test_name,
        test_group, test_category, gender, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    ''', [
        invoiceId,
        invoiceNo,
        patientId,
        testId,
        testName,
        testGroup,
        testCategory,
        gender,
      ]);

      // Get last inserted lab_report ID
      final labReportId =
          db.select('SELECT last_insert_rowid() AS id').first['id'] as int;

      final stmt = db.prepare('''
      INSERT INTO lab_report_details (
        report_id, test_id, patient_id, invoice_no,
        parameter_id,parameter_group_id, parameter_name, result, unit,
        lower_value, upper_value, flag, lab_no,
        created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    ''');

      try {
        for (var param in parameterResults) {
          stmt.execute([
            labReportId,
            testId,
            patientId,
            invoiceNo,
            param['id'],
            param['parameter_group_id'],
            param['parameter_name'] ?? "",
            param['result'],
            param['parameter_unit'] ?? "",
            param['lower_value'] ?? "",
            param['upper_value'] ?? "",
            param['flag'] ?? "",
            param['lab_no'] ?? "",
          ]);
        }
      } finally {
        stmt.dispose();
      }
    }

    debugPrint(
        'Report saved: Invoice #$invoiceNo, Test $testName ($testGroup)');
  }

  Future<void> updateReportDetails(
    List<Detail> details, {
    String? radiologyReportDetails,
    String? labReportId,
    File? radiologyReportImage,
  }) async {
    final db = await dbHelper.database;

    // Convert image file to Uint8List for BLOB
    Uint8List? imageBytes;
    if (radiologyReportImage != null) {
      imageBytes = await radiologyReportImage.readAsBytes();
    }

    db.execute('BEGIN TRANSACTION;');
    try {
      // 1. Update Pathology details
      final stmt = db.prepare('''
      UPDATE lab_report_details SET
        result = ?,
        flag = ?,
        parameter_id = ?,
        parameter_name = ?,
        unit = ?,
        lower_value = ?,
        upper_value = ?,
        parameter_group_id = ?
      WHERE id = ?
    ''');

      for (final detail in details) {
        if (detail.id == null) continue;

        stmt.execute([
          detail.result,
          detail.flag,
          detail.parameterId?.toString(),
          detail.parameterName,
          detail.unit,
          detail.lowerValue,
          detail.upperValue,
          detail.parameterGroupId,
          detail.id,
        ]);
      }
      stmt.dispose();

      // print("imageBytes: ${imageBytes}");
      // 2. Update Radiology in lab_reports table (if any)
      if (radiologyReportDetails != null || imageBytes != null) {
        // Here you need the correct report id
        final reportId =
            details.isNotEmpty ? details.first.reportId : labReportId;

        if (reportId != null) {
          final updateReportStmt = db.prepare('''
          UPDATE lab_reports SET
            radiologyReportDetails = COALESCE(?, radiologyReportDetails),
            radiogyReportImage = COALESCE(?, radiogyReportImage),
            updated_at = CURRENT_TIMESTAMP
          WHERE id = ?
        ''');
          updateReportStmt.execute([
            radiologyReportDetails,
            imageBytes,
            reportId,
          ]);
          updateReportStmt.dispose();
        }
      }

      db.execute('COMMIT;');
    } catch (e) {
      db.execute('ROLLBACK;');
      rethrow;
    }
  }

  /// Save a lab report and mark invoice detail as confirmed
  Future<void> saveLabReportAndConfirmInvoice({
    required String invoiceNo,
    required String testId,
  }) async {
    final db = await dbHelper.database;

    // 2️⃣ Update invoice_details.report_confirmed_status = '1'
    db.execute('''
      UPDATE invoice_details
      SET report_confirmed_status = '1'
      WHERE invoice_id = ? AND test_id = ?
    ''', [invoiceNo, testId]);

    debugPrint('Lab report saved and invoice detail marked as confirmed.');
  }
}
