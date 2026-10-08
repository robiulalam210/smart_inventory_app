import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Audit log এর একটা row — "কে, কখন, কোথা থেকে, কোন record এ কী বদলেছে"
class AuditEntry {
  final int id;
  final String action; // create / update / delete
  final String model; // e.g. sales.Sale
  final String objectId;
  final String objectRepr;
  final String? company;
  final int? userId;
  final String user;
  final String source; // mobile / desktop / desktop_offline / api / admin / system
  final String? device;
  final String? ip;
  final List<AuditChange> changes;
  final DateTime? clientTime; // offline এ আসলে কখন কাজটা হয়েছিল
  final DateTime createdAt; // server এ পৌঁছানোর সময়

  const AuditEntry({
    required this.id,
    required this.action,
    required this.model,
    required this.objectId,
    required this.objectRepr,
    required this.company,
    required this.userId,
    required this.user,
    required this.source,
    required this.device,
    required this.ip,
    required this.changes,
    required this.clientTime,
    required this.createdAt,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> j) => AuditEntry(
        id: int.tryParse('${j['id']}') ?? 0,
        action: '${j['action'] ?? ''}',
        model: '${j['model'] ?? ''}',
        objectId: '${j['object_id'] ?? ''}',
        objectRepr: '${j['object_repr'] ?? ''}',
        company: j['company']?.toString(),
        userId: int.tryParse('${j['user_id']}'),
        user: (j['user']?.toString().trim().isNotEmpty ?? false) ? j['user'].toString() : 'System',
        source: '${j['source'] ?? ''}',
        device: j['device']?.toString(),
        ip: j['ip']?.toString(),
        changes: [
          for (final c in (j['changes'] as List? ?? const []))
            if (c is Map) AuditChange('${c['field']}', c['old'], c['new']),
        ],
        clientTime: AuditFormat.parseDate(j['client_time']),
        createdAt: AuditFormat.parseDate(j['created_at']) ?? DateTime.now(),
      );

  /// Offline এ করা কাজ পরে sync হলে আসল সময় আর server সময় আলাদা হয়
  bool get wasOffline =>
      clientTime != null && createdAt.difference(clientTime!).inMinutes.abs() >= 2;

  DateTime get when => clientTime ?? createdAt;
}

class AuditChange {
  final String field;
  final dynamic oldValue;
  final dynamic newValue;

  const AuditChange(this.field, this.oldValue, this.newValue);
}

class AuditSummary {
  final int total, today, todayCreate, todayUpdate, todayDelete;

  const AuditSummary({
    this.total = 0,
    this.today = 0,
    this.todayCreate = 0,
    this.todayUpdate = 0,
    this.todayDelete = 0,
  });

  factory AuditSummary.fromJson(Map<String, dynamic> j) => AuditSummary(
        total: (j['total'] as num?)?.toInt() ?? 0,
        today: (j['today'] as num?)?.toInt() ?? 0,
        todayCreate: (j['today_create'] as num?)?.toInt() ?? 0,
        todayUpdate: (j['today_update'] as num?)?.toInt() ?? 0,
        todayDelete: (j['today_delete'] as num?)?.toInt() ?? 0,
      );
}

class AuditOption {
  final String value;
  final String label;
  final int count;

  const AuditOption(this.value, this.label, this.count);
}

/// Filter dropdown এর জন্য server থেকে আসা তালিকা (শুধু যেগুলোর log আছে)
class AuditMeta {
  final bool isSuperAdmin;
  final AuditSummary summary;
  final List<AuditOption> models;
  final List<AuditOption> users;
  final List<AuditOption> sources;
  final List<AuditOption> companies;

  const AuditMeta({
    this.isSuperAdmin = false,
    this.summary = const AuditSummary(),
    this.models = const [],
    this.users = const [],
    this.sources = const [],
    this.companies = const [],
  });

