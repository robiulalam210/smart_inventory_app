import 'package:flutter/material.dart';

import '../../screens/sales_report_view.dart';

/// MobileSalesReportScreen — নতুন report kit এ চলে (SalesReportView).
/// class এর নাম আগের মতো রাখা হয়েছে, যাতে menu / navigation এ কিছু বদলাতে না হয়।
/// পুরো নকশা, filter, table/card ও PDF: presentation/screens/sales_report_view.dart
class MobileSalesReportScreen extends StatelessWidget {
  const MobileSalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) => const SalesReportView(mobile: true);
}
