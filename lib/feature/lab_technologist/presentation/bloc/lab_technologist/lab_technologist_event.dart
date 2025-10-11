part of 'lab_technologist_bloc.dart';

@immutable
sealed class LabTechnologistEvent {}

class LoadSingleTestInformation extends LabTechnologistEvent {
  final String testId;

  LoadSingleTestInformation({
    required this.testId, // Default page size
  });
}
class LoadSingleReportInformation extends LabTechnologistEvent {
  final String testId;
  final String invoiceNo;

  LoadSingleReportInformation({
    required this.testId, // Default page size
    required this.invoiceNo, // Default page size
  });
}

class SaveTestReportEvent extends LabTechnologistEvent {
  final String invoiceId;
  final String invoiceNo;
  final String invoiceApp;
  final String patientId;
  final String testId;
  final String testName;
  final String testGroup;
  final String testCategory;
  final String gender;
  final String? technicianName;
  final String? validator;
  final String? remark;
  final File? radiologyReportImage;
  final String? radiologyReportDetails;
  final List<TestParameter>? parameterResults;

  SaveTestReportEvent({
    required this.invoiceId,
    required this.invoiceNo,
    required this.invoiceApp,
    required this.patientId,
    required this.testId,
    required this.testName,
    required this.testGroup,
    required this.testCategory,
    required this.gender,
    this.technicianName,
    this.validator,
    this.remark,
    this.radiologyReportImage,
    this.radiologyReportDetails,
    this.parameterResults,
  });
}

class UpdateReportDetailsEvent extends LabTechnologistEvent {
  final List<Detail> details; // Pathology parameters
  final String? radiologyReportDetails; // Radiology HTML
  final String? labReportId; // Radiology HTML
  final File? radiologyReportImage; // Radiology image file

  UpdateReportDetailsEvent(
      this.details, {
        this.radiologyReportDetails,
        this.labReportId,
        this.radiologyReportImage,
      });
}


class ConfirmReportEvent extends LabTechnologistEvent {
  final String invoiceNo;
  final String testId;

  ConfirmReportEvent({required this.invoiceNo, required this.testId});
}
