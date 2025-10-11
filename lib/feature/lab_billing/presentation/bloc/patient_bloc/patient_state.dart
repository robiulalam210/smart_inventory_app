import 'package:equatable/equatable.dart';

import '../../../data/models/patient_model/patient_model.dart';




abstract class PatientState extends Equatable {
  const PatientState();

  @override
  List<Object?> get props => [];
}

class PatientInitial extends PatientState {}

class PatientLoading extends PatientState {}

class PatientLoaded extends PatientState {
  final List<PatientLocalModel> patients;

  const PatientLoaded(this.patients);

  @override
  List<Object?> get props => [patients];
}

class PatientAdded extends PatientState {
  final PatientLocalModel patient;

  const PatientAdded(this.patient);

  @override
  List<Object?> get props => [patient];
}

class PatientUpdated extends PatientState {
  final PatientLocalModel patient;

  final String message;

  const PatientUpdated({required this.patient, required this.message});

  @override
  List<Object?> get props => [message];
}

class PatientDeleted extends PatientState {
  final String message;

  const PatientDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

class PatientError extends PatientState {
  final String error;

  const PatientError(this.error);

  @override
  List<Object?> get props => [error];
}

