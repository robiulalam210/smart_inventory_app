import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:printing/printing.dart';
import '../../../../core/configs/configs.dart';
import '../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '../../data/model/purchase_sale_model.dart';
import 'pdf/generate_purchase_pdf.dart';

class PurchaseDetailsScreen extends StatelessWidget {
  final PurchaseModel purchase;

  const PurchaseDetailsScreen({super.key, required this.purchase});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'partial':
        return AppColors.warning;
      case 'pending':
      case 'due':
        return AppColors.danger;
      default:
        return Colors.grey;
    }
  }

  /// percent হলে sub total এর উপর হিসাব করে টাকায় — আগে "10%"
  /// discount কে ৳10 হিসেবে দেখাত
  double _charge(String? value, String? type, double base) {
    final v = detailNum(value);
    final isPercent = type == 'percent' || type == 'percentage';
    return isPercent ? base * v / 100 : v;
  }

  String _label(String name, String? value, String? type) {
    final isPercent = type == 'percent' || type == 'percentage';
    return isPercent && detailNum(value) > 0
        ? '$name (${detailQty(detailNum(value))}%)'
        : name;
  }

  @override
  Widget build(BuildContext context) {
    final double grand = detailNum(purchase.grandTotal);
    final double paid = detailNum(purchase.paidAmount);
    final double due = detailNum(purchase.dueAmount);
    final double change = detailNum(purchase.changeAmount);
    final String status = (purchase.paymentStatus ?? '-').capitalize();

    final items = purchase.items ?? [];
    final double itemsTotal =
        items.fold(0.0, (s, it) => s + detailNum(it.productTotal));
    final double sub = detailNum(purchase.subTotal) > 0
        ? detailNum(purchase.subTotal)
        : itemsTotal;

    final lines = items.map((it) {
      final d = detailNum(it.discount);
      return DetailLine(
        name: it.productName ?? 'Unknown product',
        qty: '${it.qty ?? 0}',
        unitPrice: detailNum(it.price),
        discount: d > 0
            ? (it.discountType == 'percent' || it.discountType == 'percentage'
                ? '${detailQty(d)}%'
                : '৳${d.toStringAsFixed(2)}')
            : null,
        total: detailNum(it.productTotal),
      );
    }).toList();

    return AppScaffold(
      appBar: detailAppBar(
        context,
        title: 'Purchase ${purchase.invoiceNo ?? ''}',
        breadcrumb: const ['Purchase', 'Purchase List', 'Details'],
        actions: [
          PopoverButton(
            label: 'Purchase PDF',
            primary: true,
            icon: Iconsax.document_download,
            onPressed: () => _generatePdf(context),
          ),
        ],
      ),
      body: DetailPageBody(
        hero: DetailHero(
          icon: Iconsax.shopping_bag,
          title: purchase.invoiceNo ?? 'Purchase',
          subtitle:
              '${purchase.supplierName ?? '-'}  ·  ${AppWidgets().convertDateTimeDDMMYYYY(purchase.purchaseDate)}',
          pills: [
            DetailPill(status, color: _statusColor(status)),
            if ((purchase.paymentMethod ?? '').isNotEmpty)
              DetailPill(purchase.paymentMethod!,
                  color: AppColors.info, icon: Icons.payments_outlined),
            DetailPill('${lines.length} item${lines.length == 1 ? '' : 's'}',
                color: AppColors.greyColor(context),
                icon: Icons.inventory_2_outlined),
          ],
          amountLabel: 'Grand Total',
          amount: '৳${grand.toStringAsFixed(2)}',
          amountCaption:
              due > 0 ? 'Due ৳${due.toStringAsFixed(2)}' : 'Fully paid',
          amountCaptionColor: due > 0 ? AppColors.danger : AppColors.success,
        ),
        left: [
          DetailSection(
            title: 'Purchase Information',
            icon: Iconsax.info_circle,
            child: DetailGrid(items: [
              DetailItem('Supplier', purchase.supplierName,
                  icon: Iconsax.truck),
              DetailItem('Purchase Date',
                  AppWidgets().convertDateTimeDDMMYYYY(purchase.purchaseDate),
                  icon: Iconsax.calendar_1),
              DetailItem('Invoice No', purchase.invoiceNo,
                  icon: Iconsax.receipt_2),
              DetailItem('Payment Method', purchase.paymentMethod,
                  icon: Iconsax.wallet_2),
              DetailItem('Account', purchase.accountName, icon: Iconsax.bank),
              if ((purchase.remark?.toString() ?? '').isNotEmpty)
                DetailItem('Remark', purchase.remark?.toString(),
                    icon: Iconsax.note_text, fullWidth: true),
            ]),
          ),
          DetailSection(
            title: 'Items',
            icon: Iconsax.box,
            padding: const EdgeInsets.all(12),
            child: DetailItemsTable(rows: lines, emptyText: 'No items found'),
          ),
        ],
        right: [
          DetailSection(
            title: 'Amount Summary',
            icon: Iconsax.calculator,
            child: DetailAmountList(rows: [
              DetailAmount('Sub Total', sub),
              DetailAmount(
                  _label('Discount', purchase.overallDiscount,
                      purchase.overallDiscountType),
                  _charge(purchase.overallDiscount,
                      purchase.overallDiscountType, sub),
                  negative: true,
                  hideIfZero: true),
              DetailAmount(
                  _label('VAT', purchase.vat, purchase.vatType),
                  _charge(purchase.vat, purchase.vatType, sub),
                  hideIfZero: true),
              DetailAmount(
                  _label('Service Charge', purchase.overallServiceCharge,
                      purchase.overallServiceChargeType),
                  _charge(purchase.overallServiceCharge,
                      purchase.overallServiceChargeType, sub),
                  hideIfZero: true),
              DetailAmount(
                  _label('Delivery Charge', purchase.overallDeliveryCharge,
                      purchase.overallDeliveryChargeType),
                  _charge(purchase.overallDeliveryCharge,
                      purchase.overallDeliveryChargeType, sub),
                  hideIfZero: true),
              DetailAmount('Grand Total', grand,
                  strong: true,
                  dividerBefore: true,
                  color: AppColors.primaryColor(context)),
            ]),
          ),
          DetailSection(
            title: 'Payment',
            icon: Iconsax.money_send,
            child: DetailAmountList(rows: [
              DetailAmount('Paid', paid, color: AppColors.success),
              DetailAmount('Change', change, hideIfZero: true),
              DetailAmount('Due', due,
                  strong: true,
                  dividerBefore: true,
                  color: due > 0 ? AppColors.danger : AppColors.success),
            ]),
          ),
        ],
      ),
    );
  }

  void _generatePdf(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Purchase Invoice Preview'),
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
            build: (format) => generatePurchasePdf(
              purchase,
              context.read<ProfileBloc>().permissionModel?.data?.companyInfo,
            ),
            pdfPreviewPageDecoration: BoxDecoration(color: AppColors.white),
            actionBarTheme: PdfActionBarTheme(
              backgroundColor: AppColors.primaryColor(context),
              iconColor: Colors.white,
              textStyle: const TextStyle(color: Colors.white),
            ),
            onPrinted: (context) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Purchase invoice printed successfully'),
                ),
              );
            },
            onShared: (context) {},
          ),
        ),
      ),
    );
  }
}
