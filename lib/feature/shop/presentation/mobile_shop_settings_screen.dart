import 'package:flutter/material.dart';
import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:meherinMart/core/widgets/web_ui.dart';

import '../../payroll/presentation/payroll_common.dart';
import '../data/shop_models.dart';
import '../data/shop_repo.dart';

/// Shop Settings — অনলাইন শপের নাম, ঘোষণা, যোগাযোগ, delivery (ওয়েবের Shop Settings এর মতো)
/// ব্যানার ছবি বদলানো শুধু ওয়েব থেকে।
class MobileShopSettingsScreen extends StatefulWidget {
  const MobileShopSettingsScreen({super.key});

  @override
  State<MobileShopSettingsScreen> createState() => _MobileShopSettingsScreenState();
}

class _Field {
  final String key, label;
  final String? hint;
  final TextInputType type;
  final int lines;
  final bool money;
  const _Field(this.key, this.label,
      {this.hint, this.type = TextInputType.text, this.lines = 1, this.money = false});
}

const _groups = <(String, String, List<_Field>)>[
  (
    'Store',
    'Basic info shown at the top of your shop.',
    [
      _Field('shop_name', 'Shop name', hint: 'Empty = use the business name'),
      _Field('tagline', 'Tagline'),
      _Field('announcement', 'Top announcement'),
      _Field('brand_color', 'Brand colour', hint: 'Hex, e.g. #0f766e'),
    ]
  ),
  (
    'Banner',
    'The big section at the top of the home page.',
    [
      _Field('hero_title', 'Banner title'),
      _Field('hero_subtitle', 'Banner subtitle', lines: 2),
      _Field('hero_button_text', 'Banner button text'),
    ]
  ),
  (
    'About',
    'A short story about your shop. Leave empty to hide the section.',
    [
      _Field('about_title', 'About title'),
      _Field('about_text', 'About text', lines: 4),
    ]
  ),
  (
    'Contact',
    'Shown in the contact section and footer.',
    [
      _Field('phone', 'Phone', type: TextInputType.phone),
      _Field('whatsapp', 'WhatsApp number', hint: 'With country code, digits only', type: TextInputType.phone),
      _Field('email', 'Email', type: TextInputType.emailAddress),
      _Field('address', 'Address'),
      _Field('opening_hours', 'Opening hours'),
      _Field('facebook_url', 'Facebook page link', type: TextInputType.url),
    ]
  ),
  (
    'Delivery and payment',
    'Delivery charge is added to every online order.',
    [
      _Field('delivery_charge', 'Delivery charge', money: true),
      _Field('free_delivery_min', 'Free delivery above', money: true, hint: '0 = no free delivery'),
      _Field('delivery_note', 'Delivery note'),
      _Field('payment_note', 'Payment note'),
    ]
  ),
];

class _MobileShopSettingsScreenState extends State<MobileShopSettingsScreen> {
  final _repo = const ShopRepo();
  final Map<String, TextEditingController> _c = {};

  bool _isOpen = true;
  String _theme = 'auto';
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final g in _groups) {
      for (final f in g.$3) {
        _c[f.key] = TextEditingController();
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final (d, err) = await _repo.settings(context);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (d == null) {
        _error = err;
      } else {
        _fill(d);
      }
    });
  }

  void _fill(ShopSettingsData d) {
    _isOpen = d.isOpen;
    final t = d.text('default_theme');
    _theme = const ['auto', 'light', 'dark'].contains(t) ? t : 'auto';
    for (final g in _groups) {
      for (final f in g.$3) {
        _c[f.key]!.text = f.money ? shopNum(d.raw[f.key]).toStringAsFixed(2) : d.text(f.key);
      }
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final payload = <String, dynamic>{
      'is_open': _isOpen,
      'default_theme': _theme,
      for (final e in _c.entries) e.key: e.value.text.trim(),
    };
    final err = await _repo.saveSettings(payload);
    if (!mounted) return;
    setState(() => _saving = false);
    if (err != null) {
      payToast(context, err, error: true);
    } else {
      payToast(context, 'Shop settings saved.');
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text('Shop Settings', style: AppTextStyle.titleMedium(context))),
      bottomNavigationBar: (_loading || _error != null)
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(
                color: W.surface(context),
                border: Border(top: BorderSide(color: W.line(context))),
              ),
              child: SafeArea(
                top: false,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 46),
                    backgroundColor: W.blue(context),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(W.rMd)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                  ),
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined, size: 18),
                  label: Text(_saving ? 'Saving…' : 'Save settings'),
                ),
              ),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? WEmpty(
                  icon: Icons.error_outline,
                  title: 'Could not load shop settings',
                  body: _error!,
                  actionLabel: 'Try again',
                  onAction: _load,
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  children: [
                    WPanel(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _isOpen,
                            title: const Text('Accept orders', style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(_isOpen ? 'The shop is open.' : 'The shop is closed to new orders.'),
                            onChanged: (v) => setState(() => _isOpen = v),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _theme,
                            isExpanded: true,
                            decoration: wInput(context, 'Default mode'),
                            items: const [
                              DropdownMenuItem(value: 'auto', child: Text('Follow the visitor\'s device')),
                              DropdownMenuItem(value: 'light', child: Text('Always light')),
                              DropdownMenuItem(value: 'dark', child: Text('Always dark')),
                            ],
                            onChanged: (v) => setState(() => _theme = v ?? 'auto'),
                          ),
                        ],
                      ),
                    ),
                    for (final g in _groups) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
                        child: WPanelHead(g.$1, note: g.$2),
                      ),
                      WPanel(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Column(
                          children: [
                            for (final f in g.$3)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: TextField(
                                  controller: _c[f.key],
                                  keyboardType: f.money
                                      ? const TextInputType.numberWithOptions(decimal: true)
                                      : (f.lines > 1 ? TextInputType.multiline : f.type),
                                  minLines: f.lines,
                                  maxLines: f.lines,
                                  decoration: wInput(context, f.label,
                                      hint: f.hint, prefix: f.money ? '৳ ' : null),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 14, 4, 0),
                      child: Text('To change the banner picture, use Shop Settings on the web.',
                          style: TextStyle(fontSize: 13, color: W.muted(context))),
                    ),
                  ],
                ),
    );
  }
}
