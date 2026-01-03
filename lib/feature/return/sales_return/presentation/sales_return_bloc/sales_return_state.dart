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

  List<Object?> get props => [
    list,
    count,
    totalPages,
    currentPage,
    pageSize,
    from,
    to,
  ];
}

class SalesReturnCreateLoading extends SalesReturnState {}

class SalesReturnCreateSuccess extends SalesReturnState {
  final String message;
  final SalesReturnModel? salesReturn;

   SalesReturnCreateSuccess({
    required this.message,
    this.salesReturn,
  });

  List<Object?> get props => [message, salesReturn];
}

class SalesReturnApproveLoading extends SalesReturnState {}
class SalesReturnApproveSuccess extends SalesReturnState {
  final String message;
  final SalesReturnModel salesReturn;

   SalesReturnApproveSuccess({
    required this.message,
    required this.salesReturn,
  });

  List<Object?> get props => [message, salesReturn];
}

class SalesReturnRejectLoading extends SalesReturnState {}
class SalesReturnRejectSuccess extends SalesReturnState {
  final String message;
  final SalesReturnModel salesReturn;

   SalesReturnRejectSuccess({
    required this.message,
    required this.salesReturn,
  });

  List<Object?> get props => [message, salesReturn];
}

class SalesReturnCompleteLoading extends SalesReturnState {}
class SalesReturnCompleteSuccess extends SalesReturnState {
  final String message;
  final SalesReturnModel salesReturn;

   SalesReturnCompleteSuccess({
    required this.message,
    required this.salesReturn,
  });

  List<Object?> get props => [message, salesReturn];
}

class SalesReturnDetailsLoading extends SalesReturnState {}
class SalesReturnDetailsLoaded extends SalesReturnState {
  final SalesReturnModel salesReturn;

   SalesReturnDetailsLoaded(this.salesReturn);

  List<Object?> get props => [salesReturn];
}

class SalesReturnDeleteLoading extends SalesReturnState {}
class SalesReturnDeleteSuccess extends SalesReturnState {
  final String message;

   SalesReturnDeleteSuccess({required this.message});

  List<Object?> get props => [message];
}

class InvoiceListLoading extends SalesReturnState {}
class InvoiceListSuccess extends SalesReturnState {
  final List<SalesInvoiceModel> list;

   InvoiceListSuccess({required this.list});

  List<Object?> get props => [list];
}

class SalesReturnError extends SalesReturnState {
  final String title;
  final String content;

   SalesReturnError({
    required this.title,
    required this.content,
  });

  List<Object?> get props => [title, content];
}

class InvoiceError extends SalesReturnState {
  final String title;
  final String content;

   InvoiceError({
    required this.title,
    required this.content,
  });

  List<Object?> get props => [title, content];
}


class InvoiceSelected extends SalesReturnState {
  final SalesInvoiceModel invoice;
  InvoiceSelected({required this.invoice});
}

