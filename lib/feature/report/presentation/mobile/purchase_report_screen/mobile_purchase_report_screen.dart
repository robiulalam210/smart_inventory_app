import 'package:flutter/material.dart';

import '../../screens/purchase_report_view.dart';

/// MobilePurchaseReportScreen — নতুন report kit এ চলে (PurchaseReportView).
/// class এর নাম আগের মতো রাখা হয়েছে, যাতে menu / navigation এ কিছু বদলাতে না হয়।
/// পুরো নকশা, filter, table/card ও PDF: presentation/screens/purchase_report_view.dart
class MobilePurchaseReportScreen extends StatelessWidget {
  const MobilePurchaseReportScreen({super.key});

  @override
  Widget build(BuildContext context) => const PurchaseReportView(mobile: true);
}
