import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/configs/app_colors.dart';
import '../../../../core/utilities/load_image_bytes.dart';
import '../../../profile/data/model/profile_perrmission_model.dart';
import '../../../profile/presentation/bloc/profile_bloc/profile_bloc.dart';
import 'report_core.dart';

/// Statement ধরনের অংশ (যেমন Profit & Loss) — বাঁয়ে নাম, ডানে অঙ্ক
class ReportPdfSection {
  final String title;
  final List<ReportPdfLine> lines;

  const ReportPdfSection(this.title, this.lines);
}

class ReportPdfLine {
  final String label;
  final String value;
  final bool bold;
  final bool indent;
  final Color? color;

  const ReportPdfLine(this.label, this.value, {this.bold = false, this.indent = false, this.color});
}

/// সব report এর একই PDF নকশা:
///  - প্রতি page এর উপরে company (logo, নাম, ঠিকানা) + report নাম + সময়সীমা
///  - প্রথম page এ summary box
///  - table — পরের page এ গেলে column এর নাম আবার উপরে আসে
///  - শেষে মোট হিসাব, নিচে "Page x of y"
class ReportPdf {
  ReportPdf._();

  static const _ink = PdfColor.fromInt(0xFF0F172A);
  static const _muted = PdfColor.fromInt(0xFF64748B);
  static const _line = PdfColor.fromInt(0xFFE2E8F0);
  static const _zebra = PdfColor.fromInt(0xFFF8FAFC);

  static PdfColor _pdf(Color c) => PdfColor.fromInt(c.toARGB32());

