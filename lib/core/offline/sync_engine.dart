import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../configs/app_urls.dart';
import '../database/login.dart';
import 'connectivity_monitor.dart';
import 'local_store.dart';
import 'offline_config.dart';
import 'stock_alerts.dart';
import 'uuid_v4.dart';

enum SyncPhase { idle, setup, syncing, error }

@immutable
class SyncSnapshot {
  final SyncPhase phase;
  final int pending;
  final int issues;
  final DateTime? lastSyncAt;
  final String? lastError;
  final double setupProgress; // 0..1
  final String setupLabel;
  final bool setupDone;

  const SyncSnapshot({
    this.phase = SyncPhase.idle,
    this.pending = 0,
    this.issues = 0,
    this.lastSyncAt,
    this.lastError,
    this.setupProgress = 0,
    this.setupLabel = '',
    this.setupDone = false,
  });

  SyncSnapshot copyWith({
    SyncPhase? phase,
    int? pending,
    int? issues,
    DateTime? lastSyncAt,
    String? lastError,
    bool clearError = false,
    double? setupProgress,
    String? setupLabel,
    bool? setupDone,
  }) =>
      SyncSnapshot(
        phase: phase ?? this.phase,
        pending: pending ?? this.pending,
        issues: issues ?? this.issues,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        lastError: clearError ? null : (lastError ?? this.lastError),
        setupProgress: setupProgress ?? this.setupProgress,
        setupLabel: setupLabel ?? this.setupLabel,
        setupDone: setupDone ?? this.setupDone,
      );
}

class SyncResult {
  final int pushed;
  final int pulled;
  final int newIssues;
  final String? error;
  const SyncResult({this.pushed = 0, this.pulled = 0, this.newIssues = 0, this.error});
  bool get ok => error == null;
}

class SyncHttpException implements Exception {
  final int status;
  final String message;
  SyncHttpException(this.status, this.message);
  @override
  String toString() => message;
}

/// Desktop sync এর মস্তিষ্ক।
///
/// - প্রথমবার: [runInitialSetup] — progress সহ সব master data নামায় (user দেখে কী হচ্ছে)।
/// - এরপর: [start] — internet এলে, প্রতি ২ মিনিটে, আর নতুন offline entry হলে চুপচাপ sync।
///   কোনো popup নেই — শুধু header এর ছোট chip এ অবস্থা দেখা যায়।
/// - Manual: [syncNow] (manual: true) — Sync Center এর বাটন।
class SyncEngine {
  SyncEngine._();
  static final SyncEngine instance = SyncEngine._();

  final ValueNotifier<SyncSnapshot> state = ValueNotifier(const SyncSnapshot());

  Timer? _timer;
  Timer? _kickTimer;
  bool _running = false;
  bool _started = false;

  LocalStore get _store => LocalStore.instance;

  // ------------------------------------------------------------- lifecycle
  void start() {
    if (_started || !OfflineConfig.enabled) return;
    _started = true;
    ConnectivityMonitor.instance.online.addListener(_onConnectivity);
    _timer = Timer.periodic(OfflineConfig.autoSyncInterval, (_) => _auto());
    _refreshCounts();
    _auto();
  }

  void stop() {
    _timer?.cancel();
    _kickTimer?.cancel();
    ConnectivityMonitor.instance.online.removeListener(_onConnectivity);
    _started = false;
  }

  void _onConnectivity() {
    if (ConnectivityMonitor.instance.isOnline) _auto();
  }

  /// নতুন offline entry হলে ৩ সেকেন্ড পরে sync (একসাথে কয়েকটা entry হলে একবারই)
  void kick() {
    _kickTimer?.cancel();
    _kickTimer = Timer(const Duration(seconds: 3), _auto);
  }

  Future<void> _auto() async {
    if (!ConnectivityMonitor.instance.isOnline) return;
    if (!await isSetupDone()) return;
    await syncNow();
  }

  Future<bool> isSetupDone() async {
    if (!_store.isOpen) return false;
    final done = await _store.getMeta('setup_done') == '1';
    // একটাই ব্যবসা — সব user এর data এক, তাই অন্য user login করলেও আবার setup লাগে না
    final valid = done;
    if (state.value.setupDone != valid) state.value = state.value.copyWith(setupDone: valid);
    return valid;
  }

