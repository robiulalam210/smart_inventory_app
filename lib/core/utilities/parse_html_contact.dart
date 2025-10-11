//
// import 'dart:convert';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';
// import 'package:html/parser.dart' as html_parser;
// import 'package:html/dom.dart' as dom;
//
// import '../configs/configs.dart';
//
// /// --- MAIN ENTRY ---
// pw.Widget parseHtmlContent(String html, {required PdfPageFormat pageFormat}) {
//   final document = html_parser.parse(html);
//   final body = document.body;
//   if (body == null) return pw.Text('No content');
//
//   var widgets = _parseHtmlNodes(body.nodes, pageFormat: pageFormat);
//   widgets = _trimBottomSpacing(widgets);
//
//   return pw.Column(
//     crossAxisAlignment: pw.CrossAxisAlignment.stretch,
//     mainAxisSize: pw.MainAxisSize.min,
//     children: widgets.map((w) {
//       if (w is pw.Table || w is pw.Image) {
//         return pw.Container(width: pageFormat.availableWidth, child: w);
//       }
//       return w;
//     }).toList(),
//   );
// }
// /// --- PARSE TEXT ALIGN ---
// pw.TextAlign parseTextAlign(dom.Element node) {
//   final styleMap = styleToMap(node.attributes['style'] ?? '');
//   String? align = styleMap['text-align']?.toLowerCase() ?? node.attributes['align']?.toLowerCase();
//
//   switch (align) {
//     case 'center':
//       return pw.TextAlign.center;
//     case 'right':
//       return pw.TextAlign.right;
//     case 'justify':
//       return pw.TextAlign.justify;
//     case 'left':
//     default:
//       return pw.TextAlign.left;
//   }
// }
//
// /// --- BLOCK NODE PARSING ---
// List<pw.Widget> _parseHtmlNodes(List<dom.Node> nodes,
//     {required PdfPageFormat pageFormat, pw.TextAlign? parentAlign}) {
//   final widgets = <pw.Widget>[];
//
//   for (final node in nodes) {
//     if (node is dom.Element) {
//       final textAlign = parseTextAlign(node);
//
//       switch (node.localName) {
//         case 'table':
//           widgets.add(parseTable(node, pageFormat: pageFormat));
//           break;
//
//         case 'p':
//         case 'div':
//         case 'strong':
//         case 'span':
//           var rich = pw.RichText(
//             textAlign: textAlign,
//             text: pw.TextSpan(
//               children: node.nodes
//                   .map((n) => _parseInlineNode(n,
//                   parentStyle: styleToMap(node.attributes['style'] ?? ''),
//                   parentAlign: textAlign))
//                   .toList(),
//               style: parseTextStyle(styleToMap(node.attributes['style'] ?? '')),
//             ),
//             textScaleFactor: 1.0, // keeps line spacing tight
//           );
//           widgets.add(rich);
//           break;
//
//         case 'br':
//           widgets.add(pw.SizedBox(height: 2)); // smaller gap
//           break;
//
//         default:
//           if (node.nodes.isNotEmpty) {
//             widgets.addAll(
//               _parseHtmlNodes(node.nodes,
//                   pageFormat: pageFormat, parentAlign: textAlign),
//             );
//           } else if (node.text.trim().isNotEmpty) {
//             widgets.add(pw.Text(node.text.trim(),
//                 textAlign: textAlign));
//           }
//       }
//     } else if (node is dom.Text) {
//       final t = node.text.trim();
//       if (t.isNotEmpty) widgets.add(pw.Text(t, textAlign: parentAlign));
//     }
//   }
//
//   return widgets;
// }
//
// /// --- INLINE NODE PARSING ---
// pw.TextSpan _parseInlineNode(dom.Node node,
//     {Map<String, String>? parentStyle, pw.TextAlign? parentAlign}) {
//   parentStyle ??= {};
//
//   if (node is dom.Text) {
//     final text = node.text.replaceAll('\u00A0', ' ');
//     if (text.isEmpty) return const pw.TextSpan(text: '');
//     return pw.TextSpan(text: text, style: parseTextStyle(parentStyle));
//   }
//
//   if (node is dom.Element) {
//     final style = {...parentStyle};
//     final styleAttr = node.attributes['style'];
//     if (styleAttr != null) style.addAll(styleToMap(styleAttr));
//
//     if (node.localName == 'b' || node.localName == 'strong') {
//       style['font-weight'] = 'bold';
//     }
//     if (node.localName == 'i' || node.localName == 'em') {
//       style['font-style'] = 'italic';
//     }
//     if (node.localName == 'br') return const pw.TextSpan(text: '\n');
//
//     final children = node.nodes
//         .map((n) =>
//         _parseInlineNode(n, parentStyle: style, parentAlign: parentAlign))
//         .toList();
//
//     return pw.TextSpan(children: children, style: parseTextStyle(style));
//   }
//
//   return const pw.TextSpan(text: '');
// }
//
// /// --- TABLE PARSING ---
// pw.Widget parseTable(dom.Element tableElement,
//     {required PdfPageFormat pageFormat}) {
//   final rows = tableElement.querySelectorAll('tr');
//   final tableRows = <pw.TableRow>[];
//
//   pw.Widget parseNode(dom.Node node,
//       {Map<String, String>? parentStyle, pw.TextAlign? parentAlign}) {
//     parentStyle ??= {};
//
//     if (node is dom.Text) {
//       final text = node.text.replaceAll('\n', ' ').trim();
//       if (text.isEmpty) return pw.SizedBox();
//       return pw.Text(text,
//           textAlign: parentAlign ?? pw.TextAlign.left,
//           style: parseTextStyle(parentStyle));
//     }
//
//     if (node is dom.Element) {
//       final style = {...parentStyle};
//       final styleAttr = node.attributes['style'];
//       if (styleAttr != null) style.addAll(styleToMap(styleAttr));
//
//       final textAlign = style['text-align'] == 'center'
//           ? pw.TextAlign.center
//           : style['text-align'] == 'right'
//           ? pw.TextAlign.right
//           : pw.TextAlign.left;
//
//       if (node.localName == 'br') return pw.SizedBox(height: 2);
//
//       if (node.localName == 'b' || node.localName == 'strong') {
//         style['font-weight'] = 'bold';
//       }
//       if (node.localName == 'i' || node.localName == 'em') {
//         style['font-style'] = 'italic';
//       }
//
//       if (node.localName == 'img') {
//         final src = node.attributes['src'] ?? '';
//         if (src.startsWith('data:image')) {
//           final base64Data = src.split(',')[1];
//           final image = pw.MemoryImage(base64Decode(base64Data));
//
//           final pxWidth =
//               extractPx(node.attributes['width']) ?? extractPxFromStyle(style['width']);
//           final pctWidth = style.containsKey('width') && style['width']!.contains('%')
//               ? double.tryParse(style['width']!.replaceAll(RegExp(r'[^0-9.]'), ''))
//               : null;
//
//           final maxAvail = pageFormat.availableWidth;
//           final finalWidth = pctWidth != null
//               ? (pctWidth / 100.0) * maxAvail
//               : pxWidth?.clamp(0, maxAvail).toDouble();
//
//           final pxHeight = extractPx(node.attributes['height'])?.toDouble() ??
//               extractPxFromStyle(style['height'])?.toDouble();
//
//           return pw.Container(
//               width: finalWidth,
//               height: pxHeight,
//               alignment: isCentered(style) ? pw.Alignment.center : null,
//               child: pw.Image(image,
//                   width: finalWidth, height: pxHeight, fit: pw.BoxFit.fitWidth));
//         } else {
//           return pw.Text('[Unsupported image]', textAlign: textAlign);
//         }
//       }
//
//       final children = node.nodes
//           .map((n) => parseNode(n, parentStyle: style, parentAlign: textAlign))
//           .toList();
//
//       if (children.isNotEmpty && children.last is pw.SizedBox) {
//         children.removeLast();
//       }
//
//       if (children.isEmpty) return pw.SizedBox();
//
//       return pw.Align(
//           alignment: textAlign == pw.TextAlign.center
//               ? pw.Alignment.center
//               : textAlign == pw.TextAlign.right
//               ? pw.Alignment.centerRight
//               : pw.Alignment.centerLeft,
//           child: pw.Column(
//               crossAxisAlignment: textAlign == pw.TextAlign.left
//                   ? pw.CrossAxisAlignment.start
//                   : textAlign == pw.TextAlign.center
//                   ? pw.CrossAxisAlignment.center
//                   : pw.CrossAxisAlignment.end,
//               mainAxisSize: pw.MainAxisSize.min,
//               children: children));
//     }
//
//     return pw.SizedBox();
//   }
//
//   for (var i = 0; i < rows.length; i++) {
//     final row = rows[i];
//     final cells = row.querySelectorAll('td, th');
//     final rowWidgets = <pw.Widget>[];
//     for (final cell in cells) {
//       final cellStyle = styleToMap(cell.attributes['style'] ?? '');
//       final content = parseNode(cell, parentStyle: cellStyle);
//
//       rowWidgets.add(pw.Container(
//         padding: pw.EdgeInsets.only(
//           top: 2,
//           bottom: (i == rows.length - 1) ? 0 : 2,
//           left: 2,
//           right: 2,
//         ),
//         child: content,
//       ));
//     }
//     tableRows.add(pw.TableRow(children: rowWidgets));
//   }
//
//   return pw.Table(children: tableRows);
// }
// /// --- EXTRACT PIXEL VALUES FROM ATTRIBUTES / STYLE ---
// double? extractPx(String? raw) {
//   if (raw == null) return null;
//   // remove non-digit characters like "px"
//   final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
//   return double.tryParse(cleaned);
// }
//
// double? extractPxFromStyle(String? style) {
//   if (style == null) return null;
//   final map = styleToMap(style);
//   final widthStr = map['width'];
//   if (widthStr == null) return null;
//   return extractPx(widthStr);
// }
// /// --- CONVERT CSS STYLE STRING TO MAP ---
// Map<String, String> styleToMap(String style) {
//   final map = <String, String>{};
//   if (style.isEmpty) return map;
//
//   for (final part in style.split(';')) {
//     final kv = part.split(':');
//     if (kv.length == 2) {
//       map[kv[0].trim().toLowerCase()] = kv[1].trim();
//     }
//   }
//   return map;
// }
// /// --- REMOVE EXTRA BOTTOM SPACING FROM COLUMN CHILDREN ---
// List<pw.Widget> _trimBottomSpacing(List<pw.Widget> children) {
//   // Remove trailing SizedBox widgets (common for <br> or spacing)
//   int end = children.length;
//   for (int i = children.length - 1; i >= 0; i--) {
//     final w = children[i];
//     if (w is pw.SizedBox) {
//       end = i;
//     } else {
//       break;
//     }
//   }
//   return children.sublist(0, end);
// }
//
// /// --- TEXT STYLE PARSING ---
// pw.TextStyle parseTextStyle(Map<String, String> style) {
//   return pw.TextStyle(
//     fontSize: style.containsKey('font-size')
//         ? double.tryParse(style['font-size']!.replaceAll(RegExp(r'[^0-9.]'), ''))
//         : 10,
//     fontWeight: style['font-weight'] == 'bold'
//         ? pw.FontWeight.bold
//         : pw.FontWeight.normal,
//     fontStyle: style['font-style'] == 'italic'
//         ? pw.FontStyle.italic
//         : pw.FontStyle.normal,
//     color: style.containsKey('color') ? parseColor(style['color']!) : PdfColors.black,
//     height: 1.0, // tight line height
//   );
// }
//
// PdfColor parseColor(String color) {
//   if (color.startsWith('#')) {
//     final hex = color.substring(1);
//     if (hex.length == 6) {
//       final r = int.parse(hex.substring(0, 2), radix: 16);
//       final g = int.parse(hex.substring(2, 4), radix: 16);
//       final b = int.parse(hex.substring(4, 6), radix: 16);
//       return PdfColor.fromInt((r << 16) + (g << 8) + b);
//     }
//   }
//   return PdfColors.black;
// }
//
// /// --- UTILITIES ---
// /// Parse font size string (like "12px", "1em") into double
// double parseFontSize(String? sizeStr, {double defaultSize = 10}) {
//   if (sizeStr == null || sizeStr.isEmpty) return defaultSize;
//   final cleaned = sizeStr.replaceAll(RegExp(r'[^0-9.]'), '');
//   double? parsed = double.tryParse(cleaned);
//   if (parsed == null) return defaultSize;
//   if (sizeStr.contains('px')) parsed *= 0.75; // px to pt conversion
//   return parsed.clamp(2, 72);
// }
//
//
//
//
//
//
// /// Check if style indicates centered content
// bool isCentered(Map<String, String> styleMap) =>
//     (styleMap['margin-left'] == 'auto' && styleMap['margin-right'] == 'auto') ||
//         styleMap['text-align'] == 'center';
//
// /// Remove trailing empty widgets (SizedBox) to avoid bottom gap
// List<pw.Widget> trimBottomSpacing(List<pw.Widget> children) {
//   int end = children.length;
//   for (int i = children.length - 1; i >= 0; i--) {
//     final w = children[i];
//     if (w is pw.SizedBox) {
//       end = i;
//     } else {
//       break;
//     }
//   }
//   return children.sublist(0, end);
// }


