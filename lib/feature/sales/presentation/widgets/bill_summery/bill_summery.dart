import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:intl/intl.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/configs/pdf/summary_pdf.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/custom_date_range.dart';
import '../../bloc/summary_bloc/summary_bloc.dart';

class GreatLabSummary extends StatefulWidget {
  const GreatLabSummary({
    super.key,
  });

  @override
  State<GreatLabSummary> createState() => _GreatLabSummaryState();
}

class _GreatLabSummaryState extends State<GreatLabSummary> {
  @override
  void initState() {
    super.initState();
    final summaryBloc = context.read<SummaryBloc>();
    summaryBloc.selectedDateRange = DateRange(DateTime.now(), DateTime.now());

    // Initial load with provided dates:
    context.read<SummaryBloc>().add(LoadSummary(
          fromDate: summaryBloc.selectedDateRange?.start,
          toDate: summaryBloc.selectedDateRange?.end,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SummaryBloc, SummaryState>(
      builder: (context, state) {
        double newBill = 0, dueCollection = 0, testRefund = 0, grandTotal = 0;
        List paymentsAdd = [], paymentsDue = [], paymentsRefund = [];

        if (state is SummaryLoaded) {
          // print("sum : ${state.summaryData}");
          final summary = state.summaryData['summary'];
          newBill = summary['new_bill'] ?? 0;
          dueCollection = summary['due_collection'] ?? 0;
          testRefund = summary['test_refund'] ?? 0;
          grandTotal = summary['grand_total'] ?? 0;

          paymentsAdd = state.summaryData['payments_add'] ?? [];
          // print("paymentsAdd : ${paymentsAdd}");

          paymentsDue = state.summaryData['payments_due'] ?? [];

          paymentsRefund = state.summaryData['payments_refund'] ?? [];
        }
        final width = 1060.00;
        final summaryBloc = context.read<SummaryBloc>();

        return SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Great Lab Summary",
                    style: AppTextStyle.titleLarge(context)),
                gapH8,
                SizedBox(
                  width: 300,
                  child: CustomDateRangeField(
                    selectedDateRange: summaryBloc.selectedDateRange,
                    onDateRangeSelected: (value) {
                      setState(() {
                        summaryBloc.selectedDateRange = value;
                      });
                      if (value != null) {
                        context.read<SummaryBloc>().add(LoadSummary(
                              fromDate: value.start,
                              toDate: value.end,
                            ));
                      }
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Summary Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final isWideScreen = screenWidth > 600;
                    final cardsPerRow = isWideScreen ? 4 : 2;
                    final spacing = 5.0;
                    final totalSpacing = spacing * (cardsPerRow - 1);
                    final boxWidth = (screenWidth - totalSpacing) / cardsPerRow;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        _buildSummaryCard(
                          icon: Icons.note_alt,
                          iconColor: Colors.green,
                          title: 'New Bill',
                          amount: newBill,
                          borderColor: Colors.green,
                          width: boxWidth,
                        ),
                        _buildSummaryCard(
                          icon: Icons.payment,
                          iconColor: Colors.red.shade400,
                          title: 'Due Collection',
                          amount: dueCollection,
                          borderColor: Colors.red.shade400,
                          width: boxWidth,
                        ),
                        _buildSummaryCard(
                          icon: Icons.receipt_long,
                          iconColor: Colors.orange.shade700,
                          title: 'Test Refund',
                          amount: testRefund,
                          borderColor: Colors.orange.shade700,
                          width: boxWidth,
                        ),
                        _buildSummaryCard(
                          icon: Icons.calculate,
                          iconColor: Colors.blue,
                          title: 'Grand Total',
                          amount: grandTotal,
                          borderColor: Colors.blue,
                          width: boxWidth,
                        ),
                      ],
                    );
                  },
                ),



                const SizedBox(height: 12),
                buildCustomTableHeader(width),

                const SizedBox(height: 12),
                buildGroupedSummaryTables(
                  context: context,
                  paymentsAdd: paymentsAdd,
                  paymentsDue: paymentsDue,
                  paymentsRefund: paymentsRefund,
                  maxWidth: width,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildGroupedSummaryTables({
    required BuildContext context,
    required List paymentsAdd,
    required List paymentsDue,
    required List paymentsRefund,
    required double maxWidth,
  }) {
    Map<String, Map<String, List>> groupedData =
        groupPaymentsByDate(paymentsAdd, paymentsDue, paymentsRefund);

    final sortedEntries = groupedData.entries.toList()
      ..sort((a, b) {
        final dateA = DateFormat('dd-MM-yyyy').parse(a.key);
        final dateB = DateFormat('dd-MM-yyyy').parse(b.key);
        return dateA.compareTo(dateB); // Old to new
      });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedEntries.expand((entry) {
        final date = entry.key;
        final dateSections = entry.value;

        return [
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Text(
              'Date: $date',
              style: AppTextStyle.titleMedium(context),
            ),
          ),
          const SizedBox(height: 4),

          const SizedBox(height: 4),
          for (final section in ['Due Collection', 'New Bill', 'Refund']) ...[
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Text(section, style: AppTextStyle.titleSmall(context)),
            ),
            dateSections[section]!.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        // height: 250,
                        padding: const EdgeInsets.only(top: 8, right: 8),
                        width: double.infinity,
                        child:
                            _buildDataTable(maxWidth, dateSections[section]!,section: section),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, right: 8),
                          child: Text(
                            'Total: ৳ ${_calculateTotal(dateSections[section]!)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: Text("No bill available")),
                  ),
          ],
        ];
      }).toList(),
    );
  }

