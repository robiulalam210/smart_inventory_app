// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqlite3/sqlite3.dart';
// import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
//
// import 'database_migrations.dart';
//
// enum DatabaseState {
//   notInitialized,
//   initializing,
//   initialized,
//   error,
// }
//
// class DatabaseHelper {
//   final String databaseName;
//   Database? _db;
//   DatabaseState _state = DatabaseState.notInitialized;
//   final DatabaseMigrations _migrations = DatabaseMigrations();
//
//   DatabaseHelper({this.databaseName = 'mhp_billing.db'});
//
//   bool get isInitialized => _state == DatabaseState.initialized;
//
//   Future<Database> get database async {
//     if (_state != DatabaseState.initialized) {
//       await initDatabase();
//     }
//     if (_db == null) {
//       throw Exception("Database initialization failed.");
//     }
//     return _db!;
//   }
//
//   Future<void> initDatabase() async {
//     if (_state == DatabaseState.initialized) return;
//     _state = DatabaseState.initializing;
//
//     try {
//       await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
//       final Directory dir = await getApplicationSupportDirectory();
//       if (!await dir.exists()) {
//         await dir.create(recursive: true);
//       }
//
//       final String path = '${dir.path}/$databaseName';
//       debugPrint("Database Path: $path");
//
//       _db = sqlite3.open(path);
//       _state = DatabaseState.initialized;
//       debugPrint("Database opened successfully.");
//
//       await _createTables();
//       await _migrateTables();
//     } catch (e, stack) {
//       _state = DatabaseState.error;
//       debugPrint("Database initialization error: $e\n$stack");
//       rethrow;
//     }
//   }
//
//   void closeDatabase() {
//     _db?.dispose();
//     _db = null;
//     _state = DatabaseState.notInitialized;
//     debugPrint("Database closed.");
//   }
//
//   Future<void> _createTables() async {
//     final db = await database;
//
//     // ---------------- USERS ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS users (
//       id INTEGER PRIMARY KEY,
//       saas_user_id INTEGER,
//       name TEXT,
//       email TEXT UNIQUE NOT NULL,
//       phone TEXT,
//       password TEXT NOT NULL,
//       dbname TEXT NOT NULL,
//       token TEXT NOT NULL,
//       last_verify_date TEXT,
//       branch_id INTEGER,
//       branch_name TEXT,
//       bs_type TEXT,
//       user_id INTEGER,
//       user_type TEXT,
//       offline_login_expiry TEXT,
//       is_supper_admin INTEGER,
//       organization_name TEXT,
//       organization_address TEXT,
//       organization_logo_blob BLOB
//     );
//   ''');
//
//     // ---------------- PATIENTS ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS patients (
//       id INTEGER PRIMARY KEY,
//       org_patient_id INTEGER UNIQUE,
//       name TEXT NOT NULL,
//       phone TEXT NOT NULL,
//       age TEXT NOT NULL,
//       month TEXT NOT NULL,
//       day TEXT NOT NULL,
//       date_of_birth TEXT,
//       gender TEXT NOT NULL,
//       blood_group TEXT,
//       address TEXT,
//       visit_type TEXT,
//       hn_number TEXT,
//       create_date TEXT
//     );
//   ''');
//
//     // ---------------- DOCTORS ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS doctors (
//       id INTEGER PRIMARY KEY,
//       org_doctor_id INTEGER UNIQUE,
//       name TEXT NOT NULL,
//       phone TEXT NOT NULL,
//       age TEXT NOT NULL,
//       degree TEXT,
//       last_updated TEXT
//     );
//   ''');
//
//     // ---------------- TEST GROUPS ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS test_groups (
//       id INTEGER PRIMARY KEY,
//       saas_branch_id INTEGER,
//       saas_branch_name TEXT,
//       test_group_name TEXT NOT NULL,
//       created_at TEXT,
//       updated_at TEXT
//     )
//   ''');
//
//     // ---------------- TEST CATEGORIES ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS test_categories (
//       id INTEGER PRIMARY KEY,
//       org_test_category_id INTEGER UNIQUE,
//       name TEXT,
//       test_group_id INTEGER,
//       created_at TEXT,
//       updated_at TEXT,
//       FOREIGN KEY(test_group_id) REFERENCES test_groups(id) ON DELETE SET NULL
//     );
//   ''');
//
//     // ---------------- TEST NAMES ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS test_names (
//       id INTEGER PRIMARY KEY,
//       test_category_id INTEGER NOT NULL,
//       org_test_name_id INTEGER UNIQUE,
//       name TEXT NOT NULL,
//       code TEXT,
//       fee REAL,
//       discount_applied INTEGER DEFAULT 0,
//       discount REAL,
//       test_group_id INTEGER,
//       test_sub_category_id INTEGER,
//       parameter_group_id INTEGER,
//       specimen_id INTEGER,
//       status TEXT,
//       hide_test_name INTEGER DEFAULT 0,
//       created_at TEXT,
//       test_category_name TEXT,
//       test_group_name TEXT,
//       test_sub_category_name TEXT,
//       FOREIGN KEY(test_category_id) REFERENCES test_categories(org_test_category_id) ON DELETE SET NULL
//     );
//   ''');
//
//     // ---------------- PARAMETER GROUPS ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS parameter_groups (
//       id INTEGER PRIMARY KEY,
//       test_name_id INTEGER NOT NULL,
//       group_name TEXT NOT NULL,
//       hidden INTEGER DEFAULT 0,
//       created_at TEXT,
//       updated_at TEXT,
//       FOREIGN KEY(test_name_id) REFERENCES test_names(org_test_name_id) ON DELETE CASCADE
//     );
//   ''');
//
//     // ---------------- PARAMETERS ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS parameters (
//       id INTEGER PRIMARY KEY,
//       test_id INTEGER NOT NULL,
//       parameter_name TEXT NOT NULL,
//       parameter_unit TEXT,
//       reference_value TEXT,
//       show_options INTEGER DEFAULT 0,
//       options TEXT,
//       parameter_group_id INTEGER,
//       created_at TEXT,
//       updated_at TEXT,
//       FOREIGN KEY(test_id) REFERENCES test_names(org_test_name_id) ON DELETE CASCADE,
//       FOREIGN KEY(parameter_group_id) REFERENCES parameter_groups(id) ON DELETE SET NULL
//     );
//   ''');
//
//     // ---------------- TEST PARAMETERS ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS test_parameters (
//       id INTEGER PRIMARY KEY,
//       parameter_id INTEGER NOT NULL,
//       gender TEXT,
//       minimum_age INTEGER,
//       maximum_age INTEGER,
//       lower_value TEXT,
//       upper_value TEXT,
//       normal_value TEXT,
//       in_words TEXT,
//       test_name_id INTEGER NOT NULL,
//       created_at TEXT,
//       updated_at TEXT,
//       FOREIGN KEY(parameter_id) REFERENCES parameters(id) ON DELETE CASCADE,
//       FOREIGN KEY(test_name_id) REFERENCES test_names(org_test_name_id) ON DELETE CASCADE
//     );
//   ''');
//
//     // ---------------- TEST NAME CONFIGS ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS test_name_configs (
//       id INTEGER PRIMARY KEY,
//       test_name_id INTEGER NOT NULL,
//       parameter_id INTEGER NOT NULL,
//       child_lower_value TEXT,
//       child_upper_value TEXT,
//       child_normal_value TEXT,
//       male_lower_value TEXT,
//       male_upper_value TEXT,
//       male_normal_value TEXT,
//       female_lower_value TEXT,
//       female_upper_value TEXT,
//       female_normal_value TEXT,
//       created_at TEXT,
//       updated_at TEXT,
//       FOREIGN KEY(test_name_id) REFERENCES test_names(org_test_name_id) ON DELETE CASCADE,
//       FOREIGN KEY(parameter_id) REFERENCES parameters(id) ON DELETE CASCADE
//     );
//   ''');
//
//     // ---------------- PARAMETER VALUES ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS parameter_values (
//       id INTEGER PRIMARY KEY,
//       parameter_id INTEGER NOT NULL,
//       gender TEXT,
//       minimum_age INTEGER DEFAULT 0,
//       maximum_age INTEGER DEFAULT 120,
//       lower_value REAL,
//       upper_value REAL,
//       normal_value TEXT,
//       in_words TEXT,
//       test_name_id INTEGER,
//       created_at TEXT,
//       updated_at TEXT,
//       FOREIGN KEY(parameter_id) REFERENCES parameters(id) ON DELETE CASCADE
//     );
//   ''');
//
//     // ---------------- GENDERS ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS genders (
//       id INTEGER PRIMARY KEY,
//       original_id INTEGER UNIQUE,
//       name TEXT NOT NULL UNIQUE
//     );
//   ''');
//
//     // ---------------- BLOOD GROUPS ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS blood_groups (
//       id INTEGER PRIMARY KEY,
//       original_id INTEGER UNIQUE,
//       name TEXT NOT NULL UNIQUE
//     );
//   ''');
//
//     // ---------------- INVENTORY ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS inventory (
//       id INTEGER PRIMARY KEY,
//       webId TEXT UNIQUE,
//       item_code TEXT,
//       name TEXT,
//       price REAL
//     );
//   ''');
//
//     // ---------------- INVOICES ----------------
//     db.execute('''
//       CREATE TABLE IF NOT EXISTS invoices (
//         id INTEGER PRIMARY KEY,
//         webId TEXT UNIQUE,
//         patient_id TEXT,
//         patient_web_id TEXT,
//         invoice_number TEXT NOT NULL UNIQUE,     -- ✅ web ID is authoritative
//         invoice_number_local TEXT,               -- ❌ removed UNIQUE constraint
//         update_date TEXT,
//         delivery_date TEXT NOT NULL,
//         delivery_time TEXT,
//         create_date TEXT,
//         create_date_at_web TEXT,
//         update_date_at_web TEXT,
//         total_bill_amount REAL NOT NULL,
//         due REAL NOT NULL,
//         paid_amount REAL NOT NULL,
//         discount_type TEXT,
//         discount REAL NOT NULL,
//         discount_percentage REAL,
//         refer_type TEXT NOT NULL,
//         referre_id_or_desc TEXT,
//         created_by_user_id INTEGER,
//         created_by_name TEXT,
//         billingComment TEXT,
//         sample_collection_remark TEXT,
//         collection_status INTEGER DEFAULT 0 CHECK(collection_status IN (0, 1, 2)),
//         sent_to_lab_status INTEGER DEFAULT 0 CHECK(sent_to_lab_status IN (0, 1)),
//         delivery_status INTEGER DEFAULT 0 CHECK(delivery_status IN (0, 1)),
//         report_collection_status INTEGER DEFAULT 0 CHECK(report_collection_status IN (0, 1)),
//         FOREIGN KEY(patient_id) REFERENCES patients(id) ON DELETE CASCADE,
//         FOREIGN KEY(referre_id_or_desc) REFERENCES doctors(id) ON DELETE SET NULL,
//         FOREIGN KEY(created_by_user_id) REFERENCES users(saas_user_id) ON DELETE SET NULL
//       );
//       CREATE INDEX IF NOT EXISTS idx_invoice_local ON invoices(invoice_number_local);
//
//         ''');
//
//     // ---------------- INVOICE DETAILS ----------------
//     // Invoice details
//     db.execute('''
//         CREATE TABLE IF NOT EXISTS invoice_details (
//             id INTEGER PRIMARY KEY,
//             invoice_id INTEGER NOT NULL,
//             invoice_number_local TEXT,
//             test_id INTEGER,
//             inventory_id INTEGER,
//             fee REAL NOT NULL,
//             qty INTEGER DEFAULT 1,
//             is_refund INTEGER DEFAULT 0,
//             discount_applied INTEGER DEFAULT 1,
//             discount REAL,
//
//             collection_date TEXT,
//             collector_id INTEGER DEFAULT NULL,
//             collector_name TEXT,
//             booth_id INTEGER DEFAULT NULL,
//             collection_status INTEGER DEFAULT 0 CHECK(collection_status IN (0,1,2)),
//             remark TEXT,
//             is_offline_sync INTEGER DEFAULT 0,
//
//
//             -- ✅ Report / Delivery Status Columns
//             report_confirmed_status TEXT,
//             report_approve_status TEXT,
//             report_add_status TEXT,
//             delivery_status TEXT,
//             sent_to_lab_status TEXT,
//             reportCollectionStatus TEXT,
//             point TEXT,
//             point_percent TEXT,
//             status TEXT,
//
//             -- ✅ Foreign Keys
//             FOREIGN KEY(invoice_id) REFERENCES invoices(invoice_number) ON DELETE CASCADE,
//             FOREIGN KEY(test_id) REFERENCES test_names(org_test_name_id) ON DELETE CASCADE,
//             FOREIGN KEY(inventory_id) REFERENCES inventory(webId) ON DELETE SET NULL,
//
//             -- ✅ Unique constraints
//             UNIQUE(invoice_id, test_id),
//             UNIQUE(invoice_id, inventory_id)
//         );
//
//           ''');
//
//
//     // ---------------- PAYMENTS ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS payments (
//       id INTEGER PRIMARY KEY,
//       web_id TEXT UNIQUE,
//       money_receipt_number TEXT UNIQUE,
//       money_receipt_type TEXT,
//       patient_id INTEGER,
//       patient_web TEXT,
//       invoice_number TEXT,
//       invoice_number_local TEXT,
//       invoice_id INTEGER,
//       payment_type TEXT,
//       requested_amount REAL,
//       total_amount_paid REAL,
//       due_amount REAL,
//       new_discount REAL,
//       amount REAL,
//       payment_date TEXT,
//       is_sync INTEGER DEFAULT 0,
//       FOREIGN KEY(invoice_number) REFERENCES invoices(invoice_number),
//       FOREIGN KEY(patient_id) REFERENCES patients(id)
//     );
//   ''');
//
//     // ---------------- Payment  Case Effects ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS case_effects (
//       id INTEGER PRIMARY KEY,
//       web_id INTEGER UNIQUE,
//       money_receipt_id INTEGER,
//       amount REAL,
//       FOREIGN KEY(money_receipt_id) REFERENCES payments(web_id)
//     );
//     ''');
//         // ---------------- Marketers ----------------
//     db.execute('''
//       CREATE TABLE IF NOT EXISTS marketers (
//           id INTEGER PRIMARY KEY,
//           name TEXT,
//           marketer_id TEXT UNIQUE,
//           marketer_group_id INTEGER,
//           marketer_group_name TEXT,
//           phone TEXT,
//           email TEXT,
//           address TEXT
//       );
//     ''');
//
//
//
//     // ---------------- LAB REPORTS ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS lab_reports (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       web_id TEXT UNIQUE,
//       saas_branch_id INTEGER,
//       saas_branch_name TEXT,
//       invoice_id TEXT,
//       invoice_no TEXT,
//       invoice_number_local TEXT,
//       patient_id TEXT,
//       test_id TEXT,
//       test_name TEXT,
//       test_group TEXT,
//       test_category TEXT,
//       gender TEXT,
//       technician_name TEXT,
//       technician_sign TEXT,
//       validator TEXT,
//       report_confirm TEXT,
//       status INTEGER DEFAULT 0,
//       remark TEXT,
//       radiogyReportImage BLOB,
//       radiologyReportDetails TEXT,
//       created_at TEXT DEFAULT CURRENT_TIMESTAMP,
//       updated_at TEXT DEFAULT CURRENT_TIMESTAMP
//     );
//   ''');
//
//     // ---------------- REPORT DETAILS ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS lab_report_details (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       saas_branch_id INTEGER,
//       saas_branch_name TEXT,
//       report_id INTEGER,
//       web_report_id,
//       test_id TEXT,
//       patient_id TEXT,
//       invoice_no TEXT,
//       invoice_number_local TEXT,
//       parameter_id TEXT,
//       parameter_name TEXT,
//       result TEXT,
//       unit TEXT,
//       lower_value TEXT,
//       upper_value TEXT,
//       flag TEXT,
//       lab_no TEXT,
//       parameter_group_id TEXT,
//       created_at TEXT DEFAULT CURRENT_TIMESTAMP,
//       updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
//       FOREIGN KEY(report_id) REFERENCES lab_reports(id) ON DELETE CASCADE
//     );
//   ''');
//
//
//     // ---------------- REPORT Delivery Info ----------------
//     db.execute('''
//    CREATE TABLE IF NOT EXISTS mhp_great_lab_report_delivery_infos (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       saas_branch_id  INTEGER,
//       saas_branch_name TEXT,
//       invoiceNo       TEXT,
//       invoice_number_local TEXT,
//       patient_id      TEXT,
//       deliveryTime    TEXT,
//       deliveryDate    TEXT,
//       fileUpload      TEXT,
//       followUpDate    TEXT,
//       followUpComment TEXT,
//       testList        TEXT,
//       collectedBy     TEXT,
//       remark          TEXT,
//       created_at      TEXT,
//       updated_at      TEXT
//     );
// ''');
//
//
//   //   // ---------------- CENTER ----------------
//   //   db.execute('''
//   //   CREATE TABLE IF NOT EXISTS center (
//   //     id INTEGER PRIMARY KEY,
//   //     saas_branch_id INTEGER,
//   //     saas_branch_name TEXT,
//   //     email TEXT,
//   //     name TEXT NOT NULL,
//   //     address1 TEXT,
//   //     address2 TEXT,
//   //     city_id TEXT,
//   //     postal_code TEXT,
//   //     country_id TEXT,
//   //     phone TEXT,
//   //     mobile TEXT,
//   //     service TEXT,
//   //     created_at TEXT,
//   //     updated_at TEXT,
//   //     city_name TEXT,
//   //     country_name TEXT
//   //   );
//   // ''');
//
//     // ---------------- COLLECTORS ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS collectors (
//       id INTEGER PRIMARY KEY,
//       name TEXT NOT NULL,
//       phone TEXT NOT NULL,
//       email TEXT,
//       saas_branch_id INTEGER,
//       saas_branch_name TEXT,
//       address TEXT,
//       created_at TEXT,
//       updated_at TEXT
//     );
//   ''');
//
//     // ---------------- BOOTHS ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS booths (
//       id INTEGER PRIMARY KEY,
//       saas_branch_id INTEGER,
//       saas_branch_name TEXT,
//       branch_id INTEGER NOT NULL,
//       name TEXT NOT NULL,
//       booth_no TEXT,
//       status TEXT,
//       created_at TEXT,
//       updated_at TEXT
//     );
//   ''');
//
//     // ---------------- PRINT LAYOUTS ----------------
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS print_layouts (
//       id INTEGER PRIMARY KEY,
//       layout_name TEXT,
//       page_size TEXT,
//       orientation TEXT,
//       billing TEXT,
//       letter TEXT,
//       sticker TEXT,
//       created_at TEXT,
//       updated_at TEXT
//     );
//   ''');
//     // ---------------- specimens ----------------
//
//     db.execute('''
//     CREATE TABLE IF NOT EXISTS specimens (
//       id INTEGER PRIMARY KEY,
//       saas_branch_id INTEGER,
//       saas_branch_name TEXT,
//       name TEXT NOT NULL,
//       created_at TEXT,
//       updated_at TEXT
//     );
//   ''');
//
//     debugPrint("✅ All tables created successfully.");
//   }
//
//
//   Future<void> _migrateTables() async {
//     final db = await database;
//     await _migrations.runMigrations(db);
//   }
// }
