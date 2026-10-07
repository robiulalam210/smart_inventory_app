
import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../data/model/product_model.dart';
import '../shared/mobile_product_create.dart';
import '../shared/product_details.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

class ProductDataTableWidget extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel)? onEdit;
  final Function(ProductModel)? onDelete;

  const ProductDataTableWidget({
    super.key,
    required this.products,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    if (isMobile || isTablet) {
      return _buildMobileCardView(context, isMobile);
    } else {
      return _buildDesktopDataTable();
    }
  }

  Widget _buildMobileCardView(BuildContext context, bool isMobile) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product, index + 1, context, isMobile);
      },
    );
  }

  Widget _buildProductCard(
      ProductModel product,
      int index,
      BuildContext context,
      bool isMobile,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 8.0 : 16.0,
        vertical: 8.0,
      ),
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
          // Header with SL and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primaryColor(context).withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (product.isActive ?? false)
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (product.isActive ?? false) ? AppColors.success : AppColors.danger,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    (product.isActive ?? false) ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: (product.isActive ?? false) ? AppColors.success : AppColors.danger,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product Details
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                _buildDetailRow(
                  context: context,
                  icon: Iconsax.box,
                  label: 'Product Name',
                  value: product.name ?? 'N/A',
                  isImportant: true,
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child:  _buildDetailRow(
                    context: context,
                    icon: Iconsax.tag,
                    label: 'SKU',
                    value: product.sku ?? 'N/A',
                  ),),
                  SizedBox(width: 8,),
                  Expanded(child:   _buildDetailRow(
                    context: context,
                    icon: Iconsax.category,
                    label: 'Category',
                    value: product.categoryInfo?.name ?? 'N/A',
                  ),),
                ],),


                // SKU

                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child:  _buildDetailRow(
                    context: context,
                    icon: Iconsax.building,
                    label: 'Brand',
                    value: product.brandInfo?.name ?? 'N/A',
                  ),),
                  SizedBox(width: 8,),
                  Expanded(child: _buildDetailRow(
                    context: context,
                    icon: Iconsax.ruler,
                    label: 'Unit',
                    value: product.unitInfo?.name ?? 'N/A',
                  ),),
                ],),
                // Category



                // Unit

              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bottomNavBg(context),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Edit Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showAppPopover(
                        context: context,
                        builder: (context) {
                          return AppPopoverShell(
                            insetPadding: const EdgeInsets.all(10),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                // minWidth: isMobile
                                //     ? double.infinity
                                //     : AppSizes.width(context) * 0.7,
                                // maxWidth: isMobile
                                //     ? double.infinity
                                //     : AppSizes.width(context) * 0.7,
                                maxHeight: isMobile
                                    ? AppSizes.height(context) * 0.7
                                    : AppSizes.height(context) * 0.8,
                              ),
                              child: MobileProductCreate(
                                productId: product.id.toString(),
                                product: product,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Iconsax.edit,
                      size: 16,
                    ),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.info,
                      side: BorderSide(color: Colors.blue.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Delete Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteConfirmation(context, product),
                    icon: const Icon(
                      HugeIcons.strokeRoundedDeleteThrow,
                      size: 16,
                    ),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: Colors.red.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),  const SizedBox(width: 12),

                // Delete Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AppRoutes.push(context, ProductDetailsScreen(productId: product.id.toString(),));


                    },
                    icon: const Icon(
                      Iconsax.eye,
                      size: 16,
                    ),
                    label: const Text('View'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: BorderSide(color: Colors.orange.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    bool isImportant = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.text(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontWeight: isImportant ? FontWeight.w700 : FontWeight.w500,
                  color: isImportant ? AppColors.text(context) :AppColors.primaryColor(context),
                  fontSize: isImportant ? 14 : 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Desktop টেবিল — AppDataTable
  // দাম আর stock যোগ করা হয়েছে — product list এ সবচেয়ে বেশি এগুলোই দেখা হয়।
  // stock alert quantity এর নিচে নামলে লাল।
  Widget _buildDesktopDataTable() {
    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 52),
      AppTableColumn('Product', flex: 4, minWidth: 180),
      AppTableColumn('Category', flex: 2, minWidth: 110),
      AppTableColumn('Brand', flex: 2, minWidth: 100),
      AppTableColumn('Unit', flex: 1, minWidth: 70),
      AppTableColumn.numeric('Sell Price', flex: 2, minWidth: 100),
      AppTableColumn.numeric('Stock', flex: 1, minWidth: 80),
      AppTableColumn.center('Status', flex: 2, minWidth: 96),
      AppTableColumn.center('Actions', flex: 2, minWidth: 120),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: products.length,
      cellBuilder: (context, row, col) {
        final p = products[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(p.name ?? '-', bold: true, subtitle: p.sku);
          case 2:
            return AppTableText(p.categoryInfo?.name ?? '-');
          case 3:
            return AppTableText(p.brandInfo?.name ?? '-', muted: true);
          case 4:
            return AppTableText(p.unitInfo?.name ?? '-', muted: true);
          case 5:
            return AppTableMoney(AppTableMoney.parse(p.sellingPrice));
          case 6:
            final stock = p.stockQty ?? 0;
            final low = stock <= (p.alertQuantity ?? 0);
            return AppTableText('$stock',
                align: AppCellAlign.end,
                bold: true,
                color: low ? AppColors.danger : null);
          case 7:
            final active = p.isActive ?? false;
            return AppStatusPill(active ? 'Active' : 'Inactive',
                color: active ? AppColors.success : AppColors.danger);
          default:
            return AppTableEditDelete(
              onView: () => AppRoutes.push(
                  context, ProductDetailsScreen(productId: p.id.toString())),
              onEdit: onEdit == null ? null : () => onEdit!(p),
              onDelete: () => _showDeleteConfirmation(context, p),
            );
        }
      },
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, ProductModel product) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (!shouldDelete) return;

    onDelete?.call(product);
  }
}