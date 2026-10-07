
import '../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '/feature/purchase/presentation/shared/purchase_details.dart';
import 'package:printing/printing.dart';

import '../../../core/configs/configs.dart';
import '../data/model/purchase_sale_model.dart';
import 'shared/pdf/generate_purchase_pdf.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

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
          // Header with Invoice No and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    const SizedBox(width: 12),
                    SizedBox(
                      child: Text(
                        purchase.invoiceNo ?? '-',
                        style:  TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,            color: AppColors.text(context),

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

                Row(children: [
                  Expanded(
                    child: _buildDetailRow(
                        icon: Iconsax.calendar,
                        label: 'Date',
                        value: _formatDate(purchase.purchaseDate.toString()),
                        context: context
                    ),
                  ),

                  // Supplier
                  Expanded(
                    child: _buildDetailRow(
                        icon: Iconsax.user,
                        label: 'Supplier',
                        value: purchase.supplierName ?? '-',
                        context: context
                    ),
                  ),

                  if (purchase.paymentMethod?.isNotEmpty == true)
                    Expanded(
                      child: _buildDetailRow(
                          icon: Iconsax.wallet,
                          label: 'Payment Method',
                          value: purchase.paymentMethod ?? '-',context: context
                      ),
                    ),
                ],),

                const SizedBox(height: 8),

                // Financial Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bottomNavBg(context),
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
                              color: AppColors.text(context),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '৳${totalAmount.toStringAsFixed(2)}',
                            style:  TextStyle(
                              fontWeight: FontWeight.w700,            color: AppColors.text(context),

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
                              color: AppColors.text(context),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '৳${paidAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.success,
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
                              color: AppColors.text(context),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '৳${dueAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: dueAmount > 0 ? AppColors.danger :                             AppColors.text(context),

                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Payment Method

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
                      foregroundColor: AppColors.success,
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
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.text(context),
        ),
        const SizedBox(width: 3),
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
                style:  TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,            color: AppColors.text(context),

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
  Widget _buildDesktopDataTable() {
    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 52),
      AppTableColumn('Invoice No', flex: 2, minWidth: 110),
      AppTableColumn('Date', flex: 2, minWidth: 100),
      AppTableColumn('Supplier', flex: 3, minWidth: 150),
      AppTableColumn.numeric('Gross Total', flex: 2, minWidth: 110),
      AppTableColumn.numeric('Paid', flex: 2, minWidth: 100),
      AppTableColumn.numeric('Due', flex: 2, minWidth: 100),
      AppTableColumn('Method', flex: 2, minWidth: 100),
      AppTableColumn.center('Status', flex: 2, minWidth: 100),
      AppTableColumn.center('Actions', flex: 2, minWidth: 96),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: sales.length,
      cellBuilder: (context, row, col) {
        final p = sales[row];
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(p.invoiceNo ?? '-',
                bold: true, color: AppColors.primaryColor(context));
          case 2:
            return AppTableText(_formatDate(p.purchaseDate.toString()));
          case 3:
            return AppTableText(p.supplierName ?? '-');
          case 4:
            return AppTableMoney(AppTableMoney.parse(p.total), bold: true);
          case 5:
            return AppTableMoney(AppTableMoney.parse(p.paidAmount),
                color: AppColors.success);
          case 6:
            final due = AppTableMoney.parse(p.dueAmount);
            return AppTableMoney(due,
                bold: due > 0,
                color: due > 0
                    ? AppColors.danger
                    : AppColors.text(context).withValues(alpha: 0.5));
          case 7:
            return AppTableText(p.paymentMethod ?? '-', muted: true);
          case 8:
            final status = p.paymentStatus ?? '-';
            return AppStatusPill(status.capitalize(),
                color: _getPaymentStatusColor(status));
          default:
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTableAction(
                  icon: Iconsax.eye,
                  tooltip: 'View details',
                  color: AppColors.info,
                  onPressed: () => _viewPurchaseDetails(context, p),
                ),
                AppTableAction(
                  icon: Iconsax.document_download,
                  tooltip: 'Purchase PDF',
                  color: AppColors.success,
                  onPressed: () => _generatePdf(context, p),
                ),
              ],
            );
        }
      },
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'partial':
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(date.day)}/${two(date.month)}/${date.year}';
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
            backgroundColor: AppColors.primaryColor(context),
          ),
          body: PdfPreview.builder(
            useActions: true,
            allowSharing: false,
            canDebug: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
            dynamicLayout: true,
            build: (format) => generatePurchasePdf(purchase, context.read<ProfileBloc>().permissionModel?.data?.companyInfo),
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