//
// import 'package:intl/intl.dart';
// import 'package:fl_chart/fl_chart.dart';
//
//
// Widget statisticsChart(List<RevenueAndPurchase> revenueAndPurchase) {
//   // Calculate the max Y value based on the maximum value from totalRevenue and totalPurchase
//   double maxYValue = revenueAndPurchase.fold<double>(
//     0,
//         (prev, element) => [
//       prev,
//       (element.totalRevenue ?? 0) / 100,
//       (element.totalPurchase ?? 0) / 100
//     ].reduce((a, b) => a > b ? a : b),
//   );
//
//   return SizedBox(
//     height: 300,
//     // padding: const EdgeInsets.all(6.0),
//     child: LineChart(
//       LineChartData(
//         lineBarsData: [
//           LineChartBarData(
//             spots: revenueAndPurchase.map((entry) {
//               return FlSpot(
//                 revenueAndPurchase.indexOf(entry).toDouble(),
//                 (entry.totalRevenue ?? 0) / 100, // Dynamic scaling of revenue
//               );
//             }).toList(),
//             isCurved: true,
//             color: Colors.blueAccent,
//             barWidth: 3,
//             belowBarData: BarAreaData(
//               show: true,
//               color: Colors.blue.withValues(alpha: 0.3),
//             ),
//           ),
//           LineChartBarData(
//             spots: revenueAndPurchase.map((entry) {
//               return FlSpot(
//                 revenueAndPurchase.indexOf(entry).toDouble(),
//                 (entry.totalPurchase ?? 0) / 100, // Dynamic scaling of purchase
//               );
//             }).toList(),
//             isCurved: true,
//             color: Colors.greenAccent,
//             barWidth: 3,
//             belowBarData: BarAreaData(
//               show: false,
//               color: Colors.green.withValues(alpha: 0.3),
//             ),
//           ),
//         ],
//         titlesData: FlTitlesData(
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 final index = value.toInt();
//                 if (index >= 0 && index < revenueAndPurchase.length) {
//                   final month = DateFormat.MMM().format(DateTime.parse(
//                     '${revenueAndPurchase[index].date}-01',
//                   ));
//                   return Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Text(month, style: const TextStyle(fontSize: 10)),
//                   );
//                 } else {
//                   return const SizedBox();
//                 }
//               },
//             ),
//           ),
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 return Text(
//                   '${(value * 100).toInt()}', // Adjusted to show original value
//                   style: const TextStyle(fontSize: 10),
//                 );
//               },
//             ),
//           ),
//         ),
//         borderData: FlBorderData(
//           show: true,
//           border: Border.all(color: Colors.grey),
//         ),
//         gridData: const FlGridData(show: true),
//         minX: 0,
//         maxX: (revenueAndPurchase.length - 1).toDouble(),
//         minY: 0,
//         maxY: maxYValue,  // Dynamically calculated max Y value
//       ),
//     ),
//   );
// }
//
// // Widget statisticsChart(List<RevenueAndPurchase> revenueAndPurchase) {
// //   return Container(
// //     height: 300,
// //     padding: const EdgeInsets.all(6.0),
// //     child: LineChart(
// //       LineChartData(
// //         lineBarsData: [
// //           LineChartBarData(
// //             spots:revenueAndPurchase.asMap().entries.map((entry) {
// //                   return FlSpot(
// //                     entry.key.toDouble(),
// //                     (entry.value.totalRevenue as num).toDouble() / 1000000,
// //                   );
// //                 }).toList() ??
// //                 [],
// //             isCurved: true,
// //             color: Colors.blue,
// //             barWidth: 3,
// //             belowBarData: BarAreaData(
// //               show: true,
// //               color: Colors.blue.withValues(alpha:0.3),
// //             ),
// //           ),
// //           LineChartBarData(
// //             spots:revenueAndPurchase?.asMap().entries.map((entry) {
// //                   return FlSpot(
// //                     entry.key.toDouble(),
// //                     (entry.value.totalPurchase as num).toDouble() / 1000000,
// //                   );
// //                 }).toList() ??
// //                 [],
// //             isCurved: false,
// //             color: Colors.green,
// //             barWidth: 3,
// //             belowBarData: BarAreaData(
// //               show: false,
// //               color: Colors.green.withValues(alpha:0.3),
// //             ),
// //           ),
// //         ],
// //         titlesData: FlTitlesData(
// //           bottomTitles: AxisTitles(
// //             sideTitles: SideTitles(
// //               showTitles: true,
// //               getTitlesWidget: (value, meta) {
// //                 final monthIndex = value.toInt();
// //                 if (monthIndex <revenueAndPurchase!.length) {
// //                   final month =revenueAndPurchase![monthIndex].date
// //                       .toString()
// //                       .substring(5); // Get the month from the date
// //                   return Padding(
// //                     padding: const EdgeInsets.only(top: 2.0),
// //                     child: Column(
// //                       children: [
// //                         // Text(
// //                         //   month,
// //                         //   style: TextStyle(fontSize: 10),
// //                         // ),
// //                         Text(
// //                           DateFormat.MMM().format(DateFormat("yyyy-MM").parse(
// //                            revenueAndPurchase![monthIndex].date
// //                                   .toString())),
// //                           style: const TextStyle(fontSize: 10),
// //                         ),
// //                       ],
// //                     ),
// //                   );
// //                 } else {
// //                   return const SizedBox(); // Return an empty widget if the index is out of bounds
// //                 }
// //               },
// //             ),
// //           ),
// //           leftTitles: AxisTitles(
// //             sideTitles: SideTitles(
// //               showTitles: true,
// //               getTitlesWidget: (value, meta) {
// //                 return Text(
// //                   '${(value * 1000000).toInt()}',
// //                   style: const TextStyle(fontSize: 10),
// //                 );
// //               },
// //             ),
// //           ),
// //         ),
// //         borderData: FlBorderData(
// //           show: true,
// //           border: Border.all(color: Colors.grey),
// //         ),
// //         gridData: const FlGridData(show: true),
// //         minX: 0,
// //         maxX: 11,
// //         minY: 0,
// //         maxY: 30,
// //       ),
// //     ),
// //   );
// // }
