import 'dart:typed_data';

import 'package:meherinMart/core/core.dart';
import 'package:meherinMart/core/widgets/app_scaffold.dart';
import 'package:meherinMart/core/widgets/web_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/stock_models.dart';
import 'stock_kit.dart';

class _LabelRow {
  final ProductHit product;
  int count;
  _LabelRow(this.product) : count = 1;
}

const int _maxEach = 500;
const int _maxTotal = 2000;

/// Barcode Labels — অনেক পণ্যের বার্কোড লেবেল একসাথে সাজিয়ে প্রিন্ট (A4 এ)।
/// পণ্য যোগ করুন (নাম/SKU বা scanner), প্রতিটার কয়টা লাগবে লিখুন, প্রতি সারিতে কয়টা ঠিক করে Print।
class LabelPrintScreen extends StatefulWidget {
  final bool showAppBar;
  const LabelPrintScreen({super.key, this.showAppBar = true});

  @override
  State<LabelPrintScreen> createState() => _LabelPrintScreenState();
}

class _LabelPrintScreenState extends State<LabelPrintScreen> {
  final List<_LabelRow> _rows = [];
  final Map<int, TextEditingController> _ctrls = {};
  int _cols = 4;
  bool _showName = true;
  bool _showPrice = true;

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _total => _rows.fold(0, (s, r) => s + r.count);

  void _add(ProductHit p) {
    final i = _rows.indexWhere((r) => r.product.id == p.id);
    setState(() {
      if (i >= 0) {
        _rows[i].count = (_rows[i].count + 1).clamp(1, _maxEach);
        _ctrls[p.id]?.text = '${_rows[i].count}';
      } else {
        _rows.add(_LabelRow(p));
        _ctrls[p.id] = TextEditingController(text: '1');
      }
    });
  }

  void _remove(int index) {
    final r = _rows.removeAt(index);
    _ctrls.remove(r.product.id)?.dispose();
    setState(() {});
  }

  void _clear() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    _ctrls.clear();
    setState(() => _rows.clear());
  }

  void _setCount(_LabelRow r, String t) {
    final v = int.tryParse(t.trim());
    setState(() => r.count = v == null ? 1 : v.clamp(1, _maxEach));
  }

  void _openPreview() {
    if (_total == 0) return;
    final rows = [for (final r in _rows) (product: r.product, count: r.count)];
    final cols = _cols;
    final showName = _showName;
    final showPrice = _showPrice;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Barcode labels')),
          body: PdfPreview(
            build: (_) => buildLabelsPdf(rows, cols: cols, showName: showName, showPrice: showPrice),
            canChangeOrientation: false,
            canChangePageFormat: false,
            pdfFileName: 'barcode-labels.pdf',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StockScaffold(
      title: 'Barcode Labels',
      subtitle: 'Print labels for many products at once',
      showAppBar: widget.showAppBar,
      body: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 900;
        final pad = wide ? 24.0 : 12.0;
        final list = _buildList(context);
        final side = _buildOptions(context);
        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: list),
                    const SizedBox(width: 16),
                    SizedBox(width: 320, child: side),
                  ],
                )
              : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [list, const SizedBox(height: 12), side]),
        );
      }),
    );
  }

  Widget _buildList(BuildContext context) {
    return WPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WPanelHead('Products'),
          const SizedBox(height: 12),
          ProductPicker(onPicked: _add),
          const SizedBox(height: 12),
          if (_rows.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: W.line(context)),
                borderRadius: BorderRadius.circular(W.rMd),
              ),
              child: Text('Search above and add the products you want labels for.',
                  textAlign: TextAlign.center, style: TextStyle(color: W.muted(context))),
            )
          else
            for (var i = 0; i < _rows.length; i++)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                decoration: BoxDecoration(
                  color: W.soft(context),
                  border: Border.all(color: W.line(context)),
                  borderRadius: BorderRadius.circular(W.rMd),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_rows[i].product.name,
                              style: const TextStyle(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(_rows[i].product.sku, style: TextStyle(fontSize: 12, color: W.muted(context))),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _ctrls[_rows[i].product.id],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (t) => _setCount(_rows[i], t),
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(W.rMd)),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => _remove(i),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    return WPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WPanelHead('Layout'),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _cols,
            decoration: InputDecoration(
              labelText: 'Labels per row',
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(W.rMd)),
            ),
            items: [for (final c in const [2, 3, 4, 5, 6]) DropdownMenuItem(value: c, child: Text('$c'))],
            onChanged: (v) => setState(() => _cols = v ?? 4),
          ),
          CheckboxListTile(
            value: _showName,
            onChanged: (v) => setState(() => _showName = v ?? true),
            title: const Text('Show product name'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            value: _showPrice,
            onChanged: (v) => setState(() => _showPrice = v ?? true),
            title: const Text('Show price'),
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const Divider(),
          Text('$_total labels · ${_rows.length} products',
              style: TextStyle(color: W.muted(context), fontWeight: FontWeight.w600)),
          if (_total > _maxTotal)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Only the first $_maxTotal labels will print.', style: TextStyle(color: W.amberInk(context), fontSize: 12.5)),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _total == 0 ? null : _openPreview,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 46)),
            icon: const Icon(Icons.print_rounded, size: 20),
            label: const Text('Preview & print'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _rows.isEmpty ? null : _clear, child: const Text('Clear all')),
        ],
      ),
    );
  }
}

/// A4 এ লেবেলের জাল — প্রতিটা: নাম, বার্কোড (Code 128, SKU), দাম
Future<Uint8List> buildLabelsPdf(
  List<({ProductHit product, int count})> rows, {
  required int cols,
  required bool showName,
  required bool showPrice,
}) async {
  final doc = pw.Document();
  final format = PdfPageFormat.a4;
  const margin = 10 * PdfPageFormat.mm;
  const gap = 3 * PdfPageFormat.mm;
  final labelW = (format.width - margin * 2 - gap * (cols - 1)) / cols - 0.5;
  final barH = cols >= 5 ? 26.0 : 34.0;
  final nameSize = cols >= 5 ? 7.0 : 8.5;
  final code = pw.Barcode.code128();

  final labels = <pw.Widget>[];
  for (final r in rows) {
    final p = r.product;
    final canDraw = p.sku.isNotEmpty && code.isValid(p.sku);
    for (var i = 0; i < r.count && labels.length < _maxTotal; i++) {
      labels.add(
        pw.Container(
          width: labelW,
          padding: const pw.EdgeInsets.fromLTRB(4, 5, 4, 4),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey500, width: 0.4)),
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (showName)
                pw.Text(p.name,
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: pw.TextStyle(fontSize: nameSize, fontWeight: pw.FontWeight.bold)),
              if (showName) pw.SizedBox(height: 2),
              if (canDraw)
                pw.BarcodeWidget(
                  barcode: code,
                  data: p.sku,
                  width: labelW - 10,
                  height: barH,
                  drawText: true,
                  textStyle: pw.TextStyle(fontSize: cols >= 5 ? 6 : 7),
                )
              else
                pw.Text(p.sku, style: const pw.TextStyle(fontSize: 8)),
              if (showPrice) pw.SizedBox(height: 2),
              if (showPrice)
                pw.Text('Tk ${p.price.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: nameSize + 1, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      );
    }
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: format,
      margin: const pw.EdgeInsets.all(margin),
      build: (_) => [pw.Wrap(spacing: gap, runSpacing: gap, children: labels)],
    ),
  );
  return doc.save();
}
