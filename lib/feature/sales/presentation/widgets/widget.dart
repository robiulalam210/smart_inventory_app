import 'package:printing/printing.dart';

import '../../../../core/configs/configs.dart';
import '../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '../../data/models/pos_sale_model.dart';
import '../pages/sales_details_screen.dart';
import 'pdf/sales_invocei.dart';

class PosSaleDataTableWidget extends StatelessWidget {
  final List<PosSaleModel> sales;

  const PosSaleDataTableWidget({super.key, required this.sales});

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
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final sale = sales[index];
        return _buildSaleCard(sale, index + 1, context, isMobile);
      },
    );
  }

  Widget _buildSaleCard(
    PosSaleModel sale,
    int index,
    BuildContext context,
    bool isMobile,
  ) {
    final dueAmount = sale.dueAmount is String
        ? double.tryParse(sale.dueAmount!) ?? 0.0
        : (sale.dueAmount ?? 0.0).toDouble();

    final paidAmount = sale.paidAmount is String
        ? double.tryParse(sale.paidAmount!) ?? 0.0
        : (sale.paidAmount ?? 0.0).toDouble();

    final payableAmount = sale.payableAmount is String
        ? double.tryParse(sale.payableAmount!) ?? 0.0
        : (sale.payableAmount ?? 0.0).toDouble();

    final isAdvance = dueAmount < 0;
    final displayAmount = isAdvance ? dueAmount.abs() : dueAmount;
    final status = _getPaymentStatus(paidAmount, payableAmount);
    final statusColor = _getStatusColor(status);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 0.0 : 8.0,
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
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Receipt No and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.05),
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
                    const SizedBox(width: 12),
                    SizedBox(
                      child: Text(
                        sale.invoiceNo.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sale Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Date
                    Expanded(
                      child: _buildDetailRow(
                        icon: Iconsax.calendar,
                        label: 'Date',
                        value: _formatDate(sale.saleDate),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Customer
                    Expanded(
                      child: _buildDetailRow(
                        icon: Iconsax.user,
                        label: 'Customer',
                        value: sale.customerName.toString(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Sales By
                _buildDetailRow(
                  icon: Iconsax.profile_2user,
                  label: 'Sales By',
                  value: sale.saleByName.toString(),
                ),
                const SizedBox(height: 8),

                // Financial Summary
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      // Grand Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            _formatCurrency(payableAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Paid Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Paid:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            _formatCurrency(paidAmount),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Due/Advance
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isAdvance ? 'Advance:' : 'Due:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            _formatCurrency(displayAmount),
                            style: TextStyle(
                              color: isAdvance ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // View Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewSaleDetails(context, sale),
                    icon: const Icon(Iconsax.eye, size: 16),
                    label: const Text('View'),
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

                // PDF Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _generatePdf(context, sale),
                    icon: const Icon(Iconsax.document_download, size: 16),
                    label: const Text('PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: BorderSide(color: Colors.green.shade300),
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
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
        const numColumns = 11;
        const minColumnWidth = 100.0;

        final dynamicColumnWidth = (totalWidth / numColumns).clamp(
          minColumnWidth,
          double.infinity,
        );

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radius),
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
                        dataRowMinHeight: 30,
                        columnSpacing: 0,
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        headingRowColor: WidgetStateProperty.all(
                          AppColors.primaryColor,
                        ),
                        headingRowHeight: 40,
                        columns: _buildColumns(dynamicColumnWidth),
                        rows: sales
                            .asMap()
                            .entries
                            .map(
                              (entry) => _buildDataRow(
                                context,
                                entry.key + 1,
                                entry.value,
                                dynamicColumnWidth,
                              ),
                            )
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
    const labels = [
      "SL",
      "Receipt No",
      "Sale Date",
      "Customer Name",
      "Sales By",
      "Created By",
      "Grand Total",
      "Paid Amount",
      "Due/Advance",
      "Status",
      "Actions",
    ];

    return labels
        .map(
          (label) => DataColumn(
            label: SizedBox(
              width: columnWidth,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  DataRow _buildDataRow(
    BuildContext context,
    int index,
    PosSaleModel sale,
    double columnWidth,
  ) {
    final dueAmount = sale.dueAmount is String
        ? double.tryParse(sale.dueAmount!) ?? 0.0
        : (sale.dueAmount ?? 0.0).toDouble();

    final paidAmount = sale.paidAmount is String
        ? double.tryParse(sale.paidAmount!) ?? 0.0
        : (sale.paidAmount ?? 0.0).toDouble();

    final payableAmount = sale.payableAmount is String
        ? double.tryParse(sale.payableAmount!) ?? 0.0
        : (sale.payableAmount ?? 0.0).toDouble();

    final isAdvance = dueAmount < 0;
    final displayAmount = isAdvance ? dueAmount.abs() : dueAmount;
    final status = _getPaymentStatus(paidAmount, payableAmount);

    return DataRow(
      cells: [
        _buildDataCell(index.toString(), columnWidth, TextAlign.center),
        _buildDataCell(
          sale.invoiceNo.toString(),
          columnWidth,
          TextAlign.center,
        ),
        _buildDataCell(
          _formatDate(sale.saleDate),
          columnWidth,
          TextAlign.center,
        ),
        _buildDataCell(
          sale.customerName.toString(),
          columnWidth,
          TextAlign.center,
        ),
        _buildDataCell(
          sale.saleByName.toString(),
          columnWidth,
          TextAlign.center,
        ),
        _buildDataCell(
          sale.createdByName.toString(),
          columnWidth,
          TextAlign.center,
        ),
        _buildDataCell(
          _formatCurrency(payableAmount),
          columnWidth,
          TextAlign.center,
        ),
        _buildDataCell(
          _formatCurrency(paidAmount),
          columnWidth,
          TextAlign.center,
        ),
        _buildDueAdvanceCell(displayAmount, isAdvance, columnWidth),
        _buildStatusCell(status, columnWidth),
        _buildActionsCell(context, sale, columnWidth),
      ],
    );
  }

  DataCell _buildDataCell(String text, double width, TextAlign align) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          textAlign: align,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  DataCell _buildDueAdvanceCell(double amount, bool isAdvance, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isAdvance ? Colors.green : Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  DataCell _buildStatusCell(String status, double width) {
    final color = _getStatusColor(status);

    return DataCell(
      SizedBox(
        width: width,
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

  DataCell _buildActionsCell(
    BuildContext context,
    PosSaleModel sale,
    double width,
  ) {
    return DataCell(
      SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, size: 16),
              onPressed: () => _viewSaleDetails(context, sale),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              tooltip: 'View Details',
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, size: 16),
              onPressed: () => _generatePdf(context, sale),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              tooltip: 'Generate PDF',
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'pending':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(double amount) {
    return '৳${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getPaymentStatus(double paidAmount, double payableAmount) {
    if (paidAmount >= payableAmount) {
      return 'Paid';
    } else if (paidAmount > 0) {
      return 'Partial';
    } else {
      return 'Pending';
    }
  }

  void _viewSaleDetails(BuildContext context, PosSaleModel sale) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SalesDetailsScreen(sale: sale)),
    );
  }

  void _generatePdf(BuildContext context, PosSaleModel sale) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Sales Invoice'),
            backgroundColor: AppColors.primaryColor,
          ),
          body: PdfPreview.builder(
            useActions: true,
            allowSharing: false,
            canDebug: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
            dynamicLayout: true,
            build: (format) => generateSalesPdf(
              sale,
              context.read<ProfileBloc>().permissionModel?.data?.companyInfo,
            ),
            pagesBuilder: (context, pages) {
              return PageView.builder(
                itemCount: pages.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8.0),
                    child: Image(image: page.image, fit: BoxFit.contain),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
