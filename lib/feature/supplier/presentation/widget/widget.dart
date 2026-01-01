import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:meherin_mart/feature/supplier/data/model/supplier_list_model.dart';

import '../../../../core/configs/app_colors.dart';
import '../../../../core/configs/configs.dart';

class SupplierDataTableWidget extends StatelessWidget {
  final List<SupplierListModel> suppliers;
  final Function(SupplierListModel)? onEdit;
  final Function(SupplierListModel)? onDelete;

  const SupplierDataTableWidget({
    super.key,
    required this.suppliers,
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
        horizontal: isMobile ? 6.0 : 16.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
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
                        color: AppColors.primaryColor,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Row
                _buildDetailRow(
                  icon: Iconsax.user,
                  label: 'Name',
                  value: supplier.name ?? '-',
                  isImportant: true,
                ),
                const SizedBox(height: 12),

                // Phone Row
                _buildDetailRow(
                  icon: Iconsax.call,
                  label: 'Phone',
                  value: supplier.phone ?? '-',
                  onTap: supplier.phone != null
                      ? () {
                    // Add phone call functionality
                  }
                      : null,
                ),
                const SizedBox(height: 12),

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
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Address:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 26),
                        child: Text(
                          supplier.address!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

                // Financial Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
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
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Financial Summary',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Financial Details Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.5,
                        children: [
                          _buildFinancialCard(
                            label: 'Purchases',
                            value: '৳${supplier.totalPurchases.toString()}',
                            icon: Iconsax.shopping_cart,
                            color: Colors.blue,
                          ),
                          _buildFinancialCard(
                            label: 'Paid',
                            value: '৳${supplier.totalPaid.toString()}',
                            icon: Iconsax.wallet_check,
                            color: Colors.green,
                          ),
                          _buildFinancialCard(
                            label: 'Due',
                            value: '৳${supplier.totalDue.toString()}',
                            icon: Iconsax.wallet_minus,
                            color: Colors.orange,
                          ),
                          _buildFinancialCard(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
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
                    onPressed: () => onEdit?.call(supplier),
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
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onDelete?.call(supplier),
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
            color: Colors.grey.shade600,
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
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: isImportant ? FontWeight.w700 : FontWeight.w500,
                    color: isImportant ? Colors.black : Colors.grey.shade800,
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
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
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
                    color: Colors.grey.shade600,
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
      color = Colors.green;
      text = '+৳${balance.toStringAsFixed(2)}';
      icon = Iconsax.arrow_up_3;
    } else if (balance < 0) {
      color = Colors.red;
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
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
    if (balance > 0) return Colors.green;
    if (balance < 0) return Colors.red;
    return Colors.grey;
  }
// Keep your existing desktop DataTable code here
  Widget _buildDesktopDataTable() {
    final verticalController = ScrollController();
    final horizontalController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 11;
        const minColumnWidth = 100.0;

        final dynamicColumnWidth = (totalWidth / numColumns).clamp(
          minColumnWidth,
          double.infinity,
        );

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
            controller: verticalController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: verticalController,
              child: Scrollbar(
                controller: horizontalController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: totalWidth),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: DataTable(
                        columns: _buildColumns(dynamicColumnWidth),
                        rows: suppliers
                            .asMap()
                            .entries
                            .map((e) => _buildRow(e.key + 1, e.value))
                            .toList(),
                        headingRowColor: WidgetStateProperty.all(
                          AppColors.primaryColor,
                        ),
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        dataRowMinHeight: 40,
                        headingRowHeight: 40,
                        columnSpacing: 0,
                        dataTextStyle: const TextStyle(fontSize: 12),
                        // Add these properties for better alignment
                        dataRowMaxHeight: 50,
                        horizontalMargin: 12,
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

// Keep your existing desktop _buildColumns method
  List<DataColumn> _buildColumns(double columnWidth) {
    final columns = [
      _DataColumnConfig("SL", columnWidth, TextAlign.center),
      _DataColumnConfig("Supplier No", columnWidth, TextAlign.left),
      _DataColumnConfig("Name", columnWidth, TextAlign.left),
      _DataColumnConfig("Phone", columnWidth, TextAlign.left),
      _DataColumnConfig("Address", columnWidth, TextAlign.left),
      _DataColumnConfig("Total Purchases", columnWidth, TextAlign.right),
      _DataColumnConfig("Total Paid", columnWidth, TextAlign.right),
      _DataColumnConfig("Total Due", columnWidth, TextAlign.right),
      _DataColumnConfig("Advance Balance", columnWidth, TextAlign.center),
      _DataColumnConfig("Actions", columnWidth, TextAlign.center),
    ];

    return columns
        .map(
          (col) => DataColumn(
        label: Container(
          width: col.width,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            col.label,
            textAlign: col.textAlign,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    )
        .toList();
  }

// Keep your existing desktop _buildRow method
  DataRow _buildRow(int index, SupplierListModel supplier) {
    return DataRow(
      cells: [
        _buildDataCell(index.toString(), TextAlign.center),
        _buildDataCell(supplier.supplierNo ?? '-', TextAlign.left),
        _buildDataCell(supplier.name ?? '-', TextAlign.left),
        _buildDataCell(supplier.phone ?? '-', TextAlign.left),
        _buildDataCell(supplier.address ?? '-', TextAlign.left),
        _buildDataCell(
          '৳${supplier.totalPurchases}',
          TextAlign.center,
          isNumeric: true,
        ),
        _buildDataCell(
          '৳${supplier.totalPaid.toString()}',
          TextAlign.center,
          isNumeric: true,
        ),
        _buildDataCell(
          '৳${supplier.totalDue}',
          TextAlign.right,
          isNumeric: true,
        ),
        DataCell(
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: getAdvanceBalanceColor(supplier.advanceBalance)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: getAdvanceBalanceColor(supplier.advanceBalance),
                  width: 1,
                ),
              ),
              child: Text(
                '৳${supplier.advanceBalance ?? '0.00'}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: getAdvanceBalanceColor(supplier.advanceBalance),
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Iconsax.edit, size: 18),
                  color: Colors.blue,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () => onEdit?.call(supplier),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(HugeIcons.strokeRoundedDeleteThrow, size: 18),
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () => onDelete?.call(supplier),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DataCell _buildDataCell(String text, TextAlign align, {bool isNumeric = false}) {
    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        alignment: _getAlignment(align),
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(
            fontSize: 12,
            fontFamily: isNumeric ? 'RobotoMono' : null,
            fontWeight: isNumeric ? FontWeight.w500 : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

// Helper function to convert TextAlign to Alignment
  AlignmentGeometry _getAlignment(TextAlign align) {
    switch (align) {
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.center:
        return Alignment.center;
      default:
        return Alignment.centerLeft;
    }
  }}

  class _DataColumnConfig {
  final String label;
  final double width;
  final TextAlign textAlign;

  const _DataColumnConfig(this.label, this.width, this.textAlign);



}