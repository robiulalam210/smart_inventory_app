class DashboardData {
  final double totalAmount;
  final double totalDiscount;
  final double totalReceived;
  final double totalDue;
  final double dueCollection;
  final int totalPatients;
  final int totalTests;
  final int totalDoctors;
  final int totalInvoiceTests;

  final List<ChartEntry> invoiceChart;
  final List<ChartEntry> patientChart;

  DashboardData({
    required this.totalAmount,
    required this.totalDiscount,
    required this.totalReceived,
    required this.totalDue,
    required this.dueCollection,
    required this.totalPatients,
    required this.totalTests,
    required this.totalInvoiceTests,
    required this.totalDoctors,
    required this.invoiceChart,
    required this.patientChart,
  });
}


class ChartEntry {
  final DateTime date;
  final int count;
  final double totalBillAmount;  // add this

  ChartEntry({
    required this.date,
    required this.count,
    this.totalBillAmount = 0.0,
  });
}
