import 'package:pdf/pdf.dart';


// --- Helper Methods ---
// PdfPageFormat getPageFormat(String size) {
//   switch (size.toUpperCase()) {
//     case 'A4':
//       return PdfPageFormat.a4;
//     case 'A5':
//       return PdfPageFormat.a5;
//     case 'LETTER':
//       return PdfPageFormat.letter;
//     default:
//       return PdfPageFormat.a5;
//   }
// }
PdfPageFormat getPageFormat(String size) {
  switch (size.toUpperCase()) {
    case 'A4':
      return PdfPageFormat.a4;
    case 'A5':
      return PdfPageFormat.a5;
    case 'LETTER':
      return PdfPageFormat.letter;
    default:
      return PdfPageFormat.a5;
  }
}
