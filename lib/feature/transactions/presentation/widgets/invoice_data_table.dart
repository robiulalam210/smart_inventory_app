import '../../../../core/configs/configs.dart';
import '../../../feature.dart';

class InvoiceDataTable extends StatelessWidget {
  final List<InvoiceModelSync> invoices;
  final ScrollController verticalScrollController;
  final ScrollController horizontalScrollController;
  final Function(InvoiceModelSync) onViewDetails;
  final Function(InvoiceModelSync, double, double) onCollectPayment;

  const InvoiceDataTable({
    super.key,
    required this.invoices,
    required this.verticalScrollController,
    required this.horizontalScrollController,
    required this.onViewDetails,
    required this.onCollectPayment,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        const int numColumns = 14;
        const double minColumnWidth = 50;

        final double dynamicColumnWidth =
            (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Scrollbar(
            controller: verticalScrollController,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 10,
            child: SingleChildScrollView(
              controller: verticalScrollController,
              scrollDirection: Axis.vertical,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Scrollbar(
                  controller: horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ConstrainedBox(
                        // <-- Set minWidth larger than viewport width to enable horizontal scroll
                        constraints: BoxConstraints(
                          minWidth: constraints.minWidth,
                          // OR fixed width: minWidth: 1400,
                        ),
                        child: DataTable(
                          dataRowMinHeight: 40,
                          // headingRowHeight: 40,
                          columnSpacing: 0,
                          checkboxHorizontalMargin: 0,
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          headingRowColor:
                              WidgetStateProperty.all(Color(0xFF6ab129)),
                          columns: _buildDataColumns(dynamicColumnWidth),
                          rows: invoices
                              .map((invoice) => _buildDataRow(
                                  context, invoice, dynamicColumnWidth))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildDataColumns(double columnWidth) {
    const columnLabels = [
      'Invoice',
      'Date',
      'Name',
      'Total Amount',
      'Discount',
      'Net Amount',
      'Received Amount',
      'Refund Amount',
      'Due',
      'Visit Type',
      'P. Method',
      "Action"
    ];

    return columnLabels.map((label) {
      return DataColumn(
        label: Container(
          width: columnWidth,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Center(
              child: Text(
                label,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                maxLines: 2,
                softWrap: true,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  DataRow _buildDataRow(
      BuildContext context, InvoiceModelSync invoice, double columnWidth) {
    final paymentMethod = invoice.payments.isNotEmpty
        ? _formatPaymentMethod(invoice.payments.first.paymentType ?? "")
        : 'N/A';

    final discount = double.tryParse(invoice.discount.toString()) ?? 0.0;
    final total = invoice.totalBillAmount ?? 0.0;

    final netAmount = (total - discount).toStringAsFixed(2);

    return DataRow(
      cells: [
        _buildDataCell(invoice.invoiceNumber.toString(), columnWidth),
        _buildDataCell(appWidgets.formatStringDDMMYY(invoice.createDate), columnWidth),
        _buildDataCell(invoice.patient.name ?? "", columnWidth),
        _buildDataCell(
            (invoice.totalBillAmount ?? 0.0).toStringAsFixed(2), columnWidth),
        _buildDataCell(
            (invoice.discount ?? 0.0).toStringAsFixed(2), columnWidth),
        _buildDataCell(netAmount, columnWidth),
        _buildDataCell((invoice.paidAmount.toString()), columnWidth),
        _buildDataCell(
          (invoice.netAmountAfterRefund ?? 0.0).toStringAsFixed(0),
          columnWidth,
        ),
        _buildDataCell((invoice.due ?? 0.0).toStringAsFixed(2), columnWidth,
            isDue: true),
        _buildDataCell(invoice.patient.visitType ?? "", columnWidth),
        _buildDataCell(paymentMethod, columnWidth),
        _buildPrintRefundCell(context, invoice, columnWidth),
      ],
    );
  }
  DataCell _buildDataCell(String text, double columnWidth, {bool isDue = false}) {
    final amount = isDue ? double.tryParse(text) ?? 0 : 0;

    return DataCell(
      SizedBox(
        width: columnWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: SelectableText(
            text,
            style: TextStyle(
              fontSize: 10,
              color: isDue && amount > 0 ? Colors.red : Colors.black,
              fontWeight: isDue && amount > 0 ? FontWeight.w500 : null,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,   // wraps up to 3 lines
            minLines: 1,   // keep single-line if short
          ),
        ),
      ),
    );
  }



  DataCell _buildPrintRefundCell(
      BuildContext context, InvoiceModelSync invoice, double columnWidth) {
    return DataCell(
      SizedBox(
        width: columnWidth *1.5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: 'Print',
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(HugeIcons.strokeRoundedPrinter, size: 20),
                onPressed: () {
                  final transactionBloc = context.read<TransactionBloc>();
                  transactionBloc.add(LoadInvoiceTransactionDetails(
                      invoice.invoiceNumber.toString(),
                      context,
                      true));
                  transactionBloc.add(
                      LoadTransactionInvoices(pageSize: 20, pageNumber: 1));
                },
              ),
            ),
            Tooltip(
              message: 'View Details',
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(HugeIcons.strokeRoundedFileView, size: 20),
                onPressed: () => onViewDetails(invoice),
              ),
            ),
            // Tooltip(
            //   message: 'Refund',
            //   child: IconButton(
            //     padding: EdgeInsets.zero,
            //     icon: const Icon(HugeIcons.strokeRoundedPayment02, size: 20),
            //     onPressed: () {},
            //   ),
            // ),
            if (invoice.due! > 0)
              Tooltip(
                message: 'Collect Payment',
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.money_off, size: 20),
                  onPressed: () => onCollectPayment(
                      invoice, invoice.due ?? 0, invoice.paidAmount ?? 0),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Card';
      case 'online':
        return 'Online';
      default:
        return method;
    }
  }


}
