import 'package:flutter/material.dart';

import '../../screens/profit_loss_view.dart';

/// ProfitLossScreen — নতুন report kit এ চলে (ProfitLossView).
/// class এর নাম আগের মতো রাখা হয়েছে, যাতে menu / navigation এ কিছু বদলাতে না হয়।
/// পুরো নকশা, filter, table/card ও PDF: presentation/screens/profit_loss_view.dart
class ProfitLossScreen extends StatelessWidget {
  const ProfitLossScreen({super.key});

  @override
  Widget build(BuildContext context) => const ProfitLossView();
}
