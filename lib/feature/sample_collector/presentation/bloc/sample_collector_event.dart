part of 'sample_collector_bloc.dart';

@immutable
sealed class SampleCollectorEvent {}
class LoadSampleCollectorInvoices extends SampleCollectorEvent {
  final String query;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? pageNumber;
  final int? pageSize;

  LoadSampleCollectorInvoices({
    this.query = '',
    this.fromDate,
    this.toDate,
    this.pageNumber,  // Default first page
    this.pageSize ,   // Default page size
  });
}
class UpdateSampleCollectionEvent extends SampleCollectorEvent {
  final String invoiceId;
  final String patientID;
  final int collectorId;
  final int boothId;
  final String collectorName;
  final String collectionDate;
  final String? remark;
  final String status;
  final List<int> testIds; // IDs for updating sample collection

   UpdateSampleCollectionEvent({
    required this.invoiceId,
    required this.patientID,
    required this.collectorId,
    required this.boothId,
    required this.collectorName,
    required this.collectionDate,
    this.remark,
    required this.status,
    required this.testIds,
  });

  List<Object?> get props => [
    invoiceId,
    collectorId,
    boothId,
    collectionDate,
    remark,
    status,
    testIds,
  ];
}
