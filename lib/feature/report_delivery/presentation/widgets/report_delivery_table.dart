import '../../../../core/configs/configs.dart';
import '../../../feature.dart';
import 'report_delivery_alert_dialog.dart';

class ReportDeliveryTable extends StatelessWidget {
  final List<SampleCollectorInvoice> invoices;
  final ScrollController verticalScrollController;
  final ScrollController horizontalScrollController;

  const ReportDeliveryTable({
    super.key,
    required this.invoices,
    required this.verticalScrollController,
    required this.horizontalScrollController,
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
      'Patient Info',
      'Invoice Date',
      'Due',
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
        _buildDataCell(
            "${invoice.patient.name}\n${invoice.patient.hnNumber}\n${invoice.patient.phone}",
            columnWidth * 2),
        _buildDataCell(
            appWidgets.convertDateTimeDDMMYYYY(
                DateTime.tryParse(invoice.createDate.toString())),
            columnWidth),
        _buildDataCell(invoice.due.toString(), columnWidth,isDue: true),
        _buildReportStatusCell(invoice, columnWidth),
      ],
      mouseCursor: WidgetStateProperty.all(SystemMouseCursors.copy),
      onSelectChanged: (_) {
        openSampleCollectorDialog(context, invoice);
      },
    );
  }

  void openSampleCollectorDialog(BuildContext context,
      SampleCollectorInvoice invoice) {
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
          child: ReportDeliveryAlertDialog(
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

          //   testItems: invoice.details
          //     .where((d) => d.type == "Test" && d.isRefund == false)
          //     .map((d) {
          //   final collectionDate = DateTime.tryParse(d.collectionDate ?? "");
          //   final collected = d.collectionStatus == "1";
          //   return TestItem(
          //     sl: d.detailId ?? 0,
          //     collectionDate:
          //     appWidgets.convertDateTimeDDMMYYYY(collectionDate),
          //     collectionTime:
          //     appWidgets.convertDateTime(collectionDate, "HH:mm:a"),
          //     collected: collected,
          //     testName: d.testName ?? "",
          //     collectorName: d.collector?.name ?? "",
          //     allReadyCollected: collected ? 1 : 0,
          //   );
          // }).toList(),
          ),
        ),
      ),
    );
  }
  DataCell _buildReportStatusCell(
      SampleCollectorInvoice invoice, double columnWidth) {
    final total = invoice.details.length;

    // Count how many tests have deliveryStatus == "1"
    final deliveredCount = invoice.details.where((t) {
      final val = int.tryParse(t.deliveryStatus ?? "0") ?? 0;
      return val == 1;
    }).length;

    String statusText;
    Color statusColor;

    if (deliveredCount == 0) {
      statusText = 'Not Delivered';
      statusColor = Colors.red;
    } else if (deliveredCount == total) {
      statusText = 'Delivered';
      statusColor = Colors.green;
    } else {
      statusText = 'Partial';
      statusColor = Colors.orange;
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
              const SizedBox(width: 8),
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
}
