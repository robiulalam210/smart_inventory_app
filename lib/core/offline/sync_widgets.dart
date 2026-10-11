import 'dart:convert';
import 'package:meherinMart/core/widgets/app_popover_route.dart';

import 'package:flutter/material.dart';

import 'connectivity_monitor.dart';
import 'local_store.dart';
import 'offline_config.dart';
import 'stock_alerts.dart';
import 'sync_engine.dart';
import 'package:meherinMart/core/configs/app_colors.dart';

String _ago(DateTime? t) {
  if (t == null) return 'কখনো না';
  final d = DateTime.now().difference(t);
  if (d.inSeconds < 60) return 'এইমাত্র';
  if (d.inMinutes < 60) return '${d.inMinutes} মিনিট আগে';
  if (d.inHours < 24) return '${d.inHours} ঘণ্টা আগে';
  return '${d.inDays} দিন আগে';
}

String _time(String? iso) {
  final d = DateTime.tryParse(iso ?? '')?.toLocal();
  if (d == null) return '';
  String two(int x) => x.toString().padLeft(2, '0');
  return '${two(d.day)}-${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
}

// ===========================================================================
// 1) Header এর ছোট status chip — auto sync এর সময় শুধু এটাই নড়ে, কোনো popup নয়
// ===========================================================================
class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    if (!OfflineConfig.enabled) return const SizedBox.shrink();
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityMonitor.instance.online,
      builder: (context, online, _) => ValueListenableBuilder<SyncSnapshot>(
        valueListenable: SyncEngine.instance.state,
        builder: (context, s, _) {
          late Color color;
          late String text;
          IconData icon = Icons.cloud_done_outlined;
          final syncing = s.phase == SyncPhase.syncing;
          if (s.issues > 0) {
            color = const Color(0xFFD64545);
            text = '${s.issues} টি সমস্যা';
            icon = Icons.error_outline;
          } else if (!online) {
            color = const Color(0xFFE0A100);
            text = s.pending > 0 ? 'Offline · ${s.pending} অপেক্ষায়' : 'Offline';
            icon = Icons.cloud_off_outlined;
          } else if (s.pending > 0 || syncing) {
            color = const Color(0xFF2F80ED);
            text = s.pending > 0 ? '${s.pending} sync হচ্ছে' : 'Online';
            icon = Icons.cloud_sync_outlined;
          } else {
            color = const Color(0xFF27AE60);
            text = 'Online · Synced';
          }
          return Tooltip(
            message: 'শেষ sync: ${_ago(s.lastSyncAt)}\nক্লিক করে Sync Center খুলুন',
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => SyncCenterDialog.show(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.45)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (syncing)
                    SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: color))
                  else
                    Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12.5)),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===========================================================================
