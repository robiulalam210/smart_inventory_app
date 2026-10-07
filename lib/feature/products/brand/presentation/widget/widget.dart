import 'package:flutter/material.dart';
import 'package:meherinMart/core/widgets/app_data_table.dart';
import 'package:meherinMart/core/widgets/app_popover_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/configs/app_colors.dart';
import '../../../../../core/configs/app_sizes.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../../../../responsive.dart';
import '../../data/model/brand_model.dart';
import '../bloc/brand/brand_bloc.dart';
import '../shared/create_brand/create_brand_setup.dart';

class BrandTableCard extends StatelessWidget {
  final List<BrandModel> brands;
  final VoidCallback? onBrandTap;

  const BrandTableCard({super.key, required this.brands, this.onBrandTap});

  @override
  Widget build(BuildContext context) {
    if (brands.isEmpty) {
      return _buildEmptyState();
    }

    return Responsive.isMobile(context)
        ? _buildMobileListView(context)
        : _buildDesktopTable();
  }

  // Desktop টেবিল — AppDataTable (SL ছোট, নাম চওড়া, status/action মাঝে)
  Widget _buildDesktopTable() {

    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 60),
      AppTableColumn('Brand Name', flex: 5, minWidth: 200),
      AppTableColumn.center('Status', flex: 2, minWidth: 110),
      AppTableColumn.center('Actions', flex: 2, minWidth: 110),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: brands.length,
      cellBuilder: (context, row, col) {
        final brand = brands[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}', align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(brand.name ?? '-', bold: true);
          case 2:
            return AppStatusPill((brand.isActive ?? false) ? 'Active' : 'Inactive', color: (brand.isActive ?? false) ? AppColors.success : AppColors.danger);
          default:
            return AppTableEditDelete(
              onEdit: () => _showEditDialog(context, brand),
              onDelete: () => _confirmDelete(context, brand),
            );
        }
      },
    );
  }

  Widget _buildMobileListView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.bottomNavBg(context),
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
        itemCount: brands.length,
        separatorBuilder: (context, index) =>  SizedBox(height: 8),
        itemBuilder: (context, index) {
          final brand = brands[index];
          return _buildMobileBrandCard(context, brand, index);
        },
      ),
    );
  }

  Widget _buildMobileBrandCard(
    BuildContext context,
    BrandModel brand,
    int index,
  ) {
    final isActive = brand.isActive ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(AppSizes.radius),

        border: Border.all(
          color: AppColors.greyColor(context).withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),      child: Column(
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
              _buildStatusChip(isActive),
            ],
          ),

          const SizedBox(height: 6),

          // Brand Name
          Text(
            brand.name ?? "N/A",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text(context),
            ),
          ),

          const SizedBox(height: 8),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditDialog(context, brand),
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
                  onPressed: () => _confirmDelete(context, brand),
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

  Future<void> _confirmDelete(BuildContext context, BrandModel brand) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (shouldDelete && context.mounted) {
      context.read<BrandBloc>().add(DeleteBrand(id: brand.id.toString()));
    }
  }

  void _showEditDialog(BuildContext context, BrandModel brand) {
    final brandBloc = context.read<BrandBloc>();
    brandBloc.nameController.text = brand.name ?? "";
    brandBloc.selectedState = brand.isActive == true ? "Active" : "Inactive";

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
              child: BrandCreate(id: brand.id.toString()),
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
            Icons.branding_watermark_outlined,
            size: 48,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Brands Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first brand to get started',
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
