import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '/feature/lab_billing/presentation/bloc/patient_bloc/patient_event.dart';

import '../../../data/models/patient_model/patient_model.dart';
import '../../../data/repositories/patient_repo.dart';
import 'patient_state.dart';


class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientRepository patientRepository=PatientRepository();

  PatientBloc() : super(PatientInitial()) {
    on<FetchPatients>(_fetchPatients);
  }

  PatientLocalModel? patientData;

  List<PatientLocalModel>? patient;

  Future<void> _fetchPatients(
      FetchPatients event, Emitter<PatientState> emit) async {
    try {
      emit(PatientLoading());
      final patients = await patientRepository.fetchAllPatients();
      patient = patients;

      emit(PatientLoaded(patients));
    } catch (e) {
      emit(PatientError("Error fetching patients: ${e.toString()}"));
    }
  }
}
