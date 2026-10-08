import 'package:flutter/material.dart';

import '../../screens/product_reports_view.dart';

/// MobileTopProductsScreen — নতুন report kit এ চলে (TopProductsView).
/// class এর নাম আগের মতো রাখা হয়েছে, যাতে menu / navigation এ কিছু বদলাতে না হয়।
/// পুরো নকশা, filter, table/card ও PDF: presentation/screens/product_reports_view.dart
class MobileTopProductsScreen extends StatelessWidget {
  const MobileTopProductsScreen({super.key});

  @override
  Widget build(BuildContext context) => const TopProductsView(mobile: true);
}
