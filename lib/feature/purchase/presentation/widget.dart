import '/feature/purchase/presentation/page/purchase_details.dart';
import 'package:printing/printing.dart';

import '../../../../core/configs/configs.dart';
import '../data/model/purchase_sale_model.dart';
import 'page/pdf/generate_purchase_pdf.dart';

class PurchaseDataTableWidget extends StatelessWidget {
  final List<PurchaseModel> sales;

  const PurchaseDataTableWidget({super.key, required this.sales});

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
        final purchase = sales[index];
        return _buildPurchaseCard(purchase, index + 1, context, isMobile);
      },
    );
  }

  Widget _buildPurchaseCard(
      PurchaseModel purchase,
      int index,
      BuildContext context,
      bool isMobile,
      ) {
    final dueAmount = purchase.dueAmount ?? 0;
    final paidAmount = purchase.paidAmount ?? 0;
    final totalAmount = purchase.total ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 8.0 : 16.0,
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
          // Header with Invoice No and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        purchase.invoiceNo ?? '-',
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(purchase.paymentStatus??"").withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getPaymentStatusColor(purchase.paymentStatus??""),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    purchase.paymentStatus ?? '-',
                    style: TextStyle(
                      color: _getPaymentStatusColor(purchase.paymentStatus.toString()),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Purchase Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                _buildDetailRow(
                  icon: Iconsax.calendar,
                  label: 'Date',
                  value: _formatDate(purchase.purchaseDate.toString()),
                ),
                const SizedBox(height: 8),

                // Supplier
                _buildDetailRow(
                  icon: Iconsax.user,
                  label: 'Supplier',
                  value: purchase.supplierName ?? '-',
                ),
                const SizedBox(height: 8),

                // Financial Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      // Total
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
                            '৳${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Paid
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
                            '৳${paidAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Due
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Due:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '৳${dueAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: dueAmount > 0 ? Colors.red : Colors.grey,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Payment Method
                if (purchase.paymentMethod?.isNotEmpty == true)
                  _buildDetailRow(
                    icon: Iconsax.wallet,
                    label: 'Payment Method',
                    value: purchase.paymentMethod ?? '-',
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
                // View Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewPurchaseDetails(context, purchase),
                    icon: const Icon(
                      Iconsax.eye,
                      size: 16,
                    ),
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
                    onPressed: () => _generatePdf(context, purchase),
                    icon: const Icon(
                      Iconsax.document_download,
                      size: 16,
                    ),
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
        Icon(
          icon,
          size: 16,
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
        final totalWidth = constraints.maxWidth - 50;
        const numColumns = 10;
        const minColumnWidth = 100.0;

        final dynamicColumnWidth =
        (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radius),
            color: Colors.white,
          ),
          child:ClipRRect( borderRadius: BorderRadius.circular(AppSizes.radius),
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
                          AppColors.primaryColor,
                        ),
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
      "Invoice No",
      "Date",
      "Supplier",
      "Gross Total",
      "Payment Status",
      "Paid",
      "Due",
      "Payment Method",
      "Actions",
    ];

    return labels
        .map(
          (label) => DataColumn(
        label: SizedBox(
          width: columnWidth,
          child: Padding(
            padding: const EdgeInsets.all(0),
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
      PurchaseModel sale,
      double columnWidth,
      ) {
    return DataRow(
      cells: [
        _buildDataCell(index.toString(), columnWidth, TextAlign.center),
        _buildDataCell(sale.invoiceNo ?? '-', columnWidth, TextAlign.center),
        _buildDataCell(
          _formatDate(sale.purchaseDate.toString()),
          columnWidth,
          TextAlign.center,
        ),
        _buildDataCell(sale.supplierName ?? '-', columnWidth, TextAlign.center),
        _buildDataCell(sale.total?.toString() ?? '0.00', columnWidth, TextAlign.center),
        _buildPaymentStatusCell(sale.paymentStatus ?? '-', columnWidth),
        _buildDataCell(sale.paidAmount?.toString() ?? '0.00', columnWidth, TextAlign.center),
        _buildDueCell(sale.dueAmount?.toString() ?? '0.00', columnWidth),
        _buildDataCell(sale.paymentMethod ?? '-', columnWidth, TextAlign.center),
        _buildActionsCell(context, sale, columnWidth),
      ],
    );
  }

  DataCell _buildDataCell(String text, double width, TextAlign align) {
    return DataCell(
      SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
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
      ),
    );
  }

  DataCell _buildPaymentStatusCell(String status, double width) {
    final color = _getPaymentStatusColor(status);

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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

  DataCell _buildDueCell(String amount, double width) {
    final due = double.tryParse(amount) ?? 0;
    final color = due > 0 ? Colors.red : Colors.green;

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Text(
            amount,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  DataCell _buildActionsCell(BuildContext context, PurchaseModel purchase, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, size: 16),
              onPressed: () => _viewPurchaseDetails(context, purchase),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              tooltip: 'View Details',
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, size: 16),
              onPressed: () => _generatePdf(context, purchase),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              tooltip: 'Generate PDF',
            ),
          ],
        ),
      ),
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'partial':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _viewPurchaseDetails(BuildContext context, PurchaseModel purchase) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseDetailsScreen(purchase: purchase),
      ),
    );
  }

  void _generatePdf(BuildContext context, PurchaseModel purchase) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Purchase Invoice'),
            backgroundColor: AppColors.primaryColor,
          ),
          body: PdfPreview.builder(
            useActions: true,
            allowSharing: false,
            canDebug: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
            dynamicLayout: true,
            build: (format) => generatePurchasePdf(purchase),
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