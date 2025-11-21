import 'package:printing/printing.dart';
import 'package:meherin_mart/feature/money_receipt/presentation/page/pdf/generate_money_receipt.dart';
import '../../../../core/configs/configs.dart';
import '../../data/model/money_receipt_model/money_receipt_model.dart';

class MoneyReceiptDetailsScreen extends StatelessWidget {
  final MoneyreceiptModel receipt;

  const MoneyReceiptDetailsScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Money Receipt - ${receipt.mrNo}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _generatePdf(context),
            tooltip: 'Generate PDF',
          ),
        ],
      ),
      body: _buildDesktopView(),
    );
  }

  Widget _buildDesktopView() {
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
                _buildHeaderCard(),
                // const SizedBox(height: 16),
                _buildPaymentInfoCard(),
              ],
            ),
          ),
          // const SizedBox(width: 16),
          // Right Column - Summary and Affected Invoices
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 16),
                _buildAffectedInvoicesCard(),
              ],
            ),
          ),
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
                    'Money Receipt: ${receipt.mrNo}',
                    style: const TextStyle(
                      fontSize: 16,
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
                    color: _getStatusColor(receipt.paymentSummary?.status ?? '').withOpacity(0.1),
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

  Widget _buildPaymentInfoCard() {
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
            _buildPaymentDetails(amount),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails(double amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          _buildPaymentRow('Amount Received', '৳${amount.toStringAsFixed(2)}', isAmount: true),
          const SizedBox(height: 8),
          _buildPaymentRow('Payment Method', receipt.paymentMethod ?? '-'),
          _buildPaymentRow('Payment Type', receipt.paymentType ?? '-'),
          if (receipt.paymentDate != null)
            _buildPaymentRow('Payment Date', _formatDate(receipt.paymentDate)),
          if (receipt.remark != null && receipt.remark!.isNotEmpty)
            _buildPaymentRow('Remarks', receipt.remark!),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isAmount = false}) {
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
            color: isAmount ? AppColors.primaryColor : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
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
            if (before != null) _buildSummarySection('Before Payment', before),
            if (after != null) _buildSummarySection('After Payment', after),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(String title, dynamic paymentData) {
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
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

  Widget _buildAffectedInvoicesCard() {
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
              ...affectedInvoices.map((invoice) => _buildInvoiceRow(invoice)),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(AffectedInvoice invoice) {
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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
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
            title: const Text('Money Receipt Preview'),
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
            build: (format) => generateMoneyReceiptPdf(receipt),
            pdfPreviewPageDecoration: BoxDecoration(color: AppColors.white),
            actionBarTheme: PdfActionBarTheme(
              backgroundColor: AppColors.primaryColor,
              iconColor: Colors.white,
              textStyle: const TextStyle(color: Colors.white),
            ),
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