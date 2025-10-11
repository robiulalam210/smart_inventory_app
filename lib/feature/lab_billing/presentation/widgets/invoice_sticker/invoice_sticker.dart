import 'package:barcode_widget/barcode_widget.dart';
import '/core/core.dart';
import 'package:pdf/pdf.dart';
import '../../../../../core/configs/pdf/generate_invoice_sticker_pdf.dart';
import '../../../../../core/widgets/coustom_search_text_field.dart';
import '../../../../../core/widgets/dotted_border.dart';
import '../../../../common/data/models/print_layout_model.dart';
import '../../../../feature.dart';

class InvoiceStickerViewDialog extends StatefulWidget {
  const InvoiceStickerViewDialog({super.key});

  @override
  State<InvoiceStickerViewDialog> createState() =>
      _InvoiceStickerViewDialogState();
}

class _InvoiceStickerViewDialogState extends State<InvoiceStickerViewDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<bool> _selectedTests = []; // Track selected tests
  List<String> _testNames = []; // Store test names

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSubmitFilterButton() {
    return AppButton(
      onPressed: () {
        context
            .read<DueCollectionBloc>()
            .add(LoadDueCollectionDetails(_searchController.text.trim()));
      },
      color: Colors.green,
      name: "Search",
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: const EdgeInsets.all(20),
      title: const Text(
        'Invoice Sticker Print',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      content: SizedBox(
        width: 600,
        child: BlocListener<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is PaymentLoading) {
              appLoader(context, "Waiting....");
            } else if (state is PaymentSuccess) {
              context.read<TransactionBloc>().add(LoadTransactionInvoices());
              Navigator.of(context).pop(true);
              Navigator.of(context).pop(true);
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
                  .add(ChangeDashboardScreen(index: 1));
            } else if (state is PaymentError) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error}')),
              );
            }
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Row
                Row(
                  children: [
                    Expanded(
                      child: CustomSearchTextFormField(
                        onClear: () {
                          _searchController.clear();
                          _testNames.clear();

                          context.read<DueCollectionBloc>().add(
                              LoadDueCollectionDetails(
                                  _searchController.text.trim()));
                        },
                        controller: _searchController,
                        hintText: "Search Invoice No",
                        onChanged: (String value) {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildSubmitFilterButton(),
                  ],
                ),
                const SizedBox(height: 16),

                // Sticker UI
                BlocBuilder<DueCollectionBloc, DueCollectionState>(
                  builder: (context, state) {
                    if (state is DueCollectionDetailsLoading) {
                      return const CircularProgressIndicator.adaptive();
                    } else if (state is DueCollectionDetailsLoaded) {
                      final invoice = state.moneyReceiptDetails;
                      if (invoice.deliveryDate == null) {
                        return const SizedBox.shrink();
                      }

                      // Initialize selected tests when data loads
                      if (_selectedTests.isEmpty &&
                          invoice.invoiceDetails.isNotEmpty) {
                        _selectedTests = List<bool>.filled(
                            invoice.invoiceDetails.length, true);
                        _testNames = invoice.invoiceDetails
                            .map((test) => test.name ?? '')
                            .toList();
                      }

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with "All" checkbox
                            Row(
                              children: [
                                const Text(
                                  'All',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Checkbox(
                                  value: _selectedTests
                                      .every((isSelected) => isSelected),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      for (int i = 0;
                                          i < _selectedTests.length;
                                          i++) {
                                        _selectedTests[i] = value ?? false;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                            const Divider(height: 1),

                            // List of tests with checkboxes
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: List.generate(
                                invoice.invoiceDetails.length,
                                (index) {
                                  return FilterChip(
                                    label: Text(
                                        invoice.invoiceDetails[index].name ??
                                            ''),
                                    selected: _selectedTests[index],
                                    onSelected: (bool value) {
                                      setState(() {
                                        _selectedTests[index] = value;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),

                            const Divider(height: 24, thickness: 1),

                            _buildInfoRow("HN NO", invoice.patient.hnNumber),
                            const SizedBox(height: 6),
                            _buildInfoRow("Name", invoice.patient.name),
                            const SizedBox(height: 6),
                            _buildInfoRow(
                                "Collector", invoice.createdByUser.name ?? ''),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                    child: _buildInfoRow(
                                        "DOB",
                                        appWidgets.convertDateTimeDDMMYYYY(
                                            DateTime.tryParse(invoice
                                                .patient.dateOfBirth
                                                .toString())))),
                                const SizedBox(width: 8),
                                Text(
                                    "${invoice.patient.gender} ${invoice.patient.age} yr",
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Barcode
                            Center(
                              child: Column(
                                children: [
                                  BarcodeWidget(
                                    barcode: Barcode.code128(),
                                    data: invoice.invoiceNumber ?? "",
                                    width: 200,
                                    height: 30,
                                    drawText: false,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    invoice.invoiceNumber ?? "",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  )
                                ],
                              ),
                            ),

                            // const SizedBox(height: 12),
                            DottedLine(
                              height: 2,
                            ),

                          ],
                        ),
                      );
                    } else if (state is DueCollectionDetailsError) {
                      return Text(state.error);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        AppButton(
          size: 80,
          color: Colors.redAccent,
          onPressed: () {
            context.read<DueCollectionBloc>().add(LoadDueCollectionDetails(""));
            Navigator.of(context).pop(false);
          },
          name: "Cancel",
        ),
        BlocBuilder<DueCollectionBloc, DueCollectionState>(
          builder: (context, state) {
            if (state is DueCollectionDetailsLoaded) {
              final invoice = state.moneyReceiptDetails;

              return AppButton(
                size: 80,
                onPressed: () async {
                  final selectedTests = <String>[];
                  for (int i = 0; i < _selectedTests.length; i++) {
                    if (_selectedTests[i]) {
                      selectedTests.add(_testNames[i]);
                    }
                  }

                  final pdfData = await generateInvoiceStickerPdf(
                    format: PdfPageFormat.a4,
                    // or your custom sticker size
                    invoiceNumber: invoice.invoiceNumber ?? "",
                    hnNumber: invoice.patient.hnNumber,
                    patientName: invoice.patient.name,
                    collectorName: invoice.createdByUser.name ?? "",
                    dob: appWidgets.convertDateTimeDDMMYYYY(
                      DateTime.tryParse(invoice.patient.dateOfBirth.toString()),
                    ),
                    create: appWidgets.convertDateTimeDDMMYYYY(
                      DateTime.tryParse(
                        (invoice.createDate ?? invoice.issuedDate).toString(),
                      ),
                    ),
                    genderAge:
                        "${invoice.patient.gender.toString()[0]} ${invoice.patient.age}",
                    // or map gender to word
                    selectedTests: selectedTests,
                    printLayoutModel:
                        context.read<PrintLayoutBloc>().layoutModel ??
                            PrintLayoutModel(),
                  );
                  await showInvoiceStickerDialog(
                    context,
                    pdfDataFuture: Future.value(pdfData),
                  );

                },
                name: 'Print',
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey.shade100,
            ),
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }
}
