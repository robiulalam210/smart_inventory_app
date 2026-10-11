import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/configs/app_urls.dart';
import '../../../../core/repositories/get_response.dart';
import '../../../../core/widgets/web_ui.dart';

/// Due Reminders — কার কাছে কত বাকি, আর এক চাপে WhatsApp / SMS এ বার্তা তৈরি।
/// ওয়েবের Due Reminders পেজের ডেস্কটপ রূপ।
///   API: GET /api/reports/customer-due-reminders/  (reports/reminder_views.py)
///   বার্তার ছাঁচ আর "পাঠানো হয়েছে" চিহ্ন এই কম্পিউটারেই (SharedPreferences) থাকে।
///   অ্যাপ নিজে কিছু পাঠায় না — লিংক চাপলে WhatsApp/SMS এ বার্তা তৈরি হয়ে খোলে, পাঠানোর বোতাম দোকানি চাপেন।

class DueRow {
  final int customerId;
  final String name, phone;
  final String? phoneIntl, oldestDueDate;
  final double netDue;
  final int invoiceCount, daysOverdue;
  final List<({String invoiceNo, double due})> invoices;

  DueRow({
    required this.customerId,
    required this.name,
    required this.phone,
    required this.phoneIntl,
    required this.oldestDueDate,
    required this.netDue,
    required this.invoiceCount,
    required this.daysOverdue,
    required this.invoices,
  });

  static double _n(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  factory DueRow.fromJson(Map<String, dynamic> j) => DueRow(
        customerId: (j['customer_id'] as num?)?.toInt() ?? 0,
        name: '${j['name'] ?? ''}',
        phone: '${j['phone'] ?? ''}',
        phoneIntl: (j['phone_intl'] as String?)?.isNotEmpty == true ? j['phone_intl'] as String : null,
        oldestDueDate: j['oldest_due_date'] as String?,
        netDue: _n(j['net_due']),
        invoiceCount: (j['invoice_count'] as num?)?.toInt() ?? 0,
        daysOverdue: (j['days_overdue'] as num?)?.toInt() ?? 0,
        invoices: [
          for (final i in (j['invoices'] as List? ?? const []))
            if (i is Map) (invoiceNo: '${i['invoice_no'] ?? ''}', due: _n(i['due'])),
        ],
      );
}

String _money(num v) {
  final isInt = v == v.roundToDouble();
  final s = v.toStringAsFixed(isInt ? 0 : 2);
  final parts = s.split('.');
  final whole = parts[0].replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  return parts.length > 1 ? '$whole.${parts[1]}' : whole;
}

class DueRemindersScreen extends StatefulWidget {
  const DueRemindersScreen({super.key});

  @override
  State<DueRemindersScreen> createState() => _DueRemindersScreenState();
}

class _DueRemindersScreenState extends State<DueRemindersScreen> {
  static const _tplKey = 'dueRemind.template';
  static const _sentKey = 'dueRemind.sent';
  static const _pageSize = 25;

  List<DueRow> _rows = [];
  Map<String, dynamic> _summary = {};
  String _shopName = '', _shopPhone = '', _defaultTpl = '';
  bool _loading = true, _tplOpen = false;
  String _error = '';

  // ফিল্টার
  final _searchCtrl = TextEditingController();
  int _minDays = 0;
  String _sort = 'amount';
  int _page = 1;

  // বার্তার ছাঁচ + পাঠানো-চিহ্ন
  final _tplCtrl = TextEditingController();
  Map<String, String> _sent = {}; // customerId -> তারিখ

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tplCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      try {
        final raw = prefs.getString(_sentKey);
        if (raw != null) {
          _sent = (jsonDecode(raw) as Map).map((k, v) => MapEntry('$k', '$v'));
        }
      } catch (_) {
        _sent = {};
      }

