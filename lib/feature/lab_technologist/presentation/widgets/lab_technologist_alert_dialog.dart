import 'dart:io';
import '/core/core.dart';
import '/feature/lab_technologist/presentation/bloc/lab_technologist/lab_technologist_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../core/configs/pdf/generate_pathology_pdf.dart';
import '../../../common/data/models/print_layout_model.dart';
import '../../../common/presentation/print_layout_bloc/print_layout_bloc.dart';
import '../../../sample_collector/data/model/sample_collector_model.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart'
    hide TableRow;
import '../../../sample_collector/presentation/bloc/sample_collector_bloc.dart';
import '../../data/model/single_report_model.dart';

class LabTechnologistInvoiceDialog extends StatefulWidget {
  final String invoiceNo;
  final String invoiceApp;
  final String patientName;
  final String dob;
  final String hnNo;
  final String gender;
  final String billDate;
  final InvoiceDetail testId;
  final SampleCollectorInvoice sampleCollectorInvoice;

  const LabTechnologistInvoiceDialog({
    super.key,
    required this.invoiceApp,
    required this.invoiceNo,
    required this.patientName,
    required this.dob,
    required this.hnNo,
    required this.gender,
    required this.billDate,
    required this.testId,
    required this.sampleCollectorInvoice,
  });

  @override
  State<LabTechnologistInvoiceDialog> createState() =>
      _LabTechnologistInvoiceDialogState();
}

