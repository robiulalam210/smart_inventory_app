import 'package:printing/printing.dart';
import '/feature/supplier/data/model/supplier_payment/suppler_payment_model.dart';
import '/feature/supplier/presentation/shared/supplier_payment_details.dart';

import '../../../../core/configs/configs.dart';
import '../shared/pdf/generate_supplier_payment.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

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
          // Header with Payment No and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColors(
                getStatus(payment.paymentSummary),
              ).$1.withValues(alpha: 0.05),
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
                      Flexible(
                        child: Text(
                          payment.spNo ?? '-',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.text(context),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColors(
                        getStatus(payment.paymentSummary),
                      ).$1.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColors(
                          getStatus(payment.paymentSummary),
                        ).$1,
                      ),
                    ),
                    child: Text(
                      _formatStatusText(getStatus(payment.paymentSummary)),
                      style: TextStyle(
                        color: _getStatusColors(
                          getStatus(payment.paymentSummary),
                        ).$2,
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
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        context: context,
                        icon: Iconsax.user,
                        label: 'Supplier',
                        value: payment.supplierName ?? '-',
                        isImportant: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (payment.supplierPhone?.isNotEmpty == true)
                      Expanded(
                        child: _buildDetailRow(
                          context: context,
                          icon: Iconsax.call,
                          label: 'Phone',
                          value: payment.supplierPhone!,
                          onTap: () {
                            // Add phone call functionality
                          },
                        ),
                      ),
                  ],
                ),
                // Supplier Info
                SizedBox(height: 8),

                // Payment Details Grid
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bottomNavBg(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
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
                            'Payment Details',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor(context),
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
                            color: AppColors.success,
                          ),
                          _buildPaymentDetailCard(
                            label: 'Method',
                            value: payment.paymentMethod ?? '-',
                            icon: Iconsax.card,
                            color: AppColors.info,
                          ),
                          _buildPaymentDetailCard(
                            label: 'Date',
                            value: formatDate(payment.paymentDate),
                            icon: Iconsax.calendar,
                            color: AppColors.warning,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bottomNavBg(context),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
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
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              title:  Text('Supplier Payment Invoice',style: AppTextStyle.titleMedium(context),),
                              backgroundColor: AppColors.bottomNavBg(context),

                            ),
                            body: PdfPreview.builder(
                              useActions: true,
                              allowSharing: false,
                              canDebug: false,
                              canChangeOrientation: false,
                              canChangePageFormat: false,
                              dynamicLayout: true,

                              pdfPreviewPageDecoration: BoxDecoration(color: AppColors.text(context)),

                              build: (format) =>
                                  generateSupplierPaymentPdf(payment),
                              actionBarTheme: PdfActionBarTheme(
                                backgroundColor: AppColors.bottomNavBg(context),
                                iconColor: AppColors.text(context),
                                textStyle: AppTextStyle.body(context),
                              ),
                              actions: [
                                IconButton(
                                  onPressed: () => AppRoutes.pop(context),
                                  icon: const Icon(Icons.cancel, color: AppColors.danger),
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
                                      padding: const EdgeInsets.all(0.0),
                                      child: Image(image: page.image, fit: BoxFit.fill),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('PDF'),
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
          Icon(icon, size: 18, color: AppColors.text(context)),
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

  Widget _buildPaymentDetailCard({
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
        return (AppColors.success.withValues(alpha: 0.2), AppColors.success);
      case 'pending':
      case 'processing':
        return (AppColors.warning.withValues(alpha: 0.2), AppColors.warning);
      case 'failed':
      case 'cancelled':
      case 'rejected':
        return (AppColors.danger.withValues(alpha: 0.2), AppColors.danger);
      default:
        return (Colors.grey.withValues(alpha: 0.2), Colors.grey);
    }
  }

  // Desktop টেবিল — AppDataTable
  // (আগে টাকার আগে ভুল করে "\$" চিহ্ন দেখাত — এখন ৳)
  Widget _buildDesktopDataTable() {
    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 52),
      AppTableColumn('Payment No', flex: 2, minWidth: 110),
      AppTableColumn('Supplier', flex: 3, minWidth: 160),
      AppTableColumn.numeric('Amount', flex: 2, minWidth: 110),
      AppTableColumn('Method', flex: 2, minWidth: 100),
      AppTableColumn('Date', flex: 2, minWidth: 100),
      AppTableColumn('Prepared By', flex: 2, minWidth: 110),
      AppTableColumn.center('Status', flex: 2, minWidth: 100),
      AppTableColumn.center('Actions', flex: 2, minWidth: 96),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: suppliers.length,
      cellBuilder: (context, row, col) {
        final pay = suppliers[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(pay.spNo ?? '-',
                bold: true, color: AppColors.primaryColor(context));
          case 2:
            return AppTableText(pay.supplierName ?? '-',
                subtitle: pay.supplierPhone);
          case 3:
            return AppTableMoney(AppTableMoney.parse(pay.amount),
                bold: true, color: AppColors.success);
          case 4:
            return AppTableText(pay.paymentMethod ?? '-');
          case 5:
            final d = pay.paymentDate;
            return AppTableText(d == null
                ? '-'
                : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}');
          case 6:
            return AppTableText(pay.preparedByName ?? '-', muted: true);
          case 7:
            final status = pay.paymentSummary?.status ?? 'Unknown';
            return AppStatusPill(_formatStatusText(status),
                color: _getStatusColors(status).$2);
          default:
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTableAction(
                  icon: Icons.visibility_outlined,
                  tooltip: 'View details',
                  color: AppColors.info,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SupplierPaymentDetailsScreen(payment: pay),
                    ),
                  ),
                ),
                AppTableAction(
                  icon: Icons.picture_as_pdf_outlined,
                  tooltip: 'Payment PDF',
                  color: AppColors.success,
                  onPressed: () => _openPdf(context, pay),
                ),
              ],
            );
        }
      },
    );
  }

  void _openPdf(BuildContext context, SupplierPaymentModel sale) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.danger,
          body: PdfPreview.builder(
            useActions: true,
            allowSharing: false,
            canDebug: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
            dynamicLayout: true,
            build: (format) => generateSupplierPaymentPdf(sale),
            pdfPreviewPageDecoration: BoxDecoration(
              color: AppColors.white,
            ),
            actionBarTheme: PdfActionBarTheme(
              backgroundColor: AppColors.primaryColor(context),
              iconColor: Colors.white,
              textStyle: const TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: () => AppRoutes.pop(context),
                icon: const Icon(Icons.cancel, color: AppColors.danger),
              ),
            ],
            pagesBuilder: (context, pages) {
              return PageView.builder(
                itemCount: pages.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Container(
                    color: Colors.grey,
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
