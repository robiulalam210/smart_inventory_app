

import 'package:fl_chart/fl_chart.dart';

import '../../../../core/configs/configs.dart';
import '../../data/models/dashboard/dashboard_model.dart';


class BillingChart extends StatelessWidget {
  final List<ChartEntry> invoices;

  const BillingChart({super.key, required this.invoices});

  double _parseNum(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
  List<double> _aggregateByMonth(List<ChartEntry> invoices) {
    final now = DateTime.now();
    final monthlyTotals = List<double>.filled(12, 0);

    for (var invoice in invoices) {
      DateTime? date;

      date = invoice.date;


      if (date.year == now.year) {
        final month = date.month - 1;
        monthlyTotals[month] += _parseNum(invoice.totalBillAmount);
      }
    }

    return monthlyTotals;
  }


  @override
  Widget build(BuildContext context) {
    final monthlyData = _aggregateByMonth(invoices);
    final maxY = monthlyData.isNotEmpty
        ? (monthlyData.reduce((a, b) => a > b ? a : b) * 1.2).toDouble()
        : 1000.0;

    // Calculate a safe interval that's never zero
    final interval = maxY > 0 ? maxY / 5 : 2.0;

    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Billing Analytics",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BarChart(
              BarChartData(
                maxY: maxY,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec'
                        ];
                        return Text(
                          months[value.toInt() % 12],
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(), // Pad to 10 digits
                          style: const TextStyle(fontSize: 8),
                        );
                      },
                      interval: interval,
                    ),
                  ),

                  rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: List.generate(12, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: monthlyData[index],
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
