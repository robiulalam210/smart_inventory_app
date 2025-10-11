import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import '../../../../core/configs/configs.dart';
import '../../../feature.dart';
import 'lab_technologist_test_update_dialog.dart';

class LabTechnologistInvoiceDataTable extends StatelessWidget {
  final List<SampleCollectorInvoice> invoices;
  final ScrollController verticalScrollController;
  final ScrollController horizontalScrollController;
  final Function(InvoiceModelSync) onViewDetails;
  final Function(InvoiceModelSync, double, double) onCollectPayment;

  const LabTechnologistInvoiceDataTable({
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
        const int numColumns = 10;
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
                      padding: const EdgeInsets.only(bottom: 5),
                      child: ConstrainedBox(
                        // <-- Set minWidth larger than viewport width to enable horizontal scroll
                        constraints: BoxConstraints(
                          minWidth: constraints.minWidth,
                          // OR fixed width: minWidth: 1400,
                        ),
                        child: DataTable(
                          dataRowMinHeight: 30,
                          // dataRowMaxHeight: 80,
                          headingRowHeight: 40,
                          showCheckboxColumn: false,
                          // Hides the checkbox column

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
      'Patient Info',
      'Test Name',
      'Status',
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

  DataRow _buildDataRow(BuildContext context, SampleCollectorInvoice invoice,
      double columnWidth) {
    return DataRow(
      cells: [
        _buildDataCell(invoice.invoiceNumber.toString(), columnWidth),
        _buildDataCell(_formatDate(invoice.createDate), columnWidth),
        _buildDataCell("${invoice.patient.name}\n${invoice.patient.phone}",
            columnWidth * 2),
        _buildTestNamesCell(invoice, columnWidth * 3, context),
        _buildReportStatusCell(invoice, columnWidth),
      ],
      mouseCursor: WidgetStateProperty.all(SystemMouseCursors.copy),
    );
  }

  void openSampleCollectorDialog(BuildContext context,
      SampleCollectorInvoice invoice, InvoiceDetail testId) {
    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners here
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
            maxHeight: 700,
          ),
          child: LabTechnologistInvoiceDialog(
            invoiceNo: invoice.invoiceNumber,
            invoiceApp: invoice.invoiceNumber,
            patientName: invoice.patient.name,
            dob: () {
              final dob = DateTime.tryParse(invoice.patient.dateOfBirth);
              final age = invoice.patient.age;
              return '${appWidgets.convertDateTimeDDMMYYYY(dob)} -- $age Y';
            }(),
            hnNo: invoice.patient.hnNumber,
            gender: invoice.patient.gender,
            billDate: appWidgets.convertDateTimeDDMMYYYY(
              DateTime.tryParse(invoice.createDate) ?? DateTime.now(),
            ),
            sampleCollectorInvoice: invoice,
            testId: testId,
          ),
        ),
      ),
    );
  }  void openSampleCollectorTestUpdateDialog(BuildContext context,
      SampleCollectorInvoice invoice, InvoiceDetail testId) {
    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners here
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
            maxHeight: 700,
          ),
          child: LabTechnologistTestUpdateDialog(
            invoiceNo: invoice.invoiceNumber,
            patientName: invoice.patient.name,
            dob: () {
              final dob = DateTime.tryParse(invoice.patient.dateOfBirth);
              final age = invoice.patient.age;
              return '${appWidgets.convertDateTimeDDMMYYYY(dob)} -- $age Y';
            }(),
            hnNo: invoice.patient.hnNumber,
            gender: invoice.patient.gender,
            billDate: appWidgets.convertDateTimeDDMMYYYY(
              DateTime.tryParse(invoice.createDate) ?? DateTime.now(),
            ),
            sampleCollectorInvoice: invoice,
            testId: testId,
          ),
        ),
      ),
    );
  }

  DataCell _buildTestNamesCell(
    SampleCollectorInvoice invoice,
    double columnWidth,
    BuildContext context,
  ) {
    return DataCell(
      SizedBox(
        width: columnWidth,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 6),
            child: RichText(
              maxLines: 10,
              text: TextSpan(
                children: invoice.details
                    .where((t) => t.isRefund != true) // skip refunded
                    .map((t) {
                  final int added = int.tryParse(t.reportAddStatus ?? '0') ?? 0;
                  final int confirmed =
                      int.tryParse(t.reportConfirmedStatus ?? '0') ?? 0;

                  Color textColor;
                  if (added == 1 && confirmed == 1) {
                    textColor = Colors.green;
                  } else if (added == 1 && confirmed == 0) {
                    textColor = Colors.orange;
                  } else if (added == 0 && confirmed == 0) {
                    textColor = Colors.red;
                  } else {
                    textColor = Colors.grey;
                  }

                  // Override with collectionStatus
                  if (t.collectionStatus == '0') {
                    textColor = Colors.red;
                  }

                  return TextSpan(
                    text: "${t.testName ?? ''}, ",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    mouseCursor: SystemMouseCursors.click,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        if(t.collectionStatus=="1"&&t.reportAddStatus=="1"){
                          openSampleCollectorTestUpdateDialog(context, invoice, t);

                          LabTechnologistRepoDb().     fetchLabReport(invoice.invoiceNumber,t.testId.toString());
                        }else{
                          if (t.testInfo?.group?.name == "Radiology" &&
                              t.collectionStatus == '0') {
                            openSampleCollectorDialog(context, invoice, t);
                          } else if (t.collectionStatus == '0') {
                            // Other tests not collected yet
                            showDialog(
                              context: context,
                              builder: (_) => CupertinoAlertDialog(
                                title: const Text('Attention'),
                                content:
                                const Text('Please collect sample first!'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Sample already collected
                            openSampleCollectorDialog(context, invoice, t);
                          }
                        }


                      },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildReportStatusCell(
      SampleCollectorInvoice invoice, double columnWidth) {
    // Convert null/empty -> 0
    int added = invoice.details.fold<int>(
      0,
      (sum, t) => sum + int.tryParse(t.reportAddStatus ?? '0')!,
    );
    int confirmed = invoice.details.fold<int>(
      0,
      (sum, t) => sum + int.tryParse(t.reportConfirmedStatus ?? '0')!,
    );
    int total = invoice.details.length;

    String statusText;
    Color statusColor;

    if (added == total && confirmed == total) {
      statusText = 'Confirmed';
      statusColor = Colors.green;
    } else if (confirmed == 0 && added > 0) {
      statusText = 'Pending';
      statusColor = Colors.orange;
    } else if (confirmed != total && confirmed > 0) {
      statusText = 'Partial';
      statusColor = Colors.orange;
    } else if (added == 0) {
      statusText = 'Not Added';
      statusColor = Colors.red;
    } else {
      statusText = 'Unknown';
      statusColor = Colors.grey;
    }

    return DataCell(
      SizedBox(
        width: columnWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 5,
                backgroundColor: statusColor,
              ),
              gapW8,
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataCell _buildDataCell(String text, double columnWidth,
      {bool isDue = false}) {
    final amount = isDue ? double.tryParse(text) ?? 0 : 0;

    return DataCell(
      InkWell(
        child: SizedBox(
          width: columnWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: isDue && amount > 0 ? Colors.red : Colors.black,
                fontWeight: isDue && amount > 0 ? FontWeight.w500 : null,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    final parsedDate = DateTime.tryParse(date.toString());
    return parsedDate != null
        ? DateFormat('dd/MM/yyyy').format(parsedDate)
        : 'N/A';
  }
}
