import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meherinMart/core/widgets/app_alert_dialog.dart';
import 'package:meherinMart/core/widgets/app_loader.dart';
import 'package:meherinMart/core/widgets/web_ui.dart';
import 'package:meherinMart/desktop/widgets/desk_kit.dart';
import 'package:meherinMart/feature/lab_dashboard/presentation/widgets/dash_kit.dart' show DashColors;

import '../../data/model/user_model.dart';
import '../bloc/users/user_bloc.dart';
import '../widget/widget.dart' show PermissionAccess;

/// Users — ডেস্কটপ ডিজাইন: সার্চ, role chip, avatar সহ টেবিল, active switch, Permissions বোতাম।
/// আগের UsersScreen এর bloc/event একই — শুধু চেহারা বদলেছে।
class DesktopUsersScreen extends StatefulWidget {
  const DesktopUsersScreen({super.key});

  @override
  State<DesktopUsersScreen> createState() => _DesktopUsersScreenState();
}

class _DesktopUsersScreenState extends State<DesktopUsersScreen> {
  String _role = 'all';
  int _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  void _fetch({String? q, int? page}) {
    final bloc = context.read<UserBloc>();
    _page = page ?? 0;
    bloc.add(FetchUserList(context, filterText: q ?? bloc.filterTextController.text, pageNumber: _page));
  }

