part of 'transaction_bloc.dart';

@immutable
sealed class TransactionEvent {}

class FetchTransactionList extends TransactionEvent {
  final BuildContext context;
  final String filterText;
  final String? accountId;
  final String? transactionType;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int pageNumber;
  final int pageSize;
  final bool noPagination;

   FetchTransactionList(
      this.context, {
        this.filterText = '',
        this.accountId,
        this.transactionType,
        this.status,
        this.startDate,
        this.endDate,
        this.pageNumber = 1,
        this.pageSize = 10,
        this.noPagination = false,
      });

  List<Object> get props => [
    context,
    filterText,
    pageNumber,
    pageSize,
    noPagination,
    accountId ?? '',
    transactionType ?? '',
    status ?? '',
    startDate ?? DateTime.now(),
    endDate ?? DateTime.now(),
  ];
}