  static Future<Uint8List> build<T>({
    required String title,
    required String period,
    BusinessInfo? company,
    Color accent = const Color(0xFF2563EB),
    List<ReportStat> stats = const [],
    List<ReportColumn<T>>? columns,
    List<T> rows = const [],
    List<ReportTotal> totals = const [],
    List<ReportPdfSection> sections = const [],
    String? note,
    bool? landscape,
  }) async {
    final cols = (columns ?? const []).where((c) => c.inPdf).toList();
    final isLandscape = landscape ?? cols.length > 7;
    final format = isLandscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;
    final accentPdf = _pdf(accent);

    final theme = await _theme();
    Uint8List? logo;
    final logoUrl = company?.logo?.toString();
    if (logoUrl != null && logoUrl.isNotEmpty) {
      final bytes = await loadImageBytes(logoUrl);
      if (bytes.isNotEmpty) logo = bytes;
    }

    final widths = <int, pw.TableColumnWidth>{
      for (var i = 0; i < cols.length; i++) i: pw.FlexColumnWidth(cols[i].flex.toDouble()),
    };

    pw.Widget headerRow() => pw.Table(
          columnWidths: widths,
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: accentPdf),
              children: [
                for (final c in cols)
                  _cell(c.label, align: _align(c), bold: true, color: PdfColors.white, size: 8.5),
              ],
            ),
          ],
        );

    final doc = pw.Document(theme: theme, title: title, author: company?.name);
    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.fromLTRB(28, 24, 28, 24),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _companyHeader(company, logo, title, period, accentPdf),
            pw.SizedBox(height: 12),
            // পরের page গুলোতে table এর column নাম আবার
            if (ctx.pageNumber > 1 && cols.isNotEmpty) headerRow(),
          ],
        ),
        footer: (ctx) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 10),
          padding: const pw.EdgeInsets.only(top: 6),
          decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: _line, width: 0.6))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('${company?.name ?? ''}  ·  $title', style: const pw.TextStyle(fontSize: 7.5, color: _muted)),
              pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                  style: const pw.TextStyle(fontSize: 7.5, color: _muted)),
            ],
          ),
        ),
        build: (ctx) => [
          if (stats.isNotEmpty) ...[
            _stats(stats),
            pw.SizedBox(height: 14),
          ],
          for (final s in sections) ...[
            _section(s, accentPdf),
            pw.SizedBox(height: 12),
          ],
          if (cols.isNotEmpty) ...[
            headerRow(),
            pw.Table(
              columnWidths: widths,
              border: const pw.TableBorder(
                bottom: pw.BorderSide(color: _line, width: 0.6),
                horizontalInside: pw.BorderSide(color: _line, width: 0.4),
              ),
              children: [
                for (var r = 0; r < rows.length; r++)
                  pw.TableRow(
                    decoration: r.isOdd ? const pw.BoxDecoration(color: _zebra) : null,
                    children: [
                      for (final c in cols)
                        _cell(
                          c.kind == ReportKind.serial ? '${r + 1}' : c.display(rows[r]),
                          align: _align(c),
                          bold: c.bold,
                          color: c.kind == ReportKind.status
                              ? _pdf(c.color?.call(rows[r]) ?? reportStatusColor(c.display(rows[r])))
                              : (c.color?.call(rows[r]) != null ? _pdf(c.color!(rows[r])!) : _ink),
                        ),
                    ],
                  ),
              ],
            ),
            if (rows.isEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.all(16),
                child: pw.Center(
                    child: pw.Text('No records for this period', style: const pw.TextStyle(color: _muted, fontSize: 9))),
              ),
          ],
          if (totals.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            _totals(totals, accentPdf),
          ],
          if (note != null) ...[
            pw.SizedBox(height: 10),
            pw.Text(note, style: const pw.TextStyle(fontSize: 8, color: _muted)),
          ],
        ],
      ),
    );
    return doc.save();
  }

  // ───────────── parts ─────────────

  static Future<pw.ThemeData> _theme() async {
    try {
      final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
      final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
      return pw.ThemeData.withFont(base: regular, bold: bold);
    } catch (_) {
      return pw.ThemeData.base();
    }
  }

  static pw.Alignment _align(ReportColumn c) => c.isNumeric
      ? pw.Alignment.centerRight
      : (c.kind == ReportKind.serial || c.kind == ReportKind.status)
          ? pw.Alignment.center
          : pw.Alignment.centerLeft;

  static pw.Widget _cell(String text,
      {pw.Alignment align = pw.Alignment.centerLeft, bool bold = false, PdfColor color = _ink, double size = 8.5}) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: pw.Text(
        text,
        maxLines: 2,
        textAlign: align == pw.Alignment.centerRight
            ? pw.TextAlign.right
            : align == pw.Alignment.center
                ? pw.TextAlign.center
                : pw.TextAlign.left,
        style: pw.TextStyle(fontSize: size, color: color, fontWeight: bold ? pw.FontWeight.bold : null),
      ),
    );
  }

  static pw.Widget _companyHeader(
      BusinessInfo? company, Uint8List? logo, String title, String period, PdfColor accent) {
    final contact = [company?.phone, company?.email].where((e) => e != null && e.trim().isNotEmpty).join('  ·  ');
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: accent, width: 2))),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (logo != null) ...[
            pw.Container(
              width: 44,
              height: 44,
              child: pw.Image(pw.MemoryImage(logo), fit: pw.BoxFit.contain),
            ),
            pw.SizedBox(width: 10),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(company?.name ?? '',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _ink)),
                if ((company?.address ?? '').trim().isNotEmpty)
                  pw.Text(company!.address!, style: const pw.TextStyle(fontSize: 8, color: _muted)),
                if (contact.isNotEmpty) pw.Text(contact, style: const pw.TextStyle(fontSize: 8, color: _muted)),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(title.toUpperCase(),
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: accent, letterSpacing: 0.6)),
              pw.SizedBox(height: 3),
              pw.Text(period, style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _ink)),
              pw.Text('Generated ${ReportFmt.dateTime(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 7.5, color: _muted)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _stats(List<ReportStat> stats) {
    // এক সারিতে সর্বোচ্চ ৫টা box
    final rows = <List<ReportStat>>[];
    for (var i = 0; i < stats.length; i += 5) {
      rows.add(stats.sublist(i, i + 5 > stats.length ? stats.length : i + 5));
    }
    return pw.Column(
      children: [
        for (final row in rows)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              children: [
                for (var i = 0; i < row.length; i++) ...[
                  if (i > 0) pw.SizedBox(width: 6),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.fromLTRB(8, 6, 8, 6),
                      decoration: pw.BoxDecoration(
                        color: _zebra,
                        border: pw.Border(left: pw.BorderSide(color: _pdf(row[i].color), width: 2.5)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(row[i].label, style: const pw.TextStyle(fontSize: 7.5, color: _muted)),
                          pw.SizedBox(height: 2),
                          pw.Text(row[i].value.replaceAll('৳', 'Tk'),
                              style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold, color: _ink)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  static pw.Widget _section(ReportPdfSection s, PdfColor accent) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          color: accent,
          child: pw.Text(s.title, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
        ),
        for (var i = 0; i < s.lines.length; i++)
          pw.Container(
            padding: pw.EdgeInsets.fromLTRB(s.lines[i].indent ? 18 : 6, 5, 6, 5),
            decoration: pw.BoxDecoration(
              color: s.lines[i].bold ? _zebra : null,
              border: const pw.Border(bottom: pw.BorderSide(color: _line, width: 0.4)),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(s.lines[i].label,
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: s.lines[i].bold ? pw.FontWeight.bold : null, color: _ink)),
                ),
                pw.Text(s.lines[i].value.replaceAll('৳', 'Tk'),
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: s.lines[i].bold ? pw.FontWeight.bold : null,
                      color: s.lines[i].color != null ? _pdf(s.lines[i].color!) : _ink,
                    )),
              ],
            ),
          ),
      ],
    );
  }

  static pw.Widget _totals(List<ReportTotal> totals, PdfColor accent) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 260,
        decoration: pw.BoxDecoration(border: pw.Border.all(color: accent, width: 0.8)),
        child: pw.Column(
          children: [
            for (var i = 0; i < totals.length; i++)
              pw.Container(
                color: i == totals.length - 1 ? _zebra : null,
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text(totals[i].label, style: const pw.TextStyle(fontSize: 9, color: _muted))),
                    pw.Text(totals[i].value.replaceAll('৳', 'Tk'),
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                          color: totals[i].color != null ? _pdf(totals[i].color!) : _ink,
                        )),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Company info (logo, নাম, ঠিকানা) — login এর পর profile থেকে আসে
BusinessInfo? reportCompany(BuildContext context) {
  try {
    return context.read<ProfileBloc>().permissionModel?.data?.businessInfo;
  } catch (_) {
    return null;
  }
}

/// PDF দেখা / print / save — সব report এ একই preview
void openReportPdf(
  BuildContext context, {
  required String title,
  required Future<Uint8List> Function() build,
}) {
  final fileName = '${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}'
      '_${DateTime.now().toIso8601String().substring(0, 10)}.pdf';
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) => Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: AppColors.primaryColor(ctx),
          foregroundColor: Colors.white,
        ),
        body: PdfPreview(
          build: (_) => build(),
          pdfFileName: fileName,
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
          allowSharing: true,
          allowPrinting: true,
          loadingWidget: const Center(child: CircularProgressIndicator()),
          pdfPreviewPageDecoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
        ),
      ),
    ),
  );
}
