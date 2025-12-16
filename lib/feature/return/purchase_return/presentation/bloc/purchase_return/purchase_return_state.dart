part of 'purchase_return_bloc.dart';

abstract class PurchaseReturnState extends Equatable {
  const PurchaseReturnState();

  @override
  List<Object?> get props => [];
}

class PurchaseReturnInitial extends PurchaseReturnState {}

class PurchaseReturnLoading extends PurchaseReturnState {}

class PurchaseReturnSuccess extends PurchaseReturnState {
  final List<PurchaseReturnModel> list;
  final int count;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final int from;
  final int to;

  const PurchaseReturnSuccess({
    required this.list,
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.from,
    required this.to,
  });

  @override
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

class PurchaseReturnCreateLoading extends PurchaseReturnState {}
class PurchaseReturnCreateSuccess extends PurchaseReturnState {
  final String message;
  final PurchaseReturnCreatedModel? purchaseReturn;

  const PurchaseReturnCreateSuccess({
    required this.message,
    this.purchaseReturn,
  });

  @override
  List<Object?> get props => [message, purchaseReturn];
}

class PurchaseReturnApproveLoading extends PurchaseReturnState {}
class PurchaseReturnApproveSuccess extends PurchaseReturnState {
  final String message;
  final PurchaseReturnModel purchaseReturn;

  const PurchaseReturnApproveSuccess({
    required this.message,
    required this.purchaseReturn,
  });

  @override
  List<Object?> get props => [message, purchaseReturn];
}

class PurchaseReturnRejectLoading extends PurchaseReturnState {}
class PurchaseReturnRejectSuccess extends PurchaseReturnState {
  final String message;
  final PurchaseReturnModel purchaseReturn;

  const PurchaseReturnRejectSuccess({
    required this.message,
    required this.purchaseReturn,
  });

  @override
  List<Object?> get props => [message, purchaseReturn];
}

class PurchaseReturnCompleteLoading extends PurchaseReturnState {}
class PurchaseReturnCompleteSuccess extends PurchaseReturnState {
  final String message;
  final PurchaseReturnModel purchaseReturn;

  const PurchaseReturnCompleteSuccess({
    required this.message,
    required this.purchaseReturn,
  });

  @override
  List<Object?> get props => [message, purchaseReturn];
}

class PurchaseReturnDetailsLoading extends PurchaseReturnState {}
class PurchaseReturnDetailsLoaded extends PurchaseReturnState {
  final PurchaseReturnModel purchaseReturn;

  const PurchaseReturnDetailsLoaded(this.purchaseReturn);

  @override
  List<Object?> get props => [purchaseReturn];
}

class PurchaseReturnDeleteLoading extends PurchaseReturnState {}
class PurchaseReturnDeleteSuccess extends PurchaseReturnState {
  final String message;

  const PurchaseReturnDeleteSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class PurchaseInvoiceListLoading extends PurchaseReturnState {}
class PurchaseInvoiceListSuccess extends PurchaseReturnState {
  final List<PurchaseInvoiceModel> list;

  const PurchaseInvoiceListSuccess({required this.list});

  @override
  List<Object?> get props => [list];
}

class PurchaseReturnError extends PurchaseReturnState {
  final String title;
  final String content;

  const PurchaseReturnError({
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [title, content];
}

class PurchaseInvoiceError extends PurchaseReturnState {
  final String title;
  final String content;

  const PurchaseInvoiceError({
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [title, content];
}
// abstract class PurchaseReturnState extends Equatable {
//   const PurchaseReturnState();
//
//   @override
//   List<Object> get props => [];
// }
//
// class PurchaseReturnInitial extends PurchaseReturnState {}
//
// class PurchaseReturnLoading extends PurchaseReturnState {}
//
// class PurchaseReturnSuccess extends PurchaseReturnState {
//   final List<PurchaseReturnModel> list;
//   final int count;
//   final int totalPages;
//   final int currentPage;
//   final int pageSize;
//   final int from;
//   final int to;
//
//   const PurchaseReturnSuccess({
//     required this.list,
//     required this.count,
//     required this.totalPages,
//     required this.currentPage,
//     required this.pageSize,
//     required this.from,
//     required this.to,
//   });
//
//   @override
//   List<Object> get props => [list, count, totalPages, currentPage, pageSize, from, to];
// }
//
// class PurchaseReturnCreateLoading extends PurchaseReturnState {}
//
// class PurchaseReturnCreateSuccess extends PurchaseReturnState {
//   final String message;
//   final PurchaseReturnCreatedModel purchaseReturn;
//
//   const PurchaseReturnCreateSuccess({
//     required this.message,
//     required this.purchaseReturn,
//   });
//
//   @override
//   List<Object> get props => [message, purchaseReturn];
// }
//
// class PurchaseReturnDetailsLoading extends PurchaseReturnState {}
//
// class PurchaseReturnDetailsLoaded extends PurchaseReturnState {
//   final PurchaseReturnModel purchaseReturn;
//
//   const PurchaseReturnDetailsLoaded(this.purchaseReturn);
//
//   @override
//   List<Object> get props => [purchaseReturn];
// }
//
// class PurchaseReturnDeleteLoading extends PurchaseReturnState {}
//
// class PurchaseReturnDeleteSuccess extends PurchaseReturnState {
//   final String message;
//
//   const PurchaseReturnDeleteSuccess({required this.message});
//
//   @override
//   List<Object> get props => [message];
// }
//
// class PurchaseInvoiceListLoading extends PurchaseReturnState {}
//
// class PurchaseInvoiceListSuccess extends PurchaseReturnState {
//   final List<PurchaseInvoiceModel> list;
//
//   const PurchaseInvoiceListSuccess({required this.list});
//
//   @override
//   List<Object> get props => [list];
// }
//
// class PurchaseInvoiceError extends PurchaseReturnState {
//   final String title;
//   final String content;
//
//   const PurchaseInvoiceError({required this.title, required this.content});
//
//   @override
//   List<Object> get props => [title, content];
// }
//
// class PurchaseReturnError extends PurchaseReturnState {
//   final String title;
//   final String content;
//
//   const PurchaseReturnError({required this.title, required this.content});
//
//   @override
//   List<Object> get props => [title, content];
// }