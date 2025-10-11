import '../../../../../core/configs/configs.dart';
import '../../../../../core/repositories/post_response.dart';
import '../../../../lab_billing/data/repositories/lab_billing_db_repo.dart';
import '../../../../splash/presentation/bloc/connectivity_bloc/connectivity_bloc.dart';
import '../../../../splash/presentation/bloc/connectivity_bloc/connectivity_state.dart';
import '../../../data/models/invoice_server_response_model.dart';
import '../../../data/models/invoice_un_sync_model.dart';

part 'invoice_un_sync_event.dart';

part 'invoice_un_sync_state.dart';

class InvoiceUnSyncBloc extends Bloc<InvoiceUnSyncEvent, InvoiceUnSyncState> {
  final LabBillingRepository repository;
  final ConnectivityBloc connectivityBloc;
  bool _isLoading = false;

  InvoiceUnSyncBloc({required this.repository, required this.connectivityBloc})
      : super(InvoiceSyncInitial()) {
    on<LoadUnSyncInvoice>(_onLoadInvoices);
    on<PostUnSyncInvoice>(_postSyncInvoiceData);
  }

  /// Load unsynced invoices from local database
  Future<void> _onLoadInvoices(
    LoadUnSyncInvoice event,
    Emitter<InvoiceUnSyncState> emit,
  ) async {
    if (_isLoading) return; // ✅ Prevent re-entrance

    _isLoading = true;
    emit(InvoiceUnSyncLoading());
    try {
      final connectivityState = connectivityBloc.state;

      if (connectivityState is ConnectivityOffline) {
        emit(InvoiceSyncError(
            "No internet connection. Please try again later."));
        return;
      }
      final List<InvoiceUnSyncModel> invoices =
          await repository.fetchAllOfflineInvoiceDetails();

      if (invoices.isNotEmpty) {
        final List<Map<String, dynamic>> jsonList =
            invoices.map((invoice) => invoice.toJson()).toList();
        _isLoading = false;
        emit(InvoiceUnSyncLoaded(jsonList, isSingleSync: event.isSingleSync));
      } else {
        _isLoading = false;
        emit(InvoiceUnSyncEmpty());
      }
      // 👈 Emits usable unsynced invoice list
    } catch (e) {
      _isLoading = false;
      debugPrint("❌ Error loading invoices: $e");
      emit(InvoiceSyncError(e.toString()));
    }
  }

  /// Post unsynced invoices to the server
  Future<void> _postSyncInvoiceData(
    PostUnSyncInvoice event,
    Emitter<InvoiceUnSyncState> emit,
  ) async {
    emit(PostInvoiceUnSyncLoading());
    try {
      final Map<String, dynamic> data = {
        "records": event.body, // ✅ Pass list of invoices as array
      };


      final response = await postResponse(
        url: AppUrls.syncInvoice,
        payload: data, // ✅ Will be JSON-encoded in postResponse
      );

      final allSetupModel = invoiceSyncResponseModelFromJson(response);

      if (allSetupModel.statusCode == 200) {
        emit(PostInvoiceUnSyncLoaded(allSetupModel, event.invoiceCreate,
            isSingleSync: event.isSingleSync));
      } else {
        emit(PostInvoiceSyncError(allSetupModel.message ?? "Unknown error"));
      }
    } catch (e) {
        emit(PostInvoiceSyncError(e.toString()));


    }
  }
}
