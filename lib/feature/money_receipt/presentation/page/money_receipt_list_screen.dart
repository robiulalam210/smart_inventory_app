import 'package:flutter/material.dart';

import '../../../../core/configs/app_colors.dart';
import '../../../../core/shared/widgets/sideMenu/sidebar.dart';
import '../../../../responsive.dart';

class MoneyReceiptListScreen extends StatefulWidget {
  const MoneyReceiptListScreen({super.key});

  @override
  State<MoneyReceiptListScreen> createState() => _MoneyReceiptListScreenState();
}

class _MoneyReceiptListScreenState extends State<MoneyReceiptListScreen> {
  final TextEditingController mrNoController = TextEditingController();
  final TextEditingController customerController = TextEditingController();
  final TextEditingController sellerController = TextEditingController();
  final TextEditingController paymentTypeController = TextEditingController();
  DateTimeRange? dateRange = DateTimeRange(
    start: DateTime(2024, 10, 11),
    end: DateTime(2025, 10, 11),
  );

  // Example data
  final List<MoneyReceiptRowData> moneyReceipts = [
    MoneyReceiptRowData(
      sl: 1,
      mrNo: "MR-1023",
      paymentDate: "08 Oct 2025",
      locationName: "Dhaka",
      customerName: "Guest",
      customerNumber: "",
      sellerName: "MAHMUDUL HAQUE ARMAAN",
      paymentMethod: "Cash",
      amount: 1990.00,
    ),
    MoneyReceiptRowData(
      sl: 2,
      mrNo: "MR-1022",
      paymentDate: "15 Sep 2025",
      locationName: "Dhaka",
      customerName: "Guest",
      customerNumber: "",
      sellerName: "MAHMUDUL HAQUE ARMAAN",
      paymentMethod: "Cash",
      amount: 12.80,
    ),
    // Add more rows as needed, here's an example with more data
    MoneyReceiptRowData(
      sl: 3,
      mrNo: "MR-1021",
      paymentDate: "10 Sep 2025",
      locationName: "Dhaka",
      customerName: "Rupok",
      customerNumber: "018542135210",
      sellerName: "MAHMUDUL HAQUE ARMAAN",
      paymentMethod: "Mobile banking",
      amount: 5000.00,
    ),
    MoneyReceiptRowData(
      sl: 4,
      mrNo: "MR-1021",
      paymentDate: "10 Sep 2025",
      locationName: "Dhaka",
      customerName: "Rupok",
      customerNumber: "018542135210",
      sellerName: "MAHMUDUL HAQUE ARMAAN",
      paymentMethod: "Mobile banking",
      amount: 5000.00,
    ),
    MoneyReceiptRowData(
      sl: 5,
      mrNo: "MR-1021",
      paymentDate: "10 Sep 2025",
      locationName: "Dhaka",
      customerName: "Rupok",
      customerNumber: "018542135210",
      sellerName: "MAHMUDUL HAQUE ARMAAN",
      paymentMethod: "Mobile banking",
      amount: 5000.00,
    ),
    MoneyReceiptRowData(
      sl: 6,
      mrNo: "MR-1021",
      paymentDate: "10 Sep 2025",
      locationName: "Dhaka",
      customerName: "Rupok",
      customerNumber: "018542135210",
      sellerName: "MAHMUDUL HAQUE ARMAAN",
      paymentMethod: "Mobile banking",
      amount: 5000.00,
    ),
    MoneyReceiptRowData(
      sl: 7,
      mrNo: "MR-1021",
      paymentDate: "10 Sep 2025",
      locationName: "Dhaka",
      customerName: "Rupok",
      customerNumber: "018542135210",
      sellerName: "MAHMUDUL HAQUE ARMAAN",
      paymentMethod: "Mobile banking",
      amount: 5000.00,
    ),
    MoneyReceiptRowData(
      sl: 8,
      mrNo: "MR-1021",
      paymentDate: "10 Sep 2025",
      locationName: "Dhaka",
      customerName: "Rupok",
      customerNumber: "018542135210",
      sellerName: "MAHMUDUL HAQUE ARMAAN",
      paymentMethod: "Mobile banking",
      amount: 5000.00,
    ),
    MoneyReceiptRowData(
      sl: 9,
      mrNo: "MR-1020",
      paymentDate: "05 Sep 2025",
      locationName: "Dhaka",
      customerName: "Rupok",
      customerNumber: "018542135210",
      sellerName: "Rakib",
      paymentMethod: "Cash",
      amount: 849.00,
    ),
    // ... add more for demo purposes
  ];

