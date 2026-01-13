// sales_details_screen.dart

import 'package:printing/printing.dart';

import '../../../../core/configs/configs.dart';
import '../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
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
        title: Text('Sale Details', style: const TextStyle(fontSize: 16)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.print, size: 22),
            tooltip: 'Generate PDF',
            onPressed: () => _generatePdf(context),
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildMobileView(),
        tablet: _buildMobileView(),
        desktop:_buildDesktopView() ,

      ),
    );
  }

  void _generatePdf(BuildContext context) {
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
              context.read<ProfileBloc>().permissionModel?.data?.companyInfo,
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
  }

  // ===================== MOBILE VIEW =====================
  Widget _buildMobileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildMobileHeaderCard(),
          const SizedBox(height: 16),

          // Status & Invoice Info
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice #',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sale.invoiceNo??"",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
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
                          color: sale.statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
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
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildMobileInfoGrid(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Items Section
          _buildMobileItemsCard(),

          const SizedBox(height: 16),

          // Summary Section
          _buildMobileSummaryCard(),

          const SizedBox(height: 16),

          // Payment Section
          _buildMobilePaymentCard(),
        ],
      ),
    );
  }

  Widget _buildMobileHeaderCard() {
    return Card(
      elevation: 3,
      color: AppColors.primaryColor.withValues(alpha:0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long,
                    color: AppColors.primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Sale Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              sale.formattedSaleDate,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              sale.formattedTime,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileInfoGrid() {
    final List<Map<String, String>> infoItems = [
      {'label': 'Customer', 'value': sale.customerName ?? 'Walk-in Customer'},
      {'label': 'Sales Person', 'value': sale.saleByName ?? 'N/A'},
      {'label': 'Created By', 'value': sale.createdByName ?? 'N/A'},
      {'label': 'Payment Method', 'value': sale.paymentMethod ?? 'Cash'},
      if (sale.accountName != null)
        {'label': 'Account', 'value': sale.accountName!},
    ];

    return Column(
      children: infoItems.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  item['label']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  item['value']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileItemsCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart,
                    color: AppColors.primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${sale.items?.length ?? 0} items',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (sale.items == null || sale.items!.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No items found',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                children: sale.items!.map((item) {
                  final unitPrice = toDouble(item.unitPrice);
                  final subtotal = toDouble(item.subtotal);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName ?? 'Unknown Product',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Qty: ${item.quantity ?? 0}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '৳${unitPrice.toStringAsFixed(2)} each',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '৳${subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileSummaryCard() {
    final grossTotal = toDouble(sale.grossTotal);
    final netTotal = toDouble(sale.netTotal);
    final grandTotal = toDouble(sale.grandTotal);
    final discount = toDouble(sale.overallDiscount);
    final delivery = toDouble(sale.overallDeliveryCharge);
    final service = toDouble(sale.overallServiceCharge);
    final vat = toDouble(sale.overallVatAmount);

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate,
                    color: AppColors.primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _mobileSummaryRow('Gross Total', grossTotal),
            if (discount > 0)
              _mobileSummaryRow('Discount', -discount, isNegative: true),
            if (delivery > 0)
              _mobileSummaryRow('Delivery Charge', delivery),
            if (service > 0)
              _mobileSummaryRow('Service Charge', service),
            if (vat > 0)
              _mobileSummaryRow('VAT', vat),
            const Divider(height: 24),
            _mobileSummaryRow('Net Total', netTotal, isBold: true),
            const SizedBox(height: 8),
            _mobileSummaryRow('Grand Total', grandTotal,
                isBold: true, isHighlighted: true),
          ],
        ),
      ),
    );
  }

  Widget _mobileSummaryRow(String label, double value,
      {bool isNegative = false,
        bool isBold = false,
        bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? AppColors.primaryColor : Colors.black,
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}৳${value.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? AppColors.primaryColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilePaymentCard() {
    final payable = toDouble(sale.payableAmount);
    final paid = toDouble(sale.paidAmount);
    final due = sale.calculatedDueAmount;
    final isDue = due > 0;

    return Card(
      elevation: 3,
      color: isDue ? Colors.orange.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isDue ? Icons.payment : Icons.check_circle,
                  color: isDue ? Colors.orange : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Payment Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDue ? Colors.orange.shade800 : Colors.green.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDue ? Colors.orange.shade200 : Colors.green.shade200,
                ),
              ),
              child: Column(
                children: [
                  _mobilePaymentRow('Payable', payable),
                  const SizedBox(height: 8),
                  _mobilePaymentRow('Paid', paid),
                  const SizedBox(height: 8),
                  _mobilePaymentRow(
                    isDue ? 'Due Amount' : 'Advance',
                    due.abs(),
                    color: isDue ? Colors.red : Colors.green,
                  ),
                ],
              ),
            ),
            if (isDue)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange.shade600, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Payment pending',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _mobilePaymentRow(String label, double amount, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          '৳${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  // ===================== DESKTOP VIEW (unchanged) =====================
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
                color: sale.statusColor.withValues(alpha:0.1),
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
              color: AppColors.primaryColor.withValues(alpha:0.1)),
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

  TableRow _buildTableRow(PosSaleItem item) {
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