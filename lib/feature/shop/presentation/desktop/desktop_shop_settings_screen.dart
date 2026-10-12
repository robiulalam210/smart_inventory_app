import 'package:flutter/material.dart';
import 'package:meherinMart/desktop/widgets/desk_kit.dart';
import 'package:meherinMart/feature/lab_dashboard/presentation/widgets/dash_kit.dart' show DashColors;
import 'package:meherinMart/feature/payroll/presentation/payroll_common.dart';

import '../../data/shop_models.dart';
import '../../data/shop_repo.dart';

/// Shop Settings — ডেস্কটপ ডিজাইন: বামে সেকশন-কার্ড, ডানে লাইভ প্রিভিউ + Save।
/// API: GET/PATCH /api/shop/settings/  (ব্যানার ছবি বদলানো এখনো শুধু ওয়েব থেকে)
class DesktopShopSettingsScreen extends StatefulWidget {
  const DesktopShopSettingsScreen({super.key});

  @override
  State<DesktopShopSettingsScreen> createState() => _DesktopShopSettingsScreenState();
}

class _F {
  final String key, label;
  final String? hint;
  final int lines;
  final bool money;
  const _F(this.key, this.label, {this.hint, this.lines = 1, this.money = false});
}

const _groups = <(String, String, IconData, List<_F>)>[
  ('Store', 'Basic info shown at the top of your shop.', Icons.storefront_outlined, [
    _F('shop_name', 'Shop name', hint: 'Empty = use the business name'),
    _F('tagline', 'Tagline'),
    _F('announcement', 'Top announcement'),
    _F('brand_color', 'Brand colour', hint: '#0f766e'),
  ]),
  ('Banner', 'The big section at the top of the home page.', Icons.image_outlined, [
    _F('hero_title', 'Banner title'),
    _F('hero_subtitle', 'Banner subtitle', lines: 2),
    _F('hero_button_text', 'Button text'),
  ]),
  ('About', 'A short story about your shop. Leave empty to hide the section.', Icons.info_outline_rounded, [
    _F('about_title', 'About title'),
    _F('about_text', 'About text', lines: 4),
  ]),
  ('Contact', 'Shown in the contact section and footer.', Icons.call_outlined, [
    _F('phone', 'Phone'),
    _F('whatsapp', 'WhatsApp', hint: 'Country code, digits only'),
    _F('email', 'Email'),
    _F('address', 'Address'),
    _F('opening_hours', 'Opening hours'),
    _F('facebook_url', 'Facebook page link'),
  ]),
  ('Delivery and payment', 'Delivery charge is added to every online order.', Icons.local_shipping_outlined, [
    _F('delivery_charge', 'Delivery charge', money: true),
    _F('free_delivery_min', 'Free delivery above', money: true, hint: '0 = no free delivery'),
    _F('delivery_note', 'Delivery note'),
    _F('payment_note', 'Payment note'),
  ]),
];