  factory AuditMeta.fromJson(Map<String, dynamic> j) {
    List<AuditOption> list(String key, String valueKey, String Function(Map) label) => [
          for (final x in (j[key] as List? ?? const []))
            if (x is Map)
              AuditOption('${x[valueKey]}', label(x), (x['count'] as num?)?.toInt() ?? 0),
        ];
    return AuditMeta(
      isSuperAdmin: j['is_super_admin'] == true,
      summary: AuditSummary.fromJson((j['summary'] as Map?)?.cast<String, dynamic>() ?? const {}),
      models: list('models', 'model', (x) => AuditFormat.modelName('${x['model']}')),
      users: list('users', 'id', (x) => '${x['name'] ?? 'Unknown'}'),
      sources: list('sources', 'source', (x) => AuditFormat.sourceName('${x['source']}')),
      companies: list('companies', 'id', (x) => '${x['name'] ?? ''}'),
    );
  }
}

/// Filter এর অবস্থা — server এ query parameter হয়ে যায়
class AuditFilter {
  final String query;
  final String? action;
  final String? model;
  final String? userId;
  final String? source;
  final String? companyId;
  final DateTimeRange? range;
  final String? objectId; // একটা record এর পুরো ইতিহাস দেখতে

  const AuditFilter({
    this.query = '',
    this.action,
    this.model,
    this.userId,
    this.source,
    this.companyId,
    this.range,
    this.objectId,
  });

  /// dropdown/date filter কয়টা চালু (search আর action tab বাদে)
  int get advancedCount =>
      [model, userId, source, companyId, objectId].where((v) => v != null).length + (range != null ? 1 : 0);

  bool get isEmpty => query.isEmpty && action == null && advancedCount == 0;

  AuditFilter copyWith({
    String? query,
    String? Function()? action,
    String? Function()? model,
    String? Function()? userId,
    String? Function()? source,
    String? Function()? companyId,
    DateTimeRange? Function()? range,
    String? Function()? objectId,
  }) =>
      AuditFilter(
        query: query ?? this.query,
        action: action != null ? action() : this.action,
        model: model != null ? model() : this.model,
        userId: userId != null ? userId() : this.userId,
        source: source != null ? source() : this.source,
        companyId: companyId != null ? companyId() : this.companyId,
        range: range != null ? range() : this.range,
        objectId: objectId != null ? objectId() : this.objectId,
      );

  Map<String, String> toQuery({required int page, int pageSize = 30}) {
    final f = DateFormat('yyyy-MM-dd');
    return {
      'page': '$page',
      'page_size': '$pageSize',
      if (query.trim().isNotEmpty) 'q': query.trim(),
      if (action != null) 'action': action!,
      if (model != null) 'model': model!,
      if (userId != null) 'user_id': userId!,
      if (source != null) 'source': source!,
      if (companyId != null) 'company_id': companyId!,
      if (objectId != null) 'object_id': objectId!,
      if (range != null) 'date_from': f.format(range!.start),
      if (range != null) 'date_to': f.format(range!.end),
    };
  }
}

/// নাম/মান সুন্দর করে দেখানোর helper
class AuditFormat {
  AuditFormat._();

  static DateTime? parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse('$v')?.toLocal();
  }

  static const _modelNames = {
    'sales.Sale': 'Sale',
    'sales.SaleItem': 'Sale item',
    'purchases.Purchase': 'Purchase',
    'purchases.PurchaseItem': 'Purchase item',
    'returns.SalesReturn': 'Sales return',
    'returns.SalesReturnItem': 'Sales return item',
    'returns.PurchaseReturn': 'Purchase return',
    'returns.PurchaseReturnItem': 'Purchase return item',
    'returns.BadStock': 'Bad stock',
    'money_receipts.MoneyReceipt': 'Money receipt',
    'supplier_payment.SupplierPayment': 'Supplier payment',
    'expenses.Expense': 'Expense',
    'expenses.ExpenseHead': 'Expense head',
    'expenses.ExpenseSubHead': 'Expense sub head',
    'income.Income': 'Income',
    'income.IncomeHead': 'Income head',
    'transactions.Transaction': 'Transaction',
    'account_transfer.AccountTransfer': 'Account transfer',
    'accounts.Account': 'Account',
    'customers.Customer': 'Customer',
    'suppliers.Supplier': 'Supplier',
    'products.Product': 'Product',
    'products.Category': 'Category',
    'products.Unit': 'Unit',
    'products.Brand': 'Brand',
    'products.Group': 'Group',
    'products.Source': 'Source',
    'products.SaleMode': 'Sale mode',
    'products.PriceTier': 'Price tier',
    'products.ProductSaleMode': 'Product sale mode',
    'core.User': 'User',
    'core.Company': 'Company',
    'core.UserPermission': 'User permission',
    'core.StaffRole': 'Staff role',
    'core.Staff': 'Staff',
  };

