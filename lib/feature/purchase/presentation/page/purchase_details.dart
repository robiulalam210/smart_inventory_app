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

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Purchase Details - ${purchase.invoiceNo}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _generatePdf(context),
            tooltip: 'Generate PDF',
          ),
        ],
      ),
      body: isDesktop ? _buildDesktopView() : _buildMobileView(),
    );
  }

  Widget _buildDesktopView() {
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
                _buildHeaderCard(),
                const SizedBox(height: 16),
                _buildItemsCard(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right Column - Summary and Payment
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 16),
                _buildPaymentCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildItemsCard(),
          const SizedBox(height: 16),
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildPaymentCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 3,
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(purchase.paymentStatus ?? '').withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getStatusColor(purchase.paymentStatus ?? '')),
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
            const SizedBox(height: 16),
            _buildDesktopInfoGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopInfoGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 12,
      childAspectRatio: 3,
      children: [
        _buildInfoItem('Purchase Date', AppWidgets().convertDateTimeDDMMYYYY(purchase.purchaseDate)),
        _buildInfoItem('Invoice No', purchase.invoiceNo ?? '-'),
        _buildInfoItem('Supplier', purchase.supplierName ?? '-'),
        _buildInfoItem('Payment Method', purchase.paymentMethod ?? '-'),
        if (purchase.accountName != null)
          _buildInfoItem('Account', purchase.accountName!),
        if (purchase.remark != null && purchase.remark != '')
          _buildInfoItem('Remarks', purchase.remark.toString()),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Purchase Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (purchase.items == null || purchase.items!.isEmpty)
              const Center(
                child: Text(
                  'No items found',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            if (purchase.items != null && purchase.items!.isNotEmpty)
              _buildItemsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(4),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(1.5),
        },
        border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey.shade300),
        ),
        children: [
          // Header row
          TableRow(
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
            ),
            children: [
              _buildTableHeaderCell('Product'),
              _buildTableHeaderCell('Qty'),
              _buildTableHeaderCell('Price'),
              _buildTableHeaderCell('Discount'),
              _buildTableHeaderCell('Total'),
            ],
          ),
          // Data rows
          ...purchase.items!.map((item) => _buildTableRow(item)),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildTableRow(PurchaseItem item) {
    final price = item.price is String
        ? double.tryParse(item.price!) ?? 0.0
        : (item.price ?? 0.0);
    final total = item.productTotal is String
        ? double.tryParse(item.productTotal!) ?? 0.0
        : (item.productTotal ?? 0.0);

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            item.productName ?? 'Unknown Product',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            item.qty?.toString() ?? '0',
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            '৳${price.toString()}',
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            item.discount != null && item.discount != "0"
                ? '${item.discount}${item.discountType == 'percent' ? '%' : '৳'}'
                : '-',
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            '৳${total.toString()}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final total = double.tryParse(purchase.total.toString()) ?? 0.0
       ;
    final grandTotal = double.tryParse(purchase.grandTotal.toString()) ?? 0.0
       ;
    final subTotal = double.tryParse(purchase.subTotal.toString()) ?? 0.0
       ;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Purchase Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDesktopSummaryList(
              subTotal,
              total,
              grandTotal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSummaryList(
      double subTotal,
      double total,
      double grandTotal,
      ) {
    return Column(
      children: [
        if (subTotal > 0) _buildSummaryItem('Sub Total', subTotal),
        if (purchase.overallDiscount != null && purchase.overallDiscount != "0")
          _buildSummaryItem(
            'Discount ${purchase.overallDiscountType == 'percent' ? '(${purchase.overallDiscount}%)' : ''}',
            -double.parse(purchase.overallDiscount ?? '0'),
            isNegative: true,
          ),
        if (purchase.overallDeliveryCharge != null && purchase.overallDeliveryCharge != "0")
          _buildSummaryItem(
            'Delivery Charge',
            double.parse(purchase.overallDeliveryCharge ?? '0'),
          ),
        if (purchase.overallServiceCharge != null && purchase.overallServiceCharge != "0")
          _buildSummaryItem(
            'Service Charge',
            double.parse(purchase.overallServiceCharge ?? '0'),
          ),
        if (purchase.vat != null && purchase.vat != "0")
          _buildSummaryItem(
            'VAT ${purchase.vatType == 'percent' ? '(${purchase.vat}%)' : ''}',
            double.parse(purchase.vat ?? '0'),
          ),
        const Divider(),
        if (total > 0) _buildSummaryItem('Total', total, isTotal: true),
        _buildSummaryItem('Grand Total', grandTotal, isGrandTotal: true),
      ],
    );
  }

  Widget _buildSummaryItem(
      String label,
      double amount, {
        bool isNegative = false,
        bool isTotal = false,
        bool isGrandTotal = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
                color: isGrandTotal ? AppColors.primaryColor : Colors.black,
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
              color: isGrandTotal ? AppColors.primaryColor : Colors.black,
              fontSize: isGrandTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    final paid = double.tryParse(purchase.paidAmount.toString()) ?? 0.0
       ;
    final due =  double.tryParse(purchase.dueAmount.toString()) ?? 0.0
       ;
    final change =  double.tryParse(purchase.changeAmount.toString()) ?? 0.0
        ;

    return Card(
      elevation: 3,
      color: due > 0 ? Colors.orange.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentItem('Paid Amount', paid),
            _buildPaymentItem(
              'Due Amount',
              due,
              isDue: due > 0,
            ),
            if (change > 0)
              _buildPaymentItem(
                'Change Amount',
                change,
                isChange: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItem(
      String label,
      double amount, {
        bool isDue = false,
        bool isChange = false,
      }) {
    Color color = Colors.black;
    if (isDue) color = Colors.red;
    if (isChange) color = Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
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
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: PdfPreview(
            useActions: true,
            allowSharing: false,
            canDebug: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
            dynamicLayout: true,
            build: (format) => generatePurchasePdf(purchase, context.read<ProfileBloc>().permissionModel?.data?.companyInfo),
            pdfPreviewPageDecoration: BoxDecoration(color: AppColors.white),
            actionBarTheme: PdfActionBarTheme(
              backgroundColor: AppColors.primaryColor,
              iconColor: Colors.white,
              textStyle: const TextStyle(color: Colors.white),
            ),
            onPrinted: (context) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Purchase invoice printed successfully')),
              );
            },
            onShared: (context) {},
          ),
        ),
      ),
    );
  }
}