import 'package:printing/printing.dart';

import '../../../../core/configs/configs.dart';
import '../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '../../data/models/pos_sale_model.dart';
import '../shared/sales_details_screen.dart';
import 'pdf/sales_invocei.dart';
import 'package:meherinMart/core/widgets/table_scroll_controllers.dart';

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
          // Header with Receipt No and Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        sale.invoiceNo.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.text(context),

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
                        context: context,
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Customer
                    Expanded(
                      child: _buildDetailRow(
                        icon: Iconsax.user,
                        label: 'Customer',
                        value: sale.customerName.toString(),
                        context: context,
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
                  context: context,
                ),
                const SizedBox(height: 8),

                // Financial Summary
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bottomNavBg(context),
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
                              color: AppColors.text(context),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            _formatCurrency(payableAmount),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.text(context),

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
                              color: AppColors.text(context),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            _formatCurrency(paidAmount),
                            style: const TextStyle(
                              color: AppColors.success,
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
                              color: AppColors.text(context),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            _formatCurrency(displayAmount),
                            style: TextStyle(
                              color: isAdvance ? AppColors.success : AppColors.danger,
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // View Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewSaleDetails(context, sale),
                    icon: const Icon(Iconsax.eye, size: 16),
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
                    onPressed: () => _generatePdf(context, sale),
                    icon: const Icon(Iconsax.document_download, size: 16),
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
      children: [
        Icon(icon, size: 16, color: AppColors.text(context)),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text(context),
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

  // ------------------------------------------------------------
  // DESKTOP TABLE — AppDataTable
  // ------------------------------------------------------------
  // আগে: ১১টা column সমান চওড়া, সব লেখা center আর 10px, DataTable এর
  // margin এর কারণে টেবিল পর্দা ছাড়িয়ে যেত (Receipt No কেটে যেত)।
  // এখন: নাম বাঁয়ে, টাকা ডানে (দশমিক এক লাইনে), status/action মাঝে।
  // row এ ক্লিক করলে details খোলে।
  // ------------------------------------------------------------

  static const List<AppTableColumn> _columns = [
    AppTableColumn.center('SL', flex: 1, minWidth: 52),
    AppTableColumn('Receipt No', flex: 2, minWidth: 110),
    AppTableColumn('Sale Date', flex: 2, minWidth: 100),
    AppTableColumn('Customer', flex: 3, minWidth: 150),
    AppTableColumn('Sales By', flex: 2, minWidth: 110),
    AppTableColumn('Created By', flex: 2, minWidth: 110),
    AppTableColumn.numeric('Grand Total', flex: 2, minWidth: 110),
    AppTableColumn.numeric('Paid', flex: 2, minWidth: 100),
    AppTableColumn.numeric('Due / Advance', flex: 2, minWidth: 120),
    AppTableColumn.center('Status', flex: 2, minWidth: 100),
    AppTableColumn.center('Actions', flex: 2, minWidth: 96),
  ];

  Widget _buildDesktopDataTable() {
    return AppDataTable(
      columns: _columns,
      rowCount: sales.length,
      onRowTap: null,
      cellBuilder: (context, row, col) {
        final sale = sales[row];
        final double due = _toDouble(sale.dueAmount);
        final double paid = _toDouble(sale.paidAmount);
        final double payable = _toDouble(sale.payableAmount);
        final bool isAdvance = due < 0;

        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(sale.invoiceNo?.toString() ?? '-',
                bold: true, color: AppColors.primaryColor(context));
          case 2:
            return AppTableText(_formatDate(sale.saleDate));
          case 3:
            return AppTableText(_text(sale.customerName));
          case 4:
            return AppTableText(_text(sale.saleByName));
          case 5:
            return AppTableText(_text(sale.createdByName), muted: true);
          case 6:
            return AppTableText(_formatCurrency(payable),
                align: AppCellAlign.end, bold: true);
          case 7:
            return AppTableText(_formatCurrency(paid),
                align: AppCellAlign.end, color: AppColors.success);
          case 8:
            return AppTableText(
              (isAdvance ? '+ ' : '') + _formatCurrency(due.abs()),
              align: AppCellAlign.end,
              bold: due != 0,
              color: due == 0
                  ? AppColors.text(context).withValues(alpha: 0.5)
                  : isAdvance
                      ? AppColors.success
                      : AppColors.danger,
            );
          case 9:
            final status = _getPaymentStatus(paid, payable);
            return AppStatusPill(status, color: _getStatusColor(status));
          default:
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTableAction(
                  icon: Iconsax.eye,
                  tooltip: 'View details',
                  color: AppColors.info,
                  onPressed: () => _viewSaleDetails(context, sale),
                ),
                const SizedBox(width: 4),
                AppTableAction(
                  icon: Iconsax.document_download,
                  tooltip: 'Invoice PDF',
                  color: AppColors.success,
                  onPressed: () => _generatePdf(context, sale),
                ),
              ],
            );
        }
      },
    );
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  String _text(dynamic v) {
    final s = v?.toString() ?? '';
    return (s.isEmpty || s == 'null') ? '-' : s;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'partial':
        return AppColors.warning;
      case 'pending':
        return AppColors.danger;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(double amount) {
    return '৳${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year}';
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
            title:  Text('Sales Invoice',style: AppTextStyle.titleMedium(context),),
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
            build: (format) => generateSalesPdf(
              sale,
              context.read<ProfileBloc>().permissionModel?.data?.companyInfo,
            ),
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
  }
}
