import '../../../../core/configs/configs.dart';
import '../../../feature.dart';

class ReportInvoiceDataTable extends StatelessWidget {
  final List<SampleCollectorInvoice> invoices;
  final ScrollController verticalScrollController;
  final ScrollController horizontalScrollController;
  final Function(InvoiceModelSync) onViewDetails;
  final Function(InvoiceModelSync, double, double) onCollectPayment;

  const ReportInvoiceDataTable({
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
                          // maxHeight: MediaQuery.of(context).size.height * 0.7, // or any reasonable height

                          // OR fixed width: minWidth: 1400,
                        ),
                        child: DataTable(
                          headingRowHeight: 40,
                          showCheckboxColumn: false,
                          // dataRowHeight: null, // dynamic
                          columnSpacing: 0,
                          checkboxHorizontalMargin: 0,
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          headingRowColor:
                              WidgetStateProperty.all(const Color(0xFF6ab129)),
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
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              maxLines: 2,
              softWrap: true,
              textAlign: TextAlign.center,
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
            appWidgets.convertDateTimeDDMMYYYY(
                DateTime.tryParse(invoice.createDate.toString())),
            columnWidth),
        _buildDataCell(
            "${invoice.patient.name}\n${invoice.patient.hnNumber}\n${invoice.patient.phone}",
            columnWidth * 2),
        _buildTestNamesCell(invoice, columnWidth * 3),
        _buildCollectionStatusCell(invoice, columnWidth),
      ],
      mouseCursor: WidgetStateProperty.all(SystemMouseCursors.copy),
      onSelectChanged: (_) {
        openSampleCollectorDialog(context, invoice);
      },
    );
  }

  void openSampleCollectorDialog(
      BuildContext context, SampleCollectorInvoice invoice) {
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
          child: SampleCollectorInvoiceDialog(
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
            testItems: invoice.details
                .where((d) => d.type == "Test" && d.isRefund == false)
                .map((d) {
              final collectionDate = DateTime.tryParse(d.collectionDate ?? "");
              final collected = d.collectionStatus == "1";
              return TestItem(
                sl: d.detailId ?? 0,
                collectionDate:
                    appWidgets.convertDateTimeDDMMYYYY(collectionDate),
                collectionTime:
                    appWidgets.convertDateTime(collectionDate, "HH:mm:a"),
                collected: collected,
                testName: d.testName ?? "",
                collectorName: d.collector?.name ?? "",
                allReadyCollected: collected ? 1 : 0,
              );
            }).toList(),
            sampleCollectorInvoice: invoice,
          ),
        ),
      ),
    );
  }

  DataCell _buildTestNamesCell(
      SampleCollectorInvoice invoice, double columnWidth) {
    // Build TextSpans for each test with color
    final spans = invoice.details
        .where((t) => t.isRefund != true) // skip refunded
        .map((t) {
      Color textColor;
      if (t.collectionStatus == '0') {
        textColor = Colors.red; // Not collected
      } else if (t.collectionStatus == '1') {
        textColor = Colors.green; // Collected
      } else {
        textColor = Colors.orange; // Partial / other status
      }

      return TextSpan(
        text: "${t.testName ?? ''}, ",
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      );
    }).toList();
    return DataCell(
      ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: columnWidth, // ✅ limit width
          maxHeight: 100, // ✅ ~5 lines (10–12px per line)
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
          child: Text.rich(
            TextSpan(children: spans),
            maxLines: 5, // ✅ show up to 5 lines
            overflow: TextOverflow.ellipsis, // ✅ add "..." after 5th line
            softWrap: true, // ✅ allow wrapping
          ),
        ),
      ),
    );
  }

  DataCell _buildCollectionStatusCell(
      SampleCollectorInvoice invoice, double columnWidth) {
    // Determine status based on all invoice details
    int collectedCount =
        invoice.details.where((t) => t.collectionStatus == '1').length;
    int totalCount = invoice.details.length;

    String statusText;
    Color statusColor;

    if (collectedCount == 0) {
      statusText = 'Not Collected';
      statusColor = Colors.red;
    } else if (collectedCount == totalCount) {
      statusText = 'Collected';
      statusColor = Colors.green;
    } else {
      statusText = 'Partially Collected';
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
              gapW4,
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

  DataCell _buildDataCell(String text, double columnWidth, {bool isDue = false}) {
    final amount = isDue ? double.tryParse(text) ?? 0 : 0;

    return DataCell(
      SizedBox(
        width: columnWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: SelectableText(
            text,
            style: TextStyle(
              fontSize: 10,
              color: isDue && amount > 0 ? Colors.red : Colors.black,
              fontWeight: isDue && amount > 0 ? FontWeight.w500 : null,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,   // ✅ allow up to 3 lines
            minLines: 1,   // ✅ at least one line
          ),
        ),
      ),
    );
  }

}