      final res = await getResponse(
        context: context,
        url: '${AppUrls.baseUrl}/reports/customer-due-reminders/',
      );
      final json = jsonDecode(res);
      if (json is! Map || json['status'] != true) {
        throw (json is Map && json['message'] != null) ? '${json['message']}' : 'Request failed';
      }
      final d = (json['data'] as Map).cast<String, dynamic>();
      _rows = [
        for (final r in (d['customers'] as List? ?? const []))
          if (r is Map) DueRow.fromJson(r.cast<String, dynamic>()),
      ];
      _summary = ((d['summary'] ?? {}) as Map).cast<String, dynamic>();
      final shop = ((d['shop'] ?? {}) as Map).cast<String, dynamic>();
      _shopName = '${shop['name'] ?? ''}';
      _shopPhone = '${shop['phone'] ?? ''}';
      _defaultTpl = '${d['default_template'] ?? ''}';
      _tplCtrl.text = prefs.getString(_tplKey) ?? _defaultTpl;
    } catch (e) {
      _error = '$e';
      _rows = [];
      _summary = {};
    }
    if (mounted) setState(() => _loading = false);
  }

  // ───── বার্তা (ওয়েবের message() এর হুবহু একই নিয়ম) ─────
  String _invoicesText(DueRow r) {
    final inv = r.invoices;
    final head = inv
        .take(5)
        .map((i) => '${i.invoiceNo.isEmpty ? '#' : i.invoiceNo} (৳${_money(i.due)})')
        .join(', ');
    return inv.length > 5 ? '$head ও আরও ${inv.length - 5}টি' : head;
  }

  String _message(DueRow r) {
    final values = {
      'name': r.name,
      'amount': _money(r.netDue),
      'shop': _shopName,
      'phone': _shopPhone,
      'invoices': _invoicesText(r),
      'days': '${r.daysOverdue}',
    };
    var out = _tplCtrl.text.trim().isEmpty ? _defaultTpl : _tplCtrl.text;
    values.forEach((k, v) => out = out.replaceAll('{$k}', v));
    return out.replaceAll(RegExp(r'[ \t]{2,}'), ' ').trim();
  }

  Future<void> _saveTpl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tplKey, _tplCtrl.text);
  }

  Future<void> _markSent(DueRow r, bool sent) async {
    setState(() {
      if (sent) {
        final d = DateTime.now();
        _sent['${r.customerId}'] =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      } else {
        _sent.remove('${r.customerId}');
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sentKey, jsonEncode(_sent));
  }

  void _say(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 2)));
  }

  Future<void> _copy(DueRow r) async {
    await Clipboard.setData(ClipboardData(text: _message(r)));
    _say('Message copied');
  }

  Future<void> _open(DueRow r, {required bool whatsapp}) async {
    final intl = r.phoneIntl;
    if (intl == null) return;
    final text = Uri.encodeComponent(_message(r));
    final uri = whatsapp ? Uri.parse('https://wa.me/$intl?text=$text') : Uri.parse('sms:+$intl?&body=$text');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) throw 'cannot launch';
      await _markSent(r, true);
    } catch (_) {
      // কম্পিউটারে SMS app না থাকলে বার্তা কপি করে দিই
      await Clipboard.setData(ClipboardData(text: _message(r)));
      _say(whatsapp ? 'Could not open WhatsApp — message copied' : 'No SMS app here — message copied');
    }
  }

  // ───── ফিল্টার ─────
  List<DueRow> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    final list = _rows.where((r) {
      if (r.daysOverdue < _minDays) return false;
      if (q.isEmpty) return true;
      return r.name.toLowerCase().contains(q) || r.phone.toLowerCase().contains(q);
    }).toList();
    switch (_sort) {
      case 'age':
        list.sort((a, b) => b.daysOverdue.compareTo(a.daysOverdue));
      case 'name':
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      default:
        list.sort((a, b) => b.netDue.compareTo(a.netDue));
    }
    return list;
  }

  // ───── UI ─────
  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final totalPages = (list.length / _pageSize).ceil().clamp(1, 1 << 30);
    final page = _page.clamp(1, totalPages);
    final start = (page - 1) * _pageSize;
    final shown = list.skip(start).take(_pageSize).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_loading)
            const Padding(padding: EdgeInsets.all(60), child: Center(child: CircularProgressIndicator()))
          else if (_error.isNotEmpty)
            WPanel(
              child: WEmpty(
                icon: Icons.error_outline_rounded,
                title: 'Could not load reminders',
                body: _error,
                actionLabel: 'Try again',
                onAction: _load,
              ),
            )
          else ...[
            _summaryBar(),
            const SizedBox(height: 12),
            _templatePanel(),
            const SizedBox(height: 12),
            _filterBar(list.length),
            const SizedBox(height: 12),
            WPanel(
              padding: EdgeInsets.zero,
              child: list.isEmpty
                  ? WEmpty(
                      icon: Icons.notifications_none_rounded,
                      title: _rows.isEmpty ? 'No customer owes you anything' : 'No customer matches',
                      body: _rows.isEmpty
                          ? 'When a customer has a due balance, they will appear here.'
                          : 'Try a different search or age filter.',
                    )
                  : Column(
                      children: [
                        _tableHead(),
                        for (final r in shown) _tableRow(r),
                        WPager(
                          page: page,
                          totalPages: totalPages,
                          count: list.length,
                          from: start + 1,
                          to: start + shown.length,
                          onPage: (p) => setState(() => _page = p),
                        ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryBar() {
    final total = (_summary['total_due'] as num?)?.toDouble() ?? 0;
    return Column(
      children: [
        WSumBar(
          margin: EdgeInsets.zero,
          items: [
            WSum('Customers owing', '${_summary['total_customers'] ?? _rows.length}'),
            WSum('Total due', '৳${_money(total)}', color: W.redInk(context)),
            WSum('With phone', '${_summary['with_phone'] ?? 0}', color: W.greenInk(context)),
            WSum('No phone', '${_summary['without_phone'] ?? 0}',
                color: (_summary['without_phone'] ?? 0) == 0 ? null : W.amberInk(context)),
            WSum('Oldest due', '${_summary['oldest_days'] ?? 0} days'),
          ],
        ),
        if (_summary['truncated'] == true)
          const WNotice(
            tone: WTone.amber,
            icon: Icons.info_outline_rounded,
            text: 'Showing the 1000 highest dues only.',
            margin: EdgeInsets.only(top: 8),
          ),
      ],
    );
  }

  Widget _templatePanel() {
    const vars = ['{name}', '{amount}', '{shop}', '{phone}', '{invoices}', '{days}'];
    return WPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(W.rMd),
            onTap: () => setState(() => _tplOpen = !_tplOpen),
            child: Row(
              children: [
                Expanded(
                  child: WPanelHead('Message template',
                      note: _tplOpen ? 'Edit the text sent to every customer' : 'Tap to edit the message wording'),
                ),
                Icon(_tplOpen ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: W.muted(context)),
              ],
            ),
          ),
          if (_tplOpen) ...[
            const SizedBox(height: 14),
            TextField(
              controller: _tplCtrl,
              minLines: 3,
              maxLines: 6,
              onChanged: (_) {
                setState(() {});
                _saveTpl();
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Insert:', style: TextStyle(fontSize: 13, color: W.muted(context))),
                for (final v in vars)
                  WChip(
                    label: v,
                    onTap: () {
                      final sel = _tplCtrl.selection;
                      final t = _tplCtrl.text;
                      final at = sel.isValid ? sel.start : t.length;
                      _tplCtrl.value = TextEditingValue(
                        text: t.replaceRange(at, sel.isValid ? sel.end : t.length, v),
                        selection: TextSelection.collapsed(offset: at + v.length),
                      );
                      setState(() {});
                      _saveTpl();
                    },
                  ),
                TextButton(
                  onPressed: () {
                    _tplCtrl.text = _defaultTpl;
                    setState(() {});
                    _saveTpl();
                  },
                  child: const Text('Reset to default'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: W.soft(context),
                border: Border.all(color: W.line(context)),
                borderRadius: BorderRadius.circular(W.rMd),
              ),
              child: Text(
                _rows.isEmpty ? _tplCtrl.text : _message(_rows.first),
                style: TextStyle(fontSize: 13.5, color: W.ink2(context)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _filterBar(int count) {
    const dayOpts = [(0, 'Any age'), (7, '7+ days'), (15, '15+ days'), (30, '30+ days'), (60, '60+ days')];
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 320,
          child: WSearchField(
            controller: _searchCtrl,
            hint: 'Search name or phone',
            showClear: _searchCtrl.text.isNotEmpty,
            onChanged: (_) => setState(() => _page = 1),
            onClear: () => setState(() {
              _searchCtrl.clear();
              _page = 1;
            }),
          ),
        ),
        for (final (d, label) in dayOpts)
          WChip(
            label: label,
            selected: _minDays == d,
            onTap: () => setState(() {
              _minDays = d;
              _page = 1;
            }),
          ),
        WSeg(
          items: const [('amount', 'Most owed'), ('age', 'Oldest first'), ('name', 'Name')],
          value: _sort,
          onChanged: (v) => setState(() {
            _sort = v;
            _page = 1;
          }),
        ),
        OutlinedButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Refresh'),
        ),
      ],
    );
  }

  static const _cols = [3, 1, 2, 2, 3]; // flex: Customer, Invoices, Oldest due, Amount, Actions

  Widget _tableHead() {
    TextStyle s = TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: W.muted(context));
    Widget c(int i, String t, {TextAlign a = TextAlign.left}) =>
        Expanded(flex: _cols[i], child: Text(t, textAlign: a, style: s));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: W.soft(context),
        border: Border(bottom: BorderSide(color: W.line(context))),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(W.rLg)),
      ),
      child: Row(children: [
        c(0, 'Customer'),
        c(1, 'Invoices'),
        c(2, 'Oldest due'),
        c(3, 'Net due', a: TextAlign.right),
        c(4, 'Remind', a: TextAlign.right),
      ]),
    );
  }

  Widget _tableRow(DueRow r) {
    final sentOn = _sent['${r.customerId}'];
    final hasPhone = r.phoneIntl != null;
    final ageTone = r.daysOverdue >= 30
        ? WTone.red
        : r.daysOverdue >= 7
            ? WTone.amber
            : WTone.neutral;

    Widget iconBtn(IconData icon, String tip, VoidCallback? onTap, {Color? color}) => IconButton(
          tooltip: tip,
          visualDensity: VisualDensity.compact,
          onPressed: onTap,
          icon: Icon(icon, size: 19, color: onTap == null ? W.line2(context) : (color ?? W.ink2(context))),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: W.line(context)))),
      child: Row(
        children: [
          Expanded(
            flex: _cols[0],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: W.ink(context))),
                const SizedBox(height: 2),
                Text(r.phone.isEmpty ? 'No phone' : r.phone,
                    style: TextStyle(
                        fontSize: 12.5, color: r.phone.isEmpty ? W.amberInk(context) : W.muted(context))),
              ],
            ),
          ),
          Expanded(flex: _cols[1], child: Text('${r.invoiceCount}', style: TextStyle(color: W.ink2(context)))),
          Expanded(
            flex: _cols[2],
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.oldestDueDate ?? '—', style: TextStyle(fontSize: 13, color: W.ink2(context))),
                  const SizedBox(height: 3),
                  WPill('${r.daysOverdue} days', tone: ageTone),
                ],
              ),
            ),
          ),
          Expanded(
            flex: _cols[3],
            child: Text('৳${_money(r.netDue)}',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: W.redInk(context),
                    fontFeatures: W.tabular)),
          ),
          Expanded(
            flex: _cols[4],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (sentOn != null) ...[
                  Tooltip(message: 'Marked sent on $sentOn', child: const WPill('Sent', tone: WTone.green)),
                  const SizedBox(width: 4),
                ],
                iconBtn(Icons.chat_rounded, hasPhone ? 'WhatsApp' : 'No valid phone number',
                    hasPhone ? () => _open(r, whatsapp: true) : null,
                    color: W.greenInk(context)),
                iconBtn(Icons.sms_outlined, hasPhone ? 'SMS' : 'No valid phone number',
                    hasPhone ? () => _open(r, whatsapp: false) : null),
                iconBtn(Icons.copy_rounded, 'Copy message', () => _copy(r)),
                iconBtn(
                  sentOn == null ? Icons.check_circle_outline_rounded : Icons.undo_rounded,
                  sentOn == null ? 'Mark as sent' : 'Clear sent mark',
                  () => _markSent(r, sentOn == null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
