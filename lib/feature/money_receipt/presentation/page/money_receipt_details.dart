import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:printing/printing.dart';
import '../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import '/feature/money_receipt/presentation/page/pdf/generate_money_receipt.dart';
import '../../../../core/configs/configs.dart';
import '../../data/model/money_receipt_model/money_receipt_model.dart';

class MoneyReceiptDetailsScreen extends StatelessWidget {
  final MoneyreceiptModel receipt;

  const MoneyReceiptDetailsScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Money Receipt', style: AppTextStyle.titleMedium(context)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.document_download, size: 22),
            onPressed: () => _generatePdf(context),
            tooltip: 'Generate PDF',
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
  Widget _buildDesktopView(BuildContext context ,) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column - Header and Payment Info
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildDesktopHeaderCard(context ,),
                const SizedBox(height: 16),
                _buildDesktopPaymentInfoCard(context ,),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right Column - Summary and Affected Invoices
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildDesktopSummaryCard(context ,),
                const SizedBox(height: 16),
                _buildDesktopAffectedInvoicesCard(context ,),
              ],
            ),
          ),
        ],
      ),
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
                color: Colors.green.withValues(alpha:0.05),
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
                      color: Colors.green,
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
              color: isAmount ? Colors.green : AppColors.text(context),
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
              color: amount < 0 ? Colors.red :AppColors.text(context),
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
            color: isAmount ? Colors.green : Colors.black,
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
              color: amount < 0 ? Colors.red : Colors.black,
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

  // ===================== DESKTOP COMPONENTS (unchanged) =====================
  Widget _buildDesktopHeaderCard(BuildContext context ,) {
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
                    'Money Receipt: ${receipt.mrNo}',
                    style:  TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor(context),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(receipt.paymentSummary?.status ?? '').withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(16),
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
        _buildInfoItem('MR No', receipt.mrNo ?? '-'),
        _buildInfoItem('Payment Date', _formatDate(receipt.paymentDate)),
        _buildInfoItem('Customer', receipt.customerName ?? '-'),
        _buildInfoItem('Seller', receipt.sellerName ?? '-'),
        _buildInfoItem('Payment Method', receipt.paymentMethod ?? '-'),
        _buildInfoItem('Payment Type', receipt.paymentType ?? '-'),
        if (receipt.customerPhone != null)
          _buildInfoItem('Phone', receipt.customerPhone.toString()),
        if (receipt.saleInvoiceNo != null)
          _buildInfoItem('Invoice No', receipt.saleInvoiceNo!),
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
        const SizedBox(height: 2),
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

  Widget _buildDesktopPaymentInfoCard(BuildContext context ,) {
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
            _buildPaymentDetails(context ,amount),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails(BuildContext context ,double amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          _buildPaymentRow(context ,'Amount Received', '৳${amount.toStringAsFixed(2)}', isAmount: true),
          const SizedBox(height: 8),
          _buildPaymentRow(context ,'Payment Method', receipt.paymentMethod ?? '-'),
          _buildPaymentRow(context ,'Payment Type', receipt.paymentType ?? '-'),
          if (receipt.paymentDate != null)
            _buildPaymentRow(context ,'Payment Date', _formatDate(receipt.paymentDate)),
          if (receipt.remark != null && receipt.remark!.isNotEmpty)
            _buildPaymentRow(context ,'Remarks', receipt.remark!),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(BuildContext context ,String label, String value, {bool isAmount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
            fontSize: isAmount ? 16 : 14,
            color: isAmount ? AppColors.primaryColor(context) : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopSummaryCard(BuildContext context ,) {
    final summary = receipt.paymentSummary;
    final before = summary?.beforePayment;
    final after = summary?.afterPayment;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            if (before != null) _buildSummarySection(context ,'Before Payment', before),
            if (after != null) _buildSummarySection(context ,'After Payment', after),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context ,String title, dynamic paymentData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
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
              color: AppColors.primaryColor(context),
            ),
          ),
          const SizedBox(height: 4),
          if (paymentData is BeforePayment) ...[
            _buildSummaryRow('Total Due', paymentData.totalDue),
            _buildSummaryRow('Invoice Total', paymentData.invoiceTotal),
            _buildSummaryRow('Previous Paid', paymentData.previousPaid),
            _buildSummaryRow('Previous Due', paymentData.previousDue),
          ] else if (paymentData is AfterPayment) ...[
            _buildSummaryRow('Total Due', paymentData.totalDue),
            _buildSummaryRow('Payment Applied', paymentData.paymentApplied),
            _buildSummaryRow('Current Paid', paymentData.currentPaid),
            _buildSummaryRow('Current Due', paymentData.currentDue),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, dynamic value) {
    final amount = double.tryParse(value?.toString() ?? '0') ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            '৳${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: amount < 0 ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopAffectedInvoicesCard(BuildContext context ,) {
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            if (affectedInvoices.isEmpty)
              const Center(
                child: Text(
                  'No affected invoices',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            if (affectedInvoices.isNotEmpty)
              ...affectedInvoices.map((invoice) => _buildInvoiceRow(context ,invoice)),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(BuildContext context ,AffectedInvoice invoice) {
    final amount = double.tryParse(invoice.amountApplied?.toString() ?? '0') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              invoice.invoiceNo ?? 'Unknown Invoice',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '৳${amount.toStringAsFixed(2)}',
            style:  TextStyle(
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
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
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
                icon: const Icon(Icons.cancel, color: Colors.red),
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