  Map<String, Map<String, List>> groupPaymentsByDate(
      List paymentsAdd, List paymentsDue, List paymentsRefund) {
    Map<String, Map<String, List>> grouped = {};

    void addToGroup(List payments, String type) {
      for (var row in payments) {
        String dateKey = appWidgets
            .convertDateTimeDDMMYYYY(DateTime.tryParse(row['payment_date']));
        grouped[dateKey] ??= {
          'Due Collection': [],
          'New Bill': [],
          'Refund': []
        };
        grouped[dateKey]![type]!.add(row);
      }
    }

    addToGroup(paymentsDue, 'Due Collection');
    addToGroup(paymentsAdd, 'New Bill');
    addToGroup(paymentsRefund, 'Refund');

    return grouped;
  }

  String _calculateTotal(List rows) {
    double total = 0;
    for (var row in rows) {
      total += (row['paid_amount'] ?? 0) as double;
    }
    return total.toStringAsFixed(2);
  }

  Widget _buildDataTable(double maxWidth, List rows, {String section = ""}) {
    const int numColumns = 8;
    const double minColumnWidth = 60;
    final double dynamicColumnWidth =
    (maxWidth / numColumns).clamp(minColumnWidth, double.infinity);

    final dataRows = rows.map((row) {
      // ---------------- Amount logic ----------------
      double amountValue = 0;
      if (section.toLowerCase() == "refund") {
        final caseEffectAmount = row['case_effect']?['amount'];
        if (caseEffectAmount is num) {
          amountValue = caseEffectAmount.toDouble();
        } else {
          amountValue = double.tryParse(caseEffectAmount?.toString() ?? '') ?? 0;
        }
      } else {
        final paidAmount = row['paid_amount'];
        if (paidAmount is num) {
          amountValue = paidAmount.toDouble();
        } else {
          amountValue = double.tryParse(paidAmount?.toString() ?? '') ?? 0;
        }
      }

      // ---------------- Build row ----------------
      return DataRow(
        cells: [
          DataCell(SizedBox(
            width: dynamicColumnWidth,
            child: Text(
              appWidgets.convertDateTime(
                  DateTime.tryParse(row['payment_date'])?.toLocal(), "HH:mm:a"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
          DataCell(SizedBox(
            width: dynamicColumnWidth,
            child: Text(
              row['invoice_number']?.toString() ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
          DataCell(SizedBox(
            width: dynamicColumnWidth,
            child: Text(
              row['patient']?['name'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
          DataCell(SizedBox(
            width: dynamicColumnWidth,
            child: Text(
              row['invoice']?['refer_type'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
          DataCell(SizedBox(
            width: dynamicColumnWidth,
            child: Text(
              row['invoice']?['created_by_name'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
          DataCell(SizedBox(
            width: dynamicColumnWidth,
            child: Text(
              row['payment_type'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
          DataCell(SizedBox(
            width: dynamicColumnWidth,
            child: Text(
              '৳ ${((row['invoice']?['total_bill_amount'] ?? 0) as num).toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
          DataCell(SizedBox(
            width: dynamicColumnWidth,
            child: Text(
              '৳ ${amountValue.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
        ],
      );
    }).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: DataTable(
        showCheckboxColumn: false,
        headingRowHeight: 0, // custom headers used
        dataRowMinHeight: 40,
        dataRowMaxHeight: 40,
        columnSpacing: 0,
        checkboxHorizontalMargin: 0,
        columns: List.generate(numColumns, (index) => const DataColumn(label: SizedBox.shrink())),
        rows: dataRows,
      ),
    );
  }
  Widget buildCustomTableHeader(double maxWidth) {
    const int numColumns = 8;
    const double minColumnWidth = 65;
    final double dynamicColumnWidth =
    (maxWidth / numColumns).clamp(minColumnWidth, double.infinity);

    final headers = [
      'Date',
      'Bill No',
      'Patient',
      'Refd. By',
      'User Name',
      'Payment Type',
      'Bill Amount',
      'Amount'
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        // width: double.infinity,
        decoration: BoxDecoration(
            color: const Color(0xFF6ab129),

            borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8))
        ),
        child: Row(
          children: headers.map((title) {
            return Container(

              width: dynamicColumnWidth,
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required double amount,
    required Color borderColor,
    required double width,
  }) {
    return Container(
      width: width,
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                Text(
                  amount.toStringAsFixed(2),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: borderColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showFullWidthDialog(BuildContext context) {
  final summaryBloc = context.read<SummaryBloc>();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          backgroundColor: AppColors.white,
          child: BlocProvider.value(
            value: summaryBloc,
            child: SizedBox(
              width: 1100,
              height: 700, // total height adjusted to fit content
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: BlocBuilder<SummaryBloc, SummaryState>(
                  builder: (context, state) {
                    List paymentsAdd = [],
                        paymentsDue = [],
                        paymentsRefund = [];

                    var summaryAdd = {};
                    if (state is SummaryLoaded) {
                      summaryAdd = state.summaryData['summary'];

                      paymentsAdd = state.summaryData['payments_add'] ?? [];

                      paymentsDue = state.summaryData['payments_due'] ?? [];

                      paymentsRefund =
                          state.summaryData['payments_refund'] ?? [];
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: GreatLabSummary(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppButton(
                              size: 150,
                              name: "Cancel",
                              color: AppColors.redColor,
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 10),
                            AppButton(
                              name: "Save & Print",
                              size: 150,
                              color: AppColors.primaryColor,
                              onPressed: () {
                                printSummary(
                                  context: context,
                                  summery: summaryAdd,
                                  paymentsAdd: paymentsAdd,
                                  paymentsDue: paymentsDue,
                                  paymentsRefund: paymentsRefund,
                                  startDate: appWidgets.convertDateTimeDDMMYYYY(
                                      summaryBloc.selectedDateRange?.start),
                                  endDate: appWidgets.convertDateTimeDDMMYYYY(
                                      summaryBloc.selectedDateRange?.end),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  });
}