class _DesktopShopSettingsScreenState extends State<DesktopShopSettingsScreen> {
  final _repo = const ShopRepo();
  final Map<String, TextEditingController> _c = {};
  bool _isOpen = true;
  String _theme = 'auto';
  bool _loading = true, _saving = false, _dirty = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final g in _groups) {
      for (final f in g.$4) {
        _c[f.key] = TextEditingController()..addListener(_changed);
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

  void _changed() {
    if (!_loading && mounted) setState(() => _dirty = true);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final (d, err) = await _repo.settings(context);
    if (!mounted) return;
    setState(() {
      if (d == null) {
        _error = err;
      } else {
        _fill(d);
      }
      _loading = false;
      _dirty = false;
    });
  }

  void _fill(ShopSettingsData d) {
    _isOpen = d.isOpen;
    final t = d.text('default_theme');
    _theme = const ['auto', 'light', 'dark'].contains(t) ? t : 'auto';
    for (final g in _groups) {
      for (final f in g.$4) {
        _c[f.key]!.text = f.money ? shopNum(d.raw[f.key]).toStringAsFixed(2) : d.text(f.key);
      }
    }
  }

  Color _brand() {
    final h = _c['brand_color']!.text.trim().replaceFirst('#', '');
    final v = h.length == 6 ? int.tryParse('FF$h', radix: 16) : null;
    return v == null ? const Color(0xFF0F766E) : Color(v);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final err = await _repo.saveSettings({
      'is_open': _isOpen,
      'default_theme': _theme,
      for (final e in _c.entries) e.key: e.value.text.trim(),
    });
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (err == null) _dirty = false;
    });
    payToast(context, err ?? 'Shop settings saved.', error: err != null);
  }

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    return DeskPage(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DeskPageHeader(
          title: 'Shop Settings',
          subtitle: 'Name, banner, contact and delivery details of your online shop.',
          actions: [
            DeskButton(label: 'Reload', icon: Icons.refresh_rounded, outlined: true, onPressed: _loading ? null : _load),
            DeskButton(
              label: _saving ? 'Saving…' : 'Save changes',
              icon: Icons.check_rounded,
              onPressed: (_loading || _saving || _error != null || !_dirty) ? null : _save,
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (_loading)
          DeskState.loading()
        else if (_error != null)
          DeskState(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load shop settings',
            message: _error,
            color: c.red,
            action: DeskButton(label: 'Try again', icon: Icons.refresh_rounded, onPressed: _load),
          )
        else
          LayoutBuilder(builder: (context, box) {
            final wide = box.maxWidth >= 1000;
            final form = Column(children: [
              _openCard(c),
              for (final g in _groups) ...[const SizedBox(height: 14), _groupCard(c, g)],
            ]);
            if (!wide) return Column(children: [_preview(c), const SizedBox(height: 14), form]);
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 3, child: form),
              const SizedBox(width: 18),
              SizedBox(width: 340, child: _preview(c)),
            ]);
          }),
      ]),
    );
  }

  Widget _openCard(DashColors c) => DeskCard(
        child: Column(children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _isOpen,
            title: const Text('Accept online orders', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Turn off to pause new orders (the shop stays visible).'),
            onChanged: (v) => setState(() {
              _isOpen = v;
              _dirty = true;
            }),
          ),
          const Divider(height: 22),
          Row(children: [
            const Expanded(
              child: Text('Default theme', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 'auto', label: Text('Auto')),
                ButtonSegment(value: 'light', label: Text('Light')),
                ButtonSegment(value: 'dark', label: Text('Dark')),
              ],
              selected: {_theme},
              onSelectionChanged: (s) => setState(() {
                _theme = s.first;
                _dirty = true;
              }),
            ),
          ]),
        ]),
      );

  Widget _groupCard(DashColors c, (String, String, IconData, List<_F>) g) {
    return DeskCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: c.blue.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)),
            child: Icon(g.$3, size: 18, color: c.blue),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(g.$1, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c.ink)),
            Text(g.$2, style: TextStyle(fontSize: 12.5, color: c.muted)),
          ]),
        ]),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, box) {
          final cols = box.maxWidth >= 620 ? 2 : 1;
          final w = (box.maxWidth - (cols - 1) * 14) / cols;
          return Wrap(spacing: 14, runSpacing: 14, children: [
            for (final f in g.$4)
              SizedBox(width: f.lines > 1 ? box.maxWidth : w, child: _field(c, f)),
          ]);
        }),
      ]),
    );
  }

  Widget _field(DashColors c, _F f) {
    return TextField(
      controller: _c[f.key],
      minLines: f.lines,
      maxLines: f.lines,
      keyboardType: f.money ? const TextInputType.numberWithOptions(decimal: true) : null,
      style: TextStyle(fontSize: 14, color: c.ink),
      decoration: InputDecoration(
        labelText: f.label,
        hintText: f.hint,
        prefixText: f.money ? '৳ ' : null,
        suffixIcon: f.key == 'brand_color'
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: Container(width: 20, height: 20, decoration: BoxDecoration(color: _brand(), shape: BoxShape.circle, border: Border.all(color: c.line))),
              )
            : null,
        filled: true,
        fillColor: c.tint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.line)),
      ),
    );
  }

  Widget _preview(DashColors c) {
    final brand = _brand();
    final on = ThemeData.estimateBrightnessForColor(brand) == Brightness.dark ? Colors.white : const Color(0xFF111827);
    String t(String k, String fb) => _c[k]!.text.trim().isEmpty ? fb : _c[k]!.text.trim();
    return DeskCard(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Text('Live preview', style: TextStyle(fontWeight: FontWeight.w800, color: c.ink)),
        ),
        if (_c['announcement']!.text.trim().isNotEmpty)
          Container(
            width: double.infinity,
            color: brand,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Text(_c['announcement']!.text.trim(), textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: on)),
          ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [brand.withValues(alpha: .16), brand.withValues(alpha: .04)])),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t('shop_name', 'Your shop'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: brand)),
            const SizedBox(height: 8),
            Text(t('hero_title', 'Fresh products, delivered'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c.ink)),
            const SizedBox(height: 4),
            Text(t('hero_subtitle', t('tagline', 'Your tagline appears here')), style: TextStyle(fontSize: 12.5, color: c.muted)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: brand, borderRadius: BorderRadius.circular(8)),
              child: Text(t('hero_button_text', 'Shop now'), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: on)),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _pv(c, Icons.local_shipping_outlined, t('delivery_note', 'Delivery note')),
            _pv(c, Icons.payments_outlined, t('payment_note', 'Payment note')),
            _pv(c, Icons.call_outlined, t('phone', 'Phone number')),
            _pv(c, Icons.schedule_rounded, t('opening_hours', 'Opening hours')),
            if (!_isOpen)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Orders are paused', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.amber)),
              ),
          ]),
        ),
      ]),
    );
  }

  Widget _pv(DashColors c, IconData i, String s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Icon(i, size: 16, color: c.muted),
          const SizedBox(width: 8),
          Expanded(child: Text(s, style: TextStyle(fontSize: 12.5, color: c.ink2))),
        ]),
      );
}
