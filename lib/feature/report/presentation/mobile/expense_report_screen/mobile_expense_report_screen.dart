import 'package:flutter/material.dart';

import '../../screens/expense_report_view.dart';

/// MobileExpenseReportScreen — নতুন report kit এ চলে (ExpenseReportView).
/// class এর নাম আগের মতো রাখা হয়েছে, যাতে menu / navigation এ কিছু বদলাতে না হয়।
/// পুরো নকশা, filter, table/card ও PDF: presentation/screens/expense_report_view.dart
class MobileExpenseReportScreen extends StatelessWidget {
  const MobileExpenseReportScreen({super.key});

  @override
  Widget build(BuildContext context) => const ExpenseReportView(mobile: true);
}
