import '/feature/sample_collector/data/model/booth_model.dart';
import '/feature/sample_collector/data/repositories/booth_repository_db.dart';
import '../../../../../core/configs/configs.dart';

part 'booth_event.dart';

part 'booth_state.dart';

class BoothBloc extends Bloc<BoothEvent, BoothState> {
  final BoothRepository repository = BoothRepository();

  List<BoothLocalModel>? boothModel;

  BoothBloc() : super(BoothInitial()) {
    on<LoadBooth>(_onLoadBooth);
  }

  Future<void> _onLoadBooth(LoadBooth event, Emitter<BoothState> emit) async {
    emit(BoothLoading());
    try {
      boothModel = await repository.getBooth();


      emit(BoothLoaded(List.from(boothModel ?? [])));
    } catch (e, s) {
      debugPrint(s.toString());
      emit(BoothError(e.toString()));
    }
  }}
