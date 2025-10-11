import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../feature/common/data/models/print_layout_model.dart';
import '../../../feature/common/presentation/print_layout_bloc/print_layout_bloc.dart';
import '../../core.dart';
import '../../utilities/parse_html_contact.dart';

Future<Uint8List> generateSummaryPdf({
  required PdfPageFormat format,
  required startDate,
  required endDate,
  required summery,
  required List paymentsAdd,
  required List paymentsDue,
  required List paymentsRefund,
  required PrintLayoutModel layout,
}) async {
  // Decode JSON
  final billingJson = layout.billing != null ? jsonDecode(layout.billing!) : {};

  final headerData = billingJson['headerData'] ?? {};
  final isHeaderApplicable = headerData['isHeaderApplicable'] ?? false;
  final headerContent = headerData['header_content'] ?? '';

  // --- Build PDF ---
  final pdf = pw.Document();

  // Group the data by date and type, same as your Flutter grouping
  final Map<String, Map<String, List>> groupedData = {};

  void addToGroup(List payments, String type) {
    for (var row in payments) {
      final dt = DateTime.tryParse(row['payment_date']);
      if (dt == null) continue;
      final dateKey = DateFormat('dd-MM-yyyy').format(dt);
      groupedData[dateKey] ??= {
        'Due Collection': [],
        'New Bill': [],
        'Refund': []
      };
      groupedData[dateKey]![type]!.add(row);
    }
  }

  addToGroup(paymentsDue, 'Due Collection');
  addToGroup(paymentsAdd, 'New Bill');
  addToGroup(paymentsRefund, 'Refund');

  // Sort dates ascending (oldest first)
  final sortedDates = groupedData.keys.toList()
    ..sort((a, b) {
      final dtA = DateFormat('dd-MM-yyyy').parse(a);
      final dtB = DateFormat('dd-MM-yyyy').parse(b);
      return dtA.compareTo(dtB);
    });

  // Helper to format currency
  String formatCurrency(dynamic amount) {
    if (amount == null) return '0.00';
    return double.tryParse(amount.toString())?.toStringAsFixed(2) ?? '0.00';
  }

  // Calculate total paid_amount in list
  double calculateTotal(List rows) {
    double total = 0;
    for (var row in rows) {
      final amt = row['paid_amount'];
      if (amt != null) total += amt is double ? amt : (amt as num).toDouble();
    }
    return total;
  }

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        buildBackground: (context) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(color: PdfColors.white),
        ),
      ), // pageTheme: pw.PageTheme(

      header: (context) {
        if (!isHeaderApplicable || headerContent.isEmpty) {
          return pw.SizedBox();
        }

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            parseHtmlContent(headerContent, pageFormat: format),

            pw.Text(
              'Date: $startDate -- $endDate',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 4), // spacing
          ],
        );
      },

      build: (context) {
        return [
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            columnWidths: {
              0: pw.FixedColumnWidth(55),
              1: pw.FixedColumnWidth(65),
              2: pw.FixedColumnWidth(70),
              3: pw.FixedColumnWidth(50),
              4: pw.FixedColumnWidth(70),
              5: pw.FixedColumnWidth(50),
              6: pw.FixedColumnWidth(60),
              7: pw.FixedColumnWidth(50),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(
                      color: PdfColors.black,
                      width: 1,
                      style: pw.BorderStyle.dashed,
                    ),
                  ),
                ),
                children: [
                  'Date',
                  'Bill No',
                  'Patient',
                  'Refd. By',
                  'User Name',
                  'Payment Type',
                  'Bill Amount',
                  'Amount',
                ].map((header) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(header,
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 8),
                        textAlign: pw.TextAlign.center),
                  );
                }).toList(),
              ),
            ],
          ),
          for (final date in sortedDates) ...[
            pw.SizedBox(height: 8),
            pw.Text('Date: $date',
                style: pw.TextStyle(
                  fontSize: 10,
                )),
            for (final section in ['Due Collection', 'New Bill', 'Refund']) ...[
              pw.Text(section,
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),

              groupedData[date]![section]!.isEmpty
                  ? pw.Center(
                      child: pw.Text('No bill available',
                          style: pw.TextStyle(
                              fontSize: 12, fontStyle: pw.FontStyle.italic)))
                  : pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey),
                      columnWidths: {
                        0: pw.FixedColumnWidth(55),
                        1: pw.FixedColumnWidth(65),
                        2: pw.FixedColumnWidth(70),
                        3: pw.FixedColumnWidth(50),
                        4: pw.FixedColumnWidth(70),
                        5: pw.FixedColumnWidth(50),
                        6: pw.FixedColumnWidth(60),
                        7: pw.FixedColumnWidth(50),
                      },
                      children: [
                        // Data rows
                        ...groupedData[date]![section]!.map((row) {
                          final dt =
                              DateTime.tryParse(row['payment_date'] ?? '');
                          final invoice = row['invoice'] ?? {};
                          final patient = row['patient'] ?? {};

                          String formatCurrency(dynamic amount) {
                            if (amount == null) return '0.00';
                            final parsed =
                                double.tryParse(amount.toString()) ?? 0.0;
                            return parsed.toStringAsFixed(2);
                          }

                          return pw.TableRow(
                            decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                                        color: PdfColors.grey300))),
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  dt != null
                                      ? DateFormat('HH:mm:a').format(dt)
                                      : '',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  row['invoice_number'] ?? '',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  patient['name'] ?? '',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  invoice['refer_type'] ?? '',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  invoice['created_by_name'] ?? '',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  row['payment_type'] ?? '',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  formatCurrency(invoice['total_bill_amount']),
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(fontSize: 10),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(
                                  formatCurrency(row['paid_amount']),
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),

              // Total row below the table
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4, bottom: 10),
                  child: pw.Text(
                    'Total: ${formatCurrency(calculateTotal(groupedData[date]![section]!))}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ),
            ],
            pw.SizedBox(height: 20),
          ],
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(children: [
                  pw.Container(
                    width: 250,
                    padding: const pw.EdgeInsets.all(8),
                    alignment: pw.Alignment.bottomRight,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.white),
                      borderRadius: pw.BorderRadius.circular(5),
                      color: PdfColors.grey200,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Summary',
                            style: pw.TextStyle(
                                fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Due Collection :',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text('${summery['due_collection']}'),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Test Refund :',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text('${summery['test_refund']}'),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total New Bill :',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text('${summery['new_bill']}'),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Grand Total :',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 14)),
                            pw.Text('${summery['grand_total']}',
                                style: pw.TextStyle(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ])
              ])
        ];
      },
    ),
  );

  return await pdf.save();
}