// 2) Offline banner + stock alert (header এর নিচে)
// ===========================================================================
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!OfflineConfig.enabled) return const SizedBox.shrink();
    return ValueListenableBuilder<bool>(
      valueListenable: ConnectivityMonitor.instance.online,
      builder: (context, online, _) => ValueListenableBuilder<List<StockAlertItem>>(
        valueListenable: StockAlerts.instance.outOfStock,
        builder: (context, out, _) {
          if (online) return const SizedBox.shrink();
          return Material(
            color: const Color(0xFFFFF4D6),
            child: InkWell(
              onTap: () => SyncCenterDialog.show(context, initialTab: out.isNotEmpty ? 2 : 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(children: [
                  const Icon(Icons.wifi_off_rounded, size: 18, color: Color(0xFF8A6100)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Internet নেই — বিক্রি, ক্রয়, পেমেন্ট চালিয়ে যান। সংযোগ এলে নিজে থেকেই sync হবে।',
                      style: TextStyle(color: Color(0xFF6B4B00), fontSize: 13),
                    ),
                  ),
                  if (out.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFD64545), borderRadius: BorderRadius.circular(12)),
                      child: Text('${out.length} টি পণ্যের স্টক শেষ',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===========================================================================
// 3) Sync Center — অপেক্ষমাণ entry, সমস্যা, স্টক, আর "এখনই Sync" বাটন
// ===========================================================================
class SyncCenterDialog extends StatefulWidget {
  final int initialTab;
  const SyncCenterDialog({super.key, this.initialTab = 0});

  static Future<void> show(BuildContext context, {int initialTab = 0}) => showAppPopover(
        context: context,
        builder: (_) => SyncCenterDialog(initialTab: initialTab),
      );

  @override
  State<SyncCenterDialog> createState() => _SyncCenterDialogState();
}

class _SyncCenterDialogState extends State<SyncCenterDialog> {
  List<Map<String, Object?>> _pending = const [];
  List<Map<String, Object?>> _issues = const [];
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final store = LocalStore.instance;
    final pending = await store.opsByStatus(['pending', 'blocked', 'error']);
    final issues = await store.issues();
    await SyncEngine.instance.refreshCounts();
    if (mounted) {
      setState(() {
        _pending = pending;
        _issues = issues;
      });
    }
  }

  Future<void> _syncNow() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    final r = await SyncEngine.instance.syncNow(manual: true);
    await _load();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = r.ok
          ? 'Sync সম্পন্ন — ${r.pushed} টি entry পাঠানো হয়েছে, ${r.pulled} টি পরিবর্তন এসেছে'
              '${r.newIssues > 0 ? ', ${r.newIssues} টি সমস্যা' : ''}।'
          : r.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppPopoverShell(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 640),
        child: DefaultTabController(
          length: 3,
          initialIndex: widget.initialTab,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
              child: Row(children: [
                Text('Sync Center', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                const SyncStatusChip(),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ]),
            ),
            ValueListenableBuilder<SyncSnapshot>(
              valueListenable: SyncEngine.instance.state,
              builder: (context, s, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      'শেষ sync: ${_ago(s.lastSyncAt)}'
                      '${s.lastError != null && s.phase == SyncPhase.error ? '\nশেষ সমস্যা: ${s.lastError}' : ''}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _busy ? null : _syncNow,
                    icon: _busy
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.sync),
                    label: const Text('এখনই Sync করুন'),
                  ),
                ]),
              ),
            ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                child: Text(_message!, style: TextStyle(color: theme.colorScheme.primary)),
              ),
            const SizedBox(height: 8),
            TabBar(tabs: [
              Tab(text: 'অপেক্ষমাণ (${_pending.length})'),
              Tab(text: 'সমস্যা (${_issues.length})'),
              const Tab(text: 'স্টক সতর্কতা'),
            ]),
            Expanded(
              child: TabBarView(children: [
                _pendingList(),
                _issueList(),
                _stockList(),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _empty(String text, IconData icon) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ]),
      );

  Widget _pendingList() {
    if (_pending.isEmpty) return _empty('সব entry server এ পৌঁছেছে', Icons.check_circle_outline);
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _pending.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final o = _pending[i];
        final status = '${o['status']}';
        return ListTile(
          dense: true,
          leading: Icon(status == 'pending' ? Icons.schedule : Icons.hourglass_bottom,
              color: status == 'pending' ? Colors.blueGrey : AppColors.warning),
          title: Text('${o['title'] ?? o['entity']}'),
          subtitle: Text([
            _time(o['client_created_at'] as String?),
            if ('${o['user_name'] ?? ''}'.isNotEmpty) '${o['user_name']}',
            if (status != 'pending' && o['last_error'] != null) '${o['last_error']}',
          ].join(' · ')),
        );
      },
    );
  }

  Widget _issueList() {
    if (_issues.isEmpty) return _empty('কোনো সমস্যা নেই', Icons.verified_outlined);
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _issues.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final it = _issues[i];
        final opId = '${it['op_id']}';
        final isStock = it['issue_type'] == 'stock_conflict';
        return ListTile(
          leading: Icon(isStock ? Icons.inventory_2_outlined : Icons.report_gmailerrorred, color: const Color(0xFFD64545)),
          title: Text('${it['title'] ?? it['entity']}'),
          subtitle: Text(
            '${it['message']}\n'
            '${isStock ? 'সমাধান: পণ্য ক্রয়/stock যোগ করে "আবার পাঠান" দিন, অথবা বিক্রিটি বাতিল করুন।' : 'সমাধান: তথ্য ঠিক করে নতুন entry দিন, এটি বাতিল করুন।'}',
          ),
          isThreeLine: true,
          trailing: Wrap(spacing: 4, children: [
            TextButton(
              onPressed: () async {
                await SyncEngine.instance.retryIssue(opId);
                await _load();
              },
              child: const Text('আবার পাঠান'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFD64545)),
              onPressed: () async {
                final ok = await showAppPopover<bool>(
                  context: context,
                  builder: (c) => AppPopoverCard(
                    title: const Text('Entry বাতিল করবেন?'),
                    content: const Text('এই offline entry টি server এ উঠবে না। কে বাতিল করেছে তা audit log এ থাকবে।'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('না')),
                      FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('বাতিল করুন')),
                    ],
                  ),
                );
                if (ok == true) {
                  await SyncEngine.instance.dismissIssue(opId);
                  await _load();
                }
              },
              child: const Text('বাতিল'),
            ),
          ]),
        );
      },
    );
  }

  Widget _stockList() {
    return ValueListenableBuilder<List<StockAlertItem>>(
      valueListenable: StockAlerts.instance.outOfStock,
      builder: (context, out, _) => ValueListenableBuilder<List<StockAlertItem>>(
        valueListenable: StockAlerts.instance.lowStock,
        builder: (context, low, _) {
          final all = [...out, ...low];
          if (all.isEmpty) return _empty('সব পণ্যের পর্যাপ্ত stock আছে', Icons.inventory_outlined);
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: all.length,
            itemBuilder: (_, i) {
              final p = all[i];
              return ListTile(
                dense: true,
                leading: Icon(p.isOut ? Icons.remove_shopping_cart_outlined : Icons.warning_amber_rounded,
                    color: p.isOut ? const Color(0xFFD64545) : const Color(0xFFE0A100)),
                title: Text(p.name),
                trailing: Text(p.isOut ? 'স্টক শেষ' : 'বাকি ${p.available}',
                    style: TextStyle(fontWeight: FontWeight.w600, color: p.isOut ? const Color(0xFFD64545) : null)),
              );
            },
          );
        },
      ),
    );
  }
}

