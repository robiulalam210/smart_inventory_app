import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
// ignore: depend_on_referenced_packages

import '../../../feature/common/data/models/print_layout_model.dart';
import '../../../feature/transactions/data/models/invoice_local_model.dart';
import '../../utilities/app_date_time.dart';
import '../../utilities/page_format.dart';
import '../../utilities/parse_html_contact.dart';
import '../../utilities/pdf_margin_matgin_to_points.dart';
import '../app_constants.dart';
import '../convert_number_to_word.dart';
Future<pw.Font> loadFont() async {
  final data = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
  return pw.Font.ttf(data);
}


pw.Widget infoRow(String label, String value,
    {required pw.Font font, int flex = 5, bool isDue = false}) {
  return pw.Expanded(
    flex: flex,
    child: pw.Text(
      '$label: $value',
      style: pw.TextStyle(
        font: font,
        fontSize: 10,
        fontWeight: isDue ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: isDue ? PdfColors.red : PdfColors.black,
      ),
    ),
  );
}


// pw.Widget _infoRow(String label, String value, {int flex = 5, bool isDue = false, double amount = 0}) {
//   return pw.Expanded(
//     flex: flex,
//     child: pw.RichText(
//       text: pw.TextSpan(
//         children: [
//           pw.TextSpan(
//             text: '$label: ',
//             style: pw.TextStyle(
//               fontSize: 10,
//               fontWeight: pw.FontWeight.bold,
//             ),
//           ),
//           pw.TextSpan(
//             text: value,
//             style: pw.TextStyle(
//               fontSize: 10,
//               color: (isDue && amount > 0) ? PdfColors.red : PdfColors.black,
//               fontWeight: (isDue && amount > 0) ? pw.FontWeight.bold : pw.FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
pw.Widget _totalRow(String title, String value, {PdfColor? color}) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(
          color: PdfColors.black,
          width: 0.5,
          style: pw.BorderStyle.dashed,
        ),
      ),
    ),
    padding: pw.EdgeInsets.only(left:30,right:0,top: 4,bottom: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 10)),
        pw.Text(value,
            style: pw.TextStyle(fontSize: 10, color: color ?? PdfColors.black)),
      ],
    ),
  );
}