void printSummary({
  required BuildContext context,
  required summery,
  required List paymentsAdd,
  required List paymentsDue,
  required List paymentsRefund,
  required startDate,
  required endDate,
}) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.grey,
        body: PdfPreview.builder(
          useActions: true,
          allowSharing: false,
          canDebug: false,

          canChangeOrientation: false,
          canChangePageFormat: false,
          dynamicLayout: true,
          // no default actions bar

          build: (format) => generateSummaryPdf(
              paymentsAdd: paymentsAdd,
              summery: summery,
              format: format,
              paymentsDue: paymentsDue,
              paymentsRefund: paymentsRefund,
              startDate: startDate,
              endDate: endDate,
              layout: context.read<PrintLayoutBloc>().layoutModel ??
                  PrintLayoutModel()),

          initialPageFormat: PdfPageFormat.a4,
          pdfPreviewPageDecoration: BoxDecoration(color: Colors.grey),
          // page container white

          actionBarTheme: PdfActionBarTheme(
            backgroundColor: AppColors.primaryColor,
            iconColor: Colors.white,
            textStyle: const TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () => AppRoutes.pop(context),
              icon: const Icon(Icons.cancel, color: Colors.red),
            ),
          ],

          pagesBuilder: (context, pages) {
            debugPrint('Rendering ${pages.length} pages');

            return PageView.builder(
              itemCount: pages.length,
              scrollDirection: Axis.vertical,
              scrollBehavior: ScrollBehavior(),
              itemBuilder: (context, index) {
                final page = pages[index];
                return Container(
                  decoration: BoxDecoration(color: Colors.grey),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(image: page.image, fit: BoxFit.contain),
                  ),
                );
              },
            );
          },
        ),
      ),
    ),
  );
}
