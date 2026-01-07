import 'package:printing/printing.dart';
import '/feature/supplier/data/model/supplier_payment/suppler_payment_model.dart';
import '/feature/supplier/presentation/pages/supplier_payment_details.dart';

import '../../../../core/configs/configs.dart';
import '../pages/pdf/generate_supplier_payment.dart';

class SupplierPaymentWidget extends StatelessWidget {
  final List<SupplierPaymentModel> suppliers;
  final Function(SupplierPaymentModel)? onTap;
  final Function(SupplierPaymentModel)? onEdit;
  final Function(SupplierPaymentModel)? onDelete;

  const SupplierPaymentWidget({
    super.key,
    required this.suppliers,
    this.onTap,
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
      physics: const ClampingScrollPhysics(),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        return _buildPaymentCard(supplier, index + 1, context, isMobile);
      },
    );
  }

  Widget _buildPaymentCard(
      SupplierPaymentModel payment,
      int index,
      BuildContext context,
      bool isMobile,
      ) {
    String formatDate(DateTime? date) {
      if (date == null) return '-';
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    String getStatus(PaymentSummary? summary) {
      if (summary == null) return 'Unknown';
      return summary.status ?? 'Unknown';
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 8.0 : 12.0,
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
          // Header with Payment No and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColors(getStatus(payment.paymentSummary)).$1.withValues(alpha:0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // First Row: Index and Payment No
                Flexible(
                  child: Row(
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
                      Flexible(
                        child: Text(
                          payment.spNo ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Chip
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColors(getStatus(payment.paymentSummary)).$1.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColors(getStatus(payment.paymentSummary)).$1,
                      ),
                    ),
                    child: Text(
                      _formatStatusText(getStatus(payment.paymentSummary)),
                      style: TextStyle(
                        color: _getStatusColors(getStatus(payment.paymentSummary)).$2,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Payment Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Supplier Info
                _buildDetailRow(
                  icon: Iconsax.user,
                  label: 'Supplier',
                  value: payment.supplierName ?? '-',
                  isImportant: true,
                ),
                const SizedBox(height: 12),

                // Phone
                if (payment.supplierPhone?.isNotEmpty == true)
                  Column(
                    children: [
                      _buildDetailRow(
                        icon: Iconsax.call,
                        label: 'Phone',
                        value: payment.supplierPhone!,
                        onTap: () {
                          // Add phone call functionality
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

                // Payment Details Grid
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
                            'Payment Details',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Payment Details Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.5,
                        children: [
                          _buildPaymentDetailCard(
                            label: 'Amount',
                            value: '\$${_formatAmount(payment.amount)}',
                            icon: Iconsax.dollar_circle,
                            color: Colors.green,
                          ),
                          _buildPaymentDetailCard(
                            label: 'Method',
                            value: payment.paymentMethod ?? '-',
                            icon: Iconsax.card,
                            color: Colors.blue,
                          ),
                          _buildPaymentDetailCard(
                            label: 'Date',
                            value: formatDate(payment.paymentDate),
                            icon: Iconsax.calendar,
                            color: Colors.orange,
                          ),
                          _buildPaymentDetailCard(
                            label: 'Prepared By',
                            value: payment.preparedByName ?? '-',
                            icon: Iconsax.user_add,
                            color: Colors.purple,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SupplierPaymentDetailsScreen(payment: payment),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.visibility,
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
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            backgroundColor: Colors.red,
                            body: PdfPreview.builder(
                              useActions: true,
                              allowSharing: false,
                              canDebug: false,
                              canChangeOrientation: false,
                              canChangePageFormat: false,
                              dynamicLayout: true,
                              build: (format) =>
                                  generateSupplierPaymentPdf(payment),
                              pdfPreviewPageDecoration:
                              BoxDecoration(color: AppColors.white),
                              actionBarTheme: PdfActionBarTheme(
                                backgroundColor: AppColors.primaryColor,
                                iconColor: Colors.white,
                                textStyle: const TextStyle(color: Colors.white),
                              ),
                              actions: [
                                IconButton(
                                  onPressed: () => AppRoutes.pop(context),
                                  icon:
                                  const Icon(Icons.cancel, color: Colors.red),
                                ),
                              ],
                              pagesBuilder: (context, pages) {
                                debugPrint('Rendering ${pages.length} pages');
                                return PageView.builder(
                                  itemCount: pages.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    final page = pages[index];
                                    return Container(
                                      color: Colors.grey,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image(
                                          image: page.image,
                                          fit: BoxFit.contain),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.picture_as_pdf,
                      size: 16,
                    ),
                    label: const Text('PDF'),
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

  Widget _buildPaymentDetailCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha:0.2)),
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

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0.00';
    if (amount is String) {
      final numValue = double.tryParse(amount) ?? 0.0;
      return numValue.toStringAsFixed(2);
    }
    final numValue = amount is int
        ? amount.toDouble()
        : (amount is double ? amount : 0.0);
    return numValue.toStringAsFixed(2);
  }

  String _formatStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return 'PAID';
      case 'pending':
        return 'PENDING';
      case 'failed':
      case 'cancelled':
        return 'FAILED';
      default:
        return status.toUpperCase();
    }
  }

  (Color color, Color textColor) _getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
      case 'success':
        return (Colors.green.withValues(alpha:0.2), Colors.green);
      case 'pending':
      case 'processing':
        return (Colors.orange.withValues(alpha:0.2), Colors.orange);
      case 'failed':
      case 'cancelled':
      case 'rejected':
        return (Colors.red.withValues(alpha:0.2), Colors.red);
      default:
        return (Colors.grey.withValues(alpha:0.2), Colors.grey);
    }
  }

  // Keep your existing desktop DataTable code here
  Widget _buildDesktopDataTable() {
    final verticalController = ScrollController();
    final horizontalController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const numColumns = 10;
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
                color: Colors.grey.withValues(alpha:0.1),
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
                        columns: _buildColumns(context, dynamicColumnWidth),
                        rows: suppliers
                            .asMap()
                            .entries
                            .map(
                              (e) => _buildRow(
                            context,
                            e.key + 1,
                            e.value,
                            dynamicColumnWidth,
                          ),
                        )
                            .toList(),
                        headingRowColor:
                        WidgetStateProperty.all(AppColors.primaryColor),
                        headingRowHeight: 40,
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        dataRowMinHeight: 35,
                        columnSpacing: 0,
                        horizontalMargin: 0,
                        dataTextStyle: const TextStyle(fontSize: 11),
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

  List<DataColumn> _buildColumns(BuildContext context, double columnWidth) {
    return [
      _buildDataColumn("SL", columnWidth * 0.6),
      _buildDataColumn("Payment No", columnWidth * 0.8),
      _buildDataColumn("Supplier Name", columnWidth * 1.2),
      _buildDataColumn("Phone", columnWidth * 0.9),
      _buildDataColumn("Amount", columnWidth),
      _buildDataColumn("Payment Method", columnWidth),
      _buildDataColumn("Payment Date", columnWidth),
      _buildDataColumn("Prepared By", columnWidth),
      _buildDataColumn("Status", columnWidth * 0.8),
      _buildDataColumn("Actions", columnWidth * 0.8),
    ];
  }

  DataColumn _buildDataColumn(String label, double width) {
    return DataColumn(
      label: SizedBox(
        width: width,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(
      BuildContext context,
      int index,
      SupplierPaymentModel supplier,
      double columnWidth,
      ) {
    String formatDate(DateTime? date) {
      if (date == null) return '-';
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    String getStatus(PaymentSummary? summary) {
      if (summary == null) return 'Unknown';
      return summary.status ?? 'Unknown';
    }

    return DataRow(
      cells: [
        _buildIndexCell(index, columnWidth * 0.6),
        _buildDataCell(supplier.spNo ?? '-', columnWidth * 0.8),
        _buildDataCell(supplier.supplierName ?? '-', columnWidth * 1.2),
        _buildDataCell(supplier.supplierPhone ?? '-', columnWidth * 0.9),
        _buildAmountCell(supplier.amount, columnWidth),
        _buildDataCell(supplier.paymentMethod ?? '-', columnWidth),
        _buildDataCell(formatDate(supplier.paymentDate), columnWidth),
        _buildDataCell(supplier.preparedByName ?? '-', columnWidth),
        _buildStatusCell(getStatus(supplier.paymentSummary), columnWidth * 0.8),
        _buildActionsCell(context, supplier, columnWidth * 0.8),
      ],
    );
  }

  DataCell _buildActionsCell(
      BuildContext context,
      SupplierPaymentModel sale,
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SupplierPaymentDetailsScreen(payment: sale),
                  ),
                );
              },
              tooltip: 'View Details',
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, size: 16),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      backgroundColor: Colors.red,
                      body: PdfPreview.builder(
                        useActions: true,
                        allowSharing: false,
                        canDebug: false,
                        canChangeOrientation: false,
                        canChangePageFormat: false,
                        dynamicLayout: true,
                        build: (format) => generateSupplierPaymentPdf(sale),
                        pdfPreviewPageDecoration:
                        BoxDecoration(color: AppColors.white),
                        actionBarTheme: PdfActionBarTheme(
                          backgroundColor: AppColors.primaryColor,
                          iconColor: Colors.white,
                          textStyle: const TextStyle(color: Colors.white),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () => AppRoutes.pop(context),
                            icon: const Icon(Icons.cancel, color: Colors.red),
                          ),
                        ],
                        pagesBuilder: (context, pages) {
                          debugPrint('Rendering ${pages.length} pages');
                          return PageView.builder(
                            itemCount: pages.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              final page = pages[index];
                              return Container(
                                color: Colors.grey,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8.0),
                                child:
                                Image(image: page.image, fit: BoxFit.contain),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              tooltip: 'Generate PDF',
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildIndexCell(int index, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Text(
            index.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  DataCell _buildDataCell(String text, double width) {
    return DataCell(
      SizedBox(
        width: width,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  DataCell _buildAmountCell(dynamic amount, double width) {
    final formattedAmount = _formatAmount(amount);

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Text(
            '\$$formattedAmount',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildStatusCell(String status, double width) {
    final (color, textColor) = _getStatusColors(status);

    return DataCell(
      SizedBox(
        width: width,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha:0.3)),
            ),
            constraints: const BoxConstraints(minWidth: 70),
            child: Text(
              _formatStatusText(status),
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}