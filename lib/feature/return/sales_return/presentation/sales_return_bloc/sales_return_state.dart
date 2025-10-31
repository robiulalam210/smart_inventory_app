part of 'sales_return_bloc.dart';

@immutable
sealed class SalesReturnState {}

class SalesReturnInitial extends SalesReturnState {}

class SalesReturnLoading extends SalesReturnState {}

class SalesReturnSuccess extends SalesReturnState {
  final List<SalesReturnModel> list;
  final int count;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final int from;
  final int to;

  SalesReturnSuccess({
    required this.list,
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.from,
    required this.to,
  });
}

class SalesReturnCreateLoading extends SalesReturnState {}
class SalesReturnCreateSuccess extends SalesReturnState {
  final String message;
  final SalesReturnCreatedModel salesReturn;

  SalesReturnCreateSuccess({
    required this.message,
    required this.salesReturn,
  });
}

class SalesReturnDetailsLoading extends SalesReturnState {}
class SalesReturnDetailsLoaded extends SalesReturnState {
  final SalesReturnModel salesReturn;
  SalesReturnDetailsLoaded(this.salesReturn);
}

class SalesReturnDeleteLoading extends SalesReturnState {}
class SalesReturnDeleteSuccess extends SalesReturnState {
  final String message;
  SalesReturnDeleteSuccess({required this.message});
}

class InvoiceListLoading extends SalesReturnState {}
class InvoiceListSuccess extends SalesReturnState {
  final List<SalesInvoiceModel> list;
  InvoiceListSuccess({required this.list});
}

class InvoiceError extends SalesReturnState {
  final String title;
  final String content;

  InvoiceError({required this.title, required this.content});
}
class InvoiceSelected extends SalesReturnState {
  final SalesInvoiceModel invoice;
  InvoiceSelected({required this.invoice});
}

class SalesReturnError extends SalesReturnState {
  final String title;
  final String content;

  SalesReturnError({required this.title, required this.content});
}