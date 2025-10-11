import '/core/core.dart';
import 'package:intl/intl.dart';
import '../../../lab_billing/presentation/bloc/due_collection/due_collection_bloc.dart';
import '../../../lab_dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../../sample_collector/data/model/sample_collector_model.dart';
import '../../../sample_collector/presentation/bloc/sample_collector_bloc.dart';
import '../../../transactions/presentation/bloc/payment/payment_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_bloc/transaction_bloc.dart';
import '../bloc/report_delivery_bloc.dart';

class ReportDeliveryAlertDialog extends StatefulWidget {
  final String invoiceNo;
  final String patientName;
  final String dob;
  final String hnNo;
  final String gender;
  final String billDate;
  final SampleCollectorInvoice sampleCollectorInvoice;

  const ReportDeliveryAlertDialog({
    super.key,
    required this.invoiceNo,
    required this.patientName,
    required this.dob,
    required this.hnNo,
    required this.gender,
    required this.billDate,
    required this.sampleCollectorInvoice,
  });

  @override
  State<ReportDeliveryAlertDialog> createState() =>
      _ReportDeliveryAlertDialogState();
}

class _ReportDeliveryAlertDialogState extends State<ReportDeliveryAlertDialog> {
  final ValueNotifier<bool> selectAll = ValueNotifier<bool>(false);
  final TextEditingController dateDeliveryReport = TextEditingController();
  final TextEditingController timeDeliveryReport = TextEditingController();
  final TextEditingController collectedByDeliveryReport =
      TextEditingController();
  final TextEditingController remarkDeliveryReport = TextEditingController();
  final TextEditingController collectionAmount = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectAll.value = widget.sampleCollectorInvoice.details
        .every((item) => item.reportConfirmedStatus.toString() == "1");
    dateDeliveryReport.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    timeDeliveryReport.text = DateFormat('hh-mm:s').format(DateTime.now());
  }

  void onTestCollectedChanged(int index, bool? value) {
    setState(() {
      widget.sampleCollectorInvoice.details[index].isReady = (value ?? false);

      // refresh selectAll state
      selectAll.value = widget.sampleCollectorInvoice.details
          .every((item) => item.reportConfirmedStatus == "1");
    });
  }

  void onSelectAllChanged(bool? value) {
    setState(() {
      final newValue = (value ?? false);
      selectAll.value = newValue;

      for (var test in widget.sampleCollectorInvoice.details) {
        final added = int.tryParse(test.reportAddStatus ?? '0') ?? 0;
        final confirmed = int.tryParse(test.reportConfirmedStatus ?? '0') ?? 0;
        final delivery = int.tryParse(test.deliveryStatus ?? '0') ?? 0;

        if (delivery == 0 && added == 1 && confirmed == 1) {
          test.isReady = newValue;
        }
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateDeliveryReport.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        timeDeliveryReport.text = picked.format(context);
      });
    }
  }

  final collectionAmountController = TextEditingController();
  final ValueNotifier<double> collectedAmount = ValueNotifier<double>(0.0);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: EdgeInsets.zero,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: const Text(
          "Report Delivery",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1100,
          maxHeight: 700,
          minWidth: 1100,
          minHeight: 700,
        ),
        child: MultiBlocListener(
          listeners: [
            BlocListener<PaymentBloc, PaymentState>(
              listener: (context, state) {
                if (state is PaymentLoading) {
                  appLoader(context, "Waiting....");
                } else if (state is PaymentSuccess) {
                  context
                      .read<SampleCollectorBloc>()
                      .add(LoadSampleCollectorInvoices(
                        pageNumber: 1,
                        pageSize: 20,
                      ));

                  Navigator.of(context).pop(true); // Close dialog
                  context
                      .read<DueCollectionBloc>()
                      .add(LoadDueCollectionDetails(""));
                  final transactionBloc = context.read<TransactionBloc>();

                  transactionBloc.add(LoadMoneyReceiptDetails(
                      invoiceId: state.response['receiptNumber'],
                      context: context,
                      isRefund: false));

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
                      .add(ChangeDashboardScreen(index: 5));
                } else if (state is PaymentError) {
                  Navigator.of(context).pop();
                  showCustomToast(
                    context: context,
                    title: 'Failed!',
                    description: state.error,
                    type: ToastificationType.error,
                    icon: Icons.error,
                    primaryColor: Colors.red,
                  );
                }
              },
            ),
            BlocListener<ReportDeliveryBloc, ReportDeliveryState>(
              listener: (context, state) {
                if (state is ReportDeliveryLoading) {
                  appLoader(context, "Waiting....");
                } else if (state is ReportDeliverySuccess) {
                  Navigator.of(context).pop(true); // Close dialog
                  Navigator.pop(context); // go back if needed

                  context
                      .read<SampleCollectorBloc>()
                      .add(LoadSampleCollectorInvoices(
                        pageNumber: 1,
                        pageSize: 20,
                      ));
                  showCustomToast(
                    context: context,
                    title: 'Success!',
                    description: state.message,
                    type: ToastificationType.success,
                    icon: Icons.check_circle,
                    primaryColor: Colors.green,
                  );
                } else if (state is ReportDeliveryFailure) {
                  context
                      .read<SampleCollectorBloc>()
                      .add(LoadSampleCollectorInvoices(
                        pageNumber: 1,
                        pageSize: 20,
                      ));
                  showCustomToast(
                    context: context,
                    title: 'Failed!',
                    description: state.error,
                    type: ToastificationType.error,
                    icon: Icons.error,
                    primaryColor: Colors.red,
                  );
                }
              },
            ),
          ],
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: Main Content
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Invoice info header
                      Card(
                        color: Colors.white,
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style:
                                            DefaultTextStyle.of(context).style,
                                        children: [
                                          const TextSpan(
                                              text: 'Invoice NO  : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(text: widget.invoiceNo),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        style:
                                            DefaultTextStyle.of(context).style,
                                        children: [
                                          const TextSpan(
                                              text: 'HN NO       : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(text: widget.hnNo),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style:
                                            DefaultTextStyle.of(context).style,
                                        children: [
                                          const TextSpan(
                                              text: 'Name        : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(text: widget.patientName),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        style:
                                            DefaultTextStyle.of(context).style,
                                        children: [
                                          const TextSpan(
                                              text: 'Gender      : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(text: widget.gender),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style:
                                            DefaultTextStyle.of(context).style,
                                        children: [
                                          const TextSpan(
                                              text: 'DOB         : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text: appWidgets
                                                  .convertDateTimeDDMMYYYY(
                                                      DateTime.tryParse(widget
                                                          .sampleCollectorInvoice
                                                          .patient
                                                          .dateOfBirth))),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        style:
                                            DefaultTextStyle.of(context).style,
                                        children: [
                                          const TextSpan(
                                              text: 'Bill Date   : ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(text: widget.billDate),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Invoice info header
                      Card(
                        color: Colors.white,
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      controller: dateDeliveryReport,
                                      decoration: InputDecoration(
                                        fillColor: AppColors.whiteColor,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade400,
                                                width: 0.5)),
                                        filled: true,
                                        hintStyle:
                                            AppTextStyle.cardLevelHead(context),
                                        isCollapsed: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: AppColors.blackColor
                                                  .withValues(alpha: 0.8),
                                              width: 0.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: AppColors.primaryColor
                                                  .withValues(alpha: 0.8),
                                              width: 0.5),
                                        ),
                                        contentPadding: const EdgeInsets.only(
                                            top: 10.0, bottom: 10.0, left: 12),
                                        hintText: "Delivery Date",
                                        labelText: "Delivery Date",
                                      ),
                                      keyboardType: TextInputType.datetime,
                                      readOnly: true,
                                      onTap: () => _selectDate(context),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    CustomInputField(
                                      controller: collectedByDeliveryReport,
                                      hintText: "Collected By",
                                      keyboardType: TextInputType.text,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
                                      controller: timeDeliveryReport,
                                      decoration: InputDecoration(
                                        fillColor: AppColors.whiteColor,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey.shade400,
                                                width: 0.5)),
                                        filled: true,
                                        hintStyle:
                                            AppTextStyle.cardLevelHead(context),
                                        isCollapsed: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: AppColors.blackColor
                                                  .withValues(alpha: 0.8),
                                              width: 0.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: AppColors.primaryColor
                                                  .withValues(alpha: 0.8),
                                              width: 0.5),
                                        ),
                                        contentPadding: const EdgeInsets.only(
                                            top: 10.0, bottom: 10.0, left: 12),
                                        hintText: "Delivery Time",
                                        labelText: "Delivery Time",
                                      ),
                                      keyboardType: TextInputType.datetime,
                                      readOnly: true,
                                      onTap: () => _selectTime(context),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    CustomInputField(
                                      controller: remarkDeliveryReport,
                                      hintText: "Comment",
                                      keyboardType: TextInputType.text,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Table header
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            topLeft: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 6),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 30,
                              child: Text('#SL',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12)),
                            ),
                            const Expanded(
                              flex: 4,
                              child: Text('TEST NAME',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12)),
                            ),
                            const Expanded(
                              flex: 2,
                              child: Text('COLLECTION DATE',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12)),
                            ),
                            const Expanded(
                              flex: 1,
                              child: Text('Status',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12)),
                            ),
                            SizedBox(
                              width: 30,
                              child: ValueListenableBuilder<bool>(
                                valueListenable: selectAll,
                                builder: (context, value, child) {
                                  return Checkbox(
                                    value: value,
                                    onChanged: onSelectAllChanged,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

// Table rows
                      Expanded(
                        child: ListView.builder(
                          itemCount:
                              widget.sampleCollectorInvoice.details.length,
                          itemBuilder: (context, index) {
                            final test =
                                widget.sampleCollectorInvoice.details[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 6),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      "${index + 1}",
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: _buildTestNamesCell(test),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      appWidgets.convertDateTimeDDMMYYYY(
                                        DateTime.tryParse(
                                            test.collectionDate.toString()),
                                      ),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: _buildReportStatusCell(test),
                                  ),
                                  SizedBox(
                                    width: 30,
                                    child: Builder(
                                      builder: (context) {
                                        final added = int.tryParse(
                                                test.reportAddStatus ?? '0') ??
                                            0;
                                        final confirmed = int.tryParse(
                                                test.reportConfirmedStatus ??
                                                    '0') ??
                                            0;
                                        final delivery = int.tryParse(
                                                test.deliveryStatus ?? '0') ??
                                            0;

                                        // 1. Hide if Delivered
                                        if (delivery == 1) {
                                          return const SizedBox.shrink();
                                        }

                                        // 2. Show only if Ready (added + confirmed)
                                        if (added == 1 && confirmed == 1) {
                                          return Checkbox(
                                            value: test.isReady == true,
                                            onChanged: (val) =>
                                                onTestCollectedChanged(
                                                    index, val),
                                          );
                                        }

                                        // 3. Hide for Not Ready
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Right: Sidebar form

              SizedBox(
                width: 300,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      gapH16,
                      const Text(
                        'Payment Summary',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      gapH16,
                      ValueListenableBuilder<double>(
                        valueListenable: collectedAmount,
                        builder: (context, value, child) {
                          final total =
                              widget.sampleCollectorInvoice.totalBillAmount;
                          final discount =
                              widget.sampleCollectorInvoice.discount;
                          final netAmount = total - discount;
                          final paidAmount =
                              widget.sampleCollectorInvoice.paidAmount;
                          // final paidAmount = widget.sampleCollectorInvoice.due;
                          final dueAmount = netAmount - paidAmount - value;

                          return Table(
                            columnWidths: const {
                              0: FlexColumnWidth(3),
                              1: FlexColumnWidth(2),
                            },
                            border: TableBorder.symmetric(
                              inside: const BorderSide(
                                  color: Colors.transparent, width: 0.5),
                            ),
                            children: [
                              _buildTableRow(
                                  'Total Amount', total.toStringAsFixed(2)),
                              _buildTableRow('Discount Amount',
                                  discount.toStringAsFixed(2)),
                              _buildTableRow(
                                  'Net Amount', netAmount.toStringAsFixed(2)),
                              _buildTableRow('Received Amount',
                                  (paidAmount + value).toStringAsFixed(2)),
                              if (widget.sampleCollectorInvoice.due > 0)
                                _buildTableRow(
                                    'Due Amount', dueAmount.toStringAsFixed(2)),
                              if (widget.sampleCollectorInvoice.due > 0)
                                TableRow(
                                  children: [
                                    _buildTableCell('Collection',
                                        isHeader: true, withPadding: true),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomInputField(
                                        controller: collectionAmountController,
                                        hintText: "0.0",
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+\.?\d{0,2}')),
                                        ],
                                        onChanged: (val) {
                                          collectedAmount.value =
                                              double.tryParse(val) ?? 0.0;
                                        },
                                        isRequiredLable: false,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          );
                        },
                      ),
                      const Spacer(),
                      gapH16,
                      widget.sampleCollectorInvoice.due > 0
                          ? AppButton(
                              name: "Pay Now",
                              onPressed: () {
                                final collected = double.tryParse(
                                        collectionAmountController.text) ??
                                    0.0;

                                final effectiveDue = (widget
                                        .sampleCollectorInvoice
                                        .totalBillAmount) -
                                    (widget.sampleCollectorInvoice.discount) -
                                    (widget.sampleCollectorInvoice.paidAmount);

                                if (collected >= 0 &&
                                    collected <= effectiveDue) {
                                  BlocProvider.of<PaymentBloc>(context).add(
                                    CollectPartialPaymentEvent(
                                      invoiceId: widget
                                          .sampleCollectorInvoice.id
                                          .toString(),
                                      collectedAmount: collected,
                                      paymentMethod: "Cash",
                                      additionalDiscount: 0.0,
                                      totalTestPrice: widget
                                          .sampleCollectorInvoice
                                          .totalBillAmount,
                                    ),
                                  );
                                  AppRoutes.pop(context);
                                } else {
                                  showCustomToast(
                                    context: context,
                                    title: 'Warning!',
                                    description:
                                        'Enter valid amount (0–$effectiveDue) and select a payment method.',
                                    type: ToastificationType.warning,
                                    icon: Icons.warning,
                                    primaryColor: Colors.orange,
                                  );
                                }
                                selectAll.value = false;
                              },
                            )
                          : SizedBox.shrink(),
                      gapH16,
                      AppButton(
                        name: "Save Report",
                        onPressed: () {
                          final selectedTests = widget
                              .sampleCollectorInvoice.details
                              .where((d) => d.isReady == true)
                              .toList(); // pass full InvoiceDetail objects
                          if (widget.sampleCollectorInvoice.due > 0) {
                            showCustomToast(
                              context: context,
                              title: "Warning!",
                              description:
                                  "This invoice has an outstanding due of "
                                  "${widget.sampleCollectorInvoice.due}. Please clear payment before delivery.",
                              type: ToastificationType.warning,
                              icon: Icons.warning,
                              primaryColor: Colors.orange,
                            );
                            return;
                          }

                          if (selectedTests.isEmpty) {
                            showCustomToast(
                              context: context,
                              title: "Warning!",
                              description: "No tests selected for delivery.",
                              type: ToastificationType.warning,
                              icon: Icons.warning,
                              primaryColor: Colors.orange,
                            );
                            return;
                          }
                          context.read<ReportDeliveryBloc>().add(
                                SubmitReportDelivery(
                                  invoiceNo: widget.invoiceNo,
                                  patientId: widget
                                      .sampleCollectorInvoice.patient.id
                                      .toString(),
                                  deliveryDate: dateDeliveryReport.text,
                                  deliveryTime: timeDeliveryReport.text,
                                  collectedBy: collectedByDeliveryReport.text,
                                  remark: remarkDeliveryReport.text,
                                  selectedTests:
                                      selectedTests, // from your UI selection
                                ),
                              );
                        },
                      ),
                      gapH16,
                      AppButton(
                        color: AppColors.redAccent,
                        name: "Cancel",
                        onPressed: () {
                          selectAll.value = false;
                          AppRoutes.pop(context);
                        },
                      ),
                      gapH16,
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String title, String value, {bool isHeader = false}) {
    return TableRow(
      children: [
        _buildTableCell(title, isHeader: isHeader, withPadding: true),
        _buildTableCell(value, withPadding: true),
      ],
    );
  }

  Widget _buildTableCell(String text,
      {bool isHeader = false, bool withPadding = false}) {
    return Padding(
      padding: withPadding
          ? const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0)
          : EdgeInsets.zero,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildReportStatusCell(InvoiceDetail test) {
    final added = int.tryParse(test.reportAddStatus ?? '0') ?? 0;
    final confirmed = int.tryParse(test.reportConfirmedStatus ?? '0') ?? 0;
    final deliveryStatus = int.tryParse(test.deliveryStatus ?? '0') ?? 0;

    String statusText;
    Color statusColor;

    if (deliveryStatus == 1) {
      // Delivery done → Always Ready
      statusText = 'Delivery';
      statusColor = Colors.green;
    } else if (added == 1 && confirmed == 1) {
      // Report added + confirmed → Ready
      statusText = 'Ready';
      statusColor = Colors.lightBlue;
    } else {
      // Otherwise → Not Ready
      statusText = 'Not Ready';
      statusColor = Colors.red;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(radius: 5, backgroundColor: statusColor),
        const SizedBox(width: 4),
        Text(
          statusText,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: statusColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTestNamesCell(InvoiceDetail test) {
    final added = int.tryParse(test.reportAddStatus ?? '0') ?? 0;
    final confirmed = int.tryParse(test.reportConfirmedStatus ?? '0') ?? 0;

    Color textColor;
    if (added == 1 && confirmed == 1) {
      textColor = Colors.green;
    } else if (added == 1 && confirmed == 0) {
      textColor = Colors.orange;
    } else {
      textColor = Colors.red;
    }

    if (test.collectionStatus == '0') {
      textColor = Colors.red;
    }

    return Text(
      test.testName ?? '',
      style: TextStyle(
        color: textColor,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
