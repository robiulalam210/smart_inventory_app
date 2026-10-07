import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../data/model/groups.dart';
import '../bloc/groups/groups_bloc.dart';
import '../shared/create_groups.dart';

class GroupsTableCard extends StatelessWidget {
  final List<GroupsModel> groups;
  final VoidCallback? onGroupTap;

  const GroupsTableCard({super.key, required this.groups, this.onGroupTap});

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return _buildEmptyState();
    }

    return Responsive.isMobile(context)
        ? _buildMobileListView()
        : _buildDesktopTable();
  }

  // Desktop টেবিল — AppDataTable (SL ছোট, নাম চওড়া, status/action মাঝে)
  Widget _buildDesktopTable() {

    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 60),
      AppTableColumn('Group Name', flex: 5, minWidth: 200),
      AppTableColumn.center('Status', flex: 2, minWidth: 110),
      AppTableColumn.center('Actions', flex: 2, minWidth: 110),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: groups.length,
      cellBuilder: (context, row, col) {
        final group = groups[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}', align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(group.name?.capitalize() ?? '-', bold: true);
          case 2:
            return AppStatusPill((_getGroupStatus(group)) ? 'Active' : 'Inactive', color: (_getGroupStatus(group)) ? AppColors.success : AppColors.danger);
          default:
            return AppTableEditDelete(
              onEdit: () => _showEditDialog(context, group),
              onDelete: () => _confirmDelete(context, group),
            );
        }
      },
    );
  }

  Widget _buildMobileListView() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: groups.length,
        separatorBuilder: (context, index) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final group = groups[index];
          return _buildMobileGroupCard(context, group, index);
        },
      ),
    );
  }

  Widget _buildMobileGroupCard(
    BuildContext context,
    GroupsModel group,
    int index,
  ) {
    final isActive = _getGroupStatus(group);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(AppSizes.radius),

        border: Border.all(
          color: AppColors.greyColor(context).withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with No. and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: AppColors.primaryColor(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                group.name?.capitalize() ?? "N/A",
                style:  TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text(context)
                ),
              ),

              _buildStatusChip(isActive),
            ],
          ),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditDialog(context, group),
                  icon: const Icon(Iconsax.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.info,
                    side: BorderSide(color: AppColors.info.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context, group),
                  icon: const Icon(
                    HugeIcons.strokeRoundedDeleteThrow,
                    size: 16,
                  ),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(color: AppColors.danger.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: isActive ? AppColors.success : AppColors.danger,
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              color: isActive ? AppColors.success : AppColors.danger,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  bool _getGroupStatus(GroupsModel group) => group.isActive ?? false;

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
    );
  }

  Future<void> _confirmDelete(BuildContext context, GroupsModel group) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (shouldDelete && context.mounted) {
      context.read<GroupsBloc>().add(DeleteGroups(group.id.toString()));
    }
  }

  void _showEditDialog(BuildContext context, GroupsModel group) {
    final groupsBloc = context.read<GroupsBloc>();
    groupsBloc.nameController.text = group.name ?? "";
    groupsBloc.selectedState = group.isActive == true ? "Active" : "Inactive";

    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverShell(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: Responsive.isMobile(context)
                  ? MediaQuery.of(context).size.width * 0.9
                  : MediaQuery.of(context).size.width * 0.5,
              child: GroupsCreate(id: group.id.toString()),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_work_outlined,
            size: 48,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Groups Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first group to get started',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
