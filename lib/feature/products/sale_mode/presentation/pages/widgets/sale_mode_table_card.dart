

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
                            ? Colors.green
                            : Colors.grey[300],
                      ),

                      IconButton(
                        icon: Icon(Iconsax.edit, color: AppColors.primaryColor(context)),
                        onPressed: () => _showEditDialog(context, mode),
                      ),
                      IconButton(
                        icon: const Icon(HugeIcons.strokeRoundedDeleteThrow, color: Colors.red),
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
    } else {
      // Tablet/Desktop: DataTable view
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bottomNavBg(context),
            borderRadius: BorderRadius.circular(AppSizes.radius),
            border: Border.all(color: AppColors.greyColor(context)),
          ),
          child: DataTable(
            columnSpacing: 20,
            horizontalMargin: 12,
            headingRowColor: MaterialStateProperty.all(
              AppColors.primaryColor(context).withOpacity(0.1),
            ),
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Code')),
              DataColumn(label: Text('Base Unit')),
              DataColumn(label: Text('Conversion')),
              DataColumn(label: Text('Price Type')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: saleModes.map((mode) {
              return DataRow(cells: [
                DataCell(Text(mode.id?.toString() ?? '-')),
                DataCell(Text(mode.name ?? '-')),
                DataCell(Text(mode.code ?? '-')),
                DataCell(Text(mode.baseUnitName ?? mode.baseUnit?.toString() ?? '-')),
                DataCell(Text(mode.conversionFactor?.toStringAsFixed(6) ?? '-')),
                DataCell(
                  Chip(
                    label: Text(
                      _getPriceTypeDisplay(mode.priceType),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: _getPriceTypeColor(mode.priceType),
                  ),
                ),
                DataCell(
                  Chip(
                    label: Text(
                      mode.isActive == true ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: mode.isActive == true ? Colors.white : Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: mode.isActive == true
                        ? Colors.green
                        : Colors.grey[300],
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: AppColors.primaryColor(context)),
                        onPressed: () => _showEditDialog(context, mode),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteDialog(context, mode),
                      ),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      );
    }
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
        return Colors.blue;
      case 'flat':
        return Colors.orange;
      case 'tier':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showEditDialog(BuildContext context, SaleModeModel saleMode) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