class _LabTechnologistInvoiceDialogState
    extends State<LabTechnologistInvoiceDialog> {


  final quillController = quill.QuillController.basic();
  File? pickedImage;

// Pick image
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  } // Helper function

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          SizedBox(
            child: Text(
              ": ${value ?? ''}",
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  Map<String, dynamic>? token;

  @override
  void initState() {
    super.initState();
    context.read<LabTechnologistBloc>().add(
        LoadSingleTestInformation(testId: widget.testId.testId.toString()));
    _loadToken();
  }

  Future<void> _loadToken() async {
    final data = await LocalDB.getLoginInfo();
    setState(() {
      token = data;

    });
  }
  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: EdgeInsets.zero,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Test Report ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
                onPressed: () {
                  AppRoutes.pop(context);
                },
                icon: Icon(HugeIcons.strokeRoundedCancelCircle))
          ],
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1100,
          maxHeight: 700,
          minWidth: 1100,
          minHeight: 700,
        ),
        child: SingleChildScrollView(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: Main Content
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Card(
                  color: Colors.white,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildInfoRow('Patient Name', widget.invoiceNo),
                              const SizedBox(height: 4),
                              _buildInfoRow('Patient HN', widget.hnNo),
                              const SizedBox(height: 4),
                              _buildInfoRow('Sex',
                                  widget.sampleCollectorInvoice.patient.gender),
                              const SizedBox(height: 4),
                              _buildInfoRow(
                                'DOB',
                                appWidgets.convertDateTimeDDMMYYYY(
                                  DateTime.tryParse(widget
                                      .sampleCollectorInvoice
                                      .patient
                                      .dateOfBirth),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildInfoRow('Reference By',
                                  widget.sampleCollectorInvoice.referInfo.type),
                              const SizedBox(height: 4),
                              _buildInfoRow('Reference Doctor',
                                  widget.sampleCollectorInvoice.referInfo.name),
                              const SizedBox(height: 4),
                              _buildInfoRow(
                                  'Collection Date',
                                  appWidgets.convertDateTimeDDMMMYYYY(
                                      DateTime.tryParse(widget
                                          .testId.collectionDate
                                          .toString()))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                  'Report Date',
                                  appWidgets.convertDateTimeDDMMYYYYHHMMA(
                                      DateTime.now())),
                              const SizedBox(height: 4),
                            _buildInfoRow('Branch Name', "${token?['branchName'] ?? ''}"),
                              const SizedBox(height: 4),
                              _buildInfoRow('Branch ID',
                                  ""),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              BlocListener<LabTechnologistBloc, LabTechnologistState>(
                listener: (context, state) {
                  if (state is LabTechnologistLoading) {
                    CircularProgressIndicator.adaptive();
                  }
                  if (state is LabTechnologistSuccess) {

                    showCustomToast(
                      context: context,
                      title: 'Success!',
                      description: state.message,
                      type: ToastificationType.success,
                      icon: Icons.check_circle,
                      primaryColor: Colors.green,
                    );
                    AppRoutes.pop(context);
                    context
                        .read<SampleCollectorBloc>()
                        .add(LoadSampleCollectorInvoices(
                          pageNumber: 1,
                          pageSize: 20,
                        ));
                  } else if (state is LabTechnologistError) {
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
                child: BlocBuilder<LabTechnologistBloc, LabTechnologistState>(
                  buildWhen: (previous, current) =>
                      current is SingleTestInformationLoading ||
                      current is SingleTestInformationLoaded ||
                      current is SingleTestInformationError,
                  builder: (context, state) {
                    if (state is SingleTestInformationLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is SingleTestInformationError) {
                      return Center(child: Text(state.error));
                    }

                    if (state is SingleTestInformationLoaded) {
                      final testInfo = state.model.testName;

                      if (testInfo == null) return const SizedBox();

                      // Check test group
                      final groupName =
                          testInfo.testGroupName?.toLowerCase() ?? '';
                      final addStatus = widget.testId.reportAddStatus ?? "0";
                      final confirmedStatus =
                          widget.testId.reportConfirmedStatus ?? "0";

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Text(
                                testInfo.category?.testCategoryName ?? '',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 5),

                            Text(
                              testInfo.name ?? '',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),

                            // Pathology
                            if (groupName == "pathology" &&
                                testInfo.labParameter != null)
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(AppSizes.radius),
                                    topRight: Radius.circular(AppSizes.radius)),
                                child: Table(
                                  border: TableBorder.all(
                                      color: Colors.grey.shade300),
                                  columnWidths: const {
                                    0: FlexColumnWidth(3),
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(1),
                                    3: FlexColumnWidth(2),
                                  },
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(
                                                  AppSizes.radius),
                                              topRight: Radius.circular(
                                                  AppSizes.radius))),
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Test Parameter'),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Result'),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Unit'),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Normal Value'),
                                        ),
                                      ],
                                    ),
                                    ...testInfo.labParameter!.map((item) {
                                      final showOptions = item.showOptions == 1;

                                      final options =
                                          parseOptions(item.options);
                                      String? dropdownValue;
                                      if (item.result != null &&
                                          options.any((op) => op.toLowerCase() == item.result!.toLowerCase())) {
                                        dropdownValue = options.firstWhere(
                                              (op) => op.toLowerCase() == item.result!.toLowerCase(),
                                        );
                                      } else if (options.isNotEmpty) {
                                        dropdownValue = options.first;
                                        item.result = dropdownValue; // auto-set initial result
                                      }

                                      return TableRow(
                                          decoration: BoxDecoration(),
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                  item.parameterName ?? ''),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: showOptions
                                                  ? DropdownButtonFormField<
                                                      String>(
                                                      value: dropdownValue,
                                                      isExpanded: false,
                                                      // 👈 Prevents overflow when text is long
                                                      decoration:
                                                          InputDecoration(
                                                        // labelText: "Select option",
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 4,
                                                                vertical: 4),
                                                      ),
                                                      icon: const Icon(
                                                          Icons.arrow_drop_down,
                                                          color: Colors.blue),
                                                      dropdownColor:
                                                          Colors.white,
                                                      onChanged: (val) {
                                                        setState(() {
                                                          item.result = val;
                                                        });
                                                      },
                                                      items: options
                                                          .map(
                                                            (op) =>
                                                                DropdownMenuItem<
                                                                    String>(
                                                              value: op,
                                                              child: Text(
                                                                op,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis, // 👈 handles very long text
                                                              ),
                                                            ),
                                                          )
                                                          .toList(),
                                                      validator: (val) => val ==
                                                                  null ||
                                                              val.isEmpty
                                                          ? "Please select a value"
                                                          : null,
                                                    )
                                                  : CustomInputField(
                                                      controller:
                                                          TextEditingController(
                                                              text:
                                                                  item.result ??
                                                                      ""),
                                                      onChanged: (val) {
                                                        item.result = val;
                                                      },
                                                      hintText: 'Input Result',
                                                      isRequiredLable: false,
                                                      keyboardType:
                                                          TextInputType.text,
                                                    ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Text(
                                                  item.parameterUnit ?? ''),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Text(
                                                  item.referenceValue ?? ''),
                                            ),
                                          ]);
                                    }),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 10),

                            // Radiology
                            if (groupName == "radiology") ...[
                              // Use a rich text editor like flutter_quill or zefyr
                              QuillSimpleToolbar(
                                controller: quillController,
                                config: const QuillSimpleToolbarConfig(),
                              ),
                              // Editor
                              Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: quill.QuillEditor.basic(
                                  controller: quillController,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Text("Report file upload"),
                                  gapW8,
                                  // Image picker
                                  ElevatedButton.icon(
                                    icon: Icon(Icons.image),
                                    label: Text(pickedImage == null?
                                        "upload file"
                                        : "Change file"),
                                    onPressed: pickImage,
                                  ),
                                  gapW8,
                                  if (pickedImage != null)
                                    Container(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: SizedBox(
                                        height: 60,
                                        width: 100,
                                        child: Image.file(pickedImage!),
                                      ),
                                    ),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            ],

                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Confirm button: only show if addStatus == "1" && confirmedStatus == "0"

                                if (addStatus == "1" && confirmedStatus == "0")
                                  const SizedBox(width: 8),

                                // Print button: always visible
                                AppButton(
                                  name: "Print",
                                  onPressed: () {
                                    final isRadiology =
                                        groupName == "radiology";
                                    String? htmlDetails;
                                    if (isRadiology) {
                                      final delta =
                                          quillController.document.toDelta();
                                      final deltaAsMapList = delta
                                          .map((op) => op.toJson())
                                          .toList();
                                      htmlDetails = QuillDeltaToHtmlConverter(
                                              deltaAsMapList)
                                          .convert();
                                    }

                                    final details = !isRadiology
                                        ? testInfo.labParameter!
                                            .map((e) => Detail(
                                                  id: e.id,
                                                  parameterId: e.id,
                                                  parameterName:
                                                      e.parameterName,
                                                  result: e.result,
                                                  unit: e.parameterUnit,
                                                  parameter: DetailParameter(
                                                    referenceValue:
                                                        e.referenceValue,
                                                    options:
                                                        parseOptions(e.options),
                                                    parameterUnit:
                                                        e.parameterUnit,
                                                  ),
                                                  lowerValue: e.referenceValue,
                                                  upperValue: e.referenceValue,
                                                  parameterGroupId: e
                                                      .parameterGroupId
                                                      ?.toString(),
                                                ))
                                            .toList()
                                        : <Detail>[];
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Scaffold(
                                          backgroundColor: Colors.grey,
                                          body: PdfPreview.builder(
                                            useActions: true,
                                            allowSharing: false,
                                            canDebug: false,
                                            canChangeOrientation: false,
                                            canChangePageFormat: false,
                                            dynamicLayout: true,
                                            build: (format) async {
                                              return await generatePathologyPdfDraft(
                                                  isRadiology,
                                                  context,
                                                  testInfo,
                                                  widget.hnNo,
                                                  widget.patientName,
                                                  widget.gender,
                                                  widget.dob,
                                                  widget.billDate,
                                                  details,
                                                  context
                                                          .read<
                                                              PrintLayoutBloc>()
                                                          .layoutModel ??
                                                      PrintLayoutModel(),
                                                  htmlDetails);
                                            },
                                            initialPageFormat: PdfPageFormat.a4,
                                            pdfPreviewPageDecoration:
                                                BoxDecoration(
                                                    color: Colors.grey),
                                            actionBarTheme: PdfActionBarTheme(
                                              backgroundColor:
                                                  AppColors.primaryColor,
                                              iconColor: Colors.white,
                                              textStyle: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                            actions: [
                                              IconButton(
                                                onPressed: () =>
                                                    AppRoutes.pop(context),
                                                icon: const Icon(Icons.cancel,
                                                    color: Colors.red),
                                              ),
                                            ],
                                            pagesBuilder: (context, pages) {
                                              debugPrint(
                                                  'Rendering ${pages.length} pages');
                                              return PageView.builder(
                                                itemCount: pages.length,
                                                scrollDirection: Axis.vertical,
                                                itemBuilder: (context, index) {
                                                  final page = pages[index];
                                                  return Container(
                                                    color: Colors.grey,
                                                    alignment: Alignment.center,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image(
                                                        image: page.image,
                                                        fit: BoxFit.contain),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                AppButton(
                                  name: "Save",
                                  onPressed: () {
                                    final isRadiology =
                                        groupName.toLowerCase() == "radiology";

                                    String? htmlDetails;
                                    if (isRadiology) {
                                      final delta =
                                          quillController.document.toDelta();
                                      final deltaAsMapList = delta
                                          .map((op) => op.toJson())
                                          .toList();
                                      htmlDetails = QuillDeltaToHtmlConverter(
                                              deltaAsMapList)
                                          .convert();
                                    }

                                    final parameterResults =
                                        testInfo.labParameter ?? [];

                                    // ✅ Validation: if not radiology and no parameters, block save
                                    if (!isRadiology &&
                                        parameterResults.isEmpty) {
                                      showCustomToast(
                                        context: context,
                                        title: 'Failed!',
                                        description:
                                            '"No parameters found for this test"',
                                        type: ToastificationType.error,
                                        icon: Icons.error,
                                        primaryColor: Colors.red,
                                      );

                                      return; // stop execution
                                    }


                                    context.read<LabTechnologistBloc>().add(
                                          SaveTestReportEvent(
                                            invoiceId: widget
                                                .sampleCollectorInvoice.id
                                                .toString(),
                                            invoiceNo: widget.invoiceNo,
                                            invoiceApp: widget.invoiceApp,
                                            patientId: widget
                                                .sampleCollectorInvoice
                                                .patient
                                                .id
                                                .toString(),
                                            testId:
                                                widget.testId.testId.toString(),
                                            testName: widget.testId.testName
                                                .toString(),
                                            testGroup: widget.testId.testInfo
                                                    ?.group?.name ??
                                                groupName.capitalize(),
                                            testCategory: widget.testId.testInfo
                                                    ?.category?.name ??
                                                "",
                                            gender: widget
                                                .sampleCollectorInvoice
                                                .patient
                                                .gender,
                                            remark: "",
                                            // status: "0",
                                            radiologyReportImage: isRadiology
                                                ? pickedImage
                                                : null,
                                            parameterResults: isRadiology
                                                ? []
                                                : parameterResults,
                                            radiologyReportDetails: htmlDetails,
                                          ),
                                        );
                                  },
                                ),

                                const SizedBox(width: 8),

                                // Cancel button: always visible
                                AppButton(
                                  color: AppColors.redAccent,
                                  name: "Cancel",
                                  onPressed: () {
                                    AppRoutes.pop(context);
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),

              // Right: Sidebar form
            ],
          ),
        ),
      ),
    );
  }

  List<String> parseOptions(dynamic rawOptions) {
    if (rawOptions == null) return [];

    // If already a List<String>, just return it
    if (rawOptions is List<String>) {
      return rawOptions
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // If it's a String, split by line breaks or commas
    if (rawOptions is String) {
      return rawOptions
          .split(RegExp(r'[\n,]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Fallback: convert to string
    return [rawOptions.toString()];
  }
}