  @override
  Widget build(BuildContext context) {




    return SafeArea(
        child: _buildMainContent()
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
                  child: Row(
                    children: [
                      // Search MR No
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: mrNoController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search, size: 18),
                            hintText: "Search MR No...",
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Customer Dropdown
                      Expanded(
                        child: _buildDropdownField(
                          controller: customerController,
                          hint: "Select Customer",
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Seller Dropdown
                      Expanded(
                        child: _buildDropdownField(
                          controller: sellerController,
                          hint: "Select Seller",
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Payment Type Dropdown
                      Expanded(
                        child: _buildDropdownField(
                          controller: paymentTypeController,
                          hint: "Select Payment Type",
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
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                size: 16,
                              ),
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
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // List Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "List of Money Receipt (${moneyReceipts.length})",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Table
                SizedBox(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double totalWidth = constraints.maxWidth;
                      const int numColumns = 10;
                      const double minColumnWidth = 120;
                      final double dynamicColumnWidth =
                      (totalWidth / numColumns).clamp(minColumnWidth, double.infinity);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: dynamicColumnWidth * numColumns,
                              ),
                              child: SingleChildScrollView(
                                child: DataTable(
                                  dataRowMinHeight: 40,
                                  columnSpacing: 0,
                                  checkboxHorizontalMargin: 0,
                                  headingTextStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  headingRowColor: MaterialStateProperty.all(Color(0xFFF9EDE7)),
                                  columns: const [
                                    DataColumn(label: Text("SL")),
                                    DataColumn(label: Text("MR No")),
                                    DataColumn(label: Text("Payment Date")),
                                    DataColumn(label: Text("Location Name")),
                                    DataColumn(label: Text("Customer Name")),
                                    DataColumn(label: Text("Customer Number")),
                                    DataColumn(label: Text("Seller Name")),
                                    DataColumn(label: Text("Payment Method")),
                                    DataColumn(label: Text("Amount")),
                                    DataColumn(label: Text("Action")),
                                  ],
                                  rows: moneyReceipts.map(
                                        (mr) => DataRow(
                                      cells: [
                                        DataCell(Text(mr.sl.toString())),
                                        DataCell(Text(mr.mrNo)),
                                        DataCell(Text(mr.paymentDate)),
                                        DataCell(Text(mr.locationName)),
                                        DataCell(Text(mr.customerName)),
                                        DataCell(Text(mr.customerNumber)),
                                        DataCell(Text(mr.sellerName)),
                                        DataCell(Text(mr.paymentMethod)),
                                        DataCell(Text(
                                          mr.amount.toStringAsFixed(2),
                                        )),
                                        DataCell(Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.visibility,
                                                color: Color(0xFFF57A56),
                                                size: 20,
                                              ),
                                              onPressed: () {},
                                              tooltip: "View",
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Color(0xFFF57A56),
                                                size: 20,
                                              ),
                                              onPressed: () {},
                                              tooltip: "Delete",
                                            ),
                                          ],
                                        )),
                                      ],
                                    ),
                                  ).toList(),
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
                          ),
                        ),
                      );
                    },
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

Widget _buildDropdownField({
  required TextEditingController controller,
  String? hint,
}) {
  return TextField(
    controller: controller,
    readOnly: true,
    decoration: InputDecoration(
      hintText: hint,
      border: const OutlineInputBorder(),
      isDense: true,
      suffixIcon: const Icon(Icons.arrow_drop_down),
    ),
    onTap: () {},
  );
}

class MoneyReceiptRowData {
  final int sl;
  final String mrNo;
  final String paymentDate;
  final String locationName;
  final String customerName;
  final String customerNumber;
  final String sellerName;
  final String paymentMethod;
  final double amount;

  MoneyReceiptRowData({
    required this.sl,
    required this.mrNo,
    required this.paymentDate,
    required this.locationName,
    required this.customerName,
    required this.customerNumber,
    required this.sellerName,
    required this.paymentMethod,
    required this.amount,
  });
}