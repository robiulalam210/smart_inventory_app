// sales_details_screen.dart

import 'package:printing/printing.dart';

import '../../../../core/configs/configs.dart';
import '../../data/models/pos_sale_model.dart';
import '../widgets/pdf/sales_invocei.dart';

class SalesDetailsScreen extends StatelessWidget {
  final PosSaleModel sale;

  const SalesDetailsScreen({super.key, required this.sale});

  // 🔥 SAFE CONVERTER (String / double / int → double)
  double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Sale Details - ${sale.invoiceNo}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Generate PDF',
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
          ),
        ],
      ),
      body: _buildDesktopView(),
    );
  }

  // ===================== DESKTOP VIEW =====================

  Widget _buildDesktopView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Column(children: [
            _buildHeaderCard(),
            _buildItemsCard(),
          ])),
          const SizedBox(width: 16),
          Expanded(flex: 1, child: Column(children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildPaymentCard(),
          ])),
        ],
      ),
    );
  }

  // ===================== HEADER =====================

  Widget _buildHeaderCard() {
    return Card(
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Text(
                'Invoice: ${sale.invoiceNo}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                    fontSize: 12),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          _buildDesktopInfoGrid(),
        ]),
      ),
    );
  }

  Widget _buildDesktopInfoGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey)),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    ]);
  }

  // ===================== ITEMS =====================

  Widget _buildItemsCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Items',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (sale.items == null || sale.items!.isEmpty)
            const Center(
                child:
                Text('No items found', style: TextStyle(color: Colors.grey)))
          else
            _buildItemsTable(),
        ]),
      ),
    );
  }

  Widget _buildItemsTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
      },
      border:
      TableBorder.symmetric(inside: BorderSide(color: Colors.grey.shade300)),
      children: [
        TableRow(
          decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1)),
          children: const [
            _TableHeader('Product'),
            _TableHeader('Qty'),
            _TableHeader('Price'),
            _TableHeader('Total'),
          ],
        ),
        ...sale.items!.map(_buildTableRow),
      ],
    );
  }

  TableRow _buildTableRow(Item item) {
    final unitPrice = toDouble(item.unitPrice);
    final subtotal = toDouble(item.subtotal);

    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(item.productName ?? 'Unknown Product'),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(item.quantity?.toString() ?? '0',
            textAlign: TextAlign.center),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child:
        Text('৳${unitPrice.toStringAsFixed(2)}', textAlign: TextAlign.center),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text('৳${subtotal.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    ]);
  }

  // ===================== SUMMARY =====================

  Widget _buildSummaryCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          _buildDesktopSummaryList(),
        ]),
      ),
    );
  }

  Widget _buildDesktopSummaryList() {
    final grossTotal = toDouble(sale.grossTotal);
    final netTotal = toDouble(sale.netTotal);
    final grandTotal = toDouble(sale.grandTotal);

    final discount = toDouble(sale.overallDiscount);
    final delivery = toDouble(sale.overallDeliveryCharge);
    final service = toDouble(sale.overallServiceCharge);
    final vat = toDouble(sale.overallVatAmount);

    return Column(children: [
      _summaryRow('Gross Total', grossTotal),
      if (discount > 0) _summaryRow('Discount', -discount, negative: true),
      if (delivery > 0) _summaryRow('Delivery Charge', delivery),
      if (service > 0) _summaryRow('Service Charge', service),
      if (vat > 0) _summaryRow('VAT', vat),
      const Divider(),
      _summaryRow('Net Total', netTotal, bold: true),
      _summaryRow('Grand Total', grandTotal,
          bold: true, highlight: true),
    ]);
  }

  Widget _summaryRow(String label, double value,
      {bool negative = false, bool bold = false, bool highlight = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: highlight ? AppColors.primaryColor : Colors.black)),
      Text(
        '${negative ? '-' : ''}৳${value.abs().toStringAsFixed(2)}',
        style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: highlight ? AppColors.primaryColor : Colors.black),
      ),
    ]);
  }

  // ===================== PAYMENT =====================

  Widget _buildPaymentCard() {
    final payable = toDouble(sale.payableAmount);
    final paid = toDouble(sale.paidAmount);
    final due = sale.calculatedDueAmount;

    return Card(
      elevation: 3,
      color: due > 0 ? Colors.orange.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Payment Summary',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          _paymentRow('Payable', payable),
          _paymentRow('Paid', paid),
          _paymentRow(due > 0 ? 'Due' : 'Advance', due.abs(),
              color: due > 0 ? Colors.red : Colors.green),
        ]),
      ),
    );
  }

  Widget _paymentRow(String label, double amount,
      {Color color = Colors.black}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label),
      Text('৳${amount.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.bold, color: color)),
    ]);
  }
}

// ===================== SMALL HELPER =====================

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor)),
    );
  }
}
