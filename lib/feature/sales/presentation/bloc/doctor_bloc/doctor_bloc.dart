import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/doctors_model/doctor_model.dart';
import '../../../data/repositories/doctor_repo_db.dart';


part 'doctor_event.dart';
part 'doctor_state.dart';


class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final DoctorRepository repository=DoctorRepository();
  List<DoctorLocalModel>? doctor;
  DoctorBloc() : super(DoctorInitial()) {
    on<LoadDoctors>((event, emit) async {
      emit(DoctorLoading());
      try {
        final doctors = await repository.getDoctors();
        doctor=doctors;
        emit(DoctorLoaded(doctors));
      } catch (e) {
        emit(DoctorError(e.toString()));
      }
    });

  }
}
