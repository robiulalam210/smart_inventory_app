import '/core/core.dart';

import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/dotted_border.dart';
import '../../../../feature.dart';

class InvoiceDueCollectionViewDialog extends StatefulWidget {
  const InvoiceDueCollectionViewDialog({
    super.key,
  });

  @override
  State<InvoiceDueCollectionViewDialog> createState() =>
      _InvoiceDueCollectionViewDialogState();
}

class _InvoiceDueCollectionViewDialogState
    extends State<InvoiceDueCollectionViewDialog> {
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

  final TextEditingController _searchController = TextEditingController();

  Widget _buildSubmitFilterButton() {
    return AppButton(
      onPressed: () {
        context
            .read<DueCollectionBloc>()
            .add(LoadDueCollectionDetails(_searchController.text.trim()));
      },
      name: "Submit",
    );
  }

  double effectiveDueAmountUp = 0.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      contentPadding: EdgeInsets.all(20),
      title: const Text(
        'Invoice Due Collection',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      content: SizedBox(
        width: 750,
        // height: 600,
        child: BlocListener<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is PaymentLoading) {
              appLoader(context, "Waiting....");
            } else if (state is PaymentSuccess) {
              context.read<TransactionBloc>().add(LoadTransactionInvoices());
              Navigator.of(context).pop(true); // Close loader
              Navigator.of(context).pop(true); // Close dialog
              context
                  .read<DueCollectionBloc>()
                  .add(LoadDueCollectionDetails(""));
              final transactionBloc = context.read<TransactionBloc>();

              transactionBloc.add(LoadMoneyReceiptDetails(invoiceId:
                  state.response['receiptNumber'],context:  context,isRefund: false));

              transactionBloc.add(LoadTransactionInvoices());
              showCustomToast(
                context: context,
                title: 'Success!',
                description: 'Partial payment recorded!',
                type: ToastificationType.success,
                icon: Icons.check_circle,
                primaryColor: Colors.green,
              );
              context
                  .read<DashboardBloc>()
                  .add(ChangeDashboardScreen(index: 1));
            } else if (state is PaymentError) {
              Navigator.of(context).pop(); // Close loader
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}')),
              );
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration:
                              const BoxDecoration(color: Colors.white12),
                          child: CustomSearchTextFormField(
                            onClear: () {
                              _searchController.clear();
                              context.read<DueCollectionBloc>().add(
                                  LoadDueCollectionDetails(
                                      _searchController.text.trim()));
                            },
                            controller: _searchController,
                            hintText: "Search Invoice No",
                            onChanged: (String value) {
                              // No manual call needed, handled by listener + debounce
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      _buildSubmitFilterButton(),
                    ],
                  ),
                ),
                gapH16,
                BlocBuilder<DueCollectionBloc, DueCollectionState>(
                  builder: (context, state) {
                    if (state is DueCollectionDetailsLoading) {
                      return CircularProgressIndicator.adaptive();
                    } else if (state is DueCollectionDetailsLoaded) {
                      // Correct: Access moneyReceiptDetails from the state object
                      final invoice = state.moneyReceiptDetails;
                      final double totalOriginalDiscount =
                          invoice.discount ?? 0;
                      final double totalCurrentDiscount =
                          totalOriginalDiscount + _additionalDiscount;
                      final double currentNetAmount =
                          (invoice.totalBillAmount ?? 0) - totalCurrentDiscount;
                      final double currentlyPaidAmount =
                          invoice.paidAmount ?? 0;
                      final double currentPayAmount =
                          double.tryParse(collectionAmountController.text) ??
                              0.0;

                      final double effectiveDueAmount = (() {
                        final calculatedEffectiveDue =
                            invoice.due ?? 0 - _additionalDiscount;
                        return calculatedEffectiveDue >= 0
                            ? calculatedEffectiveDue
                            : 0.0;
                      })();

                      effectiveDueAmountUp = effectiveDueAmount;

                      final double updatedDueAmountAfterCollection = (() {
                        final calculatedUpdatedDue =
                            effectiveDueAmount - currentPayAmount;
                        return calculatedUpdatedDue >= 0
                            ? calculatedUpdatedDue
                            : 0.0;
                      })();

                      return invoice.deliveryDate == null
                          ? SizedBox.shrink()
                          : SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DottedLine(

                                  ),

                                  gapH4,
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                // border: Border.all(color: Colors.grey, width: 0.5),
                                                borderRadius:
                                                    BorderRadius.circular(8),
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
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    children: [
                                                      _buildTableCell(
                                                          'Invoice No',
                                                          isHeader: true),
                                                      _buildTableCell(invoice
                                                              .invoiceNumber ??
                                                          ""),
                                                      _buildTableCell('Date',
                                                          isHeader: true),
                                                      _buildTableCell(AppWidgets()
                                                          .convertDateTimeDDMMMYYYY(
                                                              DateTime.parse(invoice
                                                                  .deliveryDate
                                                                  .toString()))),
                                                      _buildTableCell(
                                                          'Total Amount',
                                                          isHeader: true),
                                                      _buildTableCell((invoice
                                                                  .totalBillAmount ??
                                                              0)
                                                          .toStringAsFixed(2)),
                                                    ],
                                                  ),
                                                  TableRow(
                                                    children: [
                                                      _buildTableCell('Name',
                                                          isHeader: true),
                                                      _buildTableCell(
                                                          invoice.patient.name),
                                                      _buildTableCell(
                                                          'Delivery Date',
                                                          isHeader: true),
                                                      _buildTableCell(AppWidgets()
                                                          .convertDateTimeDDMMMYYYY(
                                                              DateTime.parse(invoice
                                                                  .deliveryDate
                                                                  .toString()))),
                                                      _buildTableCell(
                                                          'Discount',
                                                          isHeader: true),
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
                                                      _buildTableCell(
                                                          'Created By',
                                                          isHeader: true),
                                                      _buildTableCell("Test"),
                                                      _buildTableCell(
                                                          'Reference By',
                                                          isHeader: true),
                                                      _buildTableCell(invoice
                                                              .referInfo.name ??
                                                          invoice
                                                              .referInfo.type),
                                                      _buildTableCell(
                                                          'Net Amount',
                                                          isHeader: true),
                                                      _buildTableCell(
                                                          currentNetAmount
                                                              .toStringAsFixed(
                                                                  2)),
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
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                // border: Border.all(color: Colors.grey, width: 0.5),
                                                borderRadius:
                                                    BorderRadius.circular(8),
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
                                                      _buildTableCell(
                                                          'Receive Amount',
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
                                                      _buildTableCell(
                                                          'Due Amount',
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
                                  DottedLine(

                                  ),

                                  gapH4,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Invoice Details',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),

                                      const SizedBox(height: 8),
                                      Table(
                                        border: TableBorder.all(
                                            color: Colors.grey.shade200,
                                            width: 0.5),
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
                                                height:
                                                    25, // Fixed header height
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Name',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 25,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.center,
                                                    child: Text(
                                                      'Rate',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 25,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.center,
                                                    child: Text(
                                                      'Discount',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 25,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.center,
                                                    child: Text(
                                                      'Total',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          ...invoice.invoiceDetails
                                              .map((item) => _buildItemRow(
                                                    item.name ?? "",
                                                    item.fee?.toStringAsFixed(
                                                            2) ??
                                                        "0.00",
                                                    item.discount
                                                            ?.toStringAsFixed(
                                                                2) ??
                                                        "0.00",
                                                    item.fee?.toStringAsFixed(
                                                            2) ??
                                                        "0.00",
                                                  )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      DottedLine(

                                      ),

                                      SizedBox(
                                        height: 8,
                                      ),
                                      // --- Start of consolidated discount row in the main table ---
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                              width: 300,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    // border: Border.all(color: Colors.grey, width: 0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Table(
                                                    // border: TableBorder.all(color: Colors.grey),
                                                    columnWidths: const {
                                                      0: FlexColumnWidth(3),
                                                      1: FlexColumnWidth(2),
                                                    },
                                                    children: [
                                                      TableRow(
                                                        children: [
                                                          _buildTableCell(
                                                              'Total',
                                                              isHeader: true),
                                                          _buildTableCell((invoice
                                                                      .totalBillAmount ??
                                                                  0)
                                                              .toStringAsFixed(
                                                                  2)),
                                                        ],
                                                      ),

                                                      // TableRow(
                                                      //   children: [
                                                      //     _buildTableCell(
                                                      //         'Discount Limit',
                                                      //         isHeader: true),
                                                      //     _buildTableCell((invoice
                                                      //                 .testDiscountApplyAmount ??
                                                      //             0)
                                                      //         .toStringAsFixed(
                                                      //             2)),
                                                      //   ],
                                                      // ),
                                                      //
                                                      // /// ✅ Discount Checkbox and Input Field in a Column
                                                      // TableRow(
                                                      //   children: [
                                                      //     _buildTableCell(
                                                      //         'Discount',
                                                      //         isHeader: true),
                                                      //     Padding(
                                                      //       padding:
                                                      //           const EdgeInsets
                                                      //               .all(3.0),
                                                      //       child: Row(
                                                      //         crossAxisAlignment:
                                                      //             CrossAxisAlignment
                                                      //                 .start,
                                                      //         children: [
                                                      //           // SizedBox(
                                                      //           //   height: 10,
                                                      //           //   child:
                                                      //           //       Checkbox(
                                                      //           //     value:
                                                      //           //         showDiscountInput,
                                                      //           //     onChanged:
                                                      //           //         (bool?
                                                      //           //             newValue) {
                                                      //           //       if (invoice.testDiscountApplyAmount ==
                                                      //           //               null ||
                                                      //           //           invoice.testDiscountApplyAmount ==
                                                      //           //               0) {
                                                      //           //         showCustomToast(
                                                      //           //           context:
                                                      //           //               context,
                                                      //           //           title:
                                                      //           //               'Warning!',
                                                      //           //           description:
                                                      //           //               'No discount allowed!',
                                                      //           //           type:
                                                      //           //               ToastificationType.warning,
                                                      //           //         );
                                                      //           //         return;
                                                      //           //       }
                                                      //           //
                                                      //           //       setState(
                                                      //           //           () {
                                                      //           //         showDiscountInput =
                                                      //           //             newValue!;
                                                      //           //         if (!showDiscountInput) {
                                                      //           //           _discountController
                                                      //           //               .clear();
                                                      //           //           _additionalDiscount =
                                                      //           //               0.0;
                                                      //           //         }
                                                      //           //       });
                                                      //           //     },
                                                      //           //   ),
                                                      //           //
                                                      //           // ),
                                                      //           // if (showDiscountInput)
                                                      //             SizedBox(
                                                      //               width: 60,
                                                      //               height: 30,
                                                      //               child:
                                                      //                   TextFormField(
                                                      //                 onChanged:
                                                      //                     (value) {
                                                      //                   final newDiscount =
                                                      //                       double.tryParse(value) ??
                                                      //                           0;
                                                      //                   final oldDiscount =
                                                      //                       invoice.discount ??
                                                      //                           0;
                                                      //                   final discountLimit =
                                                      //                       invoice.testDiscountApplyAmount ??
                                                      //                           0;
                                                      //
                                                      //                   final totalDiscount =
                                                      //                       oldDiscount +
                                                      //                           newDiscount;
                                                      //
                                                      //                   if (newDiscount <
                                                      //                       0) {
                                                      //                     showCustomToast(
                                                      //                       context:
                                                      //                           context,
                                                      //                       title:
                                                      //                           'Invalid Discount',
                                                      //                       description:
                                                      //                           'Discount cannot be negative.',
                                                      //                       type:
                                                      //                           ToastificationType.error,
                                                      //                     );
                                                      //                     _discountController
                                                      //                         .clear();
                                                      //                     _additionalDiscount =
                                                      //                         0.0;
                                                      //                     return;
                                                      //                   }
                                                      //
                                                      //                   if (totalDiscount >
                                                      //                       discountLimit) {
                                                      //                     showCustomToast(
                                                      //                       context:
                                                      //                           context,
                                                      //                       title:
                                                      //                           'Limit Exceeded',
                                                      //                       description:
                                                      //                           'Total discount cannot exceed ${discountLimit.toStringAsFixed(2)}.',
                                                      //                       type:
                                                      //                           ToastificationType.warning,
                                                      //                     );
                                                      //                     _discountController
                                                      //                         .clear();
                                                      //                     _additionalDiscount =
                                                      //                         0.0;
                                                      //                     return;
                                                      //                   }
                                                      //
                                                      //                   setState(
                                                      //                       () {
                                                      //                     _additionalDiscount =
                                                      //                         newDiscount;
                                                      //                     // If needed, recalculate due amount here
                                                      //                   });
                                                      //                 },
                                                      //                 controller:
                                                      //                     _discountController,
                                                      //                 keyboardType:
                                                      //                     TextInputType
                                                      //                         .number,
                                                      //                 textAlign:
                                                      //                     TextAlign
                                                      //                         .center,
                                                      //                 style: const TextStyle(
                                                      //                     fontSize:
                                                      //                         14),
                                                      //                 inputFormatters: [
                                                      //                   FilteringTextInputFormatter.allow(
                                                      //                       RegExp(r'^\d*\.?\d{0,2}')),
                                                      //                 ],
                                                      //                 decoration:
                                                      //                     InputDecoration(
                                                      //                   hintText:
                                                      //                       'Amt',
                                                      //                   hintStyle: const TextStyle(
                                                      //                       fontSize:
                                                      //                           12,
                                                      //                       color:
                                                      //                           Colors.grey),
                                                      //                   contentPadding: const EdgeInsets
                                                      //                       .symmetric(
                                                      //                       vertical:
                                                      //                           6,
                                                      //                       horizontal:
                                                      //                           6),
                                                      //                   isDense:
                                                      //                       true,
                                                      //                   filled:
                                                      //                       true,
                                                      //                   fillColor: Colors
                                                      //                       .grey
                                                      //                       .shade100,
                                                      //                   border:
                                                      //                       OutlineInputBorder(
                                                      //                     borderRadius:
                                                      //                         BorderRadius.circular(6),
                                                      //                     borderSide: BorderSide(
                                                      //                         color: Colors.grey.shade300,
                                                      //                         width: 0.5),
                                                      //                   ),
                                                      //                   enabledBorder:
                                                      //                       OutlineInputBorder(
                                                      //                     borderRadius:
                                                      //                         BorderRadius.circular(6),
                                                      //                     borderSide: BorderSide(
                                                      //                         color: Colors.grey.shade300,
                                                      //                         width: 0.5),
                                                      //                   ),
                                                      //                   focusedBorder:
                                                      //                       OutlineInputBorder(
                                                      //                     borderRadius:
                                                      //                         BorderRadius.circular(6),
                                                      //                     borderSide:
                                                      //                         const BorderSide(color: Colors.blue),
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
                                                          _buildTableCell(
                                                              'Net Amount',
                                                              isHeader: true),
                                                          _buildTableCell(
                                                              currentNetAmount
                                                                  .toStringAsFixed(
                                                                      2)),
                                                        ],
                                                      ),

                                                      TableRow(
                                                        children: [
                                                          _buildTableCell(
                                                              'Received Amount',
                                                              isHeader: true),
                                                          _buildTableCell(((double.tryParse(
                                                                          collectionAmountController
                                                                              .text) ??
                                                                      0.0) +
                                                                  currentlyPaidAmount)
                                                              .toStringAsFixed(
                                                                  2)),
                                                        ],
                                                      ),

                                                      TableRow(
                                                        children: [
                                                          _buildTableCell(
                                                              'Due Amount:',
                                                              isHeader: true),
                                                          _buildTableCell(
                                                            updatedDueAmountAfterCollection
                                                                .toStringAsFixed(
                                                                    2),
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
                                  DottedLine(

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
                                                  controller:
                                                      collectionAmountController,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        'Collection Amount',
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 12,
                                                            vertical: 12),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        AppSizes.radius,
                                                      ),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade300),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade300),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.blue),
                                                    ),
                                                  ),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            r'^\d*\.?\d{0,2}')),
                                                    // allows only positive numbers with up to 2 decimals
                                                  ],
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                          decimal: true),
                                                  onChanged: (value) {
                                                    final amount =
                                                        double.tryParse(
                                                                value) ??
                                                            0;
                                                    final maxAmount =
                                                        effectiveDueAmount;

                                                    if (amount > maxAmount) {
                                                      final correctedAmount =
                                                          maxAmount
                                                              .toStringAsFixed(
                                                                  2);
                                                      showCustomToast(
                                                        context: context,
                                                        title: 'Warning!',
                                                        description:
                                                            'Collection amount cannot exceed: $correctedAmount',
                                                        type: ToastificationType
                                                            .warning,
                                                        icon: Icons.warning,
                                                        primaryColor:
                                                            Colors.orange,
                                                      );

                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        collectionAmountController
                                                                .text =
                                                            correctedAmount;
                                                        collectionAmountController
                                                                .selection =
                                                            TextSelection
                                                                .fromPosition(
                                                          TextPosition(
                                                              offset:
                                                                  correctedAmount
                                                                      .length),
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
                                                      text:
                                                          _selectedPaymentMethod),
                                                  readOnly: true,
                                                  decoration: InputDecoration(
                                                    labelText: 'Payment Method',
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 12,
                                                            vertical: 12),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        AppSizes.radius,
                                                      ),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade300),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .grey.shade300),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.blue),
                                                    ),
                                                  ),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            r'^\d*\.?\d{0,2}')),
                                                    // allows only positive numbers with up to 2 decimals
                                                  ],
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
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
                            );
                    } else if (state is DueCollectionDetailsError) {
                      return Text(state.error);
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        SizedBox(
          width: 80,
          child: AppButton(
            onPressed: () {
              context
                  .read<DueCollectionBloc>()
                  .add(LoadDueCollectionDetails(""));
              Navigator.of(context).pop(false);
            },
            name: 'Close',
            color: Colors.redAccent,
          ),
        ),
        BlocBuilder<DueCollectionBloc, DueCollectionState>(
          builder: (context, state) {
            if (state is DueCollectionDetailsLoaded) {
              final invoice = state.moneyReceiptDetails;

              return BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, state) {
                  if (state is PaymentLoading) {
                    return const CircularProgressIndicator();
                  }
                  return SizedBox(
                    width: 80,
                    child: AppButton(
                      onPressed: () {
                        final collectedAmount =
                            double.tryParse(collectionAmountController.text);
                        final additionalDiscountToSend = _additionalDiscount;

                        if (collectedAmount != null &&
                            collectedAmount >= 0 &&
                            collectedAmount <= effectiveDueAmountUp) {
                          BlocProvider.of<PaymentBloc>(context).add(
                            CollectPartialPaymentEvent(
                              invoiceId: invoice.invoiceId.toString(),
                              collectedAmount: collectedAmount,
                              paymentMethod: _selectedPaymentMethod,
                              additionalDiscount: additionalDiscountToSend,
                              totalTestPrice:
                                  invoice.testDiscountApplyAmount ?? 0.0,
                            ),
                          );
                        } else {
                          showCustomToast(
                            context: context,
                            title: 'Warning!',
                            description:
                                'Enter valid amount (0–$effectiveDueAmountUp) and select a payment method.',
                            type: ToastificationType.warning,
                            icon: Icons.warning,
                            primaryColor: Colors.orange,
                          );
                        }
                      },
                      name: "Save",
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildTableCell(String text,
      {bool isHeader = false, bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Text(
        text,
        style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? Colors.red : null,
            fontSize: 12),
      ),
    );
  }  Widget _buildTableCellCenter(String text,
      {bool isHeader = false, bool isHighlighted = false}) {
    return Container( alignment:
    Alignment.center,
      padding: const EdgeInsets.all(1),
      child: Text(
        text,
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
        _buildTableCellCenter(rate),
        _buildTableCellCenter(discount),
        _buildTableCellCenter(total),
      ],
    );
  }
}
