// sales_details_screen.dart

import 'package:meherinMart/core/widgets/app_scaffold.dart';
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
    return AppScaffold(
      appBar: detailAppBar(
        context,
        title: 'Sale ${sale.invoiceNo ?? ''}',
        breadcrumb: const ['Sales', 'Sale List', 'Details'],
        actions: [
          PopoverButton(
            label: 'Invoice PDF',
            primary: true,
            icon: Iconsax.document_download,
            onPressed: () => _generatePdf(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Responsive(
          mobile: _buildMobileView(context),
          tablet: _buildMobileView(context),
          desktop: _buildDesktopView(context),
        ),
      ),
    );
  }

  void _generatePdf(BuildContext context) {
    // print("object")
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("Sales Invoice", style: AppTextStyle.titleMedium(context)),
          ),
          backgroundColor: AppColors.bottomNavBg(context),
          body: PdfPreview.builder(
            useActions: true,
            allowSharing: false,
            canDebug: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
            dynamicLayout: true,
            build: (format) => generateSalesPdf(
              sale,
              context.read<ProfileBloc>().permissionModel?.data?.businessInfo,
            ),
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

  // ===================== MOBILE VIEW =====================
  Widget _buildMobileView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildMobileHeaderCard(context),
          const SizedBox(height: 6),

          // Status & Invoice Info
          Card(
            elevation: 0,
            color: AppColors.bottomNavBg(context),

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
                              color: AppColors.text(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sale.invoiceNo ?? "",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor(context),
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
                          sale.paymentStatus??"N/A".toUpperCase(),
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
                  const Divider(),
                  const SizedBox(height: 4),
                  _buildMobileInfoGrid(context),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Items Section
          _buildMobileItemsCard(context),

          const SizedBox(height: 8),

          // Summary Section
          _buildMobileSummaryCard(context),

          const SizedBox(height: 8),

          // Payment Section
          _buildMobilePaymentCard(context),
        ],
      ),
    );
  }

  Widget _buildMobileHeaderCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.bottomNavBg(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: AppColors.primaryColor(context),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sale Details',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.text(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              sale.formattedSaleDate,
              style: TextStyle(fontSize: 14, color: AppColors.text(context)),
            ),
            Text(
              sale.formattedTime,
              style: TextStyle(fontSize: 14, color: AppColors.text(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileInfoGrid(BuildContext context) {
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
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  item['value']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.text(context),

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

  Widget _buildMobileItemsCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.bottomNavBg(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shopping_cart,
                  color: AppColors.primaryColor(context),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text(context),
                  ),
                ),
                const Spacer(),
                Text(
                  '${sale.items?.length ?? 0} items',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.text(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (sale.items == null || sale.items!.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No items found',
                    style: TextStyle(color: AppColors.text(context)),
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
                      color: AppColors.bottomNavBg(context),
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
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.text(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Qty: ${item.quantityWithUnit}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.text(context),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '৳${unitPrice.toStringAsFixed(2)} each',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.text(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '৳${subtotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.text(context),

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

  Widget _buildMobileSummaryCard(BuildContext context) {
    final grossTotal = toDouble(sale.grossTotal);
    final netTotal = toDouble(sale.netTotal);
    final grandTotal = toDouble(sale.grandTotal);
    final discount = toDouble(sale.overallDiscount);

    // Try multiple property names for charges
    final delivery = toDouble(sale.overallDeliveryCharge) ;
    final service = toDouble(sale.overallServiceCharge);
    final vat = toDouble(sale.overallVatAmount);

    return Card(
      elevation: 0,
      color: AppColors.bottomNavBg(context),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate,
                  color: AppColors.primaryColor(context),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.text(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _mobileSummaryRow(context, 'Gross Total', grossTotal),

            // Always show discount row
            _mobileSummaryRow(
              context,
              'Discount',
              -discount,
              isNegative: true,
            ),

            // Always show delivery charge row
            _mobileSummaryRow(
              context,
              'Delivery Charge',
              delivery,
            ),

            // Always show service charge row
            _mobileSummaryRow(
              context,
              'Service Charge',
              service,
            ),

            // Always show VAT row
            _mobileSummaryRow(context, 'VAT', vat),

            const Divider(height: 16),
            _mobileSummaryRow(context, 'Net Total', netTotal, isBold: true),
            const SizedBox(height: 8),
            _mobileSummaryRow(
              context,
              'Grand Total',
              grandTotal,
              isBold: true,
              isHighlighted: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileSummaryRow(
      BuildContext context,
      String label,
      double value, {
        bool isNegative = false,
        bool isBold = false,
        bool isHighlighted = false,
      }) {
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
              color: isHighlighted
                  ? AppColors.primaryColor(context)
                  : AppColors.text(context),
            ),
          ),
          Text(
            '${isNegative && value > 0 ? '-' : ''}৳${value.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted
                  ? AppColors.primaryColor(context)
                  : isNegative && value > 0
                  ? AppColors.danger
                  : AppColors.text(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilePaymentCard(BuildContext context) {
    final payable = toDouble(sale.payableAmount);
    final paid = toDouble(sale.paidAmount);
    final due = sale.calculatedDueAmount;
    final isDue = due > 0;

    return Card(
      elevation: 0,
      color: AppColors.bottomNavBg(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isDue ? Icons.payment : Icons.check_circle,
                  color: isDue ? AppColors.warning : AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Payment Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDue
                        ? Colors.orange.shade800
                        : Colors.green.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bottomNavBg(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDue ? Colors.orange.shade200 : Colors.green.shade200,
                ),
              ),
              child: Column(
                children: [
                  _mobilePaymentRow(context, 'Payable', payable),
                  const SizedBox(height: 8),
                  _mobilePaymentRow(context, 'Paid', paid),
                  const SizedBox(height: 8),
                  _mobilePaymentRow(
                    context,
                    isDue ? 'Due Amount' : 'Advance',
                    due.abs(),
                    color: isDue ? AppColors.danger : AppColors.success,
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

  Widget _mobilePaymentRow(
      BuildContext context,
      String label,
      double amount, {
        Color? color,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.text(context),
          ),
        ),
        Text(
          '৳${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.primaryColor(context),
          ),
        ),
      ],
    );
  }

  // ===================== DESKTOP VIEW =====================
  // ===================== DESKTOP VIEW =====================
  // সব details page এর মতো একই কাঠামো (app_detail_kit):
  //   hero — invoice নম্বর, status, তারিখ; ডানে Grand Total ও বাকি
  //   বাঁয়ে — Sale information + Items
  //   ডানে  — Amount summary + Payment
  Widget _buildDesktopView(BuildContext context) {
    final double grand = toDouble(sale.grandTotal);
    final double payable = toDouble(sale.payableAmount);
    final double paid = toDouble(sale.paidAmount);
    final double due = sale.calculatedDueAmount;
    final String status =
        (sale.paymentStatus ?? sale.paymentStatusText).capitalize();

    final lines = (sale.items ?? []).map((item) {
      final double unit = toDouble(item.unitPrice);
      final double total = toDouble(item.subtotal);
      // আগে qty "0.0" দেখাত — sale_quantity খালি এলে base_quantity
      // নেওয়া হয়, তাও না থাকলে total ÷ দাম থেকে হিসাব
      double qty = item.actualQuantity;
      if (qty == 0 && unit > 0) qty = total / unit;
      final disc = toDouble(item.discount);
      return DetailLine(
        name: item.productName ?? 'Unknown product',
        subtitle: [
          if ((item.productSku ?? '').isNotEmpty) item.productSku!,
          if ((item.saleModeName ?? '').isNotEmpty) item.saleModeName!,
        ].join('  ·  '),
        qty: detailQty(qty),
        unitPrice: unit,
        discount: disc > 0
            ? (item.discountType == 'percentage' || item.discountType == 'percent'
                ? '${detailQty(disc)}%'
                : '৳${disc.toStringAsFixed(2)}')
            : null,
        total: total,
      );
    }).toList();

    return DetailPageBody(
      hero: DetailHero(
        icon: Iconsax.receipt_2,
        title: sale.invoiceNo ?? 'Sale',
        subtitle:
            '${sale.customerName ?? 'Walk-in Customer'}  ·  ${sale.formattedSaleDate}  ${sale.formattedTime}',
        pills: [
          DetailPill(status, color: sale.statusColor),
          if ((sale.paymentMethod ?? '').isNotEmpty)
            DetailPill(sale.paymentMethod!,
                color: AppColors.info, icon: Icons.payments_outlined),
          DetailPill('${lines.length} item${lines.length == 1 ? '' : 's'}',
              color: AppColors.greyColor(context),
              icon: Icons.shopping_bag_outlined),
        ],
        amountLabel: 'Grand Total',
        amount: '৳${grand.toStringAsFixed(2)}',
        amountCaption: due > 0
            ? 'Due ৳${due.toStringAsFixed(2)}'
            : (due < 0 ? 'Advance ৳${due.abs().toStringAsFixed(2)}' : 'Fully paid'),
        amountCaptionColor: due > 0 ? AppColors.danger : AppColors.success,
      ),
      left: [
        DetailSection(
          title: 'Sale Information',
          icon: Iconsax.info_circle,
          child: DetailGrid(items: [
            DetailItem('Customer', sale.customerName ?? 'Walk-in Customer',
                icon: Iconsax.user),
            DetailItem('Sale Date',
                '${sale.formattedSaleDate}  ${sale.formattedTime}',
                icon: Iconsax.calendar_1),
            DetailItem('Sales Person', sale.saleByName, icon: Iconsax.user_tick),
            DetailItem('Created By', sale.createdByName, icon: Iconsax.edit_2),
            DetailItem('Payment Method', sale.paymentMethod,
                icon: Iconsax.wallet_2),
            DetailItem('Account', sale.accountName, icon: Iconsax.bank),
            if ((sale.remark ?? '').isNotEmpty)
              DetailItem('Remark', sale.remark,
                  icon: Iconsax.note_text, fullWidth: true),
          ]),
        ),
        DetailSection(
          title: 'Items',
          icon: Iconsax.shopping_bag,
          padding: const EdgeInsets.all(12),
          child: DetailItemsTable(rows: lines, emptyText: 'No items found'),
        ),
      ],
      right: [
        DetailSection(
          title: 'Amount Summary',
          icon: Iconsax.calculator,
          child: DetailAmountList(rows: [
            DetailAmount('Gross Total', toDouble(sale.grossTotal)),
            DetailAmount('Discount', toDouble(sale.overallDiscount),
                negative: true, hideIfZero: true),
            DetailAmount('VAT', toDouble(sale.overallVatAmount), hideIfZero: true),
            DetailAmount('Service Charge', toDouble(sale.overallServiceCharge),
                hideIfZero: true),
            DetailAmount('Delivery Charge', toDouble(sale.overallDeliveryCharge),
                hideIfZero: true),
            DetailAmount('Net Total', toDouble(sale.netTotal), dividerBefore: true),
            DetailAmount('Grand Total', grand,
                strong: true, color: AppColors.primaryColor(context)),
          ]),
        ),
        DetailSection(
          title: 'Payment',
          icon: Iconsax.money_recive,
          child: DetailAmountList(rows: [
            DetailAmount('Payable', payable),
            DetailAmount('Paid', paid, color: AppColors.success),
            DetailAmount(
              due > 0 ? 'Due' : 'Advance',
              due.abs(),
              strong: true,
              dividerBefore: true,
              color: due > 0 ? AppColors.danger : AppColors.success,
            ),
          ]),
        ),
      ],
    );
  }
}