import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

/// --- MAIN ENTRY ---
pw.Widget parseHtmlContent(String html, {required PdfPageFormat pageFormat}) {
  final document = html_parser.parse(html);
  final body = document.body;
  if (body == null) return  pw.Text('No content');

  final widgets = _parseHtmlNodes(body.nodes, pageFormat: pageFormat);

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: widgets.map((w) {
      if (w is pw.Table || w is pw.Image) {
        return pw.Container(width: pageFormat.availableWidth, child: w);
      }
      return w;
    }).toList(),
  );
}

/// --- BLOCK NODE PARSING ---
List<pw.Widget> _parseHtmlNodes(List<dom.Node> nodes, {required PdfPageFormat pageFormat, pw.TextAlign? parentAlign}) {
  final widgets = <pw.Widget>[];

  for (final node in nodes) {
    if (node is dom.Element) {
      // Determine this node's alignment first
      final textAlign = parseTextAlign(node);

      switch (node.localName) {
        case 'table':
          widgets.add(parseTable(node, pageFormat: pageFormat));
          break;

        case 'p':
        case 'div':
        case 'strong':
        case 'span':
          widgets.add(
            pw.Padding(
              padding:  pw.EdgeInsets.zero, // Remove extra bottom spacing
              child: pw.RichText(
                textAlign: textAlign,
                text: pw.TextSpan(
                  children: node.nodes
                      .map((n) => _parseInlineNode(
                    n,
                    parentStyle: styleToMap(node.attributes['style'] ?? ''),
                    parentAlign: textAlign,
                  ))
                      .toList(),
                  style: parseTextStyle(styleToMap(node.attributes['style'] ?? '')),
                ),
              ),
            ),
          );
          break;

        case 'br':
          widgets.add(pw.SizedBox(height: 2));
          break;

        default:
          if (node.nodes.isNotEmpty) {
            widgets.addAll(
              _parseHtmlNodes(node.nodes,
                  pageFormat: pageFormat, parentAlign: textAlign),
            );
          } else if (node.text.trim().isNotEmpty) {
            widgets.add(
                pw.Text(node.text.trim(), textAlign: textAlign));
          }
      }
    } else if (node is dom.Text) {
      final t = node.text.trim();
      if (t.isNotEmpty) widgets.add(pw.Text(t, textAlign: parentAlign));
    }
  }

  return widgets;
}

