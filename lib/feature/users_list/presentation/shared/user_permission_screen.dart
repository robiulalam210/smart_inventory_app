import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '../../data/model/permission_catalog.dart';
import '../../data/repositories/user_permission_repo.dart';

/// Super Admin / Admin একজন user কে module ভিত্তিক permission দেয়।
///
/// একই screen mobile ও desktop দুই জায়গায় চলে — চওড়া screen (≥ 900px) এ
/// বাঁয়ে user summary + quick actions, ডানে module grid; ছোট screen এ এক column.
///
/// নিয়ম:
/// - Create / Edit / Delete / POS ইত্যাদি চালু করলে View নিজে থেকেই চালু হয়
///   (যে জিনিস দেখতে পারে না, সেটা এডিট করার মানে নেই)
/// - View বন্ধ করলে ওই module এর সব action বন্ধ হয়
/// - Save না করা পর্যন্ত কিছুই server এ যায় না; নিচের bar এ কয়টা পরিবর্তন হয়েছে দেখায়
class UserPermissionScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const UserPermissionScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserPermissionScreen> createState() => _UserPermissionScreenState();
}

class _UserPermissionScreenState extends State<UserPermissionScreen> {
  final _repo = const UserPermissionRepo();
  final _searchCtrl = TextEditingController();

  UserPermissionDetail? _detail;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String _query = '';

  /// server এ যা আছে
  Map<String, Map<String, bool>> _original = {};

  /// screen এ এখন যা দেখা যাচ্ছে (save না করা পরিবর্তন সহ)
  Map<String, Map<String, bool>> _current = {};

