import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:meherin_mart/feature/supplier/presentation/pages/pdf/generate_supplier_payment.dart';
import '../../../../core/configs/configs.dart';
import '../../data/model/supplier_payment/suppler_payment_model.dart';


class SupplierPaymentDetailsScreen extends StatelessWidget {
  final SupplierPaymentModel payment;

  const SupplierPaymentDetailsScreen({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text('Supplier Payment - ${payment.spNo}'),
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
          // Left Column - Header and Payment Info
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 16),
                _buildPaymentInfoCard(),
              ],
            ),
          ),
          const SizedBox(width: 16),
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

  Widget _buildMobileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildPaymentInfoCard(),
          const SizedBox(height: 16),
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildAffectedInvoicesCard(),
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
                    'Supplier Payment: ${payment.spNo}',
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
                    color: _getStatusColor(payment.paymentSummary?.status ?? '').withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getStatusColor(payment.paymentSummary?.status ?? '')),
                  ),
                  child: Text(
                    (payment.paymentSummary?.status ?? 'UNKNOWN').toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(payment.paymentSummary?.status ?? ''),
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
      childAspectRatio: 4,
      children: [
        _buildInfoItem('Payment No', payment.spNo ?? '-'),
        _buildInfoItem('Payment Date', _formatDate(payment.paymentDate)),
        _buildInfoItem('Supplier', payment.supplierName ?? '-'),
        _buildInfoItem('Prepared By', payment.preparedByName ?? '-'),
        _buildInfoItem('Payment Method', payment.paymentMethod ?? '-'),
        _buildInfoItem('Payment Type', payment.paymentType ?? '-'),
        if (payment.supplierPhone != null)
          _buildInfoItem('Phone', payment.supplierPhone!),
        if (payment.purchaseInvoiceNo != null)
          _buildInfoItem('Purchase Invoice', payment.purchaseInvoiceNo!),
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

  Widget _buildPaymentInfoCard() {
    final amount = double.tryParse(payment.amount ?? '0') ?? 0;

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
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          _buildPaymentRow('Amount Paid', '৳${amount.toStringAsFixed(2)}', isAmount: true),
          const SizedBox(height: 8),
          _buildPaymentRow('Payment Method', payment.paymentMethod ?? '-'),
          _buildPaymentRow('Payment Type', payment.paymentType ?? '-'),
          if (payment.paymentDate != null)
            _buildPaymentRow('Payment Date', _formatDate(payment.paymentDate)),
          if (payment.chequeNo != null)
            _buildPaymentRow('Cheque No', payment.chequeNo!),
          if (payment.chequeDate != null)
            _buildPaymentRow('Cheque Date', _formatDate(payment.chequeDate)),
          if (payment.bankName != null)
            _buildPaymentRow('Bank Name', payment.bankName!),
          if (payment.remark != null && payment.remark!.isNotEmpty)
            _buildPaymentRow('Remarks', payment.remark!),
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
    final summary = payment.paymentSummary;
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
            if (before != null) _buildSummarySection('Before Payment', before),
            if (after != null) _buildSummarySection('After Payment', after),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(String title, dynamic paymentData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 8),
          if (paymentData is BeforePayment) ...[
            _buildSummaryRow('Total Due', paymentData.totalDue),
          ] else if (paymentData is AfterPayment) ...[
            _buildSummaryRow('Total Due', paymentData.totalDue),
            _buildSummaryRow('Payment Applied', paymentData.paymentApplied),
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
    final affectedInvoices = payment.paymentSummary?.affectedInvoices ?? [];

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Affected Purchase Invoices',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (affectedInvoices.isEmpty)
              const Center(
                child: Text(
                  'No affected purchase invoices',
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
      padding: const EdgeInsets.all(12),
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

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    if (date is DateTime) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    if (date is String) {
      try {
        final parsedDate = DateTime.parse(date);
        return '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
      } catch (e) {
        return date;
      }
    }
    return '-';
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
            title: const Text('Supplier Payment Receipt'),
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
            build: (format) => generateSupplierPaymentPdf(payment),
            pdfPreviewPageDecoration: BoxDecoration(color: AppColors.white),
            actionBarTheme: PdfActionBarTheme(
              backgroundColor: AppColors.primaryColor,
              iconColor: Colors.white,
              textStyle: const TextStyle(color: Colors.white),
            ),
            onPrinted: (context) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Supplier payment receipt printed successfully')),
              );
            },
            onShared: (context) {},
          ),
        ),
      ),
    );
  }
}