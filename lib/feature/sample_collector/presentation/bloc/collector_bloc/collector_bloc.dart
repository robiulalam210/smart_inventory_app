import '/feature/sample_collector/data/model/collector_model.dart';

import '../../../../../core/configs/configs.dart';
import '../../../data/repositories/collector_repository_db.dart';

part 'collector_event.dart';
part 'collector_state.dart';

class CollectorBloc extends Bloc<CollectorEvent, CollectorState> {
  final CollectorRepositoryDb repository=CollectorRepositoryDb();

  List<CollectorLocalModel>? collectorLocalModel;
  CollectorBloc() : super(CollectorInitial()) {
    on<LoadCollector>(_onLoadCollector);

  }
  Future<void> _onLoadCollector(LoadCollector event, Emitter<CollectorState> emit) async {
    emit(CollectorLoading());
    try {
      collectorLocalModel = await repository.getCollector();


      emit(CollectorLoaded(List.from(collectorLocalModel??[])));
    } catch (e, s) {
      debugPrint(s.toString());
      emit(CollectorError(e.toString()));
    }
  }

}
