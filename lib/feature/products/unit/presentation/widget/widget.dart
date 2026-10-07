import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../data/model/unit_model.dart';
import '../bloc/unit/unti_bloc.dart';
import '../shared/unit_create.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';


class MobileUnitTableCard extends StatelessWidget {
  final List<UnitsModel> units;
  final VoidCallback? onUnitTap;

  const MobileUnitTableCard({
    super.key,
    required this.units,
    this.onUnitTap,
  });

  @override
  Widget build(BuildContext context) {
    if (units.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: units.length,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      itemBuilder: (context, index) {
        final unit = units[index];
        return _buildUnitCard(context, unit, index + 1);
      },
    );
  }

  Widget _buildUnitCard(BuildContext context, UnitsModel unit, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(AppSizes.radius),

        border: Border.all(
          color: AppColors.greyColor(context).withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: () => onUnitTap?.call(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
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
                      '$index ',
                      style: TextStyle(
                        color: AppColors.primaryColor(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(width: 8,),
                  Expanded(
                    child: Text(
                      unit.name?.capitalize() ?? 'Unnamed Unit',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color:AppColors.text(context),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(unit.isActive ?? false),
                ],
              ),
              const SizedBox(height: 4),

              // Unit Details
              _buildDetailRow('Code:', unit.code?.capitalize() ?? 'N/A',context),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Edit Button
                  _buildActionButton(
                    context,
                    'Edit',
                    Iconsax.edit,
                    AppColors.info,
                        () => _showEditDialog(context, unit),
                  ),

                  // Delete Button
                  _buildActionButton(
                    context,
                    'Delete',
                    HugeIcons.strokeRoundedDeleteThrow,
                    AppColors.danger,
                        () => _confirmDelete(context, unit),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.text(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.text(context),
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.success.withValues(alpha: 0.1) : AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.success.withValues(alpha: 0.3) : AppColors.danger.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? AppColors.success : AppColors.danger,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      String text,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16, color: color),
          label: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: color.withValues(alpha: 0.3)),
            ),
            backgroundColor: color.withValues(alpha: 0.05),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, UnitsModel unit) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (shouldDelete && context.mounted) {
      context.read<UnitBloc>().add(
        DeleteUnit(unit.id.toString()),
      );
    }
  }

  void _showEditDialog(BuildContext context, UnitsModel unit) {
    // Pre-fill the form
    final unitBloc = context.read<UnitBloc>();
    unitBloc.nameController.text = unit.name ?? "";
    unitBloc.shortNameController.text = unit.code ?? "";
    unitBloc.selectedState = unit.isActive == true ? "Active" : "Inactive";


    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverShell(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(16),

            child: SizedBox(
              width: Responsive.isMobile(context)
                  ? MediaQuery.of(context).size.width * 0.9
                  : MediaQuery.of(context).size.width * 0.5,
              child: UnitCreate(id: unit.id.toString()),
            ),
          ),
        );
      },
    );

  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
      margin: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.square_foot,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Units Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first unit to get started',
            style: GoogleFonts.inter(
              fontSize: 14,
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
class UnitTableCard extends StatelessWidget {
  final List<UnitsModel> units;
  final VoidCallback? onUnitTap;

  const UnitTableCard({
    super.key,
    required this.units,
    this.onUnitTap,
  });

  @override
  // Desktop টেবিল — AppDataTable (SL ছোট, নাম চওড়া, status/action মাঝে)
  Widget build(BuildContext context) {
    if (units.isEmpty) {
      return _buildEmptyState();
    }

    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 60),
      AppTableColumn('Unit Name', flex: 4, minWidth: 180),
      AppTableColumn('Code', flex: 2, minWidth: 100),
      AppTableColumn.center('Status', flex: 2, minWidth: 110),
      AppTableColumn.center('Actions', flex: 2, minWidth: 110),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: units.length,
      cellBuilder: (context, row, col) {
        final unit = units[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}', align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(unit.name?.capitalize() ?? '-', bold: true);
          case 2:
            return AppTableText(unit.code?.capitalize() ?? '-', muted: true);
          case 3:
            return AppStatusPill((unit.isActive ?? false) ? 'Active' : 'Inactive', color: (unit.isActive ?? false) ? AppColors.success : AppColors.danger);
          default:
            return AppTableEditDelete(
              onEdit: () => _showEditDialog(context, unit),
              onDelete: () => _confirmDelete(context, unit),
            );
        }
      },
    );
  }

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

  Future<void> _confirmDelete(BuildContext context, UnitsModel unit) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (shouldDelete && context.mounted) {
      context.read<UnitBloc>().add(
          DeleteUnit(unit.id.toString())
      );
    }
  }

  void _showEditDialog(BuildContext context, UnitsModel unit) {
    // Pre-fill the form
    final unitBloc = context.read<UnitBloc>();
    unitBloc.nameController.text = unit.name ?? "";
    unitBloc.shortNameController.text = unit.code ?? "";
    unitBloc.selectedState = unit.isActive == true ? "Active" : "Inactive";

    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverShell(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(16),
            child: SizedBox(
              width: AppSizes.width(context) * 0.50,
              child: UnitCreate(
                id: unit.id.toString(),
              ),
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
            Icons.square_foot,
            size: 48,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Units Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first unit to get started',
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