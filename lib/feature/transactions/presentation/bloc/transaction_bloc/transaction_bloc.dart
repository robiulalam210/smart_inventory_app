import '/feature/feature.dart';
import 'package:printing/printing.dart';

import '../../../../../core/configs/configs.dart';
import '../../../../../core/configs/pdf/lab_billing_dynamic_invoice.dart';
import '../../../../common/data/models/print_layout_model.dart';

part 'transaction_event.dart';

part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepoDb repository = TransactionRepoDb();

  TransactionBloc() : super(TransactionInitial()) {
    on<LoadTransactionInvoices>(_onLoadInvoices);
    on<LoadInvoiceTransactionDetails>(_onLoadInvoiceTranscationsDetails);
    on<LoadMoneyReceiptDetails>(_onLoadMoneyReceiptDetails);
  }

  Future<void> _onLoadInvoices(
    LoadTransactionInvoices event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionInvoicesLoading());
    try {
      final invoices = await repository.fetchInvoicesWithSummary(
        event.query,
        event.fromDate,
        event.toDate,
        event.pageNumber ?? 1,
        event.pageSize ?? 10,
      );

      debugPrint(
          'pageNumber: ${invoices.pageNumber} pageSize: ${invoices.pageSize}, totalCount: ${invoices.totalCount} totalPages ${invoices.totalPages}');

      emit(TransactionInvoicesLoaded(invoices));
    } catch (e) {
      debugPrint(e.toString());
      emit(TransactionInvoicesError(e.toString()));
    }
  }

  Future<void> _onLoadInvoiceTranscationsDetails(
      LoadInvoiceTransactionDetails event,
      Emitter<TransactionState> emit) async {
    emit(TransactionInvoicesDetailsLoading());
    try {
      final invoice = await repository.fetchInvoiceDetails(event.invoiceId);
      emit(TransactionInvoiceDetailsLoaded(invoice));



      Navigator.push(
        event.context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.red,
            body: PdfPreview.builder(
              useActions: true,
              allowSharing: false,
              canDebug: false,
              canChangeOrientation: false,
              canChangePageFormat: false,
              dynamicLayout: true,
              build: (format) => generatePdfDynamic(
                context,
                invoice,
               false,
                context.read<PrintLayoutBloc>().layoutModel ?? PrintLayoutModel(), // ✅ fixed

              ),
              pdfPreviewPageDecoration:
              const BoxDecoration(color: Colors.white),
              actionBarTheme: PdfActionBarTheme(
                backgroundColor: AppColors.primaryColor,
                iconColor: Colors.white,
                textStyle: const TextStyle(color: Colors.white),
              ),
              actions: [
                IconButton(
                  onPressed: () => AppRoutes.pop(context),
                  icon: const Icon(Icons.cancel, color: Colors.red),
                ),
              ],
              pagesBuilder: (context, pages) {
                debugPrint('Rendering ${pages.length} pages');
                return PageView.builder(
                  itemCount: pages.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return Container(
                      color: Colors.grey,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8.0),
                      child: Image(image: page.image, fit: BoxFit.contain),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

    } catch (e, st) {
      debugPrint("Error loading invoice details: $e\n$st");
      emit(TransactionInvoicesDetailsError(
          "Failed to load invoice details: ${e.toString()}"));
    }
  }

  Future<void> _onLoadMoneyReceiptDetails(
      LoadMoneyReceiptDetails event, Emitter<TransactionState> emit) async {
    emit(TransactionInvoicesDetailsLoading());
    try {
      final invoice = await repository.fetchMoneyReceiptDetails(event.invoiceId,
          isRefund: event.isRefund);
      emit(MoneyReceiptDetailsLoaded(invoice));




      Navigator.push(
        event.context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.red,
            body: PdfPreview.builder(
              useActions: true,
              allowSharing: false,
              canDebug: false,
              canChangeOrientation: false,
              canChangePageFormat: false,
              dynamicLayout: true,
              build: (format) => generatePdfDynamic(
                  context,
                  invoice,
                  event.isRefund,
                context.read<PrintLayoutBloc>().layoutModel ?? PrintLayoutModel(), // ✅ fixed

              ),
              pdfPreviewPageDecoration:
                  const BoxDecoration(color: Colors.white),
              actionBarTheme: PdfActionBarTheme(
                backgroundColor: AppColors.primaryColor,
                iconColor: Colors.white,
                textStyle: const TextStyle(color: Colors.white),
              ),
              actions: [
                IconButton(
                  onPressed: () => AppRoutes.pop(context),
                  icon: const Icon(Icons.cancel, color: Colors.red),
                ),
              ],
              pagesBuilder: (context, pages) {
                debugPrint('Rendering ${pages.length} pages');
                return PageView.builder(
                  itemCount: pages.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return Container(
                      color: Colors.grey,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8.0),
                      child: Image(image: page.image, fit: BoxFit.contain),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    } catch (e, st) {
      debugPrint("Error loading invoice details: $e\n$st");
      emit(MoneyReceiptDetailsError(
          "Failed to load invoice details: ${e.toString()}"));
    }
  }
}
