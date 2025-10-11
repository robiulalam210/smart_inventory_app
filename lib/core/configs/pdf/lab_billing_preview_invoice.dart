import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../../../feature/common/data/models/print_layout_model.dart';
import '../../database/login.dart';
import '../../utilities/page_format.dart';
import '../../utilities/parse_html_contact.dart';
import '../../utilities/pdf_margin_matgin_to_points.dart';
import '../number_format.dart';
pw.Widget _infoRow(String label, String value, {int flex = 5}) {
  return pw.Expanded(
    flex: flex,
    child: pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(text: '$label: ', style: pw.TextStyle(fontSize: 10)),
          pw.TextSpan(text: value, style: pw.TextStyle(fontSize: 10)),
        ],
      ),
    ),
  );
}
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


String formatNumber(String numberString) {
  try {
    double? number = double.tryParse(numberString);
    if (number != null) {
      return number.toStringAsFixed(2);
    }
  } catch (e) {
    return numberString;
  }
  return numberString;
}

Future<Uint8List> generatePdf(
  BuildContext context,
  String patientName,
  String patientPhone,
  String age,
  String dob,
  String sex,
  String referredBy,
  String dateDeliveryReport,
  String timeDeliveryReport,
  List<Map<String, dynamic>> testItems,
  String dueAmount,
  String paidAmount,
  String totalAmount,
  final PrintLayoutModel layout,
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
  final token = await LocalDB.getLoginInfo();



  final barcode = pw.Barcode.code128();
  final svgBarcode = barcode.toSvg("0000000", width: 100, height: 20,drawText: false);

  // ✅ Handle Empty Test Items
  if (testItems.isEmpty) {
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
        // Header builder
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
              pw.SizedBox(width: 110),
              pw.Container(
                padding: pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(5),
                  border: pw.Border.all(
                      color: PdfColors.black,
                      width: 0.5,
                      style: pw.BorderStyle.dashed),
                ),
                child:
                    pw.Text('Preview Mode', style: pw.TextStyle(fontSize: 8)),
              ),
              pw.SizedBox(
                width: 112,
                child: pw.Text(
                  'Date: ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Column(children: [
            pw.Row(children: [
              _infoRow("Patient Name", patientName, flex: 6),
              _infoRow("Age", age, flex: 2),
            ]),
            pw.Row(children: [
              _infoRow("Patient Number", patientPhone, flex: 6),
              _infoRow("Sex", sex, flex: 2),
            ]),
            pw.Row(children: [
              _infoRow(
                  "Referred by", referredBy == "null" ? "Self" : referredBy,
                  flex: 6),
            ]),
          ]),
          pw.SizedBox(height: 20),

        // ✅ Test table with fixed column widths
        pw.Table(
          border: pw.TableBorder.symmetric(
            inside: pw.BorderSide.none,
            outside: pw.BorderSide.none,
          ),
          columnWidths: {
            0: const pw.FixedColumnWidth(25),   // St.
            1: const pw.FlexColumnWidth(3),     // Test Name (flexible, largest)
            2: const pw.FixedColumnWidth(65),   // Discount(%)
            3: const pw.FixedColumnWidth(70),   // Test Cost
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
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Text(
                    'Test Cost',
                    textAlign: pw.TextAlign.end,
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),

            // Show rows only if testItems is not empty
            if (testItems.isNotEmpty)
              ...List.generate(
                testItems.length,
                    (index) {
                  final test = testItems[index];

                  final double rate = (test['rate'] ?? 0).toDouble();
                  final double discountPercent =
                  (test['discountPercentage'] ?? 0).toDouble();
                  final bool discountApplied =
                      (test['discountApplied'] ?? 0) != 0;

                  final double discountAmount =
                  discountApplied ? rate * (discountPercent / 100) : 0.0;

                  final double total = test['total'];

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('${index + 1}',
                            style: pw.TextStyle(fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(test['test_name'] ?? '',
                            style: pw.TextStyle(fontSize: 10)),
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
                        padding: pw.EdgeInsets.symmetric(vertical: 4),
                        child: pw.Text(
                          formatNumberAll(total),
                          textAlign: pw.TextAlign.end,
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  );
                },
              )
            else
            // Empty row fallback if testItems is empty
              pw.TableRow(
                children: List.generate(
                  4,
                      (_) => pw.Padding(
                    padding: pw.EdgeInsets.all(4),
                    child: pw.Text(''),
                  ),
                ),
              ),
          ],
        ),


        pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 200,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("In Words: Zero Taka Only",
                        style: pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ),
              pw.SizedBox(
                width: 135,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _totalRow("Total Amount", totalAmount),

                    _totalRow("Net Amount", totalAmount),

                    _totalRow("Received Amount", paidAmount),

                    _totalRow("Due Amount", dueAmount, color: PdfColors.red),
                    pw.Container(height: 1, color: PdfColors.black),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Delivery Date: ${dateDeliveryReport.isNotEmpty ? dateDeliveryReport : "N/A"} - ${timeDeliveryReport.isNotEmpty ? timeDeliveryReport : "N/A"}',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.Text('Posted: ${token?['userName'] ?? ""}',
                  style: pw.TextStyle(fontSize: 10)),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.SvgImage(svg: svgBarcode),
          )
        ],
      ),
    );

    return await pdf.save();
  }

  // ✅ If testItems exist, continue with normal rendering
  final List<List<Map<String, dynamic>>> chunks = testItems.slices(14).toList();

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
                pw.SizedBox(width: 110),
                pw.Container(
                  padding: pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(5),
                    border: pw.Border.all(
                        color: PdfColors.black,
                        width: 0.5,
                        style: pw.BorderStyle.dashed),
                  ),
                  child: pw.Text('Preview Mode'),
                ),
                pw.SizedBox(
                  width: 100,
                  child: pw.Text(
                    'Date: ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 8),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Column(children: [
              pw.Row(children: [
                _infoRow("Patient Name", patientName, flex: 6),
                _infoRow("Age", age, flex: 2),
              ]),
              pw.Row(children: [
                _infoRow("Patient Number", patientPhone, flex: 6),
                _infoRow("Sex", sex, flex: 2),
              ]),
              pw.Row(children: [
                _infoRow(
                    "Referred by", referredBy == "null" ? "Self" : referredBy,
                    flex: 6),
              ]),
            ]),
            pw.SizedBox(height: 20),
          ],

          // ✅ Test table
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
                    top: pw.BorderSide(
                        color: PdfColors.black, width: 0.5, style: pw.BorderStyle.dashed),
                    bottom: pw.BorderSide(
                        color: PdfColors.black, width: 0.5, style: pw.BorderStyle.dashed),
                  ),
                ),
                children: [
                  pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text('St.', style: pw.TextStyle(fontSize: 10))),
                  pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text('Test Name', style: pw.TextStyle(fontSize: 10))),
                  pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text('Discount(%)',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 10))),
                  pw.Container(
                      alignment: pw.Alignment.centerLeft,
                      padding: pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text('Test Cost',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 10))),
                ],
              ),
              ...currentItems.asMap().entries.map((entry) {
                final index = entry.key + (i * 14);
                final test = entry.value;

                final double rate = (test['rate'] ?? 0).toDouble();
                final double discountPercent = (test['discountPercentage'] ?? 0).toDouble();
                final bool discountApplied = (test['discountApplied'] ?? 0) != 0;
                final double discountAmount =
                discountApplied ? rate * (discountPercent / 100) : 0.0;
                final double total = test['total'];

                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.5,
                          style: pw.BorderStyle.dashed),
                    ),
                  ),
                  children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('${index + 1}',
                            style: pw.TextStyle(fontSize: 10))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text(test['name'] ?? "N/A",
                            style: pw.TextStyle(fontSize: 10))),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(4),
                      child: pw.Text(
                        (discountAmount == 0) ? "" : discountAmount.toStringAsFixed(2),
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Container(
                      alignment: pw.Alignment.centerLeft,
                      padding: pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(
                        formatNumberAll(total),
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),


          if (isLastPage) ...[
            pw.SizedBox(height: 5),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.SizedBox(
                  width: 200,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("In Words: Zero Taka Only",
                          style: pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ),
                pw.SizedBox(
                  width: 140,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _totalRow("Total Amount", totalAmount),
                      _totalRow("Net Amount", totalAmount),
                      _totalRow("Received Amount", paidAmount),
                      _totalRow("Due Amount", dueAmount, color: PdfColors.red),
                      pw.Container(height: 1, color: PdfColors.black),
                    ],
                  ),
                ),
              ],
            ),
          ],
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Delivery Date: ${dateDeliveryReport.isNotEmpty ? dateDeliveryReport : "N/A"} - ${timeDeliveryReport.isNotEmpty ? timeDeliveryReport : "N/A"}',
                style: pw.TextStyle(fontSize: 8),
              ),
              pw.Text('Posted: ${token?['userName'] ?? ""}',
                  style: pw.TextStyle(fontSize: 8)),
            ],
          ),
          pw.Center(
            child: pw.SvgImage(svg: svgBarcode),
          )
        ],
      ),
    );
  }

  return await pdf.save();
}
