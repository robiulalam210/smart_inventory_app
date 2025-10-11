import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseMigrations {
  Future<int> getSchemaVersion(Database db) async {
    try {
      final result = db.select('PRAGMA user_version;');
      return result.first['user_version'] as int;
    } catch (_) {
      return 0;
    }
  }

  Future<void> setSchemaVersion(Database db, int version) async {
    db.execute('PRAGMA user_version = $version;');
  }

  /// Runs all migrations based on current version
  Future<void> runMigrations(Database db) async {
    final version = await getSchemaVersion(db);
    debugPrint('Current DB version: $version');

    final migrations = [
      _Migration(2, _migrateCenterTable),
      _Migration(3, _migrateOrganizationColumns),
    ];

    for (final migration in migrations) {
      if (version < migration.version) {
        debugPrint('Applying migration to version ${migration.version}');
        await migration.migrate(db);
        await setSchemaVersion(db, migration.version);
      }
    }
  }

  // === MIGRATION STEPS ===

  Future<void> _migrateCenterTable(Database db) async {
    final tables = db.select("SELECT name FROM sqlite_master WHERE type='table' AND name='center';");
    if (tables.isEmpty) {
      debugPrint('[Migration] Creating center table');
      db.execute('''
        CREATE TABLE center (
          id INTEGER PRIMARY KEY,
          saas_branch_id INTEGER,
          saas_branch_name TEXT,
          email TEXT,
          name TEXT NOT NULL,
          address1 TEXT,
          address2 TEXT,
          city_id TEXT,
          postal_code TEXT,
          country_id TEXT,
          phone TEXT,
          mobile TEXT,
          service TEXT,
          created_at TEXT,
          updated_at TEXT,
          city_name TEXT,
          country_name TEXT
        );
      ''');
    }
  }


  Future<void> _migrateOrganizationColumns(Database db) async {
    final columns = db.select('PRAGMA table_info(users);');

    if (!columns.any((col) => col['name'] == 'organization_name')) {
      db.execute('ALTER TABLE users ADD COLUMN organization_name TEXT;');
    }
    if (!columns.any((col) => col['name'] == 'organization_address')) {
      db.execute('ALTER TABLE users ADD COLUMN organization_address TEXT;');
    }
    if (!columns.any((col) => col['name'] == 'organization_logo_blob')) {
      db.execute('ALTER TABLE users ADD COLUMN organization_logo_blob BLOB;');
    }

    final testCols = db.select('PRAGMA table_info(test_names);');

    if (!testCols.any((col) => col['name'] == 'test_category_name')) {
      db.execute('ALTER TABLE test_names ADD COLUMN test_category_name TEXT;');
    }
    if (!testCols.any((col) => col['name'] == 'test_group_name')) {
      db.execute('ALTER TABLE test_names ADD COLUMN test_group_name TEXT;');
    }
    if (!testCols.any((col) => col['name'] == 'test_sub_category_name')) {
      db.execute('ALTER TABLE test_names ADD COLUMN test_sub_category_name TEXT;');
    }  if (!testCols.any((col) => col['name'] == 'org_test_name_id')) {
      db.execute('ALTER TABLE test_names ADD COLUMN org_test_name_id INTEGER;');
    }

  }
}

class _Migration {
  final int version;
  final Future<void> Function(Database db) migrate;

  _Migration(this.version, this.migrate);
}
