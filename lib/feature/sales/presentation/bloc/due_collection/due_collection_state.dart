part of 'due_collection_bloc.dart';

@immutable
sealed class DueCollectionState {}

final class DueCollectionInitial extends DueCollectionState {}

class DueCollectionDetailsLoading extends DueCollectionState {}
class DueCollectionDetailsLoaded extends DueCollectionState {
  final InvoiceLocalModel moneyReceiptDetails;

  DueCollectionDetailsLoaded(this.moneyReceiptDetails);

  List<Object?> get props => [moneyReceiptDetails];
}

class DueCollectionDetailsError extends DueCollectionState {
  final String error;

  DueCollectionDetailsError(this.error);

  List<Object?> get props => [error];
}