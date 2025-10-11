import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

import '../../../feature/common/data/models/print_layout_model.dart';
import '../../utilities/parse_html_contact.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../app_routes.dart';

// Function to show PDF in a dialog
Future<void> showInvoiceStickerDialog(
    BuildContext context, {
      required Future<Uint8List> pdfDataFuture,
    }) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.all(20),
        title: const Text(
          'Sticker Preview',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SizedBox(
          width: 600, // adjust width as needed
          height: 600, // adjust height as needed
          child: PdfPreview(
            actions: [
              IconButton(
                onPressed: () =>
                    AppRoutes.pop(context),
                icon: const Icon(Icons.cancel,
                    color: Colors.red),
              ),
            ],

            build: (format) => pdfDataFuture,
            allowPrinting: true,
            allowSharing: true,
            canChangePageFormat: false,
            canDebug: false,
            canChangeOrientation: false,
          ),
        ),

      );
    },
  );
}

Future<Uint8List> generateInvoiceStickerPdf({
  required PdfPageFormat format,
  required String invoiceNumber,
  required String hnNumber,
  required String patientName,
  required String collectorName,
  required String dob,
  required String create,
  required String genderAge,
  required List<String> selectedTests,
  required PrintLayoutModel printLayoutModel,
}) async {
  final billingJson = printLayoutModel.sticker != null
      ? jsonDecode(printLayoutModel.sticker!)
      : {};

  // --- Size / Units ---
  final width = (billingJson['width'] ?? 2.5).toDouble();
  final height = (billingJson['height'] ?? 1.5).toDouble();
  final widthUnit = billingJson['widthUnit'] ?? 'inch';
  final heightUnit = billingJson['heightUnit'] ?? 'inch';

  double convertUnit(double value, String unit) {
    switch (unit.toLowerCase()) {
      case 'mm':
        return value * (PdfPageFormat.mm); // mm → PDF points
      case 'cm':
        return value * 10 * (PdfPageFormat.mm); // cm → mm → PDF points
      case 'inch':
      case 'in':
        return value * PdfPageFormat.inch; // inches → PDF points
      default:
        return value; // fallback
    }
  }
  double convertUnitScaled(double value, String unit, {double scale = 25.0}) {
    switch (unit.toLowerCase()) {
      case 'mm': return value * PdfPageFormat.mm * scale;
      case 'cm': return value * 10 * PdfPageFormat.mm * scale;
      case 'inch':
      case 'in': return value * PdfPageFormat.inch * scale;
      default: return value * scale;
    }
  }


  // --- Fonts ---
  Map<String, dynamic> fontSize = billingJson['fontSize'] ?? {};
  Map<String, dynamic> fontWeight = billingJson['fontWeight'] ?? {};
  pw.TextStyle textStyle(String key) {
    return pw.TextStyle(
      fontSize: parseFontSize((fontSize[key] ?? 8).toString()),
      fontWeight: (fontWeight[key] == "bold")
          ? pw.FontWeight.bold
          : pw.FontWeight.normal,
    );
  }

  // --- Barcode ---
  final barcodeSettings = billingJson['barcodeSettings'] ?? {};
  final barcodeWidth = (barcodeSettings['width'] ?? 1.5).toDouble();
  final barcodeHeight = (barcodeSettings['height'] ?? 30).toDouble();
  final barcode = pw.Barcode.code128();
  final pageWidth = convertUnit(width, widthUnit);
  final pageHeight = convertUnit(height, heightUnit);
  // --- Content Spacing ---
  final contentSpacing = billingJson['contentSpacing'] ?? {};
  final displayValue = (billingJson['displayValue'] ?? false) as bool;
  final padding = (contentSpacing['padding'] ?? 4).toDouble();
  final marginH = (contentSpacing['marginHorizontal'] ?? 8).toDouble();
  final barcodeWidthPt = convertUnitScaled(barcodeWidth,widthUnit);
  final pdf = pw.Document();

// Preview: show all stickers together
  pdf.addPage(
    pw.MultiPage(
      build: (context) {
        return selectedTests.map((test) {



          final svgBarcode = barcode.toSvg(
            invoiceNumber,
            width: barcodeWidthPt,
            height: barcodeHeight,
            drawText: displayValue,
          );

          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 5),
            padding: pw.EdgeInsets.all(padding),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(patientName, style: textStyle('patientName')),
                    pw.Flexible(
                      child: pw.Text(
                        test,
                        style: textStyle('testName'),
                        textAlign: pw.TextAlign.right,
                        softWrap: false, // <- ensures 1 line only
                        overflow: pw.TextOverflow.clip, // or .ellipsis to show "..."
                      ),
                    ),
                  ],
                ),

                // pw.Row(
                //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                //   children: [
                //     pw.Text(patientName, style: textStyle('patientName')),
                //     pw.Expanded(
                //       child: pw.Text(
                //         test,
                //         style: textStyle('testName'),
                //         textAlign: pw.TextAlign.right,maxLines: 1,
                //       ),
                //     ),
                //   ],
                // ),
                pw.SizedBox(height: 1),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(invoiceNumber, style: textStyle('invoiceNo')),
                    pw.Text('$dob $genderAge', style: textStyle('dateInfo')),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Center(child: pw.SvgImage(svg: svgBarcode)),
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Col: $create',
                        style: textStyle('collectionInfo')),
                    pw.Text('By: $collectorName',
                        style: textStyle('collectionInfo')),
                  ],
                ),
              ],
            ),
          );
        }).toList();
      },
    ),
  );
  final printPdf = pw.Document();

// Printing: create **one page per sticker**
  for (final test in selectedTests) {
    final svgBarcode = barcode.toSvg(
      invoiceNumber,
      width: barcodeWidthPt,
      height: barcodeHeight,
      drawText: displayValue,
    );
    printPdf.addPage(pw.Page(
      pageFormat: PdfPageFormat(pageWidth, pageHeight),
      build: (context) => pw.Container(
        margin: pw.EdgeInsets.symmetric(horizontal: marginH),
        padding: pw.EdgeInsets.all(padding/2),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.white),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Patient + Test Name
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(patientName, style: textStyle('patientName')),
                pw.Flexible(
                  child: pw.Text(
                    test,
                    style: textStyle('testName'),
                    textAlign: pw.TextAlign.right,
                    softWrap: false, // <- ensures 1 line only
                    overflow: pw.TextOverflow.clip, // or .ellipsis to show "..."
                  ),
                ),
              ],
            ),

            // pw.Row(
            //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            //   children: [
            //     pw.Text(patientName, style: textStyle('patientName')),
            //     pw.Expanded(
            //       child: pw.Text(
            //         test,
            //         style: textStyle('testName'),
            //         textAlign: pw.TextAlign.right,
            //       ),
            //     ),
            //   ],
            // ),
            pw.SizedBox(height: 1),

            // Invoice + DOB/Gender
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(invoiceNumber, style: textStyle('invoiceNo')),
                pw.Text('$dob $genderAge', style: textStyle('dateInfo')),
              ],
            ),
            pw.Spacer(),

            pw.SizedBox(height: 2),

            // Barcode
            pw.Center(
                child: pw.SvgImage(
              svg: svgBarcode,
            )),
            pw.SizedBox(height: 2),

            pw.Spacer(),
            // Collection Info
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Col: $create', style: textStyle('collectionInfo')),
                pw.Text('By: $collectorName',
                    style: textStyle('collectionInfo')),
              ],
            ),
          ],
        ),
      ),
    ));
  }

  return await printPdf.save();
}
