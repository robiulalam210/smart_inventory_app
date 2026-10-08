import 'package:google_fonts/google_fonts.dart';
import '../../../../core/configs/configs.dart';
import '../../data/model/user_model.dart';
import '../shared/user_permission_screen.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

/// শুধু Super Admin / Admin অন্যদের permission বদলাতে পারে (backend ও একই নিয়ম মানে)।
/// Login এর সময় role টা LocalDB তে `userType` নামে রাখা হয়।
class PermissionAccess {
  PermissionAccess._();

  /// শেষ জানা মান — list rebuild হলে button যেন একবার লুকিয়ে আবার না আসে (flicker)
  static bool lastKnown = false;

  static Future<bool> canManage() async {
    final info = await LocalDB.getLoginInfo();
    final role = '${info?['userType'] ?? ''}'.toUpperCase();
    return lastKnown = role == 'SUPER_ADMIN' || role == 'ADMIN';
  }

  static void open(BuildContext context, UsersListModel user) {
    final name = user.fullName?.trim().isNotEmpty == true ? user.fullName! : (user.username ?? '');
    AppRoutes.push(context, UserPermissionScreen(userId: user.id.toString(), userName: name));
  }
}

class UserTableCard extends StatelessWidget {
  final List<UsersListModel> users;
  final VoidCallback? onUserTap;

  const UserTableCard({
    super.key,
    required this.users,
    this.onUserTap,
  });

  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return _buildEmptyState();
    }

    return FutureBuilder<bool>(
      future: PermissionAccess.canManage(),
      initialData: PermissionAccess.lastKnown,
      builder: (context, snap) {
        final canManage = snap.data ?? false;
        return _isMobile(context)
            ? _buildMobileList(context, canManage)
            : _buildDesktopTable(context, canManage);
      },
    );
  }

  // =========================
  // 📱 MOBILE VIEW
  // =========================
  Widget _buildMobileList(BuildContext context, bool canManage) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = users[index];

        return Container(
          decoration: BoxDecoration(
            color: AppColors.bottomNavBg(context),
            borderRadius: BorderRadius.circular(AppSizes.radius),

            border: Border.all(
              color: AppColors.greyColor(context).withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _mobileHeader(user,context),
                const SizedBox(height: 6),
                _mobileInfo('Email', user.email,context),
                _mobileInfo('Phone', user.phone,context),
                _mobileInfo('Role', user.role,context),
                _mobileInfo('Company', user.company?.name,context),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showViewDialog(context, user),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('Details'),
                    ),
                    if (canManage) ...[
                      const SizedBox(width: 6),
                      FilledButton.tonalIcon(
                        onPressed: () => PermissionAccess.open(context, user),
                        icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                        label: const Text('Permissions'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _mobileHeader(UsersListModel user, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Name
        Expanded(
          child: Text(
            user.fullName?.trim().isNotEmpty == true
                ? user.fullName!
                : (user.username ?? 'Unknown'),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.text(context),
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),

        // Status Chip
        _statusChip(_getUserStatus(user)),
      ],
    );
  }

  Widget _mobileInfo(String label, String? value,BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$label: ${value ?? "N/A"}',
        style: AppTextStyle.body(context),
      ),
    );
  }

  // =========================
  // 💻 DESKTOP VIEW
  // =========================
  // Desktop টেবিল — AppDataTable
  Widget _buildDesktopTable(BuildContext context, bool canManage) {
    final columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 52),
      AppTableColumn('Name', flex: 3, minWidth: 160),
      AppTableColumn('Email', flex: 3, minWidth: 160),
      AppTableColumn.center('Role', flex: 2, minWidth: 110),
      AppTableColumn('Phone', flex: 2, minWidth: 120),
      AppTableColumn('Company', flex: 2, minWidth: 120),
      AppTableColumn.center('Status', flex: 2, minWidth: 96),
      AppTableColumn.center('Actions', flex: canManage ? 2 : 1, minWidth: canManage ? 104 : 80),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: users.length,
      cellBuilder: (context, row, col) {
        final u = users[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText((u.fullName ?? '-').trim(),
                bold: true, subtitle: u.username);
          case 2:
            return AppTableText(u.email ?? '-');
          case 3:
            return AppStatusPill((u.role ?? '-').replaceAll('_', ' '),
                color: AppColors.info);
          case 4:
            return AppTableText(u.phone ?? '-');
          case 5:
            return AppTableText(u.company?.name ?? '-', muted: true);
          case 6:
            final active = _getUserStatus(u);
            return AppStatusPill(active ? 'Active' : 'Inactive',
                color: active ? AppColors.success : AppColors.danger);
          default:
            final view = AppTableAction(
              icon: Icons.visibility_outlined,
              tooltip: 'View details',
              color: AppColors.info,
              onPressed: () => _showViewDialog(context, u),
            );
            if (!canManage) return view;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                view,
                AppTableAction(
                  icon: Icons.admin_panel_settings_outlined,
                  tooltip: 'Manage permissions',
                  color: AppColors.primaryColor(context),
                  onPressed: () => PermissionAccess.open(context, u),
                ),
              ],
            );
        }
      },
    );
  }

  // =========================
  // 🔹 COMMON WIDGETS
  // =========================
  bool _getUserStatus(UsersListModel user) {
    return user.isActive ?? false;
  }

  Widget _statusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? AppColors.success : AppColors.danger,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =========================
  // 🧾 VIEW DIALOG (RESPONSIVE)
  // =========================
  void _showViewDialog(BuildContext context, UsersListModel user) {
    showAppPopover(
      context: context,
      builder: (_) {
        return AppPopoverShell(
          child: Container(
            color: AppColors.bottomNavBg(context),
            width: MediaQuery.of(context).size.width < 768
                ? double.infinity
                : AppSizes.width(context) * 0.4,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User Details',
                      style: AppTextStyle.cardLevelHead(context)),
                  const SizedBox(height: 16),
                  _detailRow('Full Name',
                      '${user.firstName ?? ""} ${user.lastName ?? ""}'.trim(),context),
                  _detailRow('Username', user.username,context),
                  _detailRow('Email', user.email,context),
                  _detailRow('Role', user.role,context),
                  _detailRow('Phone', user.phone,context),
                  _detailRow('Company', user.company?.name,context),
                  _detailRow('Status',
                      _getUserStatus(user) ? 'Active' : 'Inactive',context),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String? value,BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style:
                 TextStyle(fontWeight: FontWeight.w600, fontSize: 12,color: AppColors.text(context))),
          ),
          Expanded(
            child: Text(value ?? 'N/A',
                style:  TextStyle(fontSize: 12,color: AppColors.text(context))),
          ),
        ],
      ),
    );
  }

  // =========================
  // 🚫 EMPTY STATE
  // =========================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.people_outline, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('No Users Found',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