  bool get _editable => _detail?.editable ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────── data ─────────────────────────

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _repo.fetch(context, widget.userId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (!result.isOk) {
        _error = result.error;
        // আগের data থাকলে screen রেখে শুধু জানিয়ে দেওয়া
        if (_detail != null) _toast('Could not reload', result.error ?? '', error: true);
        return;
      }
      _detail = result.data;
      _original = _normalize(result.data!.permissions);
      _current = _copy(_original);
    });
  }

  /// শুধু catalog এ থাকা module/action রাখা — না থাকলে false
  Map<String, Map<String, bool>> _normalize(Map<String, Map<String, bool>> src) {
    return {
      for (final m in PermissionCatalog.allModules)
        m.key: {for (final a in m.actions) a.key: src[m.key]?[a.key] ?? false},
    };
  }

  Map<String, Map<String, bool>> _copy(Map<String, Map<String, bool>> src) =>
      {for (final e in src.entries) e.key: Map<String, bool>.from(e.value)};

  bool _isOn(String module, String action) => _current[module]?[action] ?? false;

  bool _isChanged(String module, String action) =>
      (_original[module]?[action] ?? false) != _isOn(module, action);

  int get _changedCount {
    var n = 0;
    for (final m in PermissionCatalog.allModules) {
      for (final a in m.actions) {
        if (_isChanged(m.key, a.key)) n++;
      }
    }
    return n;
  }

  int _enabledIn(PermissionModuleDef m) => m.actions.where((a) => _isOn(m.key, a.key)).length;

  int get _enabledTotal => PermissionCatalog.allModules.fold(0, (s, m) => s + _enabledIn(m));

  // ───────────────────────── editing ─────────────────────────

  void _toggle(PermissionModuleDef module, String action, bool value) {
    if (!_editable) return;
    setState(() {
      final map = _current[module.key]!;
      map[action] = value;
      if (value && action != 'view') map['view'] = true; // কিছু করতে হলে আগে দেখতে হবে
      if (!value && action == 'view') {
        for (final a in module.actions) {
          map[a.key] = false;
        }
      }
    });
  }

  void _setModule(PermissionModuleDef module, bool value) {
    if (!_editable) return;
    setState(() {
      for (final a in module.actions) {
        _current[module.key]![a.key] = value;
      }
    });
  }

  void _applyPreset(_Preset preset) {
    if (!_editable) return;
    setState(() {
      for (final m in PermissionCatalog.allModules) {
        for (final a in m.actions) {
          _current[m.key]![a.key] = switch (preset) {
            _Preset.full => true,
            _Preset.viewOnly => a.key == 'view',
            _Preset.none => false,
          };
        }
      }
    });
  }

  void _discard() => setState(() => _current = _copy(_original));

  Future<void> _save() async {
    if (!_editable || _saving || _changedCount == 0) return;
    setState(() => _saving = true);
    final result = await _repo.save(widget.userId, _current);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.isOk) {
      _toast('Permissions saved', 'Changes apply the next time ${_detail?.displayName ?? 'the user'} opens the app.');
      await _load();
    } else {
      _toast('Could not save', result.error ?? 'Please try again', error: true);
    }
  }

  Future<void> _resetToRole() async {
    if (!_editable) return;
    final ok = await showConfirmPopover(
      context,
      title: 'Reset to role default?',
      message: 'All custom permissions of ${_detail?.displayName} will be replaced by the '
          'default permissions of the "${_detail?.roleDisplay}" role.',
      confirmText: 'Reset',
      tone: PopoverTone.warning,
      icon: Icons.restart_alt_rounded,
    );
    if (!ok || !mounted) return;
    setState(() => _saving = true);
    final result = await _repo.resetToRole(widget.userId);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.isOk) {
      _toast('Reset complete', 'Permissions now follow the ${_detail?.roleDisplay} role.');
      await _load();
    } else {
      _toast('Could not reset', result.error ?? 'Please try again', error: true);
    }
  }

  Future<void> _confirmLeave() async {
    final ok = await showConfirmPopover(
      context,
      title: 'Discard changes?',
      message: 'You have $_changedCount unsaved permission change(s). Leave without saving?',
      confirmText: 'Discard',
      tone: PopoverTone.danger,
      icon: Icons.warning_amber_rounded,
    );
    if (ok && mounted) {
      _discard();
      Navigator.of(context).pop();
    }
  }

  void _toast(String title, String message, {bool error = false}) {
    showCustomToast(
      context: context,
      title: title,
      description: message,
      icon: error ? Icons.error_outline : Icons.check_circle_outline,
      primaryColor: error ? AppColors.danger : AppColors.success,
    );
  }

  // ───────────────────────── UI ─────────────────────────

  List<PermissionGroupDef> get _visibleGroups {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return PermissionCatalog.groups;
    return [
      for (final g in PermissionCatalog.groups)
        if (g.modules.any((m) => _matches(m, q)))
          PermissionGroupDef(g.title, g.subtitle, g.modules.where((m) => _matches(m, q)).toList()),
    ];
  }

  bool _matches(PermissionModuleDef m, String q) =>
      m.label.toLowerCase().contains(q) ||
      m.description.toLowerCase().contains(q) ||
      m.actions.any((a) => a.label.toLowerCase().contains(q));

  @override
  Widget build(BuildContext context) {
    final dirty = _changedCount > 0;
    return PopScope(
      canPop: !dirty || _saving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: AppScaffold(
        appBar: AppBar(
          title: Text('User Permissions', style: AppTextStyle.titleMedium(context)),
          actions: [
            IconButton(
              tooltip: 'Reload',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loading || _saving ? null : _load,
            ),
            const SizedBox(width: 4),
          ],
        ),
        bottomNavigationBar: _SaveBar(
          visible: dirty || _saving,
          changed: _changedCount,
          saving: _saving,
          onDiscard: _discard,
          onSave: _save,
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading && _detail == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _detail == null) {
      return _ErrorState(message: _error!, onRetry: _load);
    }
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 900;
      final content = wide ? _wideLayout(c.maxWidth) : _narrowLayout(c.maxWidth);
      return Stack(
        children: [
          content,
          if (_loading || _saving)
            const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: 2)),
        ],
      );
    });
  }

  // Desktop / tablet: বাঁয়ে summary, ডানে module grid
  Widget _wideLayout(double width) {
    const sideWidth = 320.0;
    // ডান পাশের ListView এর padding (24 + 24) বাদ দিয়ে; 1px margin যাতে rounding এ card নিচে না নামে
    final gridWidth = width - sideWidth - 48 - 1;
    final columns = gridWidth >= 1000 ? 3 : (gridWidth >= 600 ? 2 : 1);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: sideWidth,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 0, 24),
            children: [
              _UserSummaryCard(
                detail: _detail!,
                enabled: _enabledTotal,
                total: PermissionCatalog.totalActions,
              ),
              const SizedBox(height: 16),
              _QuickActionsCard(
                editable: _editable,
                busy: _saving,
                onPreset: _applyPreset,
                onReset: _resetToRole,
              ),
              const SizedBox(height: 16),
              _GroupOverviewCard(enabledIn: _enabledIn),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            children: [
              if (!_editable) ...[_ReadOnlyBanner(detail: _detail!), const SizedBox(height: 16)],
              _SearchField(controller: _searchCtrl, onChanged: (v) => setState(() => _query = v)),
              const SizedBox(height: 8),
              const _RuleHint(),
              ..._groupSections(columns: columns, maxWidth: gridWidth),
            ],
          ),
        ),
      ],
    );
  }

  // Mobile: এক column
  Widget _narrowLayout(double width) {
    final columns = width >= 640 ? 2 : 1;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _UserSummaryCard(
          detail: _detail!,
          enabled: _enabledTotal,
          total: PermissionCatalog.totalActions,
          compact: true,
        ),
        const SizedBox(height: 12),
        if (!_editable) ...[_ReadOnlyBanner(detail: _detail!), const SizedBox(height: 12)],
        if (_editable) ...[
          _PresetStrip(busy: _saving, onPreset: _applyPreset, onReset: _resetToRole),
          const SizedBox(height: 12),
        ],
        _SearchField(controller: _searchCtrl, onChanged: (v) => setState(() => _query = v)),
        const SizedBox(height: 8),
        const _RuleHint(),
        ..._groupSections(columns: columns, maxWidth: width - 32 - 1),
      ],
    );
  }

  List<Widget> _groupSections({required int columns, required double maxWidth}) {
    final groups = _visibleGroups;
    if (groups.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 40, color: AppColors.subText.withValues(alpha: 0.7)),
              const SizedBox(height: 8),
              Text('No module matches "$_query"', style: TextStyle(color: AppColors.subText)),
            ],
          ),
        ),
      ];
    }
    const spacing = 14.0;
    final cardWidth = (maxWidth - spacing * (columns - 1)) / columns;
    return [
      for (final g in groups) ...[
        const SizedBox(height: 20),
        _GroupHeader(group: g, enabledIn: _enabledIn),
        const SizedBox(height: 10),
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final m in g.modules)
              SizedBox(
                width: cardWidth,
                child: _ModuleCard(
                  module: m,
                  editable: _editable,
                  isOn: (a) => _isOn(m.key, a),
                  isChanged: (a) => _isChanged(m.key, a),
                  onToggle: (a, v) => _toggle(m, a, v),
                  onToggleAll: (v) => _setModule(m, v),
                ),
              ),
          ],
        ),
      ],
    ];
  }
}

