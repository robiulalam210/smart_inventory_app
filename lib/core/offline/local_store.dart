import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Desktop এর local database (SQLite)।
///
/// Table গুলো:
/// - entities       : server থেকে নামানো master data (product, customer...) — server এর JSON হুবহু
/// - outbox         : offline এ করা কাজের queue (ক্রমানুসারে server এ যাবে)
/// - id_map         : offline (negative) id → server id
/// - response_cache : শেষ online GET response (offline এ report/list দেখানোর জন্য)
/// - meta           : cursor, device code, শেষ sync সময় ইত্যাদি
/// - sync_issues    : server যেসব offline কাজ নিতে পারেনি (stock শেষ ইত্যাদি)
int _firstInt(List<Map<String, Object?>> rows) =>
    rows.isEmpty || rows.first.isEmpty ? 0 : ((rows.first.values.first as num?)?.toInt() ?? 0);

class LocalStore {
  LocalStore._();
  static final LocalStore instance = LocalStore._();

  static const int _schemaVersion = 1;
  Database? _db;

  Database get db {
    final d = _db;
    if (d == null) throw StateError('LocalStore.open() আগে call করতে হবে');
    return d;
  }

  bool get isOpen => _db != null;

  Future<void> open() async {
    if (_db != null) return;
    sqfliteFfiInit();
    final dir = await getApplicationSupportDirectory();
    await Directory(dir.path).create(recursive: true);
    final path = p.join(dir.path, 'meherin_offline.db');
    _db = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _schemaVersion,
        onConfigure: (db) async {
          // WAL: লেখা চলাকালীন পড়া আটকায় না, আর হঠাৎ বিদ্যুৎ গেলে data নষ্ট হওয়ার ঝুঁকি কম
          await db.rawQuery('PRAGMA journal_mode=WAL');
          await db.execute('PRAGMA synchronous=NORMAL');
        },
        onCreate: (db, _) async => _createSchema(db),
      ),
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE entities (
        entity TEXT NOT NULL,
        id INTEGER NOT NULL,
        json TEXT NOT NULL,
        search TEXT NOT NULL DEFAULT '',
        is_active INTEGER NOT NULL DEFAULT 1,
        pending INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL,
        PRIMARY KEY (entity, id)
      )''');
    await db.execute('CREATE INDEX idx_entities_search ON entities(entity, search)');
    await db.execute('''
      CREATE TABLE outbox (
        seq INTEGER PRIMARY KEY AUTOINCREMENT,
        op_id TEXT NOT NULL UNIQUE,
        entity TEXT NOT NULL,
        method TEXT NOT NULL,
        path TEXT NOT NULL,
        local_id INTEGER,
        payload TEXT NOT NULL,
        user_id INTEGER,
        user_name TEXT,
        title TEXT,
        status TEXT NOT NULL DEFAULT 'pending',
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        server_id INTEGER,
        client_created_at TEXT NOT NULL,
        synced_at TEXT
      )''');
    await db.execute('CREATE INDEX idx_outbox_status ON outbox(status, seq)');
    await db.execute('''
      CREATE TABLE id_map (
        entity TEXT NOT NULL,
        local_id INTEGER NOT NULL,
        server_id INTEGER NOT NULL,
        PRIMARY KEY (entity, local_id)
      )''');
    await db.execute('''
      CREATE TABLE response_cache (
        key TEXT PRIMARY KEY,
        path TEXT NOT NULL,
        body TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )''');
    await db.execute('CREATE INDEX idx_cache_path ON response_cache(path)');
    await db.execute('CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT)');
    await db.execute('''
      CREATE TABLE sync_issues (
        op_id TEXT PRIMARY KEY,
        server_issue_id INTEGER,
        entity TEXT,
        issue_type TEXT,
        message TEXT,
        title TEXT,
        created_at TEXT
      )''');
  }

  // ---------------------------------------------------------------- meta
  Future<String?> getMeta(String key) async {
    final r = await db.query('meta', where: 'key = ?', whereArgs: [key], limit: 1);
    return r.isEmpty ? null : r.first['value'] as String?;
  }

  Future<void> setMeta(String key, String? value) async {
    await db.insert('meta', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Atomic counter (offline invoice / temporary id এর জন্য) — দুইবার একই নম্বর আসবে না
  Future<int> nextCounter(String key, {int start = 1}) async {
    return db.transaction((txn) async {
      final r = await txn.query('meta', where: 'key = ?', whereArgs: [key], limit: 1);
      final current = r.isEmpty ? start - 1 : int.tryParse('${r.first['value']}') ?? start - 1;
      final next = current + 1;
      await txn.insert('meta', {'key': key, 'value': '$next'}, conflictAlgorithm: ConflictAlgorithm.replace);
      return next;
    });
  }

  // ------------------------------------------------------------ entities
  static String _searchText(Map<String, dynamic> m) {
    final parts = <String>[];
    for (final k in ['name', 'phone', 'sku', 'email', 'username', 'first_name', 'last_name',
      'client_no', 'supplier_no', 'barcode', 'ac_name', 'ac_no', 'product_code']) {
      final v = m[k];
      if (v != null && '$v'.isNotEmpty) parts.add('$v'.toLowerCase());
    }
    return parts.join(' | ');
  }

  static int _activeFlag(Map<String, dynamic> m) {
    final v = m['is_active'] ?? m['status'];
    if (v == null) return 1;
    if (v is bool) return v ? 1 : 0;
    final s = '$v'.toLowerCase();
    return (s == 'false' || s == '0' || s == 'inactive') ? 0 : 1;
  }

  Future<void> upsertEntities(String entity, List<Map<String, dynamic>> items, {Transaction? txn}) async {
    final now = DateTime.now().toIso8601String();
    Future<void> run(DatabaseExecutor ex) async {
      final batch = ex.batch();
      for (final m in items) {
        final id = m['id'];
        if (id is! int) continue;
        batch.insert('entities', {
          'entity': entity, 'id': id, 'json': jsonEncode(m), 'search': _searchText(m),
          'is_active': _activeFlag(m), 'pending': id < 0 ? 1 : 0, 'updated_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    }
    if (txn != null) {
      await run(txn);
    } else {
      await db.transaction((t) => run(t));
    }
  }

  Future<void> deleteEntity(String entity, int id) =>
      db.delete('entities', where: 'entity = ? AND id = ?', whereArgs: [entity, id]);

  Future<void> replaceEntity(String entity, List<Map<String, dynamic>> items) async {
    // Full refresh: server এ নেই এমন পুরনো row মুছে যায় (কিন্তু offline pending row থাকে)
    await db.transaction((txn) async {
      await txn.delete('entities', where: 'entity = ? AND pending = 0', whereArgs: [entity]);
      await upsertEntities(entity, items, txn: txn);
    });
  }

  Future<List<Map<String, dynamic>>> queryEntities(
    String entity, {
    String? search,
    bool? isActive,
    Map<String, String> equals = const {},
  }) async {
    final where = <String>['entity = ?'];
    final args = <Object?>[entity];
    if (search != null && search.trim().isNotEmpty) {
      where.add('search LIKE ?');
      args.add('%${search.trim().toLowerCase()}%');
    }
    if (isActive != null) {
      where.add('is_active = ?');
      args.add(isActive ? 1 : 0);
    }
    final rows = await db.query('entities',
        columns: ['json'], where: where.join(' AND '), whereArgs: args, orderBy: 'pending DESC, id DESC');
    var list = rows.map((r) => jsonDecode(r['json'] as String) as Map<String, dynamic>).toList();
    if (equals.isNotEmpty) {
      list = list.where((m) => equals.entries.every((e) {
            final v = m[e.key] ?? m['${e.key}_id'];
            final vv = v is Map ? v['id'] : v;
            return '$vv' == e.value;
          })).toList();
    }
    return list;
  }

  Future<Map<String, dynamic>?> getEntity(String entity, int id) async {
    final r = await db.query('entities', columns: ['json'], where: 'entity = ? AND id = ?', whereArgs: [entity, id], limit: 1);
    return r.isEmpty ? null : jsonDecode(r.first['json'] as String) as Map<String, dynamic>;
  }

  Future<int> countEntities(String entity) async =>
      _firstInt(await db.rawQuery('SELECT COUNT(*) FROM entities WHERE entity = ?', [entity]));

  // -------------------------------------------------------------- outbox
  Future<void> enqueue(Map<String, Object?> row) async {
    await db.insert('outbox', row, conflictAlgorithm: ConflictAlgorithm.ignore); // একই op_id দুইবার ঢুকবে না
  }

  Future<List<Map<String, Object?>>> pendingOps({int limit = 25}) => db.query('outbox',
      where: "status IN ('pending','blocked','error')", orderBy: 'seq ASC', limit: limit);

  Future<List<Map<String, Object?>>> opsByStatus(List<String> statuses, {int limit = 200}) => db.query('outbox',
      where: 'status IN (${List.filled(statuses.length, '?').join(',')})',
      whereArgs: statuses, orderBy: 'seq ASC', limit: limit);

  Future<int> countOps(List<String> statuses) async => _firstInt(await db.rawQuery(
          'SELECT COUNT(*) FROM outbox WHERE status IN (${List.filled(statuses.length, '?').join(',')})', statuses));

  Future<void> updateOp(String opId, Map<String, Object?> values) =>
      db.update('outbox', values, where: 'op_id = ?', whereArgs: [opId]);

  Future<void> saveIdMap(String entity, int localId, int serverId) => db.insert(
      'id_map', {'entity': entity, 'local_id': localId, 'server_id': serverId},
      conflictAlgorithm: ConflictAlgorithm.replace);

  /// Offline এ যে পণ্য বিক্রি/ক্রয় হয়েছে কিন্তু এখনো server এ ওঠেনি — তার মোট পরিমাণ
  /// (product id → +ক্রয় −বিক্রি)। Stock দেখানো ও যাচাইয়ের সময় এটা হিসাবে ধরা হয়।
  Future<Map<int, double>> pendingStockDelta() async {
    final rows = await db.query('outbox',
        columns: ['entity', 'payload'],
        where: "entity IN ('sale','purchase') AND status NOT IN ('synced','dismissed','rejected')");
    final delta = <int, double>{};
    for (final r in rows) {
      final payload = jsonDecode(r['payload'] as String) as Map<String, dynamic>;
      final sign = r['entity'] == 'sale' ? -1.0 : 1.0;
      for (final item in (payload['items'] as List? ?? const [])) {
        if (item is! Map) continue;
        final pid = int.tryParse('${item['product_id'] ?? item['product']}');
        final qty = double.tryParse('${item['base_quantity'] ?? item['_base_qty'] ?? item['quantity'] ?? 0}') ?? 0;
        if (pid == null) continue;
        delta[pid] = (delta[pid] ?? 0) + sign * qty;
      }
    }
    return delta;
  }

  // -------------------------------------------------------- response cache
  Future<void> cacheResponse(String key, String path, String body) => db.insert('response_cache',
      {'key': key, 'path': path, 'body': body, 'cached_at': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace);

  Future<Map<String, Object?>?> cachedResponse(String key) async {
    final r = await db.query('response_cache', where: 'key = ?', whereArgs: [key], limit: 1);
    return r.isEmpty ? null : r.first;
  }

  /// একই path এর যেকোনো আগের response — offline এ JSON এর "আকৃতি" (wrapper) জানার জন্য
  Future<String?> templateFor(String path) async {
    final r = await db.query('response_cache',
        columns: ['body'], where: 'path = ?', whereArgs: [path], orderBy: 'cached_at DESC', limit: 1);
    return r.isEmpty ? null : r.first['body'] as String;
  }

  // ---------------------------------------------------------- sync issues
  Future<void> saveIssue(Map<String, Object?> row) =>
      db.insert('sync_issues', row, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> removeIssue(String opId) => db.delete('sync_issues', where: 'op_id = ?', whereArgs: [opId]);

  Future<List<Map<String, Object?>>> issues() => db.query('sync_issues', orderBy: 'created_at DESC');

  /// লগআউট: শুধু cache মুছবে, কিন্তু sync না হওয়া outbox কখনো মুছবে না
  Future<void> clearCaches() async {
    await db.delete('entities', where: 'pending = 0');
    await db.delete('response_cache');
  }
}