  void _dismissDialog(String title, String content) {
    appAlertDialog(context, content,
        title: title,
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Dismiss'))]);
  }

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    final bloc = context.read<UserBloc>();
    return DeskPage(
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserAddLoading) {
            appLoader(context, 'User, please wait...');
          } else if (state is UserAddSuccess) {
            Navigator.pop(context);
            Navigator.pop(context);
            _fetch(page: _page);
          } else if (state is UserSwitchLoading) {
            appLoader(context, 'Update User, please wait...');
          } else if (state is UserSwitchSuccess) {
            Navigator.pop(context);
            _fetch(page: _page);
          } else if (state is UserSwitchFailed) {
            Navigator.pop(context);
            _dismissDialog(state.title, state.content);
            _fetch(page: _page);
          } else if (state is UserAddFailed) {
            Navigator.pop(context);
            Navigator.pop(context);
            _fetch(page: _page);
            _dismissDialog(state.title, state.content);
          }
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          DeskPageHeader(
            title: 'Users',
            subtitle: 'People who can sign in to your software. Open Permissions to choose what each one can do.',
            actions: [DeskButton(label: 'Refresh', icon: Icons.refresh_rounded, outlined: true, onPressed: () => _fetch(page: _page))],
          ),
          const SizedBox(height: 16),
          BlocBuilder<UserBloc, UserState>(
            buildWhen: (p, s) => s is UserListSuccess || s is UserListFailed || s is UserListLoading,
            builder: (context, state) {
              if (state is UserListLoading) return DeskState.loading();
              if (state is UserListFailed) {
                return DeskState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Could not load users',
                  message: state.content,
                  color: c.red,
                  action: DeskButton(label: 'Try again', icon: Icons.refresh_rounded, onPressed: _fetch),
                );
              }
              if (state is! UserListSuccess) return const SizedBox.shrink();
              return _body(context, c, bloc, state);
            },
          ),
        ]),
      ),
    );
  }

  Widget _body(BuildContext context, DashColors c, UserBloc bloc, UserListSuccess s) {
    final roles = <String>{for (final u in s.list) if ((u.role ?? '').isNotEmpty) u.role!}.toList()..sort();
    final shown = _role == 'all' ? s.list : s.list.where((u) => u.role == _role).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        DeskSearchField(
          controller: bloc.filterTextController,
          hint: 'Search name, email or phone…',
          width: 340,
          onChanged: (v) => _fetch(q: v),
          onClear: () {
            bloc.filterTextController.clear();
            _fetch(q: '');
          },
        ),
        const SizedBox(width: 6),
        WChip(label: 'All', count: s.list.length, selected: _role == 'all', onTap: () => setState(() => _role = 'all')),
        for (final r in roles)
          WChip(
            label: r,
            count: s.list.where((u) => u.role == r).length,
            selected: _role == r,
            onTap: () => setState(() => _role = r),
          ),
      ]),
      const SizedBox(height: 14),
      if (shown.isEmpty)
        const DeskState(icon: Icons.person_search_outlined, title: 'No users found', message: 'Try a different search or role.')
      else
        FutureBuilder<bool>(
          future: PermissionAccess.canManage(),
          initialData: PermissionAccess.lastKnown,
          builder: (context, snap) => _table(context, c, shown, snap.data ?? false),
        ),
      if (s.totalPages > 1) ...[const SizedBox(height: 12), _pager(c, s)],
    ]);
  }

  Widget _th(String t, DashColors c, {int flex = 1, double? width, bool right = false}) {
    final w = Text(t.toUpperCase(),
        textAlign: right ? TextAlign.right : TextAlign.left,
        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: .5, color: c.muted));
    return width != null ? SizedBox(width: width, child: w) : Expanded(flex: flex, child: w);
  }

  Widget _table(BuildContext context, DashColors c, List<UsersListModel> users, bool canManage) {
    return DeskCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
          child: Row(children: [
            _th('User', c, flex: 4),
            _th('Contact', c, flex: 4),
            _th('Role', c, width: 110),
            _th('Active', c, width: 80),
            _th('', c, width: canManage ? 250 : 110),
          ]),
        ),
        Divider(height: 1, color: c.line),
        for (final u in users) _row(context, c, u, canManage),
      ]),
    );
  }

  String _name(UsersListModel u) {
    final n = (u.fullName ?? '').trim();
    return n.isNotEmpty ? n : (u.username ?? 'No name');
  }

  Widget _row(BuildContext context, DashColors c, UsersListModel u, bool canManage) {
    final name = _name(u);
    final active = u.isActive ?? false;
    final isAdmin = (u.role ?? '').toUpperCase().contains('ADMIN');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
      child: Row(children: [
        Expanded(
          flex: 4,
          child: Row(children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: (isAdmin ? c.purple : c.blue).withValues(alpha: .14),
              child: Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.w800, color: isAdmin ? c.purple : c.blue)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700, color: c.ink)),
                if ((u.username ?? '').isNotEmpty) Text('@${u.username}', style: TextStyle(fontSize: 12, color: c.muted)),
              ]),
            ),
          ]),
        ),
        Expanded(
          flex: 4,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text((u.email ?? '').isEmpty ? '—' : u.email!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: c.ink2)),
            Text((u.phone ?? '').isEmpty ? '—' : u.phone!, style: TextStyle(fontSize: 12, color: c.muted)),
          ]),
        ),
        SizedBox(
          width: 110,
          child: Align(
            alignment: Alignment.centerLeft,
            child: WPill((u.role ?? '—'), tone: isAdmin ? WTone.blue : WTone.neutral),
          ),
        ),
        SizedBox(
          width: 80,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Switch(
              value: active,
              onChanged: canManage && u.id != null ? (v) => context.read<UserBloc>().add(UserSwitch(context, u.id!, v)) : null,
            ),
          ),
        ),
        SizedBox(
          width: canManage ? 250 : 110,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            DeskButton(label: 'Details', icon: Icons.visibility_outlined, outlined: true, onPressed: () => _details(context, c, u)),
            if (canManage) ...[
              const SizedBox(width: 8),
              DeskButton(label: 'Permissions', icon: Icons.admin_panel_settings_outlined, onPressed: () => PermissionAccess.open(context, u)),
            ],
          ]),
        ),
      ]),
    );
  }

  void _details(BuildContext context, DashColors c, UsersListModel u) {
    Widget kv(String k, String? v) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 110, child: Text(k, style: TextStyle(color: c.muted))),
            Expanded(child: SelectableText((v ?? '').isEmpty ? '—' : v!, style: TextStyle(color: c.ink))),
          ]),
        );
    showDeskDialog<void>(
      context,
      Padding(
        padding: const EdgeInsets.all(22),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_name(u), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.ink)),
          const SizedBox(height: 16),
          kv('Username', u.username),
          kv('Email', u.email),
          kv('Phone', u.phone),
          kv('Role', u.role),
          kv('Permissions', u.permissionSource),
          kv('Status', (u.isActive ?? false) ? 'Active' : 'Inactive'),
          kv('Verified', (u.isVerified ?? false) ? 'Yes' : 'No'),
          const SizedBox(height: 6),
          Align(alignment: Alignment.centerRight, child: DeskButton(label: 'Close', outlined: true, onPressed: () => Navigator.pop(context))),
        ]),
      ),
      width: 480,
    );
  }

  Widget _pager(DashColors c, UserListSuccess s) {
    Widget arrow(IconData i, bool on, VoidCallback t) => Opacity(
          opacity: on ? 1 : .4,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: on ? t : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line), borderRadius: BorderRadius.circular(8)),
              child: Icon(i, size: 18, color: c.ink2),
            ),
          ),
        );
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Text('Page ${s.currentPage + 1} of ${s.totalPages}', style: TextStyle(color: c.muted, fontSize: 13)),
      const SizedBox(width: 10),
      arrow(Icons.chevron_left_rounded, s.currentPage > 0, () => _fetch(page: s.currentPage - 1)),
      const SizedBox(width: 6),
      arrow(Icons.chevron_right_rounded, s.currentPage < s.totalPages - 1, () => _fetch(page: s.currentPage + 1)),
    ]);
  }
}
