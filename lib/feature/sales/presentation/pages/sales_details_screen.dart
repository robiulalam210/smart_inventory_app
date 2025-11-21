// sales_details_screen.dart

import 'package:printing/printing.dart';

import '../../../../core/configs/configs.dart';
import '../../data/models/pos_sale_model.dart';
import '../widgets/pdf/sales_invocei.dart';

class SalesDetailsScreen extends StatelessWidget {
  final PosSaleModel sale;

  const SalesDetailsScreen({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Sale Details - ${sale.invoiceNo}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    backgroundColor: Colors.red,
                    body: PdfPreview.builder(
                      useActions: true,
                      allowSharing: false,
                      canDebug: false,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      dynamicLayout: true,
                      build: (format) => generateSalesPdf(
                        sale,

                      ),
                      pdfPreviewPageDecoration:
                      BoxDecoration(color: AppColors.white),
                      actionBarTheme: PdfActionBarTheme(
                        backgroundColor: AppColors.primaryColor,
                        iconColor: Colors.white,
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () => AppRoutes.pop(context),
                          icon: const Icon(Icons.cancel, color: Colors.red),
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
            },
            tooltip: 'Generate PDF',
          ),
        ],
      ),
      body:  _buildDesktopView(),
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
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Invoice: ${sale.invoiceNo}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sale.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: sale.statusColor),
                  ),
                  child: Text(
                    sale.paymentStatus.toUpperCase(),
                    style: TextStyle(
                      color: sale.statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
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
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 5,
      children: [
        _buildInfoItem('Sale Date', sale.formattedSaleDate),
        _buildInfoItem('Sale Time', sale.formattedTime),
        _buildInfoItem('Customer', sale.customerName ?? 'Walk-in Customer'),
        _buildInfoItem('Sales Person', sale.saleByName ?? 'N/A'),
        _buildInfoItem('Created By', sale.createdByName ?? 'N/A'),
        _buildInfoItem('Payment Method', sale.paymentMethod ?? 'Cash'),
        if (sale.accountName != null)
          _buildInfoItem('Account', sale.accountName!),
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
              'Items',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            if (sale.items == null || sale.items!.isEmpty)
              const Center(
                child: Text(
                  'No items found',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            if (sale.items != null && sale.items!.isNotEmpty)
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
              _buildTableHeaderCell('Total'),
            ],
          ),
          // Data rows
          ...sale.items!.map((item) => _buildTableRow(item)),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
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

  TableRow _buildTableRow(Item item) {
    final unitPrice = item.unitPrice is String
        ? double.tryParse(item.unitPrice!) ?? 0.0
        : (item.unitPrice ?? 0.0).toDouble();
    final subtotal = item.subtotal is String
        ? double.tryParse(item.subtotal!) ?? 0.0
        : (item.subtotal ?? 0.0).toDouble();

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName ?? 'Unknown Product',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (item.discount != null && item.discount != "0")
                Text(
                  'Discount: ${item.discount}${item.discountType == 'percent' ? '%' : '৳'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            item.quantity?.toString() ?? '0',
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            '৳${unitPrice.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            '৳${subtotal.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final grossTotal = sale.grossTotal is String
        ? double.tryParse(sale.grossTotal!) ?? 0.0
        : (sale.grossTotal ?? 0.0).toDouble();
    final netTotal = sale.netTotal is String
        ? double.tryParse(sale.netTotal!) ?? 0.0
        : (sale.netTotal ?? 0.0).toDouble();
    final grandTotal = sale.grandTotal is String
        ? double.tryParse(sale.grandTotal!) ?? 0.0
        : (sale.grandTotal ?? 0.0).toDouble();

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            _buildDesktopSummaryList(
              grossTotal,
              netTotal,
              grandTotal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSummaryList(
      double grossTotal,
      double netTotal,
      double grandTotal,
      ) {
    return Column(
      children: [
        _buildSummaryItem('Gross Total', grossTotal),
        if (sale.overallDiscount != null && sale.overallDiscount != "0")
          _buildSummaryItem(
            'Discount ${sale.overallDiscountType == 'percent' ? '(${sale.overallDiscount}%)' : ''}',
            -double.parse(sale.overallDiscount ?? '0'),
            isNegative: true,
          ),
        if (sale.overallDeliveryCharge != null &&
            sale.overallDeliveryCharge != "0")
          _buildSummaryItem(
            'Delivery Charge',
            double.parse(sale.overallDeliveryCharge ?? '0'),
          ),
        if (sale.overallServiceCharge != null &&
            sale.overallServiceCharge != "0")
          _buildSummaryItem(
            'Service Charge',
            double.parse(sale.overallServiceCharge ?? '0'),
          ),
        if (sale.overallVatAmount != null && sale.overallVatAmount != "0")
          _buildSummaryItem(
            'VAT ${sale.overallVatType == 'percent' ? '(${sale.overallVatAmount}%)' : ''}',
            double.parse(sale.overallVatAmount ?? '0'),
          ),
        const Divider(),
        _buildSummaryItem('Net Total', netTotal, isTotal: true),
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
    final payable = sale.payableAmount is String
        ? double.tryParse(sale.payableAmount!) ?? 0.0
        : (sale.payableAmount ?? 0.0).toDouble();
    final paid = sale.paidAmount is String
        ? double.tryParse(sale.paidAmount!) ?? 0.0
        : (sale.paidAmount ?? 0.0).toDouble();
    final due = sale.calculatedDueAmount;

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
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            _buildPaymentItem('Payable Amount', payable),
            _buildPaymentItem('Paid Amount', paid),
            _buildPaymentItem(
              due > 0 ? 'Due Amount' : 'Advance Amount',
              due.abs(),
              isDue: due > 0,
              isAdvance: due < 0,
            ),
            if (sale.changeAmount != null &&
                double.parse(sale.changeAmount.toString()) > 0)
              _buildPaymentItem(
                'Change Amount',
                double.parse(sale.changeAmount.toString()),
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
        bool isAdvance = false,
      }) {
    Color color = Colors.black;
    if (isDue) color = Colors.red;
    if (isAdvance) color = Colors.green;

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

}