// ===========================================================================
// 4) প্রথম setup screen — একবারই দেখায়, user বুঝতে পারে কী হচ্ছে
// ===========================================================================
class FirstSetupScreen extends StatefulWidget {
  /// setup শেষে কোন screen এ যাবে
  final Widget Function() next;
  const FirstSetupScreen({super.key, required this.next});

  @override
  State<FirstSetupScreen> createState() => _FirstSetupScreenState();
}

class _FirstSetupScreenState extends State<FirstSetupScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    setState(() => _error = null);
    try {
      await SyncEngine.instance.runInitialSetup();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => widget.next()), (_) => false);
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: theme.dividerColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: ValueListenableBuilder<SyncSnapshot>(
                valueListenable: SyncEngine.instance.state,
                builder: (context, s, _) => Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_error == null ? Icons.cloud_download_outlined : Icons.cloud_off_outlined,
                      size: 52, color: _error == null ? theme.colorScheme.primary : const Color(0xFFD64545)),
                  const SizedBox(height: 16),
                  Text('এই কম্পিউটার প্রস্তুত করা হচ্ছে',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'পণ্য, কাস্টমার, account সহ প্রয়োজনীয় সব তথ্য এই কম্পিউটারে রাখা হচ্ছে, যাতে internet '
                    'না থাকলেও বিক্রি চালানো যায়। এটা শুধু প্রথমবার হয় — পরে সব কিছু নিজে থেকে update হবে।',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  ),
                  const SizedBox(height: 28),
                  if (_error == null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(value: s.setupProgress == 0 ? null : s.setupProgress, minHeight: 10),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: Text(s.setupLabel, style: theme.textTheme.bodySmall)),
                      Text('${(s.setupProgress * 100).round()}%',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                    ]),
                  ] else ...[
                    Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFD64545))),
                    const SizedBox(height: 16),
                    FilledButton.icon(onPressed: _run, icon: const Icon(Icons.refresh), label: const Text('আবার চেষ্টা করুন')),
                  ],
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// 5) Logout এর আগে সতর্কতা — sync না হওয়া entry থাকলে
// ===========================================================================
class OfflineGuards {
  OfflineGuards._();

  static Future<bool> confirmLogout(BuildContext context) async {
    if (!OfflineConfig.enabled || !LocalStore.instance.isOpen) return true;
    final pending = await SyncEngine.instance.pendingCount();
    if (pending == 0) return true;
    if (!context.mounted) return false;
    final ok = await showAppPopover<bool>(
      context: context,
      builder: (c) => AppPopoverCard(
        title: const Text('কিছু entry এখনো sync হয়নি'),
        content: Text('$pending টি entry এখনো server এ যায়নি। Logout করলেও এগুলো এই কম্পিউটারে নিরাপদে থাকবে, '
            'এবং যে কেউ login করলে internet পেলেই চলে যাবে।'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('থাক')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Logout')),
        ],
      ),
    );
    return ok == true;
  }

  /// debug/export: queue এর কাঁচা data (সমস্যা হলে support এ পাঠানোর জন্য)
  static Future<String> exportQueue() async {
    final rows = await LocalStore.instance.opsByStatus(['pending', 'blocked', 'error', 'issue'], limit: 1000);
    return const JsonEncoder.withIndent('  ').convert(rows);
  }
}

// ===========================================================================
// 6) Setup gate — desktop এ setup না হয়ে থাকলে আগে setup screen, তারপর আসল screen
//    (পুরনো installation update হলেও প্রথমবার নিজে থেকে setup হবে)
// ===========================================================================
class OfflineSetupGate extends StatefulWidget {
  final Widget child;
  const OfflineSetupGate({super.key, required this.child});

  @override
  State<OfflineSetupGate> createState() => _OfflineSetupGateState();
}

class _OfflineSetupGateState extends State<OfflineSetupGate> {
  // FIX: আগে build() এর ভিতরে প্রতিবার নতুন Future তৈরি হত। window resize বা যেকোনো
  // rebuild এ FutureBuilder আবার "loading" এ যেত → RootScreen সরিয়ে আবার বসাত →
  // Flutter এর focus/_dependents assertion error। এখন একবারই যাচাই হয়।
  late final Future<bool> _setupDone;

  @override
  void initState() {
    super.initState();
    _setupDone = (OfflineConfig.enabled && LocalStore.instance.isOpen)
        ? SyncEngine.instance.isSetupDone()
        : Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _setupDone,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.data == false) return FirstSetupScreen(next: () => widget.child);
        return widget.child;
      },
    );
  }
}
