import 'package:flutter/material.dart';

import '../../screens/product_reports_view.dart';

/// MobileStockReportScreen — নতুন report kit এ চলে (StockReportView).
/// class এর নাম আগের মতো রাখা হয়েছে, যাতে menu / navigation এ কিছু বদলাতে না হয়।
/// পুরো নকশা, filter, table/card ও PDF: presentation/screens/product_reports_view.dart
class MobileStockReportScreen extends StatelessWidget {
  const MobileStockReportScreen({super.key});

  @override
  Widget build(BuildContext context) => const StockReportView(mobile: true);
}
