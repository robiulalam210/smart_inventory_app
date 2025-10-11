import 'package:dotted_border/dotted_border.dart';
import '../../../../core/configs/configs.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/dotted_border.dart';
import '../../../../core/widgets/show_custom_toast.dart';
import '../../../feature.dart';

class InvoiceDueCollectionDialog extends StatefulWidget {
  final String invoiceId;
  final double dueAmount;
  final double paidAmount;
  final InvoiceModelSync items;

  const InvoiceDueCollectionDialog({
    super.key,
    required this.invoiceId,
    required this.dueAmount,
    required this.paidAmount,
    required this.items,
  });

  @override
  State<InvoiceDueCollectionDialog> createState() =>
      _InvoiceDueCollectionDialogState();
}

class _InvoiceDueCollectionDialogState
    extends State<InvoiceDueCollectionDialog> {
  TextEditingController collectionAmountController = TextEditingController();
  final _discountController = TextEditingController();
  final String _selectedPaymentMethod = "Cash";

  bool showDiscountInput =
      false; // Controls visibility and enabled state of the discount input
  double _additionalDiscount = 0.0;

  @override
  void initState() {
    super.initState();
    collectionAmountController = TextEditingController();
    collectionAmountController.addListener(_updatePaymentSummary);
    _discountController.addListener(_onDiscountAmountChanged);
  }

  @override
  void dispose() {
    collectionAmountController.removeListener(_updatePaymentSummary);
    collectionAmountController.dispose();
    _discountController.removeListener(_onDiscountAmountChanged);
    _discountController.dispose();
    super.dispose();
  }

  void _updatePaymentSummary() {
    setState(() {}); // Triggers a rebuild when the collection amount changes
  }

  void _onDiscountAmountChanged() {
    if (showDiscountInput) {
      // Only update _additionalDiscount if the discount input is currently active
      final enteredDiscount = double.tryParse(_discountController.text) ?? 0.0;
      setState(() {
        _additionalDiscount = enteredDiscount >= 0 ? enteredDiscount : 0.0;
        // _updateCollectionAmountFromDiscount();
      });
    }
  }

  // --- Getters for calculations ---
  double get totalOriginalDiscount => widget.items.discount ?? 0;

  // Total discount now includes any additional discount if the checkbox is on
  double get totalCurrentDiscount =>
      totalOriginalDiscount + _additionalDiscount;

  // Net amount payable after applying all discounts (original + additional)
  double get currentNetAmount =>
      widget.items.totalBillAmount ?? 0 - totalCurrentDiscount;

  // Amount already paid before this current transaction
  double get currentlyPaidAmount => widget.items.paidAmount ?? 0;

  // Amount being collected in this transaction
  double get currentPayAmount =>
      double.tryParse(collectionAmountController.text) ?? 0.0;

  // The actual amount remaining to be paid AFTER any additional discount
  double get effectiveDueAmount {
    final calculatedEffectiveDue = widget.dueAmount - _additionalDiscount;
    // Ensure effective due amount doesn't go below zero due to excessive discount
    return calculatedEffectiveDue >= 0 ? calculatedEffectiveDue : 0.0;
  }

  // The due amount after the current collection
  double get updatedDueAmountAfterCollection {
    final calculatedUpdatedDue = effectiveDueAmount - currentPayAmount;
    // Ensure updated due amount doesn't go below zero
    return calculatedUpdatedDue >= 0 ? calculatedUpdatedDue : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentLoading) {
          appLoader(context, "Waiting....");
        } else if (state is PaymentSuccess) {
          context.read<TransactionBloc>().add(LoadTransactionInvoices());
          Navigator.of(context).pop(true); // Close loader
          Navigator.of(context).pop(true); // Close dialog
          context.read<DashboardBloc>().add(ChangeDashboardScreen(index: 2));
        } else if (state is PaymentError) {
          Navigator.of(context).pop(); // Close loader
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.error}')),
          );
        }
      },
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: const EdgeInsets.all(20),
        title: const Text(
          'Invoice Due Collection',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        content: SizedBox(
          width: 750,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                DottedBorder(
                  options: CustomPathDottedBorderOptions(
                    dashPattern: [4, 4],
                    strokeWidth: 1,
                    color: Colors.black,
                    padding: EdgeInsets.zero,
                    customPath: (size) {
                      final path = Path();
                      path.moveTo(0, size.height);
                      path.lineTo(size.width, size.height);
                      return path;
                    },
                  ),
                  child: const SizedBox(
                    width: double.infinity,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.transparent),
                    ),
                  ),
                ),

                gapH4,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              // border: Border.all(color: Colors.grey, width: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(2.5),
                                1: FlexColumnWidth(2.5),
                                2: FlexColumnWidth(2.5),
                                3: FlexColumnWidth(2.5),
                                4: FlexColumnWidth(2.5),
                                5: FlexColumnWidth(2.5),
                              },
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  children: [
                                    _buildTableCell('Invoice No',
                                        isHeader: true),
                                    _buildTableCell(widget.items.invoiceNumber),
                                    _buildTableCell('Date', isHeader: true),
                                    _buildTableCell(AppWidgets()
                                        .convertDateTimeDDMMMYYYY(
                                            DateTime.parse(widget
                                                .items.createDate
                                                .toString()))),
                                    _buildTableCell('Total Amount',
                                        isHeader: true),
                                    _buildTableCell(
                                        (widget.items.totalBillAmount ?? 0)
                                            .toStringAsFixed(2)),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    _buildTableCell('Name', isHeader: true),
                                    _buildTableCell(
                                        widget.items.patient.name ?? ""),
                                    _buildTableCell('Delivery Date',
                                        isHeader: true),
                                    _buildTableCell(AppWidgets()
                                        .convertDateTimeDDMMMYYYY(
                                            DateTime.parse(widget
                                                .items.createDate
                                                .toString()))),
                                    _buildTableCell('Discount', isHeader: true),
                                    _buildTableCell(
                                      ((double.tryParse(_discountController
                                                      .text) ??
                                                  0.0) +
                                              totalOriginalDiscount)
                                          .toStringAsFixed(2),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    _buildTableCell('Created By',
                                        isHeader: true),
                                    _buildTableCell("Test"),
                                    _buildTableCell('Reference By',
                                        isHeader: true),
                                    _buildTableCell(
                                        widget.items.referInfo.name ??
                                            widget.items.referInfo.type ??
                                            ""),
                                    _buildTableCell('Net Amount',
                                        isHeader: true),
                                    _buildTableCell(
                                        currentNetAmount.toStringAsFixed(2)),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 250,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              // border: Border.all(color: Colors.grey, width: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Table(
                              // border: TableBorder.all(color: Colors.grey),
                              columnWidths: const {
                                0: FlexColumnWidth(2.5),
                                1: FlexColumnWidth(2.5),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    _buildTableCell('Receive Amount',
                                        isHeader: true),
                                    _buildTableCell(((double.tryParse(
                                                    collectionAmountController
                                                        .text) ??
                                                0.0) +
                                            currentlyPaidAmount)
                                        .toStringAsFixed(2)),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    _buildTableCell('Due Amount',
                                        isHeader: true),
                                    _buildTableCell(
                                      updatedDueAmountAfterCollection
                                          .toStringAsFixed(2),
                                      isHighlighted:
                                          updatedDueAmountAfterCollection
                                                  .abs() >
                                              0.001,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ),
                  ],
                ),
                DottedBorder(
                  options: CustomPathDottedBorderOptions(
                    dashPattern: [4, 4],
                    strokeWidth: 1,
                    color: Colors.black,
                    padding: EdgeInsets.zero,
                    customPath: (size) {
                      final path = Path();
                      path.moveTo(0, size.height);
                      path.lineTo(size.width, size.height);
                      return path;
                    },
                  ),
                  child: const SizedBox(
                    width: double.infinity,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.transparent),
                    ),
                  ),
                ),

                gapH4,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Invoice Details',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),
                    Table(
                      border: TableBorder.all(
                          color: Colors.grey.shade200, width: 0.5),
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                      },
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(
                            color: Color(0xFF6ab129),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              topLeft: Radius.circular(8),
                            ),
                          ),
                          children: [
                            SizedBox(
                              height: 25, // Fixed header height
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Name',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Rate',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Discount',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ...widget.items.invoiceDetails
                            .map((item) => _buildItemRow(
                                  item.testName ?? "",
                                  item.fee.toStringAsFixed(2),
                                  item.discount.toStringAsFixed(2),
                                  item.fee.toStringAsFixed(2),
                                )),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    DottedLine(
                      height: 2,
                      color: Colors.black,
                      dashPattern: [6, 3],
                      strokeWidth: 2,
                    ),

                    SizedBox(
                      height: 8,
                    ),
                    // --- Start of consolidated discount row in the main table ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                            width: 300,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  // border: Border.all(color: Colors.grey, width: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Table(
                                  // border: TableBorder.all(color: Colors.grey),
                                  columnWidths: const {
                                    0: FlexColumnWidth(3),
                                    1: FlexColumnWidth(1),
                                    2: FlexColumnWidth(2),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        _buildTableCell('Total',
                                            isHeader: true),
                                        Container(),

                                        _buildTableCell(
                                            (widget.items.totalBillAmount ?? 0)
                                                .toStringAsFixed(2)),
                                      ],
                                    ),

                                    // TableRow(
                                    //   children: [
                                    //     _buildTableCell('Discount Limit',
                                    //         isHeader: true),
                                    //     Container(),
                                    //
                                    //     _buildTableCell((widget.items
                                    //                 .testDiscountApplyAmount ??
                                    //             0)
                                    //         .toStringAsFixed(2)),
                                    //   ],
                                    // ),
                                    //
                                    // /// ✅ Discount Checkbox and Input Field in a Column
                                    // TableRow(
                                    //   children: [
                                    //     _buildTableCell('Discount',
                                    //         isHeader: true),
                                    //     // Padding(
                                    //     //   padding: const EdgeInsets.all(3.0),
                                    //     //   child: Row(
                                    //     //     crossAxisAlignment:
                                    //     //     CrossAxisAlignment.start,
                                    //     //     children: [
                                    //     //       SizedBox(
                                    //     //         height: 10,
                                    //     //         child: Checkbox(
                                    //     //           value: showDiscountInput,
                                    //     //           onChanged: (bool? newValue) {
                                    //     //             if (widget.items
                                    //     //                 .testDiscountApplyAmount ==
                                    //     //                 null ||
                                    //     //                 widget.items
                                    //     //                     .testDiscountApplyAmount ==
                                    //     //                     0) {
                                    //     //               showCustomToast(
                                    //     //                 context: context,
                                    //     //                 title: 'Warning!',
                                    //     //                 description:
                                    //     //                 'No discount allowed!',
                                    //     //                 type: ToastificationType
                                    //     //                     .warning,
                                    //     //               );
                                    //     //               return;
                                    //     //             }
                                    //     //
                                    //     //             setState(() {
                                    //     //               showDiscountInput =
                                    //     //               newValue!;
                                    //     //               if (!showDiscountInput) {
                                    //     //                 _discountController
                                    //     //                     .clear();
                                    //     //                 _additionalDiscount =
                                    //     //                 0.0;
                                    //     //               }
                                    //     //             });
                                    //     //           },
                                    //     //         ),
                                    //     //
                                    //     //
                                    //     //       ),
                                    //     //
                                    //     //     ],
                                    //     //   ),
                                    //     // ),
                                    //     Container(),
                                    //
                                    //     Padding(
                                    //       padding: const EdgeInsets.all(3.0),
                                    //       child: Row(
                                    //         crossAxisAlignment:
                                    //             CrossAxisAlignment.start,
                                    //         children: [
                                    //
                                    //           // if (showDiscountInput)
                                    //             SizedBox(
                                    //               width: 70,
                                    //               height: 30,
                                    //               child: TextFormField(
                                    //                 onChanged: (value) {
                                    //                   final newDiscount = double.tryParse(value) ?? 0;
                                    //                   final oldDiscount = widget.items.discount ?? 0;
                                    //                   final discountLimit = widget.items.testDiscountApplyAmount ?? 0;
                                    //
                                    //                   final totalDiscount = oldDiscount + newDiscount;
                                    //
                                    //                   if (newDiscount < 0) {
                                    //                     showCustomToast(
                                    //                       context: context,
                                    //                       title: 'Invalid Discount',
                                    //                       description: 'Discount cannot be negative.',
                                    //                       type: ToastificationType.error,
                                    //                     );
                                    //                     _discountController.clear();
                                    //                     _additionalDiscount = 0.0;
                                    //                     return;
                                    //                   }
                                    //
                                    //                   if (totalDiscount > discountLimit) {
                                    //                     showCustomToast(
                                    //                       context: context,
                                    //                       title: 'Limit Exceeded',
                                    //                       description:
                                    //                       'Total discount cannot exceed ${discountLimit.toStringAsFixed(2)}.',
                                    //                       type: ToastificationType.warning,
                                    //                     );
                                    //                     _discountController.clear();
                                    //                     _additionalDiscount = 0.0;
                                    //                     return;
                                    //                   }
                                    //
                                    //                   setState(() {
                                    //                     _additionalDiscount = newDiscount;
                                    //                     // If needed, recalculate due amount here
                                    //                   });
                                    //                 },
                                    //
                                    //                 controller:
                                    //                     _discountController,
                                    //                 keyboardType:
                                    //                     TextInputType.number,
                                    //                 textAlign: TextAlign.center,
                                    //                 style: const TextStyle(
                                    //                     fontSize: 14),
                                    //                 inputFormatters: [
                                    //                   FilteringTextInputFormatter
                                    //                       .allow(RegExp(
                                    //                           r'^\d*\.?\d{0,2}')),
                                    //                 ],
                                    //                 decoration: InputDecoration(
                                    //                   hintText: 'Amt',
                                    //                   hintStyle:
                                    //                       const TextStyle(
                                    //                           fontSize: 12,
                                    //                           color:
                                    //                               Colors.grey),
                                    //                   contentPadding:
                                    //                       const EdgeInsets
                                    //                           .symmetric(
                                    //                           vertical: 6,
                                    //                           horizontal: 6),
                                    //                   isDense: true,
                                    //                   filled: true,
                                    //                   fillColor:
                                    //                       Colors.grey.shade100,
                                    //                   border:
                                    //                       OutlineInputBorder(
                                    //                     borderRadius:
                                    //                         BorderRadius
                                    //                             .circular(6),
                                    //                     borderSide: BorderSide(
                                    //                         color: Colors
                                    //                             .grey.shade300,
                                    //                         width: 0.5),
                                    //                   ),
                                    //                   enabledBorder:
                                    //                       OutlineInputBorder(
                                    //                     borderRadius:
                                    //                         BorderRadius
                                    //                             .circular(6),
                                    //                     borderSide: BorderSide(
                                    //                         color: Colors
                                    //                             .grey.shade300,
                                    //                         width: 0.5),
                                    //                   ),
                                    //                   focusedBorder:
                                    //                       OutlineInputBorder(
                                    //                     borderRadius:
                                    //                         BorderRadius
                                    //                             .circular(6),
                                    //                     borderSide:
                                    //                         const BorderSide(
                                    //                             color: Colors
                                    //                                 .blue),
                                    //                   ),
                                    //                 ),
                                    //               ),
                                    //             ),
                                    //         ],
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),

                                    TableRow(
                                      children: [
                                        _buildTableCell('Net Amount',
                                            isHeader: true),        Container(),

                                        _buildTableCell(currentNetAmount
                                            .toStringAsFixed(2)),
                                      ],
                                    ),

                                    TableRow(
                                      children: [
                                        _buildTableCell('Received Amount',
                                            isHeader: true),        Container(),

                                        _buildTableCell(((double.tryParse(
                                                        collectionAmountController
                                                            .text) ??
                                                    0.0) +
                                                currentlyPaidAmount)
                                            .toStringAsFixed(2)),
                                      ],
                                    ),

                                    TableRow(
                                      children: [
                                        _buildTableCell('Due Amount:',
                                            isHeader: true),        Container(),

                                        _buildTableCell(
                                          updatedDueAmountAfterCollection
                                              .toStringAsFixed(2),
                                          isHighlighted:
                                              updatedDueAmountAfterCollection
                                                      .abs() >
                                                  0.001,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    )
                  ],
                ),
                DottedBorder(
                  options: CustomPathDottedBorderOptions(
                    dashPattern: [4, 4],
                    strokeWidth: 1,
                    color: Colors.black,
                    padding: EdgeInsets.zero,
                    customPath: (size) {
                      final path = Path();
                      path.moveTo(0, size.height);
                      path.lineTo(size.width, size.height);
                      return path;
                    },
                  ),
                  child: const SizedBox(
                    width: double.infinity,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.transparent),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: TextFormField(
                                controller: collectionAmountController,
                                decoration: InputDecoration(
                                  labelText: 'Collection Amount',
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radius,
                                    ),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.blue),
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}')),
                                  // allows only positive numbers with up to 2 decimals
                                ],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                onChanged: (value) {
                                  final amount = double.tryParse(value) ?? 0;
                                  final maxAmount = effectiveDueAmount;

                                  if (amount > maxAmount) {
                                    final correctedAmount =
                                        maxAmount.toStringAsFixed(2);
                                    showCustomToast(
                                      context: context,
                                      title: 'Warning!',
                                      description:
                                          'Collection amount cannot exceed: $correctedAmount',
                                      type: ToastificationType.warning,
                                      icon: Icons.warning,
                                      primaryColor: Colors.orange,
                                    );

                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      collectionAmountController.text =
                                          correctedAmount;
                                      collectionAmountController.selection =
                                          TextSelection.fromPosition(
                                        TextPosition(
                                            offset: correctedAmount.length),
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: TextFormField(
                                controller: TextEditingController(
                                    text: _selectedPaymentMethod),
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Payment Method',
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radius,
                                    ),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.blue),
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}')),
                                  // allows only positive numbers with up to 2 decimals
                                ],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Close'),
          ),
          BlocBuilder<PaymentBloc, PaymentState>(
            builder: (context, state) {
              if (state is PaymentLoading) {
                return const CircularProgressIndicator();
              }
              return ElevatedButton(
                onPressed: () {
                  final collectedAmount =
                      double.tryParse(collectionAmountController.text);
                  final additionalDiscountToSend = _additionalDiscount;

                  if (collectedAmount != null &&
                      collectedAmount >= 0 &&
                      collectedAmount <= effectiveDueAmount) {
                    BlocProvider.of<PaymentBloc>(context).add(
                      CollectPartialPaymentEvent(
                        invoiceId: widget.invoiceId.toString(),
                        collectedAmount: collectedAmount,
                        paymentMethod: _selectedPaymentMethod,
                        additionalDiscount: additionalDiscountToSend, totalTestPrice: widget.items.testDiscountApplyAmount??0,
                      ),
                    );
                  } else {
                    showCustomToast(
                      context: context,
                      title: 'Warning!',
                      description:
                          'Enter valid amount (0–$effectiveDueAmount) and select a payment method.',
                      type: ToastificationType.warning,
                      icon: Icons.warning,
                      primaryColor: Colors.orange,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Save', style: TextStyle(fontSize: 16)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text,
      {bool isHeader = false, bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Text(
        text,textAlign: isHeader ?null: TextAlign.center,
        style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? Colors.red : null,
            fontSize: 12),
      ),
    );
  }

  TableRow _buildItemRow(
      String name, String rate, String discount, String total) {
    return TableRow(
      children: [
        _buildTableCell(name),
        _buildTableCell(rate),
        _buildTableCell(discount),
        _buildTableCell(total),
      ],
    );
  }
}
