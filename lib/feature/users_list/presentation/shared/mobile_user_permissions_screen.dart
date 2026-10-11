import 'package:flutter/material.dart';
import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';

import '../../data/model/permission_catalog.dart';
import '../../data/repositories/user_permission_repo.dart';
import 'user_permission_screen.dart';

/// User Permissions — ওয়েবের Security → User Permissions পেজের মতো।
/// একজনকে বেছে নিলে তার "কী কী করতে পারবে" এডিটর (UserPermissionScreen) খোলে।
/// শুধু Super Admin / Admin; Admin দের সব থাকে, তাই তাদের বদলানো যায় না।
class MobileUserPermissionsScreen extends StatefulWidget {
  const MobileUserPermissionsScreen({super.key});

  @override
  State<MobileUserPermissionsScreen> createState() => _MobileUserPermissionsScreenState();
}

class _MobileUserPermissionsScreenState extends State<MobileUserPermissionsScreen> {
  static const _roleLabels = {
    'SUPER_ADMIN': 'Super Admin',
    'ADMIN': 'Admin',
    'MANAGER': 'Manager',
    'STAFF': 'Staff',
    'VIEWER': 'Viewer',
  };

  final _repo = const UserPermissionRepo();
  final _search = TextEditingController();

  List<TeamPerson> _people = const [];
  String _view = 'active'; // active | off | all
  String _q = '';
  bool _loading = true;
  String? _error;

  late final List<String> _moduleKeys = [for (final m in PermissionCatalog.allModules) m.key];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final r = await _repo.team(context);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r.isOk) {
        _people = r.data ?? const [];
      } else {
        _error = r.error;
      }
    });
  }

  String _role(String r) => _roleLabels[r] ?? r;

  List<TeamPerson> get _rows {
    final q = _q.trim().toLowerCase();
    return _people.where((u) {
      if (_view == 'active' && !u.isActive) return false;
      if (_view == 'off' && u.isActive) return false;
      if (q.isEmpty) return true;
      return [u.name, u.username, u.email, _role(u.role)].any((v) => v.toLowerCase().contains(q));
    }).toList();
  }

  String _reachText(TeamPerson u) {
    if (u.isAdmin) return 'Everything';
    final n = u.reach(_moduleKeys);
    return n == _moduleKeys.length ? 'Sees everything' : '$n of ${_moduleKeys.length} areas';
  }

  Future<void> _open(TeamPerson u) async {
    await AppRoutes.push(context, UserPermissionScreen(userId: '${u.id}', userName: u.name));
    if (mounted) _load(); // বদল হয়ে থাকলে সারাংশ নতুন করে আনা
  }

  Color _hue(String username) {
    var h = 0;
    for (final c in username.codeUnits) {
      h = (h * 31 + c) % 360;
    }
    return HSLColor.fromAHSL(1, h.toDouble(), 0.55, 0.45).toColor();
  }

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (p.isEmpty) return '?';
    return (p.first[0] + (p.length > 1 ? p.last[0] : '')).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final on = _people.where((u) => u.isActive).length;
    final chips = [
      ('active', 'Active', on),
      ('off', 'Turned off', _people.length - on),
      ('all', 'All', _people.length),
    ];
    return AppScaffold(
      appBar: AppBar(
        title: Text('User Permissions', style: AppTextStyle.titleMedium(context)),
        actions: [
          IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loading ? null : _load),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pick a person to choose what they can see and do. Admins always have full access.',
                style: AppTextStyle.bodySmall(context),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _q = v),
              decoration: InputDecoration(
                hintText: 'Search by name, username, role',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _q.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          setState(() => _q = '');
                        },
                      ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in chips)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('${c.$2} (${c.$3})'),
                        selected: _view == c.$1,
                        onSelected: (_) => setState(() => _view = c.$1),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading && _people.isEmpty) return const Center(child: CircularProgressIndicator());
    if (_error != null && _people.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 44, color: AppColors.danger),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _load, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }
    final rows = _rows;
    if (rows.isEmpty) {
      return const Center(child: Text('No one matches.'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        itemCount: rows.length,
        itemBuilder: (context, i) => _personCard(context, rows[i]),
      ),
    );
  }

  Widget _personCard(BuildContext context, TeamPerson u) {
    final color = _hue(u.username);
    final source = u.isAdmin
        ? null
        : (u.permissionSource == 'ROLE' ? 'Role defaults' : 'Customised');
    return Opacity(
      opacity: u.isActive ? 1 : 0.55,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 0,
        color: AppColors.bottomNavBg(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.greyColor(context).withValues(alpha: 0.35), width: 0.6),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _open(u),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Text(_initials(u.name),
                      style: TextStyle(color: color, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(u.name,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.titleMedium(context)),
                          ),
                          if (u.isMe)
                            const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Text('(you)', style: TextStyle(fontSize: 12, color: AppColors.slate500)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${_role(u.role)} · @${u.username}',
                          overflow: TextOverflow.ellipsis, style: AppTextStyle.bodySmall(context)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _chip(_reachText(u), AppColors.info),
                          if (source != null)
                            _chip(source,
                                u.permissionSource == 'ROLE' ? AppColors.slate500 : AppColors.warning),
                          if (!u.isActive) _chip('Turned off', AppColors.danger),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(u.canEditPermissions ? Icons.chevron_right : Icons.lock_outline,
                    color: AppColors.greyColor(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}
