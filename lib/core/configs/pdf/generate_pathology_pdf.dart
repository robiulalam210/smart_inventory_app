import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';

import '../../../feature/common/data/models/print_layout_model.dart';
import '../../../feature/lab_technologist/data/model/single_report_model.dart';
import '../../../feature/lab_technologist/data/model/single_test_parameter_model.dart';
import '../../utilities/page_format.dart';
import '../../utilities/parse_html_contact.dart';
import '../../utilities/pdf_margin_matgin_to_points.dart';

Future<Uint8List> generatePathologyPdf(
bool isRadiology,  BuildContext context,
    Report? testInfo,
  String hnNo,
  String patientName,
  String gender,
  String dob,
  String billDate,
  List<Detail> details,
  final PrintLayoutModel layout,
) async {
  // --- Helper function must be declared first ---
  pw.Widget buildPatientInfo({
    required String label,
    required String value,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 80,
          child: pw.Text('$label: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        ),
        pw.SizedBox(
            width: 110,
            child: pw.Text(value,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      ],
    );
  }

  // Decode JSON
  final billingJson = layout.letter != null ? jsonDecode(layout.letter!) : {};
  final pageType = billingJson['pageType'] ?? 'blank-page';

  final pageSize = billingJson['pageSize'] ?? 'A4';
  final margins = billingJson['margins'] ??
      {'left': 0.2, 'right': 0.2, 'top': 0.2, 'bottom': 0.2};
  final marginUnit = billingJson['marginUnit'] ?? 'Inch';

  final headerData = billingJson['headerData'] ?? {};
  final isHeaderApplicable = headerData['isHeaderApplicable'] ?? false;
  final headerContent = headerData['header_content'] ?? '';
  final footerData = billingJson['footerData'] ?? {};
  final isFooterApplicable = footerData['isFooterApplicable'] ?? false;
  final footerContent = footerData['footer_content'] ?? '';

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

  final pdf = pw.Document();
  final format = getPageFormat(pageSize);
  final roboto = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
  final robotoBold = pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Bold.ttf"));
  final fontRegular =
  pw.Font.ttf(await rootBundle.load("assets/fonts/Roboto-Regular.ttf"));
  pdf.addPage(
    pw.MultiPage(

      pageTheme: pw.PageTheme(
        theme: pw.ThemeData.withFont(
          base: roboto,
          bold: robotoBold,
          // fontFallback: [roboto],
          fontFallback: [fontRegular],// fallback for symbols/unicode
        ),
        pageFormat: format,
        margin: pw.EdgeInsets.fromLTRB(
            leftMargin, topMargin, rightMargin, bottomMargin),
        buildBackground: (context) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(color: PdfColors.white),
        ),
      ),
      header: (context) {
        if (!isHeaderApplicable ||
            headerContent.isEmpty ||
            pageType != "blank-page") {
          return pw.SizedBox(height: 5);
        }
        return parseHtmlContent(headerContent, pageFormat: format);
      },
      footer: (context) {
        if (!isFooterApplicable || footerContent.isEmpty) {
          return  pw.SizedBox(height: 5);
        }
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 10),
          child: parseHtmlContent(footerContent, pageFormat: format),
        );
      },
      build: (context) => [
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            isRadiology ? "RADIOLOGY REPORT" : 'PATHOLOGY REPORT',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 8),

        // Patient Info Table
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
          ),
          padding: const pw.EdgeInsets.all(8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  buildPatientInfo(label: 'Patient Name', value: patientName),
                  buildPatientInfo(
                      label: 'Sample Date',
                      value:""),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  buildPatientInfo(label: 'Patient ID', value: hnNo),
                  buildPatientInfo(
                      label: 'Report Date',
                      value: ""),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  buildPatientInfo(label: 'Age', value: dob),
                  buildPatientInfo(label: 'Report Status', value: hnNo),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  buildPatientInfo(label: 'Sex', value: gender),
                  buildPatientInfo(label: 'Branch Name', value: hnNo),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  buildPatientInfo(label: 'Reference By', value: patientName),
                  buildPatientInfo(label: 'Specimen', value: testInfo?.specimen?.name??""),
                ],
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 16),

        // Render radiology HTML content if applicable
        if (isRadiology && (testInfo?.radiologyReportDetails ?? "").isNotEmpty)
        pw.Container(
          constraints: const pw.BoxConstraints(minHeight: 20), // limit growth
          child: parseHtmlContent(testInfo!.radiologyReportDetails!, pageFormat: format),
        ),

        pw.SizedBox(height: 16),
        if (!isRadiology)

        // Test table
          pw.TableHelper.fromTextArray(
            headers: ['Test Name', 'Result', 'Unit', 'Normal Value'],
            data: details.map((e) => [
              e.parameterName ?? '',
              e.result ?? '',
              e.parameter?.parameterUnit ?? '',
              e.parameter?.options != null
                  ? e.parameter!.options!.map((o) => o.toString()).join(', ')
                  : '',
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: pw.TextStyle(fontSize: 10), // smaller font
            cellAlignment: pw.Alignment.centerLeft,
            columnWidths: {
              0: pw.FlexColumnWidth(3), // Test Name
              1: pw.FlexColumnWidth(2), // Result
              2: pw.FlexColumnWidth(1), // Unit
              3: pw.FlexColumnWidth(4), // Normal Value (long text)
            },
            cellPadding: const pw.EdgeInsets.all(4),
            border: pw.TableBorder.all(color: PdfColors.grey),
            // optional: wrap text in cells
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.center,
              3: pw.Alignment.centerLeft,
            },
          ),

      ],

    ),
  );

  return await pdf.save();
}

