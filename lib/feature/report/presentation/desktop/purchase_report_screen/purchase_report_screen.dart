import 'package:flutter/material.dart';

import '../../screens/purchase_report_view.dart';

/// PurchaseReportScreen — নতুন report kit এ চলে (PurchaseReportView).
/// class এর নাম আগের মতো রাখা হয়েছে, যাতে menu / navigation এ কিছু বদলাতে না হয়।
/// পুরো নকশা, filter, table/card ও PDF: presentation/screens/purchase_report_view.dart
class PurchaseReportScreen extends StatelessWidget {
  const PurchaseReportScreen({super.key});

  @override
  Widget build(BuildContext context) => const PurchaseReportView();
}
