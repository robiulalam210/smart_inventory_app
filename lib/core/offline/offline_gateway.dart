import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../configs/app_urls.dart';
import '../database/login.dart';
import 'connectivity_monitor.dart';
import 'local_store.dart';
import 'offline_config.dart';
import 'stock_alerts.dart';
import 'sync_engine.dart';

/// App এর HTTP layer (getResponse / postResponse ...) আর server এর মাঝখানে বসে।
///
/// - Online: request সরাসরি server এ যায় (আগের মতোই), শুধু response cache হয়।
/// - Offline: GET এর উত্তর local database থেকে, আর অনুমোদিত নতুন entry (sale, payment...)
///   outbox queue তে জমা হয়। UI কোনো পার্থক্য বোঝে না — তাই পুরনো screen গুলো বদলাতে হয়নি।
class OfflineGateway {
  OfflineGateway._();
  static final OfflineGateway instance = OfflineGateway._();

  bool _ready = false;

  /// Desktop এবং local DB খোলা থাকলেই offline layer সক্রিয়
  bool get enabled => OfflineConfig.enabled && _ready;

  bool get isOffline => enabled && !ConnectivityMonitor.instance.isOnline;

  Future<void> init() async {
    if (!OfflineConfig.enabled || _ready) return;
    await LocalStore.instance.open();
    _ready = true;
    await ConnectivityMonitor.instance.start();
    SyncEngine.instance.start();
    await StockAlerts.instance.refresh();
  }

  // ------------------------------------------------------------------ utils
  /// Full URL → '/api/...' path (base URL যা-ই হোক)
  String relPath(Uri uri) {
    final base = Uri.parse(AppUrls.baseUrl);
    var path = uri.path;
    final basePath = base.path.endsWith('/') ? base.path.substring(0, base.path.length - 1) : base.path;
    if (basePath.isNotEmpty && path.startsWith(basePath)) {
      path = '/api${path.substring(basePath.length)}';
    }
    return path;
  }

  String _cacheKey(Uri uri) {
    final q = Map.of(uri.queryParameters)..removeWhere((k, _) => k == '_');
    final keys = q.keys.toList()..sort();
    return '${relPath(uri)}?${keys.map((k) => '$k=${q[k]}').join('&')}';
  }

  /// সব write request এর সাথে যাওয়া header (audit + duplicate প্রতিরোধ)
  Future<Map<String, String>> extraHeaders({String? opId}) async {
    final h = <String, String>{'X-Client-Source': OfflineConfig.clientSource};
    if (opId != null) h['X-Idempotency-Key'] = opId;
    if (enabled) {
      final deviceId = await LocalStore.instance.getMeta('device_id');
      if (deviceId != null) h['X-Device-Id'] = deviceId;
    }
    return h;
  }