Future<Uint8List> generatePdfDynamic(
    BuildContext context,
    InvoiceLocalModel inv,
    bool isRefund
    ,  final PrintLayoutModel layout,

    ) async {


  // Decode JSON
  final billingJson = layout.billing != null ? jsonDecode(layout.billing!) : {};
  final pageType = billingJson['pageType'] ?? 'blank-page';

  final pageSize = billingJson['pageSize'] ?? 'A5';
  final margins = billingJson['margins'] ??
      {'left': 0.2, 'right': 0.2, 'top': 0.2, 'bottom': 0.2};
  final marginUnit = billingJson['marginUnit'] ?? 'Inch';

  final headerData = billingJson['headerData'] ?? {};
  final isHeaderApplicable = headerData['isHeaderApplicable'] ?? false;
  final headerContent = headerData['header_content'] ?? '';

  // --- Margins ---
  double marginToPoints(double margin) {
    if (marginUnit == 'Inch') return margin * 72;
    if (marginUnit == 'Cm') return margin * 28.35;
    return margin * 72;
  }

  final leftMargin = marginToPoints(parseMargin(margins['left']));
  final rightMargin = marginToPoints(parseMargin(margins['right']));
  final topMargin = marginToPoints(parseMargin(margins['top']));
  final bottomMargin = marginToPoints(parseMargin(margins['bottom']));

  // --- Build PDF ---
  final format = getPageFormat(pageSize);
  final pdf = pw.Document();
  final roboto = await loadFont(); // loadFont returns Future<pw.Font>


  final barcode = pw.Barcode.code128(escapes: true,);
  final svgBarcode =
      barcode.toSvg('${inv.invoiceNumber}', width: 100, height: 20,drawText: false);

// Build the list of rows dynamically
  final totalAmount = double.tryParse(inv.totalBillAmount.toString()) ?? 0.0;
  final discount = double.tryParse(inv.discount.toString()) ?? 0.0;
  final netAmount = totalAmount - discount;
  final receivedAmount = double.tryParse(inv.paidAmount.toString()) ?? 0.0;
  final dueAmount = double.tryParse(inv.due.toString()) ?? 0.0;
  double totalTestAmount(List<InvoiceDetailLocal> details) {
    if (details.isEmpty) return 0.0;

    return details.fold<double>(
      0.0,
      (sum, item) => sum + (item.fee ?? 0.0),
    );
  }
  double totalDiscount(List<InvoiceDetailLocal> details,discountPercentage) {
    if (details.isEmpty) return 0.0;

    return details.fold<double>(
      0.0,
          (sum, item) {
        final fee = item.fee ?? 0.0;
        final discountApplied = item.discountApplied ?? 0;

        double discountAmount = 0.0;
        if (discountApplied == 1) {
          discountAmount = fee * discountPercentage / 100.0;
        }

        return sum + discountAmount;
      },
    );
  }
  double totalPerTestDiscount(List<InvoiceDetailLocal> details) {
    if (details.isEmpty) return 0.0;

    return details.fold<double>(
      0.0,
          (sum, item) {
        final fee = item.fee ?? 0.0;
        final discountApplied = item.discountApplied ?? 0;
        final discountPercent = item.discount ?? 0.0;

        double discountAmount = 0.0;
        if (discountApplied == 1) {
          discountAmount = fee * discountPercent / 100.0;
        }

        return sum + discountAmount;
      },
    );
  }

  double netRefundAmount(InvoiceLocalModel inv) {
    final totalTests = totalTestAmount(inv.invoiceDetails);
    final perTestDiscount = totalPerTestDiscount(inv.invoiceDetails);
    final subtotal = totalTests - perTestDiscount;

    final invoiceDiscountPercent = inv.discountPercentage ?? 0.0;
    final invoiceDiscountAmount = subtotal * invoiceDiscountPercent / 100.0;

    return subtotal - invoiceDiscountAmount;
  }


  final rows = <pw.Widget>[
    _totalRow(
      "Total Amount",
      isRefund
          ? totalTestAmount(inv.invoiceDetails).toStringAsFixed(2)
          : totalAmount.toStringAsFixed(2),
    ),
  ];

  if (discount > 0) {
    rows.addAll([
      _totalRow("Discount (${inv.discountPercentage?.toStringAsFixed(2)}%)",
          isRefund
              ? totalDiscount(inv.invoiceDetails,inv.discountPercentage).toStringAsFixed(2): discount.toStringAsFixed(2)),
    ]);
  }

  rows.addAll([
    isRefund
        ?pw.SizedBox.shrink():  _totalRow("Net Amount", netAmount.toStringAsFixed(2)),

    isRefund
        ?pw.SizedBox.shrink(): _totalRow("Received Amount", receivedAmount.toStringAsFixed(2)),

    isRefund
        ? _totalRow(
      "Refund Amount",
      netRefundAmount(inv).toStringAsFixed(2),
    ):pw.SizedBox.shrink(),


    isRefund
        ?pw.SizedBox.shrink():  _totalRow(
      "Due Amount",
      dueAmount.toStringAsFixed(2),
      color: dueAmount > 0 ? PdfColors.red : null, // red only if due > 0


    ),
  ]);

  if (inv.invoiceDetails.isEmpty) {
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: format,
          margin: pw.EdgeInsets.fromLTRB(
            leftMargin,
            topMargin,
            rightMargin,
            bottomMargin,
          ),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: PdfColors.white),
          ),
        ),
        header: (context) {
          if (!isHeaderApplicable || headerContent.isEmpty ||pageType !="blank-page") {
            return pw.SizedBox();
          }
          return parseHtmlContent(headerContent, pageFormat: format);
        },

        build: (_) => [
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.SizedBox(
                width: 100,
                child: pw.Text('Invoice No : ${inv.invoiceNumber}',
                    style: pw.TextStyle(fontSize: 10)),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(5),
                  border: pw.Border.all(
                      color: PdfColors.black,
                      width: 0.5,
                      style: pw.BorderStyle.dashed),
                ),
                child: pw.Text(isRefund ? 'Refund Slip' : 'Money Receipt',
                    style: pw.TextStyle(fontSize: 8)),
              ),
              pw.SizedBox(
                width: 110,
                child: pw.Text(
                    'Date: ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10),
                    textAlign: pw.TextAlign.start),
              ),
            ],
          ),
          pw.SizedBox(height: 10),


    pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
             infoRow("Patient Name", inv.patient.name, flex: 6, font: roboto),
             infoRow(
              "Age",
              "${inv.patient.age} Y ${inv.patient.month} M ${inv.patient.day} D",
              flex: 2,
              font: roboto,
            ),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
             infoRow("Patient Number", inv.patient.phone, flex: 6, font: roboto),
             infoRow("Sex", inv.patient.gender, flex: 2, font: roboto),
          ],
        ),
        pw.Row(
          children: [
             infoRow(
              "Referred by",
              inv.referInfo.name ??
                  (inv.referInfo.type == "Other"
                      ? inv.referInfo.value
                      : inv.referInfo.type),
              flex: 6,
              font: roboto,
            ),
          ],
        ),
      ],
    ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.symmetric(
              inside: pw.BorderSide.none,
              outside: pw.BorderSide.none,
            ),
            columnWidths: {
              0: const pw.FixedColumnWidth(25),   // St. (small, fixed)
              1: const pw.FlexColumnWidth(3),     // Test Name (flexible, larger)
              2: const pw.FixedColumnWidth(65),   // Discount(%)
              3: const pw.FixedColumnWidth(70),   // Test Cost
            },
            children: [
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
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4),
                    child: pw.Text('St.', style: pw.TextStyle(fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4),
                    child: pw.Text('Test Name', style: pw.TextStyle(fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'Discount(%)',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text(
                      'Test Cost',
                      textAlign: pw.TextAlign.end,
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
              ...inv.invoiceDetails.asMap().entries.map((entry) {
                final index = entry.key;
                final test = entry.value;
                final rate = test.fee ?? 0;
                final discountPercent = test.discount ?? 0;
                final qty = test.qty ?? 1;

                final double discountAmount =
                test.discountApplied == 0 ? 0.0 : rate * (discountPercent / 100);

                final double total = (rate - discountAmount) * qty;

                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: PdfColors.black,
                        width: 0.5,
                        style: pw.BorderStyle.dashed,
                      ),
                    ),
                  ),
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text('${index + 1}', style: pw.TextStyle(fontSize: 8)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text(
                        "${test.name.toString().capitalize()}"
                            "${test.type == "Inventory" ? test.qty : ""}",
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text(
                        (discountAmount == 0) ? "" : discountAmount.toStringAsFixed(2),
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(0),
                      child: pw.Text(
                        total.toStringAsFixed(2),
                        textAlign: pw.TextAlign.end,
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 20),
          pw.Row(
            children: [
              pw.SizedBox(
                width: 200,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    isRefund?pw.SizedBox.shrink():  pw.SizedBox(
                      width: 150,
                      child: pw.Text(
                          "In Words : ${amountToWords(double.parse(inv.paidAmount.toString())).toTitleCase()}",
                          style: pw.TextStyle(fontSize: 10)),
                    ),
                    pw.SizedBox(height: 20),
                    isRefund?pw.SizedBox.shrink():    pw.Text(
                      "Due Amount: ${double.tryParse(inv.due.toString())?.toStringAsFixed(2) ?? "0.00"}",
                        style: pw.TextStyle(fontSize: 12)),

                    pw.SizedBox(height: 20),
                  ],
                ),
              ),
              pw.SizedBox(width: 135, child: pw.Column(children: rows)),
            ],
          ),


          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                  'Delivery Date: ${appWidgets.convertDateTimeDDMMYYYY(DateTime.tryParse(inv.deliveryDate.toString()))} ${inv.deliveryTime}',
                  style: pw.TextStyle(fontSize: 10)),
              pw.Text('Posted: ${inv.createdByUser.name ?? "N/A"}',
                  style: pw.TextStyle(fontSize: 10)),
            ],
          ),
          pw.Center(
            child: pw.SvgImage(svg: svgBarcode),
          ),


        ],
      ),
    );

    return await pdf.save();
  }

  final chunks = inv.invoiceDetails.slices(14).toList();

  for (int i = 0; i < chunks.length; i++) {
    final isLastPage = i == chunks.length - 1;
    final currentItems = chunks[i];

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: format,
          margin: pw.EdgeInsets.fromLTRB(
            leftMargin,
            topMargin,
            rightMargin,
            bottomMargin,
          ),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: PdfColors.white),
          ),
        ),
        header: (context) {
          if (!isHeaderApplicable || headerContent.isEmpty ||pageType !="blank-page") {
            return pw.SizedBox();
          }
          return parseHtmlContent(headerContent, pageFormat: format);
        },
        build: (_) => [
          if (i == 0) ...[
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.SizedBox(
                  width: 100,
                  child: pw.Text('Invoice No : ${inv.invoiceNumber}',
                      style: pw.TextStyle(fontSize: 10)),
                ),
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(
                        color: PdfColors.black,
                        width: 0.6,
                        style: pw.BorderStyle.dashed),
                  ),
                  child: pw.Text(isRefund ? 'Refund Slip' : 'Money Receipt',
                      style: pw.TextStyle(fontSize: 10)),
                ),
                pw.SizedBox(
                  // width: 120,
                  child: pw.Text(
                      'Date: ${DateFormat('dd/MM/yyyy-hh:mm a').format(DateTime.now())}',
                      style: pw.TextStyle(fontSize: 10),
                      textAlign: pw.TextAlign.start),
                )
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Column(children: [
              pw.Row(children: [
                infoRow("Patient Name", inv.patient.name,font: roboto,),
                infoRow("Age",
                    "${inv.patient.age} Y ${inv.patient.month} M ${inv.patient.day} D",
                    flex: 2,font: roboto,),
              ]),
              pw.SizedBox(height: 3),
              pw.Row(children: [
                infoRow("Patient Number", inv.patient.phone,font: roboto,),
                infoRow("Sex", inv.patient.gender, flex: 2,font: roboto,
                ),
              ]),
              pw.SizedBox(height: 3),
              pw.Row(children: [
                infoRow(
                    "Referred by",
                    inv.referInfo.name ??
                        (inv.referInfo.type == "Other"
                            ? inv.referInfo.value
                            : inv.referInfo.type),font: roboto,),
              ]),
            ]),
            pw.SizedBox(height: 20),
          ],
          pw.Table(
            border: pw.TableBorder.symmetric(
              inside: pw.BorderSide.none,
              outside: pw.BorderSide.none,
            ),
            columnWidths: {
              0: const pw.FixedColumnWidth(25),   // St.
              1: const pw.FlexColumnWidth(3),     // Test Name (flexible, takes most space)
              2: const pw.FixedColumnWidth(65),   // Discount(%)
              3: const pw.FixedColumnWidth(70),   // Test Cost
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(
                      color: PdfColors.black,
                      width: 0.5,
                      style: pw.BorderStyle.dashed,
                    ),
                    bottom: pw.BorderSide(
                      color: PdfColors.black,
                      width: 0.5,
                      style: pw.BorderStyle.dashed,
                    ),
                  ),
                ),
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4),
                    child: pw.Text('St.', style: pw.TextStyle(fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4),
                    child: pw.Text('Test Name', style: pw.TextStyle(fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(4),
                    child: pw.Text('Discount(%)',
                        textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10)),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text('Test Cost',
                        textAlign: pw.TextAlign.end, style: pw.TextStyle(fontSize: 10)),
                  ),
                ],
              ),

              ...currentItems.asMap().entries.map((entry) {
                final index = entry.key + (i * 14);
                final test = entry.value;
                final rate = test.fee ?? 0;
                final discountPercent = test.discount ?? 0;
                final qty = test.qty ?? 1;

                final double discountAmount =
                test.discountApplied == 0 ? 0.0 : rate * (discountPercent / 100);
                final double total = (rate - discountAmount) * qty;

                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: PdfColors.black,
                        width: 0.5,
                        style: pw.BorderStyle.dashed,
                      ),
                    ),
                  ),
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text('${index + 1}', style: pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text(
                        "${test.name.toString().capitalize()}"
                            "${test.type == "Inventory" ? " - ${test.qty}" : ""}",
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text(
                        (discountPercent == 0) ? "" : discountAmount.toStringAsFixed(2),
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(
                        total.toStringAsFixed(2),
                        textAlign: pw.TextAlign.end,
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),

          if (isLastPage) ...[
            pw.SizedBox(height: 1),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                isRefund?pw.SizedBox.shrink():  pw.SizedBox(
                  width: 170,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        width: 150,
                        child: pw.Text(
                            "In Words : ${amountToWords(double.parse(inv.paidAmount.toString())).toTitleCase()}",
                            style: pw.TextStyle(fontSize: 8)),
                      ),

                      pw.SizedBox(height: 30),
                     pw.Center(child:  pw.Text(
                         "Due Amount: ${double.tryParse(inv.due.toString())?.toStringAsFixed(2) ?? "0.00"}",
                         style: pw.TextStyle(fontSize: 12,fontWeight: pw.FontWeight.bold)),)
                    ],
                  ),
                ),
                pw.SizedBox(width: 160, child: pw.Column(children: rows)),
              ],
            ),
          ],

          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // Inside your PDF widget
              pw.Text(
                'Delivery Date: ${appWidgets.convertDateTimeDDMMYYYY(DateTime.tryParse(inv.deliveryDate.toString()))} - '
                    '${formatTime(inv.deliveryTime)}',
                style: pw.TextStyle(fontSize: 10),
              ),

              pw.Text('Posted: ${inv.createdByUser.name ?? "N/A"}',
                  style: pw.TextStyle(fontSize: 10)),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.SvgImage(svg: svgBarcode,),
          ),
        ],
      ),
    );
  }

  return await pdf.save();
}
