import 'package:intl/intl.dart';

import '../../../../core/configs/configs.dart';
import '../../../feature.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final String invoiceId;
  final InvoiceModelSync invoiceData;

  const InvoiceDetailsScreen({
    super.key,
    required this.invoiceId,
    required this.invoiceData,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.whiteColor,
      title: AppBar(
        backgroundColor: AppColors.whiteColor,
        title: Text('Invoice Details'),
      ),
      content: _buildInvoiceContent(invoiceData, invoiceData, context),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Indicate cancellation
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildInvoiceContent(
    InvoiceModelSync invoiceInfo,
    InvoiceModelSync testDetails,
    BuildContext c,
  ) {
    return SizedBox(
        width: 750,
        height: 500,
        child: SingleChildScrollView(
          primary: true,
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInvoiceHeader(invoiceInfo),
              const SizedBox(height: 10),
              _buildPatientInfo(invoiceInfo),
              const SizedBox(height: 10),
              _buildTestDetailsTable(testDetails, c),
              _buildPaymentDetailsTable(invoiceInfo.payments, c),
              const SizedBox(height: 10),
              _buildInvoiceSummary(invoiceInfo),
            ],
          ),
        ));
  }

  Widget _buildInvoiceHeader(InvoiceModelSync invoiceInfo) {
    final issuedDate = DateTime.tryParse(invoiceInfo.createDate.toString());
    final dueDate = DateTime.tryParse(invoiceInfo.createDate.toString());

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invoice #${invoiceInfo.invoiceNumber}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Status: ${_getInvoiceStatus(invoiceInfo)}',
                  style: TextStyle(
                    color: _getStatusColor(invoiceInfo),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Issued: ${issuedDate != null ? DateFormat('dd/MM/yyyy hh:mm a').format(issuedDate) : 'N/A'}'),
                Text(
                    'Due: ${dueDate != null ? DateFormat('dd/MM/yyyy hh:mm a').format(dueDate) : 'N/A'}'),
              ],
            ),
            Text(
              'Referred by : ${invoiceInfo.referInfo.name ?? (invoiceInfo.referInfo.type == "Other" ? invoiceInfo.referInfo.value : invoiceInfo.referInfo.type)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfo(InvoiceModelSync invoiceInfo) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow('Name', invoiceInfo.patient.name ?? ""),
                _buildInfoRow('Phone', invoiceInfo.patient.phone ?? ""),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow('Age',
                    "${invoiceInfo.patient.age ?? 0} Y ${invoiceInfo.patient.month ?? 0} M ${invoiceInfo.patient.day ?? 0} D"),
                _buildInfoRow('Gender', invoiceInfo.patient.gender ?? ""),
              ],
            ),
            _buildInfoRow('Blood Group', invoiceInfo.patient.bloodGroup ?? ""),
            _buildInfoRow('Address', invoiceInfo.patient.address ?? ""),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 140, child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTestDetailsTable(
      InvoiceModelSync testDetails, BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Test Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // TextButton(
                //     onPressed: () async {
                //       context.read<RefundBloc>().add(FullInvoiceRefund( testDetails.invoiceNumber,true));
                //       // // Call refund for this specific test
                //       // await TransactionRepoDb().updateInvoiceAfterRefund(
                //       //   testDetails.invoiceNumber,
                //       //   isFullRefund: true,
                //       // );
                //     },
                //     child: Text("Full Refund")),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Test Name',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Code',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Qty',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Amount',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    //   Padding(
                    //     padding: EdgeInsets.all(8.0),
                    //     child: Text('',
                    //         style: TextStyle(fontWeight: FontWeight.bold)),
                    //   ),
                  ],
                ),
                ...testDetails.invoiceDetails.map((test) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            test.testName ?? "",
                            style: TextStyle(
                                color: test.isRefund == true
                                    ? Colors.red
                                    : Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            test.testCode ?? "",
                            style: TextStyle(
                                color: test.isRefund == true
                                    ? Colors.red
                                    : Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            test.qty.toString(),
                            style: TextStyle(
                                color: test.isRefund == true
                                    ? Colors.red
                                    : Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _formatCurrency(test.fee),
                            style: TextStyle(
                                color: test.isRefund == true
                                    ? Colors.red
                                    : Colors.black),
                          ),
                        ),
                        // test.isRefund == true
                        //     ? SizedBox.shrink()
                        //     : IconButton(
                        //         onPressed: () async {
                        //           try {
                        //             // Call refund for this specific test
                        //             await TransactionRepoDb()
                        //                 .updateInvoiceAfterRefund(
                        //               testDetails.invoiceNumber,
                        //               isFullRefund: false,
                        //               refundTestIds: [
                        //                 test.testId!
                        //               ], // refund single test
                        //             );

                        //             // Optionally, refresh UI or show a message
                        //             ScaffoldMessenger.of(context).showSnackBar(
                        //               SnackBar(
                        //                   content: Text(
                        //                       '${test.testName} refunded successfully!')),
                        //             );
                        //             AppRoutes.pop(context);
                        //             context
                        //                 .read<TransactionBloc>()
                        //                 .add(LoadTransactionInvoices());

                        //           } catch (e) {
                        //             ScaffoldMessenger.of(context).showSnackBar(
                        //               SnackBar(
                        //                   content: Text('Refund failed: $e')),
                        //             );
                        //           }
                        //         },
                        //         icon: Icon(
                        //           HugeIcons.strokeRoundedDelete02,
                        //           size: 20,
                        //           color: Colors.red,
                        //         ),
                        //       )
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsTable(
      List<SyncPaymentModel> testDetails, BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             Text(
              'Payment Details',
            textAlign: TextAlign.start,style: AppTextStyle.titleMedium(context)
            ),
            const Divider(),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('Date ',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('Receipt Amount',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('Due Amount',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('Receipts No',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        'Payment Type',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('Action',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...testDetails.map((test) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                              test.paymentDate.toString() != "null"
                                  ? DateFormat('dd/MM/yyyy hh:mm:a').format(
                                      DateTime.parse(
                                          test.paymentDate.toString()))
                                  : 'N/A',
                              textAlign: TextAlign.center,
                              style: AppTextStyle.bodySmall(context)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            test.amount?.toStringAsFixed(2) ?? "",
                            textAlign: TextAlign.center,
                            style: AppTextStyle.bodySmall(context),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(test.dueAmount?.toStringAsFixed(2) ?? "",
                              textAlign: TextAlign.center,
                              style: AppTextStyle.bodySmall(context)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(test.moneyReceiptNumber ?? "",
                              textAlign: TextAlign.center,
                              style: AppTextStyle.bodySmall(context)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text((() {
                            final type =
                                test.moneyReceiptType?.toLowerCase() ?? '';
                            switch (type) {
                              case 'add':
                                return 'New Bill';
                              case 'due':
                                return 'Due';
                              case 'refund':
                                return 'Refund';
                              default:
                                return '';
                            }
                          })(),
                              textAlign: TextAlign.center,
                              style: AppTextStyle.bodySmall(context)),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            HugeIcons.strokeRoundedPrinter,
                            size: 20,
                          ),
                          tooltip: 'Print',
                          onPressed: () {
                            final transactionBloc =
                                context.read<TransactionBloc>();

                            if (test.moneyReceiptType == "refund") {
                              transactionBloc.add(LoadMoneyReceiptDetails(
                                invoiceId: test.id.toString(),
                                isRefund: true,
                                context: context,
                              ));
                            } else {
                              transactionBloc.add(LoadMoneyReceiptDetails(
                                invoiceId: test.moneyReceiptNumber.toString(),
                                isRefund: false,
                                context: context,
                              ));
                            }

                            transactionBloc.add(LoadTransactionInvoices());
                          },
                        ),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceSummary(InvoiceModelSync invoiceInfo) {
    final totalAmount = _parseNum(invoiceInfo.totalBillAmount);
    final discountAmount = _parseNum(invoiceInfo.discount);
    final paidAmount = _parseNum(invoiceInfo.paidAmount);
    final netAmount = totalAmount - discountAmount;
    final dueAmount = _parseNum(invoiceInfo.due);

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),
            _buildSummaryRow('Total Amount', totalAmount),
            _buildSummaryRow('Discount', discountAmount),
            _buildSummaryRow('Net Amount', netAmount, isBold: true),
            const Divider(),
            _buildSummaryRow('Paid Amount', paidAmount),
            _buildSummaryRow(
              'Due Amount',
              dueAmount,
              isBold: true,
              color: dueAmount > 0 ? Colors.red : Colors.green,
            ),
            Text(
              'Payment Method: ${invoiceInfo.payments.isNotEmpty ? _formatPaymentMethod(invoiceInfo.payments.reversed.first.paymentType.toString()) : ""}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _formatCurrency(value),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getInvoiceStatus(InvoiceModelSync invoiceInfo) {
    final totalAmount = _parseNum(invoiceInfo.totalBillAmount);
    final discountAmount = _parseNum(invoiceInfo.discount);
    final paidAmount = _parseNum(invoiceInfo.paidAmount);
    final dueAmount = (totalAmount - discountAmount) - paidAmount;

    if (dueAmount <= 0) {
      return 'Paid';
    } else if (paidAmount > 0) {
      return 'Partial';
    } else {
      return 'Unpaid';
    }
  }

  Color _getStatusColor(InvoiceModelSync invoiceInfo) {
    final status = _getInvoiceStatus(invoiceInfo);
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Partial':
        return Colors.orange;
      case 'Unpaid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatPaymentMethod(String? method) {
    switch (method?.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Card';
      case 'bkash':
        return 'bKash';
      case 'nagad':
        return 'Nagad';
      case 'bank':
        return 'Bank Transfer';
      default:
        return method ?? 'N/A';
    }
  }

  String _formatCurrency(dynamic value) {
    final amount = _parseNum(value);
    return NumberFormat('#,##0.00').format(amount);
  }

  double _parseNum(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