enum _Preset { full, viewOnly, none }

// ═════════════════════════ widgets ═════════════════════════

BoxDecoration _cardDecoration(BuildContext context, {Color? borderColor}) => BoxDecoration(
      color: AppColors.bottomNavBg(context),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: borderColor ?? AppColors.greyColor(context).withValues(alpha: 0.22)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );

class _UserSummaryCard extends StatelessWidget {
  final UserPermissionDetail detail;
  final int enabled;
  final int total;
  final bool compact;

  const _UserSummaryCard({
    required this.detail,
    required this.enabled,
    required this.total,
    this.compact = false,
  });

  String get _initials {
    final parts = detail.displayName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  (String, Color, String) get _source => switch (detail.permissionSource.toUpperCase()) {
        'CUSTOM' => ('Custom', AppColors.info, 'Permissions were set manually for this user'),
        'MIXED' => ('Role + Custom', AppColors.warning, 'Started from role defaults, then changed manually'),
        _ => ('Role default', AppColors.success, 'Permissions come from the user\'s role'),
      };

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor(context);
    final ratio = total == 0 ? 0.0 : enabled / total;
    final (sourceLabel, sourceColor, sourceTip) = _source;

    final avatar = Container(
      width: compact ? 48 : 64,
      height: compact ? 48 : 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [primary, Color.lerp(primary, const Color(0xFF7C3AED), 0.55)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        _initials,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: compact ? 17 : 22),
      ),
    );

