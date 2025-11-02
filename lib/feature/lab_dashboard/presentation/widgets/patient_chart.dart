// import 'package:fl_chart/fl_chart.dart';
//
// import '../../../../core/configs/configs.dart';
// import '../../data/models/dashboard/dashboard_model.dart';
//
//
// class RegisteredPatientChart extends StatelessWidget {
//   final List<ChartEntry> patients;
//
//   const RegisteredPatientChart({super.key, required this.patients});
//
//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final monthlyCounts = List<int>.filled(12, 0);
//
//     for (final patient in patients) {
//       final date = DateTime.tryParse(patient.date.toString());
//       if (date != null && date.year == now.year) {
//         monthlyCounts[date.month - 1]++;
//       }
//     }
//
//     final spots = <FlSpot>[];
//     for (int i = 0; i < 12; i++) {
//       spots.add(FlSpot(i.toDouble(), monthlyCounts[i].toDouble()));
//     }
//
//     final maxVal = monthlyCounts.isNotEmpty
//         ? monthlyCounts.reduce((a, b) => a > b ? a : b)
//         : 0;
//     final maxY = maxVal.toDouble() + 5;
//
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//
//     return Column(
//       children: [
//         const Text(
//           "Registered Patients",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         const SizedBox(height: 8),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: LineChart(
//               LineChartData(
//                 maxY: maxY,
//                 titlesData: FlTitlesData(
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       interval: 1,
//                       getTitlesWidget: (value, meta) {
//                         final index = value.toInt();
//                         if (index < 0 || index > 11) return const SizedBox();
//                         return SideTitleWidget(
//                           meta: meta,
//                           child: Text(
//                             months[index],
//                             style: const TextStyle(fontSize: 10),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       getTitlesWidget: (value, meta) {
//                         return Text(
//                           value.toInt().toString(),
//                           style: const TextStyle(fontSize: 10),
//                         );
//                       },
//                       interval: maxY / 5,
//                     ),
//                   ),
//                   rightTitles:
//                   AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   topTitles:
//                   AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 ),
//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: spots,
//                     isCurved: true,
//                     color: Colors.green,
//                     barWidth: 2,
//                     belowBarData: BarAreaData(
//                       show: true,
//                       color: Colors.greenAccent.withValues(alpha: 0.2),
//                     ),
//                     dotData: FlDotData(show: true),
//                   ),
//                 ],
//                 gridData: FlGridData(show: true),
//                 borderData: FlBorderData(show: true),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
