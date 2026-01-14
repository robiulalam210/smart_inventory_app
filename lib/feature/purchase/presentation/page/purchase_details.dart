import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:printing/printing.dart';
import '../../../../core/configs/configs.dart';
import '../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '../../data/model/purchase_sale_model.dart';
import 'pdf/generate_purchase_pdf.dart';

class PurchaseDetailsScreen extends StatelessWidget {
  final PurchaseModel purchase;

  const PurchaseDetailsScreen({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Purchase Details - ${purchase.invoiceNo}',
          style: AppTextStyle.titleMedium(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _generatePdf(context),
            tooltip: 'Generate PDF',
          ),
        ],
      ),
      body: isDesktop ? _buildDesktopView(context) : _buildMobileView(context),
    );
  }

  Widget _buildDesktopView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column - Header and Items
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildHeaderCard(context),
                const SizedBox(height: 16),
                _buildItemsCard(context),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right Column - Summary and Payment
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildSummaryCard(context),
                const SizedBox(height: 16),
                _buildPaymentCard(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildHeaderCard(context),
          const SizedBox(height: 8),
          _buildItemsCard(context),
          const SizedBox(height: 8),
          _buildSummaryCard(context),
          const SizedBox(height: 8),
          _buildPaymentCard(context),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      elevation: 3,
      color: AppColors.bottomNavBg(context),

      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Purchase Invoice: ${purchase.invoiceNo}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor(context),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      purchase.paymentStatus ?? '',
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatusColor(purchase.paymentStatus ?? ''),
                    ),
                  ),
                  child: Text(
                    (purchase.paymentStatus ?? 'UNKNOWN').toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(purchase.paymentStatus ?? ''),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDesktopInfoGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopInfoGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 12,
      childAspectRatio: 3,
      children: [
        _buildInfoItem(
          'Purchase Date',
          AppWidgets().convertDateTimeDDMMYYYY(purchase.purchaseDate),
          context,
        ),
        _buildInfoItem('Invoice No', purchase.invoiceNo ?? '-', context),
        _buildInfoItem('Supplier', purchase.supplierName ?? '-', context),
        _buildInfoItem(
          'Payment Method',
          purchase.paymentMethod ?? '-',
          context,
        ),
        if (purchase.accountName != null)
          _buildInfoItem('Account', purchase.accountName!, context),
        if (purchase.remark != null && purchase.remark != '')
          _buildInfoItem('Remarks', purchase.remark.toString(), context),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text(context),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsCard(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Purchase Items',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.text(context),

                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (purchase.items == null || purchase.items!.isEmpty)
              const Center(
                child: Text(
                  'No items found',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            if (purchase.items != null && purchase.items!.isNotEmpty)
              _buildItemsTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(1.9),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(1.6),
        },
        border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey.shade300),
        ),
        children: [
          // Header row
          TableRow(
            decoration: BoxDecoration(
              color: AppColors.primaryColor(context).withValues(alpha: 0.1),
            ),
            children: [
              _buildTableHeaderCell(context, 'Product'),
              _buildTableHeaderCell(context, 'Qty'),
              _buildTableHeaderCell(context, 'Price'),
              _buildTableHeaderCell(context, 'Discount'),
              _buildTableHeaderCell(context, 'Total'),
            ],
          ),
          // Data rows
          ...purchase.items!.map((item) => _buildTableRow(item, context)),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(context, String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor(context),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildTableRow(PurchaseItem item, BuildContext context) {
    final price = item.price is String
        ? double.tryParse(item.price!) ?? 0.0
        : (item.price ?? 0.0);
    final total = item.productTotal is String
        ? double.tryParse(item.productTotal!) ?? 0.0
        : (item.productTotal ?? 0.0);

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            item.productName ?? 'Unknown Product',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.text(context),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            item.qty?.toString() ?? '0',
            textAlign: TextAlign.center,
            style: AppTextStyle.body(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            '৳${price.toString()}',
            textAlign: TextAlign.center,
            style: AppTextStyle.body(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            item.discount != null && item.discount != "0"
                ? '${item.discount}${item.discountType == 'percent' ? '%' : '৳'}'
                : '-',
            textAlign: TextAlign.center,
            style: AppTextStyle.body(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            '৳${total.toString()}',
            textAlign: TextAlign.center,
            style: AppTextStyle.body(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final total = double.tryParse(purchase.total.toString()) ?? 0.0;
    final grandTotal = double.tryParse(purchase.grandTotal.toString()) ?? 0.0;
    final subTotal = double.tryParse(purchase.subTotal.toString()) ?? 0.0;

    return Card(
      elevation: 1,
      color: AppColors.bottomNavBg(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Purchase Summary',
              style: TextStyle(fontSize: 16,

                  color: AppColors.text(context),

                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDesktopSummaryList(context, subTotal, total, grandTotal),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSummaryList(
    BuildContext context,
    double subTotal,
    double total,
    double grandTotal,
  ) {
    return Column(
      children: [
        if (subTotal > 0) _buildSummaryItem(context, 'Sub Total', subTotal),
        if (purchase.overallDiscount != null && purchase.overallDiscount != "0")
          _buildSummaryItem(
            context,
            'Discount ${purchase.overallDiscountType == 'percent' ? '(${purchase.overallDiscount}%)' : ''}',
            -double.parse(purchase.overallDiscount ?? '0'),
            isNegative: true,
          ),
        if (purchase.overallDeliveryCharge != null &&
            purchase.overallDeliveryCharge != "0")
          _buildSummaryItem(
            context,
            'Delivery Charge',
            double.parse(purchase.overallDeliveryCharge ?? '0'),
          ),
        if (purchase.overallServiceCharge != null &&
            purchase.overallServiceCharge != "0")
          _buildSummaryItem(
            context,
            'Service Charge',
            double.parse(purchase.overallServiceCharge ?? '0'),
          ),
        if (purchase.vat != null && purchase.vat != "0")
          _buildSummaryItem(
            context,
            'VAT ${purchase.vatType == 'percent' ? '(${purchase.vat}%)' : ''}',
            double.parse(purchase.vat ?? '0'),
          ),
        const Divider(),
        if (total > 0)
          _buildSummaryItem(context, 'Total', total, isTotal: true),
        _buildSummaryItem(
          context,
          'Grand Total',
          grandTotal,
          isGrandTotal: true,
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double amount, {
    bool isNegative = false,
    bool isTotal = false,
    bool isGrandTotal = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal || isGrandTotal
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: isGrandTotal
                    ? AppColors.primaryColor(context)
                    : AppColors.text(context),
                fontSize: isGrandTotal ? 15 : 14,
              ),
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}৳${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal || isGrandTotal
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isGrandTotal
                  ? AppColors.primaryColor(context)
                  : AppColors.text(context),
              fontSize: isGrandTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context) {
    final paid = double.tryParse(purchase.paidAmount.toString()) ?? 0.0;
    final due = double.tryParse(purchase.dueAmount.toString()) ?? 0.0;
    final change = double.tryParse(purchase.changeAmount.toString()) ?? 0.0;

    return Card(
      elevation: 1,
      color: AppColors.bottomNavBg(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Payment Summary',
              style: TextStyle(fontSize: 18,
                  color: AppColors.primaryColor(context),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildPaymentItem(context,'Paid Amount', paid),
            _buildPaymentItem(context,'Due Amount', due, isDue: due > 0),
            if (change > 0)
              _buildPaymentItem(context,'Change Amount', change, isChange: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItem(
      BuildContext  context,
    String label,
    double amount, {
    bool isDue = false,
    bool isChange = false,
  }) {
    Color color = AppColors.text(context);
    if (isDue) color = Colors.red;
    if (isChange) color = Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style:  TextStyle(fontWeight: FontWeight.w500,color: AppColors.text(context))),
          Text(
            '৳${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'partial':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
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
