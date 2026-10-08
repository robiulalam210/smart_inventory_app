import 'package:flutter/material.dart';

import '../../screens/party_reports_view.dart';

/// MobileSupplierDueAdvanceScreen — নতুন report kit এ চলে (SupplierDueAdvanceView).
/// class এর নাম আগের মতো রাখা হয়েছে, যাতে menu / navigation এ কিছু বদলাতে না হয়।
/// পুরো নকশা, filter, table/card ও PDF: presentation/screens/party_reports_view.dart
class MobileSupplierDueAdvanceScreen extends StatelessWidget {
  const MobileSupplierDueAdvanceScreen({super.key});

  @override
  Widget build(BuildContext context) => const SupplierDueAdvanceView(mobile: true);
}
