

import '../../../../../../core/configs/configs.dart';
import '../../../data/sale_mode_model.dart';
import '../../bloc/sale_mode_bloc.dart';
import '../sale_mode_create_screen.dart';

class SaleModeTableCard extends StatelessWidget {
  final List<SaleModeModel> saleModes;

  const SaleModeTableCard({super.key, required this.saleModes});

  @override
  Widget build(BuildContext context) {
    if (saleModes.isEmpty) {
      return const Center(
        child: Text('No sale modes found'),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600; // Mobile breakpoint

    if (isSmallScreen) {
      // Mobile: card view
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: saleModes.length,
        itemBuilder: (context, index) {
          final mode = saleModes[index];
          return Card(
            color: AppColors.bottomNavBg(context),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius),
              side: BorderSide(color: AppColors.greyColor(context)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.name ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text('Code: ${mode.code ?? '-'}'),
                  if (mode.baseUnitName != null || mode.baseUnit != null)
                    Text(
                        'Base Unit: ${mode.baseUnitName ?? mode.baseUnit?.toString() ?? '-'}'),
                  if (mode.conversionFactor != null)
                    Text(
                        'Conversion: ${mode.conversionFactor?.toStringAsFixed(6) ?? '-'}'),
                  Wrap(
                    spacing: 6,
                    runSpacing: 0,
                    children: [
                      Chip(
                        label: Text(
                          _getPriceTypeDisplay(mode.priceType),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: _getPriceTypeColor(mode.priceType),
                      ),
                      Chip(
                        label: Text(
                          mode.isActive == true ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: mode.isActive == true
                                ? Colors.white
                                : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: mode.isActive == true
                            ? AppColors.success
                            : Colors.grey[300],
                      ),

                      IconButton(
                        icon: Icon(Iconsax.edit, color: AppColors.primaryColor(context)),
                        onPressed: () => _showEditDialog(context, mode),
                      ),
                      IconButton(
                        icon: const Icon(HugeIcons.strokeRoundedDeleteThrow, color: AppColors.danger),
                        onPressed: () => _showDeleteDialog(context, mode),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          );
        },
      );
    }

    // Tablet/Desktop: AppDataTable
    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 52),
      AppTableColumn('Name', flex: 3, minWidth: 150),
      AppTableColumn('Code', flex: 2, minWidth: 90),
      AppTableColumn('Base Unit', flex: 2, minWidth: 100),
      AppTableColumn.numeric('Conversion', flex: 2, minWidth: 110),
      AppTableColumn.center('Price Type', flex: 2, minWidth: 120),
      AppTableColumn.center('Status', flex: 2, minWidth: 96),
      AppTableColumn.center('Actions', flex: 2, minWidth: 100),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: saleModes.length,
      cellBuilder: (context, row, col) {
        final mode = saleModes[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(mode.name ?? '-', bold: true);
          case 2:
            return AppTableText(mode.code ?? '-', muted: true);
          case 3:
            return AppTableText(
                mode.baseUnitName ?? mode.baseUnit?.toString() ?? '-');
          case 4:
            return AppTableText(
                mode.conversionFactor?.toStringAsFixed(4) ?? '-',
                align: AppCellAlign.end);
          case 5:
            return AppStatusPill(_getPriceTypeDisplay(mode.priceType),
                color: _getPriceTypeColor(mode.priceType));
          case 6:
            final active = mode.isActive == true;
            return AppStatusPill(active ? 'Active' : 'Inactive',
                color: active ? AppColors.success : AppColors.danger);
          default:
            return AppTableEditDelete(
              onEdit: () => _showEditDialog(context, mode),
              onDelete: () => _showDeleteDialog(context, mode),
            );
        }
      },
    );
  }

  String _getPriceTypeDisplay(String? priceType) {
    switch (priceType) {
      case 'unit':
        return 'Unit Price';
      case 'flat':
        return 'Flat Price';
      case 'tier':
        return 'Tier Price';
      default:
        return priceType ?? 'Unknown';
    }
  }

  Color _getPriceTypeColor(String? priceType) {
    switch (priceType) {
      case 'unit':
        return AppColors.info;
      case 'flat':
        return AppColors.warning;
      case 'tier':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showEditDialog(BuildContext context, SaleModeModel saleMode) {
    showAppPopover(
      context: context,
      builder: (context) {
        return AppPopoverShell(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            child: SizedBox(
              // width: MediaQuery.of(context).size.width * 0.5,
              child: SaleModeCreateScreen(
                id: saleMode.id?.toString(),
                saleMode: saleMode,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, SaleModeModel saleMode) {
    showAppPopover(
      context: context,
      builder: (BuildContext context) {
        return AppPopoverCard(
          title: const Text('Delete Sale Mode'),
          content: Text(
            'Are you sure you want to delete "${saleMode.name}"?',
            style: AppTextStyle.body(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<SaleModeBloc>().add(
                  DeleteSaleMode(id: saleMode.id!.toString()),
                );
              },
              child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
            ),
          ],
        );
      },
    );
  }
}
