part of 'doctor_bloc.dart';
abstract class DoctorState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DoctorInitial extends DoctorState {}

class DoctorLoading extends DoctorState {}

class DoctorLoaded extends DoctorState {
  final List<DoctorLocalModel> doctors;
  DoctorLoaded(this.doctors);

  @override
  List<Object?> get props => [doctors];
}

class DoctorError extends DoctorState {
  final String message;
  DoctorError(this.message);

  @override
  List<Object?> get props => [message];
}
