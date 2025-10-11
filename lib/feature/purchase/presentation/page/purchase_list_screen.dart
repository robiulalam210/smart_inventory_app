import 'package:flutter/material.dart';

import '../../../../core/configs/app_colors.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../responsive.dart';

class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  State<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  final TextEditingController invoiceController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController paymentStatusController = TextEditingController();

  DateTimeRange? dateRange = DateTimeRange(
    start: DateTime(2025, 4, 14),
    end: DateTime(2025, 10, 11),
  );

  // Example data
  final List<PurchaseRowData> purchases = [
    PurchaseRowData(
      sl: 1, invoiceNo: "SI-1007", date: "16 Sep 2025", location: "Dhaka",
      supplier: "Kurta Supplier", grandTotal: 6840, paymentStatus: "Pending", document: "",
    ),
    PurchaseRowData(
      sl: 2, invoiceNo: "SI-1006", date: "04 Aug 2025", location: "Dhaka",
      supplier: "Kurta Supplier", grandTotal: 3350, paymentStatus: "Partially Paid", document: "",
    ),
    PurchaseRowData(
      sl: 3, invoiceNo: "SI-1005", date: "03 Aug 2025", location: "Dhaka",
      supplier: "Mahin", grandTotal: 420, paymentStatus: "Pending", document: "",
    ),
    PurchaseRowData(
      sl: 4, invoiceNo: "SI-1004", date: "07 Jul 2025", location: "Dhaka",
      supplier: "Mahin", grandTotal: 200, paymentStatus: "Pending", document: "",
    ),
    PurchaseRowData(
      sl: 5, invoiceNo: "SI-1003", date: "26 Jun 2025", location: "Dhaka",
      supplier: "Mahin", grandTotal: 4400, paymentStatus: "Pending", document: "",
    ),
    PurchaseRowData(
      sl: 6, invoiceNo: "SI-1002", date: "26 Jun 2025", location: "Dhaka",
      supplier: "Rajib", grandTotal: 6750, paymentStatus: "Pending", document: "",
    ),
    PurchaseRowData(
      sl: 7, invoiceNo: "SI-1001", date: "26 Jun 2025", location: "Dhaka",
      supplier: "Mahin", grandTotal: 6000, paymentStatus: "Partially Paid", document: "",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
          child: _buildMainContent()
      ),
    );
  }

  Widget _buildMainContent() {
    final isBigScreen =
        Responsive.isDesktop(context) || Responsive.isMaxDesktop(context);

    return ResponsiveRow(
      spacing: 0,
      runSpacing: 0,
      children: [
        if (isBigScreen)
          ResponsiveCol(
            xs: 0,
            sm: 1,
            md: 1,
            lg: 2,
            xl: 2,
            child: Container(
              decoration: BoxDecoration(color: AppColors.whiteColor),
              child: isBigScreen ? const Sidebar() : const SizedBox.shrink(),
            ),
          ),
        ResponsiveCol(
          xs: 12,
          sm: 12,
          md: 12,
          lg: 10,
          xl: 10,
          child: Container(
            color: AppColors.bg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    child:    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top filter row
                        Row(
                          children: [
                            // Search Invoice
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: invoiceController,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.search, size: 18),
                                  hintText: "Search invoice no...",
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Supplier Dropdown
                            Expanded(
                              child: TextField(
                                controller: supplierController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  hintText: "Select Supplier",
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  suffixIcon: Icon(Icons.arrow_drop_down),
                                ),
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Payment Status Dropdown
                            Expanded(
                              child: TextField(
                                controller: paymentStatusController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  hintText: "Payment Status",
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  suffixIcon: Icon(Icons.arrow_drop_down),
                                ),
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Date Range
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () async {
                                  final picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2023),
                                    lastDate: DateTime(2026),
                                    initialDateRange: dateRange,
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      dateRange = picked;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    suffixIcon: Icon(Icons.calendar_today, size: 16),
                                  ),
                                  child: Text(
                                    "${dateRange?.start.toString().split(' ').first ?? ''}  →  ${dateRange?.end.toString().split(' ').first ?? ''}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // + Create Purchase Button
                            SizedBox(
                              height: 36,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: const Text("Create Purchase"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF57A56),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Table title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Purchase List (${purchases.length})",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Purchase List Table
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(const Color(0xFFFFEEE7)),
                              headingTextStyle: const TextStyle(
                                color: Color(0xFFDE6D36),
                                fontWeight: FontWeight.bold,
                              ),
                              dataRowMinHeight: 40,
                              columns: const [
                                DataColumn(label: Text("SL")),
                                DataColumn(label: Text("Invoice No")),
                                DataColumn(label: Text("Date")),
                                DataColumn(label: Text("Location")),
                                DataColumn(label: Text("Supplier")),
                                DataColumn(label: Text("Grand Total")),
                                DataColumn(label: Text("Payment Status")),
                                DataColumn(label: Text("Document")),
                                DataColumn(label: Text("Action")),
                              ],
                              rows: purchases
                                  .map(
                                    (purchase) => DataRow(
                                  cells: [
                                    DataCell(Text(purchase.sl.toString())),
                                    DataCell(Text(purchase.invoiceNo)),
                                    DataCell(Text(purchase.date)),
                                    DataCell(Text(purchase.location)),
                                    DataCell(Text(purchase.supplier)),
                                    DataCell(Text(
                                      purchase.grandTotal.toStringAsFixed(2),
                                    )),
                                    DataCell(_buildPaymentStatusChip(purchase.paymentStatus)),
                                    DataCell(const SizedBox()), // Document cell
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility, color: Color(0xFFF57A56), size: 20),
                                          onPressed: () {},
                                          tooltip: "View",
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Color(0xFFF57A56), size: 20),
                                          onPressed: () {},
                                          tooltip: "Delete",
                                        ),
                                      ],
                                    )),
                                  ],
                                ),
                              )
                                  .toList(),
                              dataRowColor: MaterialStateProperty.all(
                                Colors.white,
                              ),
                              dataTextStyle: const TextStyle(
                                fontSize: 15,
                              ),
                              dividerThickness: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Pagination and count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("Total ${purchases.length}"),
                            const SizedBox(width: 16),
                            SizedBox(
                              height: 32,
                              child: OutlinedButton(
                                onPressed: () {},
                                child: const Icon(Icons.chevron_left, size: 18),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text("1"), // current page
                            const SizedBox(width: 4),
                            SizedBox(
                              height: 32,
                              child: OutlinedButton(
                                onPressed: () {},
                                child: const Icon(Icons.chevron_right, size: 18),
                              ),
                            ),
                            const SizedBox(width: 16),
                            DropdownButton<int>(
                              value: 50,
                              items: const [
                                DropdownMenuItem(value: 10, child: Text("10 / page")),
                                DropdownMenuItem(value: 20, child: Text("20 / page")),
                                DropdownMenuItem(value: 50, child: Text("50 / page")),
                              ],
                              onChanged: (v) {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  }

  Widget _buildPaymentStatusChip(String status) {
    Color color;
    String label = status;
    switch (status) {
      case "Pending":
        color = Colors.blue;
        break;
      case "Partially Paid":
        color = Colors.pink;
        break;
      case "Paid":
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

}

class PurchaseRowData {
  final int sl;
  final String invoiceNo;
  final String date;
  final String location;
  final String supplier;
  final double grandTotal;
  final String paymentStatus;
  final String document;

  PurchaseRowData({
    required this.sl,
    required this.invoiceNo,
    required this.date,
    required this.location,
    required this.supplier,
    required this.grandTotal,
    required this.paymentStatus,
    required this.document,
  });
}