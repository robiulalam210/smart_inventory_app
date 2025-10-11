part of 'summary_bloc.dart';

@immutable
sealed class SummaryEvent {}
class LoadSummary extends SummaryEvent {
  final DateTime? fromDate;
  final DateTime? toDate;
  LoadSummary({this.fromDate, this.toDate});
}