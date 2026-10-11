import 'package:flutter/services.dart';

import '../../core/configs/configs.dart';
import '../../core/widgets/web_ui.dart';
import '../../feature/lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../feature/profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import 'sidebar.dart';

/// Ctrl+K (বা ⌘K) — যেকোনো page এর নাম লিখে সরাসরি সেখানে যাওয়া।
/// সাইডবারে group খুঁজে খুঁজে ক্লিক করার বদলে: টাইপ → ↑/↓ → Enter।
/// শুধু সেই page-ই দেখায় যা এই ব্যবহারকারীর permission এ আছে।
Future<void> showQuickJump(BuildContext context) async {
  final profile = context.read<ProfileBloc>().state;
  if (profile is! ProfilePermissionSuccess) return; // permission এখনো আসেনি

  final entries = quickJumpEntries(
    profile.permissionData.data?.permissions,
    profile.permissionData.data?.user?.role,
  );
  if (entries.isEmpty) return;

  final bloc = context.read<DashboardBloc>();
  final picked = await showDialog<QuickJumpEntry>(
    context: context,
    barrierColor: const Color(0x73000000),
    builder: (_) => _QuickJumpDialog(entries: entries),
  );
  if (picked == null) return;

  bloc.add(ChangeDashboardScreen(index: picked.index));
  if (picked.index == 0 && context.mounted) {
    bloc.add(FetchDashboardData(context: context));
  }
}

class _QuickJumpDialog extends StatefulWidget {
  const _QuickJumpDialog({required this.entries});
  final List<QuickJumpEntry> entries;

  @override
  State<_QuickJumpDialog> createState() => _QuickJumpDialogState();
}

class _QuickJumpDialogState extends State<_QuickJumpDialog> {
  static const double _rowHeight = 44;

  final _search = TextEditingController();
  final _scroll = ScrollController();
  late List<QuickJumpEntry> _shown = widget.entries;
  int _hi = 0;

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _filter(String q) {
    final words = q
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    setState(() {
      _shown = words.isEmpty
          ? widget.entries
          : widget.entries.where((e) {
              final hay = '${e.title} ${e.group}'.toLowerCase();
              return words.every(hay.contains);
            }).toList();
      _hi = 0;
    });
  }

  void _move(int delta) {
    if (_shown.isEmpty) return;
    setState(() => _hi = (_hi + delta).clamp(0, _shown.length - 1));
    if (!_scroll.hasClients) return;
    final double top = _hi * _rowHeight;
    final double view = _scroll.position.viewportDimension;
    if (top < _scroll.offset) {
      _scroll.jumpTo(top);
    } else if (top + _rowHeight > _scroll.offset + view) {
      _scroll.jumpTo(top + _rowHeight - view);
    }
  }

  void _pick(int i) {
    if (i < 0 || i >= _shown.length) return;
    Navigator.pop(context, _shown[i]);
  }

  @override
  Widget build(BuildContext context) {
    final double listHeight =
        (_shown.length * _rowHeight + 8).clamp(_rowHeight + 8, 360.0);

    return Align(
      alignment: const Alignment(0, -0.55),
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: W.surface(context),
              border: Border.all(color: W.line(context)),
              borderRadius: BorderRadius.circular(W.rLg),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D0F172A),
                  blurRadius: 40,
                  spreadRadius: -16,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.arrowDown): () => _move(1),
                const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
                const SingleActivator(LogicalKeyboardKey.escape): () =>
                    Navigator.pop(context),
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: SizedBox(
                      height: 52,
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 20, color: W.muted(context)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _search,
                              autofocus: true,
                              onChanged: _filter,
                              onSubmitted: (_) => _pick(_hi),
                              style: TextStyle(fontSize: 15, color: W.ink(context)),
                              decoration: InputDecoration(
                                hintText: 'Go to a page…  (Sale, Product, Customer Ledger)',
                                hintStyle: TextStyle(color: W.muted(context)),
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          const _Kbd('Esc'),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, color: W.line(context)),
                  if (_shown.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: Text('No page matches',
                            style: TextStyle(color: W.muted(context))),
                      ),
                    )
                  else
                    SizedBox(
                      height: listHeight,
                      child: ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(4),
                        itemExtent: _rowHeight,
                        itemCount: _shown.length,
                        itemBuilder: (context, i) {
                          final e = _shown[i];
                          final bool hi = i == _hi;
                          return Material(
                            color: hi ? W.blueWash(context) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              hoverColor: W.tint(context),
                              onTap: () => _pick(i),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Icon(e.icon,
                                        size: 18,
                                        color: hi ? W.blue(context) : W.muted(context)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        e.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: hi ? FontWeight.w600 : FontWeight.w500,
                                          color: hi ? W.blue(context) : W.ink(context),
                                        ),
                                      ),
                                    ),
                                    Text(e.group,
                                        style: TextStyle(
                                            fontSize: 12.5, color: W.muted(context))),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: W.soft(context),
                      border: Border(top: BorderSide(color: W.line(context))),
                    ),
                    child: Row(
                      children: [
                        const _Kbd('↑'),
                        const SizedBox(width: 4),
                        const _Kbd('↓'),
                        const SizedBox(width: 6),
                        Text('move', style: TextStyle(fontSize: 12, color: W.muted(context))),
                        const SizedBox(width: 14),
                        const _Kbd('Enter'),
                        const SizedBox(width: 6),
                        Text('open', style: TextStyle(fontSize: 12, color: W.muted(context))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// কীবোর্ডের ছোট কী-চিহ্ন
class _Kbd extends StatelessWidget {
  const _Kbd(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: W.tint(context),
          border: Border.all(color: W.line(context)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: W.muted(context))),
      );
}

/// header এর "Go to…  Ctrl K" বাটন
class QuickJumpButton extends StatelessWidget {
  const QuickJumpButton({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 36,
        child: OutlinedButton(
          onPressed: () => showQuickJump(context),
          style: OutlinedButton.styleFrom(
            backgroundColor: W.surface(context),
            foregroundColor: W.muted(context),
            side: BorderSide(color: W.line2(context)),
            padding: const EdgeInsets.only(left: 10, right: 6),
            minimumSize: const Size(0, 36),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(W.rMd)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search, size: 17),
              const SizedBox(width: 8),
              const Text('Go to…',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
              const SizedBox(width: 14),
              const _Kbd('Ctrl K'),
            ],
          ),
        ),
      );
}
