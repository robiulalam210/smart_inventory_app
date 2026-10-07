import '/feature/supplier/data/model/supplier_list_model.dart';
import '../../../../core/configs/configs.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

class SupplierDataTableWidget extends StatelessWidget {
  final List<SupplierListModel> suppliers;
  final Function(SupplierListModel)? onEdit;
  final Function(SupplierListModel)? onEditMobile;
  final Function(SupplierListModel)? onDelete;

  const SupplierDataTableWidget({
    super.key,
    required this.suppliers,
    this.onEdit,
    this.onEditMobile,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    if (isMobile || isTablet) {
      return _buildMobileCardView(context, isMobile);
    } else {
      return _buildDesktopDataTable(context);
    }
  }

  Widget _buildMobileCardView(BuildContext context, bool isMobile) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        return _buildSupplierCard(supplier, index + 1, context, isMobile);
      },
    );
  }

  Widget _buildSupplierCard(
      SupplierListModel supplier,
      int index,
      BuildContext context,
      bool isMobile,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 0.0 : 16.0,
        vertical: 8.0,
      ),
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
          // Header with SL and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
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
                    const SizedBox(width: 8),
                    Text(
                      supplier.supplierNo ?? '-',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.text(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                _buildAdvanceBalanceChip(supplier.advanceBalance),
              ],
            ),
          ),

          // Supplier Details
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Row
                _buildDetailRow(
                  context: context,
                  icon: Iconsax.user,
                  label: 'Name',
                  value: supplier.name ?? '-',
                  isImportant: true,
                ),
                const SizedBox(height: 2),

                // Shop Name Row (NEW)
                if (supplier.shopName?.isNotEmpty == true)
                  Column(
                    children: [
                      _buildDetailRow(
                        context: context,
                        icon: Iconsax.shop,
                        label: 'Shop Name',
                        value: supplier.shopName ?? '-',
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),

                // Product Name Row (NEW)
                if (supplier.productName?.isNotEmpty == true)
                  Column(
                    children: [
                      _buildDetailRow(
                        context: context,
                        icon: Iconsax.box,
                        label: 'Products/Services',
                        value: supplier.productName ?? '-',
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),

                // Phone Row
                _buildDetailRow(
                  context: context,
                  icon: Iconsax.call,
                  label: 'Phone',
                  value: supplier.phone ?? '-',
                  onTap: supplier.phone != null
                      ? () {
                    // Add phone call functionality
                  }
                      : null,
                ),
                const SizedBox(height: 2),

                // Email Row
                if (supplier.email?.toString().isNotEmpty == true)
                  Column(
                    children: [
                      _buildDetailRow(
                        context: context,
                        icon: Iconsax.sms,
                        label: 'Email',
                        value: supplier.email?.toString() ?? '-',
                        onTap: supplier.email?.toString() != null
                            ? () {
                          // Add email functionality
                        }
                            : null,
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),

                // Address Row
                if (supplier.address?.isNotEmpty == true)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Iconsax.location,
                            size: 18,
                            color: AppColors.text(context),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Address:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.text(context),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          supplier.address!,
                          style: TextStyle(
                            color: AppColors.text(context),
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),

                // Financial Summary
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bottomNavBg(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Financial Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.wallet_money,
                            size: 16,
                            color: AppColors.primaryColor(context),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Financial Summary',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Financial Details Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.7,
                        children: [
                          _buildFinancialCard(
                            context: context,
                            label: 'Purchases',
                            value: '৳${supplier.totalPurchases.toString()}',
                            icon: Iconsax.shopping_cart,
                            color: AppColors.info,
                          ),
                          _buildFinancialCard(
                            context: context,
                            label: 'Paid',
                            value: '৳${supplier.totalPaid.toString()}',
                            icon: Iconsax.wallet_check,
                            color: AppColors.success,
                          ),
                          _buildFinancialCard(
                            context: context,
                            label: 'Due',
                            value: '৳${supplier.totalDue.toString()}',
                            icon: Iconsax.wallet_minus,
                            color: AppColors.warning,
                          ),
                          _buildFinancialCard(
                            context: context,
                            label: 'Advance',
                            value: '৳${supplier.advanceBalance ?? '0.00'}',
                            icon: Iconsax.wallet_add,
                            color: getAdvanceBalanceColor(
                              supplier.advanceBalance,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onEditMobile?.call(supplier),
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
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onDelete?.call(supplier),
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
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
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
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: isImportant ? FontWeight.w700 : FontWeight.w500,
                    color: isImportant
                        ? AppColors.primaryColor(context)
                        : AppColors.text(context),
                    fontSize: isImportant ? 15 : 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvanceBalanceChip(String? advanceBalance) {
    final balance = double.tryParse(advanceBalance ?? '0') ?? 0;
    Color color;
    String text;
    IconData icon;

    if (balance > 0) {
      color = AppColors.success;
      text = '+৳${balance.toStringAsFixed(2)}';
      icon = Iconsax.arrow_up_3;
    } else if (balance < 0) {
      color = AppColors.danger;
      text = '৳${balance.toStringAsFixed(2)}';
      icon = Iconsax.arrow_down_2;
    } else {
      color = Colors.grey;
      text = '৳0.00';
      icon = Iconsax.minus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color getAdvanceBalanceColor(String? advanceBalance) {
    final balance = double.tryParse(advanceBalance ?? '0') ?? 0;
    if (balance > 0) return AppColors.success;
    if (balance < 0) return AppColors.danger;
    return Colors.grey;
  }

  // Desktop টেবিল — AppDataTable
  // আগে ১৪টা column ছিল, টেবিল পর্দা ছাড়িয়ে যেত। এখন সম্পর্কিত তথ্য
  // এক cell এ (নামের নিচে Supplier No, দোকানের নিচে পণ্য, ফোনের নিচে email)
  Widget _buildDesktopDataTable(BuildContext context) {
    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 52),
      AppTableColumn('Supplier', flex: 3, minWidth: 150),
      AppTableColumn('Shop / Products', flex: 3, minWidth: 150),
      AppTableColumn('Contact', flex: 3, minWidth: 140),
      AppTableColumn('Address', flex: 3, minWidth: 140),
      AppTableColumn.numeric('Purchases', flex: 2, minWidth: 110),
      AppTableColumn.numeric('Paid', flex: 2, minWidth: 100),
      AppTableColumn.numeric('Due', flex: 2, minWidth: 100),
      AppTableColumn.numeric('Advance', flex: 2, minWidth: 100),
      AppTableColumn.center('Status', flex: 2, minWidth: 96),
      AppTableColumn.center('Actions', flex: 2, minWidth: 96),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: suppliers.length,
      cellBuilder: (context, row, col) {
        final s = suppliers[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(s.name ?? '-',
                bold: true, subtitle: s.supplierNo);
          case 2:
            return AppTableText(s.shopName ?? '-', subtitle: s.productName);
          case 3:
            return AppTableText(s.phone ?? '-', subtitle: s.email?.toString());
          case 4:
            return AppTableText(s.address ?? '-', muted: true);
          case 5:
            return AppTableMoney(AppTableMoney.parse(s.totalPurchases));
          case 6:
            return AppTableMoney(AppTableMoney.parse(s.totalPaid),
                color: AppColors.success);
          case 7:
            final due = AppTableMoney.parse(s.totalDue);
            return AppTableMoney(due,
                bold: due > 0,
                color: due > 0
                    ? AppColors.danger
                    : AppColors.text(context).withValues(alpha: 0.5));
          case 8:
            return AppTableMoney(AppTableMoney.parse(s.advanceBalance),
                color: getAdvanceBalanceColor(s.advanceBalance));
          case 9:
            final active = s.isActive == true;
            return AppStatusPill(active ? 'Active' : 'Inactive',
                color: active ? AppColors.success : AppColors.danger);
          default:
            return AppTableEditDelete(
              onEdit: onEdit == null ? null : () => onEdit!(s),
              onDelete: onDelete == null ? null : () => onDelete!(s),
            );
        }
      },
    );
  }
}