    final identity = Column(
      crossAxisAlignment: compact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          detail.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: compact ? 15 : 17, fontWeight: FontWeight.w700, color: AppColors.text(context)),
        ),
        if (detail.email.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(detail.email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: AppColors.subText)),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: compact ? WrapAlignment.start : WrapAlignment.center,
          children: [
            _Pill(label: detail.roleDisplay, color: primary, icon: Icons.badge_outlined),
            Tooltip(
              message: sourceTip,
              child: _Pill(label: sourceLabel, color: sourceColor, icon: Icons.tune_rounded),
            ),
          ],
        ),
      ],
    );

    final progress = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Access level',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.subText)),
            const Spacer(),
            Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: '$enabled',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context)),
                ),
                TextSpan(text: ' / $total', style: TextStyle(color: AppColors.subText)),
              ]),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: ratio),
            duration: const Duration(milliseconds: 350),
            builder: (_, v, __) => LinearProgressIndicator(
              value: v,
              minHeight: 7,
              backgroundColor: primary.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation(primary),
            ),
          ),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.all(compact ? 14 : 20),
      decoration: _cardDecoration(context),
      child: compact
          ? Column(
              children: [
                Row(children: [avatar, const SizedBox(width: 12), Expanded(child: identity)]),
                const SizedBox(height: 14),
                progress,
              ],
            )
          : Column(children: [avatar, const SizedBox(height: 12), identity, const SizedBox(height: 18), progress]),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final bool editable;
  final bool busy;
  final ValueChanged<_Preset> onPreset;
  final VoidCallback onReset;

  const _QuickActionsCard({
    required this.editable,
    required this.busy,
    required this.onPreset,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = editable && !busy;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick setup',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text(context))),
          const SizedBox(height: 4),
          Text('Apply to every module, then fine-tune below.',
              style: TextStyle(fontSize: 11.5, color: AppColors.subText)),
          const SizedBox(height: 12),
          _QuickButton(
            icon: Icons.verified_user_outlined,
            label: 'Full access',
            color: AppColors.success,
            onTap: enabled ? () => onPreset(_Preset.full) : null,
          ),
          _QuickButton(
            icon: Icons.visibility_outlined,
            label: 'View only',
            color: AppColors.info,
            onTap: enabled ? () => onPreset(_Preset.viewOnly) : null,
          ),
          _QuickButton(
            icon: Icons.block_rounded,
            label: 'Remove all',
            color: AppColors.danger,
            onTap: enabled ? () => onPreset(_Preset.none) : null,
          ),
          Divider(height: 20, color: AppColors.greyColor(context).withValues(alpha: 0.2)),
          _QuickButton(
            icon: Icons.restart_alt_rounded,
            label: 'Reset to role default',
            color: AppColors.warning,
            onTap: enabled ? onReset : null,
          ),
        ],
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickButton({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Opacity(
            opacity: disabled ? 0.45 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 17, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(label,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text(context))),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.subText),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile এ quick action গুলো আড়াআড়ি scroll হয়
class _PresetStrip extends StatelessWidget {
  final bool busy;
  final ValueChanged<_Preset> onPreset;
  final VoidCallback onReset;

  const _PresetStrip({required this.busy, required this.onPreset, required this.onReset});

  @override
  Widget build(BuildContext context) {
    Widget chip(IconData icon, String label, Color color, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ActionChip(
            avatar: Icon(icon, size: 16, color: color),
            label: Text(label),
            labelStyle: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.text(context)),
            backgroundColor: color.withValues(alpha: 0.08),
            side: BorderSide(color: color.withValues(alpha: 0.30)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onPressed: busy ? null : onTap,
          ),
        );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip(Icons.verified_user_outlined, 'Full access', AppColors.success, () => onPreset(_Preset.full)),
          chip(Icons.visibility_outlined, 'View only', AppColors.info, () => onPreset(_Preset.viewOnly)),
          chip(Icons.block_rounded, 'Remove all', AppColors.danger, () => onPreset(_Preset.none)),
          chip(Icons.restart_alt_rounded, 'Role default', AppColors.warning, onReset),
        ],
      ),
    );
  }
}

class _GroupOverviewCard extends StatelessWidget {
  final int Function(PermissionModuleDef) enabledIn;

  const _GroupOverviewCard({required this.enabledIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text(context))),
          const SizedBox(height: 10),
          for (final m in PermissionCatalog.allModules)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(m.icon, size: 16, color: m.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(m.label, style: TextStyle(fontSize: 12.5, color: AppColors.text(context))),
                  ),
                  _CountBadge(on: enabledIn(m), total: m.actions.length),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final PermissionGroupDef group;
  final int Function(PermissionModuleDef) enabledIn;

  const _GroupHeader({required this.group, required this.enabledIn});