  static String modelName(String label) {
    final known = _modelNames[label];
    if (known != null) return known;
    final name = label.contains('.') ? label.split('.').last : label;
    final spaced = name.replaceAllMapped(RegExp(r'(?<=[a-z])([A-Z])'), (m) => ' ${m[1]!.toLowerCase()}');
    return spaced.isEmpty ? label : spaced;
  }

  static String sourceName(String s) => switch (s) {
        'mobile' => 'Mobile app',
        'desktop' => 'Desktop app',
        'desktop_offline' => 'Desktop (offline)',
        'web' => 'Web app',
        'admin' => 'Admin panel',
        'api' => 'Web / API',
        'system' => 'System',
        _ => s.isEmpty ? 'Unknown' : s,
      };

  static IconData sourceIcon(String s) => switch (s) {
        'mobile' => Icons.phone_android_rounded,
        'desktop' => Icons.desktop_windows_outlined,
        'desktop_offline' => Icons.cloud_off_rounded,
        'web' => Icons.language_rounded,
        'admin' => Icons.admin_panel_settings_outlined,
        'api' => Icons.public_rounded,
        _ => Icons.settings_suggest_outlined,
      };

  static String actionVerb(String a) => switch (a) {
        'create' => 'created',
        'update' => 'updated',
        'delete' => 'deleted',
        _ => a,
      };

  static String actionLabel(String a) => switch (a) {
        'create' => 'Created',
        'update' => 'Updated',
        'delete' => 'Deleted',
        _ => a,
      };

  static Color actionColor(String a) => switch (a) {
        'create' => const Color(0xFF16A34A),
        'update' => const Color(0xFF2563EB),
        'delete' => const Color(0xFFDC2626),
        _ => const Color(0xFF64748B),
      };

  static IconData actionIcon(String a) => switch (a) {
        'create' => Icons.add_rounded,
        'update' => Icons.edit_rounded,
        'delete' => Icons.delete_outline_rounded,
        _ => Icons.circle_outlined,
      };

  /// "customer_id" → "Customer", "sales_view" → "Sales view"
  static String fieldName(String f) {
    var s = f;
    if (s.endsWith('_id') && s.length > 3) s = s.substring(0, s.length - 3);
    s = s.replaceAll('_', ' ').trim();
    if (s.isEmpty) return f;
    return s[0].toUpperCase() + s.substring(1);
  }

  static String value(dynamic v) {
    if (v == null) return '—';
    if (v is bool) return v ? 'Yes' : 'No';
    final s = '$v';
    if (s.isEmpty) return '—';
    // ISO তারিখ হলে পড়ার মতো করে
    if (RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}').hasMatch(s)) {
      final d = DateTime.tryParse(s);
      if (d != null) return DateFormat('dd MMM yyyy, hh:mm a').format(d.toLocal());
    }
    return s;
  }

  static String time(DateTime d) => DateFormat('hh:mm a').format(d);

  static String dateTime(DateTime d) => DateFormat('dd MMM yyyy, hh:mm:ss a').format(d);

  static String dayHeader(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat(day.year == now.year ? 'EEEE, dd MMM' : 'dd MMM yyyy').format(day);
  }
}
