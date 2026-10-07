
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 8, vertical: 4),
      itemCount: sales.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) =>
          _buildPurchaseCard(sales[index], context),
    );
  }

  Widget _buildPurchaseCard(PurchaseModel purchase, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.text(context);
    final primary = AppColors.primaryColor(context);

    final total = AppTableMoney.parse(purchase.total);
    final paid = AppTableMoney.parse(purchase.paidAmount);
    final due = AppTableMoney.parse(purchase.dueAmount);
    final status = (purchase.paymentStatus ?? '-');
    final statusColor = _getPaymentStatusColor(status);
    final supplier = (purchase.supplierName ?? '').trim();
    final method = (purchase.paymentMethod ?? '').trim();
    final divider = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.borderLight;

    String money(double v) => '৳${v.toStringAsFixed(2)}';

    return Material(
      color: AppColors.bottomNavBg(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _viewPurchaseDetails(context, purchase),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: divider),
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
                            color: AppColors.info.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Iconsax.box,
                            size: 20,
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                purchase.invoiceNo ?? '-',
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
                                _formatDate(purchase.purchaseDate.toString()),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textColor.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppStatusPill(status.capitalize(), color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── সাপ্লায়ার ও পেমেন্ট মাধ্যম ──
                    Row(
                      children: [
                        Icon(
                          Iconsax.shop,
                          size: 15,
                          color: textColor.withValues(alpha: 0.55),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            supplier.isEmpty ? '-' : supplier,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (method.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: textColor.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              method,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textColor.withValues(alpha: 0.7),
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
                              money(total),
                              textColor,
                            ),
                          ),
                          _vDivider(context),
                          Expanded(
                            child: _amount(
                              context,
                              'Paid',
                              money(paid),
                              AppColors.success,
                            ),
                          ),
                          _vDivider(context),
                          Expanded(
                            child: _amount(
                              context,
                              'Due',
                              money(due),
                              due > 0
                                  ? AppColors.danger
                                  : textColor.withValues(alpha: 0.5),
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
                  border: Border(top: BorderSide(color: divider)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _viewPurchaseDetails(context, purchase),
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
                        onPressed: () => _generatePdf(context, purchase),
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