  // ------------------------------------------------------------- GET: cache
  Future<void> cacheGet(Uri uri, String body) async {
    if (!enabled) return;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && (decoded['status'] == false || decoded['success'] == false)) return;
      await LocalStore.instance.cacheResponse(_cacheKey(uri), relPath(uri), body);
    } catch (_) {/* JSON নয় — cache করার দরকার নেই */}
  }

  // ----------------------------------------------------------- GET: offline
  Future<String> offlineGet(Uri uri) async {
    final store = LocalStore.instance;
    final path = relPath(uri);
    final q = uri.queryParameters;

    // 1) Master data list → local entity table থেকে (সবচেয়ে নতুন, offline entry সহ)
    final entity = OfflineConfig.readPaths[path];
    if (entity != null) {
      var items = await store.queryEntities(
        entity,
        search: q['search'] ?? q['q'] ?? q['name'],
        isActive: _parseBool(q['is_active']) ?? (path.contains('active') && !path.contains('inactive') ? true : null),
        equals: {
          for (final e in q.entries)
            if (e.key.endsWith('_id') || const {'product', 'category', 'brand', 'unit', 'head', 'group'}.contains(e.key))
              e.key.replaceAll(RegExp(r'_id$'), ''): e.value,
        },
      );
      if (entity == 'product') items = await _applyStock(items);
      return _buildListResponse(path, items, q);
    }

    // 2) Detail: /api/products/12/
    final detail = RegExp(r'^(/api/.+/)(-?\d+)/$').firstMatch(path);
    if (detail != null) {
      final de = OfflineConfig.readPaths[detail.group(1)!];
      if (de != null) {
        final cached = await store.cachedResponse(_cacheKey(uri));
        if (cached != null) return cached['body'] as String;
        var obj = await store.getEntity(de, int.parse(detail.group(2)!));
        if (obj != null) {
          if (de == 'product') obj = (await _applyStock([obj])).first;
          return jsonEncode({'status': true, 'message': 'Offline data', 'data': obj});
        }
      }
    }

    // 3) Report/dashboard ইত্যাদি → শেষ online এ যা দেখা হয়েছিল
    final cached = await store.cachedResponse(_cacheKey(uri));
    if (cached != null) return cached['body'] as String;

    final last = await store.getMeta('last_sync_at');
    return jsonEncode({
      'success': false,
      'status': false,
      'title': 'Offline',
      'message': 'এই তথ্য দেখতে internet সংযোগ প্রয়োজন।'
          '${last != null ? ' শেষ sync: ${_fmt(last)}' : ''}',
      'data': null,
    });
  }

  Future<List<Map<String, dynamic>>> _applyStock(List<Map<String, dynamic>> items) async {
    final delta = await LocalStore.instance.pendingStockDelta();
    if (delta.isEmpty) return items;
    return items.map((m) {
      final d = delta[m['id']];
      if (d == null) return m;
      final copy = Map<String, dynamic>.from(m);
      final cur = num.tryParse('${m['stock_qty'] ?? 0}') ?? 0;
      final next = cur + d;
      copy['stock_qty'] = next == next.roundToDouble() ? next.round() : next;
      copy['offline_adjusted'] = true;
      return copy;
    }).toList();
  }

  Future<String> _buildListResponse(String path, List<Map<String, dynamic>> items, Map<String, String> q) async {
    final templateBody = await LocalStore.instance.templateFor(path);
    dynamic root;
    try {
      root = templateBody != null ? jsonDecode(templateBody) : null;
    } catch (_) {
      root = null;
    }
    final page = int.tryParse(q['page'] ?? '') ?? 1;
    final noPagination = q['no_pagination'] == 'true' || path.contains('active');

    if (root == null) {
      if (noPagination) return jsonEncode({'status': true, 'message': 'Offline data', 'data': items});
      root = {'status': true, 'message': 'Offline data', 'data': {'results': <dynamic>[]}};
    }
    if (root is List) return jsonEncode(items);

    final map = Map<String, dynamic>.from(root as Map);
    Map<String, dynamic>? holder;
    String key = 'data';
    if (map['data'] is List) {
      holder = map;
    } else if (map['data'] is Map && (map['data'] as Map)['results'] is List) {
      holder = Map<String, dynamic>.from(map['data'] as Map);
      map['data'] = holder;
      key = 'results';
    } else if (map['results'] is List) {
      holder = map;
      key = 'results';
    } else {
      holder = map;
    }

    if (key == 'results') {
      final size = int.tryParse(q['page_size'] ?? '') ?? (num.tryParse('${holder['page_size'] ?? ''}')?.toInt() ?? 10);
      final total = items.length;
      final pages = total == 0 ? 1 : ((total + size - 1) ~/ size);
      final cur = page.clamp(1, pages);
      final slice = items.skip((cur - 1) * size).take(size).toList();
      holder
        ..['results'] = slice
        ..['count'] = total
        ..['total_pages'] = pages
        ..['current_page'] = cur
        ..['page_size'] = size
        ..['next'] = cur < pages ? '?page=${cur + 1}' : null
        ..['previous'] = cur > 1 ? '?page=${cur - 1}' : null;
      if (holder.containsKey('from')) holder['from'] = total == 0 ? 0 : (cur - 1) * size + 1;
      if (holder.containsKey('to')) holder['to'] = (cur - 1) * size + slice.length;
    } else {
      holder[key] = items;
    }
    map['message'] = 'Offline data';
    return jsonEncode(map);
  }

  // ----------------------------------------------------------- WRITE: queue
  bool canQueue(Uri uri) => enabled && OfflineConfig.writePaths.containsKey(relPath(uri));

  /// Offline এ নতুন entry: local queue তে জমা, সাথে stock যাচাই ও offline invoice no
  Future<Map<String, dynamic>> queueWrite(Uri uri, Map<String, dynamic>? payload, {required String opId}) async {
    final path = relPath(uri);
    final entity = OfflineConfig.writePaths[path];
    if (!enabled || entity == null) return offlineBlocked();

    final store = LocalStore.instance;
    final body = Map<String, dynamic>.from(payload ?? const {});
    final login = await LocalDB.getLoginInfo();
    final userId = int.tryParse('${login?['userId'] ?? ''}');
    final localId = -(await store.nextCounter('local_id'));
    final extra = <String, dynamic>{};
    String title = OfflineConfig.entityLabels[entity] ?? entity;

    if (entity == 'sale' || entity == 'purchase') {
      await _attachBaseQuantities(body);
    }

    if (entity == 'sale') {
      final stockError = await _checkStock(body);
      if (stockError != null) {
        return {'status': false, 'statusCode': 400, 'title': 'স্টক নেই', 'message': stockError, 'data': null};
      }
      final code = await store.getMeta('device_code') ?? 'DX';
      final n = await store.nextCounter('invoice_seq');
      final invoice = 'SL-$code-${n.toString().padLeft(5, '0')}';
      body['offline_invoice_no'] = invoice;
      extra['invoice_no'] = invoice;
      title = 'Sale $invoice';
    } else if (entity == 'customer') {
      title = 'Customer ${body['name'] ?? ''}';
      await store.upsertEntities('customer', [
        {...body, 'id': localId, 'is_active': true, 'offline_pending': true},
      ]);
    } else {
      final amt = body['amount'] ?? body['paid_amount'];
      if (amt != null) title = '$title — ৳$amt';
    }

    await store.enqueue({
      'op_id': opId,
      'entity': entity,
      'method': 'POST',
      'path': path,
      'local_id': localId,
      'payload': jsonEncode(body),
      'user_id': userId,
      'user_name': '${login?['userName'] ?? ''}',
      'title': title,
      'status': 'pending',
      'client_created_at': DateTime.now().toIso8601String(),
    });

    await StockAlerts.instance.refresh();
    SyncEngine.instance.kick();

    final data = {...body, ...extra, 'id': localId, 'offline': true};
    return {
      'status': true,
      'statusCode': 201,
      'message': 'Offline এ সংরক্ষিত হয়েছে — internet এলে নিজে থেকেই sync হবে',
      'data': {'status': true, 'message': 'Saved offline', 'data': data},
    };
  }

  Map<String, dynamic> offlineBlocked() => {
        'success': false,
        'status': false,
        'statusCode': 503,
        'title': 'Offline',
        'message': 'এই কাজটি করতে internet সংযোগ প্রয়োজন। Offline এ শুধু নতুন বিক্রি, '
            'ক্রয়, পেমেন্ট, খরচ, আয় ও কাস্টমার যোগ করা যায়।',
        'data': null,
      };

  /// Sale mode (যেমন "Box" = 12 pcs) থাকলে base unit এ কত — stock হিসাবের জন্য
  Future<void> _attachBaseQuantities(Map<String, dynamic> body) async {
    final items = body['items'];
    if (items is! List) return;
    for (final raw in items) {
      if (raw is! Map) continue;
      final qty = num.tryParse('${raw['sale_quantity'] ?? raw['quantity'] ?? 0}') ?? 0;
      num factor = 1;
      final modeId = raw['sale_mode_id'] ?? raw['sale_mode'];
      if (modeId != null && '$modeId'.isNotEmpty) {
        final pid = '${raw['product_id'] ?? raw['product']}';
        final psm = await LocalStore.instance
            .queryEntities('product_sale_mode', equals: {'product': pid, 'sale_mode': '$modeId'});
        final mode = await LocalStore.instance.getEntity('sale_mode', int.tryParse('$modeId') ?? 0);
        factor = num.tryParse('${(psm.isNotEmpty ? psm.first['conversion_factor'] : null) ?? mode?['conversion_factor'] ?? 1}') ?? 1;
      }
      raw['_base_qty'] = qty * factor;
    }
  }

  /// Offline বিক্রির আগে local stock যাচাই। Stock না থাকলে বিক্রি আটকে দেওয়া হয় —
  /// কারণ server এ stock ঋণাত্মক হতে পারে না, পরে sync এ এটা আটকে যেত।
  Future<String?> _checkStock(Map<String, dynamic> body) async {
    final items = body['items'];
    if (items is! List) return null;
    final need = <int, num>{};
    for (final raw in items) {
      if (raw is! Map) continue;
      final pid = int.tryParse('${raw['product_id'] ?? raw['product']}');
      if (pid == null) continue;
      need[pid] = (need[pid] ?? 0) + (num.tryParse('${raw['_base_qty'] ?? raw['quantity'] ?? 0}') ?? 0);
    }
    final delta = await LocalStore.instance.pendingStockDelta();
    final problems = <String>[];
    for (final e in need.entries) {
      final p = await LocalStore.instance.getEntity('product', e.key);
      if (p == null) {
        problems.add('Product #${e.key} local data তে নেই — একবার sync করুন');
        continue;
      }
      final available = (num.tryParse('${p['stock_qty'] ?? 0}') ?? 0) + (delta[e.key] ?? 0);
      if (e.value > available) {
        problems.add('${p['name']}: আছে ${_n(available)}, চাওয়া হয়েছে ${_n(e.value)}');
      }
    }
    if (problems.isEmpty) return null;
    return 'স্টক যথেষ্ট নেই (offline হিসাব):\n${problems.join('\n')}';
  }

  static bool? _parseBool(String? v) {
    if (v == null) return null;
    if (v == 'true' || v == '1') return true;
    if (v == 'false' || v == '0') return false;
    return null;
  }

  static String _n(num v) => v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);

  static String _fmt(String iso) {
    final d = DateTime.tryParse(iso)?.toLocal();
    if (d == null) return iso;
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}-${two(d.month)}-${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  @visibleForTesting
  void debugSetReady(bool v) => _ready = v;
}
