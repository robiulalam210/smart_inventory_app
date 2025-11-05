import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../data/model/unit_model.dart';
import '../bloc/unit/unti_bloc.dart';
import '../pages/unit_create.dart';

class UnitTableCard extends StatelessWidget {
  final List<UnitsModel> units;
  final VoidCallback? onUnitTap;

  const UnitTableCard({
    super.key,
    required this.units,
    this.onUnitTap,
  });

  @override
  Widget build(BuildContext context) {
    if (units.isEmpty) {
      return _buildEmptyState();
    }

    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 4; // No., Unit Name, Status, Actions
        const minColumnWidth = 100.0;

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Scrollbar(
            controller: verticalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: verticalScrollController,
              scrollDirection: Axis.vertical,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Scrollbar(
                  controller: horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: totalWidth),
                        child: DataTable(
                          dataRowMinHeight: 40,
                          dataRowMaxHeight: 40,
                          columnSpacing: 8,
                          horizontalMargin: 12,
                          dividerThickness: 0.5,
                          headingRowHeight: 40,
                          headingTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          headingRowColor: MaterialStateProperty.all(
                            AppColors.primaryColor,
                          ),
                          dataTextStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: GoogleFonts.inter().fontFamily,
                          ),
                          columns: _buildColumns(dynamicColumnWidth),
                          rows: units.asMap().entries.map((entry) {
                            final unit = entry.value;
                            return DataRow(
                              onSelectChanged: onUnitTap != null
                                  ? (_) => onUnitTap!()
                                  : null,
                              cells: [
                                _buildDataCell('${entry.key + 1}', dynamicColumnWidth * 0.6),
                                _buildDataCell(unit.name?.capitalize() ?? "N/A", dynamicColumnWidth),
                                _buildStatusCell(unit.isActive ?? false, dynamicColumnWidth),
                                _buildActionCell(unit, context, dynamicColumnWidth),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildColumns(double columnWidth) {
    return [
      DataColumn(
        label: SizedBox(
          width: columnWidth * 0.6,
          child: const Text('No.', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Unit Name', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Status', textAlign: TextAlign.center),
        ),
      ),
      DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: const Text('Actions', textAlign: TextAlign.center),
        ),
      ),
    ];
  }

  DataCell _buildDataCell(String text, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  DataCell _buildStatusCell(bool isActive, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildActionCell(UnitsModel unit, BuildContext context, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Edit Button
            _buildActionButton(
              icon: Iconsax.edit,
              color: Colors.blue,
              tooltip: 'Edit unit',
              onPressed: () => _showEditDialog(context, unit),
            ),

            // Delete Button
            _buildActionButton(
              icon: HugeIcons.strokeRoundedDeleteThrow,
              color: Colors.red,
              tooltip: 'Delete unit',
              onPressed: () => _confirmDelete(context, unit),
            ),
          ],
        ),
      ),
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

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: AppSizes.width(context) * 0.50,
            child: UnitCreate(
              id: unit.id.toString(),
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
            color: Colors.grey.withOpacity(0.1),
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
            color: Colors.grey.withOpacity(0.5),
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