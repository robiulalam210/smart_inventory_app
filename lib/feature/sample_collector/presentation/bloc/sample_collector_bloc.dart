import '/feature/sample_collector/data/model/sample_collector_model.dart';
import '/feature/sample_collector/data/repositories/sample_collector_repo_db.dart';

import '../../../../core/configs/configs.dart';

part 'sample_collector_event.dart';

part 'sample_collector_state.dart';

class SampleCollectorBloc
    extends Bloc<SampleCollectorEvent, SampleCollectorState> {
  final SampleCollectorRepoDb repository = SampleCollectorRepoDb();

  SampleCollectorBloc() : super(SampleCollectorInitial()) {
    on<LoadSampleCollectorInvoices>(_onLoadSampleCollectorInvoices);
    on<UpdateSampleCollectionEvent>(_onUpdateSampleCollector);
  }

  Future<void> _onLoadSampleCollectorInvoices(
    LoadSampleCollectorInvoices event,
    Emitter<SampleCollectorState> emit,
  ) async {
    emit(SampleCollectorInvoicesLoading());
    try {
      final invoices = await repository.fetchInvoicesWithSample(
        search: event.query,
        from: event.fromDate,
        to: event.toDate,
        pageNumber: event.pageNumber ?? 1,
        pageSize: event.pageSize ?? 10,
      );

      emit(SampleCollectorInvoicesLoaded(invoices));
    } catch (e) {
      debugPrint(e.toString());
      emit(SampleCollectorInvoicesError(e.toString()));
    }
  }

  Future<void> _onUpdateSampleCollector(
    UpdateSampleCollectionEvent event,
    Emitter<SampleCollectorState> emit,
  ) async {
    emit(SampleCollectorLoading());
    try {
      final invoices = await repository.updateSampleCollectionStatus(
        collectorId: event.collectorId,
        boothId: event.boothId,
        collectionDate: event.collectionDate,
        collectorName: event.collectorName,
        status: event.status,
        remark: event.remark,
        invoiceDetailIds: event.testIds,
      );

      debugPrint(
          "Updated Sample Collection Status: $invoices");

      emit(SampleCollectorLoaded());
    } catch (e) {
      debugPrint(e.toString());
      emit(SampleCollectorError(e.toString()));
    }
  }
}