  @override
  Widget build(BuildContext context) {
    final on = group.modules.fold<int>(0, (s, m) => s + enabledIn(m));
    final total = group.modules.fold<int>(0, (s, m) => s + m.actions.length);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.5,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor(context),
                  )),
              const SizedBox(height: 2),
              Text(group.subtitle, style: TextStyle(fontSize: 12, color: AppColors.subText)),
            ],
          ),
        ),
        Text('$on of $total enabled', style: TextStyle(fontSize: 11.5, color: AppColors.subText)),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final PermissionModuleDef module;
  final bool editable;
  final bool Function(String action) isOn;
  final bool Function(String action) isChanged;
  final void Function(String action, bool value) onToggle;
  final ValueChanged<bool> onToggleAll;

  const _ModuleCard({
    required this.module,
    required this.editable,
    required this.isOn,
    required this.isChanged,
    required this.onToggle,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    final on = module.actions.where((a) => isOn(a.key)).length;
    final total = module.actions.length;
    final all = on == total;
    final active = on > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 14),
      decoration: _cardDecoration(
        context,
        borderColor: active ? module.color.withValues(alpha: 0.35) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: module.color.withValues(alpha: active ? 0.14 : 0.07),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(module.icon, size: 21, color: active ? module.color : AppColors.subText),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(module.label,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text(context))),
                        ),
                        const SizedBox(width: 6),
                        _CountBadge(on: on, total: total),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(module.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.5, color: AppColors.subText, height: 1.3)),
                  ],
                ),
              ),
              Tooltip(
                message: all ? 'Turn off all' : 'Turn on all',
                child: Switch(
                  value: all,
                  activeColor: module.color,
                  onChanged: editable ? onToggleAll : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in module.actions)
                _ActionToggle(
                  action: a,
                  selected: isOn(a.key),
                  changed: isChanged(a.key),
                  onTap: editable ? () => onToggle(a.key, !isOn(a.key)) : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionToggle extends StatelessWidget {
  final PermissionActionDef action;
  final bool selected;
  final bool changed;
  final VoidCallback? onTap;

  const _ActionToggle({required this.action, required this.selected, required this.changed, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = action.color;
    final fg = selected ? color : AppColors.subText;
    return Semantics(
      button: true,
      toggled: selected,
      label: action.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha: 0.11) : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: selected ? color.withValues(alpha: 0.55) : AppColors.greyColor(context).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: Icon(
                    selected ? Icons.check_circle_rounded : action.icon,
                    key: ValueKey(selected),
                    size: 16,
                    color: fg,
                  ),
                ),
                const SizedBox(width: 6),
                Text(action.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? color : AppColors.text(context).withValues(alpha: 0.75),
                    )),
                // save না করা পরিবর্তন — ছোট বিন্দু দিয়ে চিহ্নিত
                if (changed) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int on;
  final int total;

  const _CountBadge({required this.on, required this.total});

  @override
  Widget build(BuildContext context) {
    final color = on == 0
        ? AppColors.subText
        : on == total
            ? AppColors.success
            : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$on/$total', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Pill({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(fontSize: 13.5, color: AppColors.text(context)),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search modules (e.g. sales, report, delete)',
        hintStyle: TextStyle(fontSize: 13, color: AppColors.subText),
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, v, __) => v.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
        ),
        filled: true,
        fillColor: AppColors.bottomNavBg(context),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.greyColor(context).withValues(alpha: 0.25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.greyColor(context).withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor(context), width: 1.4),
        ),
      ),
    );
  }
}

class _RuleHint extends StatelessWidget {
  const _RuleHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, top: 2),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 14, color: AppColors.subText),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Turning on Create, Edit or Delete also turns on View. Turning off View turns off the whole module.',
              style: TextStyle(fontSize: 11.5, color: AppColors.subText),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyBanner extends StatelessWidget {
  final UserPermissionDetail detail;

  const _ReadOnlyBanner({required this.detail});

  @override
  Widget build(BuildContext context) {
    final isSuper = detail.role.toUpperCase() == 'SUPER_ADMIN';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isSuper
                  ? 'Super Admin always has full access. These permissions cannot be changed.'
                  : 'You can view but not change this user\'s permissions.',
              style: TextStyle(fontSize: 12.5, color: AppColors.text(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  final bool visible;
  final int changed;
  final bool saving;
  final VoidCallback onDiscard;
  final VoidCallback onSave;

  const _SaveBar({
    required this.visible,
    required this.changed,
    required this.saving,
    required this.onDiscard,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: !visible
          ? const SizedBox(width: double.infinity)
          : Container(
              decoration: BoxDecoration(
                color: AppColors.bottomNavBg(context),
                border: Border(top: BorderSide(color: AppColors.greyColor(context).withValues(alpha: 0.2))),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -3)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          saving ? 'Saving…' : '$changed unsaved change${changed == 1 ? '' : 's'}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text(context)),
                        ),
                      ),
                      TextButton(
                        onPressed: saving ? null : onDiscard,
                        child: const Text('Discard'),
                      ),
                      const SizedBox(width: 6),
                      FilledButton.icon(
                        onPressed: saving ? null : onSave,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryColor(context),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: saving
                            ? const SizedBox(
                                width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Save changes'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_person_outlined, color: AppColors.danger, size: 30),
            ),
            const SizedBox(height: 14),
            Text('Could not load permissions',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text(context))),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppColors.subText)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
