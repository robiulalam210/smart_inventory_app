import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:printing/printing.dart';
import '../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '/feature/money_receipt/presentation/shared/pdf/generate_money_receipt.dart';
import '../../../../core/configs/configs.dart';
import '../../data/model/money_receipt_model/money_receipt_model.dart';

class MoneyReceiptDetailsScreen extends StatelessWidget {
  final MoneyreceiptModel receipt;

  const MoneyReceiptDetailsScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: detailAppBar(
        context,
        title: 'Money Receipt ${receipt.mrNo ?? ''}',
        breadcrumb: const ['Money Receipt', 'Details'],
        actions: [
          PopoverButton(
            label: 'Receipt PDF',
            primary: true,
            icon: Iconsax.document_download,
            onPressed: () => _generatePdf(context),
          ),
        ],
      ),
      body: Responsive(
        mobile: _buildMobileView(context ,),
        tablet: _buildTabletView(context ,),
        smallDesktop: _buildDesktopView(context ,),
        desktop: _buildDesktopView(context ,),
        maxDesktop: _buildDesktopView(context ,),
      ),
    );
  }

  // ===================== MOBILE VIEW (< 600px) =====================
  Widget _buildMobileView(BuildContext context ,) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          _buildMobileHeaderCard(context),
          const SizedBox(height: 8),

          // Payment Info Card
          _buildMobilePaymentInfoCard(context ,),

          const SizedBox(height: 8),

          // Summary Card
          _buildMobileSummaryCard(context ,),

          const SizedBox(height: 8),

          // Affected Invoices Card
          _buildMobileAffectedInvoicesCard(context ,),
        ],
      ),
    );
  }

  // ===================== TABLET VIEW (600px - 900px) =====================
  Widget _buildTabletView(BuildContext context ,) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row - Header & Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTabletHeaderCard(context ,),
              ),
              const SizedBox(width: 16),
              _buildTabletStatusCard(),
            ],
          ),

          const SizedBox(height: 20),

          // Payment Info Card
          _buildTabletPaymentInfoCard(),

          const SizedBox(height: 20),

          // Bottom Row - Summary & Invoices
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTabletSummaryCard(context ,),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTabletAffectedInvoicesCard(context ,),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== DESKTOP VIEW (900px+) =====================
  // ===================== DESKTOP VIEW =====================
  // hero — MR নম্বর, status, গ্রাহক; ডানে প্রাপ্ত টাকা
  // বাঁয়ে — Receipt information + Payment এর আগে/পরে পাশাপাশি
  // ডানে  — যে invoice গুলোতে টাকা বসেছে
  // (আগে "Payment Information" card এ একই তথ্য দ্বিতীয়বার দেখাত)
  Widget _buildDesktopView(BuildContext context ,) {
    final summary = receipt.paymentSummary;
    final before = summary?.beforePayment;
    final after = summary?.afterPayment;
    final invoices = summary?.affectedInvoices ?? [];
    final String status = (summary?.status ?? '-').capitalize();
    final double amount = detailNum(receipt.amount);
    final double dueAfter = detailNum(after?.currentDue);
    final String customer =
        (receipt.customerName ?? '').trim().isEmpty ? 'Walk-in Customer' : receipt.customerName!;

    return DetailPageBody(
      hero: DetailHero(
        icon: Iconsax.receipt_1,
        title: receipt.mrNo ?? 'Money Receipt',
        subtitle: '$customer  ·  ${_formatDate(receipt.paymentDate)}',
        pills: [
          DetailPill(status, color: _getStatusColor(status)),
          if ((receipt.paymentMethod ?? '').isNotEmpty)
            DetailPill(receipt.paymentMethod!,
                color: AppColors.info, icon: Icons.payments_outlined),
          if ((receipt.paymentType ?? '').isNotEmpty)
            DetailPill(receipt.paymentType!.capitalize(),
                color: AppColors.greyColor(context),
                icon: Icons.tune_rounded),
        ],
        amountLabel: 'Amount Received',
        amount: '৳${amount.toStringAsFixed(2)}',
        amountColor: AppColors.success,
        amountCaption: dueAfter > 0
            ? 'Remaining due ৳${dueAfter.toStringAsFixed(2)}'
            : 'No due remaining',
        amountCaptionColor: dueAfter > 0 ? AppColors.danger : AppColors.success,
      ),
      left: [
        DetailSection(
          title: 'Receipt Information',
          icon: Iconsax.info_circle,
          child: DetailGrid(items: [
            DetailItem('Customer', customer, icon: Iconsax.user),
            DetailItem('Phone', receipt.customerPhone?.toString(),
                icon: Iconsax.call),
            DetailItem('Payment Date', _formatDate(receipt.paymentDate),
                icon: Iconsax.calendar_1),
            DetailItem('Collected By', receipt.sellerName,
                icon: Iconsax.user_tick),
            DetailItem('Payment Method', receipt.paymentMethod,
                icon: Iconsax.wallet_2),
            DetailItem('Invoice No',
                receipt.saleInvoiceNo ?? summary?.invoiceNo,
                icon: Iconsax.receipt_2),
            if ((receipt.remark ?? '').isNotEmpty)
              DetailItem('Remark', receipt.remark,
                  icon: Iconsax.note_text, fullWidth: true),
          ]),
        ),
        LayoutBuilder(builder: (context, c) {
          final beforeCard = DetailSection(
            title: 'Before Payment',
            icon: Iconsax.clock,
            child: DetailAmountList(rows: [
              DetailAmount('Invoice Total', detailNum(before?.invoiceTotal)),
              DetailAmount('Previous Paid', detailNum(before?.previousPaid),
                  color: AppColors.success),
              DetailAmount('Previous Due', detailNum(before?.previousDue),
                  color: AppColors.danger),
              DetailAmount('Total Due', detailNum(before?.totalDue),
                  strong: true, dividerBefore: true),
            ]),
          );
          final afterCard = DetailSection(
            title: 'After Payment',
            icon: Iconsax.tick_circle,
            child: DetailAmountList(rows: [
              DetailAmount('Payment Applied', detailNum(after?.paymentApplied),
                  color: AppColors.success),
              DetailAmount('Current Paid', detailNum(after?.currentPaid)),
              DetailAmount('Current Due', detailNum(after?.currentDue),
                  color: dueAfter > 0 ? AppColors.danger : null),
              DetailAmount('Total Due', detailNum(after?.totalDue),
                  strong: true, dividerBefore: true),
            ]),
          );
          if (c.maxWidth < 560) {
            return Column(children: [beforeCard, afterCard]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: beforeCard),
              const SizedBox(width: 16),
              Expanded(child: afterCard),
            ],
          );
        }),
      ],
      right: [
        DetailSection(
          title: 'Affected Invoices',
          icon: Iconsax.document_text,
          child: invoices.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'This payment was not applied to any other invoice.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.text(context).withValues(alpha: 0.55),
                    ),
                  ),
                )
              : DetailAmountList(rows: [
                  for (final inv in invoices)
                    DetailAmount(inv.invoiceNo ?? '-',
                        detailNum(inv.amountApplied),
                        color: AppColors.success),
                  DetailAmount(
                    'Total Applied',
                    invoices.fold(
                        0.0, (s, inv) => s + detailNum(inv.amountApplied)),
                    strong: true,
                    dividerBefore: true,
                  ),
                ]),
        ),
      ],
    );
  }

  // ===================== MOBILE COMPONENTS =====================
  Widget _buildMobileHeaderCard(BuildContext context ,) {
    final amount = double.tryParse(receipt.amount ?? '0') ?? 0;

    return Card(
      elevation: 0,
      color: AppColors.bottomNavBg(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receipt #${receipt.mrNo}',
                        style:  TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(receipt.paymentDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.text(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(receipt.paymentSummary?.status ?? '').withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(receipt.paymentSummary?.status ?? '')),
                  ),
                  child: Text(
                    (receipt.paymentSummary?.status ?? 'UNKNOWN').toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(receipt.paymentSummary?.status ?? ''),
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
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha:0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    'Amount Received',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text(context),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '৳${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
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

  Widget _buildMobileInfoGrid(BuildContext context) {
    final List<Map<String, String?>> infoItems = [
      {'label': 'Customer', 'value': receipt.customerName ?? '-'},
      {'label': 'Seller', 'value': receipt.sellerName ?? '-'},
      {'label': 'Payment Method', 'value': receipt.paymentMethod ?? '-'},
      {'label': 'Payment Type', 'value': receipt.paymentType ?? '-'},
      if (receipt.customerPhone != null)
        {'label': 'Phone', 'value': receipt.customerPhone.toString()},
      if (receipt.saleInvoiceNo != null)
        {'label': 'Invoice No', 'value': receipt.saleInvoiceNo!},
    ];

    return Column(
      children: infoItems.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
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
                  style:  TextStyle(
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

  Widget _buildMobilePaymentInfoCard(BuildContext context ,) {
    final amount = double.tryParse(receipt.amount ?? '0') ?? 0;

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
                Icon(Icons.payment, color: AppColors.primaryColor(context), size: 20),
                const SizedBox(width: 8),
                 Text(
                  'Payment Information',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.text(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _buildMobilePaymentDetails(amount,context),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePaymentDetails(double amount,BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          _buildMobilePaymentRow(context,'Amount', '৳${amount.toStringAsFixed(2)}', isAmount: true),
          const SizedBox(height: 4),
          _buildMobilePaymentRow(context,'Method', receipt.paymentMethod ?? '-'),
          const SizedBox(height: 4),
          _buildMobilePaymentRow(context,'Type', receipt.paymentType ?? '-'),
          const SizedBox(height: 4),
          if (receipt.paymentDate != null)
            _buildMobilePaymentRow(context,'Date', _formatDate(receipt.paymentDate)),
          if (receipt.remark != null && receipt.remark!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildMobilePaymentRow(context,'Remarks', receipt.remark!),
          ],
        ],
      ),
    );
  }

  Widget _buildMobilePaymentRow(BuildContext context,String label, String value, {bool isAmount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color:AppColors.text(context),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isAmount ? 18 : 14,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
              color: isAmount ? AppColors.success : AppColors.text(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSummaryCard(BuildContext context ,) {
    final summary = receipt.paymentSummary;
    final before = summary?.beforePayment;
    final after = summary?.afterPayment;

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
                Icon(Icons.summarize, color: AppColors.primaryColor(context), size: 20),
                const SizedBox(width: 8),
                 Text(
                  'Payment Summary',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.text(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (before != null) _buildMobileSummarySection(context ,'Before Payment', before),
            if (after != null) _buildMobileSummarySection(context ,'After Payment', after),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileSummarySection(context ,String title, dynamic paymentData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color:       AppColors.greyColor(context).withValues(alpha: 0.5),width: 0.5
      ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.primaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          if (paymentData is BeforePayment) ...[
            _buildMobileSummaryRow(context,'Total Due', paymentData.totalDue),
            _buildMobileSummaryRow(context,'Invoice Total', paymentData.invoiceTotal),
            _buildMobileSummaryRow(context,'Previous Paid', paymentData.previousPaid),
            _buildMobileSummaryRow(context,'Previous Due', paymentData.previousDue),
          ] else if (paymentData is AfterPayment) ...[
            _buildMobileSummaryRow(context,'Total Due', paymentData.totalDue),
            _buildMobileSummaryRow(context,'Payment Applied', paymentData.paymentApplied),
            _buildMobileSummaryRow(context,'Current Paid', paymentData.currentPaid),
            _buildMobileSummaryRow(context,'Current Due', paymentData.currentDue),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileSummaryRow(BuildContext context,String label, dynamic value) {
    final amount = double.tryParse(value?.toString() ?? '0') ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:  TextStyle(
              fontSize: 13,
              color: AppColors.text(context),
            ),
          ),
          Text(
            '৳${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: amount < 0 ? AppColors.danger :AppColors.text(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileAffectedInvoicesCard(BuildContext context ,) {
    final affectedInvoices = receipt.paymentSummary?.affectedInvoices ?? [];

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
                Icon(Icons.receipt, color: AppColors.primaryColor(context), size: 20),
                const SizedBox(width: 8),
                 Text(
                  'Affected Invoices',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.text(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${affectedInvoices.length} invoice(s)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.text(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (affectedInvoices.isEmpty)
               Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No affected invoices',
                    style: TextStyle(color: AppColors.text(context)),
                  ),
                ),
              ),
            if (affectedInvoices.isNotEmpty)
              ...affectedInvoices.map((invoice) => _buildMobileInvoiceRow(context ,invoice)),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileInvoiceRow(BuildContext context ,AffectedInvoice invoice) {
    final amount = double.tryParse(invoice.amountApplied?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.invoiceNo ?? 'Unknown Invoice',
                  style:  TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text(context),
                    fontSize: 14,
                  ),
                ),
              //   const SizedBox(height: 4),
              //   if (invoice.paymentDate != null)
              //     Text(
              //       _formatDate(invoice.paymentDate),
              //       style: TextStyle(
              //         fontSize: 12,
              //         color: Colors.grey[600],
              //       ),
              //     ),
              ],
            ),
          ),
          Text(
            '৳${amount.toStringAsFixed(2)}',
            style:  TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== TABLET COMPONENTS =====================
  Widget _buildTabletHeaderCard(BuildContext context ,) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Money Receipt: ${receipt.mrNo}',
              style:  TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${_formatDate(receipt.paymentDate)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            _buildTabletInfoGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletStatusCard() {
    return Card(
      elevation: 3,
      color: _getStatusColor(receipt.paymentSummary?.status ?? '').withValues(alpha:0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Status',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(receipt.paymentSummary?.status ?? '').withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getStatusColor(receipt.paymentSummary?.status ?? '')),
              ),
              child: Text(
                (receipt.paymentSummary?.status ?? 'UNKNOWN').toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(receipt.paymentSummary?.status ?? ''),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletInfoGrid() {
    final List<Map<String, String?>> infoItems = [
      {'label': 'Customer', 'value': receipt.customerName ?? '-'},
      {'label': 'Seller', 'value': receipt.sellerName ?? '-'},
      {'label': 'Payment Method', 'value': receipt.paymentMethod ?? '-'},
      {'label': 'Payment Type', 'value': receipt.paymentType ?? '-'},
      if (receipt.customerPhone != null)
        {'label': 'Phone', 'value': receipt.customerPhone.toString()},
      if (receipt.saleInvoiceNo != null)
        {'label': 'Invoice No', 'value': receipt.saleInvoiceNo!},
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 12,
      children: infoItems.map((item) {
        return SizedBox(
          width: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['label']!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['value']!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabletPaymentInfoCard() {
    final amount = double.tryParse(receipt.amount ?? '0') ?? 0;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  _buildTabletPaymentRow('Amount Received', '৳${amount.toStringAsFixed(2)}', isAmount: true),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTabletPaymentRow('Payment Method', receipt.paymentMethod ?? '-'),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildTabletPaymentRow('Payment Type', receipt.paymentType ?? '-'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTabletPaymentRow('Payment Date', _formatDate(receipt.paymentDate)),
                  if (receipt.remark != null && receipt.remark!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildTabletPaymentRow('Remarks', receipt.remark!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletPaymentRow(String label, String value, {bool isAmount = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isAmount ? 20 : 15,
            fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
            color: isAmount ? AppColors.success : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTabletSummaryCard(BuildContext context ,) {
    final summary = receipt.paymentSummary;
    final before = summary?.beforePayment;
    final after = summary?.afterPayment;

    return Card(
      elevation: 3,
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
            if (before != null) _buildTabletSummarySection(context ,'Before Payment', before),
            if (after != null) _buildTabletSummarySection(context ,'After Payment', after),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletSummarySection(BuildContext context ,String title, dynamic paymentData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:  TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.primaryColor(context),
            ),
          ),
          const SizedBox(height: 12),
          if (paymentData is BeforePayment) ...[
            _buildTabletSummaryRow('Total Due', paymentData.totalDue),
            _buildTabletSummaryRow('Invoice Total', paymentData.invoiceTotal),
            _buildTabletSummaryRow('Previous Paid', paymentData.previousPaid),
            _buildTabletSummaryRow('Previous Due', paymentData.previousDue),
          ] else if (paymentData is AfterPayment) ...[
            _buildTabletSummaryRow('Total Due', paymentData.totalDue),
            _buildTabletSummaryRow('Payment Applied', paymentData.paymentApplied),
            _buildTabletSummaryRow('Current Paid', paymentData.currentPaid),
            _buildTabletSummaryRow('Current Due', paymentData.currentDue),
          ],
        ],
      ),
    );
  }

  Widget _buildTabletSummaryRow(String label, dynamic value) {
    final amount = double.tryParse(value?.toString() ?? '0') ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          Text(
            '৳${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: amount < 0 ? AppColors.danger : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletAffectedInvoicesCard(BuildContext context ,) {
    final affectedInvoices = receipt.paymentSummary?.affectedInvoices ?? [];

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Affected Invoices',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${affectedInvoices.length} invoice(s)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            if (affectedInvoices.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No affected invoices',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            if (affectedInvoices.isNotEmpty)
              ...affectedInvoices.map((invoice) => _buildTabletInvoiceRow(context ,invoice)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletInvoiceRow(BuildContext context ,AffectedInvoice invoice) {
    final amount = double.tryParse(invoice.amountApplied?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.invoiceNo ?? 'Unknown Invoice',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                // if (invoice. != null)
                //   Text(
                //     _formatDate(invoice.paymentDate),
                //     style: TextStyle(
                //       fontSize: 13,
                //       color: Colors.grey[600],
                //     ),
                //   ),
              ],
            ),
          ),
          Text(
            '৳${amount.toStringAsFixed(2)}',
            style:  TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
            backgroundColor: AppColors.bottomNavBg(context),

            title:  Text('Money Receipt Preview',style: AppTextStyle.titleMedium(context),),
            foregroundColor: Colors.white,
          ),
          body: PdfPreview(
            useActions: true,
            allowSharing: false,
            canDebug: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
            dynamicLayout: true,
            build: (format) => generateMoneyReceiptPdf(receipt, context.read<ProfileBloc>().permissionModel?.data?.companyInfo),

            pdfPreviewPageDecoration: BoxDecoration(color: AppColors.greyColor(context)),
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

            onPrinted: (context) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Money receipt printed successfully')),
              );
            },
            onShared: (context) {},
          ),
        ),
      ),
    );
  }
}