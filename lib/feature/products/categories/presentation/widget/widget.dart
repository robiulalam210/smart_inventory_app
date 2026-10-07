import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../data/model/categories_model.dart';
import '../bloc/categories/categories_bloc.dart';
import '../shared/categories_create.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';
// categories_list_mobile.dart

class CategoriesListMobile extends StatelessWidget {
  final List<CategoryModel> categories;
  final VoidCallback? onCategoryTap;

  const CategoriesListMobile({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh data
        context.read<CategoriesBloc>().add(
          FetchCategoriesList(context, filterText: ''),
        );
      },
      child: categories.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 20,
                left: 4,
                right: 4,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(context, category, index + 1);
              },
            ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    CategoryModel category,
    int index,
  ) {
    final isActive = _getCategoryStatus(category);
    // You can manage selection state if needed

    return GestureDetector(
      onTap: () {
        if (onCategoryTap != null) {
          onCategoryTap!();
        }
        // Optionally show category details
        // _showCategoryDetails(context, category);
      },
      child: Container(

        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
              // Header row with serial number and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Serial number
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor(
                        context,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor(context),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    category.name?.capitalize() ?? "Unnamed Category",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Action buttons
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.success.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? AppColors.success.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? Icons.check_circle : Icons.circle,
                          size: 12,
                          color: isActive ? AppColors.success : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'Active' : 'Inactive',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isActive ? AppColors.success : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showEditDialog(context, category),
                      icon: const Icon(Iconsax.edit, size: 16),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.info,
                        side: BorderSide(
                          color: AppColors.info.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context, category),
                      icon: const Icon(
                        HugeIcons.strokeRoundedDeleteThrow,
                        size: 16,
                      ),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: BorderSide(
                          color: AppColors.danger.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),

              // Description (if available)
              if (category.description?.isNotEmpty == true)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      category.description!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _getCategoryStatus(CategoryModel category) {
    // Handle different status representations
    if (category.isActive != null) {
      if (category.isActive is bool) {
        return category.isActive as bool;
      } else if (category.isActive is String) {
        return (category.isActive as String).toLowerCase() == 'active';
      } else if (category.isActive is int) {
        return (category.isActive as int) == 1;
      }
    }

    // Fallback to isActive if available
    return category.isActive ?? false;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CategoryModel category,
  ) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);

    if (shouldDelete && context.mounted) {
      context.read<CategoriesBloc>().add(
        DeleteCategories(id: category.id.toString()),
      );
    }
  }

  void _showEditDialog(BuildContext context, CategoryModel category) {
    // Pre-fill the form
    final categoriesBloc = context.read<CategoriesBloc>();
    categoriesBloc.nameController.text = category.name ?? "";
    categoriesBloc.selectedState = category.isActive == true
        ? "Active"
        : "Inactive";

    showAppPopover(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AppPopoverShell(
          insetPadding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: CategoriesCreate(id: category.id.toString()),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated illustration or icon
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.primaryColor(context).withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.category_outlined,
                size: 80,
                color: AppColors.primaryColor(context).withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'No Categories Found',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Create your first category to organize your products',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Create button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to create category
                  showAppPopover(
                    context: context,
                    builder: (context) {
                      return AppPopoverShell(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),

                            child: CategoriesCreate()),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor(context),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Create Category',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoriesTableCard extends StatelessWidget {
  final List<CategoryModel> categories;
  final VoidCallback? onCategoryTap;

  const CategoriesTableCard({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  // Desktop টেবিল — AppDataTable (SL ছোট, নাম চওড়া, status/action মাঝে)
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return _buildEmptyState();
    }

    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 60),
      AppTableColumn('Category Name', flex: 5, minWidth: 200),
      AppTableColumn.center('Status', flex: 2, minWidth: 110),
      AppTableColumn.center('Actions', flex: 2, minWidth: 110),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: categories.length,
      cellBuilder: (context, row, col) {
        final category = categories[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}', align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(category.name?.capitalize() ?? '-', bold: true);
          case 2:
            return AppStatusPill((_getCategoryStatus(category)) ? 'Active' : 'Inactive', color: (_getCategoryStatus(category)) ? AppColors.success : AppColors.danger);
          default:
            return AppTableEditDelete(
              onEdit: () => _showEditDialog(context, category),
              onDelete: () => _confirmDelete(context, category),
            );
        }
      },
    );
  }

  bool _getCategoryStatus(CategoryModel category) => category.isActive ?? false;

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

  Future<void> _confirmDelete(
    BuildContext context,
    CategoryModel category,
  ) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (shouldDelete && context.mounted) {
      context.read<CategoriesBloc>().add(
        DeleteCategories(id: category.id.toString()),
      );
    }
  }

  void _showEditDialog(BuildContext context, CategoryModel category) {
    // Pre-fill the form
    final categoriesBloc = context.read<CategoriesBloc>();
    categoriesBloc.nameController.text = category.name ?? "";
    categoriesBloc.selectedState = category.isActive == true
        ? "Active"
        : "Inactive";

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
              width: AppSizes.width(context) * 0.50,
              child: CategoriesCreate(id: category.id.toString()),
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
            Icons.category_outlined,
            size: 48,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Categories Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first category to get started',
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
