// import 'package:flutter/material.dart';
//
// import '../../../../core/configs/app_colors.dart';
// import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
// import '../../../../responsive.dart';
// class SalesListScreen extends StatefulWidget {
//   const SalesListScreen({super.key});
//
//   @override
//   State<SalesListScreen> createState() => _SalesListScreenState();
// }
//
// class _SalesListScreenState extends State<SalesListScreen> {
//
//   // Example filter controllers
//   final TextEditingController invoiceController = TextEditingController();
//   final TextEditingController customerController = TextEditingController();
//   final TextEditingController salesByController = TextEditingController();
//   final TextEditingController saleTypeController = TextEditingController();
//   DateTimeRange? dateRange = DateTimeRange(
//     start: DateTime(2025, 4, 14),
//     end: DateTime(2025, 10, 11),
//   );
//
//   // Example sales data
//   final List<SaleRowData> sales = List.generate(
//     15,
//         (index) => SaleRowData(
//       sl: index + 1,
//       receiptNo: "PS-10${32 - index}",
//       saleDate: "07 Jul 2025",
//       customerName: "Guest",
//       location: "Dhaka",
//       salesBy: "MAHMUDUL  ARMAAN",
//       createdBy: "MAHMUDUL HAQUE",
//       grandTotal: (index % 2 == 0)
//           ? 1230.00 + (index * 100)
//           : 12.80 + (index * 10),
//       due: 0.00,
//     ),
//   );
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: SafeArea(
//         child: _buildMainContent()
//       ),
//     );
//   }
//
//   Widget _buildMainContent() {
//     final isBigScreen =
//         Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);
//
//     return ResponsiveRow(
//       spacing: 0,
//       runSpacing: 0,
//       children: [
//         if (isBigScreen)
//           ResponsiveCol(
//             xs: 0,
//             sm: 1,
//             md: 1,
//             lg: 2,
//             xl: 2,
//             child: Container(
//               decoration: BoxDecoration(color: AppColors.whiteColor),
//               child: isBigScreen ? const Sidebar() : const SizedBox.shrink(),
//             ),
//           ),
//         ResponsiveCol(
//           xs: 12,
//           sm: 12,
//           md: 12,
//           lg: 10,
//           xl: 10,
//           child: Container(
//             color: AppColors.bg,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Flexible(
//                   child: SingleChildScrollView(
//                     physics: const NeverScrollableScrollPhysics(),
//                     padding: EdgeInsets.zero,
//                     child:     Column(
//                       children: [
//                         // Filter Row
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             children: [
//                               // Search Invoice
//                               Expanded(
//                                 flex: 2,
//                                 child: TextField(
//                                   controller: invoiceController,
//                                   decoration: const InputDecoration(
//                                     prefixIcon: Icon(
//                                       Icons.search,
//                                       size: 18,
//                                     ),
//                                     hintText: "Search invoice no...",
//                                     border: OutlineInputBorder(),
//                                     isDense: true,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               // Customer Dropdown
//                               Expanded(
//                                 child: _buildDropdownField(
//                                   controller: customerController,
//                                   hint: "Select Customer",
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               // Sales By Dropdown
//                               Expanded(
//                                 child: _buildDropdownField(
//                                   controller: salesByController,
//                                   hint: "Sales By",
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               // Sale Type Dropdown
//                               Expanded(
//                                 child: _buildDropdownField(
//                                   controller: saleTypeController,
//                                   hint: "Select Sale Type",
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               // Date Range
//                               Expanded(
//                                 flex: 2,
//                                 child: InkWell(
//                                   onTap: () async {
//                                     final picked =
//                                     await showDateRangePicker(
//                                       context: context,
//                                       firstDate: DateTime(2023),
//                                       lastDate: DateTime(2026),
//                                       initialDateRange: dateRange,
//                                     );
//                                     if (picked != null) {
//                                       setState(() {
//                                         dateRange = picked;
//                                       });
//                                     }
//                                   },
//                                   child: InputDecorator(
//                                     decoration: const InputDecoration(
//                                       border: OutlineInputBorder(),
//                                       isDense: true,
//                                       suffixIcon: Icon(
//                                         Icons.calendar_today,
//                                         size: 16,
//                                       ),
//                                     ),
//                                     child: Text(
//                                       "${dateRange?.start.toString().split(' ').first ?? ''}  →  ${dateRange?.end.toString().split(' ').first ?? ''}",
//                                       style: const TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w400,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               // + Sale Button
//                               SizedBox(
//                                 height: 36,
//                                 child: ElevatedButton.icon(
//                                   icon: const Icon(
//                                     Icons.add,
//                                     color: Colors.white,
//                                   ),
//                                   label: const Text("Sale"),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color(
//                                       0xFFF57A56,
//                                     ),
//                                     foregroundColor: Colors.white,
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 16,
//                                     ),
//                                   ),
//                                   onPressed: () {},
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         // List Title
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12.0,
//                           ),
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text(
//                               "List of Sales (${sales.length})",
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         LayoutBuilder(
//                           builder: (context, constraints) {
//                             final double totalWidth = constraints.maxWidth;
//                             const int numColumns = 10;
//                             const double minColumnWidth = 100;
//                             final double dynamicColumnWidth =
//                             (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);
//
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                               child: Card(
//                                 elevation: 0,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: SingleChildScrollView(
//                                   scrollDirection: Axis.horizontal,
//                                   child: ConstrainedBox(
//                                     constraints: BoxConstraints(
//                                       minWidth: dynamicColumnWidth * numColumns,
//                                     ),
//                                     child: SingleChildScrollView(
//                                       child: DataTable(
//                                         dataRowMinHeight: 40,
//                                         // headingRowHeight: 40,
//                                         columnSpacing: 0,
//                                         checkboxHorizontalMargin: 0,
//                                         headingTextStyle: const TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         headingRowColor:
//                                         WidgetStateProperty.all(Color(0xFF6ab129)),
//
//                                         columns: const [
//                                           DataColumn(label: Text("SL")),
//                                           DataColumn(label: Text("Receipt No")),
//                                           DataColumn(label: Text("Sale Date")),
//                                           DataColumn(label: Text("Customer Name")),
//                                           DataColumn(label: Text("Location")),
//                                           DataColumn(label: Text("Sales By")),
//                                           DataColumn(label: Text("Created By")),
//                                           DataColumn(label: Text("Grand Total")),
//                                           DataColumn(label: Text("Due")),
//                                           DataColumn(label: Text("Action")),
//                                         ],
//                                         rows: sales
//                                             .map(
//                                               (sale) => DataRow(
//                                             cells: [
//                                               DataCell(Text(sale.sl.toString())),
//                                               DataCell(Text(sale.receiptNo)),
//                                               DataCell(Text(sale.saleDate)),
//                                               DataCell(Text(sale.customerName)),
//                                               DataCell(Text(sale.location)),
//                                               DataCell(Text(sale.salesBy)),
//                                               DataCell(Text(sale.createdBy)),
//                                               DataCell(Text(
//                                                 sale.grandTotal.toStringAsFixed(2),
//                                               )),
//                                               DataCell(Text(
//                                                 sale.due.toStringAsFixed(2),
//                                                 style: const TextStyle(
//                                                   color: Colors.green,
//                                                 ),
//                                               )),
//                                               DataCell(Row(
//                                                 children: [
//                                                   IconButton(
//                                                     icon: const Icon(
//                                                       Icons.visibility,
//                                                       color: Color(0xFFF57A56),
//                                                       size: 20,
//                                                     ),
//                                                     onPressed: () {},
//                                                     tooltip: "View",
//                                                   ),
//                                                   IconButton(
//                                                     icon: const Icon(
//                                                       Icons.delete_outline,
//                                                       color: Color(0xFFF57A56),
//                                                       size: 20,
//                                                     ),
//                                                     onPressed: () {},
//                                                     tooltip: "Delete",
//                                                   ),
//                                                 ],
//                                               )),
//                                             ],
//                                           ),
//                                         )
//                                             .toList(),
//                                         dataRowColor: MaterialStateProperty.all(
//                                           Colors.white,
//                                         ),
//
//                                         dataTextStyle: const TextStyle(
//                                           fontSize: 15,
//                                         ),
//                                         // columnSpacing: dynamicColumnWidth - minColumnWidth + 24,
//                                         dividerThickness: 0.4,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// Widget _buildDropdownField({
//   required TextEditingController controller,
//   String? hint,
// }) {
//   return TextField(
//     controller: controller,
//     readOnly: true,
//     decoration: InputDecoration(
//       hintText: hint,
//       border: const OutlineInputBorder(),
//       isDense: true,
//       suffixIcon: const Icon(Icons.arrow_drop_down),
//     ),
//     onTap: () {},
//   );
// }
//
// class SaleRowData {
//   final int sl;
//   final String receiptNo;
//   final String saleDate;
//   final String customerName;
//   final String location;
//   final String salesBy;
//   final String createdBy;
//   final double grandTotal;
//   final double due;
//
//   SaleRowData({
//     required this.sl,
//     required this.receiptNo,
//     required this.saleDate,
//     required this.customerName,
//     required this.location,
//     required this.salesBy,
//     required this.createdBy,
//     required this.grandTotal,
//     required this.due,
//   });
// }
