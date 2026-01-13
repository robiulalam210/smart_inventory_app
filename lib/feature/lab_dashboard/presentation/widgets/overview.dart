//
// import 'package:flutter/cupertino.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../../../../core/configs/configs.dart';
// import '../../data/models/dashboard/dashboard_model.dart';
// import 'stats_card_monthly.dart';
//
// Widget buildSalesOverview(DashboardData data,BuildContext context) {
//   final isMobile = Responsive.isMobile(context);
//
//   return Container(
//     padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(8),
//       color: Colors.white,
//     ),
//     child: Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "Sales Overview",
//               style: TextStyle(
//                 fontFamily: GoogleFonts.playfairDisplay().fontFamily,
//                 fontWeight: FontWeight.w500,
//                 fontSize: isMobile ? 14 : 18,
//               ),
//             ),
//             if (!isMobile) _buildSegmentedControl('sales'),
//           ],
//         ),
//         if (isMobile) ...[
//           const SizedBox(height: 8),
//           _buildSegmentedControl('sales'),
//         ],
//         const SizedBox(height: 12),
//         Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: StatsCardMonthly(
//                     title: "Total Sold Quantity",
//                     count: data.todayMetrics?.sales?.totalQuantity?.toString() ?? "0",
//                     color: Colors.pink,
//                     icon: "assets/images/sold.png",
//                   ),
//                 ),
//                 SizedBox(width: isMobile ? 5 : 10),
//                 Expanded(
//                   child: StatsCardMonthly(
//                     title: "Total Amount",
//                     count: (data.todayMetrics?.sales?.total ?? 0).toStringAsFixed(2),
//                     color: Colors.purple,
//                     icon: "assets/images/gross.png",
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: isMobile ? 8 : 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: StatsCardMonthly(
//                     title: "Total Due",
//                     count: (data.todayMetrics?.sales?.totalDue ?? 0).toStringAsFixed(2),
//                     color: Colors.redAccent,
//                     icon: "assets/images/cancel.png",
//                   ),
//                 ),
//                 SizedBox(width: isMobile ? 5 : 10),
//                 Expanded(
//                   child: StatsCardMonthly(
//                     title: "Profit / Loss",
//                     count: (data.profitLoss?.netProfit ?? 0).toStringAsFixed(2),
//                     color: (data.profitLoss?.netProfit ?? 0) >= 0 ? Colors.green : Colors.red,
//                     icon: "assets/images/expenses.png",
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }
//
// Widget buildPurchaseOverview(DashboardData data,BuildContext context) {
//   final isMobile = Responsive.isMobile(context);
//
//   return Container(
//     padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(8),
//       color: Colors.white,
//     ),
//     child: Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "Purchase Overview",
//               style: TextStyle(
//                 fontFamily: GoogleFonts.playfairDisplay().fontFamily,
//                 fontWeight: FontWeight.w600,
//                 fontSize: isMobile ? 14 : 18,
//               ),
//             ),
//             if (!isMobile) _buildSegmentedControl('purchase'),
//           ],
//         ),
//         if (isMobile) ...[
//           const SizedBox(height: 8),
//           _buildSegmentedControl('purchase'),
//         ],
//         const SizedBox(height: 12),
//         Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: StatsCardMonthly(
//                     title: "Total Purchase\nQuantity",
//                     count: data.todayMetrics?.purchases?.totalQuantity?.toString() ?? "0",
//                     color: Colors.blue,
//                     icon: "assets/images/buy.png",
//                   ),
//                 ),
//                 SizedBox(width: isMobile ? 5 : 10),
//                 Expanded(
//                   child: StatsCardMonthly(
//                     title: "Total Amount",
//                     count: (data.todayMetrics?.purchases?.total ?? 0).toStringAsFixed(2),
//                     color: Colors.green,
//                     icon: "assets/images/gross.png",
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: isMobile ? 8 : 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: StatsCardMonthly(
//                     title: "Total Due",
//                     count: (data.todayMetrics?.purchases?.totalDue ?? 0).toStringAsFixed(2),
//                     color: Colors.redAccent,
//                     icon: "assets/images/cancel.png",
//                   ),
//                 ),
//                 SizedBox(width: isMobile ? 5 : 10),
//                 Expanded(
//                   child: StatsCardMonthly(
//                     title: "Total Returns",
//                     count: (data.todayMetrics?.purchaseReturns?.totalAmount ?? 0).toStringAsFixed(2),
//                     color: Colors.black,
//                     icon: "assets/images/product_return.png",
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }
//
// Widget buildSegmentedControl(String type,BuildContext context) {
//   final isMobile = Responsive.isMobile(context);
//   final width = isMobile ? double.infinity : AppSizes.width(context) * 0.20;
//
//   return SizedBox(
//     width: width,
//     child: CupertinoSegmentedControl<String>(
//       padding: EdgeInsets.zero,
//       children: {
//         'current_day': Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
//           child: Text(
//             'Today',
//             style: TextStyle(
//               fontFamily: GoogleFonts.playfairDisplay().fontFamily,
//               fontSize: isMobile ? 12 : 14,
//               color: selectedPurchaseOverviewType == 'current_day'
//                   ? Colors.white
//                   : Colors.black,
//             ),
//           ),
//         ),
//         'this_month': Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
//           child: Text(
//             isMobile ? DateFormat('MMM').format(DateTime.now()) : DateFormat('MMMM').format(DateTime.now()),
//             style: TextStyle(
//               fontFamily: GoogleFonts.playfairDisplay().fontFamily,
//               fontSize: isMobile ? 12 : 14,
//               color: selectedPurchaseOverviewType == 'this_month'
//                   ? Colors.white
//                   : Colors.black,
//             ),
//           ),
//         ),
//         'lifeTime': Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
//           child: Text(
//             isMobile ? 'All' : 'Life Time',
//             style: TextStyle(
//               fontFamily: GoogleFonts.playfairDisplay().fontFamily,
//               fontSize: isMobile ? 12 : 14,
//               color: selectedPurchaseOverviewType == 'lifeTime'
//                   ? Colors.white
//                   : Colors.black,
//             ),
//           ),
//         ),
//       },
//       onValueChanged: (value) {
//         setState(() {
//           selectedPurchaseOverviewType = value;
//           context.read<DashboardBloc>().add(
//             FetchDashboardData(dateFilter: value, context: context),
//           );
//         });
//       },
//       groupValue: selectedPurchaseOverviewType,
//       unselectedColor: Colors.white54,
//       selectedColor: AppColors.primaryColor(context),
//       borderColor: AppColors.primaryColor(context),
//     ),
//   );
// }