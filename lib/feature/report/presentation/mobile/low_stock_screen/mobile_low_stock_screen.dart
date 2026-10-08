import 'package:flutter/material.dart';

import '../../screens/product_reports_view.dart';

/// MobileLowStockScreen — নতুন report kit এ চলে (LowStockView).
/// class এর নাম আগের মতো রাখা হয়েছে, যাতে menu / navigation এ কিছু বদলাতে না হয়।
/// পুরো নকশা, filter, table/card ও PDF: presentation/screens/product_reports_view.dart
class MobileLowStockScreen extends StatelessWidget {
  const MobileLowStockScreen({super.key});

  @override
  Widget build(BuildContext context) => const LowStockView(mobile: true);
}
