import 'dart:io';

import '/feature/lab_technologist/data/repositories/lab_technologist_repo_db.dart';
import '../../../../../core/configs/configs.dart';
import '../../../data/model/single_report_model.dart';
import '../../../data/model/single_test_parameter_model.dart';

part 'lab_technologist_event.dart';

part 'lab_technologist_state.dart';

class LabTechnologistBloc
    extends Bloc<LabTechnologistEvent, LabTechnologistState> {
  final LabTechnologistRepoDb repository = LabTechnologistRepoDb();

  LabTechnologistBloc() : super(LabTechnologistInitial()) {
    on<LoadSingleTestInformation>(_onLoadSingleTestInformation);
    on<LoadSingleReportInformation>(_onLoadSingleReportInformation);
    on<SaveTestReportEvent>(_onSaveTestReport);
    on<UpdateReportDetailsEvent>(_onUpdateReportDetails);
    on<ConfirmReportEvent>(_onConfirmReport);
  }

  Future<void> _onLoadSingleTestInformation(
    LoadSingleTestInformation event,
    Emitter<LabTechnologistState> emit,
  ) async {
    emit(SingleTestInformationLoading());
    try {
      final invoices = await repository.getTestData(event.testId.toString());

      emit(SingleTestInformationLoaded(invoices));
    } catch (e) {
      debugPrint(e.toString());
      emit(SingleTestInformationError(e.toString()));
    }
  }

  Future<void> _onLoadSingleReportInformation(
    LoadSingleReportInformation event,
    Emitter<LabTechnologistState> emit,
  ) async {
    emit(SingleReportInformationLoading());
    try {
      final invoices = await repository.fetchLabReport(event.invoiceNo,event.testId.toString());
      // final invoices = await repository.fetchLabReportInformation(event.invoiceNo,event.testId.toString());

      emit(SingleReportInformationLoaded(invoices));
    } catch (e) {
      debugPrint(e.toString());
      emit(SingleReportInformationError(e.toString()));
    }
  }

  Future<void> _onSaveTestReport(
      SaveTestReportEvent event, Emitter<LabTechnologistState> emit) async {
    emit(LabTechnologistLoading());
    try {
      await repository.saveTestReport(
        invoiceId: event.invoiceId,
        invoiceNo: event.invoiceNo,
        invoiceApp: event.invoiceApp,
        patientId: event.patientId,
        testId: event.testId,
        testName: event.testName,
        testGroup: event.testGroup,
        testCategory: event.testCategory,
        gender: event.gender,
        technicianName: event.technicianName,
        validator: event.validator,
        remark: event.remark,
        radiologyReportImage: event.radiologyReportImage,
        radiologyReportDetails: event.radiologyReportDetails,
        parameterResults: event.parameterResults?.map((e) => e.toJson()).toList(),
      );

      emit(LabTechnologistSuccess('Test report saved successfully'));
    } catch (e) {
      emit(LabTechnologistError('Failed to save report: $e'));
    }
  }

  Future<void> _onUpdateReportDetails(
      UpdateReportDetailsEvent event,
      Emitter<LabTechnologistState> emit,
      ) async {
    emit(LabTechnologistLoading());
    try {
      await repository.updateReportDetails(
        event.details,
        radiologyReportDetails: event.radiologyReportDetails,
        radiologyReportImage: event.radiologyReportImage,
        labReportId: event.labReportId,
      );
      emit(LabTechnologistSuccess('Report details updated successfully'));
    } catch (e) {
      emit(LabTechnologistError('Failed to update details: $e'));
    }
  }


  Future<void> _onConfirmReport(
      ConfirmReportEvent event, Emitter<LabTechnologistState> emit) async {
    emit(LabTechnologistLoading());
    try {
      await repository.saveLabReportAndConfirmInvoice(
        invoiceNo: event.invoiceNo,
        testId: event.testId,
      );
      emit(LabTechnologistSuccess('Report confirmed successfully'));
    } catch (e) {
      emit(LabTechnologistError('Failed to confirm report: $e'));
    }
  }
}
