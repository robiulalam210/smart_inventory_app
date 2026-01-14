
import '../../../../../core/configs/configs.dart';
import '../../../../../core/widgets/delete_dialog.dart';
import '../../data/model/product_model.dart';
import '../pages/mobile_product_create.dart';

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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
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
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (product.isActive ?? false) ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    (product.isActive ?? false) ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: (product.isActive ?? false) ? Colors.green : Colors.red,
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
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
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
                      foregroundColor: Colors.blue,
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
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade300),
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

  Widget _buildDesktopDataTable() {
    final verticalScrollController = ScrollController();
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 8;
        const minColumnWidth = 100;

        final dynamicColumnWidth = (totalWidth / numColumns)
            .clamp(minColumnWidth, double.infinity)
            .toDouble();

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: ClipRRect( borderRadius: BorderRadius.circular(AppSizes.radius),
            child: Scrollbar(
              controller: verticalScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: verticalScrollController,
                scrollDirection: Axis.vertical,
                child: Scrollbar(
                  controller: horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: totalWidth),
                      child: DataTable(
                        dataRowMinHeight: 40,
                        headingRowHeight: 40,
                        columnSpacing: 0,
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        headingRowColor: WidgetStateProperty.all(
                          AppColors.primaryColor(context),
                        ),
                        dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                            return Colors.white;
                          },
                        ),
                        columns: _buildColumns(dynamicColumnWidth),
                        rows: products
                            .asMap()
                            .entries
                            .map((entry) => _buildDataRow(context,
                          entry.key + 1,
                          entry.value,
                          dynamicColumnWidth,
                        ))
                            .toList(),
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
    const columnLabels = [
      'SL',
      'Name',
      'SKU',
      'Category',
      'Brand',
      'Unit',
      'Status',
      'Actions',
    ];

    return columnLabels
        .map(
          (label) => DataColumn(
        label: Container(
          width: label == 'SL'
              ? columnWidth * 0.6
              : label == 'Name'
              ? columnWidth * 1.2
              : label == 'Actions'
              ? columnWidth * 0.8
              : columnWidth,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    )
        .toList();
  }

  DataRow _buildDataRow(BuildContext context,int index, ProductModel product, double columnWidth) {
    return DataRow(
      cells: [
        _buildDataCell(index.toString(), columnWidth * 0.6, TextAlign.center),
        _buildDataCell(product.name ?? 'N/A', columnWidth * 1.2, TextAlign.center),
        _buildDataCell(product.sku ?? 'N/A', columnWidth, TextAlign.center),
        _buildDataCell(
          product.categoryInfo?.name ?? 'N/A',
          columnWidth,
          TextAlign.center,
        ),
        _buildDataCell(
          product.brandInfo?.name ?? 'N/A',
          columnWidth,
          TextAlign.center,
        ),
        _buildDataCell(
          product.unitInfo?.name ?? 'N/A',
          columnWidth,
          TextAlign.center,
        ),
        _buildStatusCell(product.isActive ?? false, columnWidth),
        _buildActionsCell(context,product, columnWidth * 0.8),
      ],
    );
  }

  DataCell _buildDataCell(String text, double columnWidth, TextAlign align) {
    return DataCell(
      SizedBox(
        width: columnWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
            textAlign: align,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  DataCell _buildStatusCell(bool isActive, double columnWidth) {
    final status = isActive ? 'Active' : 'Inactive';
    final color = isActive ? Colors.green : Colors.red;

    return DataCell(
      SizedBox(
        width: columnWidth,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildActionsCell(BuildContext context,ProductModel product, double columnWidth) {
    return DataCell(
      SizedBox(
        width: columnWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Iconsax.edit,
                  size: 20,
                  color: Colors.blue.shade600,
                ),
                onPressed: () => onEdit?.call(product),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                tooltip: 'Edit Product',
              ),
              IconButton(
                icon: Icon(
                  HugeIcons.strokeRoundedDeleteThrow,
                  size: 20,
                  color: Colors.red.shade600,
                ),
                onPressed: () => _showDeleteConfirmation(context, product),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                tooltip: 'Delete Product',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, ProductModel product) async {
    final shouldDelete = await showDeleteConfirmationDialog(context);
    if (!shouldDelete) return;

    onDelete?.call(product);
  }
}