Future<Uint8List> generatePathologyPdfDraft(
bool isRadiology,    BuildContext context,
    TestName? testInfo,
    String hnNo,
    String patientName,
    String gender,
    String dob,
    String billDate,
    List<Detail> details,
    final PrintLayoutModel layout,
    radiologyReportDetails,

    ) async {
  // --- Helper function must be declared first ---
  pw.Widget buildPatientInfo({
    required String label,
    required String value,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 80,
          child: pw.Text('$label: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        ),
        pw.SizedBox(
            width: 110,
            child: pw.Text(value,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      ],
    );
  }

  // Decode JSON
  final billingJson = layout.letter != null ? jsonDecode(layout.letter!) : {};
  final pageType = billingJson['pageType'] ?? 'blank-page';

  final pageSize = billingJson['pageSize'] ?? 'A4';
  final margins = billingJson['margins'] ??
      {'left': 0.2, 'right': 0.2, 'top': 0.2, 'bottom': 0.2};
  final marginUnit = billingJson['marginUnit'] ?? 'Inch';

  final headerData = billingJson['headerData'] ?? {};
  final isHeaderApplicable = headerData['isHeaderApplicable'] ?? false;
  final headerContent = headerData['header_content'] ?? '';
  final footerData = billingJson['footerData'] ?? {};
  final isFooterApplicable = footerData['isFooterApplicable'] ?? false;
  final footerContent = footerData['footer_content'] ?? '';

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

  final pdf = pw.Document();
  final format = getPageFormat(pageSize);

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: format,
        margin: pw.EdgeInsets.fromLTRB(
            leftMargin, topMargin, rightMargin, bottomMargin),
        buildBackground: (context) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(color: PdfColors.white),
        ),
      ),
      header: (context) {
        if (!isHeaderApplicable ||
            headerContent.isEmpty ||
            pageType != "blank-page") {
          return pw.SizedBox(height: 5);
        }
        return parseHtmlContent(headerContent, pageFormat: format);
      },
      footer: (context) {
        if (!isFooterApplicable || footerContent.isEmpty) {
          return  pw.SizedBox(height: 5);
        }
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 10),
          child: parseHtmlContent(footerContent, pageFormat: format),
        );
      },
      build: (context) => [
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            isRadiology ? "RADIOLOGY REPORT" : 'PATHOLOGY REPORT',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 8),

        // Patient Info Table
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
          ),
          padding: const pw.EdgeInsets.all(8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  buildPatientInfo(label: 'Patient Name', value: patientName),
                  buildPatientInfo(
                      label: 'Sample Date',
                      value: ""),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  buildPatientInfo(label: 'Patient ID', value: hnNo),
                  buildPatientInfo(
                      label: 'Report Date',
                      value: ""),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  buildPatientInfo(label: 'Age', value: dob),
                  buildPatientInfo(label: 'Report Status', value: hnNo),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  buildPatientInfo(label: 'Sex', value: gender),
                  buildPatientInfo(label: 'Branch Name', value: hnNo),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  buildPatientInfo(label: 'Reference By', value: patientName),
                  buildPatientInfo(label: 'Specimen', value: testInfo?.specimen?.name??""),
                ],
              ),

            ],
          ),
        ),

        pw.SizedBox(height: 16),

        // Render radiology HTML content if applicable
        if (isRadiology && (radiologyReportDetails ?? "").isNotEmpty)
          parseHtmlContent(radiologyReportDetails!, pageFormat: format),

        pw.SizedBox(height: 16),
        if (!isRadiology)

        // Test table TableHelper.fromTextArray
          pw.TableHelper.fromTextArray(
            headers: ['Test Name', 'Result', 'Unit', 'Normal Value'],
            data: details.map((e) => [
              e.parameterName ?? '',
              e.result ?? '',
              e.parameter?.parameterUnit ?? '',
              e.parameter?.options != null
                  ? e.parameter!.options!.map((o) => o.toString()).join(', ')
                  : '',
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: pw.TextStyle(fontSize: 10), // smaller font
            cellAlignment: pw.Alignment.centerLeft,
            columnWidths: {
              0: pw.FlexColumnWidth(3), // Test Name
              1: pw.FlexColumnWidth(2), // Result
              2: pw.FlexColumnWidth(1), // Unit
              3: pw.FlexColumnWidth(4), // Normal Value (long text)
            },
            cellPadding: const pw.EdgeInsets.all(4),
            border: pw.TableBorder.all(color: PdfColors.grey),
            // optional: wrap text in cells
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.center,
              3: pw.Alignment.centerLeft,
            },
          ),

      ],

    ),
  );

  return await pdf.save();
}
