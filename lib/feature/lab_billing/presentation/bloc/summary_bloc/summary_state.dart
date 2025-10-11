part of 'summary_bloc.dart';

@immutable
sealed class SummaryState {}

final class SummaryInitial extends SummaryState {}

class SummaryLoading extends SummaryState {}

class SummaryLoaded extends SummaryState {
  final Map<String, dynamic> summaryData;
  SummaryLoaded(this.summaryData);
}

class SummaryError extends SummaryState {
  final String message;
  SummaryError(this.message);
}