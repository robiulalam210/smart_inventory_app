import 'dart:io';
import '/core/core.dart';
import '/feature/common/presentation/print_layout_bloc/print_layout_bloc.dart';
import '/feature/lab_technologist/presentation/bloc/lab_technologist/lab_technologist_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart'
    hide TableRow;
import '../../../../core/configs/pdf/generate_pathology_pdf.dart';
import '../../../common/data/models/print_layout_model.dart';
import '../../../sample_collector/data/model/sample_collector_model.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import '../../../sample_collector/presentation/bloc/sample_collector_bloc.dart';
import '../../data/model/single_report_model.dart';
import 'build_info_row_hader.dart';
import 'build_pathology_table_update_dialog.dart';

class LabTechnologistTestUpdateDialog extends StatefulWidget {
  final String invoiceNo;
  final String patientName;
  final String dob;
  final String hnNo;
  final String gender;
  final String billDate;
  final InvoiceDetail testId;
  final SampleCollectorInvoice sampleCollectorInvoice;

  const LabTechnologistTestUpdateDialog({
    super.key,
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
  State<LabTechnologistTestUpdateDialog> createState() =>
      _LabTechnologistInvoiceDialogState();
}

class _LabTechnologistInvoiceDialogState
    extends State<LabTechnologistTestUpdateDialog> {
  Map<String, dynamic>? token;

  @override
  void initState() {
    super.initState();
    context.read<LabTechnologistBloc>().add(LoadSingleReportInformation(
        testId: widget.testId.testId.toString(), invoiceNo: widget.invoiceNo));
    _loadToken();
  }

  Future<void> _loadToken() async {
    final data = await LocalDB.getLoginInfo();
    setState(() {
      token = data;
    });
  }

  quill.QuillController quillController = quill.QuillController.basic();
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
  }

  bool _quillInitialized = false;
  bool _imageLoaded = false;

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
              "Test Report Update & Confirm",
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
                              buildInfoRow('Patient Name', widget.invoiceNo),
                              const SizedBox(height: 4),
                              buildInfoRow('Patient HN', widget.hnNo),
                              const SizedBox(height: 4),
                              buildInfoRow('Sex',
                                  widget.sampleCollectorInvoice.patient.gender),
                              const SizedBox(height: 4),
                              buildInfoRow(
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
                              buildInfoRow('Reference By',
                                  widget.sampleCollectorInvoice.referInfo.type),
                              const SizedBox(height: 4),
                              buildInfoRow('Reference Doctor',
                                  widget.sampleCollectorInvoice.referInfo.name),
                              const SizedBox(height: 4),
                              buildInfoRow(
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
                              buildInfoRow(
                                  'Report Date',
                                  appWidgets.convertDateTimeDDMMYYYYHHMMA(
                                      DateTime.now())),
                              const SizedBox(height: 4),
                              buildInfoRow('Branch Name', ""),
                              const SizedBox(height: 4),
                              buildInfoRow('Branch ID', ""),
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
                    AppRoutes.pop(context);

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
                      current is SingleReportInformationLoading ||
                      current is SingleReportInformationLoaded ||
                      current is SingleReportInformationError,
                  builder: (context, state) {
                    if (state is SingleReportInformationLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is SingleReportInformationError) {
                      return Center(child: Text(state.error));
                    }

                    if (state is SingleReportInformationLoaded) {
                      final testInfo = state.model.report;
                      if (testInfo == null) return const SizedBox();

                      final groupName = testInfo.testGroup?.toLowerCase() ?? '';
                      final addStatus = widget.testId.reportAddStatus ?? "0";
                      final confirmedStatus =
                          widget.testId.reportConfirmedStatus ?? "0";

                      // Initialize quillController only once
                      if (!_quillInitialized && groupName == "radiology") {
                        final radiologyReport = testInfo.radiologyReportDetails;
                        if (radiologyReport != null) {
                          final plainText = htmlToPlainText(radiologyReport);
                          final textWithNewline = plainText.endsWith('\n')
                              ? plainText
                              : '$plainText\n';
                          quillController = quill.QuillController(
                            document: quill.Document()
                              ..insert(0, textWithNewline),
                            selection: const TextSelection.collapsed(offset: 0),
                          );
                        } else {
                          quillController = quill.QuillController.basic();
                        }
                        _quillInitialized = true;
                      }

                      if (!_imageLoaded) {
                        final data = state.model.report?.radiogyReportImage;

                        if (data != null && data.isNotEmpty) {
                          if (data.endsWith(".pdf")) {
                            // PDF: open with default desktop app
                            final filePath =
                                File(data).existsSync() ? data : null;
                            if (filePath != null) {
                              Process.run('start', [filePath],
                                  runInShell: true); // Windows
                              // macOS: Process.run('open', [filePath])
                              // Linux: Process.run('xdg-open', [filePath])
                            } else {
                              debugPrint("PDF file not found: $data");
                            }
                            _imageLoaded = true;
                          } else if (RegExp(r'^[A-Za-z0-9+/=]+$')
                              .hasMatch(data)) {
                            // Base64 image
                            try {
                              final Uint8List bytes = base64Decode(data);
                              bytesToFile(bytes, "report_image.png")
                                  .then((file) {
                                setState(() {
                                  pickedImage = file;
                                  _imageLoaded = true;
                                });
                              });
                            } catch (e) {
                              debugPrint("Error decoding Base64 image: $e");
                              _imageLoaded = true;
                            }
                          } else {
                            debugPrint("Unknown format: $data");
                            _imageLoaded = true;
                          }
                        } else {
                          _imageLoaded = true;
                        }
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Text(
                                testInfo.testCategory ?? '',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              testInfo.testName ?? '',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),

                            // Pathology Table
                            if (groupName == "pathology" &&
                                testInfo.parameterGroup != null)
                              BuildPathologyTable(
                                details: testInfo.details ?? [],
                              ),

                            const SizedBox(height: 10),

                            // Radiology Editor
                            if (groupName == "radiology") ...[
                              QuillSimpleToolbar(
                                controller: quillController,
                                config: const QuillSimpleToolbarConfig(),
                              ),
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
                                  const Text("Report file upload"),
                                  gapW8,
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.image),
                                    label: Text(pickedImage == null
                                        ? "upload file"
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
                                ],
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (addStatus == "1" && confirmedStatus == "0")
                                  AppButton(
                                    name: "Confirm",
                                    onPressed: () {
                                      context.read<LabTechnologistBloc>().add(
                                            ConfirmReportEvent(
                                              invoiceNo: widget.invoiceNo,
                                              testId: widget.testId.testId
                                                  .toString(),
                                            ),
                                          );
                                    },
                                  ),
                                if (addStatus == "1" && confirmedStatus == "0")
                                  const SizedBox(width: 8),
                                AppButton(
                                    name: "Print",
                                    onPressed: () {
                                      final isRadiology =
                                          groupName == "radiology";

                                      final details = !isRadiology
                                          ? testInfo.details!
                                              .map((e) => Detail(
                                                    id: e.id,
                                                    parameterId: e.parameterId,
                                                    parameterName:
                                                        e.parameterName,
                                                    result: e.result,
                                                    unit: e.parameter
                                                        ?.parameterUnit,
                                                    parameter: DetailParameter(
                                                      referenceValue: e
                                                          .parameter
                                                          ?.referenceValue,
                                                      options:
                                                          e.parameter?.options,
                                                      parameterUnit: e.parameter
                                                          ?.parameterUnit,
                                                    ),
                                                    lowerValue: e.parameter
                                                        ?.referenceValue,
                                                    upperValue: e.parameter
                                                        ?.referenceValue,
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
                                                return await generatePathologyPdf(
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
                                                        PrintLayoutModel());
                                              },
                                              initialPageFormat:
                                                  PdfPageFormat.a4,
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
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final page = pages[index];
                                                    return Container(
                                                      color: Colors.grey,
                                                      alignment:
                                                          Alignment.center,
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
                                    }),
                                const SizedBox(width: 8),
                                if (confirmedStatus == "0")
                                  AppButton(
                                    name: "Update",
                                    onPressed: () async {
                                      final isRadiology =
                                          groupName == "radiology";

                                      String? htmlDetails;
                                      File? radiologyImageFile;

                                      if (isRadiology) {
                                        final delta =
                                            quillController.document.toDelta();
                                        htmlDetails = QuillDeltaToHtmlConverter(
                                                delta
                                                    .map((e) => e.toJson())
                                                    .toList())
                                            .convert();
                                        if (pickedImage != null) {
                                          radiologyImageFile = pickedImage;
                                        }
                                      }

                                      final details = !isRadiology
                                          ? testInfo.details!
                                              .map((e) => Detail(
                                                    id: e.id,
                                                    parameterId: e.parameterId,
                                                    parameterName:
                                                        e.parameterName,
                                                    result: e.result,
                                                    unit: e.parameter
                                                        ?.parameterUnit,
                                                    lowerValue: e.parameter
                                                        ?.referenceValue,
                                                    upperValue: e.parameter
                                                        ?.referenceValue,
                                                    parameterGroupId: e
                                                        .parameterGroupId
                                                        ?.toString(),
                                                  ))
                                              .toList()
                                          : <Detail>[];

                                      context.read<LabTechnologistBloc>().add(
                                            UpdateReportDetailsEvent(details,
                                                radiologyReportDetails:
                                                    htmlDetails,
                                                radiologyReportImage:
                                                    radiologyImageFile,
                                                labReportId:
                                                    testInfo.id.toString()),
                                          );
                                    },
                                  ),
                                const SizedBox(width: 8),
                                AppButton(
                                  color: AppColors.redAccent,
                                  name: "Cancel",
                                  onPressed: () {
                                    AppRoutes.pop(context);
                                  },
                                ),
                              ],
                            ),
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
}
