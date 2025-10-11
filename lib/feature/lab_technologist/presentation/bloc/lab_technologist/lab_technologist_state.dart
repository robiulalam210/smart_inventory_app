part of 'lab_technologist_bloc.dart';

@immutable
sealed class LabTechnologistState {}

final class LabTechnologistInitial extends LabTechnologistState {}
class SingleTestInformationLoading extends LabTechnologistState {}

class SingleTestInformationLoaded extends LabTechnologistState {
  final SingleTestInformationModel model;

  SingleTestInformationLoaded(this.model);
}

class SingleTestInformationError extends LabTechnologistState {
  final String error;

  SingleTestInformationError(this.error);

  List<Object?> get props => [error];
}


class SingleReportInformationLoading extends LabTechnologistState {}

class SingleReportInformationLoaded extends LabTechnologistState {
  final ReportInformationModel model;

  SingleReportInformationLoaded(this.model);
}

class SingleReportInformationError extends LabTechnologistState {
  final String error;

  SingleReportInformationError(this.error);

  List<Object?> get props => [error];
}

class LabTechnologistLoading extends LabTechnologistState {}

class LabTechnologistSuccess extends LabTechnologistState {
  final String message;

  LabTechnologistSuccess(this.message);
}

class LabTechnologistError extends LabTechnologistState {
  final String error;

  LabTechnologistError(this.error);
}