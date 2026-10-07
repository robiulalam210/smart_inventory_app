import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:printing/printing.dart';
import '/feature/supplier/presentation/shared/pdf/generate_supplier_payment.dart';
import '../../../../core/configs/configs.dart';
import '../../data/model/supplier_payment/suppler_payment_model.dart';


class SupplierPaymentDetailsScreen extends StatelessWidget {
  final SupplierPaymentModel payment;

  const SupplierPaymentDetailsScreen({super.key, required this.payment});

  // hero — SP নম্বর, status, supplier; ডানে পরিশোধিত টাকা
  // বাঁয়ে — Payment information (cheque থাকলে cheque এর তথ্যও)
  // ডানে  — Due এর আগে/পরে + যে purchase invoice গুলোতে টাকা বসেছে
  @override
  Widget build(BuildContext context) {
    final summary = payment.paymentSummary;
    final invoices = summary?.affectedInvoices ?? [];
    final String status = (summary?.status ?? '-').capitalize();
    final double amount = detailNum(payment.amount);
    final double dueBefore = detailNum(summary?.beforePayment?.totalDue);
    final double dueAfter = detailNum(summary?.afterPayment?.totalDue);
    final bool hasCheque = (payment.chequeNo?.toString() ?? '').isNotEmpty &&
        payment.chequeNo.toString() != 'null';

    return AppScaffold(
      appBar: detailAppBar(
        context,
        title: 'Supplier Payment ${payment.spNo ?? ''}',
        breadcrumb: const ['Supplier', 'Supplier Payment', 'Details'],
        actions: [
          PopoverButton(
            label: 'Payment PDF',
            primary: true,
            icon: Icons.print_outlined,
            onPressed: () => _generatePdf(context),
          ),
        ],
      ),
      body: SafeArea(
        child: DetailPageBody(
          hero: DetailHero(
            icon: Iconsax.money_send,
            title: payment.spNo ?? 'Supplier Payment',
            subtitle:
                '${payment.supplierName ?? '-'}  ·  ${_formatDate(payment.paymentDate)}',
            pills: [
              DetailPill(status, color: _getStatusColor(status)),
              if ((payment.paymentMethod ?? '').isNotEmpty)
                DetailPill(payment.paymentMethod!,
                    color: AppColors.info, icon: Icons.payments_outlined),
              if ((payment.paymentType ?? '').isNotEmpty)
                DetailPill(payment.paymentType!.capitalize(),
                    color: AppColors.greyColor(context),
                    icon: Icons.tune_rounded),
            ],
            amountLabel: 'Amount Paid',
            amount: '৳${amount.toStringAsFixed(2)}',
            amountColor: AppColors.success,
            amountCaption: dueAfter > 0
                ? 'Still due ৳${dueAfter.toStringAsFixed(2)}'
                : 'Supplier fully paid',
            amountCaptionColor:
                dueAfter > 0 ? AppColors.danger : AppColors.success,
          ),
          left: [
            DetailSection(
              title: 'Payment Information',
              icon: Iconsax.info_circle,
              child: DetailGrid(items: [
                DetailItem('Supplier', payment.supplierName,
                    icon: Iconsax.truck),
                DetailItem('Phone', payment.supplierPhone, icon: Iconsax.call),
                DetailItem('Payment Date', _formatDate(payment.paymentDate),
                    icon: Iconsax.calendar_1),
                DetailItem('Payment Method', payment.paymentMethod,
                    icon: Iconsax.wallet_2),
                DetailItem('Prepared By', payment.preparedByName,
                    icon: Iconsax.user_tick),
                DetailItem('Purchase Invoice',
                    payment.purchaseInvoiceNo?.toString(),
                    icon: Iconsax.receipt_2),
                if ((payment.remark?.toString() ?? '').isNotEmpty &&
                    payment.remark.toString() != 'null')
                  DetailItem('Remark', payment.remark.toString(),
                      icon: Iconsax.note_text, fullWidth: true),
              ]),
            ),
            if (hasCheque)
              DetailSection(
                title: 'Cheque',
                icon: Iconsax.card,
                child: DetailGrid(items: [
                  DetailItem('Cheque No', payment.chequeNo?.toString()),
                  DetailItem('Bank', payment.bankName?.toString()),
                  DetailItem('Cheque Date', _formatDate(payment.chequeDate)),
                  DetailItem('Status', payment.chequeStatus?.toString()),
                ]),
              ),
          ],
          right: [
            DetailSection(
              title: 'Due Summary',
              icon: Iconsax.calculator,
              child: DetailAmountList(rows: [
                DetailAmount('Due before payment', dueBefore,
                    color: dueBefore > 0 ? AppColors.danger : null),
                DetailAmount('Payment applied',
                    detailNum(summary?.afterPayment?.paymentApplied),
                    negative: true),
                DetailAmount('Due after payment', dueAfter,
                    strong: true,
                    dividerBefore: true,
                    color: dueAfter > 0 ? AppColors.danger : AppColors.success),
              ]),
            ),
            DetailSection(
              title: 'Affected Invoices',
              icon: Iconsax.document_text,
              child: invoices.isEmpty
                  ? Text(
                      'This payment was not applied to a specific purchase.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.text(context).withValues(alpha: 0.55),
                      ),
                    )
                  : DetailAmountList(rows: [
                      for (final inv in invoices)
                        DetailAmount(inv.invoiceNo ?? '-',
                            detailNum(inv.amountApplied),
                            color: AppColors.success),
                    ]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    if (date is DateTime) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    if (date is String) {
      try {
        final parsedDate = DateTime.parse(date);
        return '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
      } catch (e) {
        return date;
      }
    }
    return '-';
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

  void _generatePdf(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Supplier Payment Receipt'),
            backgroundColor: AppColors.primaryColor(context),
            foregroundColor: Colors.white,
          ),
          body: PdfPreview(
            useActions: true,
            allowSharing: false,
            canDebug: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
            dynamicLayout: true,
            build: (format) => generateSupplierPaymentPdf(payment),
            pdfPreviewPageDecoration: BoxDecoration(color: AppColors.white),
            actionBarTheme: PdfActionBarTheme(
              backgroundColor: AppColors.primaryColor(context),
              iconColor: Colors.white,
              textStyle: const TextStyle(color: Colors.white),
            ),
            onPrinted: (context) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Supplier payment receipt printed successfully')),
              );
            },
            onShared: (context) {},
          ),
        ),
      ),
    );
  }
}