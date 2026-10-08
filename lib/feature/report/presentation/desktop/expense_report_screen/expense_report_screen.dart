import 'package:flutter/material.dart';

import '../../screens/expense_report_view.dart';

/// ExpenseReportScreen — নতুন report kit এ চলে (ExpenseReportView).
/// class এর নাম আগের মতো রাখা হয়েছে, যাতে menu / navigation এ কিছু বদলাতে না হয়।
/// পুরো নকশা, filter, table/card ও PDF: presentation/screens/expense_report_view.dart
class ExpenseReportScreen extends StatelessWidget {
  const ExpenseReportScreen({super.key});

  @override
  Widget build(BuildContext context) => const ExpenseReportView();
}
