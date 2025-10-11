import 'package:bloc/bloc.dart';
import '/feature/lab_billing/data/models/common_model.dart';

import '../../../data/repositories/gender_repo_db.dart';

part 'gender_event.dart';
part 'gender_state.dart';

class GenderBloc extends Bloc<GenderEvent, GenderState> {
  final GenderRepositories repository=GenderRepositories();

  List<GenderLocalModel> gender=[];
  GenderBloc() : super(GenderInitial()) {
    on<LoadGenders>(_onLoadGenders);
  }

  Future<void> _onLoadGenders(
      LoadGenders event,
      Emitter<GenderState> emit,
      ) async {
    emit(GenderLoading());
    try {
      final genders = await repository.fetchAllGender();
      gender=genders;
      emit(GenderLoaded(genders));
    } catch (e) {
      emit(GenderError(e.toString()));
    }
  }
}