/// --- INLINE NODE PARSING ---
pw.TextSpan _parseInlineNode(
    dom.Node node, {
      Map<String, String>? parentStyle,
      pw.TextAlign? parentAlign, // ✅ add this
    }) {
  parentStyle ??= {};

  if (node is dom.Text) {
    final text = node.text.replaceAll('\u00A0', ' ');
    if (text.isEmpty) return const pw.TextSpan(text: '');
    return pw.TextSpan(
      text: text,
      style: parseTextStyle(parentStyle),
    );
  }

  if (node is dom.Element) {
    final style = {...parentStyle};
    final styleAttr = node.attributes['style'];
    if (styleAttr != null) style.addAll(styleToMap(styleAttr));

    if (node.localName == 'b' || node.localName == 'strong') style['font-weight'] = 'bold';
    if (node.localName == 'i' || node.localName == 'em') style['font-style'] = 'italic';
    if (node.localName == 'br') return const pw.TextSpan(text: '\n');

    final children = node.nodes
        .map((n) => _parseInlineNode(
      n,
      parentStyle: style,
      parentAlign: parentAlign, // ✅ now valid
    ))
        .toList();

    return pw.TextSpan(children: children, style: parseTextStyle(style));
  }

  return const pw.TextSpan(text: '');
}


/// --- TABLE PARSING ---
pw.Widget parseTable(dom.Element tableElement, {required PdfPageFormat pageFormat}) {
  final rows = tableElement.querySelectorAll('tr');
  final tableRows = <pw.TableRow>[];

  // Recursive node parser
  pw.Widget parseNode(dom.Node node, {Map<String, String>? parentStyle, pw.TextAlign? parentAlign}) {
    parentStyle ??= {};

    if (node is dom.Text) {
      // Remove raw \n and trim text
      final text = node.text.replaceAll('\n', ' ').trim();
      if (text.isEmpty) return pw.SizedBox();
      return pw.Text(
        text,
        textAlign: parentAlign ?? pw.TextAlign.left,
        style: parseTextStyle(parentStyle),
      );
    }

    if (node is dom.Element) {
      final style = {...parentStyle};
      final styleAttr = node.attributes['style'];
      if (styleAttr != null) style.addAll(styleToMap(styleAttr));

      final textAlign = style['text-align'] == 'center'
          ? pw.TextAlign.center
          : style['text-align'] == 'right'
          ? pw.TextAlign.right
          : pw.TextAlign.left;

      if (node.localName == 'br') return pw.SizedBox(height: 4);

      if (node.localName == 'b' || node.localName == 'strong') style['font-weight'] = 'bold';
      if (node.localName == 'i' || node.localName == 'em') style['font-style'] = 'italic';

      if (node.localName == 'img') {
        final src = node.attributes['src'] ?? '';
        if (src.startsWith('data:image')) {
          final base64Data = src.split(',')[1];
          final image = pw.MemoryImage(base64Decode(base64Data));

          final pxWidth = extractPx(node.attributes['width']) ?? extractPxFromStyle(style['width']);
          final pctWidth = style.containsKey('width') && style['width']!.contains('%')
              ? double.tryParse(style['width']!.replaceAll(RegExp(r'[^0-9.]'), ''))
              : null;

          final maxAvail = pageFormat.availableWidth;
          final finalWidth = pctWidth != null
              ? (pctWidth / 100.0) * maxAvail
              : pxWidth?.clamp(0, maxAvail).toDouble();

          final pxHeight = extractPx(node.attributes['height'])?.toDouble() ??
              extractPxFromStyle(style['height'])?.toDouble();

          return pw.Container(
            width: finalWidth,
            height: pxHeight,
            alignment: isCentered(style) ? pw.Alignment.center : null,
            child: pw.Image(image, width: finalWidth, height: pxHeight, fit: pw.BoxFit.contain),
          );
        } else {
          return pw.Text('[Unsupported image]', textAlign: textAlign);
        }
      }

      // Parse child nodes recursively
      final children = node.nodes
          .map((n) => parseNode(n, parentStyle: style, parentAlign: textAlign))
          .toList();
      if (children.isEmpty) return pw.SizedBox();

      return pw.Align(
        alignment: textAlign == pw.TextAlign.center
            ? pw.Alignment.center
            : textAlign == pw.TextAlign.right
            ? pw.Alignment.centerRight
            : pw.Alignment.centerLeft,
        child: pw.Column(
          crossAxisAlignment: textAlign == pw.TextAlign.left
              ? pw.CrossAxisAlignment.start
              : textAlign == pw.TextAlign.center
              ? pw.CrossAxisAlignment.center
              : pw.CrossAxisAlignment.end,
          mainAxisSize: pw.MainAxisSize.min,
          children: children,
        ),
      );
    }

    return pw.SizedBox();
  }

  // Build table rows
  for (final row in rows) {
    final cells = row.querySelectorAll('td, th');
    final rowWidgets = <pw.Widget>[];
    for (final cell in cells) {
      final cellStyle = styleToMap(cell.attributes['style'] ?? '');
      final content = parseNode(cell, parentStyle: cellStyle);
      rowWidgets.add(pw.Container(
        padding: const pw.EdgeInsets.all(2),
        child: content,
      ));
    }
    tableRows.add(pw.TableRow(children: rowWidgets));
  }

  return pw.Table(children: tableRows);
}


