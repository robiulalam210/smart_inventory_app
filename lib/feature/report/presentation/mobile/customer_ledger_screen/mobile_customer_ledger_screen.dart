import 'package:flutter/material.dart';

import '../../screens/party_reports_view.dart';

/// MobileCustomerLedgerScreen — নতুন report kit এ চলে (CustomerLedgerView).
/// class এর নাম আগের মতো রাখা হয়েছে, যাতে menu / navigation এ কিছু বদলাতে না হয়।
/// পুরো নকশা, filter, table/card ও PDF: presentation/screens/party_reports_view.dart
class MobileCustomerLedgerScreen extends StatelessWidget {
  const MobileCustomerLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) => const CustomerLedgerView(mobile: true);
}
