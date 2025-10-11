part of 'due_collection_bloc.dart';

@immutable
sealed class DueCollectionEvent {}
class LoadDueCollectionDetails extends DueCollectionEvent {
  final String invoiceId;

  LoadDueCollectionDetails(this.invoiceId, );

  List<Object?> get props => [invoiceId];
}
