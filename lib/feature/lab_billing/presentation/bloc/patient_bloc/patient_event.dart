import 'package:equatable/equatable.dart';


abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

class DeletePatient extends PatientEvent {
  final String hnNumber;

  const DeletePatient(this.hnNumber);

  @override
  List<Object?> get props => [hnNumber];
}

class FetchPatients extends PatientEvent {}