  // ------------------------------------------------------------------ HTTP
  Future<Map<String, String>> _headers() async {
    final login = await LocalDB.getLoginInfo();
    final deviceId = await _deviceId();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${login?['token'] ?? ''}',
      'X-Device-Id': deviceId,
      'X-Client-Source': 'desktop',
    };
  }

  Future<String> _deviceId() async {
    var id = await _store.getMeta('device_id');
    if (id == null) {
      id = uuidV4();
      await _store.setMeta('device_id', id);
    }
    return id;
  }

  Future<Map<String, dynamic>> _api(String method, String path,
      {Map<String, String>? query, Object? body, bool retried = false}) async {
    final uri = Uri.parse('${AppUrls.baseUrl}$path').replace(queryParameters: query);
    http.Response res;
    try {
      final h = await _headers();
      final timeout = const Duration(seconds: 60);
      res = method == 'GET'
          ? await http.get(uri, headers: h).timeout(timeout)
          : await http.post(uri, headers: h, body: jsonEncode(body ?? {})).timeout(timeout);
    } on SocketException {
      ConnectivityMonitor.instance.markOffline();
      throw SyncHttpException(0, 'Server এ পৌঁছানো যাচ্ছে না');
    } on TimeoutException {
      throw SyncHttpException(0, 'Server সাড়া দিচ্ছে না (timeout)');
    }

    if (res.statusCode == 401 && !retried) {
      // Token expire — চুপচাপ নতুন token নিয়ে আবার চেষ্টা
      if (await SessionKeeper.renew()) return _api(method, path, query: query, body: body, retried: true);
      throw SyncHttpException(401, 'Session শেষ — আবার login করুন');
    }
    dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      throw SyncHttpException(res.statusCode, 'Server error (${res.statusCode})');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = decoded is Map ? '${decoded['message'] ?? decoded['detail'] ?? 'Error'}' : 'Error';
      throw SyncHttpException(res.statusCode, msg);
    }
    return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
  }

  // ----------------------------------------------------------------- setup
  Future<void> registerDevice() async {
    final deviceId = await _deviceId();
    final res = await _api('POST', '/sync/devices/register/', body: {
      'device_id': deviceId,
      'name': Platform.localHostname,
      'platform': Platform.operatingSystem,
      'app_version': AppUrls.currentVersion,
    });
    final data = res['data'] as Map<String, dynamic>? ?? const {};
    await _store.setMeta('device_code', '${data['device_code'] ?? ''}');
  }

  /// প্রথমবার: সব data নামানো। User পুরো অগ্রগতি দেখে।
  Future<void> runInitialSetup() async {
    if (_running) return;
    _running = true;
    state.value = state.value.copyWith(phase: SyncPhase.setup, setupProgress: 0, setupLabel: 'Server এর সাথে যুক্ত হচ্ছে…', clearError: true);
    try {
      if (!await ConnectivityMonitor.instance.probe()) {
        throw SyncHttpException(0, 'প্রথম setup এর জন্য internet দরকার');
      }
      await registerDevice();

      state.value = state.value.copyWith(setupLabel: 'কী কী data লাগবে দেখা হচ্ছে…', setupProgress: 0.02);
      final manifest = (await _api('GET', '/sync/manifest/'))['data'] as Map<String, dynamic>;
      final cursor = manifest['cursor'];
      final entities = (manifest['entities'] as List).cast<Map<String, dynamic>>();
      final total = entities.fold<int>(0, (s, e) => s + ((e['count'] as num?)?.toInt() ?? 0));
      var done = 0;

      for (final e in entities) {
        final entity = '${e['entity']}';
        final label = OfflineConfig.entityLabels[entity] ?? entity;
        final items = <Map<String, dynamic>>[];
        var page = 1;
        while (true) {
          state.value = state.value.copyWith(
            setupLabel: '$label নামানো হচ্ছে… (${items.length}/${e['count']})',
            setupProgress: 0.05 + 0.85 * (total == 0 ? 1 : done / total),
          );
          final res = (await _api('GET', '/sync/bootstrap/',
              query: {'entity': entity, 'page': '$page', 'page_size': '500'}))['data'] as Map<String, dynamic>;
          final batch = (res['items'] as List).cast<Map<String, dynamic>>();
          items.addAll(batch);
          done += batch.length;
          if (res['has_more'] != true) break;
          page++;
        }
        await _store.replaceEntity(entity, items);
      }

      state.value = state.value.copyWith(setupLabel: 'Screen গুলোর জন্য প্রস্তুত করা হচ্ছে…', setupProgress: 0.92);
      await _primeTemplates();

      final login = await LocalDB.getLoginInfo();
      await _store.setMeta('cursor', '$cursor');
      await _store.setMeta('setup_done', '1');
      await _store.setMeta('setup_user', '${login?['email'] ?? ''}');
      await _store.setMeta('last_full_refresh', DateTime.now().toIso8601String());

      state.value = state.value.copyWith(setupLabel: 'শেষ ধাপ…', setupProgress: 0.97);
      await _pull();
      await _store.setMeta('last_sync_at', DateTime.now().toIso8601String());
      await StockAlerts.instance.refresh();

      state.value = state.value.copyWith(
        phase: SyncPhase.idle, setupProgress: 1, setupLabel: 'সম্পন্ন', setupDone: true, lastSyncAt: DateTime.now());
      await _refreshCounts();
    } catch (e) {
      state.value = state.value.copyWith(phase: SyncPhase.error, lastError: '$e');
      rethrow;
    } finally {
      _running = false;
    }
  }

  /// প্রতিটা list screen এর JSON wrapper এর "আকৃতি" জেনে রাখা — offline এ একই আকৃতিতে উত্তর দিতে
  Future<void> _primeTemplates() async {
    final paths = OfflineConfig.readPaths.keys.toSet();
    for (final path in paths) {
      try {
        final uri = Uri.parse('${AppUrls.baseUrl}${path.substring(4)}');
        final res = await http.get(uri, headers: await _headers()).timeout(const Duration(seconds: 30));
        if (res.statusCode >= 200 && res.statusCode < 300) {
          await _store.cacheResponse('$path?', path, utf8.decode(res.bodyBytes));
        }
      } catch (_) {/* কোনো একটা না পেলে সমস্যা নেই — default আকৃতি ব্যবহার হবে */}
    }
  }

  // ------------------------------------------------------------------ sync
  /// manual = true হলে ফলাফল ফেরত দেয় (UI toast দেখায়); auto sync চুপচাপ চলে।
  Future<SyncResult> syncNow({bool manual = false}) async {
    if (_running) return const SyncResult(error: 'Sync ইতিমধ্যে চলছে');
    if (!await isSetupDone()) return const SyncResult(error: 'প্রথম setup এখনো হয়নি');
    if (manual && !await ConnectivityMonitor.instance.probe()) {
      return const SyncResult(error: 'Internet সংযোগ নেই — সংযোগ এলে নিজে থেকেই sync হবে');
    }
    if (!ConnectivityMonitor.instance.isOnline) return const SyncResult(error: 'Offline');

    _running = true;
    state.value = state.value.copyWith(phase: SyncPhase.syncing, clearError: true);
    try {
      final pushed = await _push();
      final issuesBefore = state.value.issues;
      await _refreshServerIssues();
      final pulled = await _pull();
      await _maybeFullRefresh();
      await _store.setMeta('last_sync_at', DateTime.now().toIso8601String());
      await StockAlerts.instance.refresh();
      await _refreshCounts();
      state.value = state.value.copyWith(phase: SyncPhase.idle, lastSyncAt: DateTime.now());
      return SyncResult(pushed: pushed, pulled: pulled, newIssues: (state.value.issues - issuesBefore).clamp(0, 1 << 30));
    } catch (e) {
      state.value = state.value.copyWith(phase: SyncPhase.error, lastError: '$e');
      await _refreshCounts();
      return SyncResult(error: '$e');
    } finally {
      _running = false;
    }
  }

  Map<String, dynamic> _cleanPayload(Map<String, dynamic> p) {
    dynamic clean(dynamic v) {
      if (v is Map) {
        return {
          for (final e in v.entries)
            if (!'${e.key}'.startsWith('_')) '${e.key}': clean(e.value),
        };
      }
      if (v is List) return v.map(clean).toList();
      return v;
    }
    return Map<String, dynamic>.from(clean(p) as Map);
  }

  /// Offline queue → server, ক্রমানুসারে। প্রতিটার ফলাফল আলাদা করে সংরক্ষণ।
  Future<int> _push() async {
    var pushedTotal = 0;
    final deviceId = await _deviceId();
    for (var round = 0; round < 40; round++) {
      final ops = await _store.pendingOps(limit: OfflineConfig.pushBatchSize);
      if (ops.isEmpty) break;
      final payload = ops
          .map((o) => {
                'op_id': o['op_id'],
                'method': o['method'],
                'path': o['path'],
                'local_id': o['local_id'],
                'user_id': o['user_id'],
                'client_created_at': o['client_created_at'],
                'payload': _cleanPayload(jsonDecode(o['payload'] as String) as Map<String, dynamic>),
              })
          .toList();
      final res = await _api('POST', '/sync/push/', body: {'device_id': deviceId, 'ops': payload});
      final results = ((res['data'] as Map)['results'] as List).cast<Map<String, dynamic>>();

      var progress = 0;
      final byId = {for (final o in ops) '${o['op_id']}': o};
      for (final r in results) {
        final opId = '${r['op_id']}';
        final op = byId[opId];
        if (op == null) continue;
        final status = '${r['status']}';
        final now = DateTime.now().toIso8601String();
        switch (status) {
          case 'applied':
          case 'duplicate':
            progress++;
            pushedTotal++;
            final serverId = (r['server_id'] as num?)?.toInt();
            await _store.updateOp(opId, {'status': 'synced', 'server_id': serverId, 'synced_at': now, 'last_error': null});
            final localId = (op['local_id'] as num?)?.toInt();
            if (localId != null && serverId != null) {
              await _store.saveIdMap('${op['entity']}', localId, serverId);
              if (op['entity'] == 'customer') await _store.deleteEntity('customer', localId);
            }
            await _store.removeIssue(opId);
            break;
          case 'stock_conflict':
          case 'rejected':
            progress++;
            await _store.updateOp(opId, {'status': 'issue', 'last_error': '${r['message']}'});
            await _store.saveIssue({
              'op_id': opId,
              'entity': op['entity'],
              'issue_type': status,
              'message': '${r['message']}',
              'title': op['title'],
              'created_at': now,
            });
            break;
          case 'blocked':
            await _store.updateOp(opId, {'status': 'blocked', 'last_error': '${r['message']}', 'attempts': ((op['attempts'] as int?) ?? 0) + 1});
            break;
          default:
            await _store.updateOp(opId, {'status': 'error', 'last_error': '${r['message']}', 'attempts': ((op['attempts'] as int?) ?? 0) + 1});
        }
      }
      if (progress == 0) break; // সব blocked/error — পরের sync এ আবার চেষ্টা হবে
    }
    return pushedTotal;
  }

  /// Server → desktop: শেষ cursor এর পর যা বদলেছে
  Future<int> _pull() async {
    var total = 0;
    for (var i = 0; i < 200; i++) {
      final cursor = await _store.getMeta('cursor') ?? '0';
      final data = (await _api('GET', '/sync/pull/', query: {'cursor': cursor, 'limit': '500'}))['data'] as Map<String, dynamic>;
      final changes = (data['changes'] as List).cast<Map<String, dynamic>>();
      final grouped = <String, List<Map<String, dynamic>>>{};
      for (final c in changes) {
        final entity = '${c['entity']}';
        if (c['op'] == 'delete') {
          final id = (c['id'] as num?)?.toInt();
          if (id != null) await _store.deleteEntity(entity, id);
        } else if (c['data'] is Map) {
          grouped.putIfAbsent(entity, () => []).add(Map<String, dynamic>.from(c['data'] as Map));
        }
      }
      for (final e in grouped.entries) {
        await _store.upsertEntities(e.key, e.value);
      }
      total += changes.length;
      await _store.setMeta('cursor', '${data['next_cursor']}');
      if (data['has_more'] != true) break;
    }
    return total;
  }

  /// দিনে দুইবার পুরো data আবার মিলিয়ে নেওয়া — কোনো কারণে কিছু বাদ পড়লেও ঠিক হয়ে যায়
  Future<void> _maybeFullRefresh() async {
    final last = DateTime.tryParse(await _store.getMeta('last_full_refresh') ?? '');
    if (last != null && DateTime.now().difference(last) < OfflineConfig.fullRefreshEvery) return;
    final manifest = (await _api('GET', '/sync/manifest/'))['data'] as Map<String, dynamic>;
    for (final e in (manifest['entities'] as List).cast<Map<String, dynamic>>()) {
      final entity = '${e['entity']}';
      final items = <Map<String, dynamic>>[];
      var page = 1;
      while (true) {
        final res = (await _api('GET', '/sync/bootstrap/',
            query: {'entity': entity, 'page': '$page', 'page_size': '500'}))['data'] as Map<String, dynamic>;
        items.addAll((res['items'] as List).cast<Map<String, dynamic>>());
        if (res['has_more'] != true) break;
        page++;
      }
      await _store.replaceEntity(entity, items);
    }
    await _store.setMeta('last_full_refresh', DateTime.now().toIso8601String());
  }

  /// Server এর খোলা issue এর সাথে local তালিকা মেলানো (অন্য PC বা admin সমাধান করলে এখান থেকেও সরে)
  Future<void> _refreshServerIssues() async {
    final res = await _api('GET', '/sync/issues/', query: {'status': 'open', 'mine': 'true', 'device_id': await _deviceId()});
    final open = ((res['data'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final openIds = {for (final i in open) '${i['op_id']}': i};
    for (final local in await _store.issues()) {
      final opId = '${local['op_id']}';
      final server = openIds[opId];
      if (server == null) {
        await _store.removeIssue(opId);
        final ops = await _store.db.query('outbox', where: 'op_id = ?', whereArgs: [opId], limit: 1);
        if (ops.isNotEmpty && ops.first['status'] == 'issue') await _store.updateOp(opId, {'status': 'dismissed'});
      } else {
        await _store.saveIssue({...local, 'server_issue_id': server['id']});
      }
    }
  }

  // ----------------------------------------------------- Sync Center actions
  /// সমস্যা ঠিক করার পর (যেমন stock কেনা হয়েছে) আবার পাঠানো
  Future<void> retryIssue(String opId) async {
    await _store.updateOp(opId, {'status': 'pending', 'attempts': 0});
    await _store.removeIssue(opId);
    await _refreshCounts();
    kick();
  }

  /// Entry বাতিল — server এও রেকর্ড থাকে কে বাতিল করেছে (audit)
  Future<void> dismissIssue(String opId, {String note = ''}) async {
    final issue = (await _store.issues()).where((i) => i['op_id'] == opId).toList();
    final serverId = issue.isEmpty ? null : issue.first['server_issue_id'];
    if (serverId != null && ConnectivityMonitor.instance.isOnline) {
      await _api('POST', '/sync/issues/$serverId/resolve/', body: {'resolution': 'dismissed', 'note': note});
    }
    await _store.updateOp(opId, {'status': 'dismissed'});
    await _store.removeIssue(opId);
    await StockAlerts.instance.refresh();
    await _refreshCounts();
  }

  Future<int> pendingCount() => _store.countOps(['pending', 'blocked', 'error']);

  Future<void> _refreshCounts() async {
    if (!_store.isOpen) return;
    final pending = await _store.countOps(['pending', 'blocked', 'error']);
    final issues = await _store.countOps(['issue']);
    final last = DateTime.tryParse(await _store.getMeta('last_sync_at') ?? '');
    state.value = state.value.copyWith(pending: pending, issues: issues, lastSyncAt: last);
  }

  Future<void> refreshCounts() => _refreshCounts();
}
