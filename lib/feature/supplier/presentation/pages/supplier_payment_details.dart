import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:printing/printing.dart';
import '/feature/supplier/presentation/pages/pdf/generate_supplier_payment.dart';
import '../../../../core/configs/configs.dart';
import '../../data/model/supplier_payment/suppler_payment_model.dart';


class SupplierPaymentDetailsScreen extends StatelessWidget {
  final SupplierPaymentModel payment;

  const SupplierPaymentDetailsScreen({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return AppScaffold(
      appBar: AppBar(
        title: Text('Supplier Payment - ${payment.spNo}',style: AppTextStyle.titleMedium(context),),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _generatePdf(context),
            tooltip: 'Generate PDF',
          ),
        ],
      ),
      body: SafeArea(child: isDesktop ? _buildDesktopView(context) : _buildMobileView(context,)),
    );
  }

  Widget _buildDesktopView(BuildContext context,) {
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
                _buildHeaderCard(context),
                const SizedBox(height: 8),
                _buildPaymentInfoCard(context,),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right Column - Summary and Affected Invoices
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildSummaryCard(context,),
                const SizedBox(height: 16),
                _buildAffectedInvoicesCard(context,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView(BuildContext context,) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeaderCard(context,),
          const SizedBox(height: 16),
          _buildPaymentInfoCard(context,),
          const SizedBox(height: 16),
          _buildSummaryCard(context,),
          const SizedBox(height: 16),
          _buildAffectedInvoicesCard(context,),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context,) {
    return Card(
      elevation: 0,
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
                    'Supplier Payment: ${payment.spNo}',
                    style:  TextStyle(
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
                    color: _getStatusColor(payment.paymentSummary?.status ?? '').withValues(alpha: 0.1),
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
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 3,
      children: [
        _buildInfoItem('Payment No', payment.spNo ?? '-',context),
        _buildInfoItem('Payment Date', _formatDate(payment.paymentDate),context),
        _buildInfoItem('Supplier', payment.supplierName ?? '-',context),
        _buildInfoItem('Prepared By', payment.preparedByName ?? '-',context),
        _buildInfoItem('Payment Method', payment.paymentMethod ?? '-',context),
        _buildInfoItem('Payment Type', payment.paymentType ?? '-',context),
        if (payment.supplierPhone != null)
          _buildInfoItem('Phone', payment.supplierPhone!,context),
        if (payment.purchaseInvoiceNo != null)
          _buildInfoItem('Purchase Invoice', payment.purchaseInvoiceNo!,context),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value,BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:  TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style:  TextStyle(
            fontSize: 14,
            color: AppColors.text(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfoCard(BuildContext context,) {
    final amount = double.tryParse(payment.amount ?? '0') ?? 0;

    return Card(
      elevation: 0,
      color: AppColors.bottomNavBg(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Payment Information',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.text(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildPaymentDetails(context,amount),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails(BuildContext context,double amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBg(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          _buildPaymentRow(context,'Amount Paid', '৳${amount.toStringAsFixed(2)}', isAmount: true),
          const SizedBox(height: 8),
          _buildPaymentRow(context,'Payment Method', payment.paymentMethod ?? '-'),
          _buildPaymentRow(context,'Payment Type', payment.paymentType ?? '-'),
          if (payment.paymentDate != null)
            _buildPaymentRow(context,'Payment Date', _formatDate(payment.paymentDate)),
          if (payment.chequeNo != null)
            _buildPaymentRow(context,'Cheque No', payment.chequeNo!),
          if (payment.chequeDate != null)
            _buildPaymentRow(context,'Cheque Date', _formatDate(payment.chequeDate)),
          if (payment.bankName != null)
            _buildPaymentRow(context,'Bank Name', payment.bankName!),
          if (payment.remark != null && payment.remark!.isNotEmpty)
            _buildPaymentRow(context,'Remarks', payment.remark!),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(BuildContext context,String label, String value, {bool isAmount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.text(context),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
            fontSize: isAmount ? 16 : 14,
            color: isAmount ? AppColors.primaryColor(context) :AppColors.text(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context,) {
    final summary = payment.paymentSummary;
    final before = summary?.beforePayment;
    final after = summary?.afterPayment;

    return Card(
      elevation: 0,      color: AppColors.bottomNavBg(context),

      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.text(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (before != null) _buildSummarySection(context,'Before Payment', before),
            if (after != null) _buildSummarySection(context,'After Payment', after),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context,String title, dynamic paymentData) {
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
            style:  TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor(context),
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

  Widget _buildAffectedInvoicesCard(BuildContext context,) {
    final affectedInvoices = payment.paymentSummary?.affectedInvoices ?? [];

    return Card(
      elevation: 0,
      color: AppColors.bottomNavBg(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Affected Purchase Invoices',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.text(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (affectedInvoices.isEmpty)
               Center(
                child: Text(
                  'No affected purchase invoices',
                  style: TextStyle(color: AppColors.text(context),),
                ),
              ),
            if (affectedInvoices.isNotEmpty)
              ...affectedInvoices.map((invoice) => _buildInvoiceRow(context,invoice)),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(BuildContext context,AffectedInvoice invoice) {
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
              style:  TextStyle(fontWeight: FontWeight.w500,color: AppColors.text(context)),
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
            build: (format) => generateSupplierPaymentPdf(payment),
            pdfPreviewPageDecoration: BoxDecoration(color: AppColors.white),
            actionBarTheme: PdfActionBarTheme(
              backgroundColor: AppColors.primaryColor(context),
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