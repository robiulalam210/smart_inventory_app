import '../../../../../core/configs/configs.dart';
import '../../../../transactions/data/models/invoice_local_model.dart';
import '../../../data/repositories/due_collection_repo_db.dart';

part 'due_collection_event.dart';

part 'due_collection_state.dart';

class DueCollectionBloc extends Bloc<DueCollectionEvent, DueCollectionState> {
  final DueCollectionRepoDb repository = DueCollectionRepoDb();

  DueCollectionBloc() : super(DueCollectionInitial()) {
    on<LoadDueCollectionDetails>(_onLoadDueCollectionDetails);
  }

  Future<void> _onLoadDueCollectionDetails(
      LoadDueCollectionDetails event, Emitter<DueCollectionState> emit) async {
    emit(DueCollectionDetailsLoading());
    try {
      final invoice = await repository.fetchInvoiceFilter(event.invoiceId);

      if (invoice.invoiceNumber == "") {
        emit(DueCollectionDetailsError(""));
      }
      if (invoice.invoiceNumber != null && invoice.invoiceNumber != "") {
        emit(DueCollectionDetailsLoaded(invoice));
      } else {
        emit(DueCollectionDetailsError("Invoice Not Found"));
      }
    } catch (e, st) {
      debugPrint("Error loading invoice details: $e\n$st");
      emit(DueCollectionDetailsError(e.toString()));
    }
  }
}