/// --- TEXT STYLE PARSING ---
pw.TextStyle parseTextStyle(Map<String, String> style) {
  return pw.TextStyle(
    fontSize: style.containsKey('font-size')
        ? double.tryParse(style['font-size']!.replaceAll(RegExp(r'[^0-9.]'), ''))
        : 10,
    fontWeight: style['font-weight'] == 'bold' ? pw.FontWeight.bold : pw.FontWeight.normal,
    fontStyle: style['font-style'] == 'italic' ? pw.FontStyle.italic : pw.FontStyle.normal,
    color: style.containsKey('color') ? parseColor(style['color']!) : PdfColors.black,
  );
}

PdfColor parseColor(String color) {
  // Supports #RRGGBB
  if (color.startsWith('#')) {
    final hex = color.substring(1);
    if (hex.length == 6) {
      final r = int.parse(hex.substring(0, 2), radix: 16);
      final g = int.parse(hex.substring(2, 4), radix: 16);
      final b = int.parse(hex.substring(4, 6), radix: 16);
      return PdfColor.fromInt((r << 16) + (g << 8) + b);
    }
  }
  return PdfColors.black;
}


/// --- UTILITIES ---
double parseFontSize(String? sizeStr, {double defaultSize = 10}) {
  if (sizeStr == null || sizeStr.isEmpty) return defaultSize;
  final cleaned = sizeStr.replaceAll(RegExp(r'[^0-9.]'), '');
  double? parsed = double.tryParse(cleaned);
  if (parsed == null) return defaultSize;
  if (sizeStr.contains('px')) parsed *= 0.75;
  return parsed.clamp(2, 72);
}

pw.TextAlign parseTextAlign(dom.Element node) {
  final styleMap = styleToMap(node.attributes['style'] ?? '');
  String? align = styleMap['text-align']?.toLowerCase() ?? node.attributes['align']?.toLowerCase();
  switch (align) {
    case 'center':
      return pw.TextAlign.center;
    case 'right':
      return pw.TextAlign.right;
    case 'justify':
      return pw.TextAlign.justify;
    default:
      return pw.TextAlign.left;
  }
}



Map<String, String> styleToMap(String style) {
  final map = <String, String>{};
  if (style.isEmpty) return map;
  for (final part in style.split(';')) {
    final kv = part.split(':');
    if (kv.length == 2) map[kv[0].trim().toLowerCase()] = kv[1].trim();
  }
  return map;
}

double? extractPx(String? raw) => raw == null ? null : double.tryParse(raw.replaceAll(RegExp(r'[^0-9.]'), ''));

double? extractPxFromStyle(String? style) => style == null ? null : double.tryParse(styleToMap(style)['width']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0');

bool isCentered(Map<String, String> styleMap) =>
    (styleMap['margin-left'] == 'auto' && styleMap['margin-right'] == 'auto') || styleMap['text-align'] == 'center';
