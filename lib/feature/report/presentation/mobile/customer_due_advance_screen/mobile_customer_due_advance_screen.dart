import 'package:flutter/material.dart';

import '../../screens/party_reports_view.dart';

/// MobileCustomerDueAdvanceScreen — নতুন report kit এ চলে (CustomerDueAdvanceView).
/// class এর নাম আগের মতো রাখা হয়েছে, যাতে menu / navigation এ কিছু বদলাতে না হয়।
/// পুরো নকশা, filter, table/card ও PDF: presentation/screens/party_reports_view.dart
class MobileCustomerDueAdvanceScreen extends StatelessWidget {
  const MobileCustomerDueAdvanceScreen({super.key});

  @override
  Widget build(BuildContext context) => const CustomerDueAdvanceView(mobile: true);
}
