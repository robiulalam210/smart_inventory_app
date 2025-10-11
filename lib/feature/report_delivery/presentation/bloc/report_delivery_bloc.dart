import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../sample_collector/data/model/sample_collector_model.dart';
import '../../data/repositories/report_delivery_repo_db.dart';

part 'report_delivery_event.dart';
part 'report_delivery_state.dart';


class ReportDeliveryBloc extends Bloc<ReportDeliveryEvent, ReportDeliveryState> {
  final ReportDeliveryRepoDb repo;

  ReportDeliveryBloc(this.repo) : super(ReportDeliveryInitial()) {
    on<SubmitReportDelivery>(_onSubmitReportDelivery);
  }

  Future<void> _onSubmitReportDelivery(
      SubmitReportDelivery event, Emitter<ReportDeliveryState> emit) async {
    emit(ReportDeliveryLoading());

    try {
       repo.insertReport(
        invoiceNo: event.invoiceNo,
        patientId: event.patientId,
        deliveryDate: event.deliveryDate,
        deliveryTime: event.deliveryTime,
        collectedBy: event.collectedBy,
        remark: event.remark,
        selectedTests: event.selectedTests,
      );

      emit(const ReportDeliverySuccess("Report delivery saved successfully."));
    } catch (e) {
      emit(ReportDeliveryFailure(e.toString()));
    }
  }
}
