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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 8, vertical: 4),
      itemCount: sales.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildSaleCard(sales[index], context),
    );
  }

  Widget _buildSaleCard(PosSaleModel sale, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.text(context);
    final primary = AppColors.primaryColor(context);

    final due = _toDouble(sale.dueAmount);
    final paid = _toDouble(sale.paidAmount);
    final payable = _toDouble(sale.payableAmount);
    final isAdvance = due < 0;
    final status = _getPaymentStatus(paid, payable);
    final statusColor = _getStatusColor(status);
    final dueColor = due == 0
        ? textColor.withValues(alpha: 0.5)
        : isAdvance
            ? AppColors.success
            : AppColors.danger;

    return Material(
      color: AppColors.bottomNavBg(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _viewSaleDetails(context, sale),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── ইনভয়েস নং, তারিখ, অবস্থা ──
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Iconsax.receipt_2, size: 20, color: primary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _text(sale.invoiceNo),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(sale.saleDate),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textColor.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppStatusPill(status, color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── কাস্টমার ও সেলসম্যান ──
                    Row(
                      children: [
                        Icon(
                          Iconsax.user,
                          size: 15,
                          color: textColor.withValues(alpha: 0.55),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _text(sale.customerName),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (_text(sale.saleByName) != '-') ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'by ${_text(sale.saleByName)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: textColor.withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── টাকার সারসংক্ষেপ ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _amount(
                              context,
                              'Total',
                              _formatCurrency(payable),
                              textColor,
                            ),
                          ),
                          _vDivider(context),
                          Expanded(
                            child: _amount(
                              context,
                              'Paid',
                              _formatCurrency(paid),
                              AppColors.success,
                            ),
                          ),
                          _vDivider(context),
                          Expanded(
                            child: _amount(
                              context,
                              isAdvance ? 'Advance' : 'Due',
                              _formatCurrency(due.abs()),
                              dueColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── অ্যাকশন ──
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppColors.borderLight,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _viewSaleDetails(context, sale),
                        icon: const Icon(Iconsax.eye, size: 17),
                        label: const Text('Details'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.info,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 22,
                      color: textColor.withValues(alpha: 0.1),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _generatePdf(context, sale),
                        icon: const Icon(Iconsax.document_download, size: 17),
                        label: const Text('Invoice PDF'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _amount(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.text(context).withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _vDivider(BuildContext context) => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: AppColors.text(context).withValues(alpha: 0.08),
      );

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
              context.read<ProfileBloc>().permissionModel?.data?.businessInfo,
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
