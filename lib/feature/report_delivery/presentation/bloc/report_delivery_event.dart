part of 'report_delivery_bloc.dart';



abstract class ReportDeliveryEvent extends Equatable {
  const ReportDeliveryEvent();

  @override
  List<Object?> get props => [];
}

class SubmitReportDelivery extends ReportDeliveryEvent {
  final String invoiceNo;
  final String patientId;
  final String deliveryDate;
  final String deliveryTime;
  final String collectedBy;
  final String remark;
  final List<InvoiceDetail> selectedTests;

  const SubmitReportDelivery({
    required this.invoiceNo,
    required this.patientId,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.collectedBy,
    required this.remark,
    required this.selectedTests,
  });

  @override
  List<Object?> get props =>
      [invoiceNo, patientId, deliveryDate, deliveryTime, collectedBy, remark, selectedTests];
}
