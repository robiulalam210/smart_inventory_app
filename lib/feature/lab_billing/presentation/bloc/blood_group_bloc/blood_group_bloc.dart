import 'package:bloc/bloc.dart';
import '/feature/lab_billing/data/models/common_model.dart';

import '../../../data/repositories/blood_repo_db.dart';

part 'blood_group_event.dart';
part 'blood_group_state.dart';

class BloodGroupBloc extends Bloc<BloodGroupEvent, BloodGroupState> {
  final BloodGroupRepositories repository=BloodGroupRepositories();

  List<BloodGroupLocalModel> bloodList=[];
  BloodGroupBloc() : super(BloodGroupInitial()) {
    on<LoadBloodGroups>(_onLoadBloodGroups);
  }

  Future<void> _onLoadBloodGroups(
      LoadBloodGroups event,
      Emitter<BloodGroupState> emit,
      ) async {
    emit(BloodGroupLoading());
    try {
      final bloodGroups = await repository.fetchAllBloodGroup();
      bloodList=bloodGroups;
      emit(BloodGroupLoaded(bloodGroups));
    } catch (e) {
      emit(BloodGroupError(e.toString()));
    }
  }
}
