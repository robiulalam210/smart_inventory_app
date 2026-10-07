import 'package:printing/printing.dart';

import '../../../../core/configs/configs.dart';
import '../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '../../data/model/money_receipt_model/money_receipt_model.dart';
import '../shared/money_receipt_details.dart';
import '../shared/pdf/generate_money_receipt.dart';

class MoneyReceiptDataTableWidget extends StatelessWidget {
  final List<MoneyreceiptModel> sales;

  const MoneyReceiptDataTableWidget({super.key, required this.sales});

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
        final receipt = sales[index];
        return _buildReceiptCard(receipt, index + 1, context, isMobile);
      },
    );
  }

  Widget _buildReceiptCard(
      MoneyreceiptModel receipt,
      int index,
      BuildContext context,
      bool isMobile,
      ) {
    final summary = receipt.paymentSummary;
    final totalBefore = double.tryParse(summary?.beforePayment?.totalDue.toString() ?? "0") ?? 0;
    final amount = double.tryParse(receipt.amount ?? '0') ?? 0;
    final status = summary?.status ?? '-';
    final statusColor = _getStatusColor(status);

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
          // Header with MR No and Status
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
                        receipt.mrNo ?? '-',
                        style:  TextStyle(
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor,
                      width: 1,
                    ),
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

          // Receipt Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: _buildDetailRow(
                    icon: Iconsax.user,
                    label: 'Customer',
                    value: receipt.customerName ?? '-',
                    context: context
                  ),),
                  SizedBox(width: 8,),
                  Expanded(child:  _buildDetailRow(
                    icon: Iconsax.profile_2user,
                    label: 'Seller',
                    value: receipt.sellerName ?? '-',
                    context: context
                  ),),

                ],),
                // Customer


                // Seller

                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child:  _buildDetailRow(
                    icon: Iconsax.calendar,
                    label: 'Payment Date',
                    value: _formatDate(receipt.paymentDate),
                    context: context
                  ),),
                  SizedBox(width: 8,),
                  Expanded(child:  _buildDetailRow(
                    icon: Iconsax.wallet,
                    label: 'Payment Method',
                    value: receipt.paymentMethod ?? '-',
                    context: context
                  ),),

                ],),
                // Payment Date


                const SizedBox(height: 8),

                // Phone
                if (receipt.customerPhone != null && receipt.customerPhone!.isNotEmpty)
                  Column(
                    children: [
                      _buildDetailRow(
                        icon: Iconsax.call,
                        label: 'Phone',
                        value: receipt.customerPhone!,
                        context: context
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),

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
                      // Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Amount:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.text(context),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '৳${amount.toStringAsFixed(2)}',
                            style:  TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.text(context),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Total Before
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Before:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.text(context),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '৳${totalBefore.toStringAsFixed(2)}',
                            style:  TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.text(context),
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
                    onPressed: () => _viewReceiptDetails(context, receipt),
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
                    onPressed: () => _generatePdf(context, receipt),
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
      children: [
        Icon(
          icon,
          size: 16,
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
                style:  TextStyle(
                  fontSize: 14,
                  color: AppColors.text(context),
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

  // Desktop টেবিল — AppDataTable
  Widget _buildDesktopDataTable() {
    const columns = [
      AppTableColumn.center('SL', flex: 1, minWidth: 52),
      AppTableColumn('MR No', flex: 2, minWidth: 110),
      AppTableColumn('Customer', flex: 3, minWidth: 150),
      AppTableColumn('Seller', flex: 2, minWidth: 110),
      AppTableColumn('Date', flex: 2, minWidth: 100),
      AppTableColumn('Method', flex: 2, minWidth: 100),
      AppTableColumn.numeric('Amount', flex: 2, minWidth: 110),
      AppTableColumn.numeric('Due Before', flex: 2, minWidth: 110),
      AppTableColumn.center('Status', flex: 2, minWidth: 100),
      AppTableColumn.center('Actions', flex: 2, minWidth: 96),
    ];

    return AppDataTable(
      columns: columns,
      rowCount: sales.length,
      cellBuilder: (context, row, col) {
        final r = sales[row];
        final summary = r.paymentSummary;
        switch (col) {
          case 0:
            return AppTableText('${row + 1}',
                align: AppCellAlign.center, muted: true);
          case 1:
            return AppTableText(r.mrNo ?? '-',
                bold: true, color: AppColors.primaryColor(context));
          case 2:
            return AppTableText(r.customerName ?? '-',
                subtitle: r.customerPhone?.toString());
          case 3:
            return AppTableText(r.sellerName ?? '-', muted: true);
          case 4:
            return AppTableText(_formatDate(r.paymentDate));
          case 5:
            return AppTableText(r.paymentMethod ?? '-');
          case 6:
            return AppTableMoney(AppTableMoney.parse(r.amount),
                bold: true, color: AppColors.success);
          case 7:
            return AppTableMoney(
                AppTableMoney.parse(summary?.beforePayment?.totalDue));
          case 8:
            final status = summary?.status ?? '-';
            return AppStatusPill(status, color: _getStatusColor(status));
          default:
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTableAction(
                  icon: Icons.visibility_outlined,
                  tooltip: 'View details',
                  color: AppColors.info,
                  onPressed: () => _viewReceiptDetails(context, r),
                ),
                AppTableAction(
                  icon: Icons.picture_as_pdf_outlined,
                  tooltip: 'Receipt PDF',
                  color: AppColors.success,
                  onPressed: () => _generatePdf(context, r),
                ),
              ],
            );
        }
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
      case 'paid':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
      case 'cancelled':
        return AppColors.danger;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  void _viewReceiptDetails(BuildContext context, MoneyreceiptModel receipt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoneyReceiptDetailsScreen(receipt: receipt),
      ),
    );
  }

  void _generatePdf(BuildContext context, MoneyreceiptModel receipt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Money Receipt'),
            backgroundColor: AppColors.primaryColor(context),
          ),
          body: PdfPreview.builder(
            useActions: true,
            allowSharing: false,
            canDebug: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
            dynamicLayout: true,
            build: (format) => generateMoneyReceiptPdf(receipt, context.read<ProfileBloc>().permissionModel?.data?.companyInfo),
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