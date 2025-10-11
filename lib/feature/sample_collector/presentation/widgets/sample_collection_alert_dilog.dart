import '/core/core.dart';
import '/feature/sample_collector/data/model/booth_model.dart';
import '/feature/sample_collector/data/model/collector_model.dart';
import '/feature/sample_collector/presentation/bloc/booth_bloc/booth_bloc.dart';
import '/feature/sample_collector/presentation/bloc/collector_bloc/collector_bloc.dart';
import '/feature/sample_collector/presentation/bloc/sample_collector_bloc.dart';
import 'package:pdf/pdf.dart';
import '../../../../core/configs/pdf/generate_invoice_sticker_pdf.dart';
import '../../../common/data/models/print_layout_model.dart';
import '../../../common/presentation/print_layout_bloc/print_layout_bloc.dart';
import '../../data/model/sample_collector_model.dart';

class TestItem {
  final int sl;
  final String testName;
  bool collected;
  int allReadyCollected;
  String collectionDate;
  String collectionTime;
  String? collectorName;

  TestItem({
    required this.sl,
    required this.testName,
    this.allReadyCollected = 0,
    this.collected = false,
    this.collectionDate = 'Not Collect',
    this.collectionTime = 'Not Collect',
    this.collectorName,
  });
}

class SampleCollectorInvoiceDialog extends StatefulWidget {
  final String invoiceNo;
  final String patientName;
  final String dob;
  final String hnNo;
  final String gender;
  final String billDate;
  final SampleCollectorInvoice sampleCollectorInvoice;
  final List<TestItem> testItems;

  const SampleCollectorInvoiceDialog({
    super.key,
    required this.invoiceNo,
    required this.patientName,
    required this.dob,
    required this.hnNo,
    required this.gender,
    required this.billDate,
    required this.sampleCollectorInvoice,
    required this.testItems,
  });

  @override
  State<SampleCollectorInvoiceDialog> createState() =>
      _SampleCollectorInvoiceDialogState();
}

class _SampleCollectorInvoiceDialogState
    extends State<SampleCollectorInvoiceDialog> {
  final TextEditingController commentsController = TextEditingController();
  final ValueNotifier<CollectorLocalModel?> selectedCollector =
      ValueNotifier<CollectorLocalModel?>(null);
  final ValueNotifier<BoothLocalModel?> selectedBooth =
      ValueNotifier<BoothLocalModel?>(null);
  final ValueNotifier<bool> selectAll = ValueNotifier<bool>(false);

  // Move testItems to state and initialize from widget
  late List<TestItem> testItems;

  @override
  void initState() {
    super.initState();
    testItems = List.from(widget.testItems); // Create a mutable copy
    selectAll.value = testItems.every((item) => item.collected);
  }

  void onTestCollectedChanged(int index, bool? value) {
    setState(() {
      testItems[index].collected = value ?? false;
      selectAll.value = testItems.every((item) => item.collected);
    });
  }

  void onSelectAllChanged(bool? value) {
    setState(() {
      final newValue = value ?? false;
      selectAll.value = newValue;

      // Update all test items
      for (var test in testItems) {
        test.collected = newValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSelectedTest = testItems.any((t) => t.collected);
    final selectedTestIds = widget.testItems
        .where((t) => t.collected && t.collectorName == "")
        .map((t) => t.sl)
        .toList();

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: EdgeInsets.zero,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: const Text(
          "Collect Sample",
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
        child: Center(
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

                      // Table header
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                topLeft: Radius.circular(12))),
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 6),
                        child: Row(
                          children: [
                            const SizedBox(
                                width: 30,
                                child: Text('#SL',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12))),
                            const Expanded(
                                flex: 3,
                                child: Text('TEST NAME',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12))),
                            gapW4,
                            const Expanded(
                                flex: 2,
                                child: Text('COLLECTOR NAME',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12))),
                            gapW4,
                            const Expanded(
                                flex: 2,
                                child: Text('COLLECTION DATE',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12))),
                            gapW4,
                            const Expanded(
                                flex: 2,
                                child: Text('COLLECTION TIME',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12))),
                            SizedBox(
                              width: 50,
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

                      // List of tests
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: testItems.length,
                          key: ValueKey(testItems), // unique key

                          itemBuilder: (context, index) {
                            final test = testItems[index];
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 2),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              decoration: BoxDecoration(
                                  color: test.collectorName == ""
                                      ? Colors.white
                                      : AppColors.primaryColorBg,
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade300))),
                              child: Row(
                                children: [
                                  SizedBox(
                                      width: 30,
                                      child: Text(
                                        "${index + 1}",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      )),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                        test.testName,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      )),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      (test.collectorName != null)
                                          ? test.collectorName ?? ""
                                          : selectedCollector.value?.name ??
                                              'N/A',
                                      maxLines: 5,
                                    ),
                                  ),
                                  gapW4,
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                        test.collectionDate,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      )),
                                  gapW4,
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                        test.collectionTime,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      )),
                                  gapW4,
                                  test.allReadyCollected == 1
                                      ? const SizedBox.shrink()
                                      : SizedBox(
                                          width: 40,
                                          height: 25,
                                          child: Checkbox(
                                            value: test.collected,
                                            onChanged: (val) =>
                                                onTestCollectedChanged(
                                                    index, val),
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
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Collect Sample for\n${widget.patientName}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      BlocBuilder<CollectorBloc, CollectorState>(
                        builder: (context, state) {
                          if (state is CollectorLoaded) {
                            return ValueListenableBuilder<CollectorLocalModel?>(
                              valueListenable: selectedCollector,
                              builder: (context, value, child) {
                                return AppDropdown<CollectorLocalModel>(
                                  isRequired: true,
                                  label: 'Collector',
                                  hint: (value == null || value.name.isEmpty)
                                      ? 'Select Collector'
                                      : value.name,
                                  itemList: state.collector,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedCollector.value = val;
                                    });
                                  },
                                  itemBuilder: (item) => DropdownMenuItem(
                                      value: item, child: Text(item.name)),
                                  context: context,
                                );
                              },
                            );
                          } else if (state is CollectorError) {
                            return Text('Error: ${state.message}');
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<BoothBloc, BoothState>(
                        builder: (context, state) {
                          if (state is BoothLoaded) {
                            return ValueListenableBuilder<BoothLocalModel?>(
                              valueListenable: selectedBooth,
                              builder: (context, value, child) {
                                return AppDropdown<BoothLocalModel>(
                                  isRequired: true,
                                  label: 'Booth',
                                  hint: (value == null || value.name.isEmpty)
                                      ? 'Select Booth'
                                      : value.name,
                                  itemList: state.boothLocalModel,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedBooth.value = val;
                                    });
                                  },
                                  itemBuilder: (item) => DropdownMenuItem(
                                      value: item, child: Text(item.name)),
                                  context: context,
                                );
                              },
                            );
                          } else if (state is BoothError) {
                            return Text('Error: ${state.message}');
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                      gapH16,
                      CustomInputField(
                        controller: commentsController,
                        hintText: "Enter Your Comments",
                        keyboardType: TextInputType.name,
                        isRequiredLable: false,
                        isRequired: false,
                        maxLine: 5,
                      ),
                      const Spacer(),
                      gapH16,
                      AppButton(
                        isDisabled: !hasSelectedTest,
                        onPressed: (hasSelectedTest)
                            ? () async {
                                final pdfData = generateInvoiceStickerPdf(
                                  format: PdfPageFormat.a4,
                                  invoiceNumber: widget.invoiceNo,
                                  hnNumber: widget.hnNo,
                                  patientName: widget.patientName,
                                  collectorName:
                                      selectedCollector.value?.name ?? "",
                                  dob: appWidgets.convertDateTimeDDMMYYYY(
                                    DateTime.tryParse(widget
                                        .sampleCollectorInvoice
                                        .patient
                                        .dateOfBirth
                                        .toString()),
                                  ),
                                  create: appWidgets.convertDateTimeDDMMYYYY(
                                    DateTime.tryParse(
                                      widget.sampleCollectorInvoice.createDate,
                                    ),
                                  ),
                                  genderAge:
                                      "${widget.sampleCollectorInvoice.patient.gender.toString()[0]} ${widget.sampleCollectorInvoice.patient.age} Y",
                                  selectedTests: testItems
                                      .where((t) => t.collected)
                                      .map((t) => t.testName)
                                      .toList(),
                                  printLayoutModel: context
                                          .read<PrintLayoutBloc>()
                                          .layoutModel ??
                                      PrintLayoutModel(),
                                );
                                await showInvoiceStickerDialog(
                                  context,
                                  pdfDataFuture: Future.value(pdfData),
                                );
                              }
                            : null,
                        name: 'Print Sticker',
                      ),
                      gapH16,
                      AppButton(
                        isDisabled: selectedCollector.value == null ||
                            selectedCollector.value!.name.isEmpty ||
                            selectedBooth.value == null ||
                            selectedBooth.value!.name.isEmpty ||
                            selectedTestIds.isEmpty ||
                            !hasSelectedTest,
                        onPressed: (selectedCollector.value != null &&
                                selectedCollector.value!.name.isNotEmpty &&
                                selectedBooth.value != null &&
                                selectedBooth.value!.name.isNotEmpty &&
                                selectedTestIds.isNotEmpty &&
                                hasSelectedTest)
                            ? () {
                                context
                                    .read<SampleCollectorBloc>()
                                    .add(UpdateSampleCollectionEvent(
                                      invoiceId: widget
                                          .sampleCollectorInvoice.invoiceNumber,
                                      remark: commentsController.text.trim(),
                                      collectorId:
                                          selectedCollector.value?.id ?? 0,
                                      collectionDate:
                                          DateTime.now().toIso8601String(),
                                      status: "1",
                                      boothId: selectedBooth.value?.id ?? 0,
                                      testIds: widget.testItems
                                          .where((e) =>
                                              e.collected == true &&
                                              e.collectorName == "")
                                          .map((e) => e.sl)
                                          .toList(),
                                      patientID: widget
                                          .sampleCollectorInvoice.patient.id
                                          .toString(),
                                      collectorName:
                                          selectedCollector.value?.name ?? "",
                                    ));

                                // widget.testItems.clear();

                                AppRoutes.pop(context);
                              }
                            : null,
                        name: 'Save',
                      ),
                      gapH16,
                      AppButton(
                          color: AppColors.redAccent,
                          name: "Cancel",
                          onPressed: () {
                            selectedCollector.value = null;
                            selectedBooth.value = null;
                            selectAll.value = false;
                            commentsController.clear();
                            AppRoutes.pop(context);
                          }),
                      gapH